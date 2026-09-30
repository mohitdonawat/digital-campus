import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/campus_provider.dart';
import '../shell/main_screen.dart';

/// Ultra-Clean, Step-by-Step Single Screen Login & Universe Gateway
/// Connect via Email or SMS, select mode, with instant verification.
class LandingSplashScreen extends StatefulWidget {
  const LandingSplashScreen({super.key});

  @override
  State<LandingSplashScreen> createState() => _LandingSplashScreenState();
}

class _LandingSplashScreenState extends State<LandingSplashScreen> {
  UserRole _selectedRole = UserRole.student;
  bool _isEmailMode = true; // true: Email, false: SMS
  bool _isOtpSent = false;
  bool _isLoading = false;

  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final TextEditingController _otpController = TextEditingController(text: "4290");

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: _getDefaultEmail(UserRole.student));
    _phoneController = TextEditingController(text: _getDefaultPhone(UserRole.student));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _getDefaultEmail(UserRole role) {
    switch (role) {
      case UserRole.student:
        return "rahul.sharma@digitalcampus.edu";
      case UserRole.faculty:
        return "mohit.donawat@digitalcampus.edu";
      case UserRole.admin:
        return "registrar@digitalcampus.edu";
      case UserRole.parent:
        return "suresh.parent@digitalcampus.edu";
    }
  }

  String _getDefaultPhone(UserRole role) {
    switch (role) {
      case UserRole.student:
        return "98765 43210";
      case UserRole.faculty:
        return "98260 12345";
      case UserRole.admin:
        return "94250 99887";
      case UserRole.parent:
        return "98111 22334";
    }
  }

  void _onRoleChanged(UserRole role) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRole = role;
      _emailController.text = _getDefaultEmail(role);
      _phoneController.text = _getDefaultPhone(role);
      _isOtpSent = false;
    });
  }

  void _handleSendCode() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEmailMode
                ? "Verification code sent to ${_emailController.text}"
                : "SMS OTP sent to +91 ${_phoneController.text}",
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToMain(BuildContext context, UserRole role) {
    HapticFeedback.heavyImpact();
    Provider.of<CampusProvider>(context, listen: false).switchRole(role);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Slate 50 clean background
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── BRAND LOGO & HEADER ─────────────────────────────────
                    _buildBrandHeader(),

                    const SizedBox(height: 20),

                    // ── STEP 1: CHOOSE YOUR UNIVERSE (MODE) ─────────────────
                    _buildStepHeader(
                      stepNumber: "1",
                      title: "SELECT YOUR UNIVERSE",
                      subtitle: "Choose persona to enter active portal",
                    ),
                    const SizedBox(height: 10),
                    _buildRoleGrid(),

                    const SizedBox(height: 20),

                    // ── STEP 2: CONNECT VIA EMAIL OR SMS ────────────────────
                    _buildStepHeader(
                      stepNumber: "2",
                      title: "CONNECT ACCOUNT",
                      subtitle: "Connect via Institutional Email or SMS OTP",
                    ),
                    const SizedBox(height: 10),
                    _buildConnectCard(),

                    const SizedBox(height: 14),

                    // ── ⚡ 1-TAP DEMO DIRECT ENTRY ──────────────────────────
                    _buildQuickDemoButton(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header: Brand Logo & Title ──────────────────────────────────────────────
  Widget _buildBrandHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/images/college_logo.png",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.school_rounded, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "DIGITAL ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Text(
                      "CAMPUS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2563EB),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "ERP",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  "Single Sign-On Gateway • Autonomous University",
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step Title Helper ───────────────────────────────────────────────────────
  Widget _buildStepHeader({
    required String stepNumber,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 1: Role Grid (Student, Teacher, Admin, Parent) ─────────────────────
  Widget _buildRoleGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.7,
      children: [
        _buildRoleTile(
          role: UserRole.student,
          title: "Student",
          icon: Icons.school_rounded,
          color: const Color(0xFF2563EB),
        ),
        _buildRoleTile(
          role: UserRole.faculty,
          title: "Teacher",
          icon: Icons.psychology_rounded,
          color: const Color(0xFF7C3AED),
        ),
        _buildRoleTile(
          role: UserRole.admin,
          title: "Admin",
          icon: Icons.admin_panel_settings_rounded,
          color: const Color(0xFFD97706),
        ),
        _buildRoleTile(
          role: UserRole.parent,
          title: "Parent",
          icon: Icons.family_restroom_rounded,
          color: const Color(0xFF0D9488),
        ),
      ],
    );
  }

  Widget _buildRoleTile({
    required UserRole role,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () => _onRoleChanged(role),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? color : AppColors.textDark,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Connect via Email or SMS Card ───────────────────────────────────
  Widget _buildConnectCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Segmented Toggle: Email vs SMS
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isEmailMode = true;
                        _isOtpSent = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isEmailMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isEmailMode
                            ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 15,
                            color: _isEmailMode ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Connect via Email",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: _isEmailMode ? FontWeight.w800 : FontWeight.w600,
                              color: _isEmailMode ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isEmailMode = false;
                        _isOtpSent = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isEmailMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_isEmailMode
                            ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sms_outlined,
                            size: 15,
                            color: !_isEmailMode ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Connect via SMS",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: !_isEmailMode ? FontWeight.w800 : FontWeight.w600,
                              color: !_isEmailMode ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Input field based on mode
          if (_isEmailMode) ...[
            const Text(
              "Institutional Email Address",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18, color: Color(0xFF64748B)),
                hintText: "username@digitalcampus.edu",
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
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
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
            ),
          ] else ...[
            const Text(
              "Registered Mobile Number",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: const Text("+91", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF64748B))),
                ),
                hintText: "98765 43210",
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
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
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Code Sent / OTP Verification box
          if (_isOtpSent) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _isEmailMode ? "Email Code Sent (Demo: 4290)" : "SMS OTP Sent (Demo: 4290)",
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => setState(() => _isOtpSent = false),
                        child: const Text("Edit", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 8),
                    decoration: InputDecoration(
                      hintText: "• • • •",
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF86EFAC)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _navigateToMain(context, _selectedRole),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_open_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Verify & Enter ${_selectedRole.displayName.split(' ').first} Portal",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ] else ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isLoading ? null : _handleSendCode,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isEmailMode ? Icons.send_rounded : Icons.sms_rounded, size: 15),
                        const SizedBox(width: 8),
                        Text(
                          _isEmailMode ? "Send Verification Email" : "Send SMS OTP",
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Quick 1-Tap Entry Button ────────────────────────────────────────────────
  Widget _buildQuickDemoButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => _navigateToMain(context, _selectedRole),
      icon: const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF2563EB)),
      label: Text(
        "Instant 1-Tap Access as ${_selectedRole.displayName.split(' ').first}",
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
      ),
    );
  }
}
