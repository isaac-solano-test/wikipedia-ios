#!/bin/bash

set -o errexit -o pipefail

SIMULATOR_ID=$(xcrun instruments -s | grep -o "iPhone 6 (${IOS_VER}) \[.*\]" | grep -o "\[.*\]" | sed "s/^\[\(.*\)\]$/\1/")
echo $SIMULATOR_ID
open -b com.apple.iphonesimulator --args -CurrentDeviceUDID $SIMULATOR_ID
set -o pipefail
bundle exec fastlane $FL_ARGS

