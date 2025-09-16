#!/usr/bin/env python3

import sys
import os
import json

# Activate environment
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "llarp-ai"))

# Mock vector store
sys.modules['vector_cluster_store_py'] = type('MockModule', (), {
    'Logger': lambda x: None,
    'VectorClusterStore': lambda x: type('MockStore', (), {
        'initialize': lambda *args: False
    })()
})

from llarp_trainer import LLARPTrainer

def test_single_hostname_change():
    """Test a single scenario: changing hostname"""
    print("🧪 SINGLE SCENARIO TEST: Change Hostname")
    print("=" * 50)

    # Create trainer
    trainer = LLARPTrainer(router_ip="192.168.100.1")

    # Test the hostname change scenario
    test_scenario = {
        "id": "SYS001",
        "query": "Change the router hostname to 'llarp-test'",
        "category": "system",
        "subcategory": "hostname",
        "difficulty": "basic",
        "expected_commands": ["uci set system.@system[0].hostname='llarp-test'", "uci commit system"],
        "validation": {
            "check_command": "uci get system.@system[0].hostname",
            "expected_output": "llarp-test"
        },
        "rollback": {
            "commands": ["uci set system.@system[0].hostname='LLARP'", "uci commit system"]
        }
    }

    # Connect to router
    if not trainer._connect_ssh():
        print("❌ Failed to connect to router")
        return False

    print(f"✅ Connected to router at {trainer.router_ip}")

    # Show current hostname
    success, hostname, _ = trainer._execute_ssh_command("uci get system.@system[0].hostname")
    if success:
        print(f"📋 Current hostname: {hostname}")
    else:
        print("⚠️ Could not get current hostname")

    print("\n" + "="*50)
    print("RUNNING TEST SCENARIO")
    print("="*50)

    # Run the test
    result = trainer.run_single_test(test_scenario)

    # Show results
    print(f"\n🎯 TEST RESULT")
    print(f"Status: {result.status.value}")
    print(f"Execution Time: {result.execution_time:.1f}s")
    print(f"Ground Truth Score: {result.ground_truth_score:.2f}")

    if result.generated_script:
        print(f"\n📜 Generated Script ({len(result.generated_script)} chars):")
        print("-" * 30)
        lines = result.generated_script.split('\n')
        for i, line in enumerate(lines[:10], 1):
            print(f"{i:2}: {line}")
        if len(lines) > 10:
            print(f"    ... ({len(lines) - 10} more lines)")

    if result.validation_result:
        print(f"\n✅ Validation Result:")
        for key, value in result.validation_result.items():
            print(f"  {key}: {value}")

    if result.error_message:
        print(f"\n❌ Error: {result.error_message}")

    # Check final hostname
    success, final_hostname, _ = trainer._execute_ssh_command("uci get system.@system[0].hostname")
    if success:
        print(f"\n📋 Final hostname: {final_hostname}")

    # Clean up
    trainer.ssh_client.close()

    return result.status.value in ["success", "stored"]

if __name__ == "__main__":
    success = test_single_hostname_change()

    print(f"\n{'='*50}")
    print(f"SINGLE TEST SUMMARY")
    print(f"{'='*50}")
    print(f"Result: {'✅ SUCCESS' if success else '❌ FAILED'}")

    if success:
        print("🎉 The training system works! Mistral successfully:")
        print("  • Generated a working OpenWRT script")
        print("  • Executed it on the real router")
        print("  • Validated the result")
        print("  • Could store it as a lego if successful")
    else:
        print("🔧 The test revealed issues that need fixing")

    sys.exit(0 if success else 1)