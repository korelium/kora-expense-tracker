// File location: lib/core/services/pdf_statement_service.dart
// Purpose: PDF generation service for credit card statements
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'export_service.dart';

import '../../data/models/credit_card_statement.dart';
import '../../data/models/credit_card.dart';
import '../../data/models/transaction.dart';
import '../../data/providers/currency_provider.dart';

class PDFStatementService {
  static const String _appName = 'Kora Expense Tracker';
  static const String _companyName = 'Korelium';
  
  /// Generate PDF for credit card statement
  static Future<Uint8List> generateStatementPDF({
    required CreditCardStatement statement,
    required CreditCard creditCard,
    required List<Transaction> transactions,
    required CurrencyProvider currencyProvider,
  }) async {
    final pdf = pw.Document();
    
    // Add page with statement content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildHeader(creditCard, statement, currencyProvider),
            pw.SizedBox(height: 20),
            _buildStatementSummary(statement, currencyProvider),
            pw.SizedBox(height: 20),
            _buildTransactionDetails(transactions, currencyProvider),
            pw.SizedBox(height: 20),
            _buildPaymentInformation(statement, currencyProvider),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );
    
    return pdf.save();
  }
  
  /// Build PDF header with company branding
  static pw.Widget _buildHeader(CreditCard creditCard, CreditCardStatement statement, CurrencyProvider currencyProvider) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Company header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _companyName,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.Text(
                    _appName,
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.blue600,
                    ),
                  ),
                ],
              ),
              pw.Text(
                'STATEMENT',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          
          // Credit card info
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Cardholder Name',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      creditCard.cardName,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Card Number',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      '**** **** **** ${creditCard.lastFourDigits}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          
          // Statement period
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Statement Period',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      '${DateFormat('MMM dd, yyyy').format(statement.cycleStartDate)} - ${DateFormat('MMM dd, yyyy').format(statement.cycleEndDate)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Statement Date',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      DateFormat('MMM dd, yyyy').format(statement.statementDate),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build statement summary section
  static pw.Widget _buildStatementSummary(CreditCardStatement statement, CurrencyProvider currencyProvider) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Statement Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 15),
          
          // Summary rows
          _buildSummaryRow('Previous Balance', statement.previousBalance, currencyProvider),
          _buildSummaryRow('New Purchases', statement.newBalance - statement.previousBalance, currencyProvider),
          _buildSummaryRow('Payments & Credits', statement.totalPayments, currencyProvider),
          pw.Divider(color: PdfColors.grey400),
          _buildSummaryRow('New Balance', statement.newBalance, currencyProvider, isTotal: true),
          pw.SizedBox(height: 10),
          _buildSummaryRow('Minimum Payment Due', statement.minimumPayment, currencyProvider, isHighlight: true),
          pw.SizedBox(height: 5),
          _buildSummaryRow('Payment Due Date', statement.dueDate, currencyProvider, isDate: true),
        ],
      ),
    );
  }
  
  /// Build summary row
  static pw.Widget _buildSummaryRow(String label, dynamic value, CurrencyProvider currencyProvider, {bool isTotal = false, bool isHighlight = false, bool isDate = false}) {
    String displayValue;
    if (isDate) {
      displayValue = DateFormat('MMM dd, yyyy').format(value);
    } else {
      displayValue = currencyProvider.formatAmount(value is double ? value : value.toDouble());
    }
    
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            displayValue,
            style: pw.TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal || isHighlight ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isHighlight ? PdfColors.red600 : PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build transaction details section
  static pw.Widget _buildTransactionDetails(List<Transaction> transactions, CurrencyProvider currencyProvider) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Transaction Details',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 15),
        
        // Transaction table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Description', isHeader: true),
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Type', isHeader: true),
                _buildTableCell('Amount', isHeader: true),
              ],
            ),
            // Transaction rows
            ...transactions.map((transaction) => pw.TableRow(
              children: [
                _buildTableCell(transaction.description),
                _buildTableCell(DateFormat('MMM dd').format(transaction.date)),
                _buildTableCell(transaction.type.toString().split('.').last.toUpperCase()),
                _buildTableCell(
                  currencyProvider.formatAmount(transaction.amount),
                  isAmount: true,
                  isIncome: transaction.type.toString().contains('income'),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }
  
  /// Build table cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false, bool isAmount = false, bool isIncome = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey700 : PdfColors.grey800,
        ),
        textAlign: isAmount ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }
  
  /// Build payment information section
  static pw.Widget _buildPaymentInformation(CreditCardStatement statement, CurrencyProvider currencyProvider) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Payment Information',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 15),
          
          pw.Text(
            'Payment Due Date: ${DateFormat('MMM dd, yyyy').format(statement.dueDate)}',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 10),
          
          pw.Text(
            'Minimum Payment Due: ${currencyProvider.formatAmount(statement.minimumPayment)}',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red600,
            ),
          ),
          pw.SizedBox(height: 15),
          
          pw.Text(
            'Please make your payment by the due date to avoid late fees and maintain your credit standing.',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build footer
  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for using $_appName',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Generated on ${DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Save PDF to device storage with organized directory structure
  static Future<String> savePDFToDevice(Uint8List pdfBytes, String fileName) async {
    // Use the export service to save in organized directory structure
    return await ExportService.saveFileToAppDirectory(
      pdfBytes, 
      '$fileName.pdf',
      subdirectory: 'creditcardbills',
    );
  }
  
  /// Share PDF
  static Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: fileName,
    );
  }
  
  /// Print PDF
  static Future<void> printPDF(Uint8List pdfBytes, String fileName) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: fileName,
    );
  }
}
