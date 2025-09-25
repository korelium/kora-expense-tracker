// File location: lib/presentation/screens/export/export_manager_screen.dart
// Purpose: Export manager screen to view and manage exported files
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/export_service.dart';

/// Export manager screen for viewing and managing exported files
class ExportManagerScreen extends StatefulWidget {
  const ExportManagerScreen({super.key});

  @override
  State<ExportManagerScreen> createState() => _ExportManagerScreenState();
}

class _ExportManagerScreenState extends State<ExportManagerScreen> {
  List<String> _exportDirectories = [];
  String? _selectedDirectory;
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExportDirectories();
  }

  Future<void> _loadExportDirectories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final directories = await ExportService.getAvailableExportDirectories();
      setState(() {
        _exportDirectories = directories;
        if (directories.isNotEmpty) {
          _selectedDirectory = directories.first;
        }
      });
      
      if (_selectedDirectory != null) {
        await _loadFilesInDirectory(_selectedDirectory!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading export directories: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFilesInDirectory(String directory) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await ExportService.getFilesInDirectory(directory);
      setState(() {
        _files = files;
        _selectedDirectory = directory;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Manager'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadExportDirectories,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDirectorySelector(),
                Expanded(
                  child: _files.isEmpty
                      ? _buildEmptyState()
                      : _buildFilesList(),
                ),
              ],
            ),
    );
  }

  Widget _buildDirectorySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedDirectory,
              hint: const Text('Select export directory'),
              isExpanded: true,
              items: _exportDirectories.map((directory) {
                return DropdownMenuItem(
                  value: directory,
                  child: Text(_getDirectoryDisplayName(directory)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _loadFilesInDirectory(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No files found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Export some files to see them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        return _buildFileItem(file);
      },
    );
  }

  Widget _buildFileItem(FileSystemEntity file) {
    final fileName = file.path.split('/').last;
    final isDirectory = file is Directory;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isDirectory ? Icons.folder : _getFileIcon(fileName),
          color: isDirectory ? Colors.blue : _getFileColor(fileName),
        ),
        title: Text(
          fileName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: isDirectory
            ? const Text('Directory')
            : FutureBuilder<DateTime?>(
                future: ExportService.getFileCreationDate(file.path),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'Modified: ${DateFormat('MMM dd, yyyy HH:mm').format(snapshot.data!)}',
                    );
                  }
                  return const Text('Unknown date');
                },
              ),
        trailing: isDirectory
            ? const Icon(Icons.chevron_right)
            : PopupMenuButton<String>(
                onSelected: (value) => _handleFileAction(value, file),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'open',
                    child: ListTile(
                      leading: Icon(Icons.open_in_new),
                      title: Text('Open'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Share'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert),
              ),
        onTap: isDirectory
            ? () => _loadFilesInDirectory(file.path.split('/').last)
            : () => _handleFileAction('open', file),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'csv':
        return Icons.table_chart;
      case 'json':
        return Icons.code;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'csv':
        return Colors.green;
      case 'json':
        return Colors.orange;
      case 'txt':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getDirectoryDisplayName(String directory) {
    switch (directory) {
      case 'creditcardbills':
        return 'Credit Card Bills';
      case 'reports':
        return 'Financial Reports';
      case 'transactions':
        return 'Transaction Exports';
      case 'backups':
        return 'App Backups';
      default:
        return directory.replaceAll('_', ' ').toUpperCase();
    }
  }

  Future<void> _handleFileAction(String action, FileSystemEntity file) async {
    switch (action) {
      case 'open':
        // TODO: Implement file opening based on file type
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File opening not implemented yet')),
        );
        break;
      case 'share':
        // TODO: Implement file sharing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File sharing not implemented yet')),
        );
        break;
      case 'delete':
        await _deleteFile(file);
        break;
    }
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.path.split('/').last}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ExportService.deleteFile(file.path);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the file list
          if (_selectedDirectory != null) {
            await _loadFilesInDirectory(_selectedDirectory!);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
