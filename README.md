# DroidCluster

## Quick start (PlayFlow-style, Emulator API 33)
```bash
git clone https://github.com/geekp2p/DroidCluster.git
cd DroidCluster
docker compose up -d
make health
make emu-open     # http://localhost:6080
make pf-open      # http://localhost:5000
```

## Configuration (.env)
Use the `.env` file to adjust `DEVICE`, `EMULATOR_PARAMS`, `PLAYFLOW_PORT`, `NOVNC_PORT`, and `DEVICE_SERIAL` (leave empty for auto-detect).

## Services
- **pf_emulator**: noVNC `6080` (ADB `5555` exposed only inside the Docker network).
- **pf_droidflow**: HTTP `5000` (runs an ADB server and `adb connect pf_emulator:5555`).

### Health output example
```bash
$ make health
pf_emulator: healthy
pf_droidflow: healthy
```

## Troubleshooting
- Port already in use → change `PLAYFLOW_PORT` or `NOVNC_PORT` in `.env`.
- Healthcheck failing → `docker compose logs -f`.
- ADB cannot find emulator → check `pf_droidflow` logs (it will `adb connect pf_emulator:5555` on start).