app = Flask(__name__)


def _adb_devices():
    env = os.environ.copy()
    cmd = ["adb", "devices"]
    proc = subprocess.run(cmd, capture_output=True, text=True, env=env)
    return proc.stdout


@app.route("/health")
def health():
    try:
        _adb_devices()
        return jsonify({"status": "ok"})
    except Exception as exc:  # pragma: no cover
        return jsonify({"status": "error", "error": str(exc)}), 500


@app.route("/")
def index():
    return jsonify({"device": os.getenv("DEVICE_SERIAL", "")})


if __name__ == "__main__":
    port = int(os.environ.get("PLAYFLOW_PORT", "5000"))
    app.run(host="0.0.0.0", port=port)