#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OpenWRT Router AI Chat System
Combines vector search through OpenWRT docs with live router management
"""

import os
import sys
import json
import time
import requests
from datetime import datetime
from typing import Dict, List, Optional, Any
import asyncio
import logging

# Add vectl to path
vectl_build_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../repos/vectl/build")
sys.path.append(vectl_build_path)

try:
    import vector_cluster_store_py
    VECTOR_STORE_AVAILABLE = True
except ImportError:
    print("⚠️  Vector store not available - chat will work without documentation search")
    VECTOR_STORE_AVAILABLE = False
    vector_cluster_store_py = None

from router_manager import RouterManager
from doc_embedder import OpenWRTDocEmbedder

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
OLLAMA_CHAT_URL = "http://127.0.0.1:11434/api/chat"
OLLAMA_GENERATE_URL = "http://127.0.0.1:11434/api/generate"
CHAT_MODEL = "mistral-small3.2:24b"  # or "devstral:24b"
MAX_CONTEXT_VECTORS = 5
MAX_CONVERSATION_HISTORY = 20

class RouterAIChat:
    def __init__(self):
        self.router_manager = RouterManager()
        self.doc_embedder = OpenWRTDocEmbedder() if VECTOR_STORE_AVAILABLE else None
        self.conversation_history = []
        self.current_router = None
        
        # Initialize systems
        self.initialize_systems()
    
    def initialize_systems(self):
        """Initialize all subsystems"""
        print("🤖 Initializing OpenWRT AI Chat System...")
        
        # Initialize document embedder if available
        if self.doc_embedder:
            if self.doc_embedder.init_vector_store():
                self.doc_embedder.load_metadata()
                print(f"✅ Loaded {len(self.doc_embedder.metadata['entries'])} document vectors")
            else:
                print("⚠️  Document search unavailable")
                self.doc_embedder = None
        
        # Get current target router
        self.current_router = self.router_manager.get_target_router()
        if self.current_router:
            print(f"🎯 Target router: {self.current_router}")
        else:
            print("⚠️  No target router set - use 'set target <router_ip>' in chat")
    
    def search_documentation(self, query: str, k: int = MAX_CONTEXT_VECTORS) -> List[Dict]:
        """Search through OpenWRT documentation"""
        if not self.doc_embedder:
            return []
        
        try:
            matches = self.doc_embedder.search_docs(query, k)
            return matches
        except Exception as e:
            logger.error(f"Documentation search failed: {e}")
            return []
    
    def get_router_context(self) -> Dict[str, Any]:
        """Get current router context and status"""
        if not self.current_router:
            return {"status": "no_router", "message": "No target router configured"}
        
        try:
            # Get router status
            status = self.router_manager.get_router_status(self.current_router)
            
            # Get recent command history
            history = self.router_manager.get_session_history(self.current_router, limit=5)
            
            return {
                "status": "connected",
                "router_ip": self.current_router,
                "router_info": status,
                "recent_commands": history
            }
        except Exception as e:
            return {
                "status": "error", 
                "router_ip": self.current_router,
                "error": str(e)
            }
    
    def execute_router_command(self, command: str) -> Dict[str, Any]:
        """Execute a command on the current router"""
        if not self.current_router:
            return {"success": False, "error": "No target router configured"}
        
        try:
            result = self.router_manager.execute_command(self.current_router, command)
            return result
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def build_system_prompt(self, user_query: str, context_docs: List[Dict], router_context: Dict) -> str:
        """Build the system prompt with context"""
        
        system_prompt = """You are an expert OpenWRT router assistant. You can:

1. **Answer questions** about OpenWRT configuration, networking, and troubleshooting
2. **Execute commands** on the target router when requested
3. **Analyze router state** and provide recommendations
4. **Guide users** through complex router configurations

## Current Router Context:
"""
        
        # Add router context
        if router_context["status"] == "connected":
            router_info = router_context["router_info"]
            system_prompt += f"""
