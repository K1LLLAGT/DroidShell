#!/usr/bin/env bash
set -e

echo "[DroidShell] Installing Android SDK + build tools..."

sudo mkdir -p /opt/android
sudo chown -R vscode:vscode /opt/android

cd /opt/android

# Command-line tools
curl -sSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o cmdtools.zip
unzip -q cmdtools.zip
rm cmdtools.zip

export ANDROID_HOME=/opt/android
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools

yes | sdkmanager --licenses

sdkmanager "platform-tools" \
           "platforms;android-34" \
           "build-tools;34.0.0" \
           "cmdline-tools;latest"

echo "[DroidShell] Installing Gradle..."
sudo apt-get update -y
sudo apt-get install -y gradle

echo "[DroidShell] Installing Python + build deps..."
sudo apt-get install -y python3 python3-pip python3-venv

echo "[DroidShell] Installing Android reverse-engineering tools..."
pip3 install apktool androguard

echo "[DroidShell] DevContainer setup complete."
