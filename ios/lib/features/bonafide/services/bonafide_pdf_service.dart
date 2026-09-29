import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/bonafide_model.dart';

class BonafidePdfService {
  static Future<Uint8List> generateBonafideCertificate(BonafideModel data) async {
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

    // Safely load Student Passport Photo (Base64 data or fallback)
    pw.MemoryImage? studentPhotoImg;
    if (data.profileImageUrl.isNotEmpty) {
      try {
        String cleanBase64 = data.profileImageUrl;
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        final bytes = base64Decode(cleanBase64.replaceAll(RegExp(r'\s+'), ''));
        studentPhotoImg = pw.MemoryImage(bytes);
      } catch (_) {
        studentPhotoImg = null;
      }
    }

    final formattedDate = DateFormat('dd MMMM, yyyy').format(data.issuedAt);

    // Verification QR Payload
    final qrData = 'VERIFIED_IES_BONAFIDE|Ref:${data.refNo}|Enrollment:${data.enrollmentNo}|Name:${data.studentName}|Father:${data.fatherName}|Branch:${data.branch}|Sem:${data.semester}|Date:$formattedDate';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#1E3A8A'), width: 2.2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header with Logo, College Affiliations & Student Photo
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 70,
                        height: 70,
                        child: pw.Image(logoImage),
                      )
                    else
                      pw.Container(
                        width: 70,
                        height: 70,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#EEF2FF'),
                          shape: pw.BoxShape.circle,
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'IES',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1E3A8A'),
                          ),
                        ),
                      ),
                    pw.SizedBox(width: 12),
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
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'IES UNIVERSITY • BHOPAL (M.P.)',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#B45309'),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Approved by AICTE, New Delhi & Affiliated to RGPV, Bhopal',
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            'Campus: Kalkheda, Ratibad Main Road, Bhopal (M.P.) - 462044',
                            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            'Website: www.iesbhopal.ac.in | Email: registrar@iesbhopal.ac.in',
                            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),

                    // Passport Photo Box
                    pw.Container(
                      width: 65,
                      height: 76,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColor.fromHex('#94A3B8'), width: 1),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        color: PdfColor.fromHex('#F8FAFC'),
                      ),
                      child: studentPhotoImg != null
                          ? pw.ClipRRect(
                              horizontalRadius: 3,
                              verticalRadius: 3,
                              child: pw.Image(studentPhotoImg, fit: pw.BoxFit.cover),
                            )
                          : pw.Center(
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'PASSPORT\nPHOTO',
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    '(ATTESTED)',
                                    style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#991B1B')),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#1E3A8A')),
                pw.SizedBox(height: 6),

                // Ref No & Date
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Ref No: ${data.refNo}',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                    ),
                    pw.Text(
                      'Date of Issue: $formattedDate',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                // Certificate Title Badge
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1E3A8A'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    'BONAFIDE CERTIFICATE (अध्ययनरत प्रमाण पत्र)',
                    style: pw.TextStyle(
                      fontSize: 11.5,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.0,
                      color: PdfColors.white,
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                // Certificate Body Paragraph
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.RichText(
                    textAlign: pw.TextAlign.justify,
                    text: pw.TextSpan(
                      style: const pw.TextStyle(
                        fontSize: 10.5,
                        color: PdfColors.black,
                        height: 1.65,
                      ),
                      children: [
                        const pw.TextSpan(text: 'This is to certify that Mr./Ms. '),
                        pw.TextSpan(
                          text: data.studentName.toUpperCase(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3A8A')),
                        ),
                        if (data.fatherName.isNotEmpty) ...[
                          const pw.TextSpan(text: ', Son / Daughter of Shri '),
                          pw.TextSpan(
                            text: data.fatherName.toUpperCase(),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                          ),
                        ],
                        const pw.TextSpan(text: ', Roll No: '),
                        pw.TextSpan(
                          text: data.rollNo.isNotEmpty ? data.rollNo : 'N/A',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: ', bearing University Enrollment No: '),
                        pw.TextSpan(
                          text: data.enrollmentNo,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#B45309')),
                        ),
                        const pw.TextSpan(text: ' is a bonafide student of '),
                        pw.TextSpan(
                          text: 'IES College of Technology, Bhopal',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: ' (Affiliated to Rajiv Gandhi Proudyogiki Vishwavidyalaya, Bhopal).\n\n'),
                        const pw.TextSpan(text: 'He/She is pursuing regular course of study in '),
                        pw.TextSpan(
                          text: '${data.branch} Department',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: ', currently studying in '),
                        pw.TextSpan(
                          text: '${data.year} (${data.semester}) - Section ${data.section}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: ' during the academic session '),
                        pw.TextSpan(
                          text: data.academicSession,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: '. According to the records available with the institution, his/her general conduct, academic attendance, and moral character during the tenure of study have been found to be '),
                        pw.TextSpan(
                          text: 'GOOD',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3A8A')),
                        ),
                        const pw.TextSpan(text: '.\n\n'),
                        const pw.TextSpan(text: 'This certificate is issued upon the candidate\'s application for the specific purpose of: '),
                        pw.TextSpan(
                          text: data.purpose.toUpperCase(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3A8A')),
                        ),
                        const pw.TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                // Signatures, Seal & QR Code Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // Digital QR code
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey400),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.BarcodeWidget(
                            data: qrData,
                            barcode: pw.Barcode.qrCode(),
                            width: 58,
                            height: 58,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Scan to verify authenticity',
                          style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600),
                        ),
                      ],
                    ),

                    // HOD Signature Block
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 105,
                          child: pw.Divider(thickness: 1, color: PdfColors.grey600),
                        ),
                        pw.Text(
                          'HOD / Coordinator',
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                        ),
                        pw.Text(
                          data.branch,
                          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                        ),
                      ],
                    ),

                    // Official College Circular Seal Stamp
                    buildPdfCollegeSeal(size: 60),

                    // Dean / Registrar Signature Block
                    buildPdfSignature(
                      title: 'Registrar / Principal',
                      subtitle: 'IES College of Technology',
                    ),
                  ],
                ),

                pw.SizedBox(height: 14),

                // OFFICIAL VERIFICATION STATEMENT
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F0FDF4'),
                    border: pw.Border.all(color: PdfColor.fromHex('#86EFAC')),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 6,
                        height: 6,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#16A34A'),
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Expanded(
                        child: pw.Text(
                          'OFFICIALLY VERIFIED & DIGITALLY ISSUED: This Bonafide Certificate is authenticated with the institutional seal of IES College of Technology / IES University, Bhopal. Valid for all official submissions including National Scholarship Portal (NSP), State Scholarships (MPTAAS), Education Loans, Passport/Visa, Bus Pass, and RGPV University.',
                          style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#166534'),
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Authentic Circular College Red Seal for PDF
  static pw.Widget buildPdfCollegeSeal({double size = 56}) {
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: PdfColor.fromHex('#991B1B'), width: 1.6),
      ),
      padding: const pw.EdgeInsets.all(2),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(color: PdfColor.fromHex('#991B1B'), width: 0.8),
        ),
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                '★ IES UNIVERSITY ★',
                style: pw.TextStyle(
                  fontSize: 4.8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#991B1B'),
                ),
              ),
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 1),
                padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('#991B1B'), width: 0.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
                child: pw.Text(
                  'OFFICIAL SEAL',
                  style: pw.TextStyle(
                    fontSize: 4.2,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#991B1B'),
                  ),
                ),
              ),
              pw.Text(
                '• BHOPAL (M.P.) •',
                style: pw.TextStyle(
                  fontSize: 4.2,
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

  /// Registrar / Principal Stylized Signature for PDF
  static pw.Widget buildPdfSignature({
    String title = 'Registrar / Principal',
    String subtitle = 'IES College of Technology',
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          'M. Verma',
          style: pw.TextStyle(
            fontSize: 10,
            fontStyle: pw.FontStyle.italic,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1E3A8A'),
          ),
        ),
        pw.Container(
          width: 90,
          height: 1.2,
          color: PdfColor.fromHex('#1E3A8A'),
        ),
        pw.SizedBox(height: 2.5),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
        ),
        pw.Text(
          subtitle,
          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static Future<Uint8List> generateTeacherBonafideCertificate(TeacherBonafideModel data) async {
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

    // Safely load Faculty Photo if present
    pw.MemoryImage? facultyPhotoImg;
    if (data.profileImageUrl.isNotEmpty) {
      try {
        final cleanBase64 = data.profileImageUrl.contains(',')
            ? data.profileImageUrl.split(',').last
            : data.profileImageUrl;
        final bytes = base64Decode(cleanBase64.replaceAll(RegExp(r'\s+'), ''));
        facultyPhotoImg = pw.MemoryImage(bytes);
      } catch (_) {
        facultyPhotoImg = null;
      }
    }

    final formattedDate = DateFormat('dd MMMM, yyyy').format(data.issuedAt);

    // Verification QR Payload
    final qrData = 'VERIFIED_IES_FACULTY_EMPLOYMENT_CERTIFICATE|Ref:${data.refNo}|EmpId:${data.employeeId}|Name:${data.teacherName}|Desig:${data.designation}|Dept:${data.departments}|DOJ:${data.dateOfJoining}|Status:${data.employmentType}|Date:$formattedDate';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#1E3A8A'), width: 2.2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header with Logo, College Affiliations & Faculty Photo
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 70,
                        height: 70,
                        child: pw.Image(logoImage),
                      )
                    else
                      pw.Container(
                        width: 70,
                        height: 70,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#EEF2FF'),
                          shape: pw.BoxShape.circle,
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'IES',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1E3A8A'),
                          ),
                        ),
                      ),
                    pw.SizedBox(width: 12),
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
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'IES UNIVERSITY • BHOPAL (M.P.)',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#B45309'),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Approved by AICTE, New Delhi & Affiliated to RGPV, Bhopal',
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            'Campus: Kalkheda, Ratibad Main Road, Bhopal (M.P.) - 462044',
                            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'OFFICE OF ESTABLISHMENT & FACULTY AFFAIRS',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#1E3A8A'),
                              letterSpacing: 0.5,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),

                    // Faculty Passport Photo Box
                    pw.Container(
                      width: 65,
                      height: 76,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColor.fromHex('#94A3B8'), width: 1),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        color: PdfColor.fromHex('#F8FAFC'),
                      ),
                      child: facultyPhotoImg != null
                          ? pw.ClipRRect(
                              horizontalRadius: 3,
                              verticalRadius: 3,
                              child: pw.Image(facultyPhotoImg, fit: pw.BoxFit.cover),
                            )
                          : pw.Center(
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'PASSPORT\nPHOTO',
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    '(FACULTY)',
                                    style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#991B1B')),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#1E3A8A')),
                pw.SizedBox(height: 6),

                // Ref No & Date
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Ref No: ${data.refNo}',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                    ),
                    pw.Text(
                      'Date of Issue: $formattedDate',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // Certificate Title Badge
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1E3A8A'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    'FACULTY BONAFIDE & SERVICE CERTIFICATE (कार्यरत एवं सेवा प्रमाण पत्र)',
                    style: pw.TextStyle(
                      fontSize: 10.5,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 0.8,
                      color: PdfColors.white,
                    ),
                  ),
                ),

                pw.SizedBox(height: 8),

                // Sub-heading
                pw.Text(
                  'TO WHOMSOEVER IT MAY CONCERN',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                    color: PdfColor.fromHex('#1E3A8A'),
                    letterSpacing: 1.2,
                  ),
                ),

                pw.SizedBox(height: 8),

                // Employee Particulars Summary Box
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8FAFC'),
                    border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.RichText(
                              text: pw.TextSpan(
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                children: [
                                  const pw.TextSpan(text: 'Employee Name: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                  pw.TextSpan(text: data.teacherName.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3A8A'))),
                                ],
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.RichText(
                              text: pw.TextSpan(
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                children: [
                                  const pw.TextSpan(text: 'Employee Code / ID: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                  pw.TextSpan(text: data.employeeId.isNotEmpty ? data.employeeId : 'N/A', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#B45309'))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.RichText(
                              text: pw.TextSpan(
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                children: [
                                  const pw.TextSpan(text: 'Designation: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                  pw.TextSpan(text: data.designation, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.RichText(
                              text: pw.TextSpan(
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                children: [
                                  const pw.TextSpan(text: 'Department: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                  pw.TextSpan(text: data.departments, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.RichText(
                              text: pw.TextSpan(
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                children: [
                                  const pw.TextSpan(text: 'Employment Type: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                  pw.TextSpan(text: data.employmentType, style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.RichText(
                              text: pw.TextSpan(
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                children: [
                                  const pw.TextSpan(text: 'Date of Joining: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                  pw.TextSpan(text: data.dateOfJoining.isNotEmpty ? data.dateOfJoining : 'Active Permanent Service', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.RichText(
                              text: pw.TextSpan(
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                children: [
                                  const pw.TextSpan(text: 'Academic Session: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                  pw.TextSpan(text: data.academicSession, style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.RichText(
                              text: pw.TextSpan(
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                children: [
                                  const pw.TextSpan(text: 'Purpose: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                  pw.TextSpan(text: data.purpose, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3A8A'))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // Certificate Body Paragraph
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.RichText(
                    textAlign: pw.TextAlign.justify,
                    text: pw.TextSpan(
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.black,
                        height: 1.5,
                      ),
                      children: [
                        const pw.TextSpan(text: 'This is to certify that Prof. / Dr. / Mr. / Ms. '),
                        pw.TextSpan(
                          text: data.teacherName.toUpperCase(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3A8A')),
                        ),
                        const pw.TextSpan(text: ', Employee ID: '),
                        pw.TextSpan(
                          text: data.employeeId.isNotEmpty ? data.employeeId : 'N/A',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#B45309')),
                        ),
                        const pw.TextSpan(text: ' is a bonafide, regular, and active employee of '),
                        pw.TextSpan(
                          text: 'IES College of Technology, Bhopal',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: ' (Affiliated to Rajiv Gandhi Proudyogiki Vishwavidyalaya, Bhopal). He/She is holding the substantive post of '),
                        pw.TextSpan(
                          text: data.designation,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: ' in the Department of '),
                        pw.TextSpan(
                          text: data.departments.isNotEmpty ? data.departments : 'Engineering & Technology',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: ' on a '),
                        pw.TextSpan(
                          text: data.employmentType,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: ' basis, serving the institution continuously since '),
                        pw.TextSpan(
                          text: data.dateOfJoining.isNotEmpty ? data.dateOfJoining : 'the date of appointment',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: '.\n\nDuring his/her tenure at this institution, his/her character, moral conduct, professional competence, and dedication towards academic teaching, laboratory instruction, and student mentorship have been found to be '),
                        pw.TextSpan(
                          text: 'EXCELLENT AND COMMENDABLE',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3A8A')),
                        ),
                        const pw.TextSpan(text: '. To the best of our knowledge and institutional records, there are no disciplinary or vigilance inquiries pending or contemplated against him/her.\n\n'),
                        const pw.TextSpan(text: 'This Service & Bonafide Certificate is issued upon his/her formal request as official institutional proof of employment for the express purpose of: '),
                        pw.TextSpan(
                          text: data.purpose.toUpperCase(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3A8A')),
                        ),
                        const pw.TextSpan(text: '. This certificate is valid for official, administrative, financial, and legal verifications.'),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                // Signatures, Seal & QR Code Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // Digital QR code
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey400),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.BarcodeWidget(
                            data: qrData,
                            barcode: pw.Barcode.qrCode(),
                            width: 58,
                            height: 58,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Scan to verify service record',
                          style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600),
                        ),
                      ],
                    ),

                    // Head of Department / Dean Block
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 105,
                          child: pw.Divider(thickness: 1, color: PdfColors.grey600),
                        ),
                        pw.Text(
                          'Head of Department / Dean',
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                        ),
                        pw.Text(
                          data.departments,
                          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                        ),
                      ],
                    ),

                    // Official College Circular Seal Stamp
                    buildPdfCollegeSeal(size: 60),

                    // Director / Registrar Stylized Signature
                    buildPdfSignature(
                      title: 'Director / Registrar',
                      subtitle: 'IES College of Technology',
                    ),
                  ],
                ),

                pw.SizedBox(height: 12),

                // OFFICIAL EMPLOYMENT PROOF VERIFIED STATEMENT
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F0FDF4'),
                    border: pw.Border.all(color: PdfColor.fromHex('#86EFAC')),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 6,
                        height: 6,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#16A34A'),
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Expanded(
                        child: pw.Text(
                          'OFFICIALLY VERIFIED SERVICE & EMPLOYMENT PROOF: This document is an authentic digital service certificate issued by IES College of Technology / IES University, Bhopal. It serves as verified institutional proof of active employment for submission to Scheduled Banks (Home/Personal/Auto Loans), Passport & Visa Authorities, Embassies, Income Tax Authorities, and Higher Education Bodies.',
                          style: pw.TextStyle(
                            fontSize: 6.8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#166534'),
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
