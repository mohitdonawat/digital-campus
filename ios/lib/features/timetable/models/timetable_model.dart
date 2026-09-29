import 'package:cloud_firestore/cloud_firestore.dart';

class TimetablePeriodSlot {
  final String day;          // "Monday", "Tuesday", etc.
  final int periodNumber;    // 1 to 8
  final String periodName;   // "1st Period (8:00 - 9:00)"
  final String startTime;    // "08:00"
  final String endTime;      // "09:00"
  final String subject;      // "Database Management Systems"
  final String branch;       // "Computer Science & Engineering"
  final String year;         // "3rd Year"
  final String semester;     // "6th Semester"
  final String section;      // "A"
  final String room;         // "Room 204"
  final String facultyName;  // "Prof. Sharma"

  TimetablePeriodSlot({
    required this.day,
    required this.periodNumber,
    required this.periodName,
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.branch = 'Computer Science & Engineering',
    this.year = '3rd Year',
    this.semester = '6th Semester',
    this.section = 'A',
    this.room = 'Classroom 101',
    this.facultyName = 'Faculty',
  });

  TimetablePeriodSlot copyWith({
    String? day,
    int? periodNumber,
    String? periodName,
    String? startTime,
    String? endTime,
    String? subject,
    String? branch,
    String? year,
    String? semester,
    String? section,
    String? room,
    String? facultyName,
  }) {
    return TimetablePeriodSlot(
      day: day ?? this.day,
      periodNumber: periodNumber ?? this.periodNumber,
      periodName: periodName ?? this.periodName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subject: subject ?? this.subject,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      room: room ?? this.room,
      facultyName: facultyName ?? this.facultyName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'periodNumber': periodNumber,
      'periodName': periodName,
      'startTime': startTime,
      'endTime': endTime,
      'subject': subject,
      'branch': branch,
      'year': year,
      'semester': semester,
      'section': section,
      'room': room,
      'facultyName': facultyName,
    };
  }

  factory TimetablePeriodSlot.fromMap(Map<String, dynamic> map) {
    return TimetablePeriodSlot(
      day: map['day'] ?? 'Monday',
      periodNumber: map['periodNumber'] is int ? map['periodNumber'] : int.tryParse(map['periodNumber'].toString()) ?? 1,
      periodName: map['periodName'] ?? '1st Period (8:00 - 9:00)',
      startTime: map['startTime'] ?? '08:00',
      endTime: map['endTime'] ?? '09:00',
      subject: map['subject'] ?? 'Academic Lecture',
      branch: map['branch'] ?? 'Computer Science & Engineering',
      year: map['year'] ?? '3rd Year',
      semester: map['semester'] ?? '6th Semester',
      section: map['section'] ?? 'A',
      room: map['room'] ?? 'Classroom 101',
      facultyName: map['facultyName'] ?? 'Faculty',
    );
  }
}

class TimetableModel {
  final String id;
  final String title;          // e.g. "Weekly Academic Schedule"
  final String imageUrl;       // Firebase Storage / Image path or URL
  final String fileName;       // Filename
  final String sentByUid;      // Teacher or admin UID
  final String sentByName;     // Display name
  final String sentByRole;     // 'teacher' or 'admin'
  final String sentByTitle;    // Dr / Prof / Mr
  
  // Target audience
  final String targetBranch;   // 'ALL' or branch
  final String targetYear;     // 'ALL' or year
  final String targetSemester; // 'ALL' or semester
  final String targetSection;  // 'ALL' or section
  
  // Text format schedule & structured periods
  final String extractedScheduleText;
  final List<TimetablePeriodSlot> slots;

  final DateTime createdAt;
  final bool isActive;

  TimetableModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.fileName = '',
    required this.sentByUid,
    required this.sentByName,
    this.sentByRole = 'teacher',
    this.sentByTitle = 'Mr',
    this.targetBranch = 'ALL',
    this.targetYear = 'ALL',
    this.targetSemester = 'ALL',
    this.targetSection = 'ALL',
    this.extractedScheduleText = '',
    this.slots = const [],
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'fileName': fileName,
      'sentByUid': sentByUid,
      'sentByName': sentByName,
      'sentByRole': sentByRole,
      'sentByTitle': sentByTitle,
      'targetBranch': targetBranch,
      'targetYear': targetYear,
      'targetSemester': targetSemester,
      'targetSection': targetSection,
      'extractedScheduleText': extractedScheduleText,
      'slots': slots.map((s) => s.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  factory TimetableModel.fromMap(Map<String, dynamic> map, String docId) {
    List<TimetablePeriodSlot> parsedSlots = [];
    if (map['slots'] != null && map['slots'] is List) {
      for (final item in (map['slots'] as List)) {
        if (item is Map) {
          parsedSlots.add(TimetablePeriodSlot.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    return TimetableModel(
      id: docId,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      sentByUid: map['sentByUid'] ?? '',
      sentByName: map['sentByName'] ?? '',
      sentByRole: map['sentByRole'] ?? 'teacher',
      sentByTitle: map['sentByTitle'] ?? 'Mr',
      targetBranch: map['targetBranch'] ?? 'ALL',
      targetYear: map['targetYear'] ?? 'ALL',
      targetSemester: map['targetSemester'] ?? map['semester'] ?? 'ALL',
      targetSection: map['targetSection'] ?? 'ALL',
      extractedScheduleText: map['extractedScheduleText'] ?? '',
      slots: parsedSlots,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  /// Check if this timetable is relevant for a student
  bool isRelevantFor({
    required String branch,
    required String year,
    required String section,
    String? semester,
  }) {
    final b1 = targetBranch.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final b2 = branch.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final branchMatch = targetBranch == 'ALL' || b1.isEmpty || b2.isEmpty || b1.contains(b2) || b2.contains(b1);

    final y1 = targetYear.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final y2 = year.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final yearMatch = targetYear == 'ALL' || y1.isEmpty || y2.isEmpty || y1 == y2 || y1.contains(y2) || y2.contains(y1);

    final s1 = targetSection.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final s2 = section.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final sectionMatch = targetSection == 'ALL' || s1.isEmpty || s2.isEmpty || s1 == s2;

    return branchMatch && yearMatch && sectionMatch;
  }

  String get targetLabel {
    if (targetBranch == 'ALL') return '📢 All Students (College Wide)';
    String label = targetBranch;
    if (targetYear != 'ALL') label += ' • $targetYear';
    if (targetSemester != 'ALL') label += ' ($targetSemester)';
    if (targetSection != 'ALL') label += ' • Sec $targetSection';
    return label;
  }

  String get senderLabel {
    if (sentByRole == 'admin') return '🛡️ Admin';
    return '$sentByTitle $sentByName';
  }
}
