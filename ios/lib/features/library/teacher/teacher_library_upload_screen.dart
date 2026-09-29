import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/library_resource_model.dart';
import '../services/library_service.dart';

class TeacherLibraryUploadScreen extends StatefulWidget {
  const TeacherLibraryUploadScreen({super.key});

  @override
  State<TeacherLibraryUploadScreen> createState() => _TeacherLibraryUploadScreenState();
}

class _TeacherLibraryUploadScreenState extends State<TeacherLibraryUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _urlController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedType = 'Lecture Notes';
  String _selectedDepartment = 'ALL';
  String _selectedYear = 'ALL';
  String _selectedSemester = 'ALL';
  bool _isLoading = false;

  // Selected file details
  PlatformFile? _pickedFile;
  String? _pdfBase64;
  String _fileSizeStr = '';

  final List<String> _types = [
    'Lecture Notes',
    'Lab Manual',
    'Question Bank',
    'Syllabus',
    'Reference Book',
  ];

  final List<String> _departments = ['ALL', ...AppStrings.departments];
  final List<String> _years = ['ALL', ...AppStrings.years];
  final List<String> _semesters = ['ALL', ...AppStrings.semesters];

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _urlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true, // For web/byte access
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Calculate file size string
        final sizeBytes = file.size;
        String formattedSize = '';
        if (sizeBytes < 1024) {
          formattedSize = '$sizeBytes B';
        } else if (sizeBytes < 1024 * 1024) {
          formattedSize = '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
        } else {
          formattedSize = '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }

        // Extract bytes
        List<int>? bytes = file.bytes;
        if (bytes == null && file.path != null) {
          bytes = await File(file.path!).readAsBytes();
        }

        String? b64;
        if (bytes != null) {
          // Firestore document limit is ~1MB. If file is under 800KB, we can embed it directly.
          if (bytes.length <= 800 * 1024) {
            b64 = base64Encode(bytes);
          } else {
            // Larger files: notify teacher or suggest link if storage bucket isn't configured
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('File size is $formattedSize. For best performance with large files, also provide a Google Drive / Web link.'),
                  backgroundColor: AppColors.warning,
                ),
              );
            }
          }
        }

        setState(() {
          _pickedFile = file;
          _pdfBase64 = b64;
          _fileSizeStr = formattedSize;
          if (_titleController.text.trim().isEmpty) {
            _titleController.text = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selection error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedFile == null && _urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please attach a PDF document or provide a resource link!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      String facultyName = 'Faculty';
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          facultyName = '${doc.data()?['title'] ?? 'Prof.'} ${doc.data()?['name'] ?? 'Faculty'}';
        }
      }

      final isPdf = _pickedFile != null
          ? _pickedFile!.name.toLowerCase().endsWith('.pdf')
          : _urlController.text.trim().toLowerCase().endsWith('.pdf');

      String finalResourceUrl = _urlController.text.trim();

      final res = LibraryResourceModel(
        id: '',
        title: _titleController.text.trim(),
        subject: _subjectController.text.trim(),
        department: _selectedDepartment,
        year: _selectedYear,
        semester: _selectedSemester,
        resourceType: _selectedType,
        description: _descController.text.trim(),
        resourceUrl: finalResourceUrl,
        fileType: isPdf ? 'PDF' : (_pickedFile != null ? 'DOC' : 'LINK'),
        fileName: _pickedFile?.name ?? '',
        fileSize: _fileSizeStr,
        pdfBase64: _pdfBase64,
        uploadedBy: facultyName,
        uploadedAt: DateTime.now(),
      );

      await LibraryService.uploadResource(res);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF Study Material published to Digital Library! 📚'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Publish Study Material',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.secondary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Digital Library Repository',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Upload lecture PDFs, lab manuals, or question banks for students with in-app preview and download.',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Document Attachment Box
              const Text('Attach PDF Document *',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDocument,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _pickedFile != null ? AppColors.secondary : Colors.white24,
                      width: _pickedFile != null ? 1.5 : 1,
                    ),
                  ),
                  child: _pickedFile == null
                      ? Column(
                          children: const [
                            Icon(Icons.cloud_upload_rounded, color: AppColors.secondary, size: 36),
                            SizedBox(height: 8),
                            Text('Click to browse and select PDF / Doc',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            SizedBox(height: 4),
                            Text('Supports PDF, DOC, DOCX files',
                                style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.secondary, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _pickedFile!.name,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _fileSizeStr.isNotEmpty ? 'Size: $_fileSizeStr • Ready' : 'Document attached',
                                    style: const TextStyle(color: AppColors.success, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.change_circle_rounded, color: AppColors.secondary),
                              tooltip: 'Change File',
                              onPressed: _pickDocument,
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                decoration: InputDecoration(
                  labelText: 'Document Title *',
                  hintText: 'e.g. Unit 1: Analysis of Algorithms',
                  prefixIcon: const Icon(Icons.title_rounded, color: AppColors.secondary, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 14),

              // Subject
              TextFormField(
                controller: _subjectController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? 'Subject is required' : null,
                decoration: InputDecoration(
                  labelText: 'Subject / Course Code *',
                  hintText: 'e.g. CS-501 Theory of Computation',
                  prefixIcon: const Icon(Icons.book_rounded, color: AppColors.secondary, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 14),

              // Resource Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: AppColors.surfaceVariant,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Resource Category *',
                  prefixIcon: const Icon(Icons.category_rounded, color: AppColors.secondary, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),

              const SizedBox(height: 14),

              // Target Branch & Year
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      dropdownColor: AppColors.surfaceVariant,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Department',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedDepartment = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedYear,
                      dropdownColor: AppColors.surfaceVariant,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Target Year',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (v) => setState(() => _selectedYear = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Semester Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                dropdownColor: AppColors.surfaceVariant,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Target Semester',
                  prefixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.secondary, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedSemester = v!),
              ),

              const SizedBox(height: 14),

              // Optional Cloud / Drive Link
              TextFormField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Web / Google Drive Link (Optional)',
                  hintText: 'https://drive.google.com/... or cloud PDF URL',
                  prefixIcon: const Icon(Icons.link_rounded, color: AppColors.secondary, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 14),

              // Description / Syllabus topics
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Overview / Chapter Topics (Optional)',
                  hintText: 'e.g. Covers Asymptotic notations, Recurrence relations, Master theorem...',
                  prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.secondary, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _upload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.publish_rounded),
                  label: Text(
                    _isLoading ? 'Publishing...' : 'Publish to Digital Library',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
