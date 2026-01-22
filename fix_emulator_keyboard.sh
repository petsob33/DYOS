#!/bin/bash

# Script to fix keyboard input for existing Android emulators
# This enables PC keyboard input in Android emulator

echo "🔧 Fixing keyboard settings for Android emulators..."

# Find all AVD config files
AVD_DIR="$HOME/.android/avd"

if [ ! -d "$AVD_DIR" ]; then
    echo "❌ AVD directory not found: $AVD_DIR"
    echo "   Please create an emulator first using: ./create_emulator.sh"
    exit 1
fi

# Find all config.ini files
CONFIG_FILES=$(find "$AVD_DIR" -name "config.ini" 2>/dev/null)

if [ -z "$CONFIG_FILES" ]; then
    echo "❌ No emulator config files found"
    echo "   Please create an emulator first using: ./create_emulator.sh"
    exit 1
fi

# Fix each emulator
FIXED_COUNT=0
for CONFIG_FILE in $CONFIG_FILES; do
    EMULATOR_NAME=$(basename $(dirname $CONFIG_FILE) .avd)
    echo ""
    echo "📱 Processing emulator: $EMULATOR_NAME"
    
    # Enable hardware keyboard
    if grep -q "hw.keyboard" "$CONFIG_FILE"; then
        sed -i 's/^hw\.keyboard=.*/hw.keyboard=yes/' "$CONFIG_FILE"
        echo "   ✅ Updated hw.keyboard=yes"
    else
        echo "hw.keyboard=yes" >> "$CONFIG_FILE"
        echo "   ✅ Added hw.keyboard=yes"
    fi
    
    # Also ensure keyboard.lid is set (some emulators need this)
    if grep -q "keyboard.lid" "$CONFIG_FILE"; then
        sed -i 's/^keyboard\.lid=.*/keyboard.lid=yes/' "$CONFIG_FILE"
    else
        echo "keyboard.lid=yes" >> "$CONFIG_FILE"
    fi
    
    FIXED_COUNT=$((FIXED_COUNT + 1))
done

echo ""
echo "✅ Fixed $FIXED_COUNT emulator(s)!"
echo ""
echo "📝 To apply changes:"
echo "   1. Close all running emulators"
echo "   2. Restart your emulator:"
echo "      flutter emulators --launch <emulator_name>"
echo ""
echo "   Or list available emulators:"
echo "      flutter emulators"
echo ""
echo "💡 Tip: If keyboard still doesn't work, try:"
echo "   - Settings > System > Languages & input > Physical keyboard"
echo "   - Enable 'Show on-screen keyboard' temporarily, then disable it"
echo "   - Or restart the emulator completely"
