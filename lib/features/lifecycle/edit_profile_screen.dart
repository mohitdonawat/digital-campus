import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_chip.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _rollController;
  late TextEditingController _enrollmentController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _addressController;
  late TextEditingController _roomController;

  String _selectedBranch = "Computer Science & Engineering";
  int _selectedSemester = 6;
  String _selectedSection = "A";
  String _selectedBloodGroup = "B+ Positive";
  String _selectedHostelBlock = "Ramanujan Bhawan (Block B)";

  final List<String> _branches = [
    "Computer Science & Engineering",
    "Artificial Intelligence & ML",
    "Data Science & Analytics",
    "Electronics & Comm. Engineering",
    "Mechanical Engineering",
    "Electrical & Electronics Engg",
  ];

  final List<String> _bloodGroups = [
    "A+ Positive",
    "A- Negative",
    "B+ Positive",
    "B- Negative",
    "O+ Positive",
    "O- Negative",
    "AB+ Positive",
    "AB- Negative",
  ];

  final List<String> _hostelOptions = [
    "Ramanujan Bhawan (Block B)",
    "Aryabhata Hostel (Block A)",
    "Visvesvaraya Hostel (Block C)",
    "Kalpana Chawla Girls Hostel",
    "Day Scholar (No Hostel)",
  ];

  @override
  void initState() {
    super.initState();
    final student = Provider.of<CampusProvider>(context, listen: false).student;

    _nameController = TextEditingController(text: student.name);
    _rollController = TextEditingController(text: student.rollNumber);
    _enrollmentController = TextEditingController(text: student.enrollmentNumber);
    _phoneController = TextEditingController(text: student.phone);
    _emailController = TextEditingController(text: student.email);
    _parentNameController = TextEditingController(text: student.parentName);
    _parentPhoneController = TextEditingController(text: student.parentPhone);
    _addressController = TextEditingController(text: student.address);
    _roomController = TextEditingController(text: student.roomNumber);

    if (_branches.contains(student.branch)) {
      _selectedBranch = student.branch;
    }
    _selectedSemester = student.semester;
    _selectedSection = student.section;
    if (_bloodGroups.contains(student.bloodGroup)) {
      _selectedBloodGroup = student.bloodGroup;
    }
    if (_hostelOptions.contains(student.hostelBlock)) {
      _selectedHostelBlock = student.hostelBlock;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _enrollmentController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _addressController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.heavyImpact();

    final currentStudent = Provider.of<CampusProvider>(context, listen: false).student;

    final updated = currentStudent.copyWith(
      name: _nameController.text.trim(),
      rollNumber: _rollController.text.trim().toUpperCase(),
      enrollmentNumber: _enrollmentController.text.trim().toUpperCase(),
      branch: _selectedBranch,
      semester: _selectedSemester,
      section: _selectedSection,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      parentName: _parentNameController.text.trim(),
      parentPhone: _parentPhoneController.text.trim(),
      emergencyContact: _parentPhoneController.text.trim(),
      address: _addressController.text.trim(),
      hostelBlock: _selectedHostelBlock,
      roomNumber: _roomController.text.trim(),
    );

    Provider.of<CampusProvider>(context, listen: false).updateStudentProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile & Institutional Ledger updated for ${updated.name}!"),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Edit Student Profile & Ledger"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
              label: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Info Note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.badge_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "University Admission & Identity Record",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Changes sync in real-time to your PVC Smart Card, Bonafide Certificates, Fee Invoices, and Attendance Registers.",
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 1: Academic Credentials
              _buildSectionTitle("1. ACADEMIC & INSTITUTIONAL CREDENTIALS"),
              const SizedBox(height: 10),

              _buildCardContainer([
                _buildTextField(
                  controller: _nameController,
                  label: "Full Legal Name",
                  hint: "Enter your official name",
                  icon: Icons.person_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _rollController,
                        label: "Class Roll No.",
                        hint: "e.g. CS22B045",
                        icon: Icons.confirmation_number_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? "Roll No. required" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _enrollmentController,
                        label: "RGPV Enrollment No.",
                        hint: "e.g. 0176CS221045",
                        icon: Icons.numbers_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? "Enrollment required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedBranch,
                  decoration: _inputDecoration("Branch / Department", Icons.account_tree_rounded),
                  items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) => setState(() => _selectedBranch = val ?? _selectedBranch),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedSemester,
                        decoration: _inputDecoration("Semester", Icons.school_rounded),
                        items: List.generate(8, (i) => i + 1)
                            .map((s) => DropdownMenuItem(value: s, child: Text("Semester $s", style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedSemester = val ?? _selectedSemester),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSection,
                        decoration: _inputDecoration("Section", Icons.group_rounded),
                        items: ["A", "B", "C", "D"]
                            .map((sec) => DropdownMenuItem(value: sec, child: Text("Section $sec", style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedSection = val ?? _selectedSection),
                      ),
                    ),
                  ],
                ),
              ]),

              const SizedBox(height: 20),

              // Section 2: Contact & Medical Information
              _buildSectionTitle("2. CONTACT & PERSONAL DETAILS"),
              const SizedBox(height: 10),

              _buildCardContainer([
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        label: "Student Mobile No.",
                        hint: "+91 98930 XXXXX",
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBloodGroup,
                        decoration: _inputDecoration("Blood Group", Icons.bloodtype_rounded),
                        items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (val) => setState(() => _selectedBloodGroup = val ?? _selectedBloodGroup),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  label: "Official Student Email",
                  hint: "username@apextech.ac.in",
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _addressController,
                  label: "Permanent Address & City",
                  hint: "House, Colony, City, State, PIN",
                  icon: Icons.home_rounded,
                  maxLines: 2,
                ),
              ]),

              const SizedBox(height: 20),

              // Section 3: Parent & Emergency Contact
              _buildSectionTitle("3. PARENT & GUARDIAN RECORDS"),
              const SizedBox(height: 10),

              _buildCardContainer([
                _buildTextField(
                  controller: _parentNameController,
                  label: "Father / Guardian Name",
                  hint: "Official Guardian Name",
                  icon: Icons.family_restroom_rounded,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _parentPhoneController,
                  label: "Parent Contact & Emergency Phone",
                  hint: "+91 94250 XXXXX",
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
              ]),

              const SizedBox(height: 20),

              // Section 4: Campus Residence / Hostel
              _buildSectionTitle("4. CAMPUS RESIDENCE & HOSTEL ALLOTMENT"),
              const SizedBox(height: 10),

              _buildCardContainer([
                DropdownButtonFormField<String>(
                  value: _selectedHostelBlock,
                  decoration: _inputDecoration("Hostel Residence Block", Icons.apartment_rounded),
                  items: _hostelOptions.map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) => setState(() => _selectedHostelBlock = val ?? _selectedHostelBlock),
                ),
                if (_selectedHostelBlock != "Day Scholar (No Hostel)") ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _roomController,
                    label: "Allotted Room Number",
                    hint: "e.g. B-304",
                    icon: Icons.meeting_room_rounded,
                  ),
                ],
              ]),

              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                  label: const Text(
                    "Save & Update Institutional Ledger",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.surfaceSubtle.withOpacity(0.5),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
      decoration: _inputDecoration(label, icon).copyWith(hintText: hint),
    );
  }
}
