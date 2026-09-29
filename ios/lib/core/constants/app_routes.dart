class AppRoutes {
  static const String splash = '/';
  static const String roleSelect = '/role-select';

  // Admin
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminAttendanceReport = '/admin/attendance/report';

  // Auth
  static const String studentLogin = '/student/login';
  static const String studentSignup = '/student/signup';
  static const String teacherLogin = '/teacher/login';
  static const String teacherSignup = '/teacher/signup';
  static const String teacherPendingApproval = '/teacher/pending-approval';
  static const String pendingApproval = '/pending-approval';

  // Student
  static const String studentDashboard = '/student/dashboard';
  static const String studentAttendance = '/student/attendance';
  static const String studentLibrary = '/student/library';
  static const String studentQuiz = '/student/quiz';
  static const String studentAttemptQuiz = '/student/quiz/attempt';
  static const String studentQuizResult = '/student/quiz/result';
  static const String studentAssignments = '/student/assignments';
  static const String studentSubmitAssignment = '/student/assignments/submit';
  static const String studentBonafide = '/student/bonafide';
  static const String studentGrievance = '/student/grievance';
  static const String studentTimetable = '/student/timetable';
  static const String leaderboard = '/leaderboard';
  static const String studentIdCard = '/student/id-card';
  static const String editStudentProfile = '/student/profile/edit';
  static const String studentSemesterRegistration = '/student/semester-registration';

  // Teacher
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherSemesterRegistrations = '/teacher/semester-registrations';
  static const String teacherMarkAttendance = '/teacher/attendance/mark';
  static const String teacherAttendanceHistory = '/teacher/attendance/history';
  static const String teacherLibraryUpload = '/teacher/library/upload';
  static const String teacherCreateQuiz = '/teacher/quiz/create';
  static const String teacherQuizList = '/teacher/quiz/list';
  static const String teacherCreateAssignment = '/teacher/assignments/create';
  static const String teacherViewSubmissions = '/teacher/assignments/submissions';
  static const String teacherApproveBonafide = '/teacher/bonafide/approve';
  static const String teacherGrievance = '/teacher/grievance';
  static const String teacherApproveStudents = '/teacher/students/approve';
  static const String teacherSendTimetable = '/teacher/timetable/send';
  static const String studentAttendanceLookup = '/attendance/student/lookup';

  // Group Discussions & Chat
  static const String discussionGroups = '/chat/groups';
  static const String createChatGroup = '/chat/create';

  // Announcements & Notices
  static const String announcements = '/announcements';
  static const String postAnnouncement = '/announcements/post';

  // Live Classes
  static const String studentLiveClasses = '/student/live-classes';
  static const String teacherLiveClasses = '/teacher/live-classes';
  static const String teacherScheduleClass = '/teacher/live-classes/schedule';

  // About Developer & Visionary
  static const String aboutDeveloper = '/about-developer';
}
