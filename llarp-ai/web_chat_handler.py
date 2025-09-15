#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Web Chat Handler for OpenWRT AI Chat System
Handles single chat requests from the web interface
"""

import sys
import json
from router_chat import RouterAIChat

def main():
    """Handle a single chat request from stdin"""
    try:
        # Read message from stdin
        message = input().strip()
        
        if not message:
            print(json.dumps({"error": "Empty message"}))
            sys.exit(1)
        
        # Initialize chat system
        chat_system = RouterAIChat()
        
        # Process the message
        response = chat_system.chat(message)
        
        # Get router context for status updates
        router_context = chat_system.get_router_context()
        
        # Return JSON response
        result = {
            "response": response,
            "router_status": router_context if router_context["status"] != "no_router" else None
        }
        
        print(json.dumps(result))
        
    except KeyboardInterrupt:
        print(json.dumps({"error": "Request interrupted"}))
        sys.exit(1)
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

if __name__ == "__main__":
    main()