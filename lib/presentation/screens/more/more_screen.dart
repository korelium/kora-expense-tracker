import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/currency_provider.dart';
import '../../../data/providers/theme_provider.dart';
import '../../widgets/common/currency_selector.dart';
import '../../widgets/common/theme_toggle.dart';
import '../analytics/analytics_screen.dart';
import '../../../features/loans/presentation/screens/loans_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('More'),
            actions: const [
              ThemeToggle(isCompact: true),
              SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Quick Access Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Access',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF8B5CF6)),
                        title: const Text('Loans'),
                        subtitle: const Text('Manage loans'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoansScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.analytics, color: Color(0xFF06B6D4)),
                        title: const Text('Analytics'),
                        subtitle: const Text('View reports'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnalyticsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Currency Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Currency Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.currency_exchange),
                        title: const Text('Selected Currency'),
                        subtitle: Text(currencyProvider.selectedCurrency),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const CurrencySelector(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Theme Settings Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return ListTile(
                            leading: Icon(themeProvider.themeIcon),
                            title: const Text('Theme'),
                            subtitle: Text(themeProvider.themeModeName),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Choose Theme'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RadioListTile<ThemeMode>(
                                        title: const Text('Light'),
                                        subtitle: const Text('Always use light theme'),
                                        value: ThemeMode.light,
                                        groupValue: themeProvider.themeMode,
                                        onChanged: (ThemeMode? value) {
                                          if (value != null) {
                                            themeProvider.setThemeMode(value);
                                            Navigator.of(context).pop();
                                          }
                                        },
                                      ),
                                      RadioListTile<ThemeMode>(
                                        title: const Text('Dark'),
                                        subtitle: const Text('Always use dark theme'),
                                        value: ThemeMode.dark,
                                        groupValue: themeProvider.themeMode,
                                        onChanged: (ThemeMode? value) {
                                          if (value != null) {
                                            themeProvider.setThemeMode(value);
                                            Navigator.of(context).pop();
                                          }
                                        },
                                      ),
                                      RadioListTile<ThemeMode>(
                                        title: const Text('System'),
                                        subtitle: const Text('Follow system setting'),
                                        value: ThemeMode.system,
                                        groupValue: themeProvider.themeMode,
                                        onChanged: (ThemeMode? value) {
                                          if (value != null) {
                                            themeProvider.setThemeMode(value);
                                            Navigator.of(context).pop();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // App Info Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const ListTile(
                        leading: Icon(Icons.info),
                        title: Text('Version'),
                        subtitle: Text('1.0.0'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.description),
                        title: Text('About'),
                        subtitle: Text('Kora Expense Tracker'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Features Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const ListTile(
                        leading: Icon(Icons.add_circle_outline),
                        title: Text('Add Transaction'),
                        subtitle: Text('Coming Soon'),
                        enabled: false,
                      ),
                      const ListTile(
                        leading: Icon(Icons.account_balance_wallet_outlined),
                        title: Text('Manage Accounts'),
                        subtitle: Text('Coming Soon'),
                        enabled: false,
                      ),
                      const ListTile(
                        leading: Icon(Icons.category_outlined),
                        title: Text('Categories'),
                        subtitle: Text('Coming Soon'),
                        enabled: false,
                      ),
                      const ListTile(
                        leading: Icon(Icons.cloud_sync_outlined),
                        title: Text('Data Backup'),
                        subtitle: Text('Coming Soon'),
                        enabled: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Support Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Support',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const ListTile(
                        leading: Icon(Icons.help_outline),
                        title: Text('Help & Support'),
                        subtitle: Text('Get help with the app'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.feedback_outlined),
                        title: Text('Send Feedback'),
                        subtitle: Text('Share your thoughts'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.star_outline),
                        title: Text('Rate App'),
                        subtitle: Text('Rate us on the store'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
