import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/live_class_model.dart';
import '../services/live_class_service.dart';

class TeacherScheduleClassScreen extends StatefulWidget {
  final LiveClassModel? classToEdit;

  const TeacherScheduleClassScreen({super.key, this.classToEdit});

  @override
  State<TeacherScheduleClassScreen> createState() => _TeacherScheduleClassScreenState();
}

class _TeacherScheduleClassScreenState extends State<TeacherScheduleClassScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;
  late TextEditingController _meetingUrlController;
  late TextEditingController _recordingUrlController;

  String _selectedPlatform = 'youtube';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _durationMinutes = 60;

  // Targeting filters
  String _targetBranch = 'ALL';
  String _targetYear = 'ALL';
  String _targetSemester = 'ALL';
  String _targetSection = 'ALL';

  bool _isLoading = false;
  Map<String, dynamic>? _teacherProfile;

  bool get _isEditing => widget.classToEdit != null;

  @override
  void initState() {
    super.initState();
    final c = widget.classToEdit;
    _titleController = TextEditingController(text: c?.title ?? '');
    _subjectController = TextEditingController(text: c?.subject ?? '');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _meetingUrlController = TextEditingController(text: c?.meetingUrl ?? '');
    _recordingUrlController = TextEditingController(text: c?.recordingUrl ?? '');

    if (c != null) {
      _selectedPlatform = c.platform;
      _selectedDate = c.scheduledStartTime;
      _selectedTime = TimeOfDay.fromDateTime(c.scheduledStartTime);
      _durationMinutes = c.durationMinutes;
      _targetBranch = c.targetBranch;
      _targetYear = c.targetYear;
      _targetSemester = c.targetSemester;
      _targetSection = c.targetSection;
    } else {
      // Default scheduled time to 15 mins in future rounded to next 5 min
      final now = DateTime.now().add(const Duration(minutes: 15));
      _selectedDate = now;
      _selectedTime = TimeOfDay(hour: now.hour, minute: (now.minute ~/ 5) * 5);
    }

    _loadTeacherProfile();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _meetingUrlController.dispose();
    _recordingUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      setState(() {
        _teacherProfile = doc.data();
      });
    }
  }

  void _generateJitsiRoom() {
    final randomKey = const Uuid().v4().substring(0, 8);
    final subjectCode = _subjectController.text.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final prefix = subjectCode.isNotEmpty ? subjectCode : 'Class';
    final room = 'https://meet.jit.si/IES_${prefix}_$randomKey';
    setState(() {
      _selectedPlatform = 'jitsi';
      _meetingUrlController.text = room;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ 100% Free Jitsi Classroom Room Link generated!'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondary,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondary,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;

    if (_meetingUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a live class link or generate a free Jitsi room.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final user = FirebaseAuth.instance.currentUser;
      final teacherUid = user?.uid ?? 'unknown';
      final teacherName = _teacherProfile?['name'] ?? user?.displayName ?? 'Faculty';
      final teacherTitle = _teacherProfile?['title'] ?? 'Prof.';
      final teacherDept = _teacherProfile?['department'] ?? 'CSE';

      if (_isEditing) {
        await LiveClassService.updateLiveClass(
          id: widget.classToEdit!.id,
          title: _titleController.text.trim(),
          subject: _subjectController.text.trim(),
          description: _descriptionController.text.trim(),
          platform: _selectedPlatform,
          meetingUrl: _meetingUrlController.text.trim(),
          scheduledStartTime: scheduledDateTime,
          durationMinutes: _durationMinutes,
          targetBranch: _targetBranch,
          targetYear: _targetYear,
          targetSemester: _targetSemester,
          targetSection: _targetSection,
          recordingUrl: _recordingUrlController.text.trim().isNotEmpty ? _recordingUrlController.text.trim() : null,
        );
      } else {
        await LiveClassService.scheduleLiveClass(
          title: _titleController.text.trim(),
          subject: _subjectController.text.trim(),
          description: _descriptionController.text.trim(),
          teacherUid: teacherUid,
          teacherName: teacherName,
          teacherTitle: teacherTitle,
          teacherDepartment: teacherDept,
          platform: _selectedPlatform,
          meetingUrl: _meetingUrlController.text.trim(),
          scheduledStartTime: scheduledDateTime,
          durationMinutes: _durationMinutes,
          targetBranch: _targetBranch,
          targetYear: _targetYear,
          targetSemester: _targetSemester,
          targetSection: _targetSection,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Class updated successfully!' : 'Class scheduled successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving class: $e'), backgroundColor: AppColors.error),
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Live Class' : 'Schedule Live Class',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EdTech banner hint
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.podcasts_rounded, color: AppColors.secondary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Free & Unlimited Live Streaming',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Use YouTube Live (Free HD stream) or Jitsi Meet (Free interactive room with 0 server cost).',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 1: Basic Information
                    const Text('Class Details',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),

                    // Subject Input
                    TextFormField(
                      controller: _subjectController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        label: 'Subject / Course *',
                        hint: 'e.g. Data Structures & Algorithms, TOC',
                        icon: Icons.menu_book_rounded,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter subject name' : null,
                    ),

                    const SizedBox(height: 12),

                    // Title Input
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        label: 'Class Topic / Title *',
                        hint: 'e.g. Unit 3: Graph Traversal & Dijkstra Algorithm',
                        icon: Icons.title_rounded,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter class title' : null,
                    ),

                    const SizedBox(height: 12),

                    // Description / Agenda
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        label: 'Class Agenda / Description (Optional)',
                        hint: 'Important topics covered, prerequisites, or preparation notes...',
                        icon: Icons.description_outlined,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Platform & Meeting Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Live Stream Platform',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        // 1-Click Free Jitsi Room Generator
                        TextButton.icon(
                          onPressed: _generateJitsiRoom,
                          icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF8B5CF6), size: 16),
                          label: const Text(
                            '⚡ Free Room',
                            style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Platform Selector Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _platformChip('youtube', 'YouTube Live', const Color(0xFFEF4444), Icons.ondemand_video_rounded),
                          const SizedBox(width: 8),
                          _platformChip('jitsi', 'Jitsi (100% Free)', const Color(0xFF8B5CF6), Icons.group_work_rounded),
                          const SizedBox(width: 8),
                          _platformChip('meet', 'Google Meet', const Color(0xFF10B981), Icons.video_camera_front_rounded),
                          const SizedBox(width: 8),
                          _platformChip('zoom', 'Zoom', const Color(0xFF38BDF8), Icons.videocam_rounded),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Meeting / Stream URL Input
                    TextFormField(
                      controller: _meetingUrlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        label: 'Meeting / Live Stream URL *',
                        hint: _selectedPlatform == 'youtube'
                            ? 'https://youtube.com/live/... or unlisted stream link'
                            : _selectedPlatform == 'jitsi'
                                ? 'https://meet.jit.si/IES_Class_...'
                                : 'Meeting link (Google Meet / Zoom / URL)',
                        icon: Icons.link_rounded,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter meeting/stream URL' : null,
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _recordingUrlController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Recording Link (For Completed Lecture)',
                          hint: 'YouTube recording / Drive link',
                          icon: Icons.video_library_rounded,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Section 3: Schedule Date & Time
                    const Text('Date, Time & Duration',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // Date picker button
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, color: AppColors.secondary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd MMM yyyy').format(_selectedDate),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Time picker button
                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, color: AppColors.secondary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedTime.format(context),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Duration Chips
                    Row(
                      children: [
                        const Text('Duration:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(width: 10),
                        ...[45, 60, 90, 120].map((mins) {
                          final isSelected = _durationMinutes == mins;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('$mins m'),
                              selected: isSelected,
                              selectedColor: AppColors.secondary,
                              backgroundColor: AppColors.surface,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              onSelected: (_) => setState(() => _durationMinutes = mins),
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section 4: Target Audience Filtering (PW / Batch Filter)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.filter_alt_rounded, color: AppColors.secondary, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Target Audience (Batch Filter)',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Only students matching this filter will see the class in their feed.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 14),

                          // Branch & Year row
                          Row(
                            children: [
                              // Branch
                              Expanded(
                                child: _dropdownField(
                                  label: 'Branch / Dept',
                                  value: _targetBranch,
                                  items: ['ALL', ...AppStrings.departmentShort],
                                  onChanged: (val) => setState(() => _targetBranch = val ?? 'ALL'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Year
                              Expanded(
                                child: _dropdownField(
                                  label: 'Year',
                                  value: _targetYear,
                                  items: ['ALL', ...AppStrings.years],
                                  onChanged: (val) => setState(() => _targetYear = val ?? 'ALL'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Semester & Section row
                          Row(
                            children: [
                              // Semester
                              Expanded(
                                child: _dropdownField(
                                  label: 'Semester',
                                  value: _targetSemester,
                                  items: ['ALL', ...AppStrings.semesters],
                                  onChanged: (val) => setState(() => _targetSemester = val ?? 'ALL'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Section
                              Expanded(
                                child: _dropdownField(
                                  label: 'Section',
                                  value: _targetSection,
                                  items: ['ALL', ...AppStrings.sections],
                                  onChanged: (val) => setState(() => _targetSection = val ?? 'ALL'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saveClass,
                        icon: Icon(_isEditing ? Icons.check_circle_rounded : Icons.schedule_send_rounded),
                        label: Text(
                          _isEditing ? 'Update Live Class' : 'Schedule Live Class',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.black,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _platformChip(String id, String label, Color color, IconData icon) {
    final isSelected = _selectedPlatform == id;
    return InkWell(
      onTap: () => setState(() => _selectedPlatform = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textSecondary, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      items: items.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
      prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
    );
  }
}
