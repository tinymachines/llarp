#!/bin/bash

# Activate tinymachines Python environment
# Source this file or use as wrapper for Python commands

TINYMACHINES_ENV="$HOME/.pyenv/versions/tinymachines/bin/activate"

if [[ -f "$TINYMACHINES_ENV" ]]; then
    source "$TINYMACHINES_ENV"
    echo "✓ Activated tinymachines Python environment"
else
    echo "✗ Error: tinymachines environment not found at $TINYMACHINES_ENV"
    echo "Create with: pyenv virtualenv 3.13 tinymachines"
    exit 1
fi

# If arguments provided, execute them in the environment
if [[ $# -gt 0 ]]; then
    exec "$@"
fi