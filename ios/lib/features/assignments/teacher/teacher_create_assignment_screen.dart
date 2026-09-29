import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/assignment_model.dart';
import '../services/assignment_service.dart';

class TeacherCreateAssignmentScreen extends StatefulWidget {
  const TeacherCreateAssignmentScreen({super.key});

  @override
  State<TeacherCreateAssignmentScreen> createState() => _TeacherCreateAssignmentScreenState();
}

class _TeacherCreateAssignmentScreenState extends State<TeacherCreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  final _marksController = TextEditingController(text: '20');
  final _attachmentUrlController = TextEditingController();

  String _selectedBranch = 'ALL';
  String _selectedYear = 'ALL';
  String _selectedSection = 'ALL';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  final List<String> _branches = ['ALL', ...AppStrings.departments];
  final List<String> _years = ['ALL', ...AppStrings.years];
  final List<String> _sections = ['ALL', 'A', 'B', 'C', 'D'];

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descController.dispose();
    _marksController.dispose();
    _attachmentUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      String teacherName = 'Faculty';
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          teacherName = '${doc.data()?['title'] ?? 'Prof.'} ${doc.data()?['name'] ?? 'Faculty'}';
        }
      }

      final assignment = AssignmentModel(
        id: '',
        title: _titleController.text.trim(),
        subject: _subjectController.text.trim(),
        description: _descController.text.trim(),
        teacherUid: user?.uid ?? 'teacher_uid',
        teacherName: teacherName,
        targetBranch: _selectedBranch,
        targetYear: _selectedYear,
        targetSection: _selectedSection,
        dueDate: _dueDate,
        createdAt: DateTime.now(),
        totalMarks: int.tryParse(_marksController.text.trim()) ?? 20,
        attachmentUrl: _attachmentUrlController.text.trim().isEmpty
            ? null
            : _attachmentUrlController.text.trim(),
      );

      await AssignmentService.createAssignment(assignment);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment created and notified to targeted batch! 🚀'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDue = DateFormat('dd MMMM, yyyy').format(_dueDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create New Assignment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? 'Title required' : null,
                decoration: InputDecoration(
                  labelText: 'Assignment Title *',
                  hintText: 'e.g. Design Pattern Implementation & Analysis',
                  prefixIcon: const Icon(Icons.assignment_rounded, color: AppColors.secondary),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subjectController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Subject required' : null,
                      decoration: InputDecoration(
                        labelText: 'Subject *',
                        hintText: 'e.g. CS-402 OOD',
                        prefixIcon: const Icon(Icons.book_rounded, color: AppColors.secondary),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    child: TextFormField(
                      controller: _marksController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Required' : null,
                      decoration: InputDecoration(
                        labelText: 'Marks *',
                        prefixIcon: const Icon(Icons.stars_rounded, color: AppColors.secondary),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? 'Instructions required' : null,
                decoration: InputDecoration(
                  labelText: 'Assignment Details & Guidelines *',
                  hintText: 'Detailed requirements, problem statement, or submission link requirements...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _attachmentUrlController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Assignment PDF / Question Paper Link (Optional)',
                  hintText: 'Paste Google Drive, Cloud PDF, or GitHub link...',
                  prefixIcon: const Icon(Icons.link_rounded, color: AppColors.secondary),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Targeting Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Batch & Section',
                      style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: _selectedBranch,
                      dropdownColor: AppColors.surfaceVariant,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Target Branch / Department',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (v) => setState(() => _selectedBranch = v!),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _selectedYear,
                            dropdownColor: AppColors.surfaceVariant,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Target Year',
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                            items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                            onChanged: (v) => setState(() => _selectedYear = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedSection,
                            dropdownColor: AppColors.surfaceVariant,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Section',
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                            items: _sections.map((s) => DropdownMenuItem(value: s, child: Text('Sec $s'))).toList(),
                            onChanged: (v) => setState(() => _selectedSection = v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Due Date Picker Tile
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_rounded, color: AppColors.warning),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Submission Deadline', style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                            Text(formattedDue, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _pickDueDate,
                      child: const Text('Change Date', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _publish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isLoading ? 'Publishing...' : 'Assign to Batch',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
