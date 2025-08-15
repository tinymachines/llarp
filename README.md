# OpenWRT Configuration Management Toolkit

A comprehensive toolkit for managing OpenWRT routers, including configuration scanning, backup, application, network routing setup, and USB storage management.

## 🚀 Features

- **Configuration Management**: Scan, backup, compare, and apply configurations across multiple OpenWRT routers
- **Network Routing**: Configure inter-router communication and routing between multiple network segments
- **USB Storage**: Set up USB drives for extended storage and package installation
- **Batch Operations**: Manage multiple routers simultaneously
- **Full System Backup**: Complete configuration and system state capture

## 📋 Prerequisites

- OpenWRT routers with SSH access configured
- SSH key authentication set up for root@<router_ip>
- Bash shell on the management system
- Standard Unix tools (ssh, scp, tar, diff)

## 🛠️ Available Scripts

### Configuration Management
- `openwrt-config-scan.sh` - Scan and backup router configuration
- `openwrt-config-apply.sh` - Apply configuration to a router
- `openwrt-batch-scanner.sh` - Scan multiple routers

### Network Routing
- `configure-inter-router-communication.sh` - Set up routing between routers
- `verify-inter-router-communication.sh` - Test network connectivity

### USB Storage
- `setup-usb-storage-zephyr.sh` - Configure USB drive mounting
- `setup-usb-packages-zephyr.sh` - Enable package installation to USB

## 📖 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/openwrt-toolkit.git
cd openwrt-toolkit
```

### 2. Make Scripts Executable
```bash
chmod +x *.sh
```

### 3. Scan a Router Configuration
```bash
./openwrt-config-scan.sh 192.168.1.1
```

### 4. Set Up Network Routing
```bash
./configure-inter-router-communication.sh
```

### 5. Configure USB Storage
```bash
./setup-usb-storage-zephyr.sh
```

## 📚 Documentation

- [Network Routing Setup](docs/network/README.md) - Configure inter-router communication
- [USB Storage Setup](docs/usb-storage/README.md) - Set up USB drives for extended storage
- [Configuration Management](docs/scripts/configuration-management.md) - Backup and restore router configs
- [Troubleshooting Guide](docs/troubleshooting.md) - Common issues and solutions

## 🌐 Example Network Topology

```
[Zephyr Lab: 15.0.0.0/24] ←→ [ATT Gateway: 13.0.0.0/24] ←→ [Spydr: 192.168.1.0/24]
                                        ↓
                                   [Internet]
```

## 🔧 Configuration Files

The toolkit uses standard OpenWRT configuration:
- UCI configuration system
- `/etc/config/*` files
- fstab for USB mounting
- opkg for package management

## 📦 Directory Structure

```
openwrt-toolkit/
├── README.md
├── CLAUDE.md                           # AI assistant instructions
├── docs/                               # Documentation
│   ├── network/                        # Network setup guides
│   ├── usb-storage/                    # USB storage guides
│   └── scripts/                        # Script documentation
├── router_configs/                     # Scanned configurations (generated)
│   └── <hostname>_<ip>_<timestamp>/    # Individual router backups
└── *.sh                               # Executable scripts
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- OpenWRT Project for the excellent router firmware
- Community contributors and testers

## 📮 Support

For issues and questions:
- Open an issue on GitHub
- Check the [Troubleshooting Guide](docs/troubleshooting.md)
- Review the [CLAUDE.md](CLAUDE.md) file for AI-assisted help