# syntax=docker/dockerfile:1.4
FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    android-tools-adb \
    curl \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY playflow/requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

COPY playflow /app
COPY scripts/bootstrap_emulator.sh /app/bootstrap_emulator.sh
RUN chmod +x /app/bootstrap_emulator.sh

EXPOSE 5000

ENTRYPOINT ["/app/bootstrap_emulator.sh"]