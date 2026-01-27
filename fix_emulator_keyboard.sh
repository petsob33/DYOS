#!/bin/bash

# Script to fix keyboard input in Android emulator
# This enables hardware keyboard input so you can type normally from your physical keyboard

echo "Fixing Android emulator keyboard input..."

# Get list of running emulators
EMULATORS=$(adb devices | grep "emulator" | cut -f1)

if [ -z "$EMULATORS" ]; then
    echo "No running emulators found. Please start an emulator first."
    exit 1
fi

# Enable hardware keyboard for each running emulator
for emulator in $EMULATORS; do
    echo "Fixing keyboard for emulator: $emulator"
    adb -s $emulator shell settings put secure show_ime_with_hard_keyboard 1
    echo "Hardware keyboard enabled for $emulator"
done

echo "Done! You should now be able to type normally from your keyboard."
echo "If the issue persists, try restarting the emulator."
