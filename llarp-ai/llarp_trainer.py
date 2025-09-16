#!/usr/bin/env python3

import json
import os
import sys
import time
import hashlib
import subprocess
import paramiko
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, asdict
from enum import Enum

# Add paths for our components
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Mock vector store to avoid build dependency
sys.modules['vector_cluster_store_py'] = type('MockModule', (), {
    'Logger': lambda x: None,
    'VectorClusterStore': lambda x: type('MockStore', (), {
        'initialize': lambda *args: False
    })()
})

from workflow_engine import WorkflowEngine

class TestStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    SUCCESS = "success"
    FAILED = "failed"
    ROLLED_BACK = "rolled_back"
    STORED = "stored"

@dataclass
class TestResult:
    test_id: str
    query: str
    status: TestStatus
    execution_time: float
    generated_script: str = ""
    validation_result: Dict = None
    rollback_result: Dict = None
    error_message: str = ""
    ground_truth_score: float = 0.0
    timestamp: datetime = None

    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.now()

class LLARPTrainer:
    """Training system for LLARP using the real router at 15.0.0.1"""

    def __init__(self,
                 router_ip="192.168.100.1",
                 ssh_user="root",
                 ssh_key_path=None,
                 test_queries_file=None):

        if test_queries_file is None:
            script_dir = os.path.dirname(os.path.abspath(__file__))
            test_queries_file = os.path.join(script_dir, "training_queries.json")

        self.router_ip = router_ip
        self.ssh_user = ssh_user
        self.ssh_key_path = ssh_key_path
        self.test_queries_file = test_queries_file

        # Initialize workflow engine with mistral
        self.workflow_engine = WorkflowEngine()
        self.workflow_engine.best_models = {
            "decomposition": "mistral-small3.2:24b",
            "technical_understanding": "mistral-small3.2:24b",
            "execution_planning": "mistral-small3.2:24b",
            "solution_synthesis": "mistral-small3.2:24b"
        }

        # Mock the knowledge bridge
        self.workflow_engine.knowledge_bridge = type('MockBridge', (), {
            'search_knowledge': lambda self, query, k=5: []
        })()

        # Load test queries
        self.test_queries = self._load_test_queries()

        # Results storage
        self.results_file = f"llarp_training_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        self.results = []

        # SSH connection
        self.ssh_client = None

        # Backup state for rollbacks
        self.state_snapshots = {}

    def _load_test_queries(self) -> Dict:
        """Load test queries from JSON file"""
        try:
            with open(self.test_queries_file, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading test queries: {e}")
            return {"llarp_training_scenarios": {}}

    def _connect_ssh(self) -> bool:
        """Establish SSH connection to router"""
        try:
            self.ssh_client = paramiko.SSHClient()
            self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

            if self.ssh_key_path and os.path.exists(self.ssh_key_path):
                self.ssh_client.connect(self.router_ip, username=self.ssh_user,
                                      key_filename=self.ssh_key_path, timeout=10)
            else:
                # Try with no password (assumes key-based auth is set up)
                self.ssh_client.connect(self.router_ip, username=self.ssh_user,
                                      timeout=10, look_for_keys=True)

            print(f"✓ Connected to router at {self.router_ip}")
            return True

        except Exception as e:
            print(f"✗ SSH connection failed: {e}")
            return False

    def _execute_ssh_command(self, command: str, timeout: int = 30) -> Tuple[bool, str, str]:
        """Execute command on router via SSH"""
        try:
            stdin, stdout, stderr = self.ssh_client.exec_command(command, timeout=timeout)
            stdout_data = stdout.read().decode('utf-8').strip()
            stderr_data = stderr.read().decode('utf-8').strip()
            exit_code = stdout.channel.recv_exit_status()

            return exit_code == 0, stdout_data, stderr_data

        except Exception as e:
            return False, "", str(e)

    def _create_state_snapshot(self, test_id: str) -> bool:
        """Create a configuration snapshot before test execution"""
        try:
            print(f"Creating state snapshot for {test_id}...")

            # Backup current UCI configuration
            snapshot_commands = [
                "uci export system > /tmp/backup_system.uci",
                "uci export network > /tmp/backup_network.uci",
                "uci export wireless > /tmp/backup_wireless.uci",
                "uci export firewall > /tmp/backup_firewall.uci",
                "uci export dhcp > /tmp/backup_dhcp.uci",
                "uci export dropbear > /tmp/backup_dropbear.uci"
            ]

            snapshot_data = {}
            for cmd in snapshot_commands:
                success, stdout, stderr = self._execute_ssh_command(cmd)
                if success:
                    # Get the actual backup content
                    config_name = cmd.split()[2].replace('>', '').strip()  # extract config name
                    backup_cmd = f"cat {config_name}"
                    success2, backup_content, _ = self._execute_ssh_command(backup_cmd)
                    if success2:
                        snapshot_data[config_name.split('_')[1].replace('.uci', '')] = backup_content

            self.state_snapshots[test_id] = snapshot_data
            print(f"✓ Snapshot created with {len(snapshot_data)} configs")
            return True

        except Exception as e:
            print(f"✗ Snapshot creation failed: {e}")
            return False

    def _restore_state_snapshot(self, test_id: str) -> bool:
        """Restore configuration from snapshot"""
        try:
            if test_id not in self.state_snapshots:
                print(f"✗ No snapshot found for {test_id}")
                return False

            print(f"Restoring state snapshot for {test_id}...")
            snapshot = self.state_snapshots[test_id]

            for config_name, config_content in snapshot.items():
                # Write backup content to temp file
                temp_file = f"/tmp/restore_{config_name}.uci"
                write_cmd = f"cat > {temp_file} << 'EOF'\n{config_content}\nEOF"

                success, _, stderr = self._execute_ssh_command(write_cmd)
                if success:
                    # Import the configuration
                    import_cmd = f"uci import {config_name} < {temp_file}"
                    success2, _, stderr2 = self._execute_ssh_command(import_cmd)
                    if success2:
                        commit_cmd = f"uci commit {config_name}"
                        self._execute_ssh_command(commit_cmd)
                        print(f"✓ Restored {config_name} config")
                    else:
                        print(f"✗ Failed to import {config_name}: {stderr2}")
                else:
                    print(f"✗ Failed to write {config_name} backup: {stderr}")

            # Restart affected services
            restart_commands = [
                "/etc/init.d/network restart",
                "/etc/init.d/dnsmasq restart",
                "/etc/init.d/firewall restart",
                "/etc/init.d/dropbear restart",
                "wifi"
            ]

            for cmd in restart_commands:
                self._execute_ssh_command(cmd)
                time.sleep(2)  # Allow services to restart

            print(f"✓ State restored for {test_id}")
            return True

        except Exception as e:
            print(f"✗ State restoration failed: {e}")
            return False

    def _validate_test_result(self, test_scenario: Dict) -> Dict:
        """Validate the test result against ground truth"""
        validation_config = test_scenario.get('validation', {})

        if not validation_config:
            return {"status": "no_validation", "score": 0.5}

        check_command = validation_config.get('check_command')
        expected_output = validation_config.get('expected_output')
        expected_contains = validation_config.get('expected_contains')

        if not check_command:
            return {"status": "no_check_command", "score": 0.0}

        try:
            success, stdout, stderr = self._execute_ssh_command(check_command)

            if not success:
                return {
                    "status": "check_failed",
                    "score": 0.0,
                    "error": stderr,
                    "command": check_command
                }

            # Check expected output
            if expected_output:
                if stdout.strip() == expected_output:
                    return {"status": "exact_match", "score": 1.0, "output": stdout}
                else:
                    return {
                        "status": "output_mismatch",
                        "score": 0.2,
                        "expected": expected_output,
                        "actual": stdout
                    }

            # Check contains
            if expected_contains:
                if expected_contains in stdout:
                    return {"status": "contains_match", "score": 0.9, "output": stdout}
                else:
                    return {
                        "status": "contains_mismatch",
                        "score": 0.1,
                        "expected_contains": expected_contains,
                        "actual": stdout
                    }

            return {"status": "command_success", "score": 0.7, "output": stdout}

        except Exception as e:
            return {"status": "validation_error", "score": 0.0, "error": str(e)}

    def _execute_generated_script(self, script_content: str, test_id: str) -> Tuple[bool, str]:
        """Execute the generated script on the router"""
        try:
            # Clean script content and extract just the bash script
            if "```bash" in script_content:
                # Extract script from markdown code block
                start = script_content.find("```bash") + 7
                end = script_content.find("```", start)
                if end != -1:
                    script_content = script_content[start:end].strip()
            elif "```" in script_content:
                # Handle generic code blocks
                start = script_content.find("```") + 3
                end = script_content.find("```", start)
                if end != -1:
                    script_content = script_content[start:end].strip()

            # Remove shebang and comments if present, keep only commands
            lines = script_content.split('\n')
            commands = []
            for line in lines:
                line = line.strip()
                if line and not line.startswith('#') and not line.startswith('echo'):
                    commands.append(line)

            if not commands:
                return False, "No executable commands found in script"

            print(f"Executing {len(commands)} commands for {test_id}:")

            all_outputs = []
            for i, command in enumerate(commands, 1):
                print(f"  {i}. {command}")
                success, stdout, stderr = self._execute_ssh_command(command, timeout=60)

                result_line = f"Command {i}: {'✓' if success else '✗'}"
                if stdout:
                    result_line += f" | Output: {stdout[:50]}"
                if stderr:
                    result_line += f" | Error: {stderr[:50]}"

                all_outputs.append(result_line)

                if not success and "uci" in command:
                    # UCI commands are critical, but continue anyway
                    print(f"    Warning: UCI command failed: {stderr}")

                # Small delay between commands
                time.sleep(1)

            return True, "\n".join(all_outputs)

        except Exception as e:
            return False, f"Script execution error: {e}"

    def run_single_test(self, test_scenario: Dict) -> TestResult:
        """Run a single test scenario"""
        test_id = test_scenario['id']
        query = test_scenario['query']

        print(f"\n{'='*60}")
        print(f"Running test: {test_id}")
        print(f"Query: {query}")
        print(f"{'='*60}")

        start_time = time.time()

        # Create state snapshot
        snapshot_success = self._create_state_snapshot(test_id)
        if not snapshot_success:
            return TestResult(
                test_id=test_id,
                query=query,
                status=TestStatus.FAILED,
                execution_time=time.time() - start_time,
                error_message="Failed to create state snapshot"
            )

        try:
            # Generate solution using workflow engine
            print("Generating solution with Mistral...")
            workflow_result = self.workflow_engine.run_workflow(query)

            if not workflow_result['success']:
                return TestResult(
                    test_id=test_id,
                    query=query,
                    status=TestStatus.FAILED,
                    execution_time=time.time() - start_time,
                    error_message=workflow_result.get('error_message', 'Workflow generation failed')
                )

            # Extract generated script
            execution_results = workflow_result.get('execution_results', {})
            created_scripts = execution_results.get('created_scripts', [])

            if not created_scripts:
                return TestResult(
                    test_id=test_id,
                    query=query,
                    status=TestStatus.FAILED,
                    execution_time=time.time() - start_time,
                    error_message="No script generated by workflow"
                )

            generated_script = created_scripts[0]['content']
            print(f"Generated script ({len(generated_script)} chars)")

            # Execute the script
            print("Executing generated script on router...")
            exec_success, exec_output = self._execute_generated_script(generated_script, test_id)

            if not exec_success:
                # Rollback on execution failure
                self._restore_state_snapshot(test_id)
                return TestResult(
                    test_id=test_id,
                    query=query,
                    status=TestStatus.FAILED,
                    execution_time=time.time() - start_time,
                    generated_script=generated_script,
                    error_message=f"Script execution failed: {exec_output}"
                )

            # Validate result
            print("Validating result...")
            validation_result = self._validate_test_result(test_scenario)
            ground_truth_score = validation_result.get('score', 0.0)

            print(f"Ground truth score: {ground_truth_score:.2f}")
            print(f"Validation: {validation_result}")

            # Determine final status
            if ground_truth_score >= 0.8:
                status = TestStatus.SUCCESS
                print("✅ Test PASSED")
            elif ground_truth_score >= 0.5:
                status = TestStatus.SUCCESS  # Partial success
                print("⚠️ Test PARTIALLY PASSED")
            else:
                status = TestStatus.FAILED
                print("❌ Test FAILED")
                # Rollback on validation failure
                self._restore_state_snapshot(test_id)

            return TestResult(
                test_id=test_id,
                query=query,
                status=status,
                execution_time=time.time() - start_time,
                generated_script=generated_script,
                validation_result=validation_result,
                ground_truth_score=ground_truth_score
            )

        except Exception as e:
            # Rollback on any error
            self._restore_state_snapshot(test_id)
            return TestResult(
                test_id=test_id,
                query=query,
                status=TestStatus.FAILED,
                execution_time=time.time() - start_time,
                error_message=f"Test execution error: {e}"
            )

    def store_successful_lego(self, test_result: TestResult) -> bool:
        """Store successful script as a lego"""
        if test_result.status != TestStatus.SUCCESS or test_result.ground_truth_score < 0.8:
            return False

        try:
            # Create lego filename
            lego_name = f"auto_{test_result.test_id.lower()}_{datetime.now().strftime('%Y%m%d')}.sh"
            lego_path = os.path.join("../llarp-scripts", lego_name)

            # Create lego content with metadata
            lego_content = f"""#!/bin/bash

# Auto-generated LLARP lego script
# Test ID: {test_result.test_id}
# Query: {test_result.query}
# Generated: {test_result.timestamp}
# Ground truth score: {test_result.ground_truth_score:.2f}
# Generation time: {test_result.execution_time:.1f}s

{test_result.generated_script}
"""

            # Write lego file
            with open(lego_path, 'w') as f:
                f.write(lego_content)

            # Make executable
            os.chmod(lego_path, 0o755)

            print(f"✅ Stored lego: {lego_name}")
            return True

        except Exception as e:
            print(f"✗ Failed to store lego: {e}")
            return False

    def run_training_suite(self, categories: List[str] = None, difficulty: str = None) -> Dict:
        """Run the complete training suite"""
        print("🚀 LLARP TRAINING SUITE")
        print("="*60)

        # Connect to router
        if not self._connect_ssh():
            return {"error": "Failed to connect to router"}

        # Get test scenarios
        scenarios = self.test_queries.get('llarp_training_scenarios', {})

        # Filter by categories if specified
        if categories:
            filtered_scenarios = {}
            for cat in categories:
                if cat in scenarios:
                    filtered_scenarios[cat] = scenarios[cat]
            scenarios = filtered_scenarios

        all_tests = []
        for category, tests in scenarios.items():
            for test in tests:
                if difficulty is None or test.get('difficulty') == difficulty:
                    all_tests.append(test)

        print(f"Running {len(all_tests)} tests across {len(scenarios)} categories")

        # Run tests
        successful_tests = 0
        failed_tests = 0
        stored_legos = 0

        for i, test in enumerate(all_tests, 1):
            print(f"\n[{i}/{len(all_tests)}] Starting test {test['id']}")

            result = self.run_single_test(test)
            self.results.append(result)

            if result.status == TestStatus.SUCCESS:
                successful_tests += 1

                # Store as lego if high quality
                if self.store_successful_lego(result):
                    stored_legos += 1
                    result.status = TestStatus.STORED
            else:
                failed_tests += 1

            # Save progress
            self._save_results()

            # Brief pause between tests
            time.sleep(2)

        # Final summary
        summary = {
            "total_tests": len(all_tests),
            "successful": successful_tests,
            "failed": failed_tests,
            "stored_legos": stored_legos,
            "success_rate": successful_tests / len(all_tests) if all_tests else 0,
            "results_file": self.results_file
        }

        print(f"\n{'='*60}")
        print("TRAINING SUITE SUMMARY")
        print(f"{'='*60}")
        print(f"Total tests: {summary['total_tests']}")
        print(f"Successful: {summary['successful']}")
        print(f"Failed: {summary['failed']}")
        print(f"Stored legos: {summary['stored_legos']}")
        print(f"Success rate: {summary['success_rate']:.1%}")
        print(f"Results saved: {summary['results_file']}")

        return summary

    def _save_results(self):
        """Save current results to file"""
        try:
            results_data = {
                "timestamp": datetime.now().isoformat(),
                "router_ip": self.router_ip,
                "total_tests": len(self.results),
                "results": [asdict(r) for r in self.results]
            }

            with open(self.results_file, 'w') as f:
                json.dump(results_data, f, indent=2, default=str)

        except Exception as e:
            print(f"Warning: Failed to save results: {e}")

def main():
    """Main CLI interface"""
    import argparse

    parser = argparse.ArgumentParser(description="LLARP Training System")
    parser.add_argument("--router", default="15.0.0.1", help="Router IP address")
    parser.add_argument("--categories", nargs="+", help="Test categories to run")
    parser.add_argument("--difficulty", choices=["basic", "intermediate", "advanced", "expert"],
                       help="Test difficulty level")
    parser.add_argument("--ssh-key", help="SSH private key path")
    parser.add_argument("--list-tests", action="store_true", help="List available tests")

    args = parser.parse_args()

    trainer = LLARPTrainer(
        router_ip=args.router,
        ssh_key_path=args.ssh_key
    )

    if args.list_tests:
        print("Available test categories:")
        scenarios = trainer.test_queries.get('llarp_training_scenarios', {})
        for category, tests in scenarios.items():
            print(f"\n{category}:")
            for test in tests:
                print(f"  {test['id']}: {test['query']} ({test.get('difficulty', 'unknown')})")
        return

    # Run training suite
    summary = trainer.run_training_suite(
        categories=args.categories,
        difficulty=args.difficulty
    )

    print(f"\n🎉 Training complete! Check {summary['results_file']} for detailed results.")

if __name__ == "__main__":
    main()