**Target Router:** {router_context["router_ip"]}
**Hostname:** {router_info.get("hostname", "unknown")}
**Status:** {router_info.get("status", "unknown")}
**Uptime:** {router_info.get("uptime", "unknown")}
**Last Check:** {router_info.get("last_check", "unknown")}
"""
            
            # Add recent commands if any
            if router_context.get("recent_commands"):
                system_prompt += "\n**Recent Commands:**\n"
                for cmd in router_context["recent_commands"][-3:]:  # Last 3 commands
                    status = "✅" if cmd["success"] else "❌"
                    system_prompt += f"- {status} `{cmd['command']}` ({cmd['timestamp']})\n"
        
        elif router_context["status"] == "no_router":
            system_prompt += "\n**No target router configured.** Use 'set target <router_ip>' to configure one.\n"
        else:
            system_prompt += f"\n**Router Status:** {router_context.get('error', 'Unknown error')}\n"
        
        # Add documentation context
        if context_docs:
            system_prompt += "\n## Relevant Documentation:\n"
            for i, doc in enumerate(context_docs, 1):
                system_prompt += f"""
**Doc {i}:** {doc['file_path']}
**Content:** {doc['text'][:800]}{'...' if len(doc['text']) > 800 else ''}
---
"""
        
        system_prompt += """
## Instructions:
- Provide accurate, helpful responses based on the documentation and router context
- When users ask to execute commands, explain what the command does first
- For router management tasks, use specific UCI, opkg, or shell commands
- Always prioritize safety - warn about potentially destructive operations
- If you need to execute a command, clearly state: "EXECUTE_COMMAND: <command>"
- Be concise but thorough in explanations

## Special Commands You Can Handle:
- `set target <router_ip>` - Set target router
- `router status` - Get router status
- `router info` - Get detailed router information  
- Any UCI/opkg/shell command execution

User Question: """ + user_query
        
        return system_prompt
    
    def chat_with_ollama(self, messages: List[Dict[str, str]]) -> str:
        """Send chat request to Ollama"""
        try:
            payload = {
                "model": CHAT_MODEL,
                "messages": messages,
                "stream": False
            }
            
            response = requests.post(OLLAMA_CHAT_URL, json=payload, timeout=120)
            response.raise_for_status()
            
            data = response.json()
            return data["message"]["content"]
            
        except requests.exceptions.RequestException as e:
            return f"❌ Error communicating with Ollama: {e}"
        except Exception as e:
            return f"❌ Chat error: {e}"
    
    def process_ai_response(self, ai_response: str) -> tuple[str, Optional[Dict]]:
        """Process AI response and extract any commands to execute"""
        
        # Check for command execution requests
        if "EXECUTE_COMMAND:" in ai_response:
            lines = ai_response.split('\n')
            command_lines = [line for line in lines if "EXECUTE_COMMAND:" in line]
            
            if command_lines:
                command = command_lines[0].split("EXECUTE_COMMAND:", 1)[1].strip()
                
                # Remove the command line from the response
                filtered_response = '\n'.join([line for line in lines if "EXECUTE_COMMAND:" not in line]).strip()
                
                # Execute the command
                command_result = self.execute_router_command(command)
                
                return filtered_response, command_result
        
        return ai_response, None
    
    def handle_special_commands(self, user_input: str) -> Optional[str]:
        """Handle special system commands"""
        
        user_input = user_input.strip().lower()
        
        # Set target router
        if user_input.startswith("set target "):
            router_ip = user_input.replace("set target ", "").strip()
            if self.router_manager.set_target_router(router_ip):
                self.current_router = router_ip
                return f"✅ Target router set to: {router_ip}"
            else:
                return f"❌ Failed to connect to router: {router_ip}"
        
        # Router status
        if user_input in ["router status", "status"]:
            if self.current_router:
                status = self.router_manager.get_router_status(self.current_router)
                return f"🔍 Router Status:\n{json.dumps(status, indent=2)}"
            else:
                return "❌ No target router configured"
        
        # Router info
        if user_input in ["router info", "info"]:
            if self.current_router:
                try:
                    info = self.router_manager.get_system_info(self.current_router)
                    # Simplified info display
                    summary = "🔍 Router Information:\n"
                    for key, result in info.items():
                        if result.get("success") and result.get("stdout"):
                            summary += f"**{key.title()}:**\n{result['stdout'][:200]}{'...' if len(result['stdout']) > 200 else ''}\n\n"
                    return summary
                except Exception as e:
                    return f"❌ Error getting router info: {e}"
            else:
                return "❌ No target router configured"
        
        # Help
        if user_input in ["help", "?"]:
            return """
