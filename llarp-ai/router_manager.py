#!/usr/bin/env python3
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
            )\n            \n            execution_time = time.time() - start_time\n            \n            # Prepare result\n            cmd_result = {\n                \"command\": command,\n                \"router_ip\": router_ip,\n                \"timestamp\": datetime.now().isoformat(),\n                \"execution_time\": execution_time,\n                \"returncode\": result.returncode,\n                \"stdout\": result.stdout,\n                \"stderr\": result.stderr,\n                \"success\": result.returncode == 0\n            }\n            \n            # Log command execution\n            self.log_command_execution(cmd_result)\n            \n            return cmd_result\n            \n        except subprocess.TimeoutExpired:\n            return {\n                \"command\": command,\n                \"router_ip\": router_ip,\n                \"timestamp\": datetime.now().isoformat(),\n                \"error\": \"Command timeout\",\n                \"success\": False\n            }\n        except Exception as e:\n            return {\n                \"command\": command,\n                \"router_ip\": router_ip,\n                \"timestamp\": datetime.now().isoformat(),\n                \"error\": str(e),\n                \"success\": False\n            }\n    \n    def log_command_execution(self, result: Dict[str, Any]):\n        \"\"\"Log command execution for session tracking\"\"\"\n        router_ip = result[\"router_ip\"]\n        \n        if router_ip not in self.sessions:\n            self.sessions[router_ip] = {\n                \"commands\": [],\n                \"session_start\": datetime.now().isoformat(),\n                \"last_activity\": datetime.now().isoformat()\n            }\n        \n        # Add command to session\n        self.sessions[router_ip][\"commands\"].append({\n            \"timestamp\": result[\"timestamp\"],\n            \"command\": result[\"command\"],\n            \"success\": result[\"success\"],\n            \"execution_time\": result.get(\"execution_time\", 0)\n        })\n        \n        # Update last activity\n        self.sessions[router_ip][\"last_activity\"] = datetime.now().isoformat()\n        \n        # Keep only last 100 commands per router\n        if len(self.sessions[router_ip][\"commands\"]) > 100:\n            self.sessions[router_ip][\"commands\"] = self.sessions[router_ip][\"commands\"][-100:]\n        \n        self.save_sessions()\n    \n    # OpenWRT-specific command wrappers\n    def uci_get(self, router_ip: str, config_path: str) -> Dict[str, Any]:\n        \"\"\"Get UCI configuration value\"\"\"\n        command = f\"uci get {config_path}\"\n        return self.execute_command(router_ip, command)\n    \n    def uci_set(self, router_ip: str, config_path: str, value: str) -> Dict[str, Any]:\n        \"\"\"Set UCI configuration value\"\"\"\n        command = f\"uci set {config_path}='{value}'\"\n        return self.execute_command(router_ip, command)\n    \n    def uci_commit(self, router_ip: str, config: str = \"\") -> Dict[str, Any]:\n        \"\"\"Commit UCI changes\"\"\"\n        command = f\"uci commit {config}\".strip()\n        return self.execute_command(router_ip, command)\n    \n    def uci_show(self, router_ip: str, config: str = \"\") -> Dict[str, Any]:\n        \"\"\"Show UCI configuration\"\"\"\n        command = f\"uci show {config}\".strip()\n        return self.execute_command(router_ip, command)\n    \n    def opkg_list(self, router_ip: str, pattern: str = \"\") -> Dict[str, Any]:\n        \"\"\"List installed packages\"\"\"\n        command = f\"opkg list-installed {pattern}\".strip()\n        return self.execute_command(router_ip, command)\n    \n    def opkg_install(self, router_ip: str, package: str) -> Dict[str, Any]:\n        \"\"\"Install package\"\"\"\n        command = f\"opkg install {package}\"\n        return self.execute_command(router_ip, command, timeout=120)  # Longer timeout for installs\n    \n    def opkg_remove(self, router_ip: str, package: str) -> Dict[str, Any]:\n        \"\"\"Remove package\"\"\"\n        command = f\"opkg remove {package}\"\n        return self.execute_command(router_ip, command)\n    \n    def opkg_update(self, router_ip: str) -> Dict[str, Any]:\n        \"\"\"Update package lists\"\"\"\n        command = \"opkg update\"\n        return self.execute_command(router_ip, command, timeout=120)\n    \n    def get_system_info(self, router_ip: str) -> Dict[str, Any]:\n        \"\"\"Get comprehensive system information\"\"\"\n        commands = {\n            \"hostname\": \"uci get system.@system[0].hostname\",\n            \"uptime\": \"uptime\",\n            \"memory\": \"cat /proc/meminfo\",\n            \"cpuinfo\": \"cat /proc/cpuinfo\",\n            \"version\": \"cat /etc/openwrt_release\",\n            \"kernel\": \"uname -a\",\n            \"load\": \"cat /proc/loadavg\",\n            \"disk_usage\": \"df -h\",\n            \"network_interfaces\": \"ip addr show\",\n            \"wireless_info\": \"iw dev\",\n            \"running_processes\": \"ps aux\",\n            \"routing_table\": \"ip route show\",\n            \"firewall_rules\": \"iptables -L -n\"\n        }\n        \n        results = {}\n        for key, command in commands.items():\n            try:\n                result = self.execute_command(router_ip, command)\n                results[key] = result\n                time.sleep(0.1)  # Small delay between commands\n            except Exception as e:\n                results[key] = {\"error\": str(e), \"success\": False}\n        \n        return results\n    \n    def get_log_data(self, router_ip: str, lines: int = 100) -> Dict[str, Any]:\n        \"\"\"Get system logs\"\"\"\n        commands = {\n            \"system_log\": f\"logread -l {lines}\",\n            \"kernel_log\": f\"dmesg | tail -n {lines}\",\n            \"wifi_log\": \"logread | grep -i wifi | tail -n 50\",\n            \"network_log\": \"logread | grep -i network | tail -n 50\"\n        }\n        \n        results = {}\n        for key, command in commands.items():\n            try:\n                result = self.execute_command(router_ip, command)\n                results[key] = result\n            except Exception as e:\n                results[key] = {\"error\": str(e), \"success\": False}\n        \n        return results\n    \n    def restart_service(self, router_ip: str, service: str) -> Dict[str, Any]:\n        \"\"\"Restart a service\"\"\"\n        command = f\"/etc/init.d/{service} restart\"\n        return self.execute_command(router_ip, command)\n    \n    def reboot_router(self, router_ip: str) -> Dict[str, Any]:\n        \"\"\"Reboot the router\"\"\"\n        command = \"reboot\"\n        return self.execute_command(router_ip, command)\n    \n    def get_router_status(self, router_ip: str) -> Dict[str, Any]:\n        \"\"\"Get quick router status\"\"\"\n        try:\n            result = self.execute_command(router_ip, \"echo 'Router is responsive'\", timeout=10)\n            \n            if result[\"success\"]:\n                hostname = self.get_hostname(router_ip)\n                uptime_result = self.execute_command(router_ip, \"uptime\")\n                \n                return {\n                    \"router_ip\": router_ip,\n                    \"hostname\": hostname,\n                    \"status\": \"online\",\n                    \"uptime\": uptime_result.get(\"stdout\", \"\").strip(),\n                    \"last_check\": datetime.now().isoformat(),\n                    \"response_time\": result.get(\"execution_time\", 0)\n                }\n            else:\n                return {\n                    \"router_ip\": router_ip,\n                    \"status\": \"offline\",\n                    \"error\": result.get(\"error\", \"Connection failed\"),\n                    \"last_check\": datetime.now().isoformat()\n                }\n        \n        except Exception as e:\n            return {\n                \"router_ip\": router_ip,\n                \"status\": \"error\",\n                \"error\": str(e),\n                \"last_check\": datetime.now().isoformat()\n            }\n    \n    def get_session_history(self, router_ip: str, limit: int = 20) -> List[Dict]:\n        \"\"\"Get command history for a router\"\"\"\n        if router_ip in self.sessions:\n            commands = self.sessions[router_ip].get(\"commands\", [])\n            return commands[-limit:] if limit else commands\n        return []\n    \n    def cleanup_old_sessions(self, days: int = 7):\n        \"\"\"Remove session data older than specified days\"\"\"\n        cutoff_date = datetime.now() - timedelta(days=days)\n        \n        for router_ip in list(self.sessions.keys()):\n            session = self.sessions[router_ip]\n            last_activity = datetime.fromisoformat(session.get(\"last_activity\", \"\"))\n            \n            if last_activity < cutoff_date:\n                del self.sessions[router_ip]\n                logger.info(f\"Cleaned up old session for {router_ip}\")\n        \n        self.save_sessions()

