// File location: lib/presentation/screens/credit_cards/add_credit_card_screen.dart
// Purpose: Screen for adding new credit cards
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/credit_card_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Screen for adding a new credit card
/// Contains form with mandatory fields: card name, bank name, credit limit, due day
class AddCreditCardScreen extends StatefulWidget {
  const AddCreditCardScreen({super.key});

  @override
  State<AddCreditCardScreen> createState() => _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends State<AddCreditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNameController = TextEditingController();
  final _lastFourDigitsController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _minimumPaymentController = TextEditingController();
  final _minimumPaymentPercentageController = TextEditingController();
  final _minimumPaymentFixedController = TextEditingController();
  final _gracePeriodController = TextEditingController();
  final _notesController = TextEditingController();
  
  int _selectedDueDay = 1;
  int _selectedStatementDay = 1;
  bool _useFixedMinimumPayment = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _minimumPaymentPercentageController.text = '3.0';
    _gracePeriodController.text = '21';
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _lastFourDigitsController.dispose();
    _bankNameController.dispose();
    _creditLimitController.dispose();
    _interestRateController.dispose();
    _minimumPaymentController.dispose();
    _minimumPaymentPercentageController.dispose();
    _minimumPaymentFixedController.dispose();
    _gracePeriodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Add Credit Card',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<CreditCardProvider>(
        builder: (context, creditCardProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildCardInfoSection(),
                  const SizedBox(height: 24),
                  _buildCreditDetailsSection(),
                  const SizedBox(height: 24),
                  _buildBillingCycleSection(),
                  const SizedBox(height: 24),
                  _buildPaymentDetailsSection(),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                  const SizedBox(height: 32),
                  _buildAddButton(creditCardProvider),
                  if (creditCardProvider.error != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorWidget(creditCardProvider.error!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.credit_card,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Credit Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in the details to add your credit card',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.lightText.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfoSection() {
    return _buildSection(
      title: 'Card Information',
      icon: Icons.credit_card,
      children: [
        _buildTextField(
          controller: _cardNameController,
          label: 'Card Name *',
          hint: 'e.g., Chase Freedom, Amex Gold',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Card name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastFourDigitsController,
          label: 'Last Four Digits',
          hint: 'e.g., 1234 (optional)',
          keyboardType: TextInputType.number,
          maxLength: 4,
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length != 4) {
              return 'Please enter exactly 4 digits or leave empty';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _bankNameController,
          label: 'Bank Name *',
          hint: 'e.g., Chase, American Express, Capital One',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bank name is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCreditDetailsSection() {
    return _buildSection(
      title: 'Credit Details',
      icon: Icons.account_balance,
      children: [
        _buildTextField(
          controller: _creditLimitController,
          label: 'Credit Limit *',
          hint: 'e.g., 5000',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Credit limit is required';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid credit limit';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _interestRateController,
          label: 'Interest Rate (%)',
          hint: 'e.g., 18.99',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final rate = double.tryParse(value);
              if (rate == null || rate < 0 || rate > 100) {
                return 'Please enter a valid interest rate (0-100)';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBillingCycleSection() {
    return _buildSection(
      title: 'Billing Cycle',
      icon: Icons.calendar_today,
      children: [
        _buildStatementDaySelector(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _gracePeriodController,
          label: 'Grace Period (Days) *',
          hint: 'e.g., 21',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Grace period is required';
            }
            final days = int.tryParse(value);
            if (days == null || days < 1 || days > 30) {
              return 'Please enter a valid grace period (1-30 days)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildMinimumPaymentTypeSelector(),
        const SizedBox(height: 16),
        if (_useFixedMinimumPayment)
          _buildTextField(
            controller: _minimumPaymentFixedController,
            label: 'Fixed Minimum Payment *',
            hint: 'e.g., 500',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Fixed minimum payment is required';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount < 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          )
        else
          _buildTextField(
            controller: _minimumPaymentPercentageController,
            label: 'Minimum Payment Percentage *',
            hint: 'e.g., 3.0',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Minimum payment percentage is required';
              }
              final percentage = double.tryParse(value);
              if (percentage == null || percentage < 0 || percentage > 100) {
                return 'Please enter a valid percentage (0-100)';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildPaymentDetailsSection() {
    return _buildSection(
      title: 'Payment Details',
      icon: Icons.payment,
      children: [
        _buildDueDaySelector(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _minimumPaymentController,
          label: 'Minimum Payment (Legacy)',
          hint: 'e.g., 25 (will be calculated automatically)',
          keyboardType: TextInputType.number,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildStatementDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statement Generation Day *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Day of month when your statement is generated',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.lightText.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.lightBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedStatementDay,
              isExpanded: true,
              style: TextStyle(
                color: AppTheme.lightText,
                fontSize: 16,
              ),
              dropdownColor: Colors.white,
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppTheme.lightText,
              ),
              items: List.generate(31, (index) => index + 1)
                  .map((day) => DropdownMenuItem<int>(
                        value: day,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: AppTheme.lightText,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatementDay = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimumPaymentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Payment Type *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text(
                  'Percentage',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'e.g., 3% of balance',
                  style: TextStyle(fontSize: 12),
                ),
                value: false,
                groupValue: _useFixedMinimumPayment,
                onChanged: (value) {
                  setState(() {
                    _useFixedMinimumPayment = value!;
                  });
                },
                activeColor: AppTheme.primaryBlue,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text(
                  'Fixed Amount',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'e.g., ₹500',
                  style: TextStyle(fontSize: 12),
                ),
                value: true,
                groupValue: _useFixedMinimumPayment,
                onChanged: (value) {
                  setState(() {
                    _useFixedMinimumPayment = value!;
                  });
                },
                activeColor: AppTheme.primaryBlue,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDueDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Due Day (Legacy) *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Will be calculated from statement date + grace period',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.lightText.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.lightBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedDueDay,
              isExpanded: true,
              style: TextStyle(
                color: AppTheme.lightText.withOpacity(0.6),
                fontSize: 16,
              ),
              dropdownColor: Colors.white,
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppTheme.lightText.withOpacity(0.6),
              ),
              items: List.generate(31, (index) => index + 1)
                  .map((day) => DropdownMenuItem<int>(
                        value: day,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: AppTheme.lightText.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDueDay = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return _buildSection(
      title: 'Additional Notes',
      icon: Icons.note,
      children: [
        _buildTextField(
          controller: _notesController,
          label: 'Notes',
          hint: 'Any additional information about this card',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          validator: validator,
          readOnly: readOnly,
          style: TextStyle(
            color: AppTheme.lightText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.lightText.withOpacity(0.5),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.lightBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(CreditCardProvider creditCardProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _addCreditCard(creditCardProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Add Credit Card',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCreditCard(CreditCardProvider creditCardProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate minimum payment based on type
      double calculatedMinimumPayment = 0.0;
      if (_useFixedMinimumPayment) {
        calculatedMinimumPayment = double.parse(_minimumPaymentFixedController.text.trim());
      } else {
        // For percentage, we'll calculate it when needed based on balance
        calculatedMinimumPayment = 0.0; // Will be calculated dynamically
      }

      await creditCardProvider.addCreditCard(
        cardName: _cardNameController.text.trim(),
        lastFourDigits: _lastFourDigitsController.text.trim().isEmpty ? '0000' : _lastFourDigitsController.text.trim(),
        bankName: _bankNameController.text.trim(),
        creditLimit: double.parse(_creditLimitController.text.trim()),
        interestRate: _interestRateController.text.isNotEmpty
            ? double.parse(_interestRateController.text.trim())
            : 0.0,
        dueDay: _selectedDueDay,
        statementGenerationDay: _selectedStatementDay,
        gracePeriodDays: int.parse(_gracePeriodController.text.trim()),
        minimumPaymentPercentage: _useFixedMinimumPayment 
            ? 0.0 
            : double.parse(_minimumPaymentPercentageController.text.trim()),
        minimumPaymentFixedAmount: _useFixedMinimumPayment 
            ? double.parse(_minimumPaymentFixedController.text.trim())
            : null,
        minimumPayment: calculatedMinimumPayment,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Credit card added successfully!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to add credit card: $e')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
