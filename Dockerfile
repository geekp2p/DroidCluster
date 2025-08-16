FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    android-tools-adb \
    openjdk-11-jdk \
    wget unzip \
    yq \
    android-udev-rules \
    udev \
    curl \
    netcat-openbsd \
    jq \
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/opt/android-sdk
RUN mkdir -p $ANDROID_HOME

WORKDIR /opt/dcluster

COPY scripts/ /opt/dcluster/scripts/
COPY templates/ /opt/dcluster/templates/
RUN chmod +x /opt/dcluster/scripts/*.sh

HEALTHCHECK --interval=15s --timeout=10s --start-period=180s --retries=12 CMD adb start-server >/dev/null 2>&1 && adb devices | grep -q 'List of devices'

ENTRYPOINT ["/opt/dcluster/scripts/controller-entrypoint.sh"]