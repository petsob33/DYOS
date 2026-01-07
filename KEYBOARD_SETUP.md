# Keyboard Setup Guide

## Using Physical PC Keyboard in Emulator

Your emulator is now configured to use your physical PC keyboard for typing.

### Current Status
- ✅ Hardware keyboard enabled in emulator config
- ✅ System setting configured to use hardware keyboard
- ✅ Text fields configured to accept input

### How to Use

1. **Start your emulator** (if not already running):
   ```bash
   flutter emulators --launch Pixel_6_Keyboard_Fixed
   ```

2. **Run your app**:
   ```bash
   flutter run
   ```

3. **Type directly**:
   - Click on any text field (email, password, etc.)
   - Start typing with your PC keyboard
   - The virtual keyboard won't appear (this is normal)
   - Your physical keyboard input will work directly

### Troubleshooting

**If typing doesn't work:**

1. **Restart the emulator** (the config change requires a restart):
   ```bash
   # Close the emulator completely
   # Then restart:
   flutter emulators --launch Pixel_6_Keyboard_Fixed
   ```

2. **Re-enable hardware keyboard**:
   ```bash
   bash enable_hardware_keyboard.sh
   ```

3. **Check emulator settings manually**:
   - In emulator: Settings → System → Languages & input
   - Tap "Physical keyboard"
   - Make sure it's enabled/recognized

### Switching Between Virtual and Physical Keyboard

**To use virtual keyboard (on-screen):**
```bash
adb shell settings put secure show_ime_with_hard_keyboard 1
```

**To use physical keyboard (PC keyboard):**
```bash
adb shell settings put secure show_ime_with_hard_keyboard 0
# Or run:
bash enable_hardware_keyboard.sh
```

### Notes

- The virtual keyboard won't appear when hardware keyboard is enabled (this is expected)
- You can still tap on text fields - they will receive focus
- All typing will come from your PC keyboard
- This works for all text fields in the app (login, register, etc.)
