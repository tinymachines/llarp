#!/bin/bash

# Activate LLARP pyenv environment
# Source this file to ensure you're using the correct Python environment
# Usage: source ./activate_env.sh

PYENV_ACTIVATE="$HOME/.pyenv/versions/tinymachines/bin/activate"

if [[ -f "$PYENV_ACTIVATE" ]]; then
    echo "🐍 Activating pyenv environment: tinymachines"
    source "$PYENV_ACTIVATE"
    echo "✅ Using Python: $(which python)"
    echo "✅ Python version: $(python --version)"
    
    # Set up environment variables for the project
    export LLARP_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export PYTHONPATH="$LLARP_PROJECT_ROOT/llarp-ai:$PYTHONPATH"
    
    echo "✅ LLARP environment activated"
    echo "   Project root: $LLARP_PROJECT_ROOT"
    echo ""
    echo "Available commands:"
    echo "  ./llarp-cli - Main CLI interface"
    echo "  ./startit.sh - Start all services"
    echo "  cd llarp-ai && python doc_embedder.py - Documentation embedder"
    echo "  cd llarp-ai && python router_manager.py - Router management"
    echo ""
else
    echo "❌ pyenv environment not found at: $PYENV_ACTIVATE"
    echo "   Please ensure the 'tinymachines' environment exists:"
    echo "   pyenv virtualenv 3.11 tinymachines"
    echo "   pyenv activate tinymachines"
    echo "   pip install -r llarp-ai/requirements.txt"
fi