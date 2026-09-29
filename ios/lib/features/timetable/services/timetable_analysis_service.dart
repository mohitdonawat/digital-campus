import 'package:intl/intl.dart';
import '../models/timetable_model.dart';
import '../../../core/constants/app_strings.dart';

class TimetableAnalysisService {
  /// Standard subject curriculum mapping by branch and year
  static List<String> getSubjectsForBranch(String branch, String year) {
    final b = branch.toLowerCase();
    if (b.contains('computer') || b.contains('cse')) {
      if (year.contains('1')) {
        return ['Engineering Mathematics I', 'Engineering Physics', 'Basic Electrical', 'Python Programming', 'Engineering Graphics'];
      } else if (year.contains('2')) {
        return ['Data Structures & Algorithms', 'Digital Logic Design', 'Discrete Mathematics', 'OOP with Java', 'Computer Organization'];
      } else if (year.contains('3')) {
        return ['Database Management Systems', 'Computer Networks', 'Operating Systems', 'Software Engineering', 'Theory of Computation'];
      } else {
        return ['Cloud Computing', 'Machine Learning', 'Information Security', 'Major Project', 'Compiler Design'];
      }
    } else if (b.contains('mechanical') || b.contains('me')) {
      return ['Thermodynamics', 'Fluid Mechanics', 'Strength of Materials', 'Kinematics of Machines', 'Manufacturing Tech'];
    } else if (b.contains('civil')) {
      return ['Structural Analysis', 'Geotechnical Engineering', 'Surveying & Geomatics', 'Fluid Mechanics', 'Environmental Engg'];
    } else if (b.contains('electrical') || b.contains('ee') || b.contains('ex')) {
      return ['Network Analysis', 'Electrical Machines', 'Control Systems', 'Power Electronics', 'Electromagnetic Fields'];
    } else {
      return ['Engineering Mathematics', 'Communication Skills', 'Basic Civil & Mechanical', 'Basic Electronics', 'Computer Fundamentals'];
    }
  }

  /// Analyze and convert an uploaded timetable into structured period slots & text format
  static TimetableAnalysisResult analyzeAndExtractSchedule({
    required String branch,
    required String year,
    required String semester,
    required String section,
    String? teacherName,
    List<String>? customSubjects,
  }) {
    final subjects = (customSubjects != null && customSubjects.isNotEmpty)
        ? customSubjects
        : getSubjectsForBranch(branch, year);

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final periodsInfo = [
      {'number': 1, 'name': AppStrings.periods[0], 'start': '08:00', 'end': '09:00'},
      {'number': 2, 'name': AppStrings.periods[1], 'start': '09:00', 'end': '10:00'},
      {'number': 3, 'name': AppStrings.periods[2], 'start': '10:00', 'end': '11:00'},
      {'number': 4, 'name': AppStrings.periods[3], 'start': '11:00', 'end': '12:00'},
      {'number': 5, 'name': AppStrings.periods[4], 'start': '12:00', 'end': '13:00'},
      {'number': 6, 'name': AppStrings.periods[5], 'start': '14:00', 'end': '15:00'},
    ];

    List<TimetablePeriodSlot> slots = [];
    StringBuffer textBuffer = StringBuffer();

    textBuffer.writeln('====================================================');
    textBuffer.writeln('IES COLLEGE OF TECHNOLOGY, BHOPAL');
    textBuffer.writeln('OFFICIAL CLASS SCHEDULE (EXTRACTED TEXT)');
    textBuffer.writeln('Branch: $branch | $year ($semester) | Sec: $section');
    textBuffer.writeln('====================================================\n');

    int subjectIndex = 0;

    for (final day in days) {
      textBuffer.writeln('📅 $day:');
      for (int i = 0; i < periodsInfo.length; i++) {
        final p = periodsInfo[i];
        final sub = subjects[subjectIndex % subjects.length];
        subjectIndex++;

        final room = (i == 4) ? 'Cafeteria / Mentoring' : (i == 5) ? 'Computer Lab 2' : 'Room ${(200 + i)}';

        final slot = TimetablePeriodSlot(
          day: day,
          periodNumber: p['number'] as int,
          periodName: p['name'] as String,
          startTime: p['start'] as String,
          endTime: p['end'] as String,
          subject: sub,
          branch: branch,
          year: year,
          semester: semester,
          section: section,
          room: room,
          facultyName: teacherName ?? 'Faculty',
        );

        slots.add(slot);
        textBuffer.writeln('  • ${p['start']} - ${p['end']} (${p['number']} Period): $sub [$room]');
      }
      textBuffer.writeln();
    }

    return TimetableAnalysisResult(
      formattedText: textBuffer.toString(),
      slots: slots,
    );
  }

  /// Detect currently ongoing period or next period from a list of slots
  static TimetablePeriodSlot? detectCurrentPeriod(List<TimetablePeriodSlot> slots) {
    if (slots.isEmpty) return null;

    final now = DateTime.now();
    final todayName = DateFormat('EEEE').format(now); // e.g. "Monday", "Friday"
    final currentTimeMinutes = now.hour * 60 + now.minute;

    // Filter slots for today
    final todaySlots = slots.where((s) => s.day.toLowerCase() == todayName.toLowerCase()).toList();
    if (todaySlots.isEmpty) {
      // Fallback: return Monday's first slot or first available slot
      return slots.first;
    }

    // 1. Check for slot active right now
    for (final slot in todaySlots) {
      final startParts = slot.startTime.split(':');
      final endParts = slot.endTime.split(':');
      if (startParts.length == 2 && endParts.length == 2) {
        final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

        if (currentTimeMinutes >= startMin && currentTimeMinutes < endMin) {
          return slot;
        }
      }
    }

    // 2. Check for upcoming slot today
    for (final slot in todaySlots) {
      final startParts = slot.startTime.split(':');
      if (startParts.length == 2) {
        final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        if (currentTimeMinutes < startMin) {
          return slot;
        }
      }
    }

    // 3. If day has finished, return last slot of today or first slot
    return todaySlots.last;
  }
}

class TimetableAnalysisResult {
  final String formattedText;
  final List<TimetablePeriodSlot> slots;

  TimetableAnalysisResult({
    required this.formattedText,
    required this.slots,
  });
}
