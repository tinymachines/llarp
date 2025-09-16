#!/usr/bin/env python3

import requests
import json
import time
import sys
import os

# Simple workflow test without vectl dependency
def call_mistral(prompt, timeout=45):
    """Call mistral with timeout and tag stripping"""
    import re

    def strip_thinking_tags(text):
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
        for pattern in tag_patterns:
            cleaned_text = re.sub(pattern, '', cleaned_text, flags=re.IGNORECASE | re.MULTILINE | re.DOTALL)

        cleaned_text = re.sub(r'\n\s*\n', '\n\n', cleaned_text)
        return cleaned_text.strip()

    try:
        payload = {
            "model": "mistral-small3.2:24b",
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": 0.1,
                "top_p": 0.9
            }
        }

        print(f"Calling mistral (timeout: {timeout}s)...")
        start_time = time.time()

        response = requests.post("http://127.0.0.1:11434/api/generate",
                               json=payload, timeout=timeout)
        response.raise_for_status()

        result = response.json()
        elapsed = time.time() - start_time

        raw_response = result.get("response", "")
        cleaned_response = strip_thinking_tags(raw_response)

        return {
            "success": True,
            "response": cleaned_response,
            "raw_response": raw_response,
            "had_thinking_tags": raw_response != cleaned_response,
            "elapsed_time": elapsed,
            "model_time": result.get("total_duration", 0) / 1_000_000_000
        }

    except requests.Timeout:
        return {
            "success": False,
            "error": f"Timeout after {timeout}s"
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }

def test_workflow_decomposition():
    """Test request decomposition with Mistral"""
    print("=" * 60)
    print("TESTING MISTRAL WORKFLOW INTEGRATION")
    print("=" * 60)

    print("\n1. DECOMPOSITION TEST")
    print("-" * 40)

    prompt = """Break down this OpenWRT request into specific actionable tasks:
"Set up secure WiFi with guest network on my router"

Respond with a JSON array of tasks: ["task1", "task2", "task3"]
Keep it simple and focused."""

    result = call_mistral(prompt, timeout=60)

    if result["success"]:
        print(f"✓ Success in {result['elapsed_time']:.1f}s")

        if result["had_thinking_tags"]:
            print("✓ Thinking tags stripped")
            print(f"  Raw: {len(result['raw_response'])} chars → Clean: {len(result['response'])} chars")

        print(f"\nResponse ({len(result['response'])} chars):")
        print(result['response'])

        # Try to parse JSON
        try:
            response_text = result['response']
            if '[' in response_text and ']' in response_text:
                start = response_text.find('[')
                end = response_text.rfind(']') + 1
                json_part = response_text[start:end]
                tasks = json.loads(json_part)

                print(f"\n✓ Parsed {len(tasks)} tasks:")
                for i, task in enumerate(tasks, 1):
                    print(f"  {i}. {task}")

                return {"success": True, "tasks": tasks}
            else:
                print("\n⚠ No JSON array found")
                return {"success": False, "error": "No JSON found"}

        except Exception as e:
            print(f"\n✗ JSON parsing failed: {e}")
            return {"success": False, "error": f"JSON parsing: {e}"}

    else:
        print(f"✗ Failed: {result['error']}")
        return result

def test_execution_planning():
    """Test execution planning with Mistral"""
    print("\n2. EXECUTION PLANNING TEST")
    print("-" * 40)

    prompt = """Create a simple execution plan for: "Configure secure WiFi"

Use this JSON format:
{
  "steps": [
    {"order": 1, "action": "use_existing_lego", "script": "create-wifi-network.sh"},
    {"order": 2, "action": "run_command", "command": "uci commit wireless"}
  ]
}

Keep it simple with 2-3 steps."""

    result = call_mistral(prompt, timeout=60)

    if result["success"]:
        print(f"✓ Success in {result['elapsed_time']:.1f}s")

        if result["had_thinking_tags"]:
            print("✓ Thinking tags stripped")

        print(f"\nResponse preview:")
        print(result['response'][:300] + "..." if len(result['response']) > 300 else result['response'])

        # Try to parse JSON
        try:
            response_text = result['response']
            if '{' in response_text and '}' in response_text:
                start = response_text.find('{')
                end = response_text.rfind('}') + 1
                json_part = response_text[start:end]
                plan = json.loads(json_part)

                steps = plan.get("steps", [])
                print(f"\n✓ Parsed plan with {len(steps)} steps:")
                for step in steps:
                    order = step.get('order', '?')
                    action = step.get('action', 'unknown')
                    desc = step.get('script', step.get('command', 'no description'))
                    print(f"  {order}. {action}: {desc}")

                return {"success": True, "plan": plan}
            else:
                print("\n⚠ No JSON object found")
                return {"success": False, "error": "No JSON found"}

        except Exception as e:
            print(f"\n✗ JSON parsing failed: {e}")
            return {"success": False, "error": f"JSON parsing: {e}"}

    else:
        print(f"✗ Failed: {result['error']}")
        return result

