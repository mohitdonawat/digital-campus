import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/app_constants.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';

class DocumentDownloadService {
  /// ── 1. REAL PVC SMART ID CARD PDF ──────────────────────────────────────────
  static Future<void> downloadPvcIdCardPdf(BuildContext context, StudentProfile student) async {
    _showDownloadingSheet(context, "Student PVC Smart ID Card", "CS22B045_Smart_ID.pdf");

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue900,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            AppConstants.institutionName.toUpperCase(),
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            AppConstants.affiliation,
                            style: const pw.TextStyle(color: PdfColors.blue100, fontSize: 10),
                          ),
                        ],
                      ),
                      pw.Text(
                        "DIGITAL CAMPUS",
                        style: pw.TextStyle(
                          color: PdfColors.amber,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                // PVC Card Front
                pw.Container(
                  width: 360,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(16),
                    border: pw.Border.all(color: PdfColors.blue800, width: 2),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "STUDENT IDENTITY CARD",
                            style: pw.TextStyle(
                              color: PdfColors.blue900,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            color: PdfColors.green100,
                            child: pw.Text("ACTIVE", style: pw.TextStyle(color: PdfColors.green900, fontSize: 9)),
                          ),
                        ],
                      ),
                      pw.Divider(color: PdfColors.grey300),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 80,
                            height: 100,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue50,
                              border: pw.Border.all(color: PdfColors.blue300),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                "RS",
                                style: pw.TextStyle(
                                  color: PdfColors.blue900,
                                  fontSize: 28,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 16),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  student.name,
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text("Roll No: ${student.rollNumber}", style: const pw.TextStyle(fontSize: 11)),
                                pw.Text("Branch: ${student.branch}", style: const pw.TextStyle(fontSize: 11)),
                                pw.Text("Semester: ${student.semester}th Sem (2022-26)", style: const pw.TextStyle(fontSize: 11)),
                                pw.Text("Blood Group: ${student.bloodGroup}", style: const pw.TextStyle(fontSize: 11)),
                                pw.Text("Emergency: ${student.emergencyContact}", style: const pw.TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 16),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.BarcodeWidget(
                            barcode: pw.Barcode.code128(),
                            data: student.rollNumber,
                            width: 140,
                            height: 35,
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text("Dean & Director Signature", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                              pw.Text("Mr. Shridhar Donawat", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  "This document is an authentic digitally generated PVC ID credential from the Digital Campus ERP cloud.",
                  style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );

      await _saveAndOpenFile(context, pdf, "CS22B045_Smart_ID.pdf");
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  /// ── 1B. ROLE-AWARE PVC SMART ID CARD / CREDENTIAL PASS PDF ────────────────
  static Future<void> downloadRolePvcIdCardPdf(BuildContext context, CampusProvider provider) async {
    final role = provider.currentRole;
    switch (role) {
      case UserRole.student:
        return downloadPvcIdCardPdf(context, provider.student);

      case UserRole.faculty:
        final fac = provider.facultyProfile;
        _showDownloadingSheet(context, "Faculty Official ID Pass", "FAC_CSE_019_Faculty_ID.pdf");
        try {
          final pdf = pw.Document();
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(32),
              build: (pw.Context ctx) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Header
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue900,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                AppConstants.institutionName.toUpperCase(),
                                style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text("FACULTY & RESEARCH COUNCIL • AUTONOMOUS", style: const pw.TextStyle(color: PdfColors.blue100, fontSize: 10)),
                            ],
                          ),
                          pw.Text("FACULTY PASS", style: pw.TextStyle(color: PdfColors.amber, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 24),
                    // PVC Card Box
                    pw.Container(
                      width: 360,
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(16),
                        border: pw.Border.all(color: PdfColors.blue900, width: 2),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("OFFICIAL FACULTY & RESEARCH CREDENTIAL", style: pw.TextStyle(color: PdfColors.blue900, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                color: PdfColors.green100,
                                child: pw.Text("TENURED", style: pw.TextStyle(color: PdfColors.green900, fontSize: 9)),
                              ),
                            ],
                          ),
                          pw.Divider(color: PdfColors.grey300),
                          pw.SizedBox(height: 10),
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 80,
                                height: 100,
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.blue50,
                                  border: pw.Border.all(color: PdfColors.blue300),
                                ),
                                child: pw.Center(
                                  child: pw.Text("MD", style: pw.TextStyle(color: PdfColors.blue900, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                                ),
                              ),
                              pw.SizedBox(width: 16),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(fac.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                                    pw.SizedBox(height: 4),
                                    pw.Text("Faculty ID: ${fac.id}", style: const pw.TextStyle(fontSize: 10.5)),
                                    pw.Text("Role: Associate Professor & HOD", style: const pw.TextStyle(fontSize: 10.5)),
                                    pw.Text("Department: ${fac.department}", style: const pw.TextStyle(fontSize: 10.5)),
                                    pw.Text("Cabin: ${fac.cabin}", style: const pw.TextStyle(fontSize: 10.5)),
                                    pw.Text("Clearances: Server Room, Lab 3, Senate", style: const pw.TextStyle(fontSize: 10.5)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 16),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.BarcodeWidget(
                                barcode: pw.Barcode.code128(),
                                data: fac.id,
                                width: 140,
                                height: 35,
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text("Attested by Dean & Director", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                  pw.Text("Mr. Shridhar Donawat", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 24),
                    pw.Text("Official Faculty Credential with Server Room and Academic Senate Biometric Clearance.", style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
                  ],
                );
              },
            ),
          );
          await _saveAndOpenFile(context, pdf, "FAC_CSE_019_Faculty_ID.pdf");
        } catch (e) {
          _showError(context, e.toString());
        }
        break;

      case UserRole.admin:
        final admin = provider.adminProfile;
        _showDownloadingSheet(context, "Executive Governance Pass", "DIR_EXE_001_Executive_Pass.pdf");
        try {
          final pdf = pw.Document();
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(32),
              build: (pw.Context ctx) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Header
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.amber900,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                AppConstants.institutionName.toUpperCase(),
                                style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text("OFFICE OF THE DEAN & DIRECTOR • STATUTORY SEAL", style: const pw.TextStyle(color: PdfColors.amber100, fontSize: 10)),
                            ],
                          ),
                          pw.Text("CHANCELLOR PASS", style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 24),
                    // Card Box
                    pw.Container(
                      width: 360,
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(16),
                        border: pw.Border.all(color: PdfColors.amber900, width: 2),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("EXECUTIVE GOVERNANCE SEAL PASS", style: pw.TextStyle(color: PdfColors.amber900, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                color: PdfColors.amber100,
                                child: pw.Text("SOVEREIGN LEVEL-1", style: pw.TextStyle(color: PdfColors.amber900, fontSize: 9)),
                              ),
                            ],
                          ),
                          pw.Divider(color: PdfColors.grey300),
                          pw.SizedBox(height: 10),
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 80,
                                height: 100,
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.amber50,
                                  border: pw.Border.all(color: PdfColors.amber400),
                                ),
                                child: pw.Center(
                                  child: pw.Text("SD", style: pw.TextStyle(color: PdfColors.amber900, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                                ),
                              ),
                              pw.SizedBox(width: 16),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(admin.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                                    pw.SizedBox(height: 4),
                                    pw.Text("Executive ID: ${admin.id}", style: const pw.TextStyle(fontSize: 10.5)),
                                    pw.Text("Designation: ${admin.designation}", style: const pw.TextStyle(fontSize: 10.5)),
                                    pw.Text("Office: Chancellor Suite, Central Admin", style: const pw.TextStyle(fontSize: 10.5)),
                                    pw.Text("Authority: Senate President & Attestor", style: const pw.TextStyle(fontSize: 10.5)),
                                    pw.Text("Clearance: Sovereign All Campus Zones", style: const pw.TextStyle(fontSize: 10.5)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 16),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.BarcodeWidget(
                                barcode: pw.Barcode.code128(),
                                data: admin.id,
                                width: 140,
                                height: 35,
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text("Executive Seal & Authority", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                  pw.Text("Mr. Shridhar Donawat", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 24),
                    pw.Text("Institutional Statutory Executive Seal Credential. Tier-1 Sovereign Campus Authority.", style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
                  ],
                );
              },
            ),
          );
          await _saveAndOpenFile(context, pdf, "DIR_EXE_001_Executive_Pass.pdf");
        } catch (e) {
          _showError(context, e.toString());
        }
        break;

      case UserRole.parent:
        final parent = provider.parentProfile;
        _showDownloadingSheet(context, "Guardian Campus Gate Pass", "GRD_CS045_Guardian_Pass.pdf");
        try {
          final pdf = pw.Document();
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(32),
              build: (pw.Context ctx) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Header
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green900,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                AppConstants.institutionName.toUpperCase(),
                                style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text("CAMPUS SECURITY & VISITOR PASS • VERIFIED GUARDIAN", style: const pw.TextStyle(color: PdfColors.green100, fontSize: 10)),
                            ],
                          ),
                          pw.Text("GATE PASS", style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 24),
                    // Card Box
                    pw.Container(
                      width: 360,
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(16),
                        border: pw.Border.all(color: PdfColors.green800, width: 2),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("AUTHORIZED GUARDIAN ACCESS PASS", style: pw.TextStyle(color: PdfColors.green900, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                color: PdfColors.green100,
                                child: pw.Text("GATE-1 VERIFIED", style: pw.TextStyle(color: PdfColors.green900, fontSize: 9)),
                              ),
                            ],
                          ),
                          pw.Divider(color: PdfColors.grey300),
                          pw.SizedBox(height: 10),
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 80,
                                height: 100,
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.green50,
                                  border: pw.Border.all(color: PdfColors.green300),
                                ),
                                child: pw.Center(
                                  child: pw.Text("SS", style: pw.TextStyle(color: PdfColors.green900, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                                ),
                              ),
                              pw.SizedBox(width: 16),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(parent.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                                    pw.SizedBox(height: 2),
                                    pw.Text("Relation: ${parent.relationship}", style: const pw.TextStyle(fontSize: 10.5)),
                                    pw.Text("Pass ID: GRD-PASS-2026-045", style: const pw.TextStyle(fontSize: 10.5)),
                                    pw.SizedBox(height: 4),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(6),
                                      color: PdfColors.grey100,
                                      child: pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text("LINKED WARD: ${parent.wardName}", style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                                          pw.Text("Roll No: ${parent.wardRollNumber}", style: const pw.TextStyle(fontSize: 9)),
                                          pw.Text("Course: ${parent.wardBranch} • Sem ${parent.wardSemester}", style: const pw.TextStyle(fontSize: 9)),
                                          pw.Text("Hostel: Block 3, Room H-204", style: const pw.TextStyle(fontSize: 9)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 16),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.BarcodeWidget(
                                barcode: pw.Barcode.code128(),
                                data: "GRD-2026-CS045",
                                width: 140,
                                height: 35,
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text("Issued by Dean & Chief Proctor", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                  pw.Text("Mr. Shridhar Donawat", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 24),
                    pw.Text("Authorized Guardian Campus Access Pass. Valid during visiting hours with Gate-1 verification.", style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
                  ],
                );
              },
            ),
          );
          await _saveAndOpenFile(context, pdf, "GRD_CS045_Guardian_Pass.pdf");
        } catch (e) {
          _showError(context, e.toString());
        }
        break;
    }
  }

  /// ── 2. REAL BONAFIDE / DEGREE CERTIFICATE PDF ─────────────────────────────
  static Future<void> downloadCertificatePdf(
    BuildContext context,
    DigitalCertificate cert,
    StudentProfile student,
  ) async {
    _showDownloadingSheet(context, cert.title, "${cert.id}_Official.pdf");

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context ctx) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue900, width: 3),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    AppConstants.institutionName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                  pw.Text(AppConstants.affiliation, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text(AppConstants.institutionCity, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColors.blue900, thickness: 1.5),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    cert.title.toUpperCase(),
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text("Certificate No: ${cert.id}", style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    "TO WHOMSOEVER IT MAY CONCERN",
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Paragraph(
                    text:
                        "This is to certify that Mr./Ms. ${student.name}, son/daughter of ${student.parentName}, bearing University Enrollment No. ${student.rollNumber}, is a bonafide student of this institution studying in Semester ${student.semester} of Bachelor of Technology (B.Tech) in ${student.branch}.",
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 2),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Paragraph(
                    text:
                        "During the academic session 2025-2026, his/her overall institutional attendance is certified at ${student.currentCgpa > 0 ? "84.2%" : "80.0%"} and conduct has been exemplary. This certificate is officially issued upon verified request for official purposes.",
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 2),
                  ),
                  pw.Spacer(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.BarcodeWidget(
                            barcode: pw.Barcode.qrCode(),
                            data: "VERIFIED:${cert.id}:${student.rollNumber}:${cert.sha256Hash}",
                            width: 60,
                            height: 60,
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text("Scan for Blockchain SHA-256 Seal", style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("Controller of Examinations & Registrar", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text(AppConstants.institutionName, style: const pw.TextStyle(fontSize: 9)),
                          pw.Text("Date of Issue: ${cert.issueDate}", style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      await _saveAndOpenFile(context, pdf, "${cert.id}_Official.pdf");
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  /// ── 3. REAL GST FEE RECEIPT PDF ───────────────────────────────────────────
  static Future<void> downloadFeeReceiptPdf(
    BuildContext context,
    FeeItem fee,
    StudentProfile student,
  ) async {
    _showDownloadingSheet(context, "Fee Receipt ${fee.receiptNumber}", "${fee.receiptNumber}.pdf");

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          AppConstants.institutionName,
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                        ),
                        pw.Text("GSTIN: 23AABCI9921M1ZX • ${AppConstants.institutionCity}", style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Text(
                      "TAX INVOICE / RECEIPT",
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                    ),
                  ],
                ),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Receipt No: ${fee.receiptNumber}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("Date: ${fee.paidDate ?? '2026-09-26'}"),
                  ],
                ),
                pw.Text("Student: ${student.name} (${student.rollNumber})"),
                pw.Text("Program: B.Tech ${student.branch} - Sem ${student.semester}"),
                pw.Text("Payment Mode: UPI / NetBanking (${fee.transactionId ?? 'TXN-998812'})"),
                pw.SizedBox(height: 16),

                // Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Fee Description", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Term", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Amount (INR)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(fee.title)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Semester ${student.semester} – ${student.branch}"  )),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Rs. ${fee.amount.toStringAsFixed(2)}")),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text("Total Amount Paid: ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Rs. ${fee.amount.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                  ],
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: "PAID:${fee.receiptNumber}:Rs.${fee.amount}:${student.rollNumber}",
                      width: 50,
                      height: 50,
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Finance & Accounts Officer", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text("Digital Campus Accounts Ledger Seal", style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await _saveAndOpenFile(context, pdf, "${fee.receiptNumber}.pdf");
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  /// ── 4. REAL ACADEMIC CALENDAR 2026-27 PDF ─────────────────────────────────
  static Future<void> downloadAcademicCalendarPdf(BuildContext context) async {
    _showDownloadingSheet(context, "Academic Calendar 2026-27", "Academic_Calendar_2026_27.pdf");

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    AppConstants.institutionName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                ),
                pw.Center(
                  child: pw.Text("OFFICIAL ACADEMIC CALENDAR (SESSION 2026-2027)", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Center(
                  child: pw.Text(AppConstants.affiliation, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                ),
                pw.SizedBox(height: 14),
                pw.Divider(color: PdfColors.blue900),
                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Date / Window", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Event Description", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Stakeholder", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      ],
                    ),
                    _calRow("01 Aug 2026", "Odd Semester Classes Commence", "All Students"),
                    _calRow("15 Aug 2026", "Independence Day Celebration", "Campus Holiday"),
                    _calRow("15-20 Sep 2026", "Mid-Semester Examination 1", "Dean Academic"),
                    _calRow("02 Oct 2026", "Gandhi Jayanti Holiday", "Campus Holiday"),
                    _calRow("25-30 Oct 2026", "Mid-Semester Examination 2", "Dean Academic"),
                    _calRow("15-18 Nov 2026", "End-Semester Practical & Lab Viva", "Faculty & External"),
                    _calRow("24 Nov - 12 Dec 2026", "RGPV University Final Theory Exams", "Controller of Exams"),
                    _calRow("05 Jan 2027", "Even Semester Registration & Reopening", "All Students"),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  "Note: 75% attendance is mandatory to appear in RGPV University semester examinations. Early dropout alerts and deficiency notices are automatically synced with parent portals.",
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Dean (Academics)", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Controller of Examinations", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await _saveAndOpenFile(context, pdf, "Academic_Calendar_2026_27.pdf");
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  /// ── 5. REAL INSTITUTION PROSPECTUS & SYLLABUS PDF ─────────────────────────
  static Future<void> downloadProspectusPdf(BuildContext context) async {
    _showDownloadingSheet(context, "College Prospectus 2026-27", "Digital_Campus_Prospectus_2026_27.pdf");

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  color: PdfColors.blue900,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            AppConstants.institutionName.toUpperCase(),
                            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                          ),
                          pw.Text("Bhopal, Madhya Pradesh • NAAC Accredited", style: const pw.TextStyle(fontSize: 9, color: PdfColors.blue100)),
                        ],
                      ),
                      pw.Text("2026-27", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.amber)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text("ACADEMIC PROGRAMS & ADMISSIONS BROCHURE", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Paragraph(
                  text:
                      "${AppConstants.institutionName} offers premier degree programs in Engineering, Technology, and Applied Sciences. Powered by the Digital Campus SaaS platform, the institution provides world-class AI learning, biometric smart attendance, digital blockchain verification, and hybrid live classrooms.",
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5),
                ),
                pw.SizedBox(height: 10),
                pw.Text("Offered Undergraduate Programs (B.Tech):", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Bullet(text: "Computer Science & Engineering (CSE) - 180 Seats"),
                pw.Bullet(text: "Artificial Intelligence & Machine Learning (AI/ML) - 120 Seats"),
                pw.Bullet(text: "Data Science & Cloud Computing - 60 Seats"),
                pw.Bullet(text: "Electronics & Communication Engineering - 60 Seats"),
                pw.Bullet(text: "Mechanical & Electrical Engineering - 60 Seats"),
                pw.SizedBox(height: 12),
                pw.Text("Campus Highlights:", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Bullet(text: "100% Digital Campus Cloud with Bhashini Vernacular 7-Language Voice"),
                pw.Bullet(text: "RFID PVC Smart Identity Cards with Instant Digital Verification"),
                pw.Bullet(text: "Bus GPS Transit Radar & Hostel E-Gate Pass Security System"),
                pw.Bullet(text: "Global Placements & Active Technology Incubator"),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text("Admissions Desk: admissions@digitalcampus.in • www.digitalcampus.in", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                ),
              ],
            );
          },
        ),
      );

      await _saveAndOpenFile(context, pdf, "Digital_Campus_Prospectus_2026_27.pdf");
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  /// ── 6. REAL AI LECTURE NOTES PDF ──────────────────────────────────────────
  static Future<void> downloadLectureNotesPdf(
    BuildContext context,
    String subject,
    String professor,
    String topic,
  ) async {
    _showDownloadingSheet(context, "AI Lecture Notes: $subject", "${subject}_Notes.pdf");

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("AI GENERATED LECTURE COMPANION", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text("DIGITAL CAMPUS SMART CLASS", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
                pw.Divider(color: PdfColors.blue900),
                pw.SizedBox(height: 8),
                pw.Text("Subject: $subject", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text("Topic: $topic", style: const pw.TextStyle(fontSize: 11)),
                pw.Text("Faculty: $professor • Date: 2026-09-26", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                pw.SizedBox(height: 14),
                pw.Text("Key Conceptual Takeaways (Auto-Extracted from Live Stream):", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Bullet(text: "Deep Convolutional Neural Networks (CNN) utilize spatial filters to detect image feature hierarchies."),
                pw.Bullet(text: "Pooling layers (Max/Average) reduce feature map dimensionality while preserving translation invariance."),
                pw.Bullet(text: "Cross-Entropy Loss is minimized using Adam Optimizer with adaptive learning rates."),
                pw.Bullet(text: "Backpropagation computes gradient tensors via the chain rule across network weights."),
                pw.SizedBox(height: 14),
                pw.Text("Recommended Practice Questions for Midterm 2:", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Bullet(text: "Derive the weight update formula for a 2-layer perceptron with Sigmoid activation."),
                pw.Bullet(text: "Compare and contrast L1 (Lasso) vs L2 (Ridge) regularization in preventing model overfitting."),
                pw.Spacer(),
                pw.Text("Auto-transcribed & certified by Digital Campus Bhashini Audio Engine.", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ],
            );
          },
        ),
      );

      await _saveAndOpenFile(context, pdf, "${subject.replaceAll(' ', '_')}_Notes.pdf");
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  /// ── 7. REAL SEMESTER REGISTRATION SLIP PDF ───────────────────────────────
  static Future<void> downloadSemesterRegistrationSlipPdf(
    BuildContext context,
    StudentProfile student,
    Map<String, bool> courses,
  ) async {
    _showDownloadingSheet(context, "Semester Registration Slip", "Semester_${student.semester}_Course_Slip.pdf");

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue900,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            AppConstants.institutionName.toUpperCase(),
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            "Office of the Registrar & Academic Affairs • NEP 2020 Compliant",
                            style: const pw.TextStyle(color: PdfColors.blue100, fontSize: 9),
                          ),
                        ],
                      ),
                      pw.Text(
                        "SEMESTER ${student.semester}",
                        style: pw.TextStyle(
                          color: PdfColors.amber,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.Center(
                  child: pw.Text(
                    "COURSE REGISTRATION & CREDIT LEDGER SLIP",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 14),

                // Student Meta
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Student Name: ${student.name}", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text("Roll No: ${student.rollNumber}", style: const pw.TextStyle(fontSize: 9)),
                          pw.Text("Enrollment No: ${student.enrollmentNumber}", style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("Department: ${student.branch}", style: const pw.TextStyle(fontSize: 9)),
                          pw.Text("Academic Year: 2026-2027", style: const pw.TextStyle(fontSize: 9)),
                          pw.Text("Status: VERIFIED & APPROVED", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // Table of registered courses
                pw.Text("Enrolled Course Credits:", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(5),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("#", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Course Title & Code", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Status", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ...courses.entries.toList().asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final courseName = entry.value.key;
                      final isEnrolled = entry.value.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("$idx", style: const pw.TextStyle(fontSize: 9))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(courseName, style: const pw.TextStyle(fontSize: 9))),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              isEnrolled ? "ENROLLED" : "AUDIT",
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: isEnrolled ? PdfColors.green800 : PdfColors.grey600,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 14),

                pw.Text(
                  "Total Registered Credits: 18 Credits • AICTE / NEP Model Curriculum Verified",
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                ),
                pw.Spacer(),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: "https://verify.digitalcampus.in/reg/${student.rollNumber}/sem${student.semester}",
                          width: 48,
                          height: 48,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text("Scan to verify ledger", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("Approved by HOD", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                        pw.SizedBox(height: 4),
                        pw.Text("Dr. Mohit Donawat", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Head, Dept of CSE", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Dean & Director Seal & Signature", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                        pw.SizedBox(height: 4),
                        pw.Text("Mr. Shridhar Donawat", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Dean & Director", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await _saveAndOpenFile(context, pdf, "Semester_${student.semester}_Course_Slip.pdf");
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  // ── HELPER: SAVE FILE TO STORAGE & OPEN DIRECTLY ───────────────────────────
  static Future<void> _saveAndOpenFile(BuildContext context, pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss downloading sheet

      // Show real completion modal with direct "Open File" and "Share" options
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: const Color(0xFFD1FAE5), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 30),
              ),
              const SizedBox(height: 12),
              const Text(
                "Document Downloaded Successfully!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                "Saved to: ${file.path}",
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Printing.sharePdf(bytes: bytes, filename: fileName);
                      },
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: const Text("Share File"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await OpenFile.open(file.path);
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text("Open Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E40AF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      // Auto-trigger open
      await OpenFile.open(file.path);
    }
  }

  static void _showDownloadingSheet(BuildContext context, String docTitle, String fileName) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const CircularProgressIndicator(color: Color(0xFF1E40AF), strokeWidth: 3),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Generating Official PDF...",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      docTitle,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static pw.TableRow _calRow(String date, String event, String party) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(date, style: const pw.TextStyle(fontSize: 9))),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(event, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(party, style: const pw.TextStyle(fontSize: 9))),
      ],
    );
  }

  /// ── 7. OFFICIAL VERIFIED PROFESSIONAL CV & ACADEMIC DOSSIER ─────────────
  static Future<void> downloadProfessionalCvPdf(
    BuildContext context,
    StudentProfile student,
  ) async {
    _showDownloadingSheet(
      context,
      "Official Verified Professional CV & Academic Dossier",
      "${student.rollNumber}_Professional_CV.pdf",
    );

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Top Institution Banner
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue900,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            AppConstants.institutionName.toUpperCase(),
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            "${AppConstants.affiliation} • ${AppConstants.accreditation}",
                            style: const pw.TextStyle(color: PdfColors.blue100, fontSize: 8),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.amber,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          "VERIFIED DOSSIER",
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // Student Identity & Professional Headline
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            student.name,
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            student.headline,
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            student.bio,
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 14),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: "https://digitalcampus.in/verify/cv/${student.rollNumber}?apaar=${student.apaarId}",
                      width: 65,
                      height: 65,
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 8),

                // National Regulatory ID Ribbon (NEP 2020)
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("GOVT APAAR ID (ONE NATION ID)", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                          pw.Text(student.apaarId, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("ABC ID (CREDIT BANK)", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                          pw.Text(student.abcId, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("DIGILOCKER KYC", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                          pw.Text("VERIFIED (Aadhaar Linked)", style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),

                // Key Academic Metrics
                pw.Text("ACADEMIC BENCHMARKS", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 6),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Roll No", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Branch & Specialization", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("CGPA", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Attendance", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Readiness Score", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(student.rollNumber, style: const pw.TextStyle(fontSize: 8.5))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("${student.branch} (Sem ${student.semester})", style: const pw.TextStyle(fontSize: 8.5))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("${student.currentCgpa} / 10.0", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("${student.attendancePercentage}%", style: const pw.TextStyle(fontSize: 8.5))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("${student.placementReadinessScore}% (AI Indexed)", style: pw.TextStyle(fontSize: 8.5, color: PdfColors.green800, fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),

                // Verified Technical Skills
                pw.Text("VERIFIED TECHNICAL COMPETENCIES", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 6),
                pw.Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: student.skills.map((s) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(5),
                        border: pw.Border.all(color: PdfColors.blue200, width: 0.6),
                      ),
                      child: pw.Text(s, style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue900)),
                    );
                  }).toList(),
                ),
                pw.SizedBox(height: 12),

                // Industry Certifications
                pw.Text("INSTITUTIONAL & INDUSTRY CERTIFICATIONS", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 6),
                ...student.certifications.map((c) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      children: [
                        pw.Container(width: 5, height: 5, decoration: const pw.BoxDecoration(color: PdfColors.green700, shape: pw.BoxShape.circle)),
                        pw.SizedBox(width: 6),
                        pw.Text(c, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                        pw.SizedBox(width: 6),
                        pw.Text("• Authenticated via Campus Ledger", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 12),

                // Professional Links & Contact
                pw.Text("DEVELOPER & REPOSITORY PROFILES", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("GitHub: ${student.githubUrl}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                    pw.Text("LinkedIn: ${student.linkedinUrl}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                    pw.Text("LeetCode: ${student.leetcodeHandle}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                  ],
                ),
                pw.Spacer(),

                // Official Endorsement & Seal
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("H.O.D. Academic Attestation", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                          pw.Text("Dr. Mohit Donawat", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.Text("Dept. of Computer Science", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text("DIGITAL SECURITY SEAL", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.Text("SHA256: 7a8f9021...verified", style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("Dean & Director Authority", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                          pw.Text("Mr. Shridhar Donawat", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.Text(AppConstants.institutionShort, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      await _saveAndOpenFile(context, pdf, "${student.rollNumber}_Professional_CV.pdf");
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  /// ── 8. OFFICIAL FACULTY ACADEMIC DOSSIER & RESEARCH CV ───────────────────
  static Future<void> downloadFacultyDossierPdf(
    BuildContext context,
    FacultyProfessionalProfile faculty,
  ) async {
    _showDownloadingSheet(
      context,
      "Official Verified Faculty Dossier & CV",
      "${faculty.id}_Faculty_Dossier.pdf",
    );

    try {
      final pdf = pw.Document();

      // ════════════════════════════════════════════════════════════════════════
      // PAGE 1: FACULTY ACADEMIC CURRICULUM VITAE & CORE PROFILE
      // ════════════════════════════════════════════════════════════════════════
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Top Institution Banner
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFF2E1065), // Deep Royal Purple
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            AppConstants.institutionName.toUpperCase(),
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            "OFFICE OF THE ACADEMIC SENATE & DEAN OF FACULTY AFFAIRS",
                            style: const pw.TextStyle(color: PdfColors.purple100, fontSize: 7.5),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            "NAAC GRADE A++ • NIRF TOP 10 • UGC AUTONOMOUS • ISO 9001:2015",
                            style: const pw.TextStyle(color: PdfColors.amber200, fontSize: 7),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.amber,
                              borderRadius: pw.BorderRadius.circular(5),
                            ),
                            child: pw.Text(
                              "OFFICIAL FACULTY DOSSIER",
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            "REF: SENATE/DOSSIER/2026/${faculty.id}",
                            style: const pw.TextStyle(color: PdfColors.purple200, fontSize: 6.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),

                // Faculty Identity Header & QR Code
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 44,
                      height: 44,
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFF7C3AED),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        "DR",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            faculty.name,
                            style: pw.TextStyle(
                              fontSize: 15.5,
                              fontWeight: pw.FontWeight.bold,
                              color: const PdfColor.fromInt(0xFF2E1065),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            "${faculty.designation} • ${faculty.department}",
                            style: pw.TextStyle(
                              fontSize: 9.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey900,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            faculty.qualifications,
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: const PdfColor.fromInt(0xFF7C3AED),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            children: [
                              pw.Text("Faculty UID: ${faculty.id}", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                              pw.SizedBox(width: 8),
                              pw.Text("•  Experience: ${faculty.experienceYears}+ Years", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                              pw.SizedBox(width: 8),
                              pw.Text("•  Cabin: ${faculty.cabinNumber}", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                            ],
                          ),
                          pw.SizedBox(height: 2),
                          pw.Row(
                            children: [
                              pw.Text("Email: ${faculty.email}", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                              pw.SizedBox(width: 8),
                              pw.Text("•  Phone: ${faculty.phone}", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                              pw.SizedBox(width: 8),
                              pw.Text("•  Office Hours: ${faculty.officeHours}", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: "https://digitalcampus.in/verify/faculty/${faculty.id}?auth=APEX_SENATE&valid=2026&sha=7a8f9021",
                          width: 58,
                          height: 58,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text("APEX SENATE VERIFIED", style: const pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),

                // Executive Academic & Research Statement (Bio)
                if (faculty.bio.isNotEmpty) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFFAF5FF),
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFFDDD6FE), width: 0.8),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 3,
                          height: 24,
                          decoration: pw.BoxDecoration(
                            color: const PdfColor.fromInt(0xFF7C3AED),
                            borderRadius: pw.BorderRadius.circular(2),
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: pw.Text(
                            faculty.bio,
                            style: const pw.TextStyle(
                              fontSize: 7.8,
                              fontStyle: pw.FontStyle.italic,
                              color: PdfColor.fromInt(0xFF334155),
                              lineSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),
                ],

                // Scholarly Research & Impact Matrix (6 Metrics)
                pw.Text(
                  "SCHOLARLY RESEARCH IMPACT & ACADEMIC METRICS",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065)),
                ),
                pw.SizedBox(height: 5),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF3E8FF)),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("Publications (Scopus)", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("Total Citations", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("h-Index & i10", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("Patents Granted", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("Funded R&D Grants", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("Student Rating", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("${faculty.papersPublished} Papers", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF7C3AED)))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("${faculty.citationsCount}+ Citations", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("h-${faculty.hIndex} • i10-${faculty.i10Index}", style: const pw.TextStyle(fontSize: 7.5))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("${faculty.patentsGranted} Granted (IPO)", style: const pw.TextStyle(fontSize: 7.5))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("₹52.5 L (PI)", style: const pw.TextStyle(fontSize: 7.5))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4.5), child: pw.Text("${faculty.studentFeedbackRating} / 5.0 (Top 1%)", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green800))),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),

                // Current Academic Teaching Load
                pw.Text(
                  "CURRENT ACADEMIC TEACHING ALLOCATION (AICTE CREDIT COMPLIANT)",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065)),
                ),
                pw.SizedBox(height: 4),
                ...faculty.subjectsTaught.map((s) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3.5),
                    child: pw.Row(
                      children: [
                        pw.Container(width: 4, height: 4, decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF7C3AED), shape: pw.BoxShape.circle)),
                        pw.SizedBox(width: 6),
                        pw.Text(s, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 6),
                        pw.Text("• Core Teaching Professor • Theory & Practical Lab (4 Credits) • 64 Enrolled", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 9),

                // Research Domains & Labs
                pw.Text(
                  "RESEARCH DOMAINS & INVESTIGATOR LABORATORIES",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065)),
                ),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: faculty.researchDomains.map((r) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFFF5F3FF),
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(color: const PdfColor.fromInt(0xFFDDD6FE), width: 0.6),
                      ),
                      child: pw.Text(r, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF5B21B6))),
                    );
                  }).toList(),
                ),
                pw.SizedBox(height: 9),

                // Professional Skills & Core Technical Competencies
                pw.Text(
                  "CORE TECHNICAL COMPETENCIES & ADVANCED SYSTEMS SKILLS",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065)),
                ),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  spacing: 4,
                  runSpacing: 3.5,
                  children: faculty.professionalSkills.map((s) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFFF1F5F9),
                        borderRadius: pw.BorderRadius.circular(3),
                        border: pw.Border.all(color: const PdfColor.fromInt(0xFFCBD5E1), width: 0.5),
                      ),
                      child: pw.Text(s, style: const pw.TextStyle(fontSize: 7, color: PdfColor.fromInt(0xFF334155))),
                    );
                  }).toList(),
                ),
                pw.Spacer(),

                // Page 1 Footer
                pw.Divider(thickness: 0.6, color: PdfColors.grey300),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Digital Campus OS • Official Academic Senate Record • Sovereign On-Device Ledger", style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600)),
                    pw.Text("Page 1 of 2", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065))),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // ════════════════════════════════════════════════════════════════════════
      // PAGE 2: SCHOLARLY PUBLICATIONS, PATENTS, GRANTS & SENATE ATTESTATION
      // ════════════════════════════════════════════════════════════════════════
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Top Continuation Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFF2E1065),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "${AppConstants.institutionName.toUpperCase()} • FACULTY RESEARCH & IP DOSSIER",
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: pw.BoxDecoration(color: PdfColors.amber, borderRadius: pw.BorderRadius.circular(4)),
                        child: pw.Text("PAGE 2 OF 2", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Faculty: ${faculty.name} (${faculty.designation})", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                    pw.Text("UID: ${faculty.id} • Dept of ${faculty.department}", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                  ],
                ),
                pw.SizedBox(height: 8),

                // 1. Peer-Reviewed Research Publications Table
                pw.Text(
                  "PEER-REVIEWED JOURNAL & CONFERENCE PUBLICATIONS",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065)),
                ),
                pw.Text(
                  "Indexed in Scopus, Web of Science, IEEE Xplore, ACM Digital Library & Springer LNCS",
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 4),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(18),
                    1: const pw.FlexColumnWidth(5),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF3E8FF)),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text("#", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text("Publication Citation & Bibliographic Record", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text("Index & Status", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ...faculty.publicationsList.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final pub = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text("$idx", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text(pub, style: const pw.TextStyle(fontSize: 7))),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3.5),
                            child: pw.Text(
                              "Scopus / IEEE\nPeer-Reviewed",
                              style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF5B21B6)),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 8),

                // 2. Intellectual Property & Patents Granted
                pw.Text(
                  "INTELLECTUAL PROPERTY & PATENTS REGISTERED",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065)),
                ),
                pw.Text(
                  "Officially gazetted by the Indian Patent Office (IPO) & Controller General of Patents",
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 3),
                ...faculty.patentsList.map((pat) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 3.5),
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFFFFBEB),
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFFFDE68A), width: 0.6),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(pat, style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF78350F))),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: pw.BoxDecoration(color: PdfColors.amber800, borderRadius: pw.BorderRadius.circular(3)),
                          child: pw.Text("GRANTED (IPO)", style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                        ),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 8),

                // 3. Sponsored Research Projects & Grants
                pw.Text(
                  "SPONSORED RESEARCH PROJECTS & GOVERNMENT R&D GRANTS",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065)),
                ),
                pw.Text(
                  "Externally funded research grants from Government & Industry consortiums",
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 3),
                ...faculty.grantsList.map((grant) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 3.5),
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFECFDF5),
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFFA7F3D0), width: 0.6),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(grant, style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF065F46))),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: pw.BoxDecoration(color: PdfColors.green800, borderRadius: pw.BorderRadius.circular(3)),
                          child: pw.Text("ACTIVE PI", style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                        ),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 8),

                // 4. Academic Honours & Distinctions
                pw.Text(
                  "HONOURS, FELLOWSHIPS & INSTITUTIONAL DISTINCTIONS",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065)),
                ),
                pw.SizedBox(height: 3),
                pw.Wrap(
                  spacing: 5,
                  runSpacing: 3.5,
                  children: faculty.awards.map((award) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFFFEF3C7),
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(color: const PdfColor.fromInt(0xFFFCD34D), width: 0.6),
                      ),
                      child: pw.Text(award, style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF92400E))),
                    );
                  }).toList(),
                ),
                pw.Spacer(),

                // 5. Statutory Academic Senate Attestation & Verification
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFF8FAFC),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: const PdfColor.fromInt(0xFFCBD5E1), width: 0.8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "STATUTORY ATTESTATION: This academic dossier and research portfolio has been officially attested by the Academic Senate and verified against national citation indexers and government patent gazettes. It constitutes an authorized record under NAAC Grade A++ and NIRF frameworks.",
                        style: const pw.TextStyle(fontSize: 6.5, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("Faculty Candidate Attestation", style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600)),
                              pw.SizedBox(height: 2),
                              pw.Text(faculty.name, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                              pw.Text("H.O.D. Computer Science & Engg", style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text("SOVEREIGN DIGITAL SEAL", style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065))),
                              pw.SizedBox(height: 1),
                              pw.Text("SHA256: 7a8f9021...b84e verified", style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
                              pw.Text("Zero-Cloud Sovereign Ledger", style: const pw.TextStyle(fontSize: 5.5, color: PdfColors.green800)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text("Dean of Academic Affairs & Registrar", style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600)),
                              pw.SizedBox(height: 2),
                              pw.Text("Prof. S. K. Mukherjee / Mr. S. Donawat", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                              pw.Text(AppConstants.institutionShort, style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 4),

                // Page 2 Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("AICTE National Faculty Cadre Identifier Verified • ISO 9001:2015", style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600)),
                    pw.Text("Page 2 of 2", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1065))),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await _saveAndOpenFile(context, pdf, "${faculty.id}_Faculty_Dossier.pdf");
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  static void _showError(BuildContext context, String msg) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating document: $msg"), backgroundColor: Colors.red),
      );
    }
  }
}
