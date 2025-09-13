#!/bin/bash

# LLARP Startup Script
# Launches the OpenWRT Configuration Management & AI Chat System

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════╗"
echo "║                    LLARP                       ║"
echo "║     OpenWRT AI Configuration Management        ║"
echo "║              🤖 Starting Up... 🚀              ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a service is running
service_running() {
    pgrep -f "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

# Check Node.js
if ! command_exists node; then
    echo -e "${RED}❌ Node.js not found. Please install Node.js${NC}"
    exit 1
fi

# Check Python
if ! command_exists python3; then
    echo -e "${RED}❌ Python 3 not found. Please install Python 3${NC}"
    exit 1
fi

# Check Ollama
if ! command_exists ollama; then
    echo -e "${RED}❌ Ollama not found. Please install Ollama${NC}"
    exit 1
fi

# Check if Ollama is running
if ! service_running "ollama"; then
    echo -e "${YELLOW}⚠️  Ollama service not running. Attempting to start...${NC}"
    if command_exists systemctl; then
        sudo systemctl start ollama || echo -e "${YELLOW}Could not start ollama service automatically${NC}"
    else
        echo -e "${YELLOW}Please start Ollama manually: ollama serve${NC}"
    fi
fi

# Check if required Ollama models are available
echo -e "${YELLOW}📦 Checking Ollama models...${NC}"
if ! ollama list | grep -q "nomic-embed-text"; then
    echo -e "${YELLOW}🔄 Pulling embedding model: nomic-embed-text:v1.5${NC}"
    ollama pull nomic-embed-text:v1.5
fi

if ! ollama list | grep -q "mistral-small"; then
    echo -e "${YELLOW}🔄 Checking for chat model...${NC}"
    if ollama list | grep -q "devstral"; then
        echo -e "${GREEN}✅ Found devstral model${NC}"
    else
        echo -e "${YELLOW}⚠️  No suitable chat model found. Consider pulling mistral-small3.2:24b or devstral:24b${NC}"
    fi
fi

echo -e "${GREEN}✅ Prerequisites checked${NC}"

# Setup Python environment for llarp-ai
echo -e "${YELLOW}🐍 Setting up Python environment...${NC}"

# Activate pyenv virtual environment
PYENV_ACTIVATE="$HOME/.pyenv/versions/tinymachines/bin/activate"
if [[ -f "$PYENV_ACTIVATE" ]]; then
    echo -e "${BLUE}🔧 Activating pyenv environment: tinymachines${NC}"
    source "$PYENV_ACTIVATE"
    echo -e "${GREEN}✅ Using Python: $(which python)${NC}"
    echo -e "${GREEN}✅ Python version: $(python --version)${NC}"
else
    echo -e "${YELLOW}⚠️  pyenv environment not found at: $PYENV_ACTIVATE${NC}"
    echo -e "${YELLOW}   Falling back to system Python${NC}"
fi

cd llarp-ai

# Install Python dependencies if requirements.txt exists
if [[ -f requirements.txt ]]; then
    if ! python -c "import requests" >/dev/null 2>&1; then
        echo -e "${YELLOW}📦 Installing Python dependencies...${NC}"
        pip install -r requirements.txt
    fi
fi

echo -e "${GREEN}✅ Python environment ready${NC}"

# Setup Node.js environment for web server
echo -e "${YELLOW}🌐 Setting up web server...${NC}"
cd ../app

# Install Node.js dependencies
if [[ ! -d node_modules ]]; then
    echo -e "${YELLOW}📦 Installing Node.js dependencies...${NC}"
    npm install
fi

echo -e "${GREEN}✅ Web server ready${NC}"

# Function to start web server
start_web_server() {
    echo -e "${BLUE}🌐 Starting documentation web server on port 8222...${NC}"
    cd ../app
    npm start &
    WEB_SERVER_PID=$!
    echo $WEB_SERVER_PID > ../web_server.pid
    echo -e "${GREEN}✅ Web server started (PID: $WEB_SERVER_PID)${NC}"
    echo -e "${CYAN}📖 Documentation available at: http://localhost:8222${NC}"
}

# Function to embed documentation
embed_docs() {
    echo -e "${BLUE}📚 Processing OpenWRT documentation...${NC}"
    cd ../llarp-ai
    
    # Ensure pyenv environment is active
    if [[ -f "$PYENV_ACTIVATE" ]]; then
        source "$PYENV_ACTIVATE"
    fi
    
    # Check if docs exist
    if [[ ! -d ../openwrt/openwrt.org.md ]]; then
        echo -e "${YELLOW}⚠️  OpenWRT documentation not found at ../openwrt/openwrt.org.md${NC}"
        echo -e "${YELLOW}   This is optional for CLI usage but required for AI chat${NC}"
        return 0
    fi
    
    # Check if embeddings already exist and are recent
    if [[ -f openwrt_docs_metadata.json ]]; then
        echo -e "${GREEN}✅ Found existing documentation embeddings${NC}"
        echo -e "${CYAN}💡 To rebuild embeddings, run: python doc_embedder.py process${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}🔄 Creating documentation embeddings (this may take a while)...${NC}"
    python doc_embedder.py process
    echo -e "${GREEN}✅ Documentation embeddings complete${NC}"
}

# Function to show startup complete message
show_completion() {
    echo -e "\n${GREEN}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║                🎉 LLARP READY! 🎉               ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}🔧 Available Commands:${NC}"
    echo -e "  ${YELLOW}./llarp-cli${NC} - Main CLI interface"
    echo -e "  ${YELLOW}./llarp-cli target <router_ip>${NC} - Set target router"
    echo -e "  ${YELLOW}./llarp-cli scan${NC} - Scan current router"
    echo -e "  ${YELLOW}./llarp-cli analyze${NC} - AI analysis of router config"
    echo ""
    echo -e "${CYAN}🔬 Development Commands:${NC}"
    echo -e "  ${YELLOW}cd llarp-ai && python router_manager.py status${NC} - Router status"
    echo -e "  ${YELLOW}cd llarp-ai && python doc_embedder.py search 'wifi config'${NC} - Search docs"
    echo ""
    echo -e "${CYAN}🌐 Web Interface:${NC}"
    echo -e "  ${YELLOW}http://localhost:8222${NC} - Documentation browser"
    echo ""
    echo -e "${PURPLE}Ready for your devious OpenWRT automation schemes! 😈${NC}"
}

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}🧹 Cleaning up...${NC}"
    
    # Kill web server if running
    if [[ -f web_server.pid ]]; then
        WEB_PID=$(cat web_server.pid)
        if kill -0 $WEB_PID 2>/dev/null; then
            echo -e "${YELLOW}🛑 Stopping web server (PID: $WEB_PID)...${NC}"
            kill $WEB_PID
        fi
        rm -f web_server.pid
    fi
    
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Parse command line arguments
EMBED_DOCS=true
START_WEB=true
INTERACTIVE=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-embed)
            EMBED_DOCS=false
            shift
            ;;
        --no-web)
            START_WEB=false
            shift
            ;;
        --no-interactive)
            INTERACTIVE=false
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --no-embed        Skip documentation embedding"
            echo "  --no-web          Don't start web server"
            echo "  --no-interactive  Exit after startup (don't wait)"
            echo "  --help, -h        Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Main startup sequence
cd "$(dirname "$0")"

# Start web server
if [[ "$START_WEB" == true ]]; then
    start_web_server
    sleep 2  # Give web server time to start
fi

# Process documentation
if [[ "$EMBED_DOCS" == true ]]; then
    embed_docs
fi

# Show completion message
show_completion

# Interactive mode - wait for user input
if [[ "$INTERACTIVE" == true ]]; then
    echo -e "\n${YELLOW}Press Ctrl+C to stop all services and exit...${NC}"
    echo ""
    
    # Wait indefinitely
    while true; do
        sleep 1
    done
else
    echo -e "\n${YELLOW}Startup complete. Services running in background.${NC}"
    echo -e "${YELLOW}Use 'pkill -f startit.sh' to stop services.${NC}"
fi