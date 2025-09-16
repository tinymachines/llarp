#!/usr/bin/env python3

import sys
import os
import json
import time
from datetime import datetime
from typing import Dict, List

# Add llarp-ai to path
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "llarp-ai"))

# Mock vector store
sys.modules['vector_cluster_store_py'] = type('MockModule', (), {
    'Logger': lambda x: None,
    'VectorClusterStore': lambda x: type('MockStore', (), {
        'initialize': lambda *args: False
    })()
})

from llarp_trainer import LLARPTrainer

class MultiModelTrainer:
    """Train and compare multiple models on the same test scenarios"""

    def __init__(self, router_ip="192.168.100.1"):
        self.router_ip = router_ip
        self.models_to_test = [
            "qwen3-coder:30b",
            "qwen2.5-coder:32b",
            "devstral:24b",
            "deepseek-r1:32b"
        ]
        self.results = {}
        self.baseline_file = "./llarp_training_results_20250915_203953.json"  # Mistral baseline

    def get_available_models(self) -> List[str]:
        """Get available models from ollama"""
        try:
            import requests
            response = requests.get("http://127.0.0.1:11434/api/tags", timeout=5)
            models = [m["name"] for m in response.json().get("models", [])]

            available = [m for m in self.models_to_test if m in models]
            print(f"Available models for testing: {available}")
            return available
        except Exception as e:
            print(f"Error checking available models: {e}")
            return []

    def run_model_training(self, model_name: str) -> Dict:
        """Run complete training for a specific model"""
        print(f"\n{'='*60}")
        print(f"TRAINING WITH MODEL: {model_name}")
        print(f"{'='*60}")

        # Create trainer
        trainer = LLARPTrainer(router_ip=self.router_ip)

        # Force specific model for all capabilities
        trainer.workflow_engine.best_models = {
            "decomposition": model_name,
            "technical_understanding": model_name,
            "execution_planning": model_name,
            "solution_synthesis": model_name
        }

        # Set results filename with model name
        safe_model_name = model_name.replace(":", "_").replace(".", "_")
        trainer.results_file = f"llarp_training_results_{safe_model_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

        print(f"Model: {model_name}")
        print(f"Results file: {trainer.results_file}")

        try:
            # Test connection
            if not trainer._connect_ssh():
                return {"error": "SSH connection failed", "model": model_name}

            # Run training
            start_time = time.time()
            summary = trainer.run_training_suite()
            total_time = time.time() - start_time

            # Add timing information
            summary["total_training_time"] = total_time
            summary["model_name"] = model_name
            summary["results_file"] = trainer.results_file

            return summary

        except Exception as e:
            return {"error": str(e), "model": model_name}

    def compare_all_models(self) -> Dict:
        """Compare results across all tested models"""
        print(f"\n{'='*60}")
        print("MULTI-MODEL COMPARISON ANALYSIS")
        print(f"{'='*60}")

        # Load baseline (Mistral)
        baseline_data = None
        if os.path.exists(self.baseline_file):
            with open(self.baseline_file) as f:
                baseline_data = json.load(f)
                baseline_results = baseline_data['results']
                baseline_metrics = self._calculate_metrics(baseline_results, "mistral-small3.2:24b")
                self.results["mistral-small3.2:24b"] = baseline_metrics

        # Calculate comparison
        if len(self.results) < 2:
            print("Need at least 2 models for comparison")
            return {}

        print(f"PERFORMANCE COMPARISON")
        print("-" * 80)
        print(f"{'Model':<20} {'Success%':>8} {'AvgTime':>8} {'Quality':>8} {'Legos':>6} {'Rating':>8}")
        print("-" * 80)

        for model, metrics in sorted(self.results.items(), key=lambda x: x[1]['success_rate'], reverse=True):
            rating = self._calculate_overall_rating(metrics)
            print(f"{model:<20} {metrics['success_rate']:>7.1f}% {metrics['avg_time']:>7.0f}s {metrics['avg_score']:>7.2f} {metrics['lego_count']:>6} {rating:>8}")

        # Find best model overall
        best_model = max(self.results.keys(), key=lambda m: self._calculate_overall_rating(self.results[m]))

        print(f"\nRECOMMENDATION: {best_model}")
        return {"best_model": best_model, "results": self.results}

    def _calculate_metrics(self, results: List[Dict], model_name: str) -> Dict:
        """Calculate performance metrics for a model"""
        total = len(results)
        success = sum(1 for r in results if 'SUCCESS' in r['status'])
        avg_time = sum(r.get('execution_time', 0) for r in results) / total if total > 0 else 0
        avg_score = sum(r.get('ground_truth_score', 0) for r in results) / total if total > 0 else 0
        lego_count = sum(1 for r in results if r.get('ground_truth_score', 0) >= 0.8)

        return {
            "model": model_name,
            "total_tests": total,
            "success_count": success,
            "success_rate": success / total * 100 if total > 0 else 0,
            "avg_time": avg_time,
            "avg_score": avg_score,
            "lego_count": lego_count
        }

    def _calculate_overall_rating(self, metrics: Dict) -> float:
        """Calculate overall rating for a model (0.0-1.0)"""
        # Weighted scoring: success rate (50%), quality (30%), speed (20%)
        success_score = metrics['success_rate'] / 100.0
        quality_score = metrics['avg_score']
        speed_score = max(0, 1.0 - (metrics['avg_time'] / 600.0))  # Normalize to 10min max

        rating = (success_score * 0.5) + (quality_score * 0.3) + (speed_score * 0.2)
        return rating

    def run_multi_model_training(self) -> Dict:
        """Run training across multiple models"""
        print("MULTI-MODEL LLARP TRAINING")
        print("=" * 60)

        available_models = self.get_available_models()

        if not available_models:
            print("No test models available")
            return {}

        print(f"Planning to test {len(available_models)} models")

        for i, model in enumerate(available_models, 1):
            print(f"\n[{i}/{len(available_models)}] Starting training with {model}")

            # Run training for this model
            result = self.run_model_training(model)

            if "error" in result:
                print(f"Training failed for {model}: {result['error']}")
                self.results[model] = {"error": result['error']}
            else:
                print(f"Training completed for {model}")
                print(f"Success rate: {result['success_rate']:.1%}")
                print(f"Stored legos: {result['stored_legos']}")

                # Load detailed results for analysis
                if os.path.exists(result['results_file']):
                    with open(result['results_file']) as f:
                        detailed_data = json.load(f)
                        detailed_results = detailed_data['results']
                        metrics = self._calculate_metrics(detailed_results, model)
                        self.results[model] = metrics

            # Break between models to let router stabilize
            if i < len(available_models):
                print(f"Waiting 60s before next model...")
                time.sleep(60)

        # Final comparison
        comparison = self.compare_all_models()
        return comparison

def main():
    """Main training orchestrator"""
    print("LLARP MULTI-MODEL TRAINING SYSTEM")
    print("=" * 60)

    trainer = MultiModelTrainer()

    # Check if we should run training or just analysis
    if len(sys.argv) > 1 and sys.argv[1] == "--analyze-only":
        print("Analysis-only mode")
        trainer.compare_all_models()
        return

    # Run multi-model training
    result = trainer.run_multi_model_training()

    if result:
        print(f"\n{'='*60}")
        print("MULTI-MODEL TRAINING COMPLETE")
        print(f"{'='*60}")
        print(f"Best model: {result.get('best_model', 'Unknown')}")

        # Save comparison results
        comparison_file = f"model_comparison_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(comparison_file, 'w') as f:
            json.dump(result, f, indent=2, default=str)

        print(f"Comparison saved: {comparison_file}")

if __name__ == "__main__":
    main()