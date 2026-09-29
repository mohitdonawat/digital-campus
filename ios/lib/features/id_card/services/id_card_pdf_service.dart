import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class IdCardPdfService {
  /// Generates an official print-ready A4 document containing Front and Back of the ID card
  static Future<Uint8List> generatePrintableIdCardPdf({
    required Uint8List frontImageBytes,
    Uint8List? backImageBytes,
    required String studentName,
    required String enrollmentNo,
  }) async {
    final pdf = pw.Document();

    final frontImg = pw.MemoryImage(frontImageBytes);
    final backImg = backImageBytes != null ? pw.MemoryImage(backImageBytes) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Document Header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('#1E3A8A'), width: 1.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'IES UNIVERSITY / IES COLLEGE OF TECHNOLOGY, BHOPAL',
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1E3A8A'),
                          ),
                        ),
                        pw.Text(
                          'Official Student Identity Card • Print & PVC Lamination Sheet',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            color: PdfColor.fromHex('#475569'),
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'ENROLL: $enrollmentNo',
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0F172A'),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Two Cards Side by Side (Front & Back) with Cut Guidelines
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Front Card Container
                  pw.Column(
                    children: [
                      pw.Text(
                        'FRONT SIDE (मुख पृष्ठ)',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1E3A8A'),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Container(
                        width: 220,
                        height: 345,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColor.fromHex('#94A3B8'), width: 0.8),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                        ),
                        child: pw.ClipRRect(
                          horizontalRadius: 11,
                          verticalRadius: 11,
                          child: pw.Image(frontImg, fit: pw.BoxFit.contain),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        '✂ Standard PVC Dimension: 54mm x 85.6mm',
                        style: pw.TextStyle(fontSize: 7, color: PdfColor.fromHex('#64748B')),
                      ),
                    ],
                  ),

                  pw.SizedBox(width: 24),

                  // Back Card Container
                  if (backImg != null)
                    pw.Column(
                      children: [
                        pw.Text(
                          'BACK SIDE (पृष्ठ भाग)',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1E3A8A'),
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Container(
                          width: 220,
                          height: 345,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColor.fromHex('#94A3B8'), width: 0.8),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 11,
                            verticalRadius: 11,
                            child: pw.Image(backImg, fit: pw.BoxFit.contain),
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          '✂ Fold or laminate back-to-back',
                          style: pw.TextStyle(fontSize: 7, color: PdfColor.fromHex('#64748B')),
                        ),
                      ],
                    ),
                ],
              ),

              pw.SizedBox(height: 32),

              // Printing & Laminating Instructions
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'IMPORTANT INSTRUCTIONS FOR PVC BADGE PRINTING:',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0F172A'),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '1. Print on 300 GSM photo sheet or standard CR-80 PVC identity card blank.',
                      style: pw.TextStyle(fontSize: 7.5, color: PdfColor.fromHex('#334155')),
                    ),
                    pw.Text(
                      '2. Punch slot hole at top center mark for neck lanyard clip.',
                      style: pw.TextStyle(fontSize: 7.5, color: PdfColor.fromHex('#334155')),
                    ),
                    pw.Text(
                      '3. This digital card is officially generated by IES E-Campus and bears the institutional seal.',
                      style: pw.TextStyle(fontSize: 7.5, color: PdfColor.fromHex('#334155')),
                    ),
                    pw.Text(
                      '4. In case of verification questions, contact Registrar Office, IES Campus, Ratibad Road, Bhopal.',
                      style: pw.TextStyle(fontSize: 7.5, color: PdfColor.fromHex('#334155')),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Verification footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Student: $studentName',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#64748B')),
                  ),
                  pw.Text(
                    'IES E-Campus Official Document Service',
                    style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#94A3B8')),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
