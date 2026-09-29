import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/semester_registration_model.dart';

class SemesterRegistrationPdfService {
  static Future<Uint8List> generateOfficialRegistrationForm(SemesterRegistrationModel data) async {
    final pdf = pw.Document();

    // Safely load College Logo
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/college_logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      try {
        final logoBytes = await rootBundle.load('assets/logo.webp');
        logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      } catch (_) {
        logoImage = null;
      }
    }

    final formattedDate = DateFormat('dd MMMM, yyyy').format(data.submittedAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#1E3A8A'), width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // 1. Official College Header
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 58,
                        height: 58,
                        child: pw.Image(logoImage),
                      )
                    else
                      pw.Container(
                        width: 58,
                        height: 58,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColor.fromHex('#1E3A8A')),
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Center(
                          child: pw.Text('IES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'IES COLLEGE OF TECHNOLOGY',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#1E3A8A'),
                              letterSpacing: 0.8,
                            ),
                          ),
                          pw.Text(
                            'IES UNIVERSITY • BHOPAL (M.P.)',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#B45309'),
                            ),
                          ),
                          pw.Text(
                            'Approved by AICTE, New Delhi • Affiliated to RGPV, Bhopal',
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                          ),
                          pw.Text(
                            'Campus: Kalkheda, Ratibad Main Road, Bhopal-462044 • www.iesbhopal.ac.in',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#1E3A8A')),

                // 2. Form Title Ribbon
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1E3A8A'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'SEMESTER REGISTRATION & COURSE ENROLLMENT FORM',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      pw.Text(
                        'SESSION: ${data.academicSession}',
                        style: pw.TextStyle(
                          color: PdfColor.fromHex('#FDE68A'),
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 6),

                // Form Ref and Date
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Form Ref: ${data.refNo}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                    pw.Text('Date of Submission: $formattedDate', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  ],
                ),

                pw.SizedBox(height: 8),

                // 3. Section A: Candidate Particulars
                _buildSectionHeader('A. CANDIDATE PERSONAL PARTICULARS (Auto-Populated)'),
                pw.SizedBox(height: 4),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2.5),
                    1: pw.FlexColumnWidth(3.5),
                    2: pw.FlexColumnWidth(2.5),
                    3: pw.FlexColumnWidth(3.5),
                  },
                  children: [
                    _tableRow('Student Full Name', data.studentName, 'Enrollment No', data.enrollmentNo),
                    _tableRow('Roll Number', data.rollNo, 'Department / Branch', data.branch),
                    _tableRow('Current Class & Sem', '${data.currentYear} (${data.currentSemester})', 'Academic Section', 'Section ${data.section}'),
                    _tableRow("Father's Name", data.fatherName.isNotEmpty ? data.fatherName : 'As per Records', 'Mobile Number', data.phone),
                    _tableRow('Email ID', data.email, 'Permanent Address', data.address),
                  ],
                ),

                pw.SizedBox(height: 8),

                // 4. Section B: Academic Progression & Performance Record
                _buildSectionHeader('B. ACADEMIC PROGRESSION & PERFORMANCE RECORD'),
                pw.SizedBox(height: 4),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2.5),
                    1: pw.FlexColumnWidth(3.5),
                    2: pw.FlexColumnWidth(2.5),
                    3: pw.FlexColumnWidth(3.5),
                  },
                  children: [
                    _tableRow('Previous Sem SGPA', '${data.previousSemSgpa} / 10.0', 'Overall CGPA', '${data.overallCgpa} / 10.0'),
                    _tableRow('Backlog / ATKT Papers', data.hasBacklogs ? 'YES (${data.backlogDetails})' : 'NIL (All Clear)', 'Registration Type', 'Regular Promotion'),
                  ],
                ),

                if (data.achievements.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
                      color: PdfColor.fromHex('#F8FAFC'),
                    ),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(text: 'Academic & Co-curricular Achievements / Certifications: ', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3A8A'))),
                          pw.TextSpan(text: data.achievements, style: const pw.TextStyle(fontSize: 8, color: PdfColors.black)),
                        ],
                      ),
                    ),
                  ),
                ],

                pw.SizedBox(height: 8),

                // 5. Section C: Course Registration & Electives
                _buildSectionHeader('C. COURSE & SEMESTER ENROLLMENT DETAILS'),
                pw.SizedBox(height: 4),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2.5),
                    1: pw.FlexColumnWidth(3.5),
                    2: pw.FlexColumnWidth(2.5),
                    3: pw.FlexColumnWidth(3.5),
                  },
                  children: [
                    _tableRow('Registering for Semester', data.applyingSemester, 'College & University', '${data.college} (${data.university})'),
                    _tableRow('Electives / Specialization', data.electiveSubjects.isNotEmpty ? data.electiveSubjects : 'As per Curriculum Scheme', 'Fee Clearance Status', '${data.feePaymentStatus} ${data.feeReceiptNo.isNotEmpty ? "(Rcpt: ${data.feeReceiptNo})" : ""}'),
                  ],
                ),

                pw.SizedBox(height: 8),

                // 6. Section D: Student Undertaking
                _buildSectionHeader('D. STUDENT UNDERTAKING & DECLARATION'),
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFFBEB'),
                    border: pw.Border.all(color: PdfColor.fromHex('#FDE68A')),
                  ),
                  child: pw.Text(
                    'I hereby solemnly declare that the information furnished by me in this semester registration form is true and complete to the best of my knowledge and belief. I agree to abide by the rules and disciplinary codes of IES College of Technology / RGPV and shall maintain a minimum of 75% attendance in theory and practicals. In case of any misinformation, the college reserves the right to cancel my registration.',
                    style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.black, height: 1.25),
                  ),
                ),

                pw.Spacer(),

                // 7. Section E: Signatures & Official Approvals Box
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#1E3A8A'), width: 1.2),
                    color: PdfColor.fromHex('#F8FAFC'),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _signatureBlock('Signature of Student', data.studentName),
                      _signatureBlock('Faculty Mentor / Advisor', 'Verified & Cleared'),
                      _signatureBlock('Head of Department (H.O.D.)', 'Approved & Recommended'),
                      _buildPdfCollegeSeal(size: 44),
                      _buildPdfSignature(
                        title: 'Dean / Registrar',
                        subtitle: 'Official University Seal',
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Generated electronically via IES E-Campus ERP System • Ref: ${data.refNo}', style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600)),
                    pw.Text('Page 1 of 1 • 100% Accepted Official Academic Document', style: const pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfCollegeSeal({double size = 44}) {
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: PdfColor.fromHex('#991B1B'), width: 1.4),
      ),
      padding: const pw.EdgeInsets.all(2),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(color: PdfColor.fromHex('#991B1B'), width: 0.7),
        ),
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                '★ IES UNIVERSITY ★',
                style: pw.TextStyle(
                  fontSize: 3.6,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#991B1B'),
                ),
              ),
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 0.8),
                padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('#991B1B'), width: 0.4),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1.5)),
                ),
                child: pw.Text(
                  'OFFICIAL SEAL',
                  style: pw.TextStyle(
                    fontSize: 3.2,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#991B1B'),
                  ),
                ),
              ),
              pw.Text(
                '• BHOPAL (M.P.) •',
                style: pw.TextStyle(
                  fontSize: 3.2,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#991B1B'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildPdfSignature({
    String title = 'Dean / Registrar',
    String subtitle = 'Authorized Signatory',
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          'M. Verma',
          style: pw.TextStyle(
            fontSize: 9,
            fontStyle: pw.FontStyle.italic,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1E3A8A'),
          ),
        ),
        pw.Container(
          width: 80,
          height: 1,
          color: PdfColor.fromHex('#1E3A8A'),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A')),
        ),
        pw.Text(
          subtitle,
          style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 6),
      color: PdfColor.fromHex('#E2E8F0'),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#1E3A8A'),
        ),
      ),
    );
  }

  static pw.TableRow _tableRow(String label1, String val1, String label2, String val2) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          color: PdfColor.fromHex('#F8FAFC'),
          child: pw.Text(label1, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(val1, style: const pw.TextStyle(fontSize: 8, color: PdfColors.black)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          color: PdfColor.fromHex('#F8FAFC'),
          child: pw.Text(label2, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(val2, style: const pw.TextStyle(fontSize: 8, color: PdfColors.black)),
        ),
      ],
    );
  }

  static pw.Widget _signatureBlock(String title, String subtitle) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 80,
          height: 1,
          color: PdfColor.fromHex('#64748B'),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A')),
        ),
        pw.Text(
          subtitle,
          style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600),
        ),
      ],
    );
  }
}
