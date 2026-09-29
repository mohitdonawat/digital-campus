import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../auth/models/student_model.dart';
import 'college_seal_widget.dart';
import 'id_card_barcode_widget.dart';
import 'student_photo_widget.dart';

/// Official Front side of the IES College Lanyard Student ID Card
class IdCardFront extends StatelessWidget {
  final StudentModel student;
  final VoidCallback? onPhotoTap;

  const IdCardFront({
    super.key,
    required this.student,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    // Elegant CR80 standard vertical badge proportions (approx 340w x 530h)
    return Container(
      width: 340,
      height: 535,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.5),
        child: Stack(
          children: [
            // Background subtle security guilloche / watermark pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _GuillocheSecurityPatternPainter(),
              ),
            ),

            // Main Card Layout
            Column(
              children: [
                // 1. Header Banner with College Info and Lanyard Hole
                _buildHeader(),

                // 2. Student Passport Photo with Holographic Accent
                const SizedBox(height: 10),
                _buildPhotoAndName(),

                // 3. Department Pill
                _buildDepartmentPill(),

                const SizedBox(height: 10),

                // 4. Credential Grid (Enrollment, Roll, Sem, Blood Grp, etc.)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _buildCredentialTable(),
                ),

                const Spacer(),

                // 5. Official Authentication Row (Seal, Barcode, Sign)
                _buildAuthFooter(),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Lanyard Clip Slot Punch Hole
          Center(
            child: Container(
              width: 52,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 3, offset: Offset(0, 1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // College Logo and Title
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.webp',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Color(0xFF1E3A8A), size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IES COLLEGE OF TECHNOLOGY',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Text(
                      'IES UNIVERSITY • BHOPAL (M.P.)',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFBBF24), // Amber gold
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Approved by AICTE • Affiliated to RGPV, Bhopal',
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // Student ID Card Tag Ribbon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 2),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '★ STUDENT IDENTITY CARD ★',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${student.validUpto.isNotEmpty ? student.validUpto : "2024-2028"})',
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoAndName() {
    final displayName = student.name.trim().isEmpty ? 'STUDENT NAME' : student.name.toUpperCase();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Passport Photo with tap-to-upload capability
            StudentPhotoWidget(
              photoUrlOrBase64: student.profileImageUrl,
              width: 104,
              height: 122,
              borderRadius: 8,
              onTap: onPhotoTap,
              showEditBadge: student.profileImageUrl == null || student.profileImageUrl!.isEmpty,
            ),
            // Holographic Security Overlay Ribbon in top-right corner of photo
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 7, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      'VERIFIED',
                      style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentPill() {
    final branchName = student.branch.trim().isEmpty ? 'COMPUTER SCIENCE & ENGG' : student.branch.toUpperCase();
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.35)),
      ),
      child: Text(
        branchName,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E3A8A),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildCredentialTable() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _dataField('Enrollment No', student.enrollmentNo.isNotEmpty ? student.enrollmentNo : '0103CS221001'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dataField('Roll Number', student.rollNo.isNotEmpty ? student.rollNo : '221001'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _dataField('Course / Year', '${student.year} (${student.semester})'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dataField('Blood Group', student.bloodGroup.isNotEmpty ? student.bloodGroup : 'B+', isHighlight: true),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _dataField('Contact No', student.phone.isNotEmpty ? student.phone : '+91 98XXXXXXXX'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dataField('Emergency', student.emergencyContact.isNotEmpty ? student.emergencyContact : '+91 755 4910000'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataField(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: isHighlight ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthFooter() {
    final barcodeString = student.enrollmentNo.isNotEmpty ? student.enrollmentNo : student.rollNo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. Authentic College Seal Stamp (Rotated slightly for natural ink stamp effect)
          Transform.rotate(
            angle: -0.12,
            child: const CollegeSealWidget(
              size: 58,
              sealColor: Color(0xFF991B1B), // Official deep red stamp ink
            ),
          ),

          // 2. Barcode in center
          IdCardBarcodeWidget(
            code: barcodeString.isNotEmpty ? barcodeString : 'IES2024STU',
            width: 105,
            height: 34,
            barColor: const Color(0xFF0F172A),
          ),

          // 3. Registrar / Issuing Authority Signature
          const RegistrarSignatureWidget(
            width: 82,
            title: 'Issuing Authority',
          ),
        ],
      ),
    );
  }
}

/// Subtle guilloche background security wave lines
class _GuillocheSecurityPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A8A).withOpacity(0.028)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final path = Path();
    for (double y = 80; y < size.height - 50; y += 16) {
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 30) {
        path.quadraticBezierTo(
          x + 15,
          y + 6 * math.sin((x + y) / 20),
          x + 30,
          y,
        );
      }
    }
    canvas.drawPath(path, paint);

    // Subtle center emblem watermark
    final centerPaint = Paint()
      ..color = const Color(0xFF1E3A8A).withOpacity(0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2 + 20), 85, centerPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2 + 20), 75, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
