import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../models/student_model.dart';

class StudentSignupScreen extends StatefulWidget {
  const StudentSignupScreen({super.key});

  @override
  State<StudentSignupScreen> createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _enrollmentController = TextEditingController();

  // Dropdowns
  String _selectedBranch = AppStrings.departments.first;
  String _selectedYear = AppStrings.years.first;
  String _selectedSemester = AppStrings.semesters.first;
  String _selectedSection = AppStrings.sections.first;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _rollNoController.dispose();
    _enrollmentController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final student = StudentModel(
        uid: cred.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        branch: _selectedBranch,
        year: _selectedYear,
        semester: _selectedSemester,
        section: _selectedSection,
        rollNo: _rollNoController.text.trim(),
        enrollmentNo: _enrollmentController.text.trim(),
        isApproved: false,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set(student.toMap());

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.pendingApproval);
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
          'Would you like to continue in Demo Mode to preview your registration?',
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
              final tempUid = 'student_${DateTime.now().millisecondsSinceEpoch}';
              final student = StudentModel(
                uid: tempUid,
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim(),
                branch: _selectedBranch,
                year: _selectedYear,
                semester: _selectedSemester,
                section: _selectedSection,
                rollNo: _rollNoController.text.trim(),
                enrollmentNo: _enrollmentController.text.trim(),
                isApproved: false,
                createdAt: DateTime.now(),
              );
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(tempUid)
                    .set(student.toMap());
              } catch (e) {
                debugPrint('Firestore offline notice: $e');
              }
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.pendingApproval);
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
                            Text('Student Registration',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                            Text(AppStrings.collegeFullName,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

                // Progress indicator
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

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(['Personal Info', 'Academic Info', 'Security'][_currentPage],
                        style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('Step ${_currentPage + 1} of 3',
                        style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Pages
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

                // Navigation buttons
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
                            : Text(_currentPage == 2 ? 'Create Account' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Login link
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.studentLogin),
                  child: const Text('Already have account? Login',
                    style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                ),
                const SizedBox(height: 16),
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

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildField(controller: _nameController, label: 'Full Name', icon: Icons.person_rounded,
            validator: (v) => v!.isEmpty ? 'Enter your name' : null),
          const SizedBox(height: 16),
          _buildField(controller: _emailController, label: 'Email Address', icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => !v!.contains('@') ? 'Enter valid email' : null),
          const SizedBox(height: 16),
          _buildField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone),

          const SizedBox(height: 24),

          // College (default, read-only)
          _buildReadOnlyField(
            label: 'College',
            value: AppStrings.collegeName,
            icon: Icons.school_rounded,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'University',
            value: AppStrings.universityFull,
            icon: Icons.account_balance_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildDropdown(
            label: 'Branch / Department',
            icon: Icons.category_rounded,
            value: _selectedBranch,
            items: AppStrings.departments,
            onChanged: (v) => setState(() => _selectedBranch = v!),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Current Year',
            icon: Icons.calendar_today_rounded,
            value: _selectedYear,
            items: AppStrings.years,
            onChanged: (v) => setState(() => _selectedYear = v!),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Semester',
            icon: Icons.school_outlined,
            value: _selectedSemester,
            items: AppStrings.semesters,
            onChanged: (v) => setState(() => _selectedSemester = v!),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Academic Section (Section A, B, C, D) *',
            icon: Icons.group_rounded,
            value: _selectedSection,
            items: AppStrings.sections,
            onChanged: (v) => setState(() => _selectedSection = v!),
          ),
          const SizedBox(height: 16),
          _buildField(controller: _rollNoController, label: 'Roll Number', icon: Icons.badge_rounded,
            validator: (v) => v!.isEmpty ? 'Enter roll number' : null),
          const SizedBox(height: 16),
          _buildField(controller: _enrollmentController, label: 'Enrollment Number', icon: Icons.numbers_rounded,
            validator: (v) => v!.isEmpty ? 'Enter enrollment number' : null),
        ],
      ),
    );
  }

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
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Account Summary', style: TextStyle(
                  color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                _summaryRow('Name', _nameController.text),
                _summaryRow('Branch', _selectedBranch),
                _summaryRow('Class', '$_selectedYear ($_selectedSemester) - Sec $_selectedSection'),
                _summaryRow('Roll No', _rollNoController.text),
                _summaryRow('Enrollment', _enrollmentController.text),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildField(
            controller: _passwordController,
            label: 'Create Password',
            icon: Icons.lock_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textHint),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your account will be approved by your teacher before you can login.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
            child: Text(value.isEmpty ? '—' : value,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Default', style: TextStyle(fontSize: 10, color: AppColors.success)),
          ),
        ],
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
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item, style: const TextStyle(color: Colors.white)),
      )).toList(),
    );
  }
}
