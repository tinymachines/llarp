#!/usr/bin/env python3

import sys
import os
import json
from datetime import datetime

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

def main():
    print("QWEN3-CODER:30B DIRECT TRAINING")
    print("="*50)

    # Create trainer
    trainer = LLARPTrainer(router_ip="192.168.100.1")

    # Force qwen model for all capabilities
    qwen_model = "qwen3-coder:30b"
    trainer.workflow_engine.best_models = {
        "decomposition": qwen_model,
        "technical_understanding": qwen_model,
        "execution_planning": qwen_model,
        "solution_synthesis": qwen_model
    }

    # Update results filename to distinguish from mistral
    trainer.results_file = f"llarp_training_results_qwen_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

    print(f"Model: {qwen_model}")
    print(f"Router: {trainer.router_ip}")
    print(f"Results: {trainer.results_file}")

    # Run complete training suite
    print(f"\nStarting training across all 25 scenarios...")
    summary = trainer.run_training_suite()

    print(f"\nQWEN TRAINING COMPLETE!")
    print(f"Total tests: {summary['total_tests']}")
    print(f"Successful: {summary['successful']}")
    print(f"Failed: {summary['failed']}")
    print(f"Stored legos: {summary['stored_legos']}")
    print(f"Success rate: {summary['success_rate']:.1%}")
    print(f"Results saved: {summary['results_file']}")

    return summary

if __name__ == "__main__":
    try:
        result = main()
        sys.exit(0)
    except KeyboardInterrupt:
        print("\nTraining interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"Training failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)