# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites Check
```bash
# Check if Flutter is installed
flutter --version

# Check Flutter doctor
flutter doctor
```

### 1. Clone and Setup
```bash
# Clone the repository
git clone https://github.com/korelium/kora-expense-tracker.git
cd kora-expense-tracker

# Install dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build
```

### 2. Run the App
```bash
# Run on connected device/emulator
flutter run

# Or run on specific platform
flutter run -d android    # Android
flutter run -d ios        # iOS
flutter run -d linux      # Linux Desktop
flutter run -d windows    # Windows Desktop
flutter run -d macos      # macOS Desktop
flutter run -d web        # Web Browser
```

### 3. First Time Setup
1. **Welcome Screen**: Complete the intro screens
2. **Add Account**: Create your first account (Bank/Cash)
3. **Add Transaction**: Record your first income/expense
4. **Explore Features**: Check out categories, analytics, and settings

### 4. Basic Usage
- **Add Income**: Tap + → Income → Fill details → Save
- **Add Expense**: Tap + → Expense → Fill details → Save
- **View Analytics**: Navigate to Analytics tab
- **Manage Accounts**: Go to Accounts section
- **Settings**: Access from More tab

## 🎯 Essential Features

### Quick Actions
- **Quick Amount Buttons**: Tap predefined amounts
- **Category Suggestions**: Most used categories appear first
- **Receipt Photos**: Attach receipt images to transactions
- **Date/Time Picker**: Precise transaction timing

### Navigation
- **Bottom Tabs**: Home, Transactions, Analytics, More
- **Back Navigation**: Standard back button behavior
- **Deep Linking**: Direct access to specific screens

## 🔧 Troubleshooting

### Common Issues
```bash
# If build fails
flutter clean
flutter pub get

# If Hive issues
flutter packages pub run build_runner build --delete-conflicting-outputs

# If device not detected
flutter devices
```

### Getting Help
- Check [Installation Guide](installation-guide.md) for detailed setup
- Visit [GitHub Issues](https://github.com/korelium/kora-expense-tracker/issues) for support
- Read [User Guide](user-guide.md) for detailed usage instructions

---

*You're all set! Start tracking your finances with Kora Expense Tracker.*
