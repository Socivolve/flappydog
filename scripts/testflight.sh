#!/bin/sh
# Archives Flappy Dog and uploads it to App Store Connect for TestFlight.
# Needs a paid Apple Developer Program team, signed in to Xcode (Settings > Accounts).
#   TEAM_ID=ABCDE12345 scripts/testflight.sh
set -eu
cd "$(dirname "$0")/.."
: "${TEAM_ID:?Set TEAM_ID to your Apple Developer team ID (developer.apple.com > Membership)}"

ARCHIVE=build/FlappyDog.xcarchive
xcodebuild archive \
  -project FlappyDog.xcodeproj -scheme FlappyDog \
  -destination 'generic/platform=iOS' -archivePath "$ARCHIVE" \
  DEVELOPMENT_TEAM="$TEAM_ID" -allowProvisioningUpdates

# Signs for distribution, bumps the build number and uploads in one step.
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" -exportPath build/export \
  -exportOptionsPlist scripts/ExportOptions.plist \
  DEVELOPMENT_TEAM="$TEAM_ID" -allowProvisioningUpdates

echo "Uploaded. The build shows up in App Store Connect > TestFlight after processing (about 10–30 min)."
