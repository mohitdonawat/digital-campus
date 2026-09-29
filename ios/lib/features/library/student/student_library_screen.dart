import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_colors.dart';
import '../models/library_resource_model.dart';
import '../services/library_service.dart';
import '../shared/pdf_viewer_screen.dart';

class StudentLibraryScreen extends StatefulWidget {
  const StudentLibraryScreen({super.key});

  @override
  State<StudentLibraryScreen> createState() => _StudentLibraryScreenState();
}

class _StudentLibraryScreenState extends State<StudentLibraryScreen> {
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _downloadingIds = {};

  final List<String> _categories = [
    'ALL',
    'Lecture Notes',
    'Lab Manual',
    'Question Bank',
    'Syllabus',
    'Reference Book',
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          _studentData = doc.data();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openPdfViewer(LibraryResourceModel resource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          title: resource.title,
          url: resource.resourceUrl.isNotEmpty ? resource.resourceUrl : null,
          base64Data: resource.pdfBase64,
          fileName: resource.fileName.isNotEmpty ? resource.fileName : '${resource.title}.pdf',
        ),
      ),
    );
  }

  Future<void> _openExternalLink(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $url'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _downloadResource(LibraryResourceModel resource) async {
    setState(() => _downloadingIds.add(resource.id));

    try {
      Uint8List? bytes;

      if (resource.pdfBase64 != null && resource.pdfBase64!.isNotEmpty) {
        String cleanB64 = resource.pdfBase64!;
        if (cleanB64.contains(',')) {
          cleanB64 = cleanB64.split(',').last;
        }
        bytes = base64Decode(cleanB64);
      } else if (resource.resourceUrl.isNotEmpty) {
        final uri = Uri.tryParse(resource.resourceUrl);
        if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
          final res = await http.get(uri);
          if (res.statusCode == 200) {
            bytes = res.bodyBytes;
          }
        }
      }

      if (bytes == null) {
        if (resource.resourceUrl.isNotEmpty) {
          await _openExternalLink(resource.resourceUrl);
        } else {
          throw Exception('No downloadable content available for this resource.');
        }
        return;
      }

      final fileName = resource.fileName.isNotEmpty
          ? resource.fileName
          : '${resource.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf';

      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final file = File('${dir!.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded: $fileName'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'OPEN',
            textColor: Colors.white,
            onPressed: () => OpenFile.open(file.path),
          ),
        ),
      );

      await OpenFile.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _downloadingIds.remove(resource.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final branch = _studentData?['branch'] ?? 'CSE';
    final year = _studentData?['year'] ?? '3rd Year';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Digital Library & Notes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : Column(
              children: [
                // Search Input
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search notes, subjects, topics, or faculty...',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white54),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),

                // Category Chips
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondary : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.secondary : Colors.white10,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Resources Stream List
                Expanded(
                  child: StreamBuilder<List<LibraryResourceModel>>(
                    stream: LibraryService.getResources(department: branch, year: year),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                      }

                      var resources = snapshot.data ?? [];

                      if (_selectedCategory != 'ALL') {
                        resources = resources.where((r) => r.resourceType == _selectedCategory).toList();
                      }

                      if (_searchQuery.isNotEmpty) {
                        resources = resources.where((r) {
                          return r.title.toLowerCase().contains(_searchQuery) ||
                              r.subject.toLowerCase().contains(_searchQuery) ||
                              r.uploadedBy.toLowerCase().contains(_searchQuery) ||
                              r.description.toLowerCase().contains(_searchQuery);
                        }).toList();
                      }

                      if (resources.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.info, size: 40),
                                ),
                                const SizedBox(height: 16),
                                const Text('No Study Materials Found',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                const Text(
                                  'Lecture notes, PDFs, lab manuals, and syllabus uploaded by your faculty will appear here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: resources.length,
                        itemBuilder: (context, index) {
                          final r = resources[index];
                          final formattedDate = DateFormat('dd MMM, yyyy').format(r.uploadedAt);
                          final hasPdf = r.pdfBase64 != null || r.fileType == 'PDF' || r.resourceUrl.toLowerCase().endsWith('.pdf');
                          final isDownloading = _downloadingIds.contains(r.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppColors.cardGradient,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: hasPdf ? AppColors.secondary.withOpacity(0.3) : AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: hasPdf
                                            ? AppColors.secondary.withOpacity(0.15)
                                            : AppColors.info.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        hasPdf ? Icons.picture_as_pdf_rounded : Icons.link_rounded,
                                        color: hasPdf ? AppColors.secondary : AppColors.info,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${r.subject} • ${r.uploadedBy}',
                                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        r.resourceType,
                                        style: const TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                if (r.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    r.description,
                                    style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],

                                const SizedBox(height: 12),

                                // Footer: Date, File Info & Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Added: $formattedDate',
                                            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                                          ),
                                          if (r.fileSize.isNotEmpty)
                                            Text(
                                              'Size: ${r.fileSize}',
                                              style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w500),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Action Buttons: View PDF & Download
                                    if (hasPdf) ...[
                                      ElevatedButton.icon(
                                        onPressed: () => _openPdfViewer(r),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.secondary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        ),
                                        icon: const Icon(Icons.remove_red_eye_rounded, size: 14),
                                        label: const Text('Read PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: isDownloading ? null : () => _downloadResource(r),
                                        icon: isDownloading
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                                              )
                                            : const Icon(Icons.download_rounded, color: AppColors.secondary, size: 20),
                                        tooltip: 'Download File',
                                        style: IconButton.styleFrom(
                                          backgroundColor: AppColors.surfaceVariant,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ] else if (r.resourceUrl.isNotEmpty) ...[
                                      ElevatedButton.icon(
                                        onPressed: () => _openExternalLink(r.resourceUrl),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        ),
                                        icon: const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.secondary),
                                        label: const Text('Open Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
