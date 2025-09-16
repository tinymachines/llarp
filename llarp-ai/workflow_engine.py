#!/usr/bin/env python3

import json
import time
import sys
import os
import hashlib
import subprocess
from datetime import datetime
from enum import Enum
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional, Any, Tuple
import requests

# Add paths for our components
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../repos/vectl/build"))
import vector_cluster_store_py

# Import our knowledge bridge
from knowledge_bridge import KnowledgeBridge

class WorkflowState(Enum):
    INIT = "init"
    DECOMPOSE = "decompose"
    SEARCH_KNOWLEDGE = "search_knowledge"
    PLAN = "plan"
    EXECUTE = "execute"
    REVIEW = "review"
    ARCHIVE = "archive"
    COMPLETE = "complete"
    ERROR = "error"

@dataclass
class WorkflowContext:
    request_id: str
    user_request: str
    current_state: WorkflowState
    timestamp: datetime
    decomposed_tasks: List[str] = None
    knowledge_results: List[Dict] = None
    execution_plan: Dict = None
    execution_results: Dict = None
    review_results: Dict = None
    archived_items: List[str] = None
    ollama_model: str = "llama3.2:latest"
    error_message: str = None
    metadata: Dict[str, Any] = None

    def __post_init__(self):
        if self.metadata is None:
            self.metadata = {}

