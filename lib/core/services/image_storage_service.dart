import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

/// Image Storage Service
/// Handles all image storage operations with proper folder structure
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class ImageStorageService {
  static const String _imagesFolderName = 'receipt_images';
  static const String _debtImagesFolderName = 'debt_images';
  
  /// Get the images directory for receipts
  static Future<Directory> getReceiptImagesDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDocDir.path}/$_imagesFolderName');
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    return imagesDir;
  }
  
  /// Get the images directory for debt/loan images
  static Future<Directory> getDebtImagesDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDocDir.path}/$_debtImagesFolderName');
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    return imagesDir;
  }
  
  /// Save a single receipt image
  static Future<String?> saveReceiptImage(XFile imageFile) async {
    try {
      final imagesDir = await getReceiptImagesDirectory();
      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${imagesDir.path}/$fileName';
      
      await imageFile.saveTo(filePath);
      return filePath;
    } catch (e) {
      print('Error saving receipt image: $e');
      return null;
    }
  }
  
  /// Save multiple receipt images
  static Future<List<String>> saveMultipleReceiptImages(List<XFile> imageFiles) async {
    final List<String> savedPaths = [];
    
    try {
      final imagesDir = await getReceiptImagesDirectory();
      
      for (int i = 0; i < imageFiles.length; i++) {
        final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final filePath = '${imagesDir.path}/$fileName';
        
        await imageFiles[i].saveTo(filePath);
        savedPaths.add(filePath);
      }
    } catch (e) {
      print('Error saving multiple receipt images: $e');
    }
    
    return savedPaths;
  }
  
  /// Save a debt/loan image
  static Future<String?> saveDebtImage(XFile imageFile) async {
    try {
      final imagesDir = await getDebtImagesDirectory();
      final fileName = 'debt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${imagesDir.path}/$fileName';
      
      await imageFile.saveTo(filePath);
      return filePath;
    } catch (e) {
      print('Error saving debt image: $e');
      return null;
    }
  }
  
  /// Save multiple debt/loan images
  static Future<List<String>> saveMultipleDebtImages(List<XFile> imageFiles) async {
    final List<String> savedPaths = [];
    
    try {
      final imagesDir = await getDebtImagesDirectory();
      
      for (int i = 0; i < imageFiles.length; i++) {
        final fileName = 'debt_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final filePath = '${imagesDir.path}/$fileName';
        
        await imageFiles[i].saveTo(filePath);
        savedPaths.add(filePath);
      }
    } catch (e) {
      print('Error saving multiple debt images: $e');
    }
    
    return savedPaths;
  }
  
  /// Delete an image file
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
  
  /// Delete multiple image files
  static Future<void> deleteMultipleImages(List<String> imagePaths) async {
    for (final path in imagePaths) {
      await deleteImage(path);
    }
  }
  
  /// Check if image file exists
  static Future<bool> imageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Get image file size in bytes
  static Future<int?> getImageFileSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Clean up orphaned images (images not referenced by any transaction/debt)
  static Future<void> cleanupOrphanedImages() async {
    // This would require checking all transactions and debts for referenced images
    // and deleting any images that are not referenced
    // Implementation would depend on your specific needs
  }
}
