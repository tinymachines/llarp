#!/usr/bin/env python3

import sys
import os
import json

# Add llarp-ai to path
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "llarp-ai"))

# Mock vector store to avoid build dependency
sys.modules['vector_cluster_store_py'] = type('MockModule', (), {
    'Logger': lambda x: None,
    'VectorClusterStore': lambda x: type('MockStore', (), {
        'initialize': lambda *args: False
    })()
})

from llarp_trainer import LLARPTrainer

def create_qwen_trainer():
    """Create trainer configured for qwen3-coder:30b"""
    print("Configuring LLARP trainer for qwen3-coder:30b")

    trainer = LLARPTrainer(router_ip="192.168.100.1")

    # Force qwen model for all capabilities
    qwen_model = "qwen3-coder:30b"
    trainer.workflow_engine.best_models = {
        "decomposition": qwen_model,
        "technical_understanding": qwen_model,
        "execution_planning": qwen_model,
        "solution_synthesis": qwen_model
    }

    # Update results filename to include model name
    trainer.results_file = f"llarp_training_results_qwen_{trainer.results_file.split('_', 3)[-1]}"

    print(f"Trainer configured with model: {qwen_model}")
    print(f"Results will be saved to: {trainer.results_file}")

    return trainer

def run_qwen_training():
    """Run complete training with qwen3-coder:30b"""
    print("=" * 60)
    print("LLARP TRAINING WITH QWEN3-CODER:30B")
    print("=" * 60)

    trainer = create_qwen_trainer()

    # Test connection first
    if not trainer._connect_ssh():
        print("Failed to connect to router")
        return None

    print(f"Connected to router at {trainer.router_ip}")

    # Show current router state
    success, hostname, _ = trainer._execute_ssh_command("uci get system.@system[0].hostname")
    if success:
        print(f"Current hostname: {hostname}")

    success, ip, _ = trainer._execute_ssh_command("uci get network.lan.ipaddr")
    if success:
        print(f"Current LAN IP: {ip}")

    print(f"\nStarting complete training suite...")
    print("This will test qwen3-coder:30b across all 25 scenarios")

    # Run the training
    summary = trainer.run_training_suite()

    return summary

