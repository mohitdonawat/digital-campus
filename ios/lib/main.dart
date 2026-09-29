import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/screens/role_select_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/student_signup_screen.dart';
import 'features/auth/screens/teacher_signup_screen.dart';
import 'features/auth/screens/pending_approval_screen.dart';
import 'features/auth/screens/admin_login_screen.dart';
import 'features/auth/screens/teacher_pending_screen.dart';
import 'features/timetable/teacher/send_timetable_screen.dart';
import 'features/timetable/student/student_timetable_screen.dart';
import 'features/attendance/teacher/mark_attendance_screen.dart';
import 'features/attendance/teacher/teacher_attendance_history_screen.dart';
import 'features/attendance/teacher/student_attendance_lookup_screen.dart';
import 'features/attendance/student/student_attendance_screen.dart';
import 'features/attendance/admin/admin_attendance_report_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/admin_user_approval_screen.dart';
import 'features/chat/screens/discussion_groups_list_screen.dart';
import 'features/chat/screens/create_chat_group_screen.dart';
import 'features/announcements/screens/announcements_feed_screen.dart';
import 'features/announcements/screens/post_announcement_screen.dart';
import 'student/dashboard/student_dashboard.dart';
import 'teacher/dashboard/teacher_dashboard.dart';
import 'features/bonafide/student/student_bonafide_screen.dart';
import 'features/bonafide/teacher/teacher_bonafide_screen.dart';
import 'features/quiz/models/quiz_model.dart';
import 'features/quiz/models/quiz_submission_model.dart';
import 'features/quiz/student/student_quizzes_screen.dart';
import 'features/quiz/student/student_attempt_quiz_screen.dart';
import 'features/quiz/student/student_quiz_result_screen.dart';
import 'features/quiz/teacher/teacher_create_quiz_screen.dart';
import 'features/quiz/teacher/teacher_quizzes_list_screen.dart';
import 'features/quiz/shared/quiz_leaderboard_screen.dart';
import 'features/assignments/student/student_assignments_screen.dart';
import 'features/assignments/teacher/teacher_assignments_screen.dart';
import 'features/assignments/teacher/teacher_create_assignment_screen.dart';
import 'features/library/student/student_library_screen.dart';
import 'features/library/teacher/teacher_library_upload_screen.dart';
import 'features/grievance/student/student_grievance_screen.dart';
import 'features/grievance/teacher/teacher_grievance_screen.dart';
import 'features/live_class/models/live_class_model.dart';
import 'features/live_class/student/student_live_classes_screen.dart';
import 'features/live_class/teacher/teacher_live_classes_screen.dart';
import 'features/live_class/teacher/teacher_schedule_class_screen.dart';
import 'features/about_developer/screens/about_developer_screen.dart';
import 'features/id_card/screens/student_id_card_screen.dart';
import 'features/id_card/screens/edit_student_profile_screen.dart';
import 'features/semester_registration/screens/student_semester_registration_screen.dart';
import 'features/semester_registration/screens/teacher_semester_registrations_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const IESECampusApp());
}

class IESECampusApp extends StatelessWidget {
  const IESECampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IES E Campus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        // Splash
        AppRoutes.splash: (_) => const SplashScreen(),

        // Admin
        AppRoutes.adminLogin: (_) => const AdminLoginScreen(),
        AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
        AppRoutes.adminAttendanceReport: (_) => const AdminAttendanceReportScreen(),

        // Auth - Common
        AppRoutes.roleSelect: (_) => const RoleSelectScreen(),
        AppRoutes.pendingApproval: (_) => const PendingApprovalScreen(),

        // Auth - Student
        AppRoutes.studentLogin: (_) => const LoginScreen(role: 'student'),
        AppRoutes.studentSignup: (_) => const StudentSignupScreen(),

        // Auth - Teacher
        AppRoutes.teacherLogin: (_) => const LoginScreen(role: 'teacher'),
        AppRoutes.teacherSignup: (_) => const TeacherSignupScreen(),
        AppRoutes.teacherPendingApproval: (_) => const TeacherPendingScreen(),

        // Dashboards
        AppRoutes.studentDashboard: (_) => const StudentDashboard(),
        AppRoutes.teacherDashboard: (_) => const TeacherDashboard(),

