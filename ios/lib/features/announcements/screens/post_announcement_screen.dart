import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../services/announcement_service.dart';

class PostAnnouncementScreen extends StatefulWidget {
  final bool isAdmin;
  const PostAnnouncementScreen({super.key, this.isAdmin = false});

  @override
  State<PostAnnouncementScreen> createState() => _PostAnnouncementScreenState();
}

class _PostAnnouncementScreenState extends State<PostAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _linkController = TextEditingController();

  String _selectedBranch = 'ALL';
  String _selectedYear = 'ALL';
  String _selectedSemester = 'ALL';
  String _selectedSection = 'ALL';
  String _selectedPriority = 'NORMAL';

  File? _attachedFile;
  String? _attachedFileName;
  int? _attachedFileSize;

  bool _isPublishing = false;
  Map<String, dynamic>? _authorData;

  final _branchOptions = ['ALL', ...AppStrings.departments];
  final _yearOptions = ['ALL', ...AppStrings.years];
  final _semesterOptions = ['ALL', ...AppStrings.semesters];
  final _sectionOptions = ['ALL', ...AppStrings.sections];
  final _priorityOptions = ['NORMAL', 'IMPORTANT', 'URGENT'];

  @override
  void initState() {
    super.initState();
    _loadAuthorData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthorData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      setState(() {
        _authorData = doc.data();
        if (!widget.isAdmin) {
          final depts = _authorData?['departments'] as List<dynamic>?;
          if (depts != null && depts.isNotEmpty) {
            _selectedBranch = depts.first.toString();
          }
        }
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _attachedFile = File(result.files.single.path!);
          _attachedFileName = result.files.single.name;
          _attachedFileSize = result.files.single.size;
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

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPublishing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final name = _authorData?['name'] ?? 'Faculty';
      final title = _authorData?['title'] ?? 'Prof';
      final role = widget.isAdmin ? 'admin' : (_authorData?['role'] ?? 'teacher');

      await AnnouncementService.postAnnouncement(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        linkUrl: _linkController.text.trim(),
        attachmentFile: _attachedFile,
        attachmentOriginalName: _attachedFileName,
        authorUid: user.uid,
        authorName: name,
        authorTitle: title,
        authorRole: role,
        targetBranch: _selectedBranch,
        targetYear: _selectedYear,
        targetSemester: _selectedSemester,
        targetSection: _selectedSection,
        priority: _selectedPriority,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📢 Announcement published successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publishing failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📢 Publish Announcement'),
        backgroundColor: AppColors.surface,
        actions: [
          if (!_isPublishing)
            TextButton.icon(
              onPressed: _publish,
              icon: const Icon(Icons.send_rounded, color: AppColors.secondary),
              label: const Text('Publish',
                  style: TextStyle(
                      color: AppColors.secondary, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Priority Bar
              Row(
                children: [
                  const Text('PRIORITY: ',
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 6,
                    children: _priorityOptions.map((p) {
                      final isSel = _selectedPriority == p;
                      final Color col = p == 'URGENT'
                          ? AppColors.error
                          : p == 'IMPORTANT'
                              ? AppColors.warning
                              : AppColors.info;
                      return ChoiceChip(
                        label: Text(p),
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedPriority = p),
                        selectedColor: col,
                        labelStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : AppColors.textSecondary),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                validator: (v) => v!.trim().isEmpty ? 'Enter notice title' : null,
                decoration: const InputDecoration(
                  labelText: 'Notice Title',
                  hintText: 'e.g. Mid-Sem Exam Datesheet Announced',
                  prefixIcon: Icon(Icons.campaign_rounded, color: AppColors.secondary),
                ),
              ),

              const SizedBox(height: 16),

              // Message Body
              TextFormField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                validator: (v) => v!.trim().isEmpty ? 'Enter notice description' : null,
                decoration: const InputDecoration(
                  labelText: 'Notice Message / Details',
                  hintText: 'Explain the guidelines or details clearly for students...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              // External Link
              TextFormField(
                controller: _linkController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Attachment Link / URL (Optional)',
                  hintText: 'e.g. https://drive.google.com/... or college link',
                  prefixIcon: Icon(Icons.link_rounded, color: Color(0xFF60A5FA)),
                ),
              ),

              const SizedBox(height: 20),

              // PDF / File Attachment Picker
              const Text('FILE / PDF ATTACHMENT',
                  style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _attachedFile != null
                          ? AppColors.success.withOpacity(0.5)
                          : AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _attachedFile != null
                              ? AppColors.success.withOpacity(0.15)
                              : AppColors.secondary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _attachedFile != null
                              ? Icons.picture_as_pdf_rounded
                              : Icons.attach_file_rounded,
                          color: _attachedFile != null
                              ? AppColors.success
                              : AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _attachedFileName ?? 'Attach PDF Document or Image',
                              style: TextStyle(
                                  color: _attachedFile != null
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: _attachedFile != null
                                      ? FontWeight.w600
                                      : FontWeight.normal),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_attachedFileSize != null)
                              Text(
                                '${(_attachedFileSize! / (1024 * 1024)).toStringAsFixed(2)} MB',
                                style: const TextStyle(
                                    color: AppColors.textHint, fontSize: 10),
                              ),
                          ],
                        ),
                      ),
                      if (_attachedFile != null)
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.error),
                          onPressed: () => setState(() {
                            _attachedFile = null;
                            _attachedFileName = null;
                            _attachedFileSize = null;
                          }),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Target Filters
              const Text('TARGET AUDIENCE FILTER',
                  style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),

              _buildDropdown(
                label: 'Target Branch (Choose ALL or Specific)',
                icon: Icons.category_rounded,
                value: _selectedBranch,
                items: _branchOptions,
                onChanged: (v) => setState(() => _selectedBranch = v!),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Year',
                      icon: Icons.calendar_today_rounded,
                      value: _selectedYear,
                      items: _yearOptions,
                      onChanged: (v) => setState(() => _selectedYear = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Semester',
                      icon: Icons.school_rounded,
                      value: _selectedSemester,
                      items: _semesterOptions,
                      onChanged: (v) => setState(() => _selectedSemester = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildDropdown(
                label: 'Section',
                icon: Icons.group_rounded,
                value: _selectedSection,
                items: _sectionOptions,
                onChanged: (v) => setState(() => _selectedSection = v!),
              ),

              const SizedBox(height: 32),

              // Publish Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isPublishing ? null : _publish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isPublishing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded),
                            SizedBox(width: 8),
                            Text('Publish Notice to Students',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      dropdownColor: AppColors.surfaceVariant,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 18),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ))
          .toList(),
    );
  }
}
