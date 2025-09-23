// File location: lib/data/services/bill_generation_service.dart
// Purpose: Service for generating credit card bills and statements
// Author: Pown Kumar - Founder of Korelium
// Date: September 23, 2025

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/bill.dart';
import '../models/credit_card.dart';
import '../models/credit_card_transaction.dart';
import '../providers/credit_card_provider.dart';
import '../../core/error_handling/error_handler.dart';

/// Service for generating credit card bills and statements
class BillGenerationService {
  static final BillGenerationService _instance = BillGenerationService._internal();
  factory BillGenerationService() => _instance;
  BillGenerationService._internal();

  /// Generate a bill for a credit card
  Future<Bill> generateBill({
    required String creditCardId,
    required CreditCard creditCard,
    required List<CreditCardTransaction> transactions,
    required DateTime statementPeriodStart,
    required DateTime statementPeriodEnd,
    String? notes,
  }) async {
    try {
      // Calculate bill details
      final billCalculations = _calculateBillDetails(
        creditCard: creditCard,
        transactions: transactions,
        statementPeriodStart: statementPeriodStart,
        statementPeriodEnd: statementPeriodEnd,
      );

      // Create bill
      final bill = Bill(
        id: _generateBillId(),
        creditCardId: creditCardId,
        billDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 15)), // 15 days default
        statementPeriodStart: statementPeriodStart,
        statementPeriodEnd: statementPeriodEnd,
        previousBalance: billCalculations['previousBalance']!,
        totalPayments: billCalculations['totalPayments']!,
        totalPurchases: billCalculations['totalPurchases']!,
        totalInterest: billCalculations['totalInterest']!,
        totalFees: billCalculations['totalFees']!,
        newBalance: billCalculations['newBalance']!,
        minimumPayment: billCalculations['minimumPayment']!,
        availableCredit: billCalculations['availableCredit']!,
        status: BillStatus.pending,
        notes: notes,
      );

      // Generate PDF
      final pdfPath = await _generateBillPDF(bill, creditCard, transactions);
      final updatedBill = bill.copyWith(filePath: pdfPath);

