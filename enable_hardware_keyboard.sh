#!/bin/bash

echo "⌨️  Enabling hardware keyboard (PC keyboard) for Android emulator..."

# Check if emulator is running
if ! adb devices | grep -q "emulator"; then
    echo "❌ No emulator detected. Please start an emulator first."
    exit 1
fi

echo "✅ Emulator detected"

# Disable on-screen keyboard when hardware keyboard is present
# This allows you to type directly with your PC keyboard
echo "Configuring keyboard settings..."
adb shell settings put secure show_ime_with_hard_keyboard 0

# Also set in system settings
adb shell setprop qemu.hw.mainkeys 1 2>/dev/null || true

echo ""
echo "✅ Hardware keyboard enabled!"
echo ""
echo "You can now type directly with your PC keyboard in the emulator."
echo ""
echo "Note: If you want to see the virtual keyboard again, run:"
echo "  adb shell settings put secure show_ime_with_hard_keyboard 1"
