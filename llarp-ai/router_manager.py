#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OpenWRT Router State Management System
Handles SSH connections, command execution, and state tracking for OpenWRT routers
"""

import os
import json
import subprocess
import time
from datetime import datetime, timedelta
from pathlib import Path
import paramiko
import logging
from typing import Dict, List, Optional, Any

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RouterManager:
    def __init__(self, config_dir="~/.config/llarp"):
        self.config_dir = Path(config_dir).expanduser()
        self.config_dir.mkdir(parents=True, exist_ok=True)
        
        self.routers_file = self.config_dir / "routers.json"
        self.sessions_file = self.config_dir / "router_sessions.json"
        
        self.routers = self.load_routers()
        self.sessions = self.load_sessions()
        self.ssh_options = "-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    
    def load_routers(self) -> Dict:
        """Load router configuration"""
        if self.routers_file.exists():
            try:
                with open(self.routers_file, 'r') as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Error loading routers: {e}")
        
        return {"target_router": None, "routers": {}}
    
    def save_routers(self):
        """Save router configuration"""
        try:
            with open(self.routers_file, 'w') as f:
                json.dump(self.routers, f, indent=2)
        except Exception as e:
            logger.error(f"Error saving routers: {e}")
    
    def load_sessions(self) -> Dict:
        """Load session data"""
        if self.sessions_file.exists():
            try:
                with open(self.sessions_file, 'r') as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Error loading sessions: {e}")
        
        return {}
    
    def save_sessions(self):
        """Save session data"""
        try:
            with open(self.sessions_file, 'w') as f:
                json.dump(self.sessions, f, indent=2)
        except Exception as e:
            logger.error(f"Error saving sessions: {e}")
    
    def set_target_router(self, router_ip: str) -> bool:
        """Set the target router"""
        if self.test_connection(router_ip):
            hostname = self.get_hostname(router_ip)
            
            self.routers["target_router"] = router_ip
            self.routers["routers"][router_ip] = {
                "hostname": hostname,
                "last_connected": datetime.now().isoformat(),
                "status": "connected"
            }
            
            self.save_routers()
            logger.info(f"Target router set: {hostname} ({router_ip})")
            return True
        
        return False
    
    def get_target_router(self) -> Optional[str]:
        """Get current target router IP"""
        return self.routers.get("target_router")
    
    def test_connection(self, router_ip: str) -> bool:
        """Test SSH connection to router"""
        try:
            cmd = f"ssh {self.ssh_options} root@{router_ip} 'exit'"
            result = subprocess.run(cmd, shell=True, capture_output=True, timeout=15)
            return result.returncode == 0
        except Exception as e:
            logger.error(f"Connection test failed for {router_ip}: {e}")
            return False
    
    def get_hostname(self, router_ip: str) -> str:
        """Get router hostname"""
        try:
            cmd = f"ssh {self.ssh_options} root@{router_ip} \"uci get system.@system[0].hostname 2>/dev/null || echo 'unknown'\""
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=15)
            if result.returncode == 0:
                return result.stdout.strip()
        except Exception as e:
            logger.error(f"Failed to get hostname for {router_ip}: {e}")
        
        return "unknown"
    
    def execute_command(self, router_ip: str, command: str, timeout: int = 30) -> Dict[str, Any]:
        """Execute a command on the router"""
        try:
            start_time = time.time()
            
            # Build SSH command
            ssh_cmd = f"ssh {self.ssh_options} root@{router_ip} '{command}'"
            
            # Execute command
            result = subprocess.run(
                ssh_cmd, 
                shell=True, 
                capture_output=True, 
                text=True, 
                timeout=timeout
            )
            
            execution_time = time.time() - start_time
            
            # Prepare result
            cmd_result = {
                "command": command,
                "router_ip": router_ip,
                "timestamp": datetime.now().isoformat(),
                "execution_time": execution_time,
                "returncode": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr,
                "success": result.returncode == 0
            }
            
            # Log command execution
            self.log_command_execution(cmd_result)
            
            return cmd_result
            
        except subprocess.TimeoutExpired:
            return {
                "command": command,
                "router_ip": router_ip,
                "timestamp": datetime.now().isoformat(),
                "error": "Command timeout",
                "success": False
            }
        except Exception as e:
            return {
                "command": command,
                "router_ip": router_ip,
                "timestamp": datetime.now().isoformat(),
                "error": str(e),
                "success": False
            }
    
    def log_command_execution(self, result: Dict[str, Any]):
        """Log command execution for session tracking"""
        router_ip = result["router_ip"]
        
        if router_ip not in self.sessions:
            self.sessions[router_ip] = {
                "commands": [],
                "session_start": datetime.now().isoformat(),
                "last_activity": datetime.now().isoformat()
            }
        
        # Add command to session
        self.sessions[router_ip]["commands"].append({
            "timestamp": result["timestamp"],
            "command": result["command"],
            "success": result["success"],
            "execution_time": result.get("execution_time", 0)
        })
        
        # Update last activity
        self.sessions[router_ip]["last_activity"] = datetime.now().isoformat()
        
        # Keep only last 100 commands per router
        if len(self.sessions[router_ip]["commands"]) > 100:
            self.sessions[router_ip]["commands"] = self.sessions[router_ip]["commands"][-100:]
        
        self.save_sessions()
    
    # OpenWRT-specific command wrappers
    def uci_get(self, router_ip: str, config_path: str) -> Dict[str, Any]:
        \"\"\"Get UCI configuration value\"\"\"
        command = f\"uci get {config_path}\"
        return self.execute_command(router_ip, command)
    
    def uci_set(self, router_ip: str, config_path: str, value: str) -> Dict[str, Any]:
        \"\"\"Set UCI configuration value\"\"\"
        command = f\"uci set {config_path}='{value}'\"
        return self.execute_command(router_ip, command)
    
    def uci_commit(self, router_ip: str, config: str = \"\") -> Dict[str, Any]:
        \"\"\"Commit UCI changes\"\"\"
        command = f\"uci commit {config}\".strip()
        return self.execute_command(router_ip, command)
    
    def uci_show(self, router_ip: str, config: str = \"\") -> Dict[str, Any]:
        \"\"\"Show UCI configuration\"\"\"
        command = f\"uci show {config}\".strip()
        return self.execute_command(router_ip, command)
    
    def opkg_list(self, router_ip: str, pattern: str = \"\") -> Dict[str, Any]:
        \"\"\"List installed packages\"\"\"
        command = f\"opkg list-installed {pattern}\".strip()
        return self.execute_command(router_ip, command)
    
    def opkg_install(self, router_ip: str, package: str) -> Dict[str, Any]:
        \"\"\"Install package\"\"\"
        command = f\"opkg install {package}\"
        return self.execute_command(router_ip, command, timeout=120)  # Longer timeout for installs
    
    def opkg_remove(self, router_ip: str, package: str) -> Dict[str, Any]:
        \"\"\"Remove package\"\"\"
        command = f\"opkg remove {package}\"
        return self.execute_command(router_ip, command)
    
    def opkg_update(self, router_ip: str) -> Dict[str, Any]:
        \"\"\"Update package lists\"\"\"
        command = \"opkg update\"
        return self.execute_command(router_ip, command, timeout=120)
    
    def get_system_info(self, router_ip: str) -> Dict[str, Any]:
        \"\"\"Get comprehensive system information\"\"\"
        commands = {
            \"hostname\": \"uci get system.@system[0].hostname\",
            \"uptime\": \"uptime\",
            \"memory\": \"cat /proc/meminfo\",
            \"cpuinfo\": \"cat /proc/cpuinfo\",
            \"version\": \"cat /etc/openwrt_release\",
            \"kernel\": \"uname -a\",
            \"load\": \"cat /proc/loadavg\",
            \"disk_usage\": \"df -h\",
            \"network_interfaces\": \"ip addr show\",
            \"wireless_info\": \"iw dev\",
            \"running_processes\": \"ps aux\",
            \"routing_table\": \"ip route show\",
            \"firewall_rules\": \"iptables -L -n\"
        }
        
        results = {}
        for key, command in commands.items():
            try:
                result = self.execute_command(router_ip, command)
                results[key] = result
                time.sleep(0.1)  # Small delay between commands
            except Exception as e:
                results[key] = {\"error\": str(e), \"success\": False}
        
        return results
    
    def get_log_data(self, router_ip: str, lines: int = 100) -> Dict[str, Any]:
        \"\"\"Get system logs\"\"\"
        commands = {
            \"system_log\": f\"logread -l {lines}\",
            \"kernel_log\": f\"dmesg | tail -n {lines}\",
            \"wifi_log\": \"logread | grep -i wifi | tail -n 50\",
            \"network_log\": \"logread | grep -i network | tail -n 50\"
        }
        
        results = {}
        for key, command in commands.items():
            try:
                result = self.execute_command(router_ip, command)
                results[key] = result
            except Exception as e:
                results[key] = {\"error\": str(e), \"success\": False}
        
        return results
    
    def restart_service(self, router_ip: str, service: str) -> Dict[str, Any]:
        \"\"\"Restart a service\"\"\"
        command = f\"/etc/init.d/{service} restart\"
        return self.execute_command(router_ip, command)
    
    def reboot_router(self, router_ip: str) -> Dict[str, Any]:
        \"\"\"Reboot the router\"\"\"
        command = \"reboot\"
        return self.execute_command(router_ip, command)
    
    def get_router_status(self, router_ip: str) -> Dict[str, Any]:
        \"\"\"Get quick router status\"\"\"
        try:
            result = self.execute_command(router_ip, \"echo 'Router is responsive'\", timeout=10)
            
            if result[\"success\"]:
                hostname = self.get_hostname(router_ip)
                uptime_result = self.execute_command(router_ip, \"uptime\")
                
                return {
                    \"router_ip\": router_ip,
                    \"hostname\": hostname,
                    \"status\": \"online\",
                    \"uptime\": uptime_result.get(\"stdout\", \"\").strip(),
                    \"last_check\": datetime.now().isoformat(),
                    \"response_time\": result.get(\"execution_time\", 0)
                }
            else:
                return {
                    \"router_ip\": router_ip,
                    \"status\": \"offline\",
                    \"error\": result.get(\"error\", \"Connection failed\"),
                    \"last_check\": datetime.now().isoformat()
                }
        
        except Exception as e:
            return {
                \"router_ip\": router_ip,
                \"status\": \"error\",
                \"error\": str(e),
                \"last_check\": datetime.now().isoformat()
            }
    
    def get_session_history(self, router_ip: str, limit: int = 20) -> List[Dict]:
        \"\"\"Get command history for a router\"\"\"
        if router_ip in self.sessions:
            commands = self.sessions[router_ip].get(\"commands\", [])
            return commands[-limit:] if limit else commands
        return []
    
    def cleanup_old_sessions(self, days: int = 7):
        \"\"\"Remove session data older than specified days\"\"\"
        cutoff_date = datetime.now() - timedelta(days=days)
        
        for router_ip in list(self.sessions.keys()):
            session = self.sessions[router_ip]
            last_activity = datetime.fromisoformat(session.get(\"last_activity\", \"\"))
            
            if last_activity < cutoff_date:
                del self.sessions[router_ip]
                logger.info(f\"Cleaned up old session for {router_ip}\")
        
        self.save_sessions()

# Example usage and testing
if __name__ == \"__main__\":
    import sys
    
    rm = RouterManager()
    
    if len(sys.argv) < 2:
        print(\"Usage: python router_manager.py <command> [args...]\")
        print(\"Commands: status, info, uci-get, uci-set, logs, test\")
        sys.exit(1)
    
    command = sys.argv[1]
    router_ip = rm.get_target_router()
    
    if not router_ip and command != \"test\":
        print(\"No target router set. Use llarp-cli to set one first.\")
        sys.exit(1)
    
    if command == \"status\":
        status = rm.get_router_status(router_ip)
        print(json.dumps(status, indent=2))
    
    elif command == \"info\":
        info = rm.get_system_info(router_ip)
        print(json.dumps(info, indent=2))
    
    elif command == \"uci-get\" and len(sys.argv) > 2:
        result = rm.uci_get(router_ip, sys.argv[2])
        print(f\"Value: {result.get('stdout', 'Error').strip()}\")
    
    elif command == \"logs\":
        logs = rm.get_log_data(router_ip)
        for log_type, result in logs.items():
            print(f\"\
=== {log_type.upper()} ===\")
            if result.get(\"success\"):
                print(result[\"stdout\"])
            else:
                print(f\"Error: {result.get('error', 'Unknown error')}\")
    
    elif command == \"test\":
        test_ip = sys.argv[2] if len(sys.argv) > 2 else \"192.168.1.1\"
        print(f\"Testing connection to {test_ip}...\")
        if rm.test_connection(test_ip):
            print(\"✅ Connection successful\")
            hostname = rm.get_hostname(test_ip)
            print(f\"Hostname: {hostname}\")
        else:
            print(\"❌ Connection failed\")
    
    else:
        print(f\"Unknown command: {command}\")