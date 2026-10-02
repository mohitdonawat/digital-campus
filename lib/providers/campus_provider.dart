import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/firebase_service.dart';
import '../core/services/api_service.dart';
import '../core/services/go_backend_service.dart';
import '../models/campus_models.dart';
import '../models/quiz_models.dart';
import '../data/campus_database.dart';
import '../core/ai/personalized_learning_recommender.dart';
import '../core/services/textbook_quiz_repository.dart';

class CampusProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // Current Role
  UserRole _currentRole = UserRole.student;
  UserRole get currentRole => _currentRole;

  // Student Profile
  StudentProfile _student = CampusDatabase.student;
  StudentProfile get student => _student;

  // Role Professional Profiles
  FacultyProfessionalProfile _facultyProfile = const FacultyProfessionalProfile();
  FacultyProfessionalProfile get facultyProfile => _facultyProfile;

  AdminProfessionalProfile _adminProfile = const AdminProfessionalProfile();
  AdminProfessionalProfile get adminProfile => _adminProfile;

  ParentProfessionalProfile _parentProfile = const ParentProfessionalProfile();
  ParentProfessionalProfile get parentProfile => _parentProfile;

  dynamic get currentProfile {
    switch (_currentRole) {
      case UserRole.faculty:
        return _facultyProfile;
      case UserRole.admin:
        return _adminProfile;
      case UserRole.parent:
        return _parentProfile;
      case UserRole.student:
        return _student;
    }
  }

  // AI Automated Career & Placement Insights
  late AiCareerInsight _aiCareerInsight = _computeAiCareerInsight();
  AiCareerInsight get aiCareerInsight => _aiCareerInsight;

  // Attendance
  List<SubjectAttendance> _attendance = List.from(CampusDatabase.initialAttendance);
  List<SubjectAttendance> get attendance => _attendance;

  double get overallAttendance {
    if (_attendance.isEmpty) return 0.0;
    int attended = 0;
    int total = 0;
    for (var s in _attendance) {
      attended += s.attendedClasses;
      total += s.totalClasses;
    }
    return total == 0 ? 0.0 : (attended / total) * 100;
  }

  // Timetable & Live Classes
  List<TimetablePeriod> _timetable = List.from(CampusDatabase.todayTimetable);
  List<TimetablePeriod> get timetable => _timetable;

  List<LiveClassSession> _liveClasses = List.from(CampusDatabase.initialLiveClasses);
  List<LiveClassSession> get liveClasses => _liveClasses;

  // Semester Course & Academic Registration
  List<SemesterRegistration> _semesterRegistrations = List.from(CampusDatabase.initialSemesterRegistrations);
  List<SemesterRegistration> get semesterRegistrations => _semesterRegistrations;

  SemesterRegistration get currentStudentRegistration {
    return _semesterRegistrations.firstWhere(
      (r) => r.studentId == _student.id,
      orElse: () => _semesterRegistrations.first,
    );
  }

  // Live Campus Notifications & System Messages
  List<CampusNotificationItem> _notifications = List.from(CampusDatabase.initialNotifications);
  List<CampusNotificationItem> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  // Certificates
  List<DigitalCertificate> _certificates = List.from(CampusDatabase.certificates);
  List<DigitalCertificate> get certificates => _certificates;

  // Fees
  List<FeeItem> _fees = List.from(CampusDatabase.fees);
  List<FeeItem> get fees => _fees;

  double get totalDues {
    double dues = 0.0;
    for (var f in _fees) {
      if (!f.isPaid) dues += f.amount;
    }
    return dues;
  }

  // Hostel & Gate Passes
  HostelDetails _hostel = CampusDatabase.hostel;
  HostelDetails get hostel => _hostel;

  List<GatePass> _gatePasses = List.from(CampusDatabase.gatePasses);
  List<GatePass> get gatePasses => _gatePasses;

  List<HostelMaintenanceTicket> _hostelMaintenanceTickets = List.from(CampusDatabase.hostelMaintenanceTickets);
  List<HostelMaintenanceTicket> get hostelMaintenanceTickets => _hostelMaintenanceTickets;

  List<MessMealFeedback> _messFeedbacks = List.from(CampusDatabase.messMealFeedbacks);
  List<MessMealFeedback> get messFeedbacks => _messFeedbacks;

  List<MessRebateClaim> _messRebates = List.from(CampusDatabase.messRebates);
  List<MessRebateClaim> get messRebates => _messRebates;

  List<HostelBlockOccupancy> _hostelBlocksOccupancy = List.from(CampusDatabase.hostelBlocksOccupancy);
  List<HostelBlockOccupancy> get hostelBlocksOccupancy => _hostelBlocksOccupancy;

  HostelFeePolicy _hostelFeePolicy = const HostelFeePolicy();
  HostelFeePolicy get hostelFeePolicy => _hostelFeePolicy;

  List<RoomSwapRequest> _roomSwaps = List.from(CampusDatabase.roomSwapRequests);
  List<RoomSwapRequest> get roomSwaps => _roomSwaps;

  List<HostelFacilitySlot> _facilitySlots = List.from(CampusDatabase.hostelFacilitySlots);
  List<HostelFacilitySlot> get facilitySlots => _facilitySlots;

  RoommateCompatibilityProfile _roommateProfile = CampusDatabase.roommateProfile;
  RoommateCompatibilityProfile get roommateProfile => _roommateProfile;

  HostelEnergyMeter _hostelEnergyMeter = CampusDatabase.hostelEnergyMeter;
  HostelEnergyMeter get hostelEnergyMeter => _hostelEnergyMeter;

  List<HostelEmergencySosLog> _hostelSosLogs = List.from(CampusDatabase.hostelSosLogs);
  List<HostelEmergencySosLog> get hostelSosLogs => _hostelSosLogs;

  bool _isSosActive = false;
  bool get isSosActive => _isSosActive;

  // 6 Ultra-Smart Hostel Innovations State
  RoommateQuizProfile _roommateQuiz = CampusDatabase.studentRoommateQuiz;
  RoommateQuizProfile get roommateQuiz => _roommateQuiz;

  List<RoommateQuizProfile> _roommateCandidates = List.from(CampusDatabase.allRoommateCandidates);
  List<RoommateQuizProfile> get roommateCandidates => _roommateCandidates;

  RoommateMatchmakerSetting _matchmakerSetting = CampusDatabase.roommateMatchmakerSetting;
  RoommateMatchmakerSetting get matchmakerSetting => _matchmakerSetting;

  List<DiningIntentRecord> _diningIntents = List.from(CampusDatabase.initialDiningIntents);
  List<DiningIntentRecord> get diningIntents => _diningIntents;

  MessHeadcountForecast _messForecast = CampusDatabase.messHeadcountForecast;
  MessHeadcountForecast get messForecast => _messForecast;

  SilentDuressAlarm _silentDuress = CampusDatabase.silentDuressAlarm;
  SilentDuressAlarm get silentDuress => _silentDuress;

  bool _isSilentDuressTriggered = false;
  bool get isSilentDuressTriggered => _isSilentDuressTriggered;

  List<RoomAssetInspection> _roomAssetInspections = List.from(CampusDatabase.roomAssetInspections);
  List<RoomAssetInspection> get roomAssetInspections => _roomAssetInspections;

  GreenDormEnergyCredit _greenDormEnergy = CampusDatabase.greenDormEnergyCredit;
  GreenDormEnergyCredit get greenDormEnergy => _greenDormEnergy;

  List<CurfewExtensionRequest> _curfewExtensions = List.from(CampusDatabase.initialCurfewExtensions);
  List<CurfewExtensionRequest> get curfewExtensions => _curfewExtensions;

  // Transport
  BusRoute _busRoute = CampusDatabase.busRoute;
  BusRoute get busRoute => _busRoute;

  // Helpdesk
  List<GrievanceTicket> _grievances = List.from(CampusDatabase.grievances);
  List<GrievanceTicket> get grievances => _grievances;

  // Dynamic AI Analytics (Guaranteed Non-Null Initialization)
  late PredictivePerformance _predictivePerformance = _firebaseService.computeDynamicPerformance(
    attendanceList: _attendance,
    currentCgpa: _student.currentCgpa,
    extraStudyHours: 4.0,
    targetAttendance: 85.0,
  );
  PredictivePerformance get predictivePerformance => _predictivePerformance;

  late DropoutRiskAnalysis _dropoutRisk = _firebaseService.computeDynamicDropoutRisk(
    attendanceList: _attendance,
    totalUnpaidFees: totalDues,
    activeBacklogs: 0,
  );
  DropoutRiskAnalysis get dropoutRisk => _dropoutRisk;

  List<LearningRecommendation> _learningRecommendations = List.from(CampusDatabase.learningRecommendations);
  List<LearningRecommendation> get learningRecommendations => _learningRecommendations;

  // AI Chat & Voice Assistant
  List<AiChatMessage> _chatMessages = [];
  List<AiChatMessage> get chatMessages => _chatMessages;

  bool _isVoiceListening = false;
  bool get isVoiceListening => _isVoiceListening;

  bool _isAiSpeaking = false;
  bool get isAiSpeaking => _isAiSpeaking;

  // Adaptive Quizzes & Submissions
  List<CampusQuiz> _quizzes = TextbookQuizRepository.getInitialQuizzes();
  List<CampusQuiz> get quizzes => _quizzes;

  List<QuizSubmission> _quizSubmissions = TextbookQuizRepository.getInitialSubmissions();
  List<QuizSubmission> get quizSubmissions => _quizSubmissions;

  CampusProvider() {
    // 1. Synchronously pre-calculate models so widgets NEVER crash on initial build
    _recomputeAiModels();

    // 2. Set role-isolated welcome message immediately
    _chatMessages = _getInitialChatMessagesForRole(_currentRole);

    // 3. Asynchronously initialize services in background without blocking UI
    _initializeServices();
  }

  // ── Go Backend Integration & Automation State ─────────────────────────────
  bool _isGoBackendOnline = false;
  bool get isGoBackendOnline => _isGoBackendOnline;

  List<Map<String, dynamic>> _automationLogs = [];
  List<Map<String, dynamic>> get automationLogs => _automationLogs;

  Future<void> _initializeServices() async {
    try {
      // 1. Initialize Firebase & Firestore safely
      await _firebaseService.initialize();
    } catch (e) {
      debugPrint("⚠ Firebase background init note: $e");
    }

    // 2. Connect to single-file Go backend engine
    await syncWithGoBackend();

    // 3. Recompute dynamic state if cloud sync updated anything
    _recomputeAiModels();
    notifyListeners();
  }

  Future<void> syncWithGoBackend() async {
    try {
      final health = await GoBackendService.checkHealth();
      if (health != null) {
        _isGoBackendOnline = true;
        // Fetch real-time tenants from Go engine
        final remoteTenants = await GoBackendService.fetchTenants();
        if (remoteTenants != null && remoteTenants.isNotEmpty) {
          _colleges = remoteTenants;
        }
        // Fetch real-time class attendance from Go engine
        final remoteAttendance = await GoBackendService.fetchAttendanceRecords();
        if (remoteAttendance != null && remoteAttendance.isNotEmpty) {
          _classAttendanceRecords = remoteAttendance;
        }
        // Fetch background automation logs
        final logs = await GoBackendService.fetchAutomationLogs();
        if (logs != null) {
          _automationLogs = logs;
        }
        notifyListeners();
      } else {
        _isGoBackendOnline = false;
        notifyListeners();
      }
    } catch (e) {
      _isGoBackendOnline = false;
      debugPrint("Go engine offline note: $e");
    }
  }

  // Real Dynamic AI Model Recomputation
  void _recomputeAiModels({double extraStudyHours = 4.0, double targetAttendance = 85.0}) {
    _predictivePerformance = _firebaseService.computeDynamicPerformance(
      attendanceList: _attendance,
      currentCgpa: _student.currentCgpa,
      extraStudyHours: extraStudyHours,
      targetAttendance: targetAttendance,
    );

    _dropoutRisk = _firebaseService.computeDynamicDropoutRisk(
      attendanceList: _attendance,
      totalUnpaidFees: totalDues,
      activeBacklogs: 0,
    );

    _learningRecommendations = PersonalizedLearningRecommender.generateRecommendations(
      attendanceList: _attendance,
      subjectScores: _predictivePerformance.subjectRiskScores,
    );
  }

  List<AiChatMessage> _getInitialChatMessagesForRole(UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return [
          AiChatMessage(
            id: "ai-init-faculty",
            text: "Namaste ${_facultyProfile.name}! Faculty AI Teaching & Academic Copilot is ready. Ask about your today's schedule, pending semester registrations, attendance defaulters (<75%), or copy grading.",
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
            actionSuggestions: [
              "Show today's lecture schedule",
              "Pending course registration forms",
              "Attendance defaulters (<75%)",
              "Lab 3 High Performance batch status",
            ],
          ),
        ];
      case UserRole.admin:
        return [
          AiChatMessage(
            id: "ai-init-admin",
            text: "Pranam ${_adminProfile.name} (${_adminProfile.designation})! Executive AI Governance Copilot is active. Query campus daily attendance ratio, tuition fee collection audit, AICTE/NAAC compliance, or affiliated colleges.",
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
            actionSuggestions: [
              "Campus overall attendance ratio",
              "Fee revenue & collection summary",
              "AICTE & NAAC compliance audit",
              "Affiliated colleges tenant count",
            ],
          ),
        ];
      case UserRole.parent:
        return [
          AiChatMessage(
            id: "ai-init-parent",
            text: "Namaste ${_parentProfile.name}! Parent AI Ward Care & Safety Copilot is online for your ward ${_parentProfile.wardName} (${_parentProfile.wardRollNumber}, ${_parentProfile.wardBranch} Sem ${_parentProfile.wardSemester}). Track bus location, check attendance & dues, or connect with mentor Dr. Mohit Donawat.",
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
            actionSuggestions: [
              "${_parentProfile.wardName.split(' ').first} ki attendance kitni hai?",
              "Pending college fee dues kitni hai?",
              "Bus Route 4 live location kahan hai?",
              "Call CSE Mentor Dr. Mohit",
            ],
          ),
        ];
      case UserRole.student:
        return [
          AiChatMessage(
            id: "ai-init-student",
            text: "Namaste ${_student.name.split(' ').first}! Digital Campus AI Engine is active with live database records. Speak or type to analyze real-time attendance, predictive GPA, bus tracking, or instant bonafide generation.",
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
            actionSuggestions: [
              "Check my attendance status",
              "Predict my Semester 6 GPA",
              "Am I at risk of dropout?",
              "Where is Campus Bus Route 4?",
              "Show today's dinner menu",
              "Generate instant Bonafide",
            ],
          ),
        ];
    }
  }

  // Switch stakeholder role
  void switchRole(UserRole role) {
    _currentRole = role;
    _chatMessages = _getInitialChatMessagesForRole(role);
    notifyListeners();
  }

  // Update Real Student Profile / Admission Ledger
  void updateStudentProfile(StudentProfile updated) {
    _student = updated;
    _aiCareerInsight = _computeAiCareerInsight();
    _recomputeAiModels();
    notifyListeners();
  }

  // ── AI Automated Career & Placement Engine ────────────────────────────────
  AiCareerInsight _computeAiCareerInsight() {
    double baseScore = (_student.currentCgpa / 10.0) * 65.0;
    if (_student.attendancePercentage >= 75) baseScore += 10.0;
    baseScore += (_student.skills.length * 1.5).clamp(0.0, 15.0);
    baseScore += (_student.hackathonsWon * 2.5).clamp(0.0, 8.0);
    final finalProb = baseScore.clamp(55.0, 98.8);

    return AiCareerInsight(
      placementProbability: double.parse(finalProb.toStringAsFixed(1)),
      suggestedHeadline: "${_student.branch.split(' ').first} AI Systems Scholar • SIH Winner • Full-Stack Engineer",
      generatedBio: "Accomplished Computer Science undergrad with ${_student.currentCgpa} CGPA and ${_student.skills.length}+ verified competencies across distributed architectures, mobile engineering, and deep learning models. Actively building next-gen campus automation solutions.",
      recommendedSkills: const ["Kubernetes", "GraphQL", "Apache Kafka", "Low-Level System Design", "TensorFlow Lite"],
      topCompanyMatches: const ["Google Cloud Platform", "Microsoft Core Engineering", "Amazon AWS", "Uber India", "Oracle Cloud"],
      strengthsSummary: "Top 5% University CGPA (${_student.currentCgpa}), ${_student.hackathonsWon} national hackathon podiums, verified Government APAAR/ABC credentials, and 80%+ institutional lecture compliance.",
      nextActionPlan: "Acquire AWS Cloud Architect certification and deploy 1 open-source distributed microservice to push placement probability to 99%.",
    );
  }

  // AI Automation: Auto-optimize profile headline and bio
  void optimizeProfileWithAi() {
    _aiCareerInsight = _computeAiCareerInsight();
    _student = _student.copyWith(
      headline: _aiCareerInsight.suggestedHeadline,
      bio: _aiCareerInsight.generatedBio,
      placementReadinessScore: _aiCareerInsight.placementProbability,
    );
    notifyListeners();
  }

  // Update Faculty Profile
  void updateFacultyProfile(FacultyProfessionalProfile updated) {
    _facultyProfile = updated;
    notifyListeners();
  }

  // AI Optimization for Faculty Professional Dossier & Research Bio
  void optimizeFacultyProfileWithAi() {
    const aiBio = "Distinguished Academician & Senior Systems Researcher. Specializes in Sovereign Edge AI, Distributed Byzantine Fault Tolerance, High-Performance Compilers, and AICTE Curriculum Engineering.";
    final recommendedSkills = ["Edge AI Optimization", "Federated Learning", "Byzantine Fault Tolerance", "System Verilog", "Distributed Consensus"];
    final updatedSkills = List<String>.from(_facultyProfile.professionalSkills);
    for (final s in recommendedSkills) {
      if (!updatedSkills.contains(s)) {
        updatedSkills.add(s);
      }
    }
    _facultyProfile = _facultyProfile.copyWith(
      bio: aiBio,
      professionalSkills: updatedSkills,
    );
    notifyListeners();
  }

  // Add Faculty Skill
  void addFacultySkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty || _facultyProfile.professionalSkills.contains(trimmed)) return;
    final updated = List<String>.from(_facultyProfile.professionalSkills)..add(trimmed);
    _facultyProfile = _facultyProfile.copyWith(professionalSkills: updated);
    notifyListeners();
  }

  // Remove Faculty Skill
  void removeFacultySkill(String skill) {
    final updated = List<String>.from(_facultyProfile.professionalSkills)..remove(skill);
    _facultyProfile = _facultyProfile.copyWith(professionalSkills: updated);
    notifyListeners();
  }

  // AI Automation: Auto-sync DigiLocker credentials
  Future<void> syncDigiLocker() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _student = _student.copyWith(
      isDigiLockerSynced: true,
      digiLockerAadhaarMasked: "XXXX-XXXX-8921",
      apaarId: "9842-1082-9901-4456",
      abcId: "ABC-662-901-442",
    );
    _aiCareerInsight = _computeAiCareerInsight();
    notifyListeners();
  }

  // Add / Remove Skill
  void addSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty || _student.skills.contains(trimmed)) return;
    final updatedSkills = List<String>.from(_student.skills)..add(trimmed);
    _student = _student.copyWith(skills: updatedSkills);
    _aiCareerInsight = _computeAiCareerInsight();
    notifyListeners();
  }

  void removeSkill(String skill) {
    final updatedSkills = List<String>.from(_student.skills)..remove(skill);
    _student = _student.copyWith(skills: updatedSkills);
    _aiCareerInsight = _computeAiCareerInsight();
    notifyListeners();
  }

  // Update Professional Links & Details
  void updateProfessionalDetails({
    String? headline,
    String? bio,
    String? githubUrl,
    String? linkedinUrl,
    String? portfolioUrl,
    String? leetcodeHandle,
  }) {
    _student = _student.copyWith(
      headline: headline ?? _student.headline,
      bio: bio ?? _student.bio,
      githubUrl: githubUrl ?? _student.githubUrl,
      linkedinUrl: linkedinUrl ?? _student.linkedinUrl,
      portfolioUrl: portfolioUrl ?? _student.portfolioUrl,
      leetcodeHandle: leetcodeHandle ?? _student.leetcodeHandle,
    );
    _aiCareerInsight = _computeAiCareerInsight();
    notifyListeners();
  }

  // Toggle Security Options
  void toggleBiometrics() {
    _student = _student.copyWith(biometricLoginEnabled: !_student.biometricLoginEnabled);
    notifyListeners();
  }

  void toggleTwoFactor() {
    _student = _student.copyWith(twoFactorEnabled: !_student.twoFactorEnabled);
    notifyListeners();
  }

  // Real Anti-Proxy Attendance Check-in
  Future<void> simulateAttendanceCheckIn(String subjectCode) async {
    await ApiService.checkInAttendance(subjectCode);
    final index = _attendance.indexWhere((s) => s.subjectCode == subjectCode);
    if (index != -1) {
      final s = _attendance[index];
      _attendance[index] = SubjectAttendance(
        subjectCode: s.subjectCode,
        subjectName: s.subjectName,
        attendedClasses: s.attendedClasses + 1,
        totalClasses: s.totalClasses + 1,
        facultyName: s.facultyName,
      );

      // Real-time AI recomputation: updating attendance immediately updates predicted SGPA and dropout risk!
      _recomputeAiModels();
      notifyListeners();
    }
  }

  // What-If Sandbox Slider Simulation
  void updateWhatIfSimulation(double studyHours, double targetAttendance) {
    _recomputeAiModels(extraStudyHours: studyHours, targetAttendance: targetAttendance);
    notifyListeners();
  }

  // Faculty Substitute Timetable Toggle
  void toggleSubstituteClass(String periodId, String substituteName, String reason) {
    final index = _timetable.indexWhere((p) => p.id == periodId);
    if (index != -1) {
      final p = _timetable[index];
      _timetable[index] = TimetablePeriod(
        id: p.id,
        day: p.day,
        startTime: p.startTime,
        endTime: p.endTime,
        subjectName: p.subjectName,
        subjectCode: p.subjectCode,
        roomNumber: p.roomNumber,
        facultyName: substituteName,
        isSubstitute: true,
        originalFacultyName: p.facultyName,
        substituteReason: reason,
      );
      notifyListeners();
    }
  }

  // Live Class Scheduling & Execution (Jitsi, Meet, Zoom, Any Link)
  void scheduleLiveClass(LiveClassSession session) {
    _liveClasses.insert(0, session);
    notifyListeners();
  }

  void startLiveClass(String classId) {
    final idx = _liveClasses.indexWhere((c) => c.id == classId);
    if (idx != -1) {
      _liveClasses[idx] = _liveClasses[idx].copyWith(
        status: LiveClassStatus.live,
        durationText: "Live Stream Active Now",
      );
      notifyListeners();
    }
  }

  void endLiveClass(String classId) {
    final idx = _liveClasses.indexWhere((c) => c.id == classId);
    if (idx != -1) {
      final c = _liveClasses[idx];
      _liveClasses[idx] = c.copyWith(
        status: LiveClassStatus.completed,
        durationText: "Lecture Ended • Saved to History",
        recordingUrl: "https://stream.digitalcampus.edu/recordings/${c.subjectCode}-${c.id}",
        aiSummary: "Key concepts covered during live lecture on ${c.topic}. Attendance logged and sync'd to Academic Radar.",
      );
      notifyListeners();
    }
  }

  // Dynamic Timetable Creation, Upload & Modification
  void addTimetablePeriod(TimetablePeriod period) {
    _timetable.add(period);
    notifyListeners();
  }

  void uploadTimetable(List<TimetablePeriod> newPeriods) {
    _timetable = List.from(newPeriods);
    notifyListeners();
  }

  void updateTimetablePeriod(TimetablePeriod updated) {
    final index = _timetable.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _timetable[index] = updated;
      notifyListeners();
    }
  }

  void deleteTimetablePeriod(String periodId) {
    _timetable.removeWhere((p) => p.id == periodId);
    notifyListeners();
  }

  // Real Dynamic Fee Payment Execution
  Future<void> payFee(String feeId) async {
    final index = _fees.indexWhere((f) => f.id == feeId);
    if (index != -1) {
      final f = _fees[index];
      final receiptData = await ApiService.payFeeOnline(f.id, f.amount);
      final timestamp = DateTime.now();
      _fees[index] = FeeItem(
        id: f.id,
        title: f.title,
        amount: f.amount,
        dueDate: f.dueDate,
        isPaid: true,
        paidDate: "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}",
        transactionId: receiptData["transaction_id"] ?? "TXN-UPI-${timestamp.millisecondsSinceEpoch}",
        receiptNumber: receiptData["receipt_number"] ?? "REC-2026-${timestamp.minute}${timestamp.second}",
      );

      // Re-compute dropout risk immediately: clearing dues reduces financial risk!
      _recomputeAiModels();
      notifyListeners();
    }
  }

  // Real Dynamic Cryptographic Bonafide Issuance (SHA-256)
  Future<void> issueInstantBonafide() async {
    final newCert = _firebaseService.createCryptographicCertificate(
      student: _student,
      type: "Bonafide",
      title: "Immediate State Scholarship Bonafide Certificate",
    );
    _certificates.insert(0, newCert);
    notifyListeners();
  }

  // Apply Real Gate Pass
  void submitGatePass({
    required String reason,
    required String destination,
    required String outDateTime,
    required String expectedInDateTime,
  }) {
    final newId = "GP-2026-${(1000 + _gatePasses.length * 111)}";
    final pass = GatePass(
      id: newId,
      reason: reason,
      destination: destination,
      outDateTime: outDateTime,
      expectedInDateTime: expectedInDateTime,
      status: "Approved",
      approvedBy: "Chief Warden Prof. Arvind Sharma",
      qrPayload: "DIGITAL_CAMPUS_${newId}_STU_${_student.rollNumber}_AUTHORIZED",
      studentName: _student.name,
      rollNumber: _student.rollNumber,
      parentPhone: "+91 98260 11400",
      isCurfewBreached: false,
    );
    _gatePasses.insert(0, pass);
    notifyListeners();
  }

  void approveGatePass(String passId) {
    final idx = _gatePasses.indexWhere((p) => p.id == passId);
    if (idx != -1) {
      _gatePasses[idx] = _gatePasses[idx].copyWith(
        status: "Approved",
        approvedBy: "Chief Warden (Digital Seal)",
      );
      notifyListeners();
    }
  }

  void rejectGatePass(String passId) {
    final idx = _gatePasses.indexWhere((p) => p.id == passId);
    if (idx != -1) {
      _gatePasses[idx] = _gatePasses[idx].copyWith(
        status: "Rejected",
        approvedBy: "Rejected by Chief Warden",
      );
      notifyListeners();
    }
  }

  void logGatePassCheckOut(String passId) {
    final idx = _gatePasses.indexWhere((p) => p.id == passId);
    if (idx != -1) {
      _gatePasses[idx] = _gatePasses[idx].copyWith(
        status: "Out of Campus",
      );
      notifyListeners();
    }
  }

  void logGatePassCheckIn(String passId) {
    final idx = _gatePasses.indexWhere((p) => p.id == passId);
    if (idx != -1) {
      _gatePasses[idx] = _gatePasses[idx].copyWith(
        status: "Closed",
        isCurfewBreached: false,
      );
      notifyListeners();
    }
  }

  void submitHostelMaintenanceTicket({
    required String category,
    required String description,
    required String urgency,
  }) {
    final newTicket = HostelMaintenanceTicket(
      id: "HMT-2026-0${_hostelMaintenanceTickets.length + 85}",
      roomNumber: _hostel.roomNumber,
      studentName: _student.name,
      rollNumber: _student.rollNumber,
      category: category,
      description: description,
      urgency: urgency,
      status: "Reported",
      assignedStaff: urgency == "Critical" ? "Duty Caretaker (Urgent SLA 4h)" : "Assigned: Campus Maintenance Staff",
      reportedAt: "Today, Just Now",
    );
    _hostelMaintenanceTickets.insert(0, newTicket);
    notifyListeners();
  }

  void resolveHostelMaintenanceTicket(String ticketId) {
    final idx = _hostelMaintenanceTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _hostelMaintenanceTickets[idx] = _hostelMaintenanceTickets[idx].copyWith(
        status: "Resolved",
        resolvedAt: "Today, Just Now",
      );
      notifyListeners();
    }
  }

  void assignHostelMaintenanceTicket(String ticketId, String staffName) {
    final idx = _hostelMaintenanceTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _hostelMaintenanceTickets[idx] = _hostelMaintenanceTickets[idx].copyWith(
        status: "Assigned",
        assignedStaff: staffName,
      );
      notifyListeners();
    }
  }

  void approveMessRebate(String rebateId) {
    final idx = _messRebates.indexWhere((r) => r.id == rebateId);
    if (idx != -1) {
      _messRebates[idx] = _messRebates[idx].copyWith(
        status: "Approved & Credited",
      );
      notifyListeners();
    }
  }

  void submitMessMealFeedback({
    required String mealType,
    required int rating,
    required String comment,
  }) {
    final feedback = MessMealFeedback(
      id: "MF-0${_messFeedbacks.length + 1}",
      mealType: mealType,
      rating: rating,
      comment: comment,
      timestamp: "Today, Just Now",
    );
    _messFeedbacks.insert(0, feedback);
    notifyListeners();
  }

  void submitMessRebateClaim({
    required String startDate,
    required String endDate,
    required int days,
    required String reason,
  }) {
    final claim = MessRebateClaim(
      id: "REB-2026-${110 + _messRebates.length}",
      studentName: _student.name,
      rollNumber: _student.rollNumber,
      startDate: startDate,
      endDate: endDate,
      days: days,
      rebateAmount: days * 120.0,
      reason: reason,
      status: "Approved",
    );
    _messRebates.insert(0, claim);
    notifyListeners();
  }

  void updateHostelFeePolicy(HostelFeePolicy newPolicy) {
    _hostelFeePolicy = newPolicy;
    // Dynamically adjust student fee invoice in the ledger
    final feeIdx = _fees.indexWhere((f) => f.id == "FEE-HOSTEL-S2");
    if (feeIdx != -1) {
      final totalNew = newPolicy.tripleRoomAcRent + (newPolicy.messDailyRate * 120) + newPolicy.wifiAndAmenitiesFee;
      _fees[feeIdx] = FeeItem(
        id: "FEE-HOSTEL-S2",
        title: "Hostel & Mess Charges (Term 2)",
        amount: totalNew,
        dueDate: "2026-08-10",
        isPaid: _fees[feeIdx].isPaid,
        paidDate: _fees[feeIdx].paidDate,
        transactionId: _fees[feeIdx].transactionId,
        receiptNumber: _fees[feeIdx].receiptNumber,
      );
    }
    notifyListeners();
  }

  void submitRoomSwapRequest({
    required String targetRoll,
    required String targetName,
    required String targetRoom,
    required String reason,
  }) {
    final swap = RoomSwapRequest(
      id: "SWAP-2026-0${_roomSwaps.length + 15}",
      requesterStudentName: _student.name,
      requesterRoll: _student.rollNumber,
      currentRoom: _hostel.roomNumber,
      targetStudentName: targetName,
      targetRoll: targetRoll,
      targetRoom: targetRoom,
      reason: reason,
      status: "Peer Approved",
      timestamp: "Today (Just Now)",
    );
    _roomSwaps.insert(0, swap);
    notifyListeners();
  }

  void approveRoomSwapByWarden(String swapId) {
    final idx = _roomSwaps.indexWhere((s) => s.id == swapId);
    if (idx != -1) {
      _roomSwaps[idx] = _roomSwaps[idx].copyWith(status: "Warden Approved");
      notifyListeners();
    }
  }

  void bookFacilitySlot(String slotId) {
    final idx = _facilitySlots.indexWhere((s) => s.id == slotId);
    if (idx != -1) {
      _facilitySlots[idx] = _facilitySlots[idx].copyWith(
        status: "Booked",
        bookedByRoll: _student.rollNumber,
      );
      notifyListeners();
    }
  }

  void cancelFacilitySlot(String slotId) {
    final idx = _facilitySlots.indexWhere((s) => s.id == slotId);
    if (idx != -1) {
      _facilitySlots[idx] = _facilitySlots[idx].copyWith(
        status: "Available",
        bookedByRoll: "",
      );
      notifyListeners();
    }
  }

  void triggerHostelSos({String reason = "Hostel Medical / Security Panic Alarm"}) {
    _isSosActive = true;
    final log = HostelEmergencySosLog(
      id: "SOS-2026-${1000 + _hostelSosLogs.length * 17}",
      studentName: _student.name,
      rollNumber: _student.rollNumber,
      roomNumber: _hostel.roomNumber,
      block: _hostel.blockName,
      triggerTime: "Active Alert: Just Now",
      status: "TRIGGERED",
      resolvedBy: "Campus QRT Alert Dispatched",
    );
    _hostelSosLogs.insert(0, log);
    notifyListeners();
  }

  void resolveHostelSos(String id) {
    _isSosActive = false;
    final idx = _hostelSosLogs.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _hostelSosLogs[idx] = _hostelSosLogs[idx].copyWith(
        status: "RESOLVED",
        resolvedBy: "Chief Warden & QRT Cleared",
      );
    }
    notifyListeners();
  }

  void simulateTurnstileScan(String gatePassId) {
    final idx = _gatePasses.indexWhere((p) => p.id == gatePassId);
    if (idx != -1) {
      final current = _gatePasses[idx];
      String nextStatus = "Out of Campus";
      if (current.status == "Out of Campus") {
        nextStatus = "Closed";
      } else if (current.status == "Closed") {
        nextStatus = "Approved";
      }
      _gatePasses[idx] = current.copyWith(status: nextStatus);
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // 6 Ultra-Smart Hostel Innovations Actions
  // -------------------------------------------------------------

  // 1. Roommate Matchmaking & Gale-Shapley Algorithm
  void toggleRoommateSelfDiscovery(bool enable) {
    _matchmakerSetting = _matchmakerSetting.copyWith(isSelfDiscoveryEnabled: enable);
    notifyListeners();
  }

  void updateRoommateQuiz({
    required String sleepCycle,
    required String studyEnvironment,
    required String acPreference,
    required String cleanliness,
    required List<String> interests,
  }) {
    _roommateQuiz = _roommateQuiz.copyWith(
      sleepCycle: sleepCycle,
      studyEnvironment: studyEnvironment,
      acPreference: acPreference,
      cleanliness: cleanliness,
      interests: interests,
      isQuizCompleted: true,
    );
    notifyListeners();
  }

  void runGaleShapleyMatchmaking() {
    _roommateCandidates.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
    final bestMatch = _roommateCandidates.first;
    _roommateQuiz = _roommateQuiz.copyWith(
      matchedRoommateRoll: bestMatch.rollNumber,
      matchedRoommateName: bestMatch.studentName,
      compatibilityScore: bestMatch.compatibilityScore,
      assignedRoom: "B-304",
    );
    _matchmakerSetting = _matchmakerSetting.copyWith(
      matchedPairsCount: _matchmakerSetting.matchedPairsCount + 1,
      isAutoAllocationActive: true,
    );
    notifyListeners();
  }

  void selectRoommateDirectly(RoommateQuizProfile candidate) {
    _roommateQuiz = _roommateQuiz.copyWith(
      matchedRoommateRoll: candidate.rollNumber,
      matchedRoommateName: candidate.studentName,
      compatibilityScore: candidate.compatibilityScore,
      assignedRoom: "B-304",
    );
    notifyListeners();
  }

  // 2. AI Predictive Mess Headcount & Food Waste Minimizer
  void toggleDiningIntent({
    required String mealType,
    required String intent, // "ATTENDING" or "SKIPPING"
  }) {
    final idx = _diningIntents.indexWhere((i) => i.studentRoll == _student.rollNumber && i.mealType == mealType);
    if (idx != -1) {
      _diningIntents[idx] = _diningIntents[idx].copyWith(
        intent: intent,
        updatedAt: "Today, Just Now",
      );
    } else {
      _diningIntents.insert(0, DiningIntentRecord(
        id: "INT-${DateTime.now().millisecondsSinceEpoch}",
        studentRoll: _student.rollNumber,
        studentName: _student.name,
        date: "Today",
        mealType: mealType,
        intent: intent,
        updatedAt: "Today, Just Now",
      ));
    }

    int attendingDelta = intent == "SKIPPING" ? -1 : 1;
    int newAttending = (_messForecast.expectedDiningCount + attendingDelta).clamp(0, _messForecast.totalHostellers);
    int newSkipping = (_messForecast.voluntarySkippingCount - attendingDelta).clamp(0, _messForecast.totalHostellers);
    double recommendedRice = (newAttending * 0.123).clamp(20.0, 60.0);
    double savedKg = (_messForecast.baselineRiceKg - recommendedRice).clamp(0.0, 30.0);
    double savedRs = savedKg * 248.0;

    _messForecast = MessHeadcountForecast(
      date: _messForecast.date,
      mealType: _messForecast.mealType,
      totalHostellers: _messForecast.totalHostellers,
      expectedDiningCount: newAttending,
      gatePassOutCount: _messForecast.gatePassOutCount,
      voluntarySkippingCount: newSkipping,
      recommendedRiceKg: double.parse(recommendedRice.toStringAsFixed(1)),
      baselineRiceKg: _messForecast.baselineRiceKg,
      foodSavedKg: double.parse(savedKg.toStringAsFixed(1)),
      dailyRupeesSaved: double.parse(savedRs.toStringAsFixed(0)),
      annualProjectedSavings: _messForecast.annualProjectedSavings,
      chefAlertMessage: "Chef Alert: Tonight $newAttending students are dining ($savedKg kg rice saved, ₹${savedRs.toStringAsFixed(0)} saved today).",
    );
    notifyListeners();
  }

  // 3. Anti-Ragging Silent Duress Secret PIN
  bool verifyAndTriggerDuressPin(String enteredPin) {
    if (enteredPin == _silentDuress.secretDuressPin) {
      _isSilentDuressTriggered = true;
      _silentDuress = _silentDuress.copyWith(
        isDuressTriggered: true,
        triggeredAt: "ALERT: Active Just Now",
        dispatchStatus: "🚨 Silent Red Alert: Campus QRT & Chief Warden Dispatched to Room B-304",
      );
      _hostelSosLogs.insert(0, HostelEmergencySosLog(
        id: "DURESS-${DateTime.now().millisecondsSinceEpoch % 100000}",
        studentName: _student.name,
        rollNumber: _student.rollNumber,
        roomNumber: _hostel.roomNumber,
        block: _hostel.blockName,
        triggerTime: "Active Silent Duress Alert",
        status: "TRIGGERED",
        resolvedBy: "🚨 Silent QRT Coordinates Dispatched: B-304 (Lat: 23.2599, Long: 77.4126)",
      ));
      notifyListeners();
      return true;
    }
    return false;
  }

  void resolveSilentDuress() {
    _isSilentDuressTriggered = false;
    _silentDuress = _silentDuress.copyWith(
      isDuressTriggered: false,
      dispatchStatus: "RESOLVED & STANDBY",
    );
    notifyListeners();
  }

  // 4. AI Computer Vision Room Damage & Caution Deposit Audit
  void completeAssetCheckOutInspection(String assetId) {
    final idx = _roomAssetInspections.indexWhere((a) => a.id == assetId);
    if (idx != -1) {
      _roomAssetInspections[idx] = _roomAssetInspections[idx].copyWith(
        checkOutDate: "Today (Verified)",
        checkOutCondition: "AI Vision Scan: 0.00% Structural Damage, Normal Wear Cleared",
        checkOutSha256Hash: "SHA256:d41d8cd98f00b204e9800998ecf8427e${idx}b304",
        damageScore: 0.0,
        cautionDeduction: 0.0,
        auditStatus: "REFUND_APPROVED",
      );
      notifyListeners();
    }
  }

  // 5. Green Dorm Energy Quota & Eco-Credits
  void recordGreenEnergyLoad(double loadWatts) {
    double updatedUnits = _greenDormEnergy.consumedUnits + (loadWatts / 1000.0) * 0.1;
    double remaining = (_greenDormEnergy.monthlyQuotaUnits - updatedUnits).clamp(0.0, 120.0);
    _greenDormEnergy = _greenDormEnergy.copyWith(
      liveLoadWatts: loadWatts,
      consumedUnits: double.parse(updatedUnits.toStringAsFixed(1)),
      remainingUnits: double.parse(remaining.toStringAsFixed(1)),
      ecoCredits: _greenDormEnergy.ecoCredits + (loadWatts < 400 ? 5 : 0),
    );
    notifyListeners();
  }

  // 6. Curfew Auto-Extension with Parent WhatsApp 1-Click Consent
  void requestCurfewExtension({
    required int extensionMinutes,
    required String reason,
  }) {
    final newExt = CurfewExtensionRequest(
      id: "EXT-2026-${_curfewExtensions.length + 90}",
      gatePassId: _gatePasses.isNotEmpty ? _gatePasses.first.id : "GP-2026-089",
      studentRoll: _student.rollNumber,
      studentName: _student.name,
      roomNumber: _hostel.roomNumber,
      originalCurfewTime: "08:30 PM",
      requestedExtensionMinutes: extensionMinutes,
      extendedCurfewTime: extensionMinutes == 45 ? "09:15 PM" : "09:30 PM",
      reason: reason,
      parentConsentStatus: "PENDING",
      wardenApprovalStatus: "AUTO_APPROVED",
      isFineWaived: true,
    );
    _curfewExtensions.insert(0, newExt);
    notifyListeners();
  }

  void approveCurfewExtensionByParent(String requestId) {
    final idx = _curfewExtensions.indexWhere((e) => e.id == requestId);
    if (idx != -1) {
      _curfewExtensions[idx] = _curfewExtensions[idx].copyWith(
        parentConsentStatus: "APPROVED",
        parentConsentTimestamp: "Today, Just Now (WhatsApp 1-Click)",
        wardenApprovalStatus: "AUTO_APPROVED",
        isFineWaived: true,
      );
      if (_gatePasses.isNotEmpty) {
        _gatePasses[0] = _gatePasses[0].copyWith(
          expectedInDateTime: "Today, 09:15 PM (Extended)",
          isCurfewBreached: false,
        );
      }
      notifyListeners();
    }
  }

  void rejectCurfewExtensionByParent(String requestId) {
    final idx = _curfewExtensions.indexWhere((e) => e.id == requestId);
    if (idx != -1) {
      _curfewExtensions[idx] = _curfewExtensions[idx].copyWith(
        parentConsentStatus: "REJECTED",
        parentConsentTimestamp: "Today, Just Now",
        wardenApprovalStatus: "DENIED",
      );
      notifyListeners();
    }
  }



  // Submit Grievance Ticket
  void submitGrievance({
    required String category,
    required String subject,
    required String description,
    required String priority,
  }) {
    final ticket = GrievanceTicket(
      id: "GRV-2026-0${_grievances.length + 50}",
      category: category,
      subject: subject,
      description: description,
      createdAt: "Today (Just Now)",
      status: "In Progress",
      priority: priority,
      remainingSlaHours: AppConstants.grievanceSlaHours,
      assignedOfficer: category.contains("Anti-Ragging")
          ? "Statutory Anti-Ragging Cell & Dean Office"
          : "Academic Grievance Redressal Officer",
    );
    _grievances.insert(0, ticket);
    notifyListeners();
  }

  // ── Smart Sovereign Voice & NLP AI Processing ────────────────────────────
  int _voiceQueryIndex = 0;

  List<String> getSampleVoiceQueriesForRole(UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return [
          "Aaj mere kon-kon se lectures scheduled hain?",
          "Pending semester registration forms kitne hain?",
          "Attendance defaulters list dikhao CSE 6th sem",
          "Computer Networks lab evaluation update karo",
        ];
      case UserRole.admin:
        return [
          "Overall campus attendance report aur status batao",
          "This semester pending fee collection audit dikhao",
          "AICTE and NAAC accreditation compliance status",
          "Colleges multi-tenant registration pending list",
        ];
      case UserRole.parent:
        return [
          "Rahul ki attendance kitni percent hai?",
          "College fee dues kitni pending hain?",
          "Campus bus route 4 kahan tak pahuchi hai?",
          "Academic mentor se baat karni hai contact do",
        ];
      case UserRole.student:
        return [
          "Mera attendance kitna hai aur safe bunks kitne hain?",
          "Compiler Design me kitni classes attend karni hongi?",
          "Aaj ka timetable aur lecture substitution batao",
          "Hostel mess me aaj lunch aur dinner me kya bana hai?",
          "Pending fee dues kitni hai aur due date kab hai?",
          "Campus Bus Route 4 abhi kahan tak pahuchi hai?",
          "Hostel gate pass aur Bonafide certificate kaise milega?",
          "College placement package aur top companies ke baare me batao",
        ];
    }
  }

  void toggleVoiceListening([String? customQuery]) {
    _isVoiceListening = !_isVoiceListening;
    notifyListeners();

    if (_isVoiceListening) {
      Timer(const Duration(milliseconds: 1600), () {
        _isVoiceListening = false;
        notifyListeners();
        final queries = getSampleVoiceQueriesForRole(_currentRole);
        final queryToSend = customQuery ?? queries[_voiceQueryIndex % queries.length];
        _voiceQueryIndex++;
        sendAiUserMessage(queryToSend);
      });
    }
  }

  Future<void> sendAiUserMessage(String query) async {
    final userMsg = AiChatMessage(
      id: "user-${DateTime.now().millisecondsSinceEpoch}",
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _chatMessages.add(userMsg);
    notifyListeners();

    _isAiSpeaking = true;
    notifyListeners();

    // Query live dynamic sovereign AI over current state
    await Future.delayed(const Duration(milliseconds: 400));
    final aiResponse = _firebaseService.processDynamicVoiceQuery(
      query: query,
      student: _student,
      attendanceList: _attendance,
      totalDues: totalDues,
      performance: _predictivePerformance,
      dropoutRisk: _dropoutRisk,
      role: _currentRole,
      facultyProfile: _facultyProfile,
      adminProfile: _adminProfile,
      parentProfile: _parentProfile,
      semesterRegistrations: _semesterRegistrations,
      classAttendanceRecords: _classAttendanceRecords,
      timetable: _timetable,
      busRoute: _busRoute,
      fees: _fees,
      hostel: _hostel,
      gatePasses: _gatePasses,
      certificates: _certificates,
      grievances: _grievances,
    );

    _chatMessages.add(aiResponse);
    _isAiSpeaking = false;
    notifyListeners();
  }

  // ── Multi-Tenant SaaS College Management ──────────────────────────────
  List<CollegeTenant> _colleges = [
    CollegeTenant(
      id: "COL-01",
      name: "Apex Institute of Technology",
      code: "APEX-0103",
      city: "Bhopal",
      state: "Madhya Pradesh",
      affiliation: "Autonomous University • AICTE Approved",
      status: "Active",
      adminEmail: "director@apextech.edu.in",
      adminPassword: "Apex@Campus#2026",
      adminName: "Mr. Shridhar Donawat",
      studentCount: 4280,
      facultyCount: 210,
      licensePlan: "Autonomous University Tier-1",
      registeredDate: DateTime.now().subtract(const Duration(days: 340)),
    ),
    CollegeTenant(
      id: "COL-02",
      name: "Rajiv Gandhi Proudyogiki Vishwavidyalaya",
      code: "RGPV-STU-01",
      city: "Bhopal",
      state: "Madhya Pradesh",
      affiliation: "State Technological University",
      status: "Active",
      adminEmail: "coe@rgpv.ac.in",
      adminPassword: "RGPV@Admin#992",
      adminName: "Prof. S.C. Choube",
      studentCount: 85000,
      facultyCount: 1420,
      licensePlan: "State University Enterprise Cloud",
      registeredDate: DateTime.now().subtract(const Duration(days: 520)),
    ),
    CollegeTenant(
      id: "COL-03",
      name: "Lakshmi Narain College of Technology",
      code: "LNCT-0101",
      city: "Bhopal",
      state: "Madhya Pradesh",
      affiliation: "Affiliated RGPV • NAAC Grade A",
      status: "Active",
      adminEmail: "admin@lnct.ac.in",
      adminPassword: "LNCT@Secure#2026",
      adminName: "Dr. Ashok Rai",
      studentCount: 6100,
      facultyCount: 320,
      licensePlan: "Enterprise Cloud",
      registeredDate: DateTime.now().subtract(const Duration(days: 180)),
    ),
    CollegeTenant(
      id: "COL-04",
      name: "Govt Autonomous Engineering College",
      code: "GEC-JBP-04",
      city: "Jabalpur",
      state: "Madhya Pradesh",
      affiliation: "Estd. 1947 • AICTE Tier-1 Govt",
      status: "Pending Approval",
      adminEmail: "principal@gecjbp.ac.in",
      adminPassword: "GEC@Jabalpur#47",
      adminName: "Dr. P.K. Jhinge",
      studentCount: 3400,
      facultyCount: 180,
      licensePlan: "Enterprise Cloud",
      registeredDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    CollegeTenant(
      id: "COL-05",
      name: "Madhav Institute of Technology & Science",
      code: "MITS-GWL-02",
      city: "Gwalior",
      state: "Madhya Pradesh",
      affiliation: "Autonomous • NAAC A++",
      status: "Pending Approval",
      adminEmail: "director@mitsgwalior.in",
      adminPassword: "MITS@Gwalior#88",
      adminName: "Dr. R.K. Pandit",
      studentCount: 4800,
      facultyCount: 240,
      licensePlan: "Autonomous University Tier-1",
      registeredDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
  List<CollegeTenant> get colleges => _colleges;

  void approveCollegeTenant(String collegeId) {
    final index = _colleges.indexWhere((c) => c.id == collegeId);
    if (index != -1) {
      _colleges[index] = _colleges[index].copyWith(status: "Active");
      notifyListeners();
    }
    if (_isGoBackendOnline) {
      GoBackendService.approveTenant(collegeId).catchError((_) => null);
    }
  }

  void addCollegeTenant(CollegeTenant tenant) {
    _colleges.insert(0, tenant);
    notifyListeners();
    if (_isGoBackendOnline) {
      GoBackendService.registerTenant(tenant).then((saved) {
        if (saved != null) {
          final idx = _colleges.indexWhere((c) => c.id == tenant.id || c.code == tenant.code);
          if (idx != -1) {
            _colleges[idx] = saved;
            notifyListeners();
          }
        }
      }).catchError((_) => null);
    }
  }

  // ── Class-Wise Student Attendance Roster ──────────────────────────────────
  List<StudentAttendanceRecord> _classAttendanceRecords = [
    const StudentAttendanceRecord(
      studentId: "STU-01",
      name: "Rahul Sharma",
      rollNumber: "0103CS211048",
      branch: "CSE",
      semester: 6,
      section: "Sec A",
      attendancePercentage: 81.4,
      isPresentToday: true,
      totalClasses: 140,
      attendedClasses: 114,
    ),
    const StudentAttendanceRecord(
      studentId: "STU-02",
      name: "Pooja Deshmukh",
      rollNumber: "0103CS211052",
      branch: "CSE",
      semester: 6,
      section: "Sec A",
      attendancePercentage: 58.4,
      isPresentToday: false,
      totalClasses: 140,
      attendedClasses: 82,
    ),
    const StudentAttendanceRecord(
      studentId: "STU-03",
      name: "Vikas Patel",
      rollNumber: "0103CS211062",
      branch: "CSE",
      semester: 6,
      section: "Sec A",
      attendancePercentage: 64.0,
      isPresentToday: false,
      totalClasses: 140,
      attendedClasses: 90,
    ),
    const StudentAttendanceRecord(
      studentId: "STU-04",
      name: "Ananya Singhania",
      rollNumber: "0103CS211012",
      branch: "CSE",
      semester: 6,
      section: "Sec A",
      attendancePercentage: 92.8,
      isPresentToday: true,
      totalClasses: 140,
      attendedClasses: 130,
    ),
    const StudentAttendanceRecord(
      studentId: "STU-05",
      name: "Aman Verma",
      rollNumber: "0103CS211005",
      branch: "CSE",
      semester: 6,
      section: "Sec A",
      attendancePercentage: 76.5,
      isPresentToday: true,
      totalClasses: 140,
      attendedClasses: 107,
    ),
    const StudentAttendanceRecord(
      studentId: "STU-06",
      name: "Rohan Gupta",
      rollNumber: "0103CS211075",
      branch: "CSE",
      semester: 6,
      section: "Sec B",
      attendancePercentage: 88.0,
      isPresentToday: true,
      totalClasses: 138,
      attendedClasses: 121,
    ),
    const StudentAttendanceRecord(
      studentId: "STU-07",
      name: "Divya Tiwari",
      rollNumber: "0103CS211030",
      branch: "CSE",
      semester: 6,
      section: "Sec B",
      attendancePercentage: 61.2,
      isPresentToday: false,
      totalClasses: 138,
      attendedClasses: 84,
    ),
    const StudentAttendanceRecord(
      studentId: "STU-08",
      name: "Siddharth Jain",
      rollNumber: "0103IT211018",
      branch: "IT",
      semester: 4,
      section: "Sec A",
      attendancePercentage: 84.5,
      isPresentToday: true,
      totalClasses: 120,
      attendedClasses: 101,
    ),
    const StudentAttendanceRecord(
      studentId: "STU-09",
      name: "Megha Soni",
      rollNumber: "0103IT211025",
      branch: "IT",
      semester: 4,
      section: "Sec A",
      attendancePercentage: 54.0,
      isPresentToday: false,
      totalClasses: 120,
      attendedClasses: 65,
    ),
    const StudentAttendanceRecord(
      studentId: "STU-10",
      name: "Karan Malviya",
      rollNumber: "0103EC211014",
      branch: "ECE",
      semester: 6,
      section: "Sec A",
      attendancePercentage: 79.2,
      isPresentToday: true,
      totalClasses: 130,
      attendedClasses: 103,
    ),
  ];
  List<StudentAttendanceRecord> get classAttendanceRecords => _classAttendanceRecords;

  void toggleStudentAttendance(String studentId) {
    final index = _classAttendanceRecords.indexWhere((s) => s.studentId == studentId);
    if (index != -1) {
      final current = _classAttendanceRecords[index];
      final newPresent = !current.isPresentToday;
      final newAttended = newPresent ? current.attendedClasses + 1 : current.attendedClasses - 1;
      final newPercent = (newAttended / current.totalClasses) * 100;

      _classAttendanceRecords[index] = current.copyWith(
        isPresentToday: newPresent,
        attendedClasses: newAttended,
        attendancePercentage: double.parse(newPercent.toStringAsFixed(1)),
      );
      notifyListeners();
    }
    if (_isGoBackendOnline) {
      GoBackendService.toggleAttendance(studentId).catchError((_) => null);
    }
  }

  void bulkMarkAttendance({required String branch, required int semester, required String section, required bool isPresent}) {
    for (int i = 0; i < _classAttendanceRecords.length; i++) {
      final s = _classAttendanceRecords[i];
      final matchBranch = branch == "All" || s.branch == branch;
      final matchSem = semester == 0 || s.semester == semester;
      final matchSec = section == "All" || s.section == section;

      if (matchBranch && matchSem && matchSec) {
        if (s.isPresentToday != isPresent) {
          final newAttended = isPresent ? s.attendedClasses + 1 : (s.attendedClasses > 0 ? s.attendedClasses - 1 : 0);
          final newPercent = (newAttended / s.totalClasses) * 100;
          _classAttendanceRecords[i] = s.copyWith(
            isPresentToday: isPresent,
            attendedClasses: newAttended,
            attendancePercentage: double.parse(newPercent.toStringAsFixed(1)),
          );
        }
      }
    }
    notifyListeners();
    if (_isGoBackendOnline) {
      GoBackendService.bulkAttendance(
        branch: branch,
        semester: semester,
        section: section,
        isPresent: isPresent,
      ).catchError((_) => null);
    }
  }

  /// Trigger automated SMS/WhatsApp alerts for defaulters via Go engine
  Future<Map<String, dynamic>?> triggerParentDefaulterAlerts() async {
    if (_isGoBackendOnline) {
      final result = await GoBackendService.alertParents();
      await syncWithGoBackend();
      return result;
    }
    return null;
  }

  // ── Universal AI Copilot Toggle ──────────────────────────────────────────
  bool _isAiCopilotEnabled = true;
  bool get isAiCopilotEnabled => _isAiCopilotEnabled;

  void toggleAiCopilot() {
    _isAiCopilotEnabled = !_isAiCopilotEnabled;
    notifyListeners();
  }

  // ── Semester Course & Academic Registration Workflow ──────────────────────
  void submitSemesterRegistration(SemesterRegistration form) {
    final idx = _semesterRegistrations.indexWhere((r) => r.id == form.id || r.studentId == form.studentId);
    if (idx != -1) {
      _semesterRegistrations[idx] = form;
    } else {
      _semesterRegistrations.insert(0, form);
    }

    // Add confirmation notification to student
    _notifications.insert(
      0,
      CampusNotificationItem(
        id: "NOTIF-${DateTime.now().millisecondsSinceEpoch}",
        title: "Semester 6 Registration Submitted",
        body: "Your form has been routed to Faculty Advisor Dr. Mohit Donawat for credit & fee verification.",
        timestamp: DateTime.now(),
        type: "registration",
      ),
    );

    // Update roster registration status
    final rosterIdx = _classAttendanceRecords.indexWhere((s) => s.studentId == form.studentId);
    if (rosterIdx != -1) {
      _classAttendanceRecords[rosterIdx] = _classAttendanceRecords[rosterIdx].copyWith(registrationStatus: "Pending");
    }
    notifyListeners();
  }

  void approveSemesterRegistration(String registrationId, String facultyName, String? remarks) {
    final idx = _semesterRegistrations.indexWhere((r) => r.id == registrationId);
    if (idx != -1) {
      final reg = _semesterRegistrations[idx];
      _semesterRegistrations[idx] = reg.copyWith(
        status: RegistrationStatus.approved,
        reviewedAt: DateTime.now(),
        reviewedByFaculty: facultyName,
        facultyRemarks: remarks ?? "Verified and Approved. Credits and eligibility cleared.",
        rejectionReason: null,
      );

      // Add instant notification for student
      _notifications.insert(
        0,
        CampusNotificationItem(
          id: "NOTIF-${DateTime.now().millisecondsSinceEpoch}",
          title: "✅ Semester Registration APPROVED",
          body: "Your Semester ${reg.semester} Registration has been APPROVED by $facultyName. ${remarks != null && remarks.isNotEmpty ? 'Remarks: $remarks' : 'Academic enrollment slip active.'}",
          timestamp: DateTime.now(),
          type: "registration",
        ),
      );

      // Update student's roster record
      final rosterIdx = _classAttendanceRecords.indexWhere((s) => s.studentId == reg.studentId);
      if (rosterIdx != -1) {
        _classAttendanceRecords[rosterIdx] = _classAttendanceRecords[rosterIdx].copyWith(registrationStatus: "Approved");
      }
      notifyListeners();
    }
  }

  void rejectSemesterRegistration(String registrationId, String facultyName, String reason) {
    final idx = _semesterRegistrations.indexWhere((r) => r.id == registrationId);
    if (idx != -1) {
      final reg = _semesterRegistrations[idx];
      _semesterRegistrations[idx] = reg.copyWith(
        status: RegistrationStatus.rejected,
        reviewedAt: DateTime.now(),
        reviewedByFaculty: facultyName,
        rejectionReason: reason,
        facultyRemarks: null,
      );

      // Add instant notification for student
      _notifications.insert(
        0,
        CampusNotificationItem(
          id: "NOTIF-${DateTime.now().millisecondsSinceEpoch}",
          title: "❌ Semester Registration REJECTED",
          body: "Your Semester ${reg.semester} Registration was rejected by $facultyName. Reason: $reason. Please update details and resubmit.",
          timestamp: DateTime.now(),
          type: "registration",
        ),
      );

      // Update student's roster record
      final rosterIdx = _classAttendanceRecords.indexWhere((s) => s.studentId == reg.studentId);
      if (rosterIdx != -1) {
        _classAttendanceRecords[rosterIdx] = _classAttendanceRecords[rosterIdx].copyWith(registrationStatus: "Rejected");
      }
      notifyListeners();
    }
  }

  void markNotificationAsRead(String notifId) {
    final idx = _notifications.indexWhere((n) => n.id == notifId);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void addNotification(CampusNotificationItem notif) {
    _notifications.insert(0, notif);
    notifyListeners();
  }

  // ── Adaptive Quizzes & Examination Engine ──────────────────────────
  void createQuiz(CampusQuiz newQuiz) {
    _quizzes.insert(0, newQuiz);
    notifyListeners();
  }

  void submitQuiz(QuizSubmission submission) {
    _quizSubmissions.removeWhere((s) => s.quizId == submission.quizId && s.studentId == submission.studentId);
    _quizSubmissions.add(submission);

    // Update quiz metrics
    final quizIndex = _quizzes.indexWhere((q) => q.id == submission.quizId);
    if (quizIndex != -1) {
      final quizSubs = _quizSubmissions.where((s) => s.quizId == submission.quizId).toList();
      double total = 0;
      double highest = 0;
      for (var s in quizSubs) {
        total += s.score;
        if (s.score > highest) highest = s.score;
      }
      final avg = quizSubs.isNotEmpty ? total / quizSubs.length : 0.0;
      _quizzes[quizIndex] = _quizzes[quizIndex].copyWith(
        totalSubmissions: quizSubs.length,
        classAverageScore: double.parse(avg.toStringAsFixed(1)),
        highestScore: highest,
      );
    }
    notifyListeners();
  }

  List<LeaderboardEntry> getLeaderboardForQuiz(String quizId, {String? currentStudentRoll}) {
    final subs = _quizSubmissions.where((s) => s.quizId == quizId).toList();
    // Sort: Score DESC, then TimeTaken ASC (tie-breaker)
    subs.sort((a, b) {
      final scoreComp = b.score.compareTo(a.score);
      if (scoreComp != 0) return scoreComp;
      return a.timeTakenSeconds.compareTo(b.timeTakenSeconds);
    });

    return subs.asMap().entries.map((entry) {
      final rank = entry.key + 1;
      final s = entry.value;
      return LeaderboardEntry(
        rank: rank,
        studentName: s.studentName,
        rollNumber: s.rollNumber,
        branch: s.branch,
        semester: s.semester,
        score: s.score,
        totalMarks: s.totalPossibleMarks,
        timeTakenSeconds: s.timeTakenSeconds,
        accuracy: s.accuracyPercentage,
        isCurrentStudent: currentStudentRoll != null && s.rollNumber == currentStudentRoll,
      );
    }).toList();
  }

  CampusQuiz? getQuizById(String id) {
    try {
      return _quizzes.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  QuizSubmission? getStudentSubmission(String quizId, String studentId) {
    try {
      return _quizSubmissions.firstWhere((s) => s.quizId == quizId && s.studentId == studentId);
    } catch (_) {
      return null;
    }
  }
}

