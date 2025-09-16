#!/usr/bin/env python3

import sys
import os
import time
import json

# Add llarp-ai to path
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "llarp-ai"))

from workflow_engine import WorkflowEngine, OllamaModelTester

def test_mistral_capabilities():
    """Test mistral-small3.2:24b capabilities specifically"""
    print("=" * 60)
    print("TESTING MISTRAL-SMALL3.2:24B CAPABILITIES")
    print("=" * 60)

    model = "mistral-small3.2:24b"
    tester = OllamaModelTester()

    # Test each capability individually
    test_cases = {
        "decomposition": {
            "prompt": """Break down this technical request into specific actionable tasks:
'Configure a new OpenWRT router with secure WiFi, port forwarding for SSH, and basic firewall rules'

Respond with a JSON list of tasks like: ["task1", "task2", "task3"]""",
            "expected_format": "JSON array"
        },
        "technical_understanding": {
            "prompt": """Explain the security implications of enabling SSH password authentication on an OpenWRT router.
Be specific about the risks and provide 2-3 mitigation strategies. Keep response under 200 words.""",
            "expected_format": "Technical explanation"
        },
        "execution_planning": {
            "prompt": """Create a step-by-step execution plan to set up port forwarding on OpenWRT:
1. What UCI commands are needed?
2. What services need to be restarted?
3. How to verify the configuration worked?

Format as numbered steps.""",
            "expected_format": "Numbered steps"
        },
        "solution_synthesis": {
            "prompt": """Given these existing script fragments:
- change-hostname.sh: Changes router hostname via UCI
- create-wifi-network.sh: Sets up WiFi networks
- diagnose-connectivity.sh: Tests network connectivity

Design a new script that combines elements from these to create a 'quick-setup' script for new routers.
Describe the approach in 100-150 words.""",
            "expected_format": "Script design description"
        }
    }

    results = {}

    for capability, test_config in test_cases.items():
        print(f"\n{'='*40}")
        print(f"Testing: {capability}")
        print(f"{'='*40}")

        result = tester.test_model_capability(model, capability, test_config["prompt"])

        if result["success"]:
            print(f"✓ Success | Time: {result['elapsed_time']:.2f}s")
            print(f"Response length: {len(result['response'])} chars")

            # Check if raw response had thinking tags
            if 'raw_response' in result and result['raw_response'] != result['response']:
                print("🧹 Thinking tags were stripped from response")
                raw_len = len(result['raw_response'])
                clean_len = len(result['response'])
                print(f"Raw: {raw_len} chars → Cleaned: {clean_len} chars")

            print(f"\nResponse preview:")
            preview = result['response'][:300]
            if len(result['response']) > 300:
                preview += "..."
            print(preview)

            # Try to validate the response format
            if capability == "decomposition":
                try:
                    # Look for JSON in the response
                    response = result['response'].strip()
                    if '[' in response and ']' in response:
                        start = response.find('[')
                        end = response.rfind(']') + 1
                        json_part = response[start:end]
                        tasks = json.loads(json_part)
                        print(f"✓ Valid JSON with {len(tasks)} tasks")
                    else:
                        print("⚠ No JSON array found in response")
                except Exception as e:
                    print(f"✗ JSON parsing failed: {e}")

        else:
            print(f"✗ Failed | Error: {result['error']}")

        results[capability] = result

    # Overall assessment
    print(f"\n{'='*60}")
    print("MISTRAL MODEL ASSESSMENT")
    print(f"{'='*60}")

    successful_tests = sum(1 for r in results.values() if r["success"])
    total_tests = len(results)

    print(f"Success rate: {successful_tests}/{total_tests} ({successful_tests/total_tests*100:.1f}%)")

    if successful_tests > 0:
        avg_time = sum(r["elapsed_time"] for r in results.values() if r["success"]) / successful_tests
        print(f"Average response time: {avg_time:.2f}s")

    # Check for consistent thinking tag stripping
    stripped_responses = sum(1 for r in results.values() if r.get("success") and
                           'raw_response' in r and r['raw_response'] != r['response'])
    if stripped_responses > 0:
        print(f"Thinking tags stripped in: {stripped_responses} responses")

    return results

