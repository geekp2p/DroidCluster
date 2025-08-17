from flask import Flask, jsonify
import os
import subprocess
import adbutils

app = Flask(__name__)


def _adb_devices():
    env = os.environ.copy()
    cmd = ["adb", "devices"]
    proc = subprocess.run(cmd, capture_output=True, text=True, env=env)
    if proc.returncode != 0:
        raise RuntimeError(f"adb failed: {proc.stderr.strip()}")
    return proc.stdout


def _detect_device_serial():
    serial = os.getenv("DEVICE_SERIAL")
    if serial:
        return serial
    try:
        client = adbutils.AdbClient()
        devices = client.device_list()
        if devices:
            return devices[0].serial
    except Exception:
        pass
    return ""


@app.route("/health")
def health():
    try:
        _adb_devices()
        return jsonify({"status": "ok"})
    except Exception as exc:  # pragma: no cover
        return jsonify({"status": "error", "error": str(exc)}), 500


@app.route("/")
def index():
    return jsonify({"device": _detect_device_serial()})


if __name__ == "__main__":
    port = int(os.environ.get("PLAYFLOW_PORT", "5000"))
    app.run(host="0.0.0.0", port=port)