# Example usage and testing\nif __name__ == \"__main__\":\n    import sys\n    \n    rm = RouterManager()\n    \n    if len(sys.argv) < 2:\n        print(\"Usage: python router_manager.py <command> [args...]\")\n        print(\"Commands: status, info, uci-get, uci-set, logs, test\")\n        sys.exit(1)\n    \n    command = sys.argv[1]\n    router_ip = rm.get_target_router()\n    \n    if not router_ip and command != \"test\":\n        print(\"No target router set. Use llarp-cli to set one first.\")\n        sys.exit(1)\n    \n    if command == \"status\":\n        status = rm.get_router_status(router_ip)\n        print(json.dumps(status, indent=2))\n    \n    elif command == \"info\":\n        info = rm.get_system_info(router_ip)\n        print(json.dumps(info, indent=2))\n    \n    elif command == \"uci-get\" and len(sys.argv) > 2:\n        result = rm.uci_get(router_ip, sys.argv[2])\n        print(f\"Value: {result.get('stdout', 'Error').strip()}\")\n    \n    elif command == \"logs\":\n        logs = rm.get_log_data(router_ip)\n        for log_type, result in logs.items():\n            print(f\"\\n=== {log_type.upper()} ===\")\n            if result.get(\"success\"):\n                print(result[\"stdout\"])\n            else:\n                print(f\"Error: {result.get('error', 'Unknown error')}\")\n    \n    elif command == \"test\":\n        test_ip = sys.argv[2] if len(sys.argv) > 2 else \"192.168.1.1\"\n        print(f\"Testing connection to {test_ip}...\")\n        if rm.test_connection(test_ip):\n            print(\"✅ Connection successful\")\n            hostname = rm.get_hostname(test_ip)\n            print(f\"Hostname: {hostname}\")\n        else:\n            print(\"❌ Connection failed\")\n    \n    else:\n        print(f\"Unknown command: {command}\")