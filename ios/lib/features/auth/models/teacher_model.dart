import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String title;           // Mr / Mrs / Dr / Prof
  final List<String> departments; // Multiple departments
  final List<String> years;       // Multiple years they teach
  final List<String> subjects;    // Multiple subjects
  final String employeeId;
  final String designation;
  final String college;
  final String? profileImageUrl;
  final bool isApproved;          // Admin/Teacher approval
  final String role;              // 'teacher' or 'admin'
  final DateTime createdAt;

  TeacherModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.title = 'Mr',
    this.departments = const [],
    this.years = const [],
    this.subjects = const [],
    required this.employeeId,
    this.designation = 'Assistant Professor',
    this.college = 'IES College of Technology',
    this.profileImageUrl,
    this.isApproved = false,
    this.role = 'teacher',
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'title': title,
      'departments': departments,
      'years': years,
      'subjects': subjects,
      'employeeId': employeeId,
      'designation': designation,
      'college': college,
      'profileImageUrl': profileImageUrl,
      'isApproved': isApproved,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      title: map['title'] ?? 'Mr',
      departments: List<String>.from(map['departments'] ?? [map['department'] ?? '']),
      years: List<String>.from(map['years'] ?? []),
      subjects: List<String>.from(map['subjects'] ?? []),
      employeeId: map['employeeId'] ?? '',
      designation: map['designation'] ?? 'Assistant Professor',
      college: map['college'] ?? 'IES College of Technology',
      profileImageUrl: map['profileImageUrl'],
      isApproved: map['isApproved'] ?? false,
      role: map['role'] ?? 'teacher',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get displayTitle => '$title $name';
}
