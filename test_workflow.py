#!/usr/bin/env python3

import sys
import os
import time

# Add llarp-ai to path
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "llarp-ai"))

from workflow_engine import WorkflowEngine
from knowledge_bridge import KnowledgeBridge

def test_knowledge_bridge():
    """Test the knowledge bridge functionality"""
    print("=" * 60)
    print("TESTING KNOWLEDGE BRIDGE")
    print("=" * 60)

    bridge = KnowledgeBridge()

    # Test 1: Index lego scripts
    print("\n1. Indexing lego scripts...")
    count = bridge.index_lego_scripts("./llarp-scripts")
    print(f"Indexed {count} scripts")

    # Test 2: Store some manual knowledge
    print("\n2. Storing manual knowledge...")
    test_knowledge = [
        ("Setting up WiFi on OpenWRT requires configuring the wireless UCI section", "wifi_setup"),
        ("Port forwarding uses iptables rules and requires firewall configuration", "port_forwarding"),
        ("SSH hardening involves disabling password auth and using key-based authentication", "ssh_security")
    ]

    for text, knowledge_type in test_knowledge:
        success = bridge.store_knowledge(text, knowledge_type)
        print(f"Stored {knowledge_type}: {'✓' if success else '✗'}")

    # Test 3: Search for knowledge
    print("\n3. Testing knowledge search...")
    test_queries = [
        "How to configure WiFi",
        "SSH security best practices",
        "Firewall port forwarding"
    ]

    for query in test_queries:
        results = bridge.search_knowledge(query, k=3)
        print(f"\nQuery: '{query}'")
        for result in results:
            print(f"  Score: {result['similarity']:.3f} | Type: {result['type']} | Text: {result['text'][:80]}...")

    # Test 4: Show statistics
    print("\n4. Knowledge base statistics:")
    stats = bridge.get_stats()
    print(f"Total entries: {stats['total_entries']}")
    print(f"Type distribution: {stats['type_distribution']}")

    return count > 0

def test_model_selection():
    """Test ollama model selection"""
    print("\n" + "=" * 60)
    print("TESTING OLLAMA MODEL SELECTION")
    print("=" * 60)

    engine = WorkflowEngine()

    # Test available models
    available_models = engine.model_tester.list_available_models()
    print(f"Available models: {available_models}")

    if not available_models:
        print("No ollama models available - skipping model tests")
        return False

    # Run capability tests on a subset of models (for speed)
    test_models = available_models[:2] if len(available_models) > 2 else available_models

    print(f"\nTesting models: {test_models}")
    results = engine.model_tester.run_capability_tests(test_models)

    # Show results
    for model, model_results in results.items():
        print(f"\n{model}: Overall score: {model_results['overall_score']:.3f}")
        for capability, result in model_results.items():
            if capability != "overall_score":
                status = "✓" if result.get("success", False) else "✗"
                score = result.get("score", 0)
                print(f"  {status} {capability}: {score:.3f}")

    return True

def test_workflow_execution():
    """Test complete workflow execution"""
    print("\n" + "=" * 60)
    print("TESTING COMPLETE WORKFLOW")
    print("=" * 60)

    engine = WorkflowEngine()

    # Test requests
    test_requests = [
        "Set up a new OpenWRT router with secure WiFi and SSH access",
        "Configure port forwarding for a web server on port 80",
        "Create a backup script for router configurations"
    ]

    results = []

    for request in test_requests:
        print(f"\n{'=' * 40}")
        print(f"Processing: {request}")
        print(f"{'=' * 40}")

        start_time = time.time()
        result = engine.run_workflow(request)
        duration = time.time() - start_time

        print(f"\nResult: {'SUCCESS' if result['success'] else 'FAILED'}")
        print(f"Duration: {duration:.2f}s")

        if result.get('decomposed_tasks'):
            print(f"Tasks: {', '.join(result['decomposed_tasks'])}")

        if result.get('execution_results'):
            exec_results = result['execution_results']
            print(f"Executed steps: {len(exec_results.get('executed_steps', []))}")
            print(f"Created scripts: {len(exec_results.get('created_scripts', []))}")
            print(f"Errors: {len(exec_results.get('errors', []))}")

        if result.get('archived_items'):
            print(f"Archived items: {len(result['archived_items'])}")

        if result.get('error_message'):
            print(f"Error: {result['error_message']}")

        results.append(result)

    return results

def run_all_tests():
    """Run all tests"""
    print("LLARP WORKFLOW ENGINE TEST SUITE")
    print("=" * 60)

    # Test 1: Knowledge Bridge
    kb_success = test_knowledge_bridge()

    # Test 2: Model Selection (optional - requires ollama)
    model_success = test_model_selection()

    # Test 3: Complete Workflow
    workflow_results = test_workflow_execution()

    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)

    print(f"Knowledge Bridge: {'✓ PASS' if kb_success else '✗ FAIL'}")
    print(f"Model Selection: {'✓ PASS' if model_success else '✗ FAIL'}")

    successful_workflows = sum(1 for r in workflow_results if r['success'])
    print(f"Workflow Tests: {successful_workflows}/{len(workflow_results)} successful")

    # Show any workflow errors
    for i, result in enumerate(workflow_results):
        if not result['success']:
            print(f"  Workflow {i+1} failed: {result.get('error_message', 'Unknown error')}")

    overall_success = kb_success and successful_workflows > 0
    print(f"\nOverall: {'✓ PASS' if overall_success else '✗ FAIL'}")

    return overall_success

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Test LLARP Workflow Engine")
    parser.add_argument("--knowledge-only", action="store_true", help="Test only knowledge bridge")
    parser.add_argument("--models-only", action="store_true", help="Test only model selection")
    parser.add_argument("--workflow-only", action="store_true", help="Test only workflow execution")

    args = parser.parse_args()

    if args.knowledge_only:
        test_knowledge_bridge()
    elif args.models_only:
        test_model_selection()
    elif args.workflow_only:
        test_workflow_execution()
    else:
        run_all_tests()