class OllamaModelTester:
    """Test ollama models for various capabilities"""

    def __init__(self, base_url="http://127.0.0.1:11434"):
        self.base_url = base_url
        self.test_results = {}

    def list_available_models(self) -> List[str]:
        try:
            response = requests.get(f"{self.base_url}/api/tags")
            response.raise_for_status()
            models = [model["name"] for model in response.json().get("models", [])]
            return models
        except Exception as e:
            print(f"Error listing models: {e}")
            return []

    def test_model_capability(self, model_name: str, capability: str, test_prompt: str) -> Dict:
        """Test a specific capability of a model"""
        start_time = time.time()

        try:
            payload = {
                "model": model_name,
                "prompt": test_prompt,
                "stream": False,
                "options": {
                    "temperature": 0.1,
                    "top_p": 0.9
                }
            }

            response = requests.post(f"{self.base_url}/api/generate", json=payload)
            response.raise_for_status()

            result = response.json()
            elapsed_time = time.time() - start_time

            # Strip thinking tags from response
            response_text = result.get("response", "")
            cleaned_response = self._strip_thinking_tags(response_text)

            return {
                "capability": capability,
                "model": model_name,
                "success": True,
                "response": cleaned_response,
                "raw_response": response_text,  # Keep original for debugging
                "elapsed_time": elapsed_time,
                "total_duration": result.get("total_duration", 0) / 1_000_000_000,  # Convert to seconds
                "eval_count": result.get("eval_count", 0),
                "eval_duration": result.get("eval_duration", 0) / 1_000_000_000
            }

        except Exception as e:
            return {
                "capability": capability,
                "model": model_name,
                "success": False,
                "error": str(e),
                "elapsed_time": time.time() - start_time
            }

    def _strip_thinking_tags(self, text: str) -> str:
        """Strip thinking tags and similar problematic XML-like tags from response"""
        import re

        # Define patterns for tags to strip
        tag_patterns = [
            r'<think>.*?</think>',
            r'<thinking>.*?</thinking>',
            r'<thought>.*?</thought>',
            r'<analysis>.*?</analysis>',
            r'<reasoning>.*?</reasoning>',
            r'<internal>.*?</internal>',
            r'<scratch>.*?</scratch>'
        ]

        cleaned_text = text

        # Strip each pattern (case-insensitive, multiline, dotall)
        for pattern in tag_patterns:
            cleaned_text = re.sub(pattern, '', cleaned_text, flags=re.IGNORECASE | re.MULTILINE | re.DOTALL)

        # Clean up extra whitespace left by removed tags
        cleaned_text = re.sub(r'\n\s*\n', '\n\n', cleaned_text)  # Multiple newlines to double newlines
        cleaned_text = cleaned_text.strip()

        return cleaned_text

    def run_capability_tests(self, models: List[str] = None) -> Dict:
        """Run comprehensive capability tests on models"""

        if models is None:
            models = self.list_available_models()

        test_cases = {
            "decomposition": {
                "prompt": """Break down this technical request into specific actionable tasks:
'Configure a new OpenWRT router with secure WiFi, port forwarding for SSH, and basic firewall rules'

Respond with a JSON list of tasks like: ["task1", "task2", "task3"]""",
                "weight": 0.3
            },
            "technical_understanding": {
                "prompt": """Explain the security implications of enabling SSH password authentication on an OpenWRT router.
Be specific about the risks and provide 2-3 mitigation strategies. Keep response under 200 words.""",
                "weight": 0.25
            },
            "execution_planning": {
                "prompt": """Create a step-by-step execution plan to set up port forwarding on OpenWRT:
1. What UCI commands are needed?
2. What services need to be restarted?
3. How to verify the configuration worked?

Format as numbered steps.""",
                "weight": 0.25
            },
            "solution_synthesis": {
                "prompt": """Given these existing script fragments:
- change-hostname.sh: Changes router hostname via UCI
- create-wifi-network.sh: Sets up WiFi networks
- diagnose-connectivity.sh: Tests network connectivity

Design a new script that combines elements from these to create a 'quick-setup' script for new routers.
Describe the approach in 100-150 words.""",
                "weight": 0.2
            }
        }

        results = {}

        for model in models:
            print(f"\nTesting model: {model}")
            model_results = {}
            total_score = 0.0

            for capability, test_config in test_cases.items():
                print(f"  Testing {capability}...")
                result = self.test_model_capability(model, capability, test_config["prompt"])

                # Simple scoring based on success and response quality
                score = 0.0
                if result["success"]:
                    response_len = len(result["response"])
                    if response_len > 50:  # Minimum meaningful response
                        score = min(1.0, response_len / 500.0)  # Scale by response length
                        if result["elapsed_time"] < 10.0:  # Bonus for speed
                            score += 0.1

                result["score"] = score
                model_results[capability] = result
                total_score += score * test_config["weight"]

            model_results["overall_score"] = total_score
            results[model] = model_results

        self.test_results = results
        return results

    def get_best_model(self, capability: str = None) -> str:
        """Get the best model for a specific capability or overall"""
        if not self.test_results:
            return "llama3.2:latest"  # Default fallback

        if capability:
            best_model = None
            best_score = 0.0

            for model, results in self.test_results.items():
                if capability in results and results[capability]["score"] > best_score:
                    best_score = results[capability]["score"]
                    best_model = model

            return best_model or "llama3.2:latest"
        else:
            # Return best overall model
            best_model = max(self.test_results.keys(),
                           key=lambda m: self.test_results[m]["overall_score"])
            return best_model

