import 'package:cloud_firestore/cloud_firestore.dart';

class LiveClassModel {
  final String id;
  final String title;
  final String subject;
  final String description;
  final String teacherUid;
  final String teacherName;
  final String teacherTitle;
  final String teacherDepartment;

  /// Platform: 'youtube' | 'meet' | 'zoom' | 'jitsi' | 'other'
  final String platform;
  final String meetingUrl;

  final DateTime scheduledStartTime;
  final int durationMinutes;

  /// Status: 'UPCOMING' | 'LIVE' | 'COMPLETED' | 'CANCELLED'
  final String status;

  // Batch filtering
  final String targetBranch;   // 'ALL' or 'CSE', 'Civil', etc.
  final String targetYear;     // 'ALL' or '1st Year', etc.
  final String targetSemester; // 'ALL' or '1st Sem', etc.
  final String targetSection;  // 'ALL' or 'A', 'B', etc.

  final String? recordingUrl;
  final DateTime createdAt;

  LiveClassModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.teacherUid,
    required this.teacherName,
    this.teacherTitle = 'Prof.',
    this.teacherDepartment = 'CSE',
    this.platform = 'youtube',
    required this.meetingUrl,
    required this.scheduledStartTime,
    this.durationMinutes = 60,
    this.status = 'UPCOMING',
    this.targetBranch = 'ALL',
    this.targetYear = 'ALL',
    this.targetSemester = 'ALL',
    this.targetSection = 'ALL',
    this.recordingUrl,
    required this.createdAt,
  });

  bool get isLive => status == 'LIVE';
  bool get isUpcoming => status == 'UPCOMING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';

  /// Check if this live class is targeted for a specific student's batch
  bool isRelevantFor({
    required String branch,
    required String year,
    required String semester,
    required String section,
  }) {
    final bMatch = targetBranch == 'ALL' || targetBranch.trim().toLowerCase() == branch.trim().toLowerCase();
    final yMatch = targetYear == 'ALL' || targetYear.trim().toLowerCase() == year.trim().toLowerCase();
    final semMatch = targetSemester == 'ALL' || targetSemester.trim().toLowerCase() == semester.trim().toLowerCase();
    final secMatch = targetSection == 'ALL' || targetSection.trim().toLowerCase() == section.trim().toLowerCase();
    return bMatch && yMatch && semMatch && secMatch;
  }

  String get targetBadge {
    if (targetBranch == 'ALL' && targetYear == 'ALL') return '📢 All College';
    final parts = <String>[];
    if (targetBranch != 'ALL') parts.add(targetBranch);
    if (targetYear != 'ALL') parts.add(targetYear);
    if (targetSemester != 'ALL') parts.add(targetSemester);
    if (targetSection != 'ALL') parts.add('Sec $targetSection');
    return parts.join(' • ');
  }

  String get teacherDisplay => '$teacherTitle $teacherName'.trim();

  String get platformName {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return 'YouTube Live';
      case 'meet':
        return 'Google Meet';
      case 'zoom':
        return 'Zoom';
      case 'jitsi':
        return 'Jitsi Meet (Free)';
      default:
        return 'Live Stream';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'description': description,
      'teacherUid': teacherUid,
      'teacherName': teacherName,
      'teacherTitle': teacherTitle,
      'teacherDepartment': teacherDepartment,
      'platform': platform,
      'meetingUrl': meetingUrl,
      'scheduledStartTime': Timestamp.fromDate(scheduledStartTime),
      'durationMinutes': durationMinutes,
      'status': status,
      'targetBranch': targetBranch,
      'targetYear': targetYear,
      'targetSemester': targetSemester,
      'targetSection': targetSection,
      'recordingUrl': recordingUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory LiveClassModel.fromMap(Map<String, dynamic> map, String docId) {
    return LiveClassModel(
      id: docId,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      teacherUid: map['teacherUid'] ?? '',
      teacherName: map['teacherName'] ?? 'Faculty',
      teacherTitle: map['teacherTitle'] ?? 'Prof.',
      teacherDepartment: map['teacherDepartment'] ?? 'CSE',
      platform: map['platform'] ?? 'youtube',
      meetingUrl: map['meetingUrl'] ?? '',
      scheduledStartTime: (map['scheduledStartTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 60,
      status: map['status'] ?? 'UPCOMING',
      targetBranch: map['targetBranch'] ?? 'ALL',
      targetYear: map['targetYear'] ?? 'ALL',
      targetSemester: map['targetSemester'] ?? 'ALL',
      targetSection: map['targetSection'] ?? 'ALL',
      recordingUrl: map['recordingUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  LiveClassModel copyWith({
    String? title,
    String? subject,
    String? description,
    String? platform,
    String? meetingUrl,
    DateTime? scheduledStartTime,
    int? durationMinutes,
    String? status,
    String? targetBranch,
    String? targetYear,
    String? targetSemester,
    String? targetSection,
    String? recordingUrl,
  }) {
    return LiveClassModel(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      teacherUid: teacherUid,
      teacherName: teacherName,
      teacherTitle: teacherTitle,
      teacherDepartment: teacherDepartment,
      platform: platform ?? this.platform,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      targetBranch: targetBranch ?? this.targetBranch,
      targetYear: targetYear ?? this.targetYear,
      targetSemester: targetSemester ?? this.targetSemester,
      targetSection: targetSection ?? this.targetSection,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      createdAt: createdAt,
    );
  }
}