def test_mistral_workflow():
    """Test full workflow with mistral model"""
    print(f"\n{'='*60}")
    print("TESTING FULL WORKFLOW WITH MISTRAL")
    print(f"{'='*60}")

    # Force the engine to use mistral for all capabilities
    engine = WorkflowEngine()
    mistral_model = "mistral-small3.2:24b"

    # Override model selection
    engine.best_models = {
        "decomposition": mistral_model,
        "technical_understanding": mistral_model,
        "execution_planning": mistral_model,
        "solution_synthesis": mistral_model
    }

    test_request = "Set up a secure OpenWRT router with guest WiFi network and basic monitoring"

    print(f"Request: {test_request}")
    print(f"Using model: {mistral_model}")

    start_time = time.time()
    result = engine.run_workflow(test_request)
    duration = time.time() - start_time

    print(f"\n{'='*40}")
    print("WORKFLOW RESULT")
    print(f"{'='*40}")

    print(f"Status: {'SUCCESS' if result['success'] else 'FAILED'}")
    print(f"Duration: {duration:.2f}s")

    if result.get('decomposed_tasks'):
        print(f"\nDecomposed Tasks ({len(result['decomposed_tasks'])}):")
        for i, task in enumerate(result['decomposed_tasks'], 1):
            print(f"  {i}. {task}")

    if result.get('execution_results'):
        exec_results = result['execution_results']
        print(f"\nExecution Results:")
        print(f"  Executed steps: {len(exec_results.get('executed_steps', []))}")
        print(f"  Created scripts: {len(exec_results.get('created_scripts', []))}")
        print(f"  Errors: {len(exec_results.get('errors', []))}")

        # Show created scripts
        for script in exec_results.get('created_scripts', []):
            print(f"\n  Generated Script: {script['script_name']}")
            preview = script['content'][:200].replace('\n', ' ')
            print(f"    Preview: {preview}...")

    if result.get('archived_items'):
        print(f"\nArchived Items ({len(result['archived_items'])}):")
        for item in result['archived_items']:
            tags = ', '.join(item.get('tags', []))
            print(f"  {item['script_name']} | Tags: {tags}")

    if result.get('error_message'):
        print(f"\nError: {result['error_message']}")

    return result

def main():
    """Main test function"""
    print("MISTRAL-SMALL3.2:24B WORKFLOW ENGINE TEST")
    print("=" * 60)

    # Test 1: Individual capability tests
    capability_results = test_mistral_capabilities()

    # Test 2: Full workflow test
    workflow_result = test_mistral_workflow()

    # Summary
    print(f"\n{'='*60}")
    print("FINAL SUMMARY")
    print(f"{'='*60}")

    capability_success = sum(1 for r in capability_results.values() if r["success"])
    capability_total = len(capability_results)

    print(f"Capability Tests: {capability_success}/{capability_total} passed")
    print(f"Workflow Test: {'PASSED' if workflow_result['success'] else 'FAILED'}")

    # Check for thinking tag handling
    has_raw_responses = any('raw_response' in r for r in capability_results.values())
    if has_raw_responses:
        stripped_count = sum(1 for r in capability_results.values()
                           if r.get('success') and 'raw_response' in r
                           and r['raw_response'] != r['response'])
        print(f"Thinking Tag Stripping: {stripped_count} responses cleaned")

    overall_success = capability_success >= 3 and workflow_result['success']
    print(f"\nOverall Assessment: {'✓ MISTRAL COMPATIBLE' if overall_success else '✗ ISSUES DETECTED'}")

    if overall_success:
        print("\nMistral-small3.2:24b works well with the LLARP workflow system!")
    else:
        print("\nMistral-small3.2:24b may need additional tuning for optimal performance.")

if __name__ == "__main__":
    main()