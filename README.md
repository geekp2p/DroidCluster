# DroidCluster

DroidCluster bundles an Android emulator and the [PlayFlow](https://github.com/geekp2p/PlayFlow) UI so that a target device is always available for UI automation.

## Use Emulator

```bash
git clone https://github.com/geekp2p/DroidCluster.git
cd DroidCluster
make up             # or: docker compose up -d
make ps             # show container status
curl http://localhost:5000/health
```

- The PlayFlow UI is served on [http://localhost:5000](http://localhost:5000).
- `adb devices` inside `pf_droidflow` should list an emulator after boot:

```bash
docker compose exec pf_droidflow adb devices
```

If you need a web view of the emulator screen, set `WEB_VNC=true` in `.env` and add a `6080` port mapping in `docker-compose.yml`.

## Use Real Device (Wi‑Fi or USB)

### Wi‑Fi ADB
1. Enable wireless debugging on your phone and put it on the same network as the host.
2. Create a `.env` file containing:
   ```env
   ANDROID_MODE=real
   DEVICE_SERIAL=PHONE_IP:5555
   ```
3. Start PlayFlow:
   ```bash
   docker compose up -d pf_droidflow
   docker compose exec pf_droidflow adb devices
   ```
   The phone should appear as a connected device.

### USB (requires host ADB)
1. Plug the device into the host and authorize ADB access.
2. Expose the host ADB server to the container:
   ```bash
   ANDROID_MODE=real ADB_SERVER_SOCKET=tcp:host.docker.internal:5037 docker compose up -d pf_droidflow
   ```
3. Verify with `docker compose exec pf_droidflow adb devices`.

## Make Targets
- `make up` – start the stack
- `make logs` – tail logs from all services
- `make ps` – show container list
- `make doctor` – quick health summary

## Configuration (.env)
Common knobs:

```env
ANDROID_MODE=emulator      # or: real
EMULATOR_HOST=pf_emulator
EMULATOR_PORT=5555
PLAYFLOW_PORT=5000
# DEVICE_SERIAL=192.168.0.10:5555  # for real device
# WEB_VNC=true                     # enable noVNC on 6080
```