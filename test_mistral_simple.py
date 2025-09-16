#!/usr/bin/env python3

import requests
import json
import time
import re

def strip_thinking_tags(text: str) -> str:
    """Strip thinking tags and similar problematic XML-like tags from response"""
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

def call_ollama(prompt: str, model: str = "mistral-small3.2:24b") -> dict:
    """Call ollama with error handling and tag stripping"""
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

        response = requests.post("http://127.0.0.1:11434/api/generate", json=payload)
        response.raise_for_status()

        result = response.json()
        response_text = result.get("response", "")

        # Strip thinking tags
        cleaned_response = strip_thinking_tags(response_text)

        return {
            "success": True,
            "response": cleaned_response,
            "raw_response": response_text,
            "had_thinking_tags": response_text != cleaned_response,
            "elapsed_time": result.get("total_duration", 0) / 1_000_000_000
        }

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }

def test_mistral_capabilities():
    """Test mistral-small3.2:24b capabilities"""
    print("=" * 60)
    print("TESTING MISTRAL-SMALL3.2:24B CAPABILITIES")
    print("=" * 60)

    test_cases = {
        "decomposition": {
            "prompt": """Break down this technical request into specific actionable tasks:
'Configure a new OpenWRT router with secure WiFi, port forwarding for SSH, and basic firewall rules'

Respond with a JSON list of tasks like: ["task1", "task2", "task3"]""",
        },
        "technical_understanding": {
            "prompt": """Explain the security implications of enabling SSH password authentication on an OpenWRT router.
Be specific about the risks and provide 2-3 mitigation strategies. Keep response under 200 words.""",
        },
        "execution_planning": {
            "prompt": """Create a step-by-step execution plan to set up port forwarding on OpenWRT:
1. What UCI commands are needed?
2. What services need to be restarted?
3. How to verify the configuration worked?

Format as numbered steps.""",
        },
        "solution_synthesis": {
            "prompt": """Given these existing script fragments:
- change-hostname.sh: Changes router hostname via UCI
- create-wifi-network.sh: Sets up WiFi networks
- diagnose-connectivity.sh: Tests network connectivity

Design a new script that combines elements from these to create a 'quick-setup' script for new routers.
Describe the approach in 100-150 words.""",
        }
    }

    results = {}

    for capability, test_config in test_cases.items():
        print(f"\n{'='*40}")
        print(f"Testing: {capability}")
        print(f"{'='*40}")

        start_time = time.time()
        result = call_ollama(test_config["prompt"])
        result["test_elapsed"] = time.time() - start_time

        if result["success"]:
            print(f"✓ Success | Time: {result['test_elapsed']:.2f}s")
            print(f"Response length: {len(result['response'])} chars")

            # Check if thinking tags were stripped
            if result["had_thinking_tags"]:
                print("🧹 Thinking tags were stripped from response")
                raw_len = len(result['raw_response'])
                clean_len = len(result['response'])
                print(f"Raw: {raw_len} chars → Cleaned: {clean_len} chars")

                # Show what was stripped (first 100 chars of difference)
                raw_preview = result['raw_response'][:100]
                clean_preview = result['response'][:100]
                if raw_preview != clean_preview:
                    print("Stripped content preview:")
                    print(f"  Raw start: {raw_preview}...")
                    print(f"  Clean start: {clean_preview}...")

            print(f"\nResponse preview:")
            preview = result['response'][:300]
            if len(result['response']) > 300:
                preview += "..."
            print(preview)

            # Try to validate response format for decomposition
            if capability == "decomposition":
                try:
                    response = result['response'].strip()
                    if '[' in response and ']' in response:
                        start = response.find('[')
                        end = response.rfind(']') + 1
                        json_part = response[start:end]
                        tasks = json.loads(json_part)
                        print(f"✓ Valid JSON with {len(tasks)} tasks")
                        for i, task in enumerate(tasks, 1):
                            print(f"  {i}. {task}")
                    else:
                        print("⚠ No JSON array found in response")
                except Exception as e:
                    print(f"✗ JSON parsing failed: {e}")

        else:
            print(f"✗ Failed | Error: {result['error']}")

        results[capability] = result

    return results

