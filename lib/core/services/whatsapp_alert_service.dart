import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../../models/campus_models.dart';

/// Enterprise WhatsApp Parent Alert & Statutory Notice Dispatcher
/// Integrates with WhatsApp deep-linking (wa.me) & url_launcher
/// Formats official AICTE 75% attendance detention notices.
class WhatsAppAlertService {
  /// Formats an official statutory university notice for attendance shortage.
  static String formatDefaulterNotice({
    required StudentAttendanceRecord student,
    String collegeName = "IES College of Technology, Bhopal",
    String facultyName = "Dr. Mohit Donawat (HOD, CSE)",
    String departmentHelpline = "+91 98260 11223",
  }) {
    final deficitClasses = student.attendancePercentage < 75.0
        ? (((0.75 * student.totalClasses) - student.attendedClasses) / 0.25).ceil().clamp(1, 40)
        : 0;

    return """
🏛️ *${collegeName.toUpperCase()}*
*OFFICIAL STATUTORY NOTICE - ATTENDANCE DEFICIT*
═════════════════════════════
To: Parent / Guardian of *${student.name}*
Roll No: *${student.rollNumber}* | Sem: ${student.semester} (${student.branch} - ${student.section})

⚠️ *Subject: Mandatory AICTE 75% Attendance Compliance Alert*

Dear Parent,
This is an official urgent notification from the Office of the Head of Department.

📊 *Current Cumulative Attendance:* *${student.attendancePercentage}%*
🔴 *Academic Risk Status:* CRITICAL DEFAULTER (Below 75% AICTE Threshold)
📚 *Total Classes Conducted:* ${student.totalClasses}
✅ *Classes Attended:* ${student.attendedClasses}
⏳ *Deficit Required:* Must attend next *${deficitClasses} consecutive classes* without absence.

⚖️ *Statutory University Ordinance:*
As per AICTE & University Ordinance 12, students having attendance below 75% are *STRICTLY DETAINED* from appearing in the Semester Final Examinations, and their exam Admit Cards / Hall Tickets will be withheld.

👨‍🏫 *Faculty / HOD:* $facultyName
📞 *Department Hotline:* $departmentHelpline
🏫 *Campus:* Kalkheda, Ratibad Main Road, Bhopal (M.P.)

Kindly counsel your ward to ensure 100% attendance from tomorrow onwards.
═════════════════════════════
*Digital Campus Smart ERP • Automated Dispatch ID: WHA-${DateTime.now().millisecondsSinceEpoch % 100000}*
""".trim();
  }

  /// Directly launches WhatsApp with pre-filled official message.
  static Future<bool> sendWhatsAppAlert({
    required BuildContext context,
    required StudentAttendanceRecord student,
    String? customMessage,
  }) async {
    final message = customMessage ?? formatDefaulterNotice(student: student);
    final rawPhone = student.parentPhone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Ensure international country code (default to India 91 if 10 digits)
    final phone = rawPhone.length == 10 ? "91$rawPhone" : rawPhone;

    final encodedMsg = Uri.encodeComponent(message);
    final whatsappUri = Uri.parse("https://wa.me/$phone?text=$encodedMsg");
    final appUri = Uri.parse("whatsapp://send?phone=$phone&text=$encodedMsg");

    try {
      HapticFeedback.mediumImpact();
      // Try native WhatsApp URI first, fallback to web wa.me
      if (await canLaunchUrl(appUri)) {
        return await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(whatsappUri)) {
        return await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Copy to clipboard and notify
        await Clipboard.setData(ClipboardData(text: message));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("WhatsApp not installed. Notice copied to clipboard for ${student.name}'s parent ($phone)!"),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: message));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Notice copied to clipboard ($phone). Paste into WhatsApp!"),
            backgroundColor: AppColors.primary,
          ),
        );
      }
      return false;
    }
  }

  /// Opens an interactive Preview & Dispatch Modal Sheet
  static void showDispatchBottomSheet({
    required BuildContext context,
    required StudentAttendanceRecord student,
    String facultyName = "Dr. Mohit Donawat",
  }) {
    final noticeText = formatDefaulterNotice(student: student, facultyName: facultyName);
    final cleanPhone = student.parentPhone.replaceAll(RegExp(r'[^0-9]'), '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Top drag pill
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Dispatch WhatsApp Notice",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                          Text(
                            "AICTE Statutory Detention Warning • Parent Hotline",
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Student Quick Info Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.error.withOpacity(0.15),
                      child: Text(
                        student.name.isNotEmpty ? student.name[0] : "S",
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.error),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                          Text(
                            "${student.rollNumber} • ${student.branch} Sem ${student.semester} (${student.section})",
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Parent: ${student.parentPhone}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${student.attendancePercentage}%",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Message Preview Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "OFFICIAL NOTICE PREVIEW (WHATSAPP)",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.6),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: noticeText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Notice copied to clipboard!"), duration: Duration(seconds: 2)),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text("Copy Text", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      noticeText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        color: Color(0xFF1E293B),
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3)),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Direct Phone Call
                      OutlinedButton.icon(
                        onPressed: () async {
                          final telUri = Uri.parse("tel:$cleanPhone");
                          if (await canLaunchUrl(telUri)) {
                            await launchUrl(telUri);
                          }
                        },
                        icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                        label: const Text("Call"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Launch WhatsApp Direct
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await sendWhatsAppAlert(
                              context: context,
                              student: student,
                              customMessage: noticeText,
                            );
                          },
                          icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                          label: const Text(
                            "Dispatch via WhatsApp",
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
