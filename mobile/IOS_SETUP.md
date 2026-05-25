# iOS Setup Instructions (for Mac)

## Prerequisites

1. **Xcode** - Install from the Mac App Store (free)
2. **Flutter SDK** - Install from https://docs.flutter.dev/get-started/install/macos
3. **CocoaPods** - Run in Terminal:
   ```bash
   sudo gem install cocoapods
   ```

## First-Time Setup

Open Terminal, navigate to the project folder, and run:

```bash
# 1. Get Flutter dependencies
flutter pub get

# 2. Install iOS pods
cd ios
pod install
cd ..

# 3. Verify everything is ready
flutter doctor
```

## Running on iPhone

### Connect Your iPhone

1. Connect iPhone to Mac via USB cable
2. On iPhone: tap "Trust This Computer" when prompted
3. Unlock your iPhone and keep it unlocked during first install

### Enable Developer Mode (iOS 16+)

If your iPhone runs iOS 16 or later:
1. Go to **Settings > Privacy & Security > Developer Mode**
2. Toggle **ON** and restart when prompted

### Run the App

```bash
# List available devices
flutter devices

# Run on connected iPhone
flutter run
```

If multiple devices are connected, specify the device:
```bash
flutter run -d <device_id>
```

## First Run Notes

- The **first build takes 5-10 minutes** (downloading dependencies, compiling)
- Subsequent runs are much faster (~30 seconds)
- You may need to **trust the developer certificate** on iPhone:
  - Go to **Settings > General > VPN & Device Management**
  - Tap your Apple ID under "Developer App"
  - Tap **Trust**

## Troubleshooting

### "No provisioning profile"
You need an Apple ID signed into Xcode:
1. Open Xcode
2. Go to **Xcode > Settings > Accounts**
3. Add your Apple ID (free account works for personal device testing)
4. In the project, select your "Team" in Signing & Capabilities

### Pod install fails
```bash
cd ios
pod deintegrate
pod cache clean --all
pod install
```

### Device not detected
- Make sure iPhone is unlocked
- Try a different USB cable/port
- Run `flutter doctor` to check for issues

## Quick Commands Reference

| Command | Description |
|---------|-------------|
| `flutter run` | Run in debug mode |
| `flutter run --release` | Run optimized release build |
| `flutter devices` | List connected devices |
| `flutter clean` | Clear build cache |
| `flutter pub get` | Reinstall dependencies |
