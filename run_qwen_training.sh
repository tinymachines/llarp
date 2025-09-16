#!/bin/bash

# LLARP Training with Qwen3-Coder:30b
# Automated training script with model override

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROUTER_IP="192.168.100.1"

echo -e "${CYAN}QWEN3-CODER:30B TRAINING EXECUTION${NC}"
echo "="*50

# Activate environment
if [[ -f ~/.pyenv/versions/tinymachines/bin/activate ]]; then
    source ~/.pyenv/versions/tinymachines/bin/activate
    echo -e "${GREEN}✓ Activated tinymachines Python environment${NC}"
else
    echo -e "${RED}Error: tinymachines environment not found${NC}"
    exit 1
fi

# Check dependencies
echo -e "${BLUE}Checking dependencies...${NC}"

# Check router connectivity
if ! ping -c 1 "$ROUTER_IP" >/dev/null 2>&1; then
    echo -e "${RED}Error: Router $ROUTER_IP not reachable${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Router reachable${NC}"

# Check ollama and qwen model
if ! curl -s http://127.0.0.1:11434/api/tags | grep -q "qwen3-coder:30b"; then
    echo -e "${RED}Error: qwen3-coder:30b not found in ollama${NC}"
    echo "Install with: ollama pull qwen3-coder:30b"
    exit 1
fi
echo -e "${GREEN}✓ qwen3-coder:30b available${NC}"

# Create custom trainer script that forces qwen model
cat > /tmp/qwen_trainer.py << 'EOF'
#!/usr/bin/env python3

import sys
import os

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

def main():
    print("🤖 QWEN3-CODER:30B TRAINING SESSION")
    print("="*50)

    # Create trainer with qwen model override
    trainer = LLARPTrainer(router_ip="192.168.100.1")

    # Force qwen for all capabilities
    qwen_model = "qwen3-coder:30b"
    trainer.workflow_engine.best_models = {
        "decomposition": qwen_model,
        "technical_understanding": qwen_model,
        "execution_planning": qwen_model,
        "solution_synthesis": qwen_model
    }

    # Update results filename
    from datetime import datetime
    trainer.results_file = f"llarp_training_results_qwen_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

    print(f"Using model: {qwen_model}")
    print(f"Results file: {trainer.results_file}")

    # Run training
    summary = trainer.run_training_suite()

    print(f"\nQWEN TRAINING SUMMARY")
    print(f"Success rate: {summary['success_rate']:.1%}")
    print(f"Total tests: {summary['total_tests']}")
    print(f"Successful: {summary['successful']}")
    print(f"Failed: {summary['failed']}")
    print(f"Stored legos: {summary['stored_legos']}")

    return summary

if __name__ == "__main__":
    main()
EOF

chmod +x /tmp/qwen_trainer.py

echo -e "${BLUE}Starting qwen3-coder:30b training...${NC}"
echo -e "${YELLOW}This will execute 25 tests on the router${NC}"
echo -e "${YELLOW}Expected duration: ~90 minutes (qwen is faster than mistral)${NC}"

read -p "Continue with qwen training? (y/N): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Change to project directory
cd "$SCRIPT_DIR"

# Run the qwen training
echo -e "${PURPLE}Executing qwen training suite...${NC}"
python3 /tmp/qwen_trainer.py

echo -e "${GREEN}Qwen training completed!${NC}"

# Clean up temp file
rm -f /tmp/qwen_trainer.py

echo -e "${CYAN}Check results in llarp_training_results_qwen_*.json${NC}"