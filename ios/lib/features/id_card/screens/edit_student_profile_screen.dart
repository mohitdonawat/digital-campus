import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/student_photo_widget.dart';

class EditStudentProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const EditStudentProfileScreen({super.key, this.initialData});

  @override
  State<EditStudentProfileScreen> createState() => _EditStudentProfileScreenState();
}

class _EditStudentProfileScreenState extends State<EditStudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _fatherNameController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _rollNoController;
  late TextEditingController _enrollmentNoController;
  late TextEditingController _validUptoController;

  String _selectedBloodGroup = 'B+';
  String _selectedSection = 'A';
  DateTime? _selectedDob;
  String? _photoBase64;
  bool _isSaving = false;
  bool _isLoading = true;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _fatherNameController = TextEditingController();
    _addressController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _rollNoController = TextEditingController();
    _enrollmentNoController = TextEditingController();
    _validUptoController = TextEditingController(text: '2024 - 2028');

    _populateOrFetch();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _fatherNameController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _rollNoController.dispose();
    _enrollmentNoController.dispose();
    _validUptoController.dispose();
    super.dispose();
  }

  Future<void> _populateOrFetch() async {
    Map<String, dynamic>? data = widget.initialData;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (data == null && uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      data = doc.data();
    }

    if (data != null && mounted) {
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _fatherNameController.text = data['fatherName'] ?? '';
      _addressController.text = data['address'] ?? '';
      _emergencyContactController.text = data['emergencyContact'] ?? '';
      _rollNoController.text = data['rollNo'] ?? '';
      _enrollmentNoController.text = data['enrollmentNo'] ?? '';
      _validUptoController.text = data['validUpto'] ?? '2024 - 2028';
      _photoBase64 = data['profileImageUrl'];

      final bg = data['bloodGroup']?.toString().toUpperCase();
      if (bg != null && _bloodGroups.contains(bg)) {
        _selectedBloodGroup = bg;
      }

      final sec = data['section']?.toString().toUpperCase();
      if (sec != null && _sections.contains(sec)) {
        _selectedSection = sec;
      }

      final dobStr = data['dob']?.toString();
      if (dobStr != null && dobStr.isNotEmpty) {
        try {
          _selectedDob = DateFormat('dd/MM/yyyy').parse(dobStr);
        } catch (_) {}
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70, // Optimized for light weight Firestore storage
      );

      if (image == null) return;

      final Uint8List bytes = await image.readAsBytes();
      final String base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      setState(() {
        _photoBase64 = base64Image;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Passport photo captured (${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB)'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.error, content: Text('Failed to pick photo: $e')),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Passport Size Photo',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please select a clear, frontal passport photo with light background for your official ID card.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _photoSourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Take Photo',
                    color: AppColors.secondary,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _photoSourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'From Gallery',
                    color: const Color(0xFF38BDF8),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoSourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(1980),
      lastDate: DateTime(now.year - 14),
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
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      final updateData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'address': _addressController.text.trim(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'rollNo': _rollNoController.text.trim(),
        'enrollmentNo': _enrollmentNoController.text.trim(),
        'bloodGroup': _selectedBloodGroup,
        'section': _selectedSection,
        'validUpto': _validUptoController.text.trim(),
        if (_selectedDob != null) 'dob': DateFormat('dd/MM/yyyy').format(_selectedDob!),
        if (_photoBase64 != null) 'profileImageUrl': _photoBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).set(
            updateData,
            SetOptions(merge: true),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('ID Card profile updated successfully!'),
              ],
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.error, content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Update ID Card Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Photo Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        StudentPhotoWidget(
                          photoUrlOrBase64: _photoBase64,
                          width: 100,
                          height: 120,
                          borderRadius: 10,
                          onTap: _showPhotoOptions,
                        ),
                        GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showPhotoOptions,
                      icon: const Icon(Icons.add_a_photo_rounded, size: 16, color: Colors.black),
                      label: Text(
                        _photoBase64 != null ? 'Change Passport Photo' : 'Upload Passport Photo',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Free Cloud Sync: Saved automatically to your Student Profile',
                      style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Form fields card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Student Credentials',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 14),

                    // Full Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Student Full Name (As per College Records)',
                      icon: Icons.person_rounded,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Phone, Section & Blood Group
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildTextField(
                            controller: _phoneController,
                            label: 'Mobile Number',
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: _buildSectionDropdown(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 4,
                          child: _buildBloodGroupDropdown(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Date of Birth
                    _buildDobField(),

                    const SizedBox(height: 14),

                    // Father's Name
                    _buildTextField(
                      controller: _fatherNameController,
                      label: "Father's / Guardian's Name",
                      icon: Icons.family_restroom_rounded,
                    ),

                    const SizedBox(height: 14),

                    // Emergency Contact
                    _buildTextField(
                      controller: _emergencyContactController,
                      label: 'Emergency Helpline Number',
                      icon: Icons.emergency_rounded,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 14),

                    // Address
                    _buildTextField(
                      controller: _addressController,
                      label: 'Residential / Permanent Address',
                      icon: Icons.home_rounded,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 14),

                    // Enrollment No & Roll No
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _enrollmentNoController,
                            label: 'Enrollment No',
                            icon: Icons.badge_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _rollNoController,
                            label: 'Roll Number',
                            icon: Icons.numbers_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Card Validity / Session
                    _buildTextField(
                      controller: _validUptoController,
                      label: 'Batch / Validity (e.g. 2024 - 2028)',
                      icon: Icons.calendar_today_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.check_circle_rounded, color: Colors.black),
                  label: Text(
                    _isSaving ? 'Updating Profile & ID Card...' : 'Save & Update Official ID Card',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
      ),
    );
  }

  Widget _buildSectionDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSection,
          dropdownColor: AppColors.surface,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.secondary),
          items: _sections.map((sec) {
            return DropdownMenuItem<String>(
              value: sec,
              child: Text(
                'Sec: $sec',
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedSection = val);
          },
        ),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBloodGroup,
          dropdownColor: AppColors.surface,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.secondary),
          items: _bloodGroups.map((bg) {
            return DropdownMenuItem<String>(
              value: bg,
              child: Text(
                'Blood: $bg',
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedBloodGroup = val);
          },
        ),
      ),
    );
  }

  Widget _buildDobField() {
    final displayText = _selectedDob != null ? DateFormat('dd MMMM, yyyy').format(_selectedDob!) : 'Tap to select DOB';

    return InkWell(
      onTap: _selectDob,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake_rounded, color: AppColors.secondary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date of Birth', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                Text(
                  displayText,
                  style: TextStyle(
                    color: _selectedDob != null ? Colors.white : AppColors.textHint,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.calendar_month_rounded, color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }
}
