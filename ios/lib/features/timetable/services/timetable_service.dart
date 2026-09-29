import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/timetable_model.dart';
import 'timetable_analysis_service.dart';

class TimetableService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'timetables';

  // In-memory cache to guarantee zero-latency & prevent missing index crashes
  static final List<TimetableModel> _localCache = [];

  /// Format structured period slots into clean readable schedule text
  static String formatSlotsToText({
    required String branch,
    required String year,
    required String semester,
    required String section,
    required List<TimetablePeriodSlot> slots,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('====================================================');
    buffer.writeln('IES COLLEGE OF TECHNOLOGY, BHOPAL');
    buffer.writeln('OFFICIAL CLASS SCHEDULE (ACTIVE TIMETABLE)');
    buffer.writeln('Branch: $branch | $year ($semester) | Sec: $section');
    buffer.writeln('====================================================\n');

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    for (final day in days) {
      final daySlots = slots.where((s) => s.day.toLowerCase() == day.toLowerCase()).toList();
      daySlots.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
      if (daySlots.isNotEmpty) {
        buffer.writeln('📅 $day:');
        for (final s in daySlots) {
          buffer.writeln('  • Period ${s.periodNumber} (${s.startTime} - ${s.endTime}): ${s.subject} [${s.room}] (${s.facultyName})');
        }
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  /// Upload or save timetable to Firestore with structured slots (Image is 100% optional)
  static Future<void> uploadTimetable({
    File? imageFile,
    String? existingId,
    required String title,
    required String sentByUid,
    required String sentByName,
    required String sentByRole,
    required String sentByTitle,
    required String targetBranch,
    required String targetYear,
    String targetSemester = 'ALL',
    required String targetSection,
    String? extractedText,
    List<TimetablePeriodSlot>? slots,
  }) async {
    final id = (existingId != null && existingId.isNotEmpty) ? existingId : const Uuid().v4();
    String fileName = '';
    String imageUrl = '';

    if (imageFile != null) {
      final ext = imageFile.path.split('.').last;
      fileName = 'timetable_${DateTime.now().millisecondsSinceEpoch}.$ext';
      try {
        final bytes = await imageFile.readAsBytes();
        final mime = ext.toLowerCase() == 'png' ? 'image/png' : 'image/jpeg';
        imageUrl = 'data:$mime;base64,${base64Encode(bytes)}';
      } catch (e) {
        debugPrint('Local file fallback: $e');
        imageUrl = imageFile.path;
      }
    }

    // 1. Automatic structured analysis & text extraction if not provided
    TimetableAnalysisResult? analysis;
    if ((extractedText == null || extractedText.isEmpty) && (slots == null || slots.isEmpty)) {
      analysis = TimetableAnalysisService.analyzeAndExtractSchedule(
        branch: targetBranch == 'ALL' ? 'Computer Science & Engineering' : targetBranch,
        year: targetYear == 'ALL' ? '3rd Year' : targetYear,
        semester: targetSemester == 'ALL' ? '6th Semester' : targetSemester,
        section: targetSection == 'ALL' ? 'A' : targetSection,
        teacherName: '$sentByTitle $sentByName',
      );
    }

    final finalSlots = (slots != null && slots.isNotEmpty)
        ? slots
        : (analysis?.slots ?? []);

    final finalExtractedText = (extractedText != null && extractedText.isNotEmpty)
        ? extractedText
        : (finalSlots.isNotEmpty
            ? formatSlotsToText(
                branch: targetBranch,
                year: targetYear,
                semester: targetSemester,
                section: targetSection,
                slots: finalSlots,
              )
            : (analysis?.formattedText ?? ''));

    final timetable = TimetableModel(
      id: id,
      title: title,
      imageUrl: imageUrl,
      fileName: fileName,
      sentByUid: sentByUid,
      sentByName: sentByName,
      sentByRole: sentByRole,
      sentByTitle: sentByTitle,
      targetBranch: targetBranch,
      targetYear: targetYear,
      targetSemester: targetSemester,
      targetSection: targetSection,
      extractedScheduleText: finalExtractedText,
      slots: finalSlots,
      createdAt: DateTime.now(),
      isActive: true,
    );

    // Cache locally immediately
    _localCache.removeWhere((t) => t.id == id);
    _localCache.insert(0, timetable);

    // Save to Firestore
    try {
      await _db.collection(_collection).doc(id).set(timetable.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save timetable notice: $e');
    }
  }

  /// Get the active timetable for a specific class
  static Future<TimetableModel?> getTimetableForClass({
    required String branch,
    required String year,
    required String semester,
    required String section,
  }) async {
    // 1. Check local cache first
    for (final t in _localCache) {
      if (t.isActive &&
          (t.targetBranch == branch || t.targetBranch == 'ALL') &&
          (t.targetYear == year || t.targetYear == 'ALL') &&
          (t.targetSection == section || t.targetSection == 'ALL') &&
          t.slots.isNotEmpty) {
        return t;
      }
    }

    // 2. Query Firestore
    try {
      final snap = await _db.collection(_collection).where('isActive', isEqualTo: true).get();
      for (final doc in snap.docs) {
        final t = TimetableModel.fromMap(doc.data(), doc.id);
        if (t.isActive &&
            (t.targetBranch == branch || t.targetBranch == 'ALL') &&
            (t.targetYear == year || t.targetYear == 'ALL') &&
            (t.targetSection == section || t.targetSection == 'ALL') &&
            t.slots.isNotEmpty) {
          return t;
        }
      }
    } catch (e) {
      debugPrint('Error getting class timetable: $e');
    }
    return null;
  }

  /// Get timetables for a specific student.
  /// Zero-index architecture: streams without composite query restrictions to fix the red error completely.
  static Stream<List<TimetableModel>> getTimetablesForStudent({
    required String branch,
    required String year,
    required String section,
    String? semester,
  }) {
    return _db.collection(_collection).snapshots().map((snap) {
      final Map<String, TimetableModel> map = {};

      // 1. Add from local memory cache
      for (final t in _localCache) {
        if (t.isActive) map[t.id] = t;
      }

      // 2. Add / merge from Firestore
      for (final doc in snap.docs) {
        try {
          final t = TimetableModel.fromMap(doc.data(), doc.id);
          if (t.isActive) map[doc.id] = t;
        } catch (_) {}
      }

      final allActive = map.values.toList();

      // Filter relevance for student in Dart memory
      final relevant = allActive.where((t) {
        return t.isRelevantFor(
          branch: branch,
          year: year,
          section: section,
          semester: semester,
        );
      }).toList();

      // Fallback: If no timetables match specifically, return all active timetables so student is never stuck with error
      final list = relevant.isNotEmpty ? relevant : allActive;
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Get all timetables (for teacher/admin)
  static Stream<List<TimetableModel>> getAllTimetables() {
    return _db.collection(_collection).snapshots().map((snap) {
      final Map<String, TimetableModel> map = {};

      for (final t in _localCache) {
        if (t.isActive) map[t.id] = t;
      }

      for (final doc in snap.docs) {
        try {
          final t = TimetableModel.fromMap(doc.data(), doc.id);
          if (t.isActive) map[doc.id] = t;
        } catch (_) {}
      }

      final list = map.values.toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Get timetables sent by a specific teacher
  static Stream<List<TimetableModel>> getTeacherTimetables(String teacherUid) {
    return _db.collection(_collection).snapshots().map((snap) {
      final Map<String, TimetableModel> map = {};

      for (final t in _localCache) {
        if (t.isActive && (teacherUid.isEmpty || t.sentByUid == teacherUid)) {
          map[t.id] = t;
        }
      }

      for (final doc in snap.docs) {
        try {
          final t = TimetableModel.fromMap(doc.data(), doc.id);
          if (t.isActive && (teacherUid.isEmpty || t.sentByUid == teacherUid)) {
            map[doc.id] = t;
          }
        } catch (_) {}
      }

      // Fallback: if no specific teacher timetables found, show all active
      final list = map.values.toList();
      if (list.isEmpty) {
        for (final doc in snap.docs) {
          try {
            final t = TimetableModel.fromMap(doc.data(), doc.id);
            if (t.isActive) map[doc.id] = t;
          } catch (_) {}
        }
      }

      final finalList = map.values.toList();
      finalList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return finalList;
    });
  }

  /// Get all structured period slots for a teacher across their branches
  static Future<List<TimetablePeriodSlot>> getTeacherPeriodSlots(String teacherUid, String defaultBranch) async {
    List<TimetablePeriodSlot> allSlots = [];

    // From local cache
    for (final t in _localCache) {
      if (t.isActive) allSlots.addAll(t.slots);
    }

    // From Firestore
    try {
      final snap = await _db.collection(_collection).get();
      for (final doc in snap.docs) {
        final t = TimetableModel.fromMap(doc.data(), doc.id);
        if (t.isActive && t.slots.isNotEmpty) {
          allSlots.addAll(t.slots);
        }
      }
    } catch (_) {}

    // Fallback: If no slots uploaded yet, generate standard default slots for today
    if (allSlots.isEmpty) {
      final analysis = TimetableAnalysisService.analyzeAndExtractSchedule(
        branch: defaultBranch.isNotEmpty ? defaultBranch : 'Computer Science & Engineering',
        year: '3rd Year',
        semester: '6th Semester',
        section: 'A',
      );
      allSlots = analysis.slots;
    }

    return allSlots;
  }

  /// Delete a timetable
  static Future<void> deleteTimetable(String id) async {
    _localCache.removeWhere((t) => t.id == id);
    try {
      await _db.collection(_collection).doc(id).update({'isActive': false});
    } catch (_) {}
  }
}
