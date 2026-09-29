import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryResourceModel {
  final String id;
  final String title;
  final String subject;
  final String department;
  final String year;
  final String semester;
  final String resourceType; // 'Lecture Notes', 'Lab Manual', 'Question Bank', 'Syllabus', 'Reference Book'
  final String description;
  final String resourceUrl;
  final String fileType; // 'PDF', 'LINK', 'DOC', 'NOTES'
  final String fileName;
  final String fileSize;
  final String? pdfBase64; // Base64 data if embedded directly
  final String uploadedBy;
  final DateTime uploadedAt;

  LibraryResourceModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.department,
    required this.year,
    this.semester = 'ALL',
    required this.resourceType,
    this.description = '',
    required this.resourceUrl,
    this.fileType = 'PDF',
    this.fileName = '',
    this.fileSize = '',
    this.pdfBase64,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'department': department,
      'year': year,
      'semester': semester,
      'resourceType': resourceType,
      'description': description,
      'resourceUrl': resourceUrl,
      'fileType': fileType,
      'fileName': fileName,
      'fileSize': fileSize,
      'pdfBase64': pdfBase64,
      'uploadedBy': uploadedBy,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  factory LibraryResourceModel.fromMap(Map<String, dynamic> map, String docId) {
    return LibraryResourceModel(
      id: docId,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      department: map['department'] ?? 'ALL',
      year: map['year'] ?? 'ALL',
      semester: map['semester'] ?? 'ALL',
      resourceType: map['resourceType'] ?? 'Lecture Notes',
      description: map['description'] ?? '',
      resourceUrl: map['resourceUrl'] ?? '',
      fileType: map['fileType'] ?? (map['resourceUrl']?.toString().toLowerCase().endsWith('.pdf') == true ? 'PDF' : 'LINK'),
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? '',
      pdfBase64: map['pdfBase64'],
      uploadedBy: map['uploadedBy'] ?? 'Faculty',
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
