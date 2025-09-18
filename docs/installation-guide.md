# Kora Expense Tracker - Installation Guide

## 📋 Prerequisites

### System Requirements
- **Operating System**: Windows 10+, macOS 10.14+, Linux (Ubuntu 18.04+)
- **RAM**: Minimum 4GB, Recommended 8GB+
- **Storage**: At least 2GB free space
- **Internet**: Required for initial setup and dependencies

### Development Tools Required

#### 1. Flutter SDK
- **Version**: Flutter 3.16.0 or higher
- **Download**: [Flutter Official Website](https://flutter.dev/docs/get-started/install)
- **Installation**: Follow platform-specific installation guides

#### 2. Dart SDK
- **Included**: Comes with Flutter SDK
- **Version**: Dart 3.2.0 or higher

#### 3. Platform-Specific Tools

##### For Android Development:
- **Android Studio**: Latest stable version
- **Android SDK**: API level 21+ (Android 5.0)
- **Android SDK Build Tools**: Latest version
- **Android SDK Platform Tools**: Latest version

##### For iOS Development (macOS only):
- **Xcode**: Version 14.0 or higher
- **iOS Simulator**: Latest version
- **CocoaPods**: For iOS dependencies

##### For Desktop Development:
- **CMake**: Version 3.10 or higher
- **Visual Studio** (Windows): 2019 or higher with C++ tools
- **Xcode** (macOS): Command Line Tools

## 🚀 Installation Steps

### Step 1: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/korelium/kora-expense-tracker.git

# Navigate to the project directory
cd kora-expense-tracker
```

### Step 2: Install Flutter Dependencies

```bash
# Get Flutter packages
flutter pub get

# Generate code (for Hive adapters)
flutter packages pub run build_runner build
```

### Step 3: Platform Setup

#### For Android:
```bash
# Check Flutter doctor
flutter doctor

# Accept Android licenses
flutter doctor --android-licenses

# Run on Android device/emulator
flutter run
```

#### For iOS (macOS only):
```bash
# Install iOS dependencies
cd ios && pod install && cd ..

# Run on iOS device/simulator
flutter run
```

#### For Desktop:
```bash
# Enable desktop support (if not already enabled)
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop

# Run on desktop
flutter run -d linux    # For Linux
flutter run -d windows  # For Windows
flutter run -d macos    # For macOS
```

### Step 4: Verify Installation

```bash
# Check if everything is working
flutter doctor -v

# Run tests
flutter test

# Analyze code
flutter analyze
```

## 🔧 Development Setup

### IDE Configuration

#### Recommended IDEs:
1. **VS Code** with Flutter/Dart extensions
2. **Android Studio** with Flutter plugin
3. **IntelliJ IDEA** with Flutter plugin

#### VS Code Extensions:
```json
{
  "recommendations": [
    "dart-code.dart-code",
    "dart-code.flutter",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss"
  ]
}
```

### Environment Configuration

#### Create `.env` file (optional):
```bash
# Copy environment template
cp .env.example .env

# Edit with your configurations
nano .env
```

#### Environment Variables:
```env
# App Configuration
APP_NAME=Kora Expense Tracker
APP_VERSION=1.0.0

# Database Configuration
DATABASE_NAME=kora_expense_tracker

# Feature Flags
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=false
```

## 📱 Running the App

### Development Mode

#### Hot Reload Development:
```bash
# Start the app in development mode
flutter run

# Hot reload (press 'r' in terminal)
# Hot restart (press 'R' in terminal)
```

#### Debug Mode:
```bash
# Run with debug information
flutter run --debug

# Run with verbose logging
flutter run -v
```

#### Release Mode:
```bash
# Run in release mode (optimized)
flutter run --release
```

### Platform-Specific Commands

#### Android:
```bash
# Run on specific Android device
flutter run -d <device-id>

# List available devices
flutter devices

# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle
```

#### iOS:
```bash
# Run on iOS simulator
flutter run -d ios

# Run on physical iOS device
flutter run -d <device-id>

# Build iOS app
flutter build ios
```

#### Desktop:
```bash
# Linux
flutter run -d linux
flutter build linux

# Windows
flutter run -d windows
flutter build windows

# macOS
flutter run -d macos
flutter build macos
```

#### Web:
```bash
# Run on web
flutter run -d web-server --web-port 8080

# Build for web
flutter build web
```

## 🏗️ Building for Production

### Android APK
```bash
# Build release APK
flutter build apk --release

# Build split APKs (smaller size)
flutter build apk --split-per-abi

# Sign the APK (if you have a keystore)
flutter build apk --release --signing-key=<path-to-key>
```

### Android App Bundle
```bash
# Build AAB for Play Store
flutter build appbundle --release
```

### iOS App
```bash
# Build iOS app
flutter build ios --release

# Archive for App Store (requires Xcode)
# Open ios/Runner.xcworkspace in Xcode
# Product -> Archive
```

### Desktop Applications
```bash
# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

### Web Application
```bash
# Build for web deployment
flutter build web --release

# The build output will be in build/web/
```

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart

# Run integration tests
flutter test integration_test/
```

### Code Analysis
```bash
# Analyze code for issues
flutter analyze

# Fix auto-fixable issues
dart fix --apply

# Format code
dart format .
```

## 🐛 Troubleshooting

### Common Issues

#### Flutter Doctor Issues:
```bash
# Check Flutter installation
flutter doctor

# Fix common issues
flutter doctor --android-licenses
```

#### Dependency Issues:
```bash
# Clean and reinstall dependencies
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### Build Issues:
```bash
# Clean build cache
flutter clean
flutter pub get

# Rebuild
flutter build apk --debug
```

#### Hive Database Issues:
```bash
# Regenerate Hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs

# If still having issues, delete build folder
rm -rf build/
flutter clean
flutter pub get
```

### Platform-Specific Troubleshooting

#### Android:
- **Gradle Issues**: Update Gradle wrapper
- **SDK Issues**: Check Android SDK installation
- **Emulator Issues**: Create new AVD or use physical device

#### iOS:
- **Pod Issues**: Delete Podfile.lock and reinstall
- **Xcode Issues**: Update Xcode and command line tools
- **Simulator Issues**: Reset iOS simulator

#### Desktop:
- **CMake Issues**: Install CMake and Visual Studio (Windows)
- **Linux Issues**: Install required system dependencies
- **macOS Issues**: Install Xcode command line tools

## 📚 Additional Resources

### Documentation Links:
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/docs)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Provider Documentation](https://pub.dev/packages/provider)

### Community Support:
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [GitHub Issues](https://github.com/korelium/kora-expense-tracker/issues)

### Video Tutorials:
- [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
- [VS Code Flutter Setup](https://flutter.dev/docs/development/tools/vs-code)

---

*If you encounter any issues not covered in this guide, please open an issue on our GitHub repository.*