def compare_with_mistral_baseline():
    """Compare qwen results with mistral baseline"""
    print("\n" + "=" * 60)
    print("COMPARING QWEN vs MISTRAL RESULTS")
    print("=" * 60)

    # Load mistral results
    mistral_file = "./llarp_training_results_20250915_203953.json"
    qwen_files = [f for f in os.listdir('.') if 'qwen' in f and f.endswith('.json')]

    if not os.path.exists(mistral_file):
        print("Mistral baseline results not found")
        return

    if not qwen_files:
        print("Qwen results not found")
        return

    qwen_file = sorted(qwen_files)[-1]  # Get latest qwen results

    # Load both result sets
    with open(mistral_file) as f:
        mistral_data = json.load(f)

    with open(qwen_file) as f:
        qwen_data = json.load(f)

    # Compare metrics
    mistral_results = mistral_data['results']
    qwen_results = qwen_data['results']

    def calc_metrics(results):
        total = len(results)
        success = sum(1 for r in results if 'SUCCESS' in r['status'])
        avg_time = sum(r.get('execution_time', 0) for r in results) / total
        avg_score = sum(r.get('ground_truth_score', 0) for r in results) / total
        legos = sum(1 for r in results if r.get('ground_truth_score', 0) >= 0.8)

        return {
            "total": total,
            "success": success,
            "success_rate": success / total * 100,
            "avg_time": avg_time,
            "avg_score": avg_score,
            "legos": legos
        }

    mistral_metrics = calc_metrics(mistral_results)
    qwen_metrics = calc_metrics(qwen_results)

    print("MODEL COMPARISON")
    print("-" * 40)
    print(f"{'Metric':<25} {'Mistral':>12} {'Qwen':>12} {'Delta':>12}")
    print("-" * 40)
    print(f"{'Total Tests':<25} {mistral_metrics['total']:>12} {qwen_metrics['total']:>12} {qwen_metrics['total'] - mistral_metrics['total']:>12}")
    print(f"{'Success Rate':<25} {mistral_metrics['success_rate']:>11.1f}% {qwen_metrics['success_rate']:>11.1f}% {qwen_metrics['success_rate'] - mistral_metrics['success_rate']:>+11.1f}%")
    print(f"{'Avg Exec Time':<25} {mistral_metrics['avg_time']:>11.1f}s {qwen_metrics['avg_time']:>11.1f}s {qwen_metrics['avg_time'] - mistral_metrics['avg_time']:>+11.1f}s")
    print(f"{'Avg Quality Score':<25} {mistral_metrics['avg_score']:>12.2f} {qwen_metrics['avg_score']:>12.2f} {qwen_metrics['avg_score'] - mistral_metrics['avg_score']:>+12.2f}")
    print(f"{'Generated Legos':<25} {mistral_metrics['legos']:>12} {qwen_metrics['legos']:>12} {qwen_metrics['legos'] - mistral_metrics['legos']:>+12}")

    # Category-by-category comparison
    print(f"\nCATEGORY PERFORMANCE COMPARISON")
    print("-" * 60)

    # Group results by test ID prefix
    def group_by_category(results):
        categories = {}
        for result in results:
            test_id = result['test_id']
            category = test_id[:3]  # SYS, NET, WIFI, etc.
            if category not in categories:
                categories[category] = []
            categories[category].append(result)
        return categories

    mistral_cats = group_by_category(mistral_results)
    qwen_cats = group_by_category(qwen_results)

    for category in sorted(set(mistral_cats.keys()) | set(qwen_cats.keys())):
        mistral_cat_results = mistral_cats.get(category, [])
        qwen_cat_results = qwen_cats.get(category, [])

        mistral_success = sum(1 for r in mistral_cat_results if 'SUCCESS' in r['status'])
        qwen_success = sum(1 for r in qwen_cat_results if 'SUCCESS' in r['status'])

        mistral_total = len(mistral_cat_results)
        qwen_total = len(qwen_cat_results)

        if mistral_total > 0 and qwen_total > 0:
            mistral_rate = mistral_success / mistral_total * 100
            qwen_rate = qwen_success / qwen_total * 100
            delta = qwen_rate - mistral_rate

            print(f"{category:<8} Mistral: {mistral_rate:>5.1f}% | Qwen: {qwen_rate:>5.1f}% | Delta: {delta:>+6.1f}%")

    return {
        "mistral": mistral_metrics,
        "qwen": qwen_metrics,
        "comparison": {
            "better_success_rate": qwen_metrics['success_rate'] > mistral_metrics['success_rate'],
            "faster_execution": qwen_metrics['avg_time'] < mistral_metrics['avg_time'],
            "higher_quality": qwen_metrics['avg_score'] > mistral_metrics['avg_score'],
            "more_legos": qwen_metrics['legos'] > mistral_metrics['legos']
        }
    }

def main():
    """Main function to orchestrate qwen training"""
    print("QWEN3-CODER:30B TRAINING ORCHESTRATION")
    print("=" * 60)

    # Check if qwen model is available
    try:
        import requests
        response = requests.get("http://127.0.0.1:11434/api/tags", timeout=5)
        models = [m["name"] for m in response.json().get("models", [])]

        if "qwen3-coder:30b" not in models:
            print("ERROR: qwen3-coder:30b not found in ollama")
            print(f"Available models: {[m for m in models if 'qwen' in m]}")
            return
        else:
            print("Found qwen3-coder:30b - ready for training")

    except Exception as e:
        print(f"ERROR: Cannot connect to ollama: {e}")
        return

    # Run training
    summary = run_qwen_training()

    if summary:
        print(f"\nQWEN TRAINING COMPLETED")
        print(f"Success rate: {summary['success_rate']:.1%}")
        print(f"Stored legos: {summary['stored_legos']}")
        print(f"Results file: {summary['results_file']}")

        # Compare with mistral if possible
        comparison = compare_with_mistral_baseline()

        if comparison:
            print(f"\nMODEL RECOMMENDATION")
            print("-" * 30)

            better_metrics = sum(comparison['comparison'].values())
            if better_metrics >= 3:
                print("RECOMMENDATION: qwen3-coder:30b performs better overall")
            elif better_metrics >= 2:
                print("RECOMMENDATION: qwen3-coder:30b shows promise, mixed results")
            else:
                print("RECOMMENDATION: mistral-small3.2:24b remains preferred")

            print(f"Qwen advantages: {better_metrics}/4 metrics")

if __name__ == "__main__":
    main()