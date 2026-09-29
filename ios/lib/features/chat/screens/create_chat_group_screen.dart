import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../services/chat_service.dart';

class CreateChatGroupScreen extends StatefulWidget {
  const CreateChatGroupScreen({super.key});

  @override
  State<CreateChatGroupScreen> createState() => _CreateChatGroupScreenState();
}

class _CreateChatGroupScreenState extends State<CreateChatGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  static const String _allDeptsOption = 'ALL Departments (College Wide)';
  static const String _allYearsOption = 'ALL Years';
  static const String _allSemsOption = 'ALL Semesters';
  static const String _allSecsOption = 'ALL Sections';

  late List<String> _deptOptions;
  late List<String> _yearOptions;
  late List<String> _semOptions;
  late List<String> _sectionOptions;

  late String _selectedBranch;
  late String _selectedYear;
  late String _selectedSemester;
  late String _selectedSection;

  bool _isLoading = false;
  Map<String, dynamic>? _creatorData;

  @override
  void initState() {
    super.initState();
    _deptOptions = [_allDeptsOption, ...AppStrings.departments];
    _yearOptions = [_allYearsOption, ...AppStrings.years];
    _semOptions = [_allSemsOption, ...AppStrings.semesters];
    _sectionOptions = [_allSecsOption, ...AppStrings.sections];

    _selectedBranch = _deptOptions.first;
    _selectedYear = _yearOptions.first;
    _selectedSemester = _semOptions.first;
    _selectedSection = _sectionOptions.first;

    _loadCreatorData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadCreatorData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      setState(() {
        _creatorData = doc.data();
        final depts = _creatorData?['departments'] as List<dynamic>?;
        if (depts != null && depts.isNotEmpty) {
          final firstDept = depts.first.toString();
          if (_deptOptions.contains(firstDept)) {
            _selectedBranch = firstDept;
          }
        }
      });
    }
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final name = _creatorData?['name'] ?? 'Faculty';
      final title = _creatorData?['title'] ?? 'Prof';
      final role = _creatorData?['role'] ?? 'teacher';

      final deptVal = _selectedBranch == _allDeptsOption ? 'ALL' : _selectedBranch;
      final yearVal = _selectedYear == _allYearsOption ? 'ALL' : _selectedYear;
      final semVal = _selectedSemester == _allSemsOption ? 'ALL' : _selectedSemester;
      final secVal = _selectedSection == _allSecsOption ? 'ALL' : _selectedSection;

      await ChatService.createGroup(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        createdByUid: user.uid,
        createdByName: name,
        createdByTitle: title,
        createdByRole: role,
        department: deptVal,
        year: yearVal,
        semester: semVal,
        section: secVal,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Discussion Group created! Eligible students can now see and join.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create group: $e'),
            backgroundColor: AppColors.error,
          ),
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
        title: const Text('👥 Create Batch Discussion Group'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.forum_rounded,
                          color: AppColors.secondary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Targeted Class Group',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Only students belonging to the chosen Branch, Year and Semester will be invited to participate.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Group Title
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                validator: (v) => v!.trim().isEmpty ? 'Enter group title' : null,
                decoration: const InputDecoration(
                  labelText: 'Group Title / Subject Name',
                  hintText: 'e.g. CSE 3rd Year (5th Sem) - OS Discussion',
                  prefixIcon: Icon(Icons.title_rounded, color: AppColors.secondary),
                ),
              ),

              const SizedBox(height: 8),

              // Quick subject suggestions
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _templateChip('💻 OS Discussion', 'Weekly doubts, assignments and theory queries for Operating Systems.'),
                    const SizedBox(width: 6),
                    _templateChip('🗄️ DBMS Queries', 'Database lab exercises, SQL queries, and normalization doubts.'),
                    const SizedBox(width: 6),
                    _templateChip('📡 Computer Networks', 'Protocols, routing algorithms, and networking assignments.'),
                    const SizedBox(width: 6),
                    _templateChip('🔬 Final Year Project', 'Major project coordination, synopsis, and presentation prep.'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Topic / Description (Optional)',
                  hintText: 'Rules: Respectful discussion, no message deletion.',
                  prefixIcon: Icon(Icons.description_rounded, color: AppColors.secondary),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'TARGET AUDIENCE',
                style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),

              // Branch
              _buildDropdown(
                label: 'Branch / Department',
                icon: Icons.category_rounded,
                value: _selectedBranch,
                items: _deptOptions,
                onChanged: (v) => setState(() => _selectedBranch = v!),
              ),

              const SizedBox(height: 14),

              // Year & Semester
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Semester',
                      icon: Icons.school_rounded,
                      value: _selectedSemester,
                      items: _semOptions,
                      onChanged: (v) => setState(() => _selectedSemester = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Section
              _buildDropdown(
                label: 'Section (Choose ALL or Specific)',
                icon: Icons.group_rounded,
                value: _selectedSection,
                items: _sectionOptions,
                onChanged: (v) => setState(() => _selectedSection = v!),
              ),

              const SizedBox(height: 20),

              // Security Rules Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.info.withOpacity(0.25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security_rounded, color: AppColors.info, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '🛡️ Anti-Tamper Policy: Students can reply and edit only within 60s. Deletion & forwarding are permanently blocked.',
                        style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_rounded),
                            SizedBox(width: 8),
                            Text(
                              'Create Group & Send Invitations',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
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

  Widget _templateChip(String title, String desc) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _titleController.text = title;
          _descController.text = desc;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
