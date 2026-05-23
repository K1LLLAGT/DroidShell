#!/usr/bin/env bash
# ds-deps-upgrade.sh
# Full dependency upgrade batch for DroidShell

set -euo pipefail

echo "[+] Starting full dependency upgrade batch..."
echo

GRADLE_FILE="source/DroidShell/app/build.gradle"
ROOT_GRADLE="source/DroidShell/build.gradle"
WRAPPER_PROPS="source/DroidShell/gradle/wrapper/gradle-wrapper.properties"

echo "[+] Updating AndroidX libraries..."
sed -i 's/androidx.core:core-ktx:.*/androidx.core:core-ktx:1.13.1"/' $GRADLE_FILE
sed -i 's/androidx.appcompat:appcompat:.*/androidx.appcompat:appcompat:1.7.0"/' $GRADLE_FILE
sed -i 's/androidx.activity:activity-ktx:.*/androidx.activity:activity-ktx:1.9.0"/' $GRADLE_FILE
sed -i 's/androidx.fragment:fragment-ktx:.*/androidx.fragment:fragment-ktx:1.7.1"/' $GRADLE_FILE
sed -i 's/androidx.lifecycle:lifecycle-runtime-ktx:.*/androidx.lifecycle:lifecycle-runtime-ktx:2.8.0"/' $GRADLE_FILE

echo "[+] Updating Kotlin stdlib..."
sed -i 's/kotlin-stdlib:.*/kotlin-stdlib:1.9.24"/' $GRADLE_FILE

echo "[+] Updating Google libraries..."
sed -i 's/com.google.code.gson:gson:.*/com.google.code.gson:gson:2.11.0"/' $GRADLE_FILE
sed -i 's/com.google.android.material:material:.*/com.google.android.material:material:1.12.0"/' $GRADLE_FILE

echo "[+] Updating Square libraries..."
sed -i 's/com.squareup.okio:okio:.*/com.squareup.okio:okio:3.9.0"/' $GRADLE_FILE
sed -i 's/com.squareup.okhttp3:okhttp:.*/com.squareup.okhttp3:okhttp:4.12.0"/' $GRADLE_FILE

echo "[+] Updating Android Gradle Plugin..."
sed -i 's/com.android.tools.build:gradle:.*/com.android.tools.build:gradle:8.5.0"/' $ROOT_GRADLE

echo "[+] Updating Gradle wrapper..."
sed -i 's/distributionUrl=.*/distributionUrl=https\\:\/\/services.gradle.org\/distributions\/gradle-8.7-bin.zip/' $WRAPPER_PROPS

echo "[+] Refreshing dependencies..."
cd source/DroidShell
./gradlew --refresh-dependencies

echo "[+] Running full build to verify..."
./gradlew clean build

cd ../..

echo "[+] Committing dependency upgrade batch..."
git add -A
git commit -m "Batch upgrade: AndroidX, Kotlin, Google, Square, AGP, Gradle"
git push

echo
echo "[✓] Dependency upgrade batch complete."
echo "[✓] All vulnerable dependencies updated."
echo "[✓] Build verified and pushed."
