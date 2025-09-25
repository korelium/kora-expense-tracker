import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/transaction.dart';
import '../../../../core/services/image_storage_service.dart';

/// Transaction Form Controller
/// Manages the state and logic for the transaction form
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class TransactionFormController extends ChangeNotifier {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TransactionType _selectedType = TransactionType.expense;
  bool _isLoading = false;
  String? _receiptImagePath;
  List<String> _receiptImagePaths = [];
  
  // Quick amount buttons
  final List<double> quickAmounts = [100, 500, 1000, 2000, 5000];
  
  // Getters
  String? get selectedAccountId => _selectedAccountId;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedSubcategoryId => _selectedSubcategoryId;
  DateTime get selectedDate => _selectedDate;
  TimeOfDay get selectedTime => _selectedTime;
  TransactionType get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  String? get receiptImagePath => _receiptImagePath;
  List<String> get receiptImagePaths => _receiptImagePaths;

  /// Initialize form with transaction data (for editing)
  void initializeWithTransaction(Transaction transaction) {
    descriptionController.text = transaction.description;
    amountController.text = transaction.amount.toString();
    notesController.text = transaction.notes ?? '';
    _selectedAccountId = transaction.accountId;
    _selectedCategoryId = transaction.categoryId;
    _selectedSubcategoryId = transaction.subcategoryId;
    _selectedDate = transaction.date;
    _selectedTime = TimeOfDay.fromDateTime(transaction.date);
    _selectedType = transaction.type;
    _receiptImagePath = transaction.receiptImagePath;
    _receiptImagePaths = List.from(transaction.receiptImagePaths);
    notifyListeners();
  }

  /// Validate and reset account selection if account no longer exists
  void validateAccountSelection(List<String> availableAccountIds) {
    if (_selectedAccountId != null && !availableAccountIds.contains(_selectedAccountId)) {
      _selectedAccountId = null;
      notifyListeners();
    }
  }

  /// Initialize form with initial type
  void initializeWithType(TransactionType type) {
    _selectedType = type;
    notifyListeners();
  }

  /// Update transaction type
  void updateTransactionType(TransactionType type) {
    _selectedType = type;
    _selectedCategoryId = null;
    _selectedSubcategoryId = null;
    notifyListeners();
  }

  /// Update selected account
  void updateAccountId(String? accountId) {
    _selectedAccountId = accountId;
    notifyListeners();
  }

  /// Update selected category
  void updateCategoryId(String? categoryId) {
    _selectedCategoryId = categoryId;
    _selectedSubcategoryId = null; // Reset subcategory when category changes
    notifyListeners();
  }

  /// Update selected subcategory
  void updateSubcategoryId(String? subcategoryId) {
    _selectedSubcategoryId = subcategoryId;
    notifyListeners();
  }

  /// Update selected date
  void updateDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Update selected time
  void updateTime(TimeOfDay time) {
    _selectedTime = time;
    notifyListeners();
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Pick image from camera or gallery
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        // Use the image storage service to save the image
        final String? savedPath = await ImageStorageService.saveReceiptImage(image);
        if (savedPath != null) {
          _receiptImagePath = savedPath;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  /// Remove selected image
  Future<void> removeImage() async {
    if (_receiptImagePath != null) {
      // Delete the actual file
      await ImageStorageService.deleteImage(_receiptImagePath!);
      _receiptImagePath = null;
      notifyListeners();
    }
  }

  /// Pick multiple images from gallery
  Future<void> pickMultipleImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        // Use the image storage service to save multiple images
        final List<String> savedPaths = await ImageStorageService.saveMultipleReceiptImages(images);
        _receiptImagePaths.addAll(savedPaths);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
    }
  }

  /// Remove image at specific index
  Future<void> removeImageAt(int index) async {
    if (index >= 0 && index < _receiptImagePaths.length) {
      // Delete the actual file
      await ImageStorageService.deleteImage(_receiptImagePaths[index]);
      _receiptImagePaths.removeAt(index);
      notifyListeners();
    }
  }

  /// Clear all images
  Future<void> clearAllImages() async {
    // Delete all actual files
    await ImageStorageService.deleteMultipleImages(_receiptImagePaths);
    _receiptImagePaths.clear();
    notifyListeners();
  }

  /// Validate form
  bool validateForm() {
    if (descriptionController.text.trim().isEmpty) {
      return false;
    }
    
    if (amountController.text.isEmpty) {
      return false;
    }
    
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      return false;
    }
    
    if (_selectedAccountId == null || _selectedAccountId!.isEmpty) {
      return false;
    }
    
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      return false;
    }
    
    return true;
  }

  /// Create transaction from form data
  Transaction createTransaction() {
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      accountId: _selectedAccountId!,
      categoryId: _selectedCategoryId!,
      subcategoryId: _selectedSubcategoryId,
      amount: double.parse(amountController.text),
      description: descriptionController.text.trim(),
      date: combinedDateTime,
      type: _selectedType,
      receiptImagePath: _receiptImagePath,
      receiptImagePaths: _receiptImagePaths,
      notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
    );
  }

  /// Update existing transaction
  Transaction updateTransaction(Transaction existingTransaction) {
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    return existingTransaction.copyWith(
      accountId: _selectedAccountId!,
      categoryId: _selectedCategoryId!,
      subcategoryId: _selectedSubcategoryId,
      amount: double.parse(amountController.text),
      description: descriptionController.text.trim(),
      date: combinedDateTime,
      type: _selectedType,
      receiptImagePath: _receiptImagePath,
      receiptImagePaths: _receiptImagePaths,
      notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
