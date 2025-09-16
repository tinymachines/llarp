#!/usr/bin/env python3

import sys
import os
import time

# Activate environment first
def activate_environment():
    env_path = os.path.expanduser("~/.pyenv/versions/tinymachines/bin/activate")
    if os.path.exists(env_path):
        print(f"✓ Using tinymachines environment")
    else:
        print(f"⚠ tinymachines environment not found at {env_path}")

activate_environment()

try:
    import paramiko
    print("✓ paramiko imported successfully")
except ImportError as e:
    print(f"✗ Failed to import paramiko: {e}")
    print("Install with: pip install paramiko")
    sys.exit(1)

def test_ssh_connection(router_ip="192.168.100.1", username="root"):
    """Test SSH connection to the LLARP router"""
    print(f"Testing SSH connection to {router_ip}...")

    try:
        # Create SSH client
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        # Try to connect (assumes key-based auth is set up)
        ssh.connect(router_ip, username=username, timeout=10, look_for_keys=True)

        # Run a simple test command
        stdin, stdout, stderr = ssh.exec_command("uname -a", timeout=10)
        output = stdout.read().decode('utf-8').strip()
        error = stderr.read().decode('utf-8').strip()

        if output:
            print(f"✓ SSH connection successful!")
            print(f"Router info: {output}")

            # Test UCI command
            stdin, stdout, stderr = ssh.exec_command("uci get system.@system[0].hostname", timeout=10)
            hostname = stdout.read().decode('utf-8').strip()
            if hostname:
                print(f"✓ UCI working, hostname: {hostname}")
            else:
                print("⚠ UCI command returned empty")

            return True
        else:
            print(f"✗ Command failed: {error}")
            return False

    except paramiko.AuthenticationException:
        print("✗ SSH authentication failed")
        print("Make sure SSH key authentication is set up for root@15.0.0.1")
        return False
    except paramiko.SSHException as e:
        print(f"✗ SSH connection error: {e}")
        return False
    except Exception as e:
        print(f"✗ Connection failed: {e}")
        return False
    finally:
        try:
            ssh.close()
        except:
            pass

def test_ollama_connection():
    """Test ollama connection and mistral model"""
    print("\nTesting ollama connection...")

    try:
        import requests

        # Test ollama API
        response = requests.get("http://127.0.0.1:11434/api/tags", timeout=5)
        response.raise_for_status()

        models = [model["name"] for model in response.json().get("models", [])]
        print(f"✓ Ollama running with {len(models)} models")

        # Check for mistral
        mistral_models = [m for m in models if "mistral" in m.lower()]
        if mistral_models:
            print(f"✓ Found mistral models: {mistral_models}")

            if "mistral-small3.2:24b" in models:
                print("✓ mistral-small3.2:24b is ready")
                return True
            else:
                print("⚠ mistral-small3.2:24b not found")
                print("Install with: ollama pull mistral-small3.2:24b")
                return False
        else:
            print("⚠ No mistral models found")
            return False

    except Exception as e:
        print(f"✗ Ollama connection failed: {e}")
        print("Start ollama with: ollama serve")
        return False

def main():
    """Main test function"""
    print("LLARP Router Connection Test")
    print("=" * 40)

    # Test SSH connection
    ssh_ok = test_ssh_connection()

    # Test ollama
    ollama_ok = test_ollama_connection()

    # Summary
    print(f"\n{'='*40}")
    print("CONNECTION TEST SUMMARY")
    print(f"{'='*40}")
    print(f"SSH to router: {'✓ OK' if ssh_ok else '✗ FAILED'}")
    print(f"Ollama + Mistral: {'✓ OK' if ollama_ok else '✗ FAILED'}")

    if ssh_ok and ollama_ok:
        print("\n🎉 All systems ready for LLARP training!")
        print("You can now run: ./llarp-train list")
        return 0
    else:
        print("\n❌ Please fix the issues above before training")
        if not ssh_ok:
            print("SSH issues:")
            print("  - Check router is accessible at 15.0.0.1")
            print("  - Ensure SSH key auth is configured")
            print("  - Test manually: ssh root@15.0.0.1")
        if not ollama_ok:
            print("Ollama issues:")
            print("  - Start ollama: ollama serve")
            print("  - Install mistral: ollama pull mistral-small3.2:24b")
        return 1

if __name__ == "__main__":
    sys.exit(main())