        // Student features
        AppRoutes.studentAttendance: (_) => const StudentAttendanceScreen(),
        AppRoutes.studentLibrary: (_) => const StudentLibraryScreen(),
        AppRoutes.studentQuiz: (_) => const StudentQuizzesScreen(),
        AppRoutes.studentAttemptQuiz: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
          final quiz = args!['quiz'] as QuizModel;
          final studentData = args['studentData'] as Map<String, dynamic>?;
          return StudentAttemptQuizScreen(quiz: quiz, studentData: studentData);
        },
        AppRoutes.studentQuizResult: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
          final quiz = args!['quiz'] as QuizModel;
          final submission = args['submission'] as QuizSubmissionModel;
          return StudentQuizResultScreen(quiz: quiz, submission: submission);
        },
        AppRoutes.studentAssignments: (_) => const StudentAssignmentsScreen(),
        AppRoutes.studentBonafide: (_) => const StudentBonafideScreen(),
        AppRoutes.studentGrievance: (_) => const StudentGrievanceScreen(),
        AppRoutes.studentTimetable: (_) => const StudentTimetableScreen(),
        AppRoutes.studentIdCard: (_) => const StudentIdCardScreen(),
        AppRoutes.editStudentProfile: (_) => const EditStudentProfileScreen(),
        AppRoutes.studentSemesterRegistration: (_) => const StudentSemesterRegistrationScreen(),
        AppRoutes.leaderboard: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
          final quiz = args!['quiz'] as QuizModel;
          final isTeacher = args['isTeacher'] as bool? ?? false;
          return QuizLeaderboardScreen(quiz: quiz, isTeacher: isTeacher);
        },

        // Teacher features
        AppRoutes.teacherSemesterRegistrations: (_) => const TeacherSemesterRegistrationsScreen(),
        AppRoutes.teacherMarkAttendance: (_) => const MarkAttendanceScreen(),
        AppRoutes.teacherAttendanceHistory: (_) => const TeacherAttendanceHistoryScreen(),
        AppRoutes.studentAttendanceLookup: (_) => const StudentAttendanceLookupScreen(),
        AppRoutes.teacherLibraryUpload: (_) => const TeacherLibraryUploadScreen(),
        AppRoutes.teacherCreateQuiz: (_) => const TeacherCreateQuizScreen(),
        AppRoutes.teacherQuizList: (_) => const TeacherQuizzesListScreen(),
        AppRoutes.teacherCreateAssignment: (_) => const TeacherCreateAssignmentScreen(),
        AppRoutes.teacherViewSubmissions: (_) => const TeacherAssignmentsScreen(),
        AppRoutes.teacherApproveBonafide: (_) => const TeacherBonafideScreen(),
        AppRoutes.teacherGrievance: (_) => const TeacherGrievanceScreen(),
        AppRoutes.teacherApproveStudents: (_) => const AdminUserApprovalScreen(),
        AppRoutes.teacherSendTimetable: (_) => const SendTimetableScreen(isAdmin: false),

        // Group Discussion & Chat
        AppRoutes.discussionGroups: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          final isFaculty = args is bool ? args : false;
          return DiscussionGroupsListScreen(isTeacherOrAdmin: isFaculty);
        },
        AppRoutes.createChatGroup: (_) => const CreateChatGroupScreen(),

        // Announcements & Notices
        AppRoutes.announcements: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          final isFaculty = args is bool ? args : false;
          return AnnouncementsFeedScreen(isFaculty: isFaculty);
        },
        AppRoutes.postAnnouncement: (_) => const PostAnnouncementScreen(),

        // Live Classes (PhysicsWallah / Unacademy style)
        AppRoutes.studentLiveClasses: (_) => const StudentLiveClassesScreen(),
        AppRoutes.teacherLiveClasses: (_) => const TeacherLiveClassesScreen(),
        AppRoutes.teacherScheduleClass: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          return TeacherScheduleClassScreen(
            classToEdit: args is LiveClassModel ? args : null,
          );
        },

        // About Developer (Mohit Donawat)
        AppRoutes.aboutDeveloper: (_) => const AboutDeveloperScreen(),
      },
    );
  }
}

/// Temporary placeholder screen while feature screens are being built
Widget _placeholderScreen(String title) {
  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(title),
      backgroundColor: AppColors.surface,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: const Icon(Icons.construction_rounded, color: AppColors.secondary, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coming Soon...\nThis feature is under development',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    ),
  );
}
