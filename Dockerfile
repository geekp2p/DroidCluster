FROM ubuntu:22.04

RUN apt-get update && apt-get install -y         android-tools-adb         openjdk-11-jdk         wget unzip &&         rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/opt/android-sdk
RUN mkdir -p $ANDROID_HOME

# Placeholder for additional SDK or emulator setup
CMD ["bash"]