class WorkflowEngine:
    """Main workflow state machine engine"""

    def __init__(self,
                 vectl_store_path="./workflow_knowledge.bin",
                 lego_store_path="../llarp-scripts",
                 ollama_base_url="http://127.0.0.1:11434"):

        self.vectl_store_path = vectl_store_path
        self.lego_store_path = lego_store_path
        self.ollama_base_url = ollama_base_url
        self.model_tester = OllamaModelTester(ollama_base_url)

        # Initialize knowledge bridge for vector search
        self.knowledge_bridge = KnowledgeBridge(vectl_store_path, ollama_base_url)

        # State transition map
        self.state_transitions = {
            WorkflowState.INIT: [WorkflowState.DECOMPOSE, WorkflowState.ERROR],
            WorkflowState.DECOMPOSE: [WorkflowState.SEARCH_KNOWLEDGE, WorkflowState.ERROR],
            WorkflowState.SEARCH_KNOWLEDGE: [WorkflowState.PLAN, WorkflowState.ERROR],
            WorkflowState.PLAN: [WorkflowState.EXECUTE, WorkflowState.ERROR],
            WorkflowState.EXECUTE: [WorkflowState.REVIEW, WorkflowState.ERROR],
            WorkflowState.REVIEW: [WorkflowState.ARCHIVE, WorkflowState.COMPLETE, WorkflowState.ERROR],
            WorkflowState.ARCHIVE: [WorkflowState.COMPLETE, WorkflowState.ERROR],
            WorkflowState.COMPLETE: [],
            WorkflowState.ERROR: [WorkflowState.COMPLETE]
        }

        # Load or initialize model performance data
        self.best_models = self._load_model_performance()

    def _load_model_performance(self) -> Dict[str, str]:
        """Load cached model performance data"""
        perf_file = "./model_performance.json"
        if os.path.exists(perf_file):
            try:
                with open(perf_file, 'r') as f:
                    return json.load(f)
            except:
                pass

        # Default model assignments - prefer mistral if available
        available_models = self.model_tester.list_available_models()

        # Check for preferred models
        preferred_model = "llama3.2:latest"  # fallback
        if "mistral-small3.2:24b" in available_models:
            preferred_model = "mistral-small3.2:24b"
        elif any("mistral" in m for m in available_models):
            # Use any available mistral model
            preferred_model = next(m for m in available_models if "mistral" in m)

        return {
            "decomposition": preferred_model,
            "technical_understanding": preferred_model,
            "execution_planning": preferred_model,
            "solution_synthesis": preferred_model
        }

    def _save_model_performance(self):
        """Save model performance data"""
        try:
            with open("./model_performance.json", 'w') as f:
                json.dump(self.best_models, f)
        except Exception as e:
            print(f"Warning: Could not save model performance: {e}")

    def test_and_select_models(self) -> Dict:
        """Test available models and select the best for each capability"""
        print("Testing ollama models for workflow capabilities...")

        available_models = self.model_tester.list_available_models()
        if not available_models:
            print("No ollama models found. Using defaults.")
            return self.best_models

        print(f"Found models: {available_models}")

        # Run capability tests
        results = self.model_tester.run_capability_tests(available_models)

        # Update best model selections
        capabilities = ["decomposition", "technical_understanding", "execution_planning", "solution_synthesis"]

        for capability in capabilities:
            best_model = self.model_tester.get_best_model(capability)
            self.best_models[capability] = best_model
            print(f"Best model for {capability}: {best_model}")

        # Save the results
        self._save_model_performance()

        return results

    def _call_ollama(self, prompt: str, model: str = None) -> str:
        """Call ollama with error handling and tag stripping"""
        if model is None:
            model = "llama3.2:latest"

        try:
            payload = {
                "model": model,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.1,
                    "top_p": 0.9
                }
            }

            response = requests.post(f"{self.ollama_base_url}/api/generate", json=payload)
            response.raise_for_status()

            response_text = response.json().get("response", "")

            # Strip thinking tags and similar problematic tags
            cleaned_response = self._strip_thinking_tags(response_text)

            return cleaned_response

        except Exception as e:
            print(f"Error calling ollama: {e}")
            return f"Error: {e}"

    def _strip_thinking_tags(self, text: str) -> str:
        """Strip thinking tags and similar problematic XML-like tags from response"""
        import re

        # Define patterns for tags to strip
        tag_patterns = [
            r'<think>.*?</think>',
            r'<thinking>.*?</thinking>',
            r'<thought>.*?</thought>',
            r'<analysis>.*?</analysis>',
            r'<reasoning>.*?</reasoning>',
            r'<internal>.*?</internal>',
            r'<scratch>.*?</scratch>'
        ]

        cleaned_text = text

        # Strip each pattern (case-insensitive, multiline, dotall)
        for pattern in tag_patterns:
            cleaned_text = re.sub(pattern, '', cleaned_text, flags=re.IGNORECASE | re.MULTILINE | re.DOTALL)

        # Clean up extra whitespace left by removed tags
        cleaned_text = re.sub(r'\n\s*\n', '\n\n', cleaned_text)  # Multiple newlines to double newlines
        cleaned_text = cleaned_text.strip()

        return cleaned_text

    def _search_knowledge_base(self, query: str, k: int = 5) -> List[Dict]:
        """Search the knowledge base using vector similarity"""
        try:
            return self.knowledge_bridge.search_knowledge(query, k)
        except Exception as e:
            print(f"Knowledge search error: {e}")
            return []

    def _scan_lego_scripts(self) -> List[Dict]:
        """Scan the lego script directory for available scripts"""
        legos = []

        try:
            if os.path.exists(self.lego_store_path):
                for filename in os.listdir(self.lego_store_path):
                    if filename.endswith('.sh'):
                        filepath = os.path.join(self.lego_store_path, filename)

                        # Extract basic info from script
                        with open(filepath, 'r') as f:
                            content = f.read()

                        # Simple parsing for description/usage
                        description = "No description available"
                        lines = content.split('\n')
                        for line in lines[:10]:  # Check first 10 lines
                            if line.startswith('#') and len(line) > 2:
                                desc_candidate = line[1:].strip()
                                if len(desc_candidate) > 10:
                                    description = desc_candidate
                                    break

                        legos.append({
                            "name": filename,
                            "path": filepath,
                            "description": description,
                            "size": len(content)
                        })

        except Exception as e:
            print(f"Error scanning lego scripts: {e}")

        return legos

    def create_workflow_context(self, user_request: str) -> WorkflowContext:
        """Create a new workflow context"""
        request_id = hashlib.md5(f"{user_request}{time.time()}".encode()).hexdigest()[:8]

        return WorkflowContext(
            request_id=request_id,
            user_request=user_request,
            current_state=WorkflowState.INIT,
            timestamp=datetime.now(),
            ollama_model=self.best_models.get("decomposition", "llama3.2:latest")
        )

    def transition_state(self, context: WorkflowContext, new_state: WorkflowState) -> bool:
        """Transition to a new state if valid"""
        if new_state in self.state_transitions[context.current_state]:
            context.current_state = new_state
            print(f"[{context.request_id}] State: {context.current_state.value}")
            return True
        else:
            print(f"[{context.request_id}] Invalid transition: {context.current_state.value} -> {new_state.value}")
            return False

    def process_init(self, context: WorkflowContext) -> bool:
        """Initialize the workflow"""
        print(f"[{context.request_id}] Initializing workflow for: {context.user_request[:100]}...")

        # Basic validation
        if not context.user_request or len(context.user_request.strip()) < 5:
            context.error_message = "Request too short or empty"
            return self.transition_state(context, WorkflowState.ERROR)

        context.metadata["start_time"] = time.time()
        return self.transition_state(context, WorkflowState.DECOMPOSE)

    def process_decompose(self, context: WorkflowContext) -> bool:
        """Decompose the user request into actionable tasks"""
        print(f"[{context.request_id}] Decomposing request...")

        model = self.best_models.get("decomposition", "llama3.2:latest")

        prompt = f"""Break down this OpenWRT/networking request into specific actionable tasks:

Request: "{context.user_request}"

Respond with a JSON array of specific tasks, each task should be:
- Actionable and specific
- Focused on OpenWRT/networking concepts
- Technical and implementable

Example format: ["Configure WiFi network", "Set up port forwarding", "Install packages"]

JSON array:"""

        response = self._call_ollama(prompt, model)

        try:
            # Extract JSON from response
            response = response.strip()
            if response.startswith('[') and response.endswith(']'):
                tasks = json.loads(response)
                context.decomposed_tasks = tasks
                print(f"[{context.request_id}] Decomposed into {len(tasks)} tasks")
                return self.transition_state(context, WorkflowState.SEARCH_KNOWLEDGE)
            else:
                # Fallback parsing
                tasks = [line.strip(' -"') for line in response.split('\n') if line.strip()]
                context.decomposed_tasks = tasks[:5]  # Limit to 5 tasks
                return self.transition_state(context, WorkflowState.SEARCH_KNOWLEDGE)

        except Exception as e:
            context.error_message = f"Failed to decompose request: {e}"
            return self.transition_state(context, WorkflowState.ERROR)

    def process_search_knowledge(self, context: WorkflowContext) -> bool:
        """Search for relevant knowledge and existing solutions"""
        print(f"[{context.request_id}] Searching knowledge base...")

        # Search vector store for similar solutions
        knowledge_results = []
        for task in context.decomposed_tasks:
            results = self._search_knowledge_base(task)
            knowledge_results.extend(results)

        # Scan available lego scripts
        lego_scripts = self._scan_lego_scripts()

        context.knowledge_results = {
            "vector_search": knowledge_results,
            "lego_scripts": lego_scripts
        }

        print(f"[{context.request_id}] Found {len(lego_scripts)} lego scripts")
        return self.transition_state(context, WorkflowState.PLAN)

    def process_plan(self, context: WorkflowContext) -> bool:
        """Create an execution plan"""
        print(f"[{context.request_id}] Creating execution plan...")

        model = self.best_models.get("execution_planning", "llama3.2:latest")

        # Build context for planning
        available_legos = context.knowledge_results.get("lego_scripts", [])
        lego_descriptions = "\n".join([f"- {lego['name']}: {lego['description']}" for lego in available_legos])

        prompt = f"""Create an execution plan for these tasks:
Tasks: {json.dumps(context.decomposed_tasks)}

Available script legos:
{lego_descriptions}

Original request: "{context.user_request}"

Create a step-by-step execution plan that:
1. Uses existing lego scripts where possible
2. Identifies what new scripts need to be created
3. Specifies the order of execution
4. Includes validation steps

Format as JSON with this structure:
{{
  "steps": [
    {{
      "order": 1,
      "action": "use_existing_lego",
      "script": "script-name.sh",
      "parameters": "param1 param2",
      "description": "What this step does"
    }},
    {{
      "order": 2,
      "action": "create_new_script",
      "script_name": "new-script.sh",
      "functionality": "What the new script should do",
      "description": "Purpose of this script"
    }}
  ],
  "validation": ["Test step 1", "Test step 2"]
}}

JSON response:"""

        response = self._call_ollama(prompt, model)

        try:
            # Extract and parse JSON
            if '{' in response and '}' in response:
                json_start = response.find('{')
                json_end = response.rfind('}') + 1
                json_str = response[json_start:json_end]
                plan = json.loads(json_str)
                context.execution_plan = plan
                print(f"[{context.request_id}] Created plan with {len(plan.get('steps', []))} steps")
                return self.transition_state(context, WorkflowState.EXECUTE)
            else:
                raise ValueError("No valid JSON found in response")

        except Exception as e:
            context.error_message = f"Failed to create execution plan: {e}"
            return self.transition_state(context, WorkflowState.ERROR)

    def process_execute(self, context: WorkflowContext) -> bool:
        """Execute the plan"""
        print(f"[{context.request_id}] Executing plan...")

        execution_results = {
            "executed_steps": [],
            "created_scripts": [],
            "errors": []
        }

        steps = context.execution_plan.get("steps", [])

        for step in steps:
            try:
                if step["action"] == "use_existing_lego":
                    # For now, just record that we would use this script
                    result = {
                        "step": step,
                        "status": "simulated",
                        "message": f"Would execute: {step['script']} {step.get('parameters', '')}"
                    }
                    execution_results["executed_steps"].append(result)
                    print(f"  [SIMULATE] {result['message']}")

                elif step["action"] == "create_new_script":
                    # Generate the new script content
                    script_content = self._generate_script(step, context)
                    if script_content:
                        script_path = os.path.join(self.lego_store_path, step["script_name"])

                        # For safety, don't actually write during testing
                        execution_results["created_scripts"].append({
                            "script_name": step["script_name"],
                            "path": script_path,
                            "content": script_content,
                            "status": "generated"
                        })
                        print(f"  [GENERATE] Created script: {step['script_name']}")
                    else:
                        execution_results["errors"].append(f"Failed to generate {step['script_name']}")

            except Exception as e:
                execution_results["errors"].append(f"Error in step {step.get('order', '?')}: {e}")

        context.execution_results = execution_results
        print(f"[{context.request_id}] Execution completed with {len(execution_results['errors'])} errors")
        return self.transition_state(context, WorkflowState.REVIEW)

    def _generate_script(self, step: Dict, context: WorkflowContext) -> str:
        """Generate script content using ollama"""
        model = self.best_models.get("solution_synthesis", "llama3.2:latest")

        prompt = f"""Generate a bash script for OpenWRT with this specification:

Script name: {step['script_name']}
Functionality: {step['functionality']}
Description: {step['description']}

Requirements:
- Must be a complete, executable bash script
- Use OpenWRT UCI commands where appropriate
- Include error handling and validation
- Add comments explaining key steps
- Follow the style of existing llarp-scripts

Generate the complete script content:"""

        response = self._call_ollama(prompt, model)

        # Clean up the response to extract script content
        if '#!/bin/bash' in response or '#!/usr/bin/env bash' in response:
            return response
        else:
            # Add shebang if missing
            return f"#!/bin/bash\n\n{response}"

    def process_review(self, context: WorkflowContext) -> bool:
        """Review the execution results"""
        print(f"[{context.request_id}] Reviewing results...")

        results = context.execution_results
        errors = results.get("errors", [])
        created_scripts = results.get("created_scripts", [])

        review_results = {
            "success": len(errors) == 0,
            "error_count": len(errors),
            "scripts_created": len(created_scripts),
            "quality_score": 0.8 if len(errors) == 0 else 0.4,
            "archivable_items": []
        }

        # Determine what should be archived
        for script in created_scripts:
            if script["status"] == "generated" and len(script["content"]) > 100:
                review_results["archivable_items"].append(script)

        context.review_results = review_results

        if review_results["success"] and review_results["archivable_items"]:
            return self.transition_state(context, WorkflowState.ARCHIVE)
        else:
            return self.transition_state(context, WorkflowState.COMPLETE)

    def process_archive(self, context: WorkflowContext) -> bool:
        """Archive successful solutions to the lego box"""
        print(f"[{context.request_id}] Archiving solutions...")

        archived_items = []

        for item in context.review_results["archivable_items"]:
            # For safety, don't actually write files in this implementation
            # In production, you would write the script and add metadata

            tags = self._generate_tags(item, context)
            archived_item = {
                "script_name": item["script_name"],
                "tags": tags,
                "request_id": context.request_id,
                "archived_at": datetime.now().isoformat()
            }
            archived_items.append(archived_item)
            print(f"  [ARCHIVE] {item['script_name']} with tags: {', '.join(tags)}")

        context.archived_items = archived_items
        return self.transition_state(context, WorkflowState.COMPLETE)

    def _generate_tags(self, script_item: Dict, context: WorkflowContext) -> List[str]:
        """Generate relevant tags for a script"""
        tags = ["auto-generated"]

        # Extract keywords from request and script content
        content = script_item["content"].lower()
        request = context.user_request.lower()

        # Common OpenWRT/networking tags
        tag_keywords = {
            "wifi": ["wifi", "wireless", "ssid"],
            "firewall": ["firewall", "iptables", "port"],
            "network": ["network", "interface", "ip"],
            "ssh": ["ssh", "dropbear"],
            "dhcp": ["dhcp", "dnsmasq"],
            "uci": ["uci", "config"],
            "routing": ["route", "gateway", "routing"]
        }

        for tag, keywords in tag_keywords.items():
            if any(keyword in content or keyword in request for keyword in keywords):
                tags.append(tag)

        return tags

    def process_complete(self, context: WorkflowContext) -> Dict:
        """Complete the workflow and return results"""
        context.metadata["end_time"] = time.time()
        context.metadata["duration"] = context.metadata["end_time"] - context.metadata["start_time"]

        print(f"[{context.request_id}] Workflow completed in {context.metadata['duration']:.2f}s")

        return {
            "request_id": context.request_id,
            "success": context.current_state == WorkflowState.COMPLETE,
            "duration": context.metadata["duration"],
            "decomposed_tasks": context.decomposed_tasks,
            "execution_results": context.execution_results,
            "review_results": context.review_results,
            "archived_items": context.archived_items,
            "error_message": context.error_message
        }

    def process_error(self, context: WorkflowContext) -> Dict:
        """Handle error state"""
        print(f"[{context.request_id}] Error: {context.error_message}")
        return self.process_complete(context)

    def run_workflow(self, user_request: str) -> Dict:
        """Run the complete workflow for a user request"""
        context = self.create_workflow_context(user_request)

        # State processing map
        processors = {
            WorkflowState.INIT: self.process_init,
            WorkflowState.DECOMPOSE: self.process_decompose,
            WorkflowState.SEARCH_KNOWLEDGE: self.process_search_knowledge,
            WorkflowState.PLAN: self.process_plan,
            WorkflowState.EXECUTE: self.process_execute,
            WorkflowState.REVIEW: self.process_review,
            WorkflowState.ARCHIVE: self.process_archive,
            WorkflowState.COMPLETE: self.process_complete,
            WorkflowState.ERROR: self.process_error
        }

        # Run the state machine
        max_iterations = 20  # Prevent infinite loops
        iteration = 0

        while context.current_state not in [WorkflowState.COMPLETE, WorkflowState.ERROR] and iteration < max_iterations:
            processor = processors[context.current_state]
            processor(context)
            iteration += 1

        # Final processing
        if context.current_state == WorkflowState.COMPLETE:
            return self.process_complete(context)
        else:
            return self.process_error(context)

