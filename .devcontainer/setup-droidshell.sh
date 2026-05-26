#!/usr/bin/env bash
set -e

echo "[DroidShell] Installing Android SDK + build tools..."

sudo mkdir -p /opt/android
sudo chown -R vscode:vscode /opt/android

export ANDROID_HOME=/opt/android
export ANDROID_SDK_ROOT=/opt/android
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

cd /opt/android

# ------------------------------------------------------------
# Install Android command-line tools (correct folder structure)
# ------------------------------------------------------------
curl -sSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o cmdtools.zip
mkdir -p cmdline-tools/latest
unzip -q cmdtools.zip -d cmdline-tools/latest
rm cmdtools.zip

# ------------------------------------------------------------
# Accept licenses + install SDK components
# ------------------------------------------------------------
yes | sdkmanager --licenses

sdkmanager \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  "cmdline-tools;latest"

echo "[DroidShell] Installing Gradle..."
sudo apt-get update -y
sudo apt-get install -y gradle

echo "[DroidShell] Installing Python + build deps..."
sudo apt-get install -y python3 python3-pip python3-venv

echo "[DroidShell] Installing Android reverse-engineering tools..."
pip3 install androguard

# apktool installation (correct method)
curl -sSL https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -o /usr/local/bin/apktool
chmod +x /usr/local/bin/apktool

curl -sSL https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar -o /usr/local/bin/apktool.jar
chmod +x /usr/local/bin/apktool.jar

echo "[DroidShell] Installing package manager environment..."

pip3 install networkx rich fastapi uvicorn

mkdir -p /opt/ds-pkg
cp -r scripts/pkg/* /opt/ds-pkg/

echo 'export PATH=$PATH:/opt/ds-pkg' >> /home/vscode/.bashrc

echo "[DroidShell] DevContainer setup complete."
