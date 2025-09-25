// File location: lib/core/services/export_service.dart
// Purpose: General export service for app data (transactions, reports, etc.)
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class ExportService {
  static const String _appName = 'koraexpensetracker';
  
  /// Get the main app export directory
  static Future<Directory> getAppExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDirectory = Directory('${directory.path}/$_appName');
    
    // Create directory if it doesn't exist
    if (!await appDirectory.exists()) {
      await appDirectory.create(recursive: true);
    }
    
    return appDirectory;
  }
  
  /// Get specific subdirectory for different export types
  static Future<Directory> getExportSubdirectory(String subdirectory) async {
    final appDirectory = await getAppExportDirectory();
    final subDir = Directory('${appDirectory.path}/$subdirectory');
    
    // Create subdirectory if it doesn't exist
    if (!await subDir.exists()) {
      await subDir.create(recursive: true);
    }
    
    return subDir;
  }
  
  /// Save file to app export directory
  static Future<String> saveFileToAppDirectory(
    Uint8List fileBytes, 
    String fileName, 
    {String? subdirectory}
  ) async {
    Directory targetDirectory;
    
    if (subdirectory != null) {
      targetDirectory = await getExportSubdirectory(subdirectory);
    } else {
      targetDirectory = await getAppExportDirectory();
    }
    
    final file = File('${targetDirectory.path}/$fileName');
    await file.writeAsBytes(fileBytes);
    return file.path;
  }
  
  /// Get available export directories
  static Future<List<String>> getAvailableExportDirectories() async {
    final appDirectory = await getAppExportDirectory();
    
    if (!await appDirectory.exists()) {
      return [];
    }
    
    final subdirectories = <String>[];
    await for (final entity in appDirectory.list()) {
      if (entity is Directory) {
        subdirectories.add(entity.path.split('/').last);
      }
    }
    
    return subdirectories;
  }
  
  /// Get files in a specific export directory
  static Future<List<FileSystemEntity>> getFilesInDirectory(String subdirectory) async {
    final directory = await getExportSubdirectory(subdirectory);
    
    if (!await directory.exists()) {
      return [];
    }
    
    return directory.list().toList();
  }
  
  /// Delete file from export directory
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Get file size in human readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Get file creation date
  static Future<DateTime?> getFileCreationDate(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.modified;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
