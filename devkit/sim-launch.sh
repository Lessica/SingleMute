#!/bin/sh

if [ -z "$THEOS_DEVICE_SIMULATOR" ]; then
  exit 0
fi

cd $(dirname $0)/..

DEVICE_ID="C3B345BB-59B0-48DE-8D9C-7D71052162A7"
XCODE_PATH=$(xcode-select -p)

xcrun simctl boot $DEVICE_ID
open $XCODE_PATH/Applications/Simulator.app
