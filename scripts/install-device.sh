#!/bin/sh
set -euo pipefail
# Signed install onto the paired physical iPhone (iPhone s / 13 mini).
cd "$(dirname "$0")/.."
APP="DerivedDataDevice/Build/Products/Debug-iphoneos/PurrfectFrame.app"
DEVICE="${1:-24FD2D6E-6EE2-59CE-90EC-39B48B6FF171}"

if [[ ! -d "$APP" ]]; then
  xcodebuild -project PurrfectFrame.xcodeproj \
    -scheme PurrfectFrame \
    -configuration Debug \
    -destination 'generic/platform=iOS' \
    -derivedDataPath DerivedDataDevice \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=XMS5ZC28UJ \
    build
fi

xcrun devicectl device install app --timeout 180 --device "$DEVICE" "$APP"
xcrun devicectl device process launch --device "$DEVICE" com.sergiiziborov.purrfectframe
