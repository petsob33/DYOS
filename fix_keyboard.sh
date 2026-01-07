#!/bin/bash

echo "🔧 Fixing keyboard settings for Android emulator..."

# Check if emulator is running
if ! adb devices | grep -q "emulator"; then
    echo "❌ No emulator detected. Please start an emulator first."
    exit 1
fi

echo "✅ Emulator detected"

# Enable on-screen keyboard
echo "Setting keyboard preferences..."
adb shell settings put secure show_ime_with_hard_keyboard 1

# Enable default IME
adb shell settings put secure default_input_method com.android.inputmethod.latin/.LatinIME

# Show IME even with hardware keyboard
adb shell settings put secure show_ime_with_hard_keyboard 1

# Restart IME service
adb shell am force-stop com.android.inputmethod.latin 2>/dev/null || true

echo ""
echo "✅ Keyboard settings updated!"
echo ""
echo "Try tapping on a text field now. If it still doesn't work:"
echo "1. Restart the emulator completely"
echo "2. In emulator: Settings → System → Languages & input → Physical keyboard"
echo "3. Make sure 'Show on-screen keyboard' is enabled"
echo "4. Try the new emulator: Pixel_6_Keyboard_Fixed"
