# Kora Expense Tracker - Architecture Documentation

## 🏗️ Architecture Overview

Kora Expense Tracker follows **Clean Architecture** principles with **MVVM (Model-View-ViewModel)** pattern, ensuring separation of concerns, testability, and maintainability.

## 📐 Architecture Layers

### 1. Presentation Layer
**Location**: `lib/presentation/`
**Purpose**: UI components, screens, and user interactions

```
presentation/
├── screens/           # App screens and pages
│   ├── home/         # Home dashboard
│   ├── accounts/     # Account management
│   ├── transactions/ # Transaction management
│   └── categories/   # Category management
├── widgets/          # Reusable UI components
│   ├── common/       # Shared widgets
│   ├── forms/        # Form components
│   ├── charts/       # Chart components
│   └── transaction_form/ # Transaction form widgets
└── providers/        # State management (Provider pattern)
```

### 2. Data Layer
**Location**: `lib/data/`
**Purpose**: Data models, storage, and external data sources

```
data/
├── models/           # Data models and entities
│   ├── account.dart
│   ├── category.dart
│   └── transaction.dart
├── providers/        # Data providers and repositories
│   ├── transaction_provider_hive.dart
│   ├── currency_provider.dart
│   └── theme_provider.dart
└── services/         # External services and APIs
    └── hive_database_helper.dart
```

### 3. Core Layer
**Location**: `lib/core/`
**Purpose**: Shared utilities, constants, and base classes

```
core/
├── theme/           # App theming and styling
│   └── app_theme.dart
├── utils/           # Utility functions
└── constants/       # App constants
```

## 🔄 Data Flow Architecture

### MVVM Pattern Implementation

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   View (UI)     │◄──►│ ViewModel       │◄──►│   Model         │
│   (Widgets)     │    │ (Providers)     │    │ (Data Models)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ User Interface  │    │ Business Logic  │    │ Data Storage    │
│ - Screens       │    │ - State Mgmt    │    │ - Hive DB       │
│ - Widgets       │    │ - Validation    │    │ - Models        │
│ - Navigation    │    │ - Data Transform│    │ - Services      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📊 State Management

### Provider Pattern Implementation

#### 1. TransactionProviderHive
**Purpose**: Manages transaction, account, and category data
**Location**: `lib/data/providers/transaction_provider_hive.dart`

```dart
class TransactionProviderHive with ChangeNotifier {
  // State
  bool _isLoading = false;
  
  // Getters
  List<Transaction> get transactions => _db.getAllTransactions();
  List<Account> get accounts => _db.getAllAccounts();
  List<Category> get categories => _db.getAllCategories();
  
  // Methods
  Future<void> addTransaction(Transaction transaction) async { ... }
  Future<void> updateTransaction(Transaction transaction) async { ... }
  Future<void> deleteTransaction(String id) async { ... }
}
```

#### 2. CurrencyProvider
**Purpose**: Manages currency settings and formatting
**Location**: `lib/data/providers/currency_provider.dart`

```dart
class CurrencyProvider with ChangeNotifier {
  String _selectedCurrency = 'INR';
  String _currencySymbol = '₹';
  
  String get selectedCurrency => _selectedCurrency;
  String get currencySymbol => _currencySymbol;
  
  Future<void> setCurrency(String currency) async { ... }
  String formatAmount(double amount) { ... }
}
```

#### 3. ThemeProvider
**Purpose**: Manages app theme (light/dark/system)
**Location**: `lib/data/providers/theme_provider.dart`

```dart
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  
  Future<void> setThemeMode(ThemeMode mode) async { ... }
  Future<void> toggleTheme() async { ... }
}
```

## 🗄️ Database Architecture

### Hive Database Structure

#### Database Helper
**Location**: `lib/data/services/hive_database_helper.dart`

```dart
class HiveDatabaseHelper {
  // Database boxes
  static const String _transactionsBox = 'transactions_box';
  static const String _accountsBox = 'accounts_box';
  static const String _categoriesBox = 'categories_box';
  static const String _settingsBox = 'settings_box';
  
  // Box references
  late Box<Transaction> _transactionsBoxRef;
  late Box<Account> _accountsBoxRef;
  late Box<Category> _categoriesBoxRef;
  late Box _settingsBoxRef;
}
```

#### Data Models with Hive Annotations

**Transaction Model**:
```dart
@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String accountId;
  @HiveField(2) final String categoryId;
  @HiveField(3) final String? subcategoryId;
  @HiveField(4) final double amount;
  @HiveField(5) final String description;
  @HiveField(6) final DateTime date;
  @HiveField(7) final TransactionType type;
  @HiveField(8) final String? receiptImagePath;
}
```

**Account Model**:
```dart
@HiveType(typeId: 4)
class Account extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final AccountType type;
  @HiveField(3) final double balance;
  @HiveField(4) final String? description;
  @HiveField(5) final DateTime createdAt;
}
```

**Category Model**:
```dart
@HiveType(typeId: 5)
class Category extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final String icon;
  @HiveField(3) final CategoryType type;
  @HiveField(4) final String color;
  @HiveField(5) final String? parentId;
  @HiveField(6) final String? notes;
  @HiveField(7) final int usageCount;
  @HiveField(8) final DateTime? lastUsed;
}
```

## 🎨 UI Architecture

### Screen Structure