def test_script_generation():
    """Test script generation with Mistral"""
    print("\n3. SCRIPT GENERATION TEST")
    print("-" * 40)

    prompt = """Generate a simple bash script for OpenWRT that configures basic WiFi:
- Set SSID to 'MyNetwork'
- Set WPA2 password
- Enable the wireless interface

Keep it simple and include #!/bin/bash header."""

    result = call_mistral(prompt, timeout=60)

    if result["success"]:
        print(f"✓ Success in {result['elapsed_time']:.1f}s")

        if result["had_thinking_tags"]:
            print("✓ Thinking tags stripped")

        script_content = result['response']
        print(f"\nGenerated script ({len(script_content)} chars):")
        print("-" * 30)
        # Show first 20 lines
        lines = script_content.split('\n')
        for i, line in enumerate(lines[:20]):
            print(f"{i+1:2}: {line}")
        if len(lines) > 20:
            print(f"    ... ({len(lines) - 20} more lines)")

        # Basic validation
        has_shebang = script_content.startswith('#!/bin/bash') or script_content.startswith('#!/usr/bin/env bash')
        has_uci = 'uci' in script_content
        has_wireless = 'wireless' in script_content.lower()

        print(f"\nScript validation:")
        print(f"  Has shebang: {'✓' if has_shebang else '✗'}")
        print(f"  Uses UCI: {'✓' if has_uci else '✗'}")
        print(f"  Wireless config: {'✓' if has_wireless else '✗'}")

        quality_score = sum([has_shebang, has_uci, has_wireless]) / 3.0
        print(f"  Quality score: {quality_score:.1f}/1.0")

        return {"success": True, "script": script_content, "quality": quality_score}

    else:
        print(f"✗ Failed: {result['error']}")
        return result

def main():
    """Main test function"""
    print("MISTRAL-SMALL3.2:24B WORKFLOW INTEGRATION TEST")

    # Check if mistral is available
    try:
        models_response = requests.get("http://127.0.0.1:11434/api/tags", timeout=5)
        models = [m["name"] for m in models_response.json().get("models", [])]

        if "mistral-small3.2:24b" not in models:
            print(f"✗ mistral-small3.2:24b not found")
            print(f"Available models: {models}")
            return
        else:
            print(f"✓ Found mistral-small3.2:24b")

    except Exception as e:
        print(f"✗ Cannot connect to ollama: {e}")
        return

    # Run tests
    start_time = time.time()

    results = {}
    results["decomposition"] = test_workflow_decomposition()
    results["planning"] = test_execution_planning()
    results["generation"] = test_script_generation()

    total_time = time.time() - start_time

    # Summary
    print(f"\n{'='*60}")
    print("INTEGRATION TEST SUMMARY")
    print(f"{'='*60}")

    successful_tests = sum(1 for r in results.values() if r.get("success", False))
    total_tests = len(results)

    print(f"Tests passed: {successful_tests}/{total_tests}")
    print(f"Total time: {total_time:.1f}s")

    # Performance summary
    if successful_tests > 0:
        times = [r.get("elapsed_time", 0) for r in results.values() if r.get("success")]
        if times:
            avg_time = sum(times) / len(times)
            print(f"Average response time: {avg_time:.1f}s")

    # Feature summary
    thinking_tags_found = any(r.get("had_thinking_tags", False) for r in results.values() if r.get("success"))
    if thinking_tags_found:
        print("✓ Thinking tags properly stripped")

    # Overall assessment
    success_rate = successful_tests / total_tests
    if success_rate >= 0.67:  # At least 2/3 tests pass
        print(f"\n✅ MISTRAL INTEGRATION: COMPATIBLE")
        print("Mistral-small3.2:24b works well with the LLARP workflow system!")
        if thinking_tags_found:
            print("The thinking tag stripping is working correctly.")
    else:
        print(f"\n❌ MISTRAL INTEGRATION: NEEDS WORK")
        print("Mistral-small3.2:24b needs additional configuration or prompting.")

    # Specific recommendations
    print(f"\nRecommendations:")
    if successful_tests > 0:
        print("- Mistral can be used for workflow tasks")
        print("- Consider increasing timeouts for complex requests")
        if thinking_tags_found:
            print("- Thinking tag stripping is working properly")
    else:
        print("- Check ollama configuration")
        print("- Verify model is loaded correctly")

if __name__ == "__main__":
    main()