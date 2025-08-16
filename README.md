# DroidCluster

DroidCluster provides a Docker-only environment for controlling real and emulated Android devices. All services run inside containers on a single bridge network and communicate through a central ADB server hosted in the `controller` container.

## Quickstart

```bash
# build and start all services
make up

# show running containers
make ps

# list devices seen by the controller's ADB server
make adb-devices
```

Stop the stack with `make down`.

## Compose Overview

Example `docker-compose.yml`:

```yaml
version: "3.9"
services:
  controller:
    build: .
    environment:
      - ADB_SERVER_SOCKET=tcp:5037
    volumes:
      - /dev/bus/usb:/dev/bus/usb
      - adb_keys:/root/.android
      - ./templates:/opt/dcluster/templates:ro
      - ./scripts:/opt/dcluster/scripts:ro
    healthcheck:
      test: ["CMD-SHELL","adb start-server >/dev/null 2>&1 && adb devices | grep -q 'List of devices'"]
      start_period: 180s
      interval: 15s
      timeout: 10s
      retries: 12

  emulator:
    image: budtmo/docker-android-x86-13.0
    ports:
      - "6080:6080"   # noVNC
      - "5555:5555"   # adbd
    healthcheck:
      test: ["CMD-SHELL","nc -z localhost 5555 && nc -z localhost 6080"]
      start_period: 180s
      interval: 15s
      timeout: 10s
      retries: 12

  playflow:
    build: ./playflow
    depends_on:
      controller:
        condition: service_healthy
    environment:
      - ADB_SERVER_SOCKET=tcp:controller:5037
      - DEVICE_SERIAL=
    volumes:
      - playflow_data:/var/lib/playflow
    ports:
      - "5000:5000"
    healthcheck:
      test: ["CMD-SHELL","curl -fsS http://localhost:5000/health || exit 1"]
      start_period: 180s
      interval: 15s
      timeout: 10s
      retries: 12
```

All services join the `droidnet` bridge network. The controller hosts the ADB server used by the emulator and PlayFlow service.

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

The watcher script inside the controller uses `yq` to read this file and connects to configured emulators while reporting physical devices.

## Ports and Health

- noVNC: http://localhost:6080
- ADB: localhost:5555
- PlayFlow: http://localhost:5000

Health checks (180s start period, 15s interval, 10s timeout, 12 retries):

- Controller: `adb devices` responds
- Emulator: ports 5555 and 6080 respond
- PlayFlow: `curl http://localhost:5000/health` returns 200

## Useful Make Targets

- `make up` / `make down` – start or stop the stack
- `make logs` – follow logs for all services
- `make sh-controller`, `make sh-emulator`, `make sh-playflow` – open a shell
- `make pf-shell` – alias for `sh-playflow`
- `make adb-devices` – run `adb devices` via the controller
- `make adb-killstart` – restart the ADB server in the controller
- `make emu-connect` – force ADB connect to the emulator
- `make pf-logs` – follow only PlayFlow logs
- `make pf-restart` – restart the PlayFlow service
- `make compose-config` – validate compose file
- `make health` – show container health state
- `make clean-volumes` – remove `adb_keys` and `playflow_data` volumes

## Troubleshooting ADB

- **USB device not detected** – ensure the host passes `/dev/bus/usb` into the controller and that `android-udev-rules` are installed.
- **ADB keys rejected** – run `make clean-volumes` to remove the `adb_keys` volume and regenerate keys.
- **Permissions** – check that your user has rights to access the USB device; udev rules may need adjustment.
- **Cannot reach ADB server** – verify `ADB_SERVER_SOCKET=tcp:controller:5037` for clients.

## Acceptance / Test Plan

1. `docker compose up -d --build` – all services become healthy (`make health`).
2. `make adb-devices` shows the configured emulator and any physical devices.
3. `curl http://localhost:5000/health` returns `200`.
4. Plugging or unplugging a device changes the output of `make adb-devices`.
5. noVNC available at `http://localhost:6080` and `adb connect localhost:5555` works.
6. No host-side tools other than Docker and Compose are required.
