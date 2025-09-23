# 💳 Kora Expense Tracker

A comprehensive Flutter expense tracking application with advanced credit card management, analytics, and smart navigation features.

## 🚀 Features

### 💰 **Core Financial Management**
- **Multi-Account Support** - Bank accounts, cash, and credit cards
- **Transaction Tracking** - Income and expense management
- **Category Management** - Customizable spending categories
- **Currency Support** - Multiple currency options with real-time conversion

### 💳 **Advanced Credit Card Management**
- **Credit Card Accounts** - Full credit card lifecycle management
- **Balance Tracking** - Real-time balance and available credit monitoring
- **Transaction History** - Detailed credit card transaction records
- **Payment Reminders** - Due date tracking and payment notifications
- **Credit Utilization** - Smart credit utilization monitoring

### 📊 **Analytics & Insights**
- **Visual Charts** - Line, pie, and bar charts for spending analysis
- **Trend Analysis** - Monthly and yearly spending patterns
- **Category Breakdown** - Detailed spending by category
- **Financial Insights** - Smart recommendations and alerts

### 🎯 **Smart Navigation**
- **Intelligent Back Button** - Smart navigation with double-tap to exit
- **Tabbed Interface** - Organized content with Overview, Transactions, and Analytics tabs
- **Context-Aware Navigation** - Breadcrumb navigation system

### 🎨 **Modern UI/UX**
- **Minimalist Design** - Clean, modern interface
- **Responsive Layout** - Optimized for all screen sizes
- **Dark/Light Theme** - Theme switching support
- **Smooth Animations** - Polished user experience

## 🏗️ Architecture

### **Clean Architecture Pattern**
```
lib/
├── core/                    # Core functionality
│   ├── error_handling/     # Error handling system
│   ├── navigation/         # Navigation management
│   └── theme/             # App theming
├── data/                   # Data layer
│   ├── models/            # Data models
│   ├── providers/         # State management
│   └── services/          # Database services
└── presentation/          # UI layer
    ├── screens/           # App screens
    └── widgets/           # Reusable widgets
```

### **State Management**
- **Provider Pattern** - Reactive state management
- **ChangeNotifier** - Efficient UI updates
- **Hive Database** - Local data persistence

### **Key Components**
- **TransactionProviderHive** - Transaction management
- **CreditCardProvider** - Credit card operations
- **CurrencyProvider** - Currency handling
- **NavigationController** - Smart navigation
- **ErrorHandler** - Centralized error management

## 🛠️ Technical Stack

- **Framework:** Flutter 3.x
- **Database:** Hive (NoSQL)
- **State Management:** Provider
- **Charts:** fl_chart
- **Architecture:** Clean Architecture
- **Platform:** Android/iOS

## 📱 Screenshots

### Home Dashboard
- Financial overview with total balance
- Quick stats and recent transactions
- Smart navigation breadcrumbs

### Credit Card Management
- Tabbed interface (Overview, Transactions, Analytics)
- Real-time balance updates
- Transaction history with smart sorting

### Analytics
- Visual spending charts
- Category breakdown
- Trend analysis

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/kora-expense-tracker.git
   cd kora-expense-tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Database Setup
The app uses Hive for local data storage. Database initialization is handled automatically on first launch.

### Currency Configuration
Default currency can be configured in the `CurrencyProvider`. The app supports multiple currencies with real-time conversion.

## 📊 Key Features Implementation

### Credit Card Management
- **Account Creation** - Create credit card accounts with limit and due date
- **Transaction Tracking** - Automatic transaction recording
- **Balance Updates** - Real-time balance synchronization
- **Payment Management** - Payment tracking and reminders

### Smart Navigation
- **Context-Aware Back Button** - Returns to appropriate screen
- **Double-Tap Exit** - Quick app exit functionality
- **Breadcrumb Navigation** - Clear navigation context

### Error Handling
- **Centralized Error Management** - Consistent error handling
- **User-Friendly Messages** - Clear error communication
- **Graceful Degradation** - App continues functioning despite errors

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### Test Coverage
- Unit tests for providers and services
- Widget tests for UI components
- Integration tests for user flows

## 📈 Performance Optimizations

- **Efficient State Management** - Minimal rebuilds
- **Lazy Loading** - On-demand data loading
- **Image Optimization** - Compressed assets
- **Memory Management** - Proper disposal of resources

## 🔒 Security Features

- **Local Data Storage** - No cloud dependency
- **Data Encryption** - Hive encryption support
- **Input Validation** - Comprehensive data validation
- **Error Boundaries** - Graceful error handling

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Pown Kumar** - Founder of Korelium
- GitHub: [@pownkumar](https://github.com/pownkumar)
- LinkedIn: [Pown Kumar](https://linkedin.com/in/pownkumar)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Hive team for the excellent database solution
- fl_chart team for the beautiful charting library
- Provider team for the state management solution

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Contact: pown@korelium.com
- Visit: [korelium.com](https://korelium.com)

---

**Made with ❤️ by Korelium Team**