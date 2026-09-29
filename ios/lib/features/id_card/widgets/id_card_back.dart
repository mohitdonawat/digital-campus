import 'package:flutter/material.dart';
import '../../auth/models/student_model.dart';
import 'college_seal_widget.dart';

/// Official Back side of the IES College Lanyard Student ID Card
class IdCardBack extends StatelessWidget {
  final StudentModel student;

  const IdCardBack({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            // 1. Top Header with Lanyard slot & Back Title
            _buildHeader(),

            // 2. Personal & Emergency Details Card
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: _buildPersonalDetails(),
            ),

            const SizedBox(height: 8),

            // 3. Official Terms & Rules Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _buildRulesSection(),
            ),

            const Spacer(),

            // 4. Return Address & QR Verification Footer
            _buildFooter(),
            const SizedBox(height: 10),
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
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Lanyard Clip Slot Punch Hole (Matches front)
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

          const Text(
            'TERMS & EMERGENCY INFORMATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'IES UNIVERSITY • ISO 9001:2015 CERTIFIED CAMPUS',
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFBBF24).withOpacity(0.9),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails() {
    final fatherName = student.fatherName.isNotEmpty ? student.fatherName : 'Mr. Father / Guardian';
    final address = student.address.isNotEmpty ? student.address : 'Bhopal, Madhya Pradesh - India';
    final dob = student.dob.isNotEmpty ? student.dob : 'Not Specified';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        children: [
          _rowItem('Father / Guardian:', fatherName),
          const Divider(height: 10, color: Color(0xFFE2E8F0)),
          _rowItem('Date of Birth:', dob),
          const Divider(height: 10, color: Color(0xFFE2E8F0)),
          _rowItem('Residential Address:', address, isMultiline: true),
          const Divider(height: 10, color: Color(0xFFE2E8F0)),
          _rowItem('Emergency Helpline:', student.emergencyContact.isNotEmpty ? student.emergencyContact : '+91 755 4910000', isBold: true),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value, {bool isMultiline = false, bool isBold = false}) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: isMultiline ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRulesSection() {
    final rules = [
      '1. This card is non-transferable and remains college property.',
      '2. Students must wear this card with official lanyard at all times.',
      '3. Loss must be reported immediately to the Registrar office.',
      '4. Unauthorized possession or alteration is a serious offence.',
      '5. Card must be surrendered upon course completion or leaving.',
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel_rounded, size: 12, color: Color(0xFF991B1B)),
              SizedBox(width: 5),
              Text(
                'CAMPUS DISCIPLINE & RULES',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF991B1B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ...rules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  rule,
                  style: const TextStyle(
                    fontSize: 7.5,
                    height: 1.25,
                    color: Color(0xFF450A0A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Mini Security Stamp
            const CollegeSealWidget(
              size: 42,
              sealColor: Color(0xFFFBBF24), // Gold seal on dark background
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IF FOUND, PLEASE RETURN TO:',
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFBBF24),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'IES Campus, Kalkheda, Ratibad Main Road, Bhopal, MP - 462044',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ph: +91 755 4910000 • Web: iesbhopal.ac.in',
                    style: TextStyle(
                      fontSize: 6.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
