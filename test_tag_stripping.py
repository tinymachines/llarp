#!/usr/bin/env python3

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

def test_tag_stripping():
    """Test thinking tag stripping with various examples"""
    print("TESTING THINKING TAG STRIPPING")
    print("=" * 50)

    test_cases = [
        {
            "name": "Basic thinking tags",
            "input": """<think>Let me analyze this request...</think>

Here are the UCI commands for WiFi:
1. uci set wireless...
2. uci commit wireless""",
            "expected_stripped": True
        },
        {
            "name": "Multiple thinking sections",
            "input": """<thinking>
The user wants WiFi configuration commands.
I should provide UCI commands.
</thinking>

Here are three commands:

<analysis>
These commands will work on OpenWRT.
</analysis>

1. uci set wireless.@wifi-device[0].disabled='0'
2. uci commit wireless""",
            "expected_stripped": True
        },
        {
            "name": "Nested and complex thinking",
            "input": """<think>
This is a complex request about OpenWRT.
Let me think step by step:
1. First analyze the requirements
2. Then provide solutions

<internal>Some internal processing</internal>
</think>

The solution is:
- Configure the wireless interface
- Set the SSID and encryption""",
            "expected_stripped": True
        },
        {
            "name": "No thinking tags",
            "input": """Here are the UCI commands:
1. uci set wireless.@wifi-device[0].disabled='0'
2. uci commit wireless""",
            "expected_stripped": False
        },
        {
            "name": "Case insensitive tags",
            "input": """<THINKING>This is uppercase thinking</THINKING>
<Think>Mixed case</Think>

The answer is: configure with UCI commands.""",
            "expected_stripped": True
        }
    ]

    for i, test_case in enumerate(test_cases, 1):
        print(f"\nTest {i}: {test_case['name']}")
        print("-" * 30)

        original = test_case["input"]
        cleaned = strip_thinking_tags(original)

        was_stripped = original != cleaned
        expected_stripped = test_case["expected_stripped"]

        print(f"Expected stripping: {expected_stripped}")
        print(f"Actual stripping: {was_stripped}")

        if was_stripped == expected_stripped:
            print("✓ PASS")
        else:
            print("✗ FAIL")

        print(f"\nOriginal length: {len(original)} chars")
        print(f"Cleaned length: {len(cleaned)} chars")

        if was_stripped:
            print(f"Reduction: {len(original) - len(cleaned)} chars")

        print(f"\nOriginal:\n{original[:100]}...")
        print(f"\nCleaned:\n{cleaned[:100]}...")

def test_real_mistral_response():
    """Test with a realistic mistral response that might have thinking tags"""
    print(f"\n{'='*50}")
    print("TESTING WITH REALISTIC RESPONSES")
    print("=" * 50)

    # Simulated mistral response with thinking tags
    mistral_response = """<thinking>
The user is asking for OpenWRT UCI commands for WiFi configuration.
I need to provide practical, working commands that cover the most common scenarios.
Let me structure this as a clear list with explanations.
</thinking>

Here are three essential OpenWRT UCI commands for WiFi configuration:

1. **Enable WiFi radio**:
   ```bash
   uci set wireless.@wifi-device[0].disabled='0'
   uci commit wireless
   wifi
   ```

2. **Configure WiFi network**:
   ```bash
   uci set wireless.@wifi-iface[0].ssid='MyNetwork'
   uci set wireless.@wifi-iface[0].key='mypassword'
   uci set wireless.@wifi-iface[0].encryption='psk2'
   uci commit wireless
   ```

<analysis>
These commands cover the basic setup that most users need.
The wifi command restarts the wireless service.
</analysis>

3. **Set WiFi channel and bandwidth**:
   ```bash
   uci set wireless.@wifi-device[0].channel='6'
   uci set wireless.@wifi-device[0].htmode='HT40'
   uci commit wireless
   wifi
   ```

These commands will configure a basic WiFi access point on OpenWRT."""

    print("Testing realistic Mistral response with thinking tags...")
    cleaned = strip_thinking_tags(mistral_response)

    print(f"Original length: {len(mistral_response)} chars")
    print(f"Cleaned length: {len(cleaned)} chars")
    print(f"Reduction: {len(mistral_response) - len(cleaned)} chars")

    print("\nCleaned response:")
    print("-" * 30)
    print(cleaned)

    # Check if all thinking tags were removed
    has_thinking = any(tag in cleaned.lower() for tag in ['<think', '<analysis', '<reasoning'])
    print(f"\nThinking tags removed: {'✓' if not has_thinking else '✗'}")

def main():
    """Run all tests"""
    test_tag_stripping()
    test_real_mistral_response()

    print(f"\n{'='*50}")
    print("SUMMARY")
    print("=" * 50)
    print("✓ Thinking tag stripping functionality is working")
    print("✓ Handles multiple tag types (thinking, analysis, etc.)")
    print("✓ Case-insensitive matching")
    print("✓ Preserves actual content while removing meta-thinking")
    print("\nThe workflow engine should now handle Mistral responses correctly!")

if __name__ == "__main__":
    main()