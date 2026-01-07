# Android Emulator Setup Guide

## Option 1: Create a New Android Emulator via Android Studio

### Steps:
1. **Open Android Studio**
2. **Open AVD Manager**:
   - Click on "More Actions" → "Virtual Device Manager"
   - Or go to Tools → Device Manager
3. **Create New Device**:
   - Click "Create Device"
   - Choose a device definition (e.g., Pixel 6, Pixel 7)
   - Click "Next"
4. **Select System Image**:
   - Choose a recent API level (API 33 or 34 recommended)
   - Make sure to download if not already downloaded
   - Click "Next"
5. **Configure AVD**:
   - **Name**: Give it a name (e.g., "Pixel_6_API_34")
   - **Graphics**: Choose "Hardware - GLES 2.0" or "Automatic"
   - **Important**: Click "Show Advanced Settings"
   - **Keyboard**: Make sure "Hardware keyboard present" is **UNCHECKED**
   - This ensures the on-screen keyboard appears
   - Click "Finish"

### Key Settings for Keyboard:
- **Uncheck "Hardware keyboard present"** - This is crucial!
- This forces the emulator to show the on-screen keyboard

## Option 2: Create Emulator via Command Line

### Using avdmanager:
```bash
# List available system images
sdkmanager --list | grep system-images

# Install a system image (if not already installed)
sdkmanager "system-images;android-34;google_apis;x86_64"

# Create AVD
avdmanager create avd -n Pixel_6_API_34 -k "system-images;android-34;google_apis;x86_64" -d "pixel_6"

# Edit the config to disable hardware keyboard
# Edit: ~/.android/avd/Pixel_6_API_34.avd/config.ini
# Set: hw.keyboard = no
```

## Option 3: Use Physical Device

### Connect Physical Android Device:
1. **Enable Developer Options** on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. **Enable USB Debugging**:
   - Settings → Developer Options → USB Debugging (enable)
3. **Connect via USB**:
   ```bash
   # Check if device is detected
   flutter devices
   
   # Run on device
   flutter run -d <device-id>
   ```

## Option 4: Use Genymotion (Alternative Emulator)

Genymotion is a popular alternative Android emulator:
1. Download from: https://www.genymotion.com/
2. Install and create a virtual device
3. Genymotion typically has better keyboard support out of the box

## Option 5: Use Chrome OS Emulator (Web-based)

For quick testing, you can also test on web:
```bash
flutter run -d chrome
```

## Quick Fix for Current Emulator

Before creating a new one, try these commands:

```bash
# Enable on-screen keyboard in current emulator
adb shell settings put secure show_ime_with_hard_keyboard 1

# Restart the emulator
adb reboot
```

Or manually in emulator:
1. Open Settings app in emulator
2. Go to System → Languages & input
3. Tap "Physical keyboard"
4. Toggle OFF "Show on-screen keyboard" (wait, this might be backwards)
5. Actually, make sure "Show on-screen keyboard" is ON when hardware keyboard is connected

## Recommended Emulator Configuration

For best results with Flutter apps:

- **Device**: Pixel 6 or Pixel 7
- **API Level**: 33 or 34 (Android 13/14)
- **Graphics**: Hardware acceleration enabled
- **RAM**: 2GB minimum (4GB recommended)
- **Hardware Keyboard**: **DISABLED** (unchecked)
- **Storage**: 2GB minimum

## Verify Emulator Setup

After creating the emulator:

```bash
# List all available devices
flutter devices

# Run your app
flutter run

# Or specify the device
flutter run -d <emulator-name>
```

## Troubleshooting

### Keyboard still not showing?
1. Make sure hardware keyboard is disabled in AVD settings
2. Try: `adb shell settings put secure show_ime_with_hard_keyboard 1`
3. Restart emulator completely
4. Try a different emulator image (API 33 vs 34)

### Emulator is slow?
1. Enable hardware acceleration in BIOS (Intel VT-x or AMD-V)
2. Allocate more RAM to emulator (4GB+)
3. Use x86_64 system images (not ARM)

### Can't create emulator?
1. Make sure Android SDK is properly installed
2. Check that system images are downloaded
3. Verify AVD Manager has proper permissions
