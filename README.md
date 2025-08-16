# DroidCluster

**DroidCluster** is a Docker-based framework designed to orchestrate, manage, and scale both real and emulated Android devices.
It provides a containerized environment where developers and testers can easily set up, control, and automate Android devices without the complexity of manual configuration.

## Features
- Supports real Android devices connected via USB (via `/dev/bus/usb` pass-through).
- Includes an emulator service for development.
- Designed to scale to hundreds of devices in the future.
- YAML-based device definitions for easy customization.

## Getting Started
1. Ensure Docker and Docker Compose are installed.
2. Configure devices in `templates/device_config.yaml`.
3. Start the environment:
   ```sh
   docker compose up -d
   ```
4. Check connected devices:
   ```sh
   scripts/init_devices.sh
   ```

## Directory Structure
```text
DroidCluster/
├── Dockerfile
├── README.md
├── docker-compose.yml
├── scripts/
│   └── init_devices.sh
└── templates/
    └── device_config.yaml
```

## Future Work
- Add load balancing for up to 500 devices.
- Integrate automation frameworks (Appium/UIAutomator).
