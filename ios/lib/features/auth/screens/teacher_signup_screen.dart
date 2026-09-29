import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../models/teacher_model.dart';

class TeacherSignupScreen extends StatefulWidget {
  const TeacherSignupScreen({super.key});

  @override
  State<TeacherSignupScreen> createState() => _TeacherSignupScreenState();
}

class _TeacherSignupScreenState extends State<TeacherSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _subjectInputController = TextEditingController();

  // Selections
  String _selectedTitle = 'Mr';
  String _selectedDesignation = 'Assistant Professor';
  List<String> _selectedDepartments = [];
  List<String> _selectedYears = [];
  List<String> _addedSubjects = [];

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const List<String> _titles = ['Mr', 'Mrs', 'Ms', 'Dr', 'Prof'];
  static const List<String> _designations = [
    'Professor',
    'Associate Professor',
    'Assistant Professor',
    'Lecturer',
    'Lab Instructor',
    'HOD',
    'Principal',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    _subjectInputController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_selectedDepartments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 1 department'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_selectedYears.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 1 year'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final teacher = TeacherModel(
        uid: cred.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        title: _selectedTitle,
        departments: _selectedDepartments,
        years: _selectedYears,
        subjects: _addedSubjects,
        employeeId: _employeeIdController.text.trim(),
        designation: _selectedDesignation,
        isApproved: false, // Needs admin approval
        role: 'teacher',
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set(teacher.toMap());

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.teacherPendingApproval);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'configuration-not-found' || e.code.contains('config')) {
        _showConfigErrorDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Signup failed'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showConfigErrorDialog();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConfigErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.secondary),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Firebase Setup Notice',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Firebase Authentication Email/Password provider is not enabled in Firebase Console yet.\n\n'
          '📌 To enable Cloud Sync:\n'
          '1. Go to Firebase Console\n'
          '2. Authentication > Sign-in method\n'
          '3. Enable "Email/Password" and Save.\n\n'
          'Would you like to continue in Demo Mode to preview your teacher registration?',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final tempUid = 'teacher_${DateTime.now().millisecondsSinceEpoch}';
              final teacher = TeacherModel(
                uid: tempUid,
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim(),
                title: _selectedTitle,
                departments: _selectedDepartments,
                years: _selectedYears,
                subjects: _addedSubjects,
                employeeId: _employeeIdController.text.trim(),
                designation: _selectedDesignation,
                isApproved: false,
                role: 'teacher',
                createdAt: DateTime.now(),
              );
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(tempUid)
                    .set(teacher.toMap());
              } catch (e) {
                debugPrint('Firestore offline notice: $e');
              }
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.teacherPendingApproval);
            },
            child: const Text(
              'Continue in Demo Mode',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Teacher Registration',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                            Text(AppStrings.collegeFullName,
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.secondary, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.webp',
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: List.generate(3, (i) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _currentPage ? AppColors.secondary : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ['Personal Info', 'Teaching Details', 'Security'][_currentPage],
                        style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text('Step ${_currentPage + 1} of 3',
                        style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    children: [
                      _buildPage1(),
                      _buildPage2(),
                      _buildPage3(),
                    ],
                  ),
                ),

                // Buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      if (_currentPage > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_currentPage == 2 ? 'Submit Application' : 'Next →'),
                        ),
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.teacherLogin),
                  child: const Text('Already registered? Login',
                    style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _signup();
    }
  }

  // ─── Page 1: Personal Info ───────────────────────────────────────────────
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Name Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 90,
                child: DropdownButtonFormField<String>(
                  value: _selectedTitle,
                  onChanged: (v) => setState(() => _selectedTitle = v!),
                  dropdownColor: AppColors.surfaceVariant,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  items: _titles.map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t, style: const TextStyle(color: Colors.white)),
                  )).toList(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(_nameController, 'Full Name', Icons.person_rounded,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildField(_emailController, 'Email Address', Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => !v!.contains('@') ? 'Invalid email' : null),

          const SizedBox(height: 16),

          _buildField(_phoneController, 'Phone Number', Icons.phone_rounded,
            keyboardType: TextInputType.phone),

          const SizedBox(height: 16),

          _buildField(
            _employeeIdController,
            'Employee ID / Faculty Code',
            Icons.badge_rounded,
            hintText: 'e.g. IES-FAC-1042 or EMP-101',
            helperText: 'Official College Faculty / Employee ID',
            textCapitalization: TextCapitalization.characters,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Employee ID is required';
              if (v.trim().length < 3) return 'Enter a valid Employee ID (min 3 chars)';
              return null;
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedDesignation,
            onChanged: (v) => setState(() => _selectedDesignation = v!),
            dropdownColor: AppColors.surfaceVariant,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Designation',
              prefixIcon: const Icon(Icons.work_rounded, color: AppColors.secondary, size: 20),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
              ),
            ),
            items: _designations.map((d) => DropdownMenuItem(
              value: d,
              child: Text(d, style: const TextStyle(color: Colors.white)),
            )).toList(),
          ),

          const SizedBox(height: 16),

          // College (read-only)
          _buildReadOnlyField('College', AppStrings.collegeName, Icons.school_rounded),
          const SizedBox(height: 8),
          _buildReadOnlyField('University', AppStrings.universityFull, Icons.account_balance_rounded),
        ],
      ),
    );
  }

  // ─── Page 2: Teaching Details ─────────────────────────────────────────────
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department Multi-select
          const Text('Select Departments You Teach',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _buildMultiSelectChips(
            items: AppStrings.departments,
            selected: _selectedDepartments,
            color: AppColors.info,
            onToggle: (dept) => setState(() {
              _selectedDepartments.contains(dept)
                ? _selectedDepartments.remove(dept)
                : _selectedDepartments.add(dept);
            }),
          ),

          if (_selectedDepartments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('* Select at least 1 department',
                style: TextStyle(color: AppColors.error, fontSize: 11)),
            ),

          const SizedBox(height: 24),

          // Year Multi-select
          const Text('Years You Teach',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _buildMultiSelectChips(
            items: AppStrings.years,
            selected: _selectedYears,
            color: AppColors.success,
            onToggle: (year) => setState(() {
              _selectedYears.contains(year)
                ? _selectedYears.remove(year)
                : _selectedYears.add(year);
            }),
          ),

          if (_selectedYears.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('* Select at least 1 year',
                style: TextStyle(color: AppColors.error, fontSize: 11)),
            ),

          const SizedBox(height: 24),

          // Subjects — add one by one
          const Text('Subjects You Teach',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _subjectInputController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. Data Structures',
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onFieldSubmitted: (_) => _addSubject(),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: _addSubject,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_addedSubjects.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _addedSubjects.map((s) => Chip(
                label: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
                onDeleted: () => setState(() => _addedSubjects.remove(s)),
                backgroundColor: AppColors.primary.withOpacity(0.5),
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              )).toList(),
            )
          else
            const Text('No subjects added yet',
              style: TextStyle(color: AppColors.textHint, fontSize: 12)),
        ],
      ),
    );
  }

  // ─── Page 3: Security + Summary ───────────────────────────────────────────
  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Application Summary',
                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),
                _summaryRow('Name', '$_selectedTitle ${_nameController.text}'),
                _summaryRow('Designation', _selectedDesignation),
                _summaryRow('Employee ID', _employeeIdController.text),
                _summaryRow('Departments', _selectedDepartments.join(', ')),
                _summaryRow('Years', _selectedYears.join(', ')),
                _summaryRow('Subjects', _addedSubjects.isEmpty ? 'None added' : _addedSubjects.join(', ')),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
            decoration: InputDecoration(
              labelText: 'Create Password',
              prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.secondary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textHint),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Approval notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your application will be reviewed by the Admin. You will be notified once approved.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectChips({
    required List<String> items,
    required List<String> selected,
    required Color color,
    required void Function(String) onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected.contains(item);
        return GestureDetector(
          onTap: () => onToggle(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.textHint.withOpacity(0.3),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check_circle_rounded, size: 14, color: color),
                  const SizedBox(width: 6),
                ],
                Text(
                  item,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _addSubject() {
    final subject = _subjectInputController.text.trim();
    if (subject.isNotEmpty && !_addedSubjects.contains(subject)) {
      setState(() {
        _addedSubjects.add(subject);
        _subjectInputController.clear();
      });
    }
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? hintText,
    String? helperText,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
        helperText: helperText,
        helperStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
              Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Fixed', style: TextStyle(fontSize: 9, color: AppColors.success)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text('$label:', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '—' : value,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