def main():
    """Main CLI interface for the workflow engine"""
    import argparse

    parser = argparse.ArgumentParser(description="LLARP Workflow Engine")
    parser.add_argument("--test-models", action="store_true", help="Test and select best ollama models")
    parser.add_argument("--request", type=str, help="Process a specific request")
    parser.add_argument("--interactive", action="store_true", help="Interactive mode")

    args = parser.parse_args()

    engine = WorkflowEngine()

    if args.test_models:
        print("Testing ollama models...")
        results = engine.test_and_select_models()
        print("\nModel test results:")
        for model, model_results in results.items():
            print(f"\n{model}: Overall score: {model_results['overall_score']:.3f}")
            for capability, result in model_results.items():
                if capability != "overall_score":
                    status = "✓" if result.get("success", False) else "✗"
                    score = result.get("score", 0)
                    print(f"  {status} {capability}: {score:.3f}")

    elif args.request:
        print(f"Processing request: {args.request}")
        result = engine.run_workflow(args.request)
        print("\nWorkflow Result:")
        print(json.dumps(result, indent=2, default=str))

    elif args.interactive:
        print("LLARP Workflow Engine - Interactive Mode")
        print("========================================")

        while True:
            try:
                request = input("\nEnter your request (or 'quit' to exit): ")
                if request.lower() in ['quit', 'exit', 'q']:
                    break

                if request.strip():
                    result = engine.run_workflow(request)
                    print(f"\nResult: {'SUCCESS' if result['success'] else 'FAILED'}")
                    if result.get('decomposed_tasks'):
                        print(f"Tasks: {', '.join(result['decomposed_tasks'])}")
                    if result.get('error_message'):
                        print(f"Error: {result['error_message']}")

            except KeyboardInterrupt:
                print("\nExiting...")
                break

    else:
        print("Use --help for usage options")

if __name__ == "__main__":
    main()