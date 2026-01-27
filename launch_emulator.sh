#!/bin/bash

# Script to launch Android emulator and fix keyboard input

echo "Launching Android emulator..."

# Check if emulator is already running
RUNNING=$(adb devices | grep "emulator" | wc -l)
if [ "$RUNNING" -gt 0 ]; then
    echo "Emulator is already running. Fixing keyboard..."
    ./fix_emulator_keyboard.sh
    exit 0
fi

# Get list of available emulators
# Try to get emulator IDs from flutter emulators output
EMULATOR_LIST=$(flutter emulators 2>/dev/null | tail -n +4 | awk '{print $1}' | grep -v "^$")

if [ -z "$EMULATOR_LIST" ]; then
    echo "No emulators found. Please create an emulator first."
    exit 1
fi

# Use first available emulator or the one specified as argument
EMULATOR_ID=${1:-$(echo "$EMULATOR_LIST" | head -n1)}

if [ -z "$EMULATOR_ID" ]; then
    echo "Could not determine emulator ID. Available emulators:"
    echo "$EMULATOR_LIST"
    exit 1
fi

echo "Launching emulator: $EMULATOR_ID"
flutter emulators --launch "$EMULATOR_ID" &

# Wait for emulator to boot
echo "Waiting for emulator to boot..."
sleep 5

# Wait until emulator is fully booted (checking for boot_completed)
MAX_WAIT=120
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    BOOT_COMPLETE=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    if [ "$BOOT_COMPLETE" = "1" ]; then
        echo "Emulator is ready!"
        break
    fi
    sleep 2
    WAITED=$((WAITED + 2))
    echo -n "."
done

echo ""

# Fix keyboard
echo "Fixing keyboard input..."
./fix_emulator_keyboard.sh

echo "Emulator is ready to use with keyboard input fixed!"
