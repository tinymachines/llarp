#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Multi-Router Management System
Handles coordination between multiple connected OpenWRT routers
"""

import json
from typing import Dict, List, Set
from router_manager import RouterManager

class MultiRouterManager:
    def __init__(self):
        self.router_manager = RouterManager()
        self.discovered_routers = {}
        self.topology = {}
        
    def discover_router_topology(self, entry_router: str) -> Dict:
        """Discover all routers in the network topology"""
        print(f"🕷️ Discovering router topology starting from {entry_router}")
        
        visited = set()
        to_discover = [entry_router]
        topology = {"routers": {}, "connections": []}
        
        while to_discover:
            current_router = to_discover.pop(0)
            if current_router in visited:
                continue
                
            print(f"🔍 Scanning router: {current_router}")
            
            try:
                # Get router info
                router_info = self.scan_single_router(current_router)
                topology["routers"][current_router] = router_info
                visited.add(current_router)
                
                # Find connected routers from routing table and ARP
                connected_routers = self.find_connected_routers(current_router, router_info)
                
                for connected_router in connected_routers:
                    if connected_router not in visited:
                        to_discover.append(connected_router)
                    
                    # Record connection
                    connection = {
                        "from": current_router,
                        "to": connected_router,
                        "type": "layer3"  # Could be extended for different connection types
                    }
                    if connection not in topology["connections"]:
                        topology["connections"].append(connection)
                        
            except Exception as e:
                print(f"❌ Failed to scan {current_router}: {e}")
                topology["routers"][current_router] = {"error": str(e), "accessible": False}
        
        self.topology = topology
        return topology
    
    def scan_single_router(self, router_ip: str) -> Dict:
        """Get comprehensive info about a single router"""
        try:
            # Test basic connectivity
            if not self.router_manager.test_connection(router_ip):
                return {"accessible": False, "error": "No SSH access"}
            
            # Get basic info
            hostname = self.router_manager.get_hostname(router_ip)
            status = self.router_manager.get_router_status(router_ip)
            
            # Get network configuration
            network_result = self.router_manager.execute_command(router_ip, "uci show network")
            dhcp_result = self.router_manager.execute_command(router_ip, "uci show dhcp")
            routes_result = self.router_manager.execute_command(router_ip, "ip route show")
            interfaces_result = self.router_manager.execute_command(router_ip, "ip addr show")
            
            return {
                "accessible": True,
                "hostname": hostname,
                "status": status,
                "network_config": network_result.get("stdout", ""),
                "dhcp_config": dhcp_result.get("stdout", ""),
                "routes": routes_result.get("stdout", ""),
                "interfaces": interfaces_result.get("stdout", ""),
                "scan_time": status.get("last_check")
            }
            
        except Exception as e:
            return {"accessible": False, "error": str(e)}
    
    def find_connected_routers(self, router_ip: str, router_info: Dict) -> List[str]:
        """Find other routers connected to this one"""
        connected_routers = []
        
        try:
            routes = router_info.get("routes", "")
            
            # Look for routes that might point to other routers
            # Example: "15.0.0.0/24 via 13.0.0.73" suggests 13.0.0.73 might be another router
            for line in routes.split('\n'):
                if 'via' in line:
                    parts = line.split('via')
                    if len(parts) > 1:
                        gateway = parts[1].strip().split()[0]
                        if self.is_likely_router(gateway):
                            connected_routers.append(gateway)
            
            # Also check ARP table for potential routers
            arp_result = self.router_manager.execute_command(router_ip, "cat /proc/net/arp")
            if arp_result.get("success"):
                arp_lines = arp_result["stdout"].split('\n')[1:]  # Skip header
                for line in arp_lines:
                    if line.strip():
                        ip = line.split()[0]
                        if self.is_likely_router(ip) and ip != router_ip:
                            # Test if it's actually a router
                            if self.router_manager.test_connection(ip):
                                connected_routers.append(ip)
        
        except Exception as e:
            print(f"⚠️ Error finding connected routers for {router_ip}: {e}")
        
        return list(set(connected_routers))  # Remove duplicates
    
    def is_likely_router(self, ip: str) -> bool:
        """Heuristic to determine if an IP might be a router"""
        # Common router IP patterns
        router_patterns = [
            r"\.1$",      # Ends with .1 (common gateway)
            r"\.254$",    # Ends with .254 (common gateway)
            r"^192\.168", # Private Class C
            r"^10\.",     # Private Class A
            r"^172\."     # Private Class B
        ]
        
        import re
        for pattern in router_patterns:
            if re.search(pattern, ip):
                return True
        return False
    
    def configure_inter_router_connectivity(self, router1: str, router2: str) -> Dict:
        """Set up proper connectivity between two routers"""
        print(f"🔗 Configuring connectivity between {router1} and {router2}")
        
        # This would implement the logic to:
        # 1. Set up proper DHCP server configuration
        # 2. Configure routing between networks
        # 3. Set up firewall rules
        # 4. Test connectivity
        
        # For now, return a placeholder
        return {
            "success": False,
            "message": "Inter-router configuration not yet implemented",
            "recommendations": [
                f"Check DHCP server configuration on {router1}",
                f"Verify routing table entries",
                f"Test manual IP assignment"
            ]
        }
    
    def get_topology_summary(self) -> str:
        """Get a human-readable topology summary"""
        if not self.topology:
            return "No topology discovered yet"
        
        summary = "🕷️ **Network Topology:**\n\n"
        
        # List routers
        summary += "**Routers:**\n"
        for router_ip, info in self.topology["routers"].items():
            if info.get("accessible"):
                hostname = info.get("hostname", "unknown")
                summary += f"- {hostname} ({router_ip}) - ✅ Accessible\n"
            else:
                summary += f"- {router_ip} - ❌ {info.get('error', 'Unknown error')}\n"
        
        # List connections
        summary += "\n**Connections:**\n"
        for conn in self.topology["connections"]:
            summary += f"- {conn['from']} → {conn['to']}\n"
        
        return summary
    
    def create_unified_dashboard(self) -> Dict:
        """Create a unified view of all routers"""
        dashboard = {
            "timestamp": self.router_manager.sessions,
            "routers": {},
            "network_health": "unknown",
            "total_devices": 0
        }
        
        for router_ip, info in self.topology.get("routers", {}).items():
            if info.get("accessible"):
                # Get current status
                current_status = self.router_manager.get_router_status(router_ip)
                dashboard["routers"][router_ip] = {
                    "hostname": info.get("hostname"),
                    "status": current_status,
                    "role": self.determine_router_role(router_ip, info)
                }
        
        return dashboard
    
    def determine_router_role(self, router_ip: str, router_info: Dict) -> str:
        """Determine the role of a router in the network"""
        # Check if it has internet access
        ping_result = self.router_manager.execute_command(router_ip, "ping -c 1 8.8.8.8")
        has_internet = ping_result.get("success", False)
        
        # Check if it serves DHCP
        dhcp_config = router_info.get("dhcp_config", "")
        serves_dhcp = "dhcp.lan.dhcpv4='server'" in dhcp_config
        
        if has_internet and serves_dhcp:
            return "gateway"
        elif serves_dhcp:
            return "access_point"
        else:
            return "client"

# Example usage
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python multi_router_manager.py <entry_router_ip>")
        sys.exit(1)
    
    entry_router = sys.argv[1]
    
    manager = MultiRouterManager()
    topology = manager.discover_router_topology(entry_router)
    
    print("\n" + "="*60)
    print(manager.get_topology_summary())
    print("="*60)
    
    # Create dashboard
    dashboard = manager.create_unified_dashboard()
    print(f"\nUnified Dashboard:")
    print(json.dumps(dashboard, indent=2))