      return updatedBill;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error generating bill: $e');
      }
      rethrow;
    }
  }

  /// Calculate bill details from transactions
  Map<String, double> _calculateBillDetails({
    required CreditCard creditCard,
    required List<CreditCardTransaction> transactions,
    required DateTime statementPeriodStart,
    required DateTime statementPeriodEnd,
  }) {
    // Filter transactions for the statement period
    final periodTransactions = transactions.where((transaction) {
      return transaction.transactionDate.isAfter(statementPeriodStart.subtract(const Duration(days: 1))) &&
             transaction.transactionDate.isBefore(statementPeriodEnd.add(const Duration(days: 1)));
    }).toList();

    // Calculate totals
    double totalPayments = 0.0;
    double totalPurchases = 0.0;
    double totalInterest = 0.0;
    double totalFees = 0.0;

    for (final transaction in periodTransactions) {
      if (transaction.isPayment || transaction.isRefund) {
        totalPayments += transaction.amount.abs();
      } else if (transaction.type == CreditCardTransactionType.purchase) {
        totalPurchases += transaction.amount.abs();
      } else if (transaction.type == CreditCardTransactionType.interest) {
        totalInterest += transaction.amount.abs();
      } else if (transaction.type == CreditCardTransactionType.fee) {
        totalFees += transaction.amount.abs();
      }
    }

    // Calculate previous balance (balance at start of period)
    final previousBalance = creditCard.currentBalance - totalPurchases + totalPayments - totalInterest - totalFees;
    
    // Calculate new balance
    final newBalance = previousBalance + totalPurchases - totalPayments + totalInterest + totalFees;
    
    // Calculate minimum payment (typically 5% of new balance or minimum amount)
    final minimumPayment = (newBalance * 0.05).clamp(creditCard.minimumPayment, newBalance);
    
    // Calculate available credit
    final availableCredit = creditCard.creditLimit - newBalance;

    return {
      'previousBalance': previousBalance,
      'totalPayments': totalPayments,
      'totalPurchases': totalPurchases,
      'totalInterest': totalInterest,
      'totalFees': totalFees,
      'newBalance': newBalance,
      'minimumPayment': minimumPayment,
      'availableCredit': availableCredit,
    };
  }

  /// Generate PDF for the bill
  Future<String> _generateBillPDF(
    Bill bill,
    CreditCard creditCard,
    List<CreditCardTransaction> transactions,
  ) async {
    try {
      final pdf = pw.Document();

      // Filter transactions for the statement period
      final periodTransactions = transactions.where((transaction) {
        return transaction.transactionDate.isAfter(bill.statementPeriodStart.subtract(const Duration(days: 1))) &&
               transaction.transactionDate.isBefore(bill.statementPeriodEnd.add(const Duration(days: 1)));
      }).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildBillHeader(creditCard, bill),
                pw.SizedBox(height: 20),
                
                // Statement period
                _buildStatementPeriod(bill),
                pw.SizedBox(height: 20),
                
                // Account summary
                _buildAccountSummary(bill),
                pw.SizedBox(height: 20),
                
                // Transaction details
                _buildTransactionDetails(periodTransactions),
                pw.SizedBox(height: 20),
                
                // Payment information
                _buildPaymentInformation(bill),
                pw.SizedBox(height: 20),
                
                // Footer
                _buildBillFooter(),
              ],
            );
          },
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/bill_${bill.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error generating PDF: $e');
      }
      rethrow;
    }
  }

  /// Build bill header
  pw.Widget _buildBillHeader(CreditCard creditCard, Bill bill) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CREDIT CARD STATEMENT',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Card: ${creditCard.displayName}',
            style: const pw.TextStyle(fontSize: 16),
          ),
          pw.Text(
            'Bank: ${creditCard.bankName}',
            style: const pw.TextStyle(fontSize: 16),
          ),
          pw.Text(
            'Statement Period: ${bill.formattedPeriod}',
            style: const pw.TextStyle(fontSize: 16),
          ),
          pw.Text(
            'Due Date: ${bill.formattedDueDate}',
            style: const pw.TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Build statement period section
  pw.Widget _buildStatementPeriod(Bill bill) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Text(
        'Statement Period: ${bill.formattedPeriod}',
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  /// Build account summary section
  pw.Widget _buildAccountSummary(Bill bill) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ACCOUNT SUMMARY',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildSummaryRow('Previous Balance', bill.previousBalance),
          _buildSummaryRow('Payments', -bill.totalPayments),
          _buildSummaryRow('Purchases', bill.totalPurchases),
          _buildSummaryRow('Interest', bill.totalInterest),
          _buildSummaryRow('Fees', bill.totalFees),
          pw.Divider(),
          _buildSummaryRow('NEW BALANCE', bill.newBalance, isTotal: true),
          pw.SizedBox(height: 5),
          _buildSummaryRow('Minimum Payment', bill.minimumPayment),
          _buildSummaryRow('Available Credit', bill.availableCredit),
        ],
      ),
    );
  }

  /// Build summary row
  pw.Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            '₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Build transaction details section
  pw.Widget _buildTransactionDetails(List<CreditCardTransaction> transactions) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TRANSACTION DETAILS',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          if (transactions.isEmpty)
            pw.Text(
              'No transactions for this period',
              style: const pw.TextStyle(fontSize: 12),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Description',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Type',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Amount',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Transactions
                ...transactions.map((transaction) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${transaction.transactionDate.day}/${transaction.transactionDate.month}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        transaction.description,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        transaction.type.toString().split('.').last.toUpperCase(),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        transaction.formattedAmount,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                )),
              ],
            ),
        ],
      ),
    );
  }

  /// Build payment information section
  pw.Widget _buildPaymentInformation(Bill bill) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.red50,
        border: pw.Border.all(color: PdfColors.red200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT INFORMATION',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Due Date: ${bill.formattedDueDate}',
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.Text(
            'Minimum Payment: ₹${bill.minimumPayment.toStringAsFixed(2)}',
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.Text(
            'Total Amount Due: ₹${bill.newBalance.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Please make your payment by the due date to avoid late fees and interest charges.',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Build bill footer
  pw.Widget _buildBillFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Text(
        'This statement was generated by Kora Expense Tracker on ${DateTime.now().toString().split(' ')[0]}.',
        style: const pw.TextStyle(fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Generate unique bill ID
  String _generateBillId() {
    final now = DateTime.now();
    return 'BILL_${now.millisecondsSinceEpoch}';
  }
}
