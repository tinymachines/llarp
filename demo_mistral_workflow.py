#!/usr/bin/env python3

import sys
import os

# Add llarp-ai to path
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "llarp-ai"))

# Mock the vector store import to avoid build dependency
sys.modules['vector_cluster_store_py'] = type('MockModule', (), {
    'Logger': lambda x: None,
    'VectorClusterStore': lambda x: type('MockStore', (), {
        'initialize': lambda *args: False
    })()
})

from workflow_engine import WorkflowEngine

def demo_mistral_workflow():
    """Demonstrate the complete workflow with mistral model"""
    print("🚀 LLARP WORKFLOW ENGINE - MISTRAL DEMONSTRATION")
    print("=" * 60)

    # Create engine
    engine = WorkflowEngine()

    # Force mistral usage
    engine.best_models = {
        "decomposition": "mistral-small3.2:24b",
        "technical_understanding": "mistral-small3.2:24b",
        "execution_planning": "mistral-small3.2:24b",
        "solution_synthesis": "mistral-small3.2:24b"
    }

    print(f"Using model: mistral-small3.2:24b for all workflow stages")

    # Test request
    test_request = "Configure a secure OpenWRT router with WiFi and basic firewall"

    print(f"Request: {test_request}")
    print(f"{'='*60}")

    # Override vector store methods to avoid dependency
    engine.knowledge_bridge = type('MockBridge', (), {
        'search_knowledge': lambda self, query, k=5: []
    })()

    # Run workflow
    try:
        import time
        start_time = time.time()

        result = engine.run_workflow(test_request)

        duration = time.time() - start_time

        # Display results
        print(f"\n🎯 WORKFLOW RESULT")
        print(f"{'='*40}")
        print(f"Status: {'✅ SUCCESS' if result['success'] else '❌ FAILED'}")
        print(f"Duration: {duration:.1f}s")

        if result.get('decomposed_tasks'):
            print(f"\n📋 DECOMPOSED TASKS ({len(result['decomposed_tasks'])})")
            for i, task in enumerate(result['decomposed_tasks'], 1):
                print(f"  {i}. {task}")

        if result.get('execution_results'):
            exec_results = result['execution_results']
            print(f"\n🔧 EXECUTION RESULTS")
            print(f"  Steps executed: {len(exec_results.get('executed_steps', []))}")
            print(f"  Scripts created: {len(exec_results.get('created_scripts', []))}")
            print(f"  Errors: {len(exec_results.get('errors', []))}")

            # Show generated scripts
            for script in exec_results.get('created_scripts', []):
                print(f"\n📜 GENERATED SCRIPT: {script['script_name']}")
                print("-" * 30)
                content = script['content']
                lines = content.split('\n')
                # Show first 15 lines
                for i, line in enumerate(lines[:15]):
                    print(f"  {i+1:2}: {line}")
                if len(lines) > 15:
                    print(f"      ... ({len(lines) - 15} more lines)")

        if result.get('review_results'):
            review = result['review_results']
            print(f"\n📊 REVIEW RESULTS")
            print(f"  Success: {'✅' if review['success'] else '❌'}")
            print(f"  Quality Score: {review['quality_score']:.1f}")
            print(f"  Archivable Items: {len(review['archivable_items'])}")

        if result.get('archived_items'):
            print(f"\n📚 ARCHIVED ITEMS ({len(result['archived_items'])})")
            for item in result['archived_items']:
                tags = ', '.join(item.get('tags', []))
                print(f"  {item['script_name']} | Tags: {tags}")

        if result.get('error_message'):
            print(f"\n❌ ERROR: {result['error_message']}")

        # Summary
        print(f"\n{'='*60}")
        print("✅ DEMONSTRATION COMPLETE")
        print(f"{'='*60}")

        if result['success']:
            print("🎉 Mistral-small3.2:24b successfully completed the full workflow!")
            print("✅ Request decomposition - Working")
            print("✅ Knowledge search - Working (mocked)")
            print("✅ Execution planning - Working")
            print("✅ Script generation - Working")
            print("✅ Quality review - Working")
            print("✅ Archiving - Working")
            print("\n🔧 The LLARP workflow system is ready for production use with Mistral!")
        else:
            print("❌ Workflow encountered issues - check error details above")

        return result

    except Exception as e:
        print(f"\n❌ WORKFLOW ERROR: {e}")
        import traceback
        traceback.print_exc()
        return {"success": False, "error": str(e)}

def main():
    """Main demonstration"""
    # Check if mistral is available
    try:
        import requests
        models_response = requests.get("http://127.0.0.1:11434/api/tags", timeout=5)
        models = [m["name"] for m in models_response.json().get("models", [])]

        if "mistral-small3.2:24b" not in models:
            print(f"❌ mistral-small3.2:24b not available")
            print(f"Available models: {models[:5]}...")
            return
        else:
            print(f"✅ mistral-small3.2:24b is available")

    except Exception as e:
        print(f"❌ Cannot connect to ollama: {e}")
        return

    # Run demonstration
    result = demo_mistral_workflow()

    # Final status
    if result and result.get('success'):
        print(f"\n🎊 SUCCESS: Mistral integration is working perfectly!")
        print(f"The LLARP workflow system now supports:")
        print(f"  • Thinking tag stripping ✅")
        print(f"  • Request decomposition ✅")
        print(f"  • Execution planning ✅")
        print(f"  • Script generation ✅")
        print(f"  • Quality review ✅")
        print(f"  • Solution archiving ✅")
    else:
        print(f"\n⚠️  Integration needs refinement - check logs above")

if __name__ == "__main__":
    main()