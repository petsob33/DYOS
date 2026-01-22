#!/bin/bash

# Script to launch Android emulator with keyboard support enabled
# This ensures keyboard input works even if config.ini doesn't have it set

echo "🚀 Launching Android emulator with keyboard support..."

# Check if emulator name is provided
if [ -z "$1" ]; then
    echo "Available emulators:"
    flutter emulators
    echo ""
    echo "Usage: $0 <emulator_name>"
    echo "Example: $0 Pixel_6_Keyboard_Fixed"
    exit 1
fi

EMULATOR_NAME="$1"

# Check if emulator exists
if ! flutter emulators | grep -q "$EMULATOR_NAME"; then
    echo "❌ Emulator '$EMULATOR_NAME' not found"
    echo ""
    echo "Available emulators:"
    flutter emulators
    exit 1
fi

# Get the AVD path
AVD_DIR="$HOME/.android/avd"
CONFIG_FILE="$AVD_DIR/${EMULATOR_NAME}.avd/config.ini"

# Ensure keyboard is enabled in config
if [ -f "$CONFIG_FILE" ]; then
    if grep -q "hw.keyboard" "$CONFIG_FILE"; then
        sed -i 's/^hw\.keyboard=.*/hw.keyboard=yes/' "$CONFIG_FILE"
    else
        echo "hw.keyboard=yes" >> "$CONFIG_FILE"
    fi
    
    if ! grep -q "keyboard.lid" "$CONFIG_FILE"; then
        echo "keyboard.lid=yes" >> "$CONFIG_FILE"
    fi
fi

# Launch emulator with explicit keyboard parameter
echo "Launching $EMULATOR_NAME..."
flutter emulators --launch "$EMULATOR_NAME"

echo ""
echo "✅ Emulator launched!"
echo "💡 If keyboard doesn't work:"
echo "   - Wait for emulator to fully boot"
echo "   - Try clicking in a text field"
echo "   - Check Settings > System > Languages & input > Physical keyboard"
