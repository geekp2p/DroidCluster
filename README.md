## First run checklist

1. `make compose-config`
2. `make up`
3. `make health`
4. `make adb-devices`
5. `make emu-open` / `make pf-open`

## Configuration

The stack loads variables from a `.env` file in the project root. See `.env.example` for options such as `DEVICE`, `EMULATOR_PARAMS`, `PLAYFLOW_PORT`, and `DEVICE_SERIAL`.

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
```

- **Emulator**: noVNC `6080`, ADB `5555`
- **PlayFlow**: HTTP `5000`
- **Controller**: no host ports exposed (ADB used internally)

Health checks (180s start period, 15s interval, 10s timeout, 12 retries):

- Controller: `adb devices` responds
- Emulator: ports 5555 and 6080 respond
- PlayFlow: `curl http://localhost:5000/health` returns 200

### Example health output

```bash
$ make health
droid_controller: healthy
droid_emulator: healthy
droid_playflow: healthy
```

Short log snippet:

```text
controller  | [watcher] devices=1
```

For detailed health information, inspect the container directly:

```bash
docker inspect -f '{{.State.Health.Status}}' droid_controller
```

## Profiles usage examples

```bash
# Emulator only
make up --profile emulator

# USB devices + emulator
make up --profile usb --profile emulator

# Enable metrics (cAdvisor)
make up --profile emulator --profile observability
```

## Metrics & cadvisor

When the `observability` profile is enabled, cAdvisor publishes metrics at [http://localhost:8080](http://localhost:8080). Run `make metrics` to print the URL.

## Watcher flags

Set `WATCHER_VERBOSE=1` for verbose watcher logs and `WATCHER_METRICS=1` to emit JSON metrics to stdout.

## Useful Make Targets

- `make up` / `make down` – start or stop the stack
- `make logs` – follow logs for all services
- `make logs-controller` / `make logs-emulator` / `make logs-playflow` – follow logs for a single service
- `make sh-controller`, `make ctrl-shell` – open a shell in the controller
- `make sh-emulator` – open a shell in the emulator
- `make sh-playflow`, `make pf-shell` – open a shell in the PlayFlow container
- `make emu-shell` – alias for opening a shell in the emulator
- `make emu-open` – print the noVNC URL
- `make pf-open` – print the PlayFlow URL
- `make pf-build-cache` – build PlayFlow using local cache
- `make metrics` – print the cAdvisor URL
- `make adb-devices` – run `adb devices` via the controller
- `make adb-killstart` – restart the ADB server in the controller
- `make emu-connect` – force ADB connect to the emulator
- `make pf-logs` – follow only PlayFlow logs
- `make pf-restart` – restart the PlayFlow service
- `make compose-config` – validate compose file
- `make health` – show container health state
- `make clean-volumes` – remove `adb_keys` and `playflow_data` volumes
- `make rebuild` – stop containers and rebuild the stack
- `make clean` – remove containers, images, and volumes
- `make restart` – restart all services
- `make doctor` – check for required Docker components
- `make status` – show health status and exposed ports

## Troubleshooting USB

- Use `dmesg` to inspect kernel messages when plugging in a device.
- `lsusb` lists detected USB devices on the host.
- `adb devices` verifies the controller can see the hardware.
- `udevadm monitor` streams real-time udev events.
- `scripts/setup-usb.sh --dry-run` shows rules before installing.

## Troubleshooting ADB

- **USB device not detected** – ensure the host passes `/dev/bus/usb` into the controller and that `android-udev-rules` are installed.
- **ADB keys rejected** – run `make clean-volumes` to remove the `adb_keys` volume and regenerate keys.
- **Permissions** – check that your user has rights to access the USB device; udev rules may need adjustment.
- **Cannot reach ADB server** – verify `ADB_SERVER_SOCKET=tcp:controller:5037` for clients.

## Acceptance / Test Plan

1. `make onboard` completes (Docker Engine and Compose installed).
2. `make up --profile emulator` → containers become healthy (`make health`), `make pf-open` and `make emu-open` work.
3. `make up --profile usb --profile emulator` on Linux → physical devices appear in `make adb-devices`.
4. `make up --profile observability` → cAdvisor accessible at `http://localhost:8080`.
5. Watcher logs show structured output when `WATCHER_VERBOSE=1` and metrics when `WATCHER_METRICS=1`.
6. CI workflow runs lint, compose validation, and builds the PlayFlow image without errors.