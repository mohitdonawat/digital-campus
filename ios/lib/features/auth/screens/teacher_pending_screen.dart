import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';

/// Shown to teachers after signup — waiting for Admin to approve
class TeacherPendingScreen extends StatelessWidget {
  const TeacherPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 2),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: AppColors.secondary,
                    size: 52,
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Application Submitted! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Your teacher account application has been sent to the Admin.\n\nPlease wait for approval before logging in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 36),

                // Status steps
                _statusStep(Icons.check_circle_rounded, 'Application submitted', AppColors.success, true),
                _statusStep(Icons.hourglass_top_rounded, 'Waiting for Admin approval', AppColors.warning, false),
                _statusStep(Icons.login_rounded, 'Login after approval', AppColors.textHint, false),

                const SizedBox(height: 40),

                // College info
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.school_rounded, color: AppColors.secondary, size: 16),
                          SizedBox(width: 8),
                          Text(AppStrings.collegeName,
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.phone_rounded, color: AppColors.textHint, size: 14),
                          SizedBox(width: 8),
                          Text(AppStrings.collegePhone,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.email_rounded, color: AppColors.textHint, size: 14),
                          SizedBox(width: 8),
                          Text(AppStrings.collegeEmail,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Login button (will check approval)
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.teacherLogin),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Check Approval Status'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Back to Home'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textHint),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusStep(IconData icon, String text, Color color, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            text,
            style: TextStyle(
              color: done ? Colors.white : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: done ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
