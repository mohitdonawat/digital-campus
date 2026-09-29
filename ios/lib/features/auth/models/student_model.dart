import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String branch;
  final String year;
  final String semester;
  final String section;
  final String rollNo;
  final String enrollmentNo;
  final String college;
  final String university;
  final bool isApproved;
  final String? profileImageUrl;
  final DateTime createdAt;
  final String bloodGroup;
  final String dob;
  final String fatherName;
  final String address;
  final String emergencyContact;
  final String validUpto;

  StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    required this.branch,
    required this.year,
    required this.semester,
    required this.section,
    required this.rollNo,
    required this.enrollmentNo,
    this.college = 'IES College of Technology',
    this.university = 'RGPV',
    this.isApproved = false,
    this.profileImageUrl,
    required this.createdAt,
    this.bloodGroup = 'B+',
    this.dob = '',
    this.fatherName = '',
    this.address = 'Bhopal, Madhya Pradesh',
    this.emergencyContact = '',
    this.validUpto = '2024 - 2028',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'branch': branch,
      'year': year,
      'semester': semester,
      'section': section,
      'rollNo': rollNo,
      'enrollmentNo': enrollmentNo,
      'college': college,
      'university': university,
      'isApproved': isApproved,
      'profileImageUrl': profileImageUrl,
      'role': 'student',
      'createdAt': Timestamp.fromDate(createdAt),
      'bloodGroup': bloodGroup,
      'dob': dob,
      'fatherName': fatherName,
      'address': address,
      'emergencyContact': emergencyContact,
      'validUpto': validUpto,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      branch: map['branch'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '1st Sem',
      section: map['section'] ?? '',
      rollNo: map['rollNo'] ?? '',
      enrollmentNo: map['enrollmentNo'] ?? '',
      college: map['college'] ?? 'IES College of Technology',
      university: map['university'] ?? 'RGPV',
      isApproved: map['isApproved'] ?? false,
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bloodGroup: map['bloodGroup'] ?? 'B+',
      dob: map['dob'] ?? '',
      fatherName: map['fatherName'] ?? '',
      address: map['address'] ?? 'Bhopal, Madhya Pradesh',
      emergencyContact: map['emergencyContact'] ?? '',
      validUpto: map['validUpto'] ?? '2024 - 2028',
    );
  }

  StudentModel copyWith({
    String? name,
    String? phone,
    String? semester,
    bool? isApproved,
    String? profileImageUrl,
    String? bloodGroup,
    String? dob,
    String? fatherName,
    String? address,
    String? emergencyContact,
    String? validUpto,
  }) {
    return StudentModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      branch: branch,
      year: year,
      semester: semester ?? this.semester,
      section: section,
      rollNo: rollNo,
      enrollmentNo: enrollmentNo,
      college: college,
      university: university,
      isApproved: isApproved ?? this.isApproved,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      dob: dob ?? this.dob,
      fatherName: fatherName ?? this.fatherName,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      validUpto: validUpto ?? this.validUpto,
    );
  }
}