#### Main App Structure
```dart
KoraApp
├── AppInitializer
│   ├── IntroScreen (first time users)
│   └── HomeScreen (returning users)
└── MultiProvider
    ├── CurrencyProvider
    ├── TransactionProviderHive
    └── ThemeProvider
```

#### Home Screen Architecture
```dart
HomeScreen
├── AppBar
├── DashboardContent
│   ├── FinancialOverview
│   ├── QuickActions
│   └── RecentTransactions
└── BottomNavigationBar
    ├── HomeTab
    ├── TransactionsTab
    ├── AnalyticsTab
    └── MoreTab
```

#### Transaction Form Architecture
```dart
TransactionFormScreen
├── TransactionFormController (Business Logic)
├── TransactionTypeToggle
├── AmountInputSection
├── AccountSelector
├── CategorySelector
├── SubcategorySelector
├── DateTimePicker
└── ReceiptImagePicker
```

### Widget Composition

#### Reusable Widgets
```dart
// Common widgets
EmptyStateWidget
DashboardWidgets
MiniCharts

// Form widgets
TransactionTypeToggle
AmountInputSection
AccountSelector
CategorySelector
SubcategorySelector
DateTimePicker
ReceiptImagePicker

// Chart widgets
PieChart
BarChart
LineChart
```

## 🔄 Data Flow Patterns

### 1. Adding a Transaction

```
User Input → TransactionFormController → TransactionProviderHive → HiveDatabaseHelper → Hive Database
     ↓                    ↓                         ↓                      ↓
UI Update ← Widget Rebuild ← notifyListeners() ← Data Validation ← Database Write
```

### 2. Loading Data

```
App Start → HiveDatabaseHelper.initialize() → Open Boxes → Load Default Data
     ↓                    ↓                        ↓              ↓
UI Render ← Provider State ← notifyListeners() ← Data Query ← Hive Database
```

### 3. Theme Changes

```
User Action → ThemeProvider.setThemeMode() → SharedPreferences → App Rebuild
     ↓                    ↓                         ↓              ↓
UI Update ← MaterialApp ← Consumer<ThemeProvider> ← State Change ← Storage
```

## 🧪 Testing Architecture

### Test Structure
```
test/
├── unit/              # Unit tests
│   ├── models/       # Model tests
│   ├── providers/    # Provider tests
│   └── services/     # Service tests
├── widget/           # Widget tests
│   ├── screens/      # Screen tests
│   └── widgets/      # Widget tests
└── integration/      # Integration tests
```

### Testing Strategy
- **Unit Tests**: Test individual components in isolation
- **Widget Tests**: Test UI components and interactions
- **Integration Tests**: Test complete user workflows

## 📱 Platform Architecture

### Cross-Platform Structure
```
lib/
├── main.dart          # Entry point
├── core/             # Shared core functionality
├── data/             # Data layer (platform agnostic)
└── presentation/     # UI layer (Flutter widgets)

Platform-specific:
├── android/          # Android-specific configurations
├── ios/             # iOS-specific configurations
├── linux/           # Linux-specific configurations
├── windows/         # Windows-specific configurations
├── macos/           # macOS-specific configurations
└── web/             # Web-specific configurations
```

### Platform Adaptations
- **Mobile**: Touch-optimized UI, camera integration
- **Desktop**: Keyboard shortcuts, window management
- **Web**: Progressive Web App features

## 🔧 Dependency Injection

### Provider Setup
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CurrencyProvider()),
    ChangeNotifierProvider(create: (_) => TransactionProviderHive()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: MaterialApp(...),
)
```

### Service Locator Pattern
```dart
// Singleton pattern for database helper
class HiveDatabaseHelper {
  static final HiveDatabaseHelper _instance = HiveDatabaseHelper._internal();
  factory HiveDatabaseHelper() => _instance;
  HiveDatabaseHelper._internal();
}
```

## 🚀 Performance Optimizations

### State Management Optimizations
- **Selective Rebuilds**: Use `Consumer` and `Selector` widgets
- **Lazy Loading**: Load data only when needed
- **Caching**: Cache frequently accessed data
- **Debouncing**: Debounce user inputs

### Database Optimizations
- **Indexing**: Efficient querying with Hive
- **Batch Operations**: Group database operations
- **Lazy Initialization**: Initialize database boxes on demand
- **Memory Management**: Proper disposal of resources

### UI Optimizations
- **ListView.builder**: Efficient list rendering
- **Image Optimization**: Compress and cache images
- **Animation Performance**: Use efficient animations
- **Memory Management**: Dispose controllers and listeners

## 🔒 Security Architecture

### Data Security
- **Local Storage**: All data stored locally
- **No Network Calls**: No external API dependencies
- **Input Validation**: Validate all user inputs
- **Error Handling**: Graceful error management

### Privacy Protection
- **No Analytics**: No usage tracking
- **No Ads**: Ad-free experience
- **Data Control**: User has complete control over data
- **Backup Security**: Secure local backups

## 📈 Scalability Considerations

### Code Organization
- **Modular Structure**: Easy to add new features
- **Separation of Concerns**: Clear boundaries between layers
- **Reusable Components**: Widget composition
- **Consistent Patterns**: Standardized code patterns

### Performance Scaling
- **Efficient Queries**: Optimized database operations
- **Memory Management**: Proper resource cleanup
- **Lazy Loading**: Load data on demand
- **Caching Strategy**: Intelligent data caching

---

*This architecture ensures the app is maintainable, testable, and scalable while providing excellent user experience across all platforms.*
