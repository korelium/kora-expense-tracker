import 'package:flutter/material.dart';
import 'dart:io';

/// Receipt Image Picker Widget
/// Provides image selection and preview for receipts
/// Author: Pown Kumar - Founder of Korelium
/// Date: September 18, 2025

class ReceiptImagePicker extends StatelessWidget {
  final String? receiptImagePath;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const ReceiptImagePicker({
    super.key,
    required this.receiptImagePath,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt Image (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        if (receiptImagePath != null) ...[
          // Show selected image
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    File(receiptImagePath!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onRemoveImage,
                        icon: const Icon(Icons.close, color: Colors.white),
                        iconSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Add/Change image button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onPickImage,
            icon: Icon(receiptImagePath != null ? Icons.change_circle : Icons.add_photo_alternate),
            label: Text(receiptImagePath != null ? 'Change Receipt' : 'Add Receipt Photo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