🤖 **OpenWRT AI Chat Commands:**

**Special Commands:**
- `set target <router_ip>` - Set target router
- `router status` - Get router status
- `router info` - Get detailed router information
- `help` - Show this help message
- `exit` or `quit` - Exit chat

**Example Questions:**
- "How do I configure WiFi?"
- "Show me the firewall rules"
- "What packages are installed?"
- "Check the system logs"
- "How do I set up port forwarding?"

**Command Execution:**
Just ask naturally! For example:
- "Check the system uptime"
- "Show me the network interfaces"
- "Install the curl package"
"""
        
        return None
    
    def chat(self, user_input: str) -> str:
        """Main chat function"""
        
        # Handle special commands first
        special_response = self.handle_special_commands(user_input)
        if special_response:
            return special_response
        
        print("🔍 Searching documentation...")
        # Search relevant documentation
        context_docs = self.search_documentation(user_input)
        
        print("📡 Getting router context...")
        # Get router context
        router_context = self.get_router_context()
        
        print("🧠 Building AI prompt...")
        # Build system prompt
        system_prompt = self.build_system_prompt(user_input, context_docs, router_context)
        
        # Prepare conversation
        messages = [{"role": "system", "content": system_prompt}]
        
        # Add conversation history (last few exchanges)
        if self.conversation_history:
            messages.extend(self.conversation_history[-MAX_CONVERSATION_HISTORY:])
        
        # Add current user message
        messages.append({"role": "user", "content": user_input})
        
        print("🤖 Generating AI response...")
        # Get AI response
        ai_response = self.chat_with_ollama(messages)
        
        # Process response for command execution
        final_response, command_result = self.process_ai_response(ai_response)
        
        # Add command result to response if any
        if command_result:
            final_response += f"\n\n**Command Executed:** `{command_result.get('command', 'unknown')}`\n"
            if command_result.get("success"):
                final_response += f"**Output:**\n```\n{command_result.get('stdout', '')}\n```"
            else:
                final_response += f"**Error:**\n```\n{command_result.get('stderr', command_result.get('error', 'Unknown error'))}\n```"
        
        # Update conversation history
        self.conversation_history.append({"role": "user", "content": user_input})
        self.conversation_history.append({"role": "assistant", "content": final_response})
        
        return final_response
    
    def interactive_chat(self):
        """Run interactive chat session"""
        print("🚀 OpenWRT AI Chat System Started!")
        print("="*60)
        print("Type 'help' for commands, 'exit' to quit")
        print("="*60)
        
        while True:
            try:
                user_input = input("\n🤖 You: ").strip()
                
                if not user_input:
                    continue
                
                if user_input.lower() in ["exit", "quit", "q"]:
                    print("\n👋 Goodbye!")
                    break
                
                print("\n🔄 Processing...")
                response = self.chat(user_input)
                print(f"\n🤖 Assistant: {response}")
                
            except KeyboardInterrupt:
                print("\n\n👋 Chat interrupted. Goodbye!")
                break
            except Exception as e:
                print(f"\n❌ Error: {e}")

def main():
    """Main entry point"""
    chat_system = RouterAIChat()
    chat_system.interactive_chat()

if __name__ == "__main__":
    main()