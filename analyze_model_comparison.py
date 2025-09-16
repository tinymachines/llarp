#!/usr/bin/env python3

import json
import os
from datetime import datetime

def analyze_mistral_performance():
    """Analyze the completed Mistral training results"""
    mistral_file = "./llarp_training_results_20250915_203953.json"

    if not os.path.exists(mistral_file):
        print("Mistral results file not found")
        return None

    with open(mistral_file) as f:
        data = json.load(f)

    results = data['results']
    total = len(results)

    # Calculate metrics
    success_count = sum(1 for r in results if 'SUCCESS' in r['status'])
    failed_count = sum(1 for r in results if 'FAILED' in r['status'])
    partial_count = total - success_count - failed_count

    avg_time = sum(r.get('execution_time', 0) for r in results) / total
    avg_score = sum(r.get('ground_truth_score', 0) for r in results) / total
    lego_count = sum(1 for r in results if r.get('ground_truth_score', 0) >= 0.8)

    # Category breakdown
    categories = {}
    for result in results:
        test_id = result['test_id']
        category = test_id[:3]  # SYS, NET, WIFI, etc.
        if category not in categories:
            categories[category] = {'total': 0, 'success': 0, 'scores': []}

        categories[category]['total'] += 1
        if 'SUCCESS' in result['status']:
            categories[category]['success'] += 1
        categories[category]['scores'].append(result.get('ground_truth_score', 0))

    return {
        "model": "mistral-small3.2:24b",
        "total_tests": total,
        "success_count": success_count,
        "failed_count": failed_count,
        "partial_count": partial_count,
        "success_rate": success_count / total * 100,
        "avg_execution_time": avg_time,
        "avg_quality_score": avg_score,
        "lego_count": lego_count,
        "categories": categories,
        "timestamp": data['timestamp'],
        "router_ip": data['router_ip']
    }

def generate_insights_from_mistral():
    """Generate insights from the Mistral training run"""
    analysis = analyze_mistral_performance()

    if not analysis:
        return

    print("MISTRAL TRAINING ANALYSIS")
    print("=" * 50)

    print(f"Model: {analysis['model']}")
    print(f"Router: {analysis['router_ip']}")
    print(f"Timestamp: {analysis['timestamp']}")

    print(f"\nPERFORMANCE METRICS")
    print("-" * 30)
    print(f"Total Tests: {analysis['total_tests']}")
    print(f"Success Rate: {analysis['success_rate']:.1f}%")
    print(f"Avg Execution Time: {analysis['avg_execution_time']:.1f}s")
    print(f"Avg Quality Score: {analysis['avg_quality_score']:.2f}/1.0")
    print(f"Generated Legos: {analysis['lego_count']}")

    print(f"\nCATEGORY BREAKDOWN")
    print("-" * 30)
    print(f"{'Category':<8} {'Tests':>6} {'Success':>8} {'Rate':>6} {'Avg Score':>10}")
    print("-" * 40)

    for category, data in sorted(analysis['categories'].items()):
        success_rate = data['success'] / data['total'] * 100
        avg_score = sum(data['scores']) / len(data['scores'])
        print(f"{category:<8} {data['total']:>6} {data['success']:>8} {success_rate:>5.1f}% {avg_score:>10.2f}")

    print(f"\nSTRENGTHS IDENTIFIED")
    print("-" * 30)
    best_categories = sorted(analysis['categories'].items(),
                           key=lambda x: x[1]['success'] / x[1]['total'], reverse=True)

    for category, data in best_categories[:3]:
        rate = data['success'] / data['total'] * 100
        print(f"- {category}: {rate:.1f}% success rate")

    print(f"\nWEAKNESSES IDENTIFIED")
    print("-" * 30)
    worst_categories = sorted(analysis['categories'].items(),
                            key=lambda x: x[1]['success'] / x[1]['total'])

    for category, data in worst_categories[:3]:
        rate = data['success'] / data['total'] * 100
        print(f"- {category}: {rate:.1f}% success rate")

    return analysis

def recommend_model_strategies():
    """Recommend strategies for different models based on analysis"""
    print(f"\nMODEL STRATEGY RECOMMENDATIONS")
    print("=" * 50)

    print("Based on Mistral performance analysis:")
    print()

    print("PROMPT OPTIMIZATION PRIORITIES:")
    print("1. Improve UCI syntax generation for device-specific commands")
    print("2. Add validation steps to generated scripts")
    print("3. Provide more OpenWRT context in prompts")
    print("4. Include error handling patterns in examples")

    print()
    print("QWEN3-CODER:30B HYPOTHESIS:")
    print("- Should excel at code generation (it's a coding model)")
    print("- May have better syntax accuracy for UCI commands")
    print("- Likely faster inference than Mistral-24b")
    print("- Should handle complex multi-step configurations better")

    print()
    print("TESTING STRATEGY:")
    print("1. Run same 25 scenarios with qwen3-coder:30b")
    print("2. Compare success rates by category")
    print("3. Analyze quality score distributions")
    print("4. Measure execution time differences")
    print("5. Evaluate generated script quality")

    print()
    print("EXPECTED IMPROVEMENTS:")
    print("- Network configuration (NET): Better UCI syntax")
    print("- Firewall rules (FW): More accurate iptables/UCI integration")
    print("- Complex scenarios: Better multi-step execution")

def create_multi_model_training_plan():
    """Create plan for testing multiple models"""
    models_to_test = [
        "qwen3-coder:30b",
        "qwen2.5-coder:32b",
        "deepseek-r1:32b",
        "devstral:24b"
    ]

    print(f"\nMULTI-MODEL TRAINING PLAN")
    print("=" * 50)

    print("MODELS TO TEST:")
    for i, model in enumerate(models_to_test, 1):
        print(f"{i}. {model}")

    print(f"\nTRAINING SEQUENCE:")
    print("1. Complete qwen3-coder:30b training (25 scenarios)")
    print("2. Compare with Mistral baseline")
    print("3. Identify best model per category")
    print("4. Create hybrid model selection strategy")
    print("5. Test hybrid approach on subset of scenarios")

    print(f"\nEXPECTED OUTCOMES:")
    print("- Category-specific model recommendations")
    print("- Performance benchmarks across all models")
    print("- Optimal model selection algorithm")
    print("- Expanded lego library with diverse solutions")

def main():
    """Main analysis function"""
    print("LLARP MODEL COMPARISON ANALYSIS")
    print("=" * 60)

    # Analyze completed Mistral run
    mistral_analysis = generate_insights_from_mistral()

    # Generate recommendations
    recommend_model_strategies()

    # Create multi-model plan
    create_multi_model_training_plan()

    print(f"\n{'='*60}")
    print("ANALYSIS COMPLETE")
    print(f"{'='*60}")

    if mistral_analysis:
        print("Mistral baseline analysis available for comparison")
        print("Ready to proceed with qwen3-coder:30b training")
        print()
        print("NEXT STEPS:")
        print("1. Fix router SSH connectivity")
        print("2. Run: python3 run_qwen_direct.py")
        print("3. Compare results with analyze_model_comparison.py")
    else:
        print("Mistral baseline not found - run training first")

if __name__ == "__main__":
    main()