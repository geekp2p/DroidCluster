# DroidCluster

**DroidCluster** provides a Docker-only environment for controlling real and emulated Android devices.  All services run inside containers on a single bridge network and communicate through a central ADB server hosted in the `controller` container.

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

## Services

| Service     | Ports        | Purpose                                         |
|-------------|--------------|-------------------------------------------------|
| controller  | –            | Central ADB server and device watcher           |
| emulator    | 6080 (VNC)   | Android emulator with `adbd` on TCP 5555        |
| playflow    | 5000         | Simple web UI using the controller's ADB server |

All services are attached to the same bridge network `droidnet`.  Two named volumes are used:

- `adb_keys` – stores adb keypairs for reconnecting devices
- `playflow_data` – persistent data for the PlayFlow service

## Device Configuration

Devices are declared in `templates/device_config.yaml`.

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

## Health Checks

- Controller: `adb devices` responds (used by Docker healthcheck)
- Emulator: TCP port 5555 and noVNC on 6080
- PlayFlow: `curl http://localhost:5000/health` returns HTTP 200

## Troubleshooting

- **USB device not detected** – ensure the host passes `/dev/bus/usb` into the controller and that `android-udev-rules` are installed.
- **ADB cannot connect** – verify the controller container is healthy and that `ADB_SERVER_SOCKET` is set to `tcp:controller:5037` for clients.
- **PlayFlow not responding** – check logs with `make pf-logs` and restart using `make pf-restart`.