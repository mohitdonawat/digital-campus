import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecordModel {
  final String id;
  final String teacherUid;
  final String teacherName;
  final String teacherTitle;
  final String branch;
  final String year;
  final String semester;
  final String section;
  final String subject;
  final String period;
  final DateTime date;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  // studentUid -> 'P' (Present) or 'A' (Absent)
  final Map<String, String> statusMap;
  // studentUid -> Student Details snapshot (name, rollNo)
  final Map<String, Map<String, String>> studentDetails;
  final DateTime createdAt;

  AttendanceRecordModel({
    required this.id,
    required this.teacherUid,
    required this.teacherName,
    this.teacherTitle = 'Prof',
    required this.branch,
    required this.year,
    required this.semester,
    required this.section,
    required this.subject,
    required this.period,
    required this.date,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.statusMap,
    this.studentDetails = const {},
    required this.createdAt,
  });

  double get percentage =>
      totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherUid': teacherUid,
      'teacherName': teacherName,
      'teacherTitle': teacherTitle,
      'branch': branch,
      'year': year,
      'semester': semester,
      'section': section,
      'subject': subject,
      'period': period,
      'date': Timestamp.fromDate(date),
      'totalStudents': totalStudents,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'statusMap': statusMap,
      'studentDetails': studentDetails,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AttendanceRecordModel.fromMap(Map<String, dynamic> map, String docId) {
    Map<String, String> parsedStatus = {};
    if (map['statusMap'] != null) {
      (map['statusMap'] as Map<dynamic, dynamic>).forEach((k, v) {
        parsedStatus[k.toString()] = v.toString();
      });
    }

    Map<String, Map<String, String>> parsedDetails = {};
    if (map['studentDetails'] != null) {
      (map['studentDetails'] as Map<dynamic, dynamic>).forEach((k, v) {
        if (v is Map) {
          Map<String, String> sub = {};
          v.forEach((sk, sv) => sub[sk.toString()] = sv.toString());
          parsedDetails[k.toString()] = sub;
        }
      });
    }

    return AttendanceRecordModel(
      id: docId,
      teacherUid: map['teacherUid'] ?? '',
      teacherName: map['teacherName'] ?? '',
      teacherTitle: map['teacherTitle'] ?? 'Prof',
      branch: map['branch'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '',
      section: map['section'] ?? '',
      subject: map['subject'] ?? '',
      period: map['period'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalStudents: map['totalStudents'] ?? 0,
      presentCount: map['presentCount'] ?? 0,
      absentCount: map['absentCount'] ?? 0,
      statusMap: parsedStatus,
      studentDetails: parsedDetails,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
