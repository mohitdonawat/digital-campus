import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Reusable passport photo widget that seamlessly renders:
/// 1. Base64 strings (stored in Firestore on free-tier)
/// 2. Remote HTTP URLs
/// 3. Fallback placeholder with camera prompt
class StudentPhotoWidget extends StatelessWidget {
  final String? photoUrlOrBase64;
  final double width;
  final double height;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const StudentPhotoWidget({
    super.key,
    required this.photoUrlOrBase64,
    this.width = 100,
    this.height = 120,
    this.borderRadius = 8,
    this.onTap,
    this.showEditBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImageContent();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: const Color(0xFFD97706), width: 1.8), // Gold/Amber border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 1),
              child: imageWidget,
            ),
          ),
          if (showEditBadge)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    final raw = photoUrlOrBase64?.trim() ?? '';
    if (raw.isEmpty) {
      return _buildPlaceholder();
    }

    // Check if Base64 Data URI or raw Base64
    if (raw.startsWith('data:image') || !raw.startsWith('http')) {
      try {
        String base64Clean = raw;
        if (raw.contains(',')) {
          base64Clean = raw.split(',').last;
        }
        final Uint8List bytes = base64Decode(base64Clean);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (_) {
        return _buildPlaceholder();
      }
    }

    // Remote HTTP Image
    return Image.network(
      raw,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFF1E293B),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1E293B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_rounded, size: width * 0.45, color: Colors.white38),
          const SizedBox(height: 4),
          Text(
            'PHOTO',
            style: TextStyle(
              fontSize: width * 0.09,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
