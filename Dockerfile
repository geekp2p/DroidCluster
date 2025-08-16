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

ENTRYPOINT ["/opt/dcluster/scripts/controller-entrypoint.sh"]