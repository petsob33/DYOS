#!/bin/bash

# Script to create a new Android emulator with proper keyboard settings

echo "Creating new Android emulator for Flutter development..."

# Check if system image is available
echo "Checking for available system images..."
# Try API 35 first (most recent), fallback to 33
SYSTEM_IMAGE="system-images;android-35;google_apis_playstore;x86_64"

# Check if it exists, if not try API 33
if ! $HOME/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --list 2>/dev/null | grep -q "$SYSTEM_IMAGE"; then
    SYSTEM_IMAGE="system-images;android-33;google_apis;x86_64"
    if ! $HOME/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --list 2>/dev/null | grep -q "$SYSTEM_IMAGE"; then
        echo "No suitable system image found. Please install one via Android Studio or:"
        echo "  sdkmanager \"system-images;android-35;google_apis_playstore;x86_64\""
        exit 1
    fi
fi

echo "Using system image: $SYSTEM_IMAGE"

# Create the emulator
EMULATOR_NAME="Pixel_6_Keyboard_Fixed"
echo "Creating emulator: $EMULATOR_NAME"

# Create AVD
$HOME/Android/Sdk/cmdline-tools/latest/bin/avdmanager create avd \
    -n "$EMULATOR_NAME" \
    -k "$SYSTEM_IMAGE" \
    -d "pixel_6" \
    --force

# Get the config file path
CONFIG_FILE="$HOME/.android/avd/${EMULATOR_NAME}.avd/config.ini"

if [ -f "$CONFIG_FILE" ]; then
    echo "Configuring emulator settings..."
    
    # Enable hardware keyboard (allows typing with PC keyboard)
    if grep -q "hw.keyboard" "$CONFIG_FILE"; then
        sed -i 's/^hw\.keyboard=.*/hw.keyboard=yes/' "$CONFIG_FILE"
    else
        echo "hw.keyboard=yes" >> "$CONFIG_FILE"
    fi
    
    # Set RAM to 2GB
    if grep -q "hw.ramSize" "$CONFIG_FILE"; then
        sed -i 's/^hw\.ramSize=.*/hw.ramSize=2048/' "$CONFIG_FILE"
    else
        echo "hw.ramSize=2048" >> "$CONFIG_FILE"
    fi
    
    echo "✅ Emulator created and configured!"
    echo ""
    echo "To start the emulator:"
    echo "  flutter emulators --launch $EMULATOR_NAME"
    echo ""
    echo "Or:"
    echo "  flutter run"
else
    echo "❌ Failed to create emulator config file"
    exit 1
fi