def test_workflow_steps():
    """Test individual workflow steps with Mistral"""
    print(f"\n{'='*60}")
    print("TESTING WORKFLOW STEPS WITH MISTRAL")
    print(f"{'='*60}")

    # Test decomposition
    print("\n1. DECOMPOSITION TEST")
    print("-" * 30)

    decomp_result = call_ollama("""Break down this request: "Set up a secure OpenWRT router with guest WiFi"

Respond with a JSON array of specific tasks: ["task1", "task2", "task3"]""")

    if decomp_result["success"]:
        print("✓ Decomposition successful")
        if decomp_result["had_thinking_tags"]:
            print("✓ Thinking tags stripped")

        # Try to extract and parse JSON
        response = decomp_result["response"]
        try:
            if '[' in response and ']' in response:
                start = response.find('[')
                end = response.rfind(']') + 1
                json_part = response[start:end]
                tasks = json.loads(json_part)
                print(f"Parsed {len(tasks)} tasks:")
                for i, task in enumerate(tasks, 1):
                    print(f"  {i}. {task}")
        except:
            print("Could not parse JSON from response")
            print(f"Response: {response[:200]}...")
    else:
        print(f"✗ Decomposition failed: {decomp_result['error']}")

    # Test execution planning
    print("\n2. EXECUTION PLANNING TEST")
    print("-" * 30)

    plan_result = call_ollama("""Create a step-by-step plan to configure WiFi on OpenWRT:

Format as JSON:
{
  "steps": [
    {"order": 1, "action": "use_existing_lego", "script": "script-name.sh", "description": "What this does"},
    {"order": 2, "action": "create_new_script", "script_name": "new-script.sh", "functionality": "What it should do"}
  ]
}""")

    if plan_result["success"]:
        print("✓ Planning successful")
        if plan_result["had_thinking_tags"]:
            print("✓ Thinking tags stripped")

        # Try to parse JSON
        response = plan_result["response"]
        try:
            if '{' in response and '}' in response:
                start = response.find('{')
                end = response.rfind('}') + 1
                json_part = response[start:end]
                plan = json.loads(json_part)
                steps = plan.get("steps", [])
                print(f"Parsed plan with {len(steps)} steps:")
                for step in steps:
                    print(f"  {step.get('order')}. {step.get('action')} - {step.get('description', 'No description')}")
        except Exception as e:
            print(f"Could not parse JSON: {e}")
            print(f"Response: {response[:200]}...")
    else:
        print(f"✗ Planning failed: {plan_result['error']}")

def main():
    """Main test function"""
    print("MISTRAL-SMALL3.2:24B SIMPLIFIED TEST")
    print("=" * 60)

    # Check if ollama is running
    try:
        response = requests.get("http://127.0.0.1:11434/api/tags")
        models = [model["name"] for model in response.json().get("models", [])]
        if "mistral-small3.2:24b" not in models:
            print("ERROR: mistral-small3.2:24b not found in ollama")
            print(f"Available models: {models}")
            return
        else:
            print(f"✓ Found mistral-small3.2:24b in {len(models)} available models")
    except Exception as e:
        print(f"ERROR: Cannot connect to ollama: {e}")
        return

    # Test 1: Individual capability tests
    print("\nRunning capability tests...")
    capability_results = test_mistral_capabilities()

    # Test 2: Workflow step tests
    test_workflow_steps()

    # Summary
    print(f"\n{'='*60}")
    print("FINAL SUMMARY")
    print(f"{'='*60}")

    capability_success = sum(1 for r in capability_results.values() if r["success"])
    capability_total = len(capability_results)

    print(f"Capability Tests: {capability_success}/{capability_total} passed")

    # Check thinking tag handling
    stripped_count = sum(1 for r in capability_results.values()
                        if r.get("success") and r.get("had_thinking_tags"))
    if stripped_count > 0:
        print(f"Thinking Tag Stripping: {stripped_count} responses cleaned")

    # Performance metrics
    if capability_success > 0:
        successful_results = [r for r in capability_results.values() if r["success"]]
        avg_time = sum(r.get("test_elapsed", 0) for r in successful_results) / len(successful_results)
        print(f"Average response time: {avg_time:.2f}s")

    overall_success = capability_success >= 3
    print(f"\nOverall Assessment: {'✓ MISTRAL COMPATIBLE' if overall_success else '✗ NEEDS TUNING'}")

    if overall_success:
        print("Mistral-small3.2:24b works well with thinking tag stripping!")
        if stripped_count > 0:
            print("✓ Thinking tags are being properly stripped from responses")
    else:
        print("Mistral-small3.2:24b may need additional configuration.")

if __name__ == "__main__":
    main()