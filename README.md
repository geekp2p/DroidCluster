# DroidCluster

**DroidCluster** provides a Docker-only environment for controlling real and emulated Android devices. All services run inside containers on a single bridge network and communicate through a central ADB server hosted in the `controller` container.

## Quickstart

```bash
# build and start all services
make up

# show running containers
make ps

# list devices seen by the controller's ADB server
make adb-devices
```

To stop the stack use `make down`.

## Compose Overview

A minimal `docker-compose.yml` looks like:

```yaml
version: "3.9"
services:
  controller:
    build: .
  emulator:
    image: budtmo/docker-android-x86-13.0
  playflow:
    build: ./playflow
```

All services join the `droidnet` bridge network. The controller exposes the ADB server used by the emulator and PlayFlow service.

## Device Configuration

Devices are declared in `templates/device_config.yaml`:

```yaml
devices:
  - name: real_device_1
    type: physical
    serial: usb
  - name: emulator_1
    type: emulator
    host: droid_emulator
    port: 5555
```

The watcher script inside the controller uses `yq` to read this file and will automatically connect to listed emulators while also reporting physical devices.

## Useful Make Targets

- `make up` / `make down` – start or stop the stack
- `make logs` – follow logs for all services
- `make sh-controller`, `make sh-emulator`, `make sh-playflow` – open a shell
- `make adb-devices` – run `adb devices` via the controller
- `make emu-connect` – force ADB connect to the emulator
- `make pf-logs` – follow only PlayFlow logs
- `make pf-restart` – restart the PlayFlow service
- `make compose-config` – validate compose file
- `make health` – show container health state

## Health Checks

- Controller: `adb devices` responds (Docker healthcheck)
- Emulator: TCP ports 5555 and 6080 respond
- PlayFlow: `curl http://localhost:5000/health` returns HTTP 200

## Troubleshooting ADB

- **USB device not detected** – ensure the host passes `/dev/bus/usb` into the controller and that `android-udev-rules` are installed.
- **ADB keys rejected** – remove the `adb_keys` volume to regenerate keys, then reconnect the device.
- **Permissions** – check that your user has rights to access the USB device; udev rules may need adjustment.
- **Cannot reach ADB server** – verify `ADB_SERVER_SOCKET=tcp:controller:5037` for clients.

## Acceptance / Test Plan

1. `docker compose up -d --build` – all services become healthy (`make health`).
2. `make adb-devices` shows the configured emulator and any physical devices.
3. `curl http://localhost:5000/health` returns `200`.
4. Plugging or unplugging a device changes the output of `make adb-devices`.
5. No host-side tools other than Docker and Compose are required.