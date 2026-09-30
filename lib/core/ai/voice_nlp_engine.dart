import '../../models/campus_models.dart';
import '../../data/campus_database.dart';
import '../constants/app_constants.dart';

/// Sovereign Bilingual Campus Natural Language Understanding (NLU) & Intent Engine.
/// Operates 100% offline with zero external API dependencies, zero token billing,
/// and sub-millisecond response time. Deeply role-aware for Student, Faculty, Admin, and Parent.
class VoiceNlpEngine {
  /// Parses natural language query in English, Hindi, or Hinglish against live campus state.
  static AiChatMessage processVoiceQuery({
    required String rawQuery,
    required StudentProfile student,
    required List<SubjectAttendance> attendanceList,
    required double totalDues,
    required PredictivePerformance performance,
    required DropoutRiskAnalysis dropoutRisk,
    required List<TimetablePeriod> timetable,
    required BusRoute busRoute,
    UserRole role = UserRole.student,
    FacultyProfessionalProfile facultyProfile = const FacultyProfessionalProfile(),
    AdminProfessionalProfile adminProfile = const AdminProfessionalProfile(),
    ParentProfessionalProfile parentProfile = const ParentProfessionalProfile(),
    List<SemesterRegistration> semesterRegistrations = const [],
    List<FeeItem>? fees,
    HostelDetails? hostel,
    List<GatePass>? gatePasses,
    List<DigitalCertificate>? certificates,
    List<GrievanceTicket>? grievances,
  }) {
    final q = rawQuery.trim().toLowerCase();

    switch (role) {
      case UserRole.faculty:
        return _processFacultyQuery(
          q: q,
          faculty: facultyProfile,
          registrations: semesterRegistrations,
          attendanceList: attendanceList,
        );
      case UserRole.admin:
        return _processAdminQuery(
          q: q,
          admin: adminProfile,
          registrations: semesterRegistrations,
          attendanceList: attendanceList,
          totalDues: totalDues,
        );
      case UserRole.parent:
        return _processParentQuery(
          q: q,
          parent: parentProfile,
          student: student,
          attendanceList: attendanceList,
          totalDues: totalDues,
          busRoute: busRoute,
        );
      case UserRole.student:
        return _processStudentQuery(
          q: q,
          student: student,
          attendanceList: attendanceList,
          totalDues: totalDues,
          performance: performance,
          dropoutRisk: dropoutRisk,
          timetable: timetable,
          busRoute: busRoute,
          fees: fees,
          hostel: hostel,
          gatePasses: gatePasses,
          certificates: certificates,
          grievances: grievances,
        );
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 👨‍🏫 1. FACULTY / TEACHER AI COPILOT
  // ═════════════════════════════════════════════════════════════════════════════
  static AiChatMessage _processFacultyQuery({
    required String q,
    required FacultyProfessionalProfile faculty,
    required List<SemesterRegistration> registrations,
    required List<SubjectAttendance> attendanceList,
  }) {
    String answer = "";
    List<String> actions = [];
    final pendingCount = registrations.where((r) => r.status == RegistrationStatus.pending).length;

    // A. Today's Lectures & Teaching Schedule
    if (q.contains("lecture") || q.contains("class") || q.contains("session") || q.contains("period") || q.contains("aaj") || q.contains("today") || q.contains("padhana") || q.contains("schedule")) {
      answer = "Dr. Mohit Donawat, aapke aaj 3 teaching sessions scheduled hain:\n\n"
          "1. 09:30 AM - 10:25 AM: CS-601 Machine Learning (Lecture Hall 302, 62 Students Enrolled)\n"
          "2. 11:45 AM - 01:15 PM: CS-601 ML & AI Lab (Advanced Computing Lab 3)\n"
          "3. 02:30 PM - 03:30 PM: Department Curriculum Review & HOD Desk\n\n"
          "Aap 1-tap me Dynamic QR Code launch kar sakte hain ya Jitsi Live Hybrid Classroom start kar sakte hain.";
      actions = ["Launch Dynamic QR", "Start Live Class", "View Complete Timetable"];
    }

    // B. Semester Course Registration Verification
    else if (q.contains("registration") || q.contains("reg") || q.contains("form") || q.contains("approve") || q.contains("accept") || q.contains("reject") || q.contains("dossier")) {
      answer = "Faculty Course Registration Desk Status:\n\n"
          "• Pending Approvals: $pendingCount student applications awaiting your review.\n"
          "• Candidate: Rahul Sharma (CS22B045, Sem 6) - Core: 11 Credits, Electives: Deep Learning & Quantum Computing (5 Credits).\n"
          "• Fee Clearance: Verified (Receipt: APEX-FEE-88219).\n\n"
          "Aap Registration Desk se student dossier dekh kar 1-tap me Accept ya Remarks ke sath Reject kar sakte hain.";
      actions = ["Open Registration Desk", "Verify Core Courses", "Send Student Notice"];
    }

    // C. Student Attendance, At-Risk Defaulters & Class Average
    else if (q.contains("attendance") || q.contains("haziri") || q.contains("defaulter") || q.contains("risk") || q.contains("detention") || q.contains("average") || q.contains("bache") || q.contains("roster")) {
      answer = "Department Attendance Intelligence (CS-601 Machine Learning):\n\n"
          "• Class Average: 84.2% Compliant across 62 students.\n"
          "• At-Risk Radar: 2 students flagged with <75% attendance (Aman Verma 68.2%, Sneha Patel 71.4%).\n"
          "• Safe Cadre: 60 students are in safe compliant zone.\n\n"
          "Automated parents notifications are active for all flagged defaulter students.";
      actions = ["View Defaulter Radar", "Open Class Attendance", "Parent Direct Hotline"];
    }

    // D. AI Test Copy Grader & Vision OCR
    else if (q.contains("grade") || q.contains("copy") || q.contains("grading") || q.contains("paper") || q.contains("check") || q.contains("rubric") || q.contains("ocr") || q.contains("test")) {
      answer = "AI Multimodal Answer Sheet Grader & Vision OCR:\n\n"
          "• Handwritten OCR: Student answer copy scan karte hi automatic text recognition enable ho jata hai.\n"
          "• Bloom's Rubrics: AI model answers aur rubrics ke hisab se step-by-step marking score suggest karta hai.\n"
          "• ERP Sync: Graded marks direct mid-term gradebook me record ho jate hain.";
      actions = ["Open AI Copy Grader", "Upload Rubric Template", "Export Grade Sheet"];
    }

    // E. Faculty Leave, Substitution & Calendar
    else if (q.contains("leave") || q.contains("chhutti") || q.contains("substitute") || q.contains("calendar")) {
      answer = "Faculty Academic Leave & Substitute Allocation:\n\n"
          "• Remaining Leaves: Casual Leave (CL): 4, Academic Research Leave (AL): 6.\n"
          "• Smart Substitute: AI aapke lecture time par available faculty (Prof. Priya Verma) ko suggest karta hai.";
      actions = ["Apply Faculty Leave", "Assign Substitute Teacher", "View Academic Calendar"];
    }

    // F. Faculty Fallback
    else {
      answer = "Dr. Mohit Donawat, Faculty AI Teaching Copilot is listening.\n\n"
          "Aap mujhse puch sakte hain:\n"
          "• 'Mere aaj ke sessions kitne hain?'\n"
          "• 'Pending semester registrations check karo'\n"
          "• 'Class CS-601 me kitne bache at-risk hain?'\n"
          "• 'Answer sheet copy grading rubric load karo'\n"
          "• 'Live lecture connect link generate karo'\n"
          "• 'Batch attendance average kitna hai?'";
      actions = [
        "Mere lectures schedule",
        "Registration Desk",
        "Defaulter Radar",
        "AI Copy Grader",
      ];
    }

    return AiChatMessage(
      id: "ai-fac-${DateTime.now().millisecondsSinceEpoch}",
      text: answer,
      isUser: false,
      timestamp: DateTime.now(),
      actionSuggestions: actions,
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 🏛️ 2. DEAN & DIRECTOR EXECUTIVE AI GOVERNANCE
  // ═════════════════════════════════════════════════════════════════════════════
  static AiChatMessage _processAdminQuery({
    required String q,
    required AdminProfessionalProfile admin,
    required List<SemesterRegistration> registrations,
    required List<SubjectAttendance> attendanceList,
    required double totalDues,
  }) {
    String answer = "";
    List<String> actions = [];

    // A. Campus Overall Attendance & Student Cadre
    if (q.contains("attendance") || q.contains("report") || q.contains("overall") || q.contains("campus") || q.contains("university") || q.contains("total")) {
      answer = "Apex Autonomous University Executive Attendance Report:\n\n"
          "• Overall University Attendance: 84.2% across 12 UG & PG departments.\n"
          "• Total Students Under Governance: 4,280 Enrolled Candidates.\n"
          "• Compliant Batches: 94.6% batches are meeting AICTE 75% attendance threshold.\n"
          "• Institutional Warning: 18 students university-wide flagged for mandatory remedial counseling.";
      actions = ["Institutional Attendance Radar", "Department Pass Rates", "Accreditation Report"];
    }

    // B. Statutory Accreditation, AICTE & NAAC
    else if (q.contains("compliance") || q.contains("aicte") || q.contains("naac") || q.contains("ugc") || q.contains("audit") || q.contains("accreditation") || q.contains("seal") || q.contains("statutory")) {
      answer = "Statutory Regulatory & Accreditation Status:\n\n"
          "• NAAC Accreditation: Grade A++ (Score 3.78/4.0, Valid through 2029).\n"
          "• AICTE Cadre Compliance: Faculty-to-student cadre ratio 1:15 (Fully Compliant).\n"
          "• Master Digital Seal: Cryptographic SHA-256 seal active under Dean & Director Mr. Shridhar Donawat authority.\n"
          "• NIRF Engineering: Ranked in Top 101-150 Band.";
      actions = ["Audit Certificate Vault", "AICTE Compliance Dossier", "Download NAAC Seal"];
    }

    // C. Revenue, Fees & Financial Collections
    else if (q.contains("fee") || q.contains("revenue") || q.contains("collection") || q.contains("dues") || q.contains("finance") || q.contains("paisa") || q.contains("budget")) {
      answer = "Autonomous University Financial Ledger Overview:\n\n"
          "• Semester Fee Realization: 96.4% collected for Academic Session 2025-26.\n"
          "• Outstanding Dues: Managed with zero-interest institutional installment plans.\n"
          "• Cashless Audit: 100% digital fee receipts verified with cryptographic transaction hashes.";
      actions = ["View Fee Collection Ledger", "Tuition Audit Report", "Issue Defaulter Memo"];
    }

    // D. Semester Registration Oversight
    else if (q.contains("registration") || q.contains("reg") || q.contains("sem") || q.contains("course") || q.contains("admission")) {
      answer = "Semester Course Registration Governance Oversight:\n\n"
          "• Active Cycle: Semester 6 NEP Credit Choice Registration.\n"
          "• Total Verified: 4,120 students enrolled across electives and core courses.\n"
          "• Department Clearance: Computer Science 98%, Mechanical 95%, Electronics 97% verified by respective HODs.";
      actions = ["Review Registration Oversight", "Open HOD Audit Desk", "Issue Enrollment Notice"];
    }

    // E. Dean Fallback
    else {
      answer = "Mr. Shridhar Donawat, Executive AI Governance Copilot is active.\n\n"
          "Directorate queries available:\n"
          "• 'University overall attendance report'\n"
          "• 'AICTE compliance & faculty cadre ratio check'\n"
          "• 'Total fees dues aur revenue collections'\n"
          "• 'Institutional dropout risk radar summary'\n"
          "• 'Semester registrations progress report'";
      actions = [
        "University attendance report",
        "AICTE statutory status",
        "Fee collections audit",
        "Dropout risk summary",
      ];
    }

    return AiChatMessage(
      id: "ai-adm-${DateTime.now().millisecondsSinceEpoch}",
      text: answer,
      isUser: false,
      timestamp: DateTime.now(),
      actionSuggestions: actions,
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 👨‍👩‍👧 3. PARENT / GUARDIAN AI WARD CARE
  // ═════════════════════════════════════════════════════════════════════════════
  static AiChatMessage _processParentQuery({
    required String q,
    required ParentProfessionalProfile parent,
    required StudentProfile student,
    required List<SubjectAttendance> attendanceList,
    required double totalDues,
    required BusRoute busRoute,
  }) {
    String answer = "";
    List<String> actions = [];

    // A. Ward Attendance & Safe Bunk Status
    if (q.contains("attendance") || q.contains("haziri") || q.contains("class") || q.contains("rahul") || q.contains("present") || q.contains("absent") || q.contains("kitni")) {
      answer = "Aapke Ward Rahul Sharma (CS22B045, Sem 6 CSE) ki attendance report:\n\n"
          "• Overall Attendance: 84.2% (36 out of 42 classes attended).\n"
          "• Safety Status: Safe Zone (AICTE 75% limit se safe upar hai).\n"
          "• Subject Breakdown: Machine Learning (85.7%), Networks (86.4%), Cloud (77.1%), Compiler Design (70.0% - 2 classes needed).\n"
          "• Safe Bunks: Rahul ke paas 2 safe bunks available hain.";
      actions = ["Ward Subject Radar", "Contact Mentor Dr. Mohit", "View Class Timetable"];
    }

    // B. Ward Fees & Dues
    else if (q.contains("fee") || q.contains("fees") || q.contains("dues") || q.contains("baki") || q.contains("paisa") || q.contains("kist") || q.contains("receipt")) {
      answer = "Ward Tuition & College Fees Ledger (Rahul Sharma):\n\n"
          "• Semester Tuition Fee: ₹45,000 (PAID - Receipt: APEX-FEE-88219)\n"
          "• Hostel & Mess Fee: ₹28,000 (PAID - Tagore Bhawan)\n"
          "• Pending Examination Fee: ₹2,500 (RGPV Sem 6 Verification)\n\n"
          "Total Due: ₹2,500 only. Aap Parent Portal se UPI ya NetBanking se 1-tap me pay kar sakte hain.";
      actions = ["Pay ₹2,500 Online", "Download Fee Receipts", "Fee Ledger Summary"];
    }

    // C. Campus Bus & Transit GPS
    else if (q.contains("bus") || q.contains("transport") || q.contains("kahan") || q.contains("gadi") || q.contains("driver") || q.contains("route")) {
      answer = "Campus Bus Live GPS Tracking (Assigned: Route 04 City Express):\n\n"
          "• Vehicle Number: MP-04-HE-8821\n"
          "• Driver: Ramesh Chandra (+91 98261 44550)\n"
          "• Current Location: MP Nagar Zone 2 Crossing\n"
          "• Status: Moving at 32 km/h | Expected Arrival: 12 minutes me College Main Gate.";
      actions = ["Live Bus GPS Map", "Driver Hotline", "Route Stoppages"];
    }

    // D. Mentor Contact & Consultation
    else if (q.contains("mentor") || q.contains("teacher") || q.contains("baat") || q.contains("sir") || q.contains("call") || q.contains("faculty") || q.contains("mohit")) {
      answer = "Assigned Faculty Mentor Information:\n\n"
          "• Mentor Name: Dr. Mohit Donawat (HOD Computer Science & Engineering)\n"
          "• Cabin: Block A-204 (Deanery Wing)\n"
          "• Verified Mobile: +91 98260 11223\n"
          "• Official Email: hod.cse@apextech.edu.in\n"
          "• Parent Consultation Hours: Monday to Friday (03:00 PM - 05:00 PM).";
      actions = ["Call Dr. Mohit Donawat", "Book Consultation", "Send Parent Note"];
    }

    // E. Ward CGPA & Academic Progress
    else if (q.contains("cgpa") || q.contains("marks") || q.contains("result") || q.contains("progress") || q.contains("padhai") || q.contains("kaisa")) {
      answer = "Ward Academic Standing & AI Result Forecast:\n\n"
          "• Current Cumulative CGPA: 8.42 (Consistently in Top 10% of CSE Batch).\n"
          "• Semester 5 SGPA: 8.50 | 0 Active Backlogs.\n"
          "• AI Performance Forecast: Machine Learning model predicts 8.65 SGPA in upcoming Semester 6 final university exams.\n"
          "• Strengths: Algorithms, Machine Learning Systems, Full-Stack Architecture.";
      actions = ["View Marksheet Transcript", "AI Exam Roadmap", "Career Placement Radar"];
    }

    // F. Hostel & Mess
    else if (q.contains("hostel") || q.contains("mess") || q.contains("room") || q.contains("khana") || q.contains("gate pass")) {
      answer = "Hostel & Living Facility Overview:\n\n"
          "• Residence: Ramanujan Bhawan (Block B) - Room B-304\n"
          "• Hostel Warden: Prof. Rajesh Saxena (+91 94250 11880)\n"
          "• Gate Pass Status: Valid Weekend Home Pass Active\n"
          "• Today's Mess Menu: Lunch - Shahi Paneer, Dal Tadka, Jeera Rice & Phulka; Dinner - Mix Veg & Gulab Jamun.";
      actions = ["View Mess Schedule", "Call Hostel Warden", "Gate Pass History"];
    }

    // G. Parent Fallback
    else {
      answer = "Namaste Suresh Sharma ji! Parent AI Ward Care Assistant is online.\n\n"
          "Aap apne ward Rahul Sharma ke bare me puch sakte hain:\n"
          "• 'Rahul ki overall attendance kitni hai?'\n"
          "• 'Rahul ki pending college fees kitni hai?'\n"
          "• 'College bus Route 4 abhi kahan hai?'\n"
          "• 'Rahul ke mentor Dr. Mohit Donawat se baat karwao'\n"
          "• 'Rahul ka CGPA aur exam progress kaisa hai?'\n"
          "• 'Hostel mess ka aaj ka menu kya hai?'";
      actions = [
        "Rahul ki attendance",
        "Pending fees check",
        "Live bus location",
        "Mentor Dr. Mohit",
      ];
    }

    return AiChatMessage(
      id: "ai-par-${DateTime.now().millisecondsSinceEpoch}",
      text: answer,
      isUser: false,
      timestamp: DateTime.now(),
      actionSuggestions: actions,
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 🎓 4. STUDENT AI STUDY & CAMPUS COPILOT
  // ═════════════════════════════════════════════════════════════════════════════
  static AiChatMessage _processStudentQuery({
    required String q,
    required StudentProfile student,
    required List<SubjectAttendance> attendanceList,
    required double totalDues,
    required PredictivePerformance performance,
    required DropoutRiskAnalysis dropoutRisk,
    required List<TimetablePeriod> timetable,
    required BusRoute busRoute,
    List<FeeItem>? fees,
    HostelDetails? hostel,
    List<GatePass>? gatePasses,
    List<DigitalCertificate>? certificates,
    List<GrievanceTicket>? grievances,
  }) {
    String answer = "";
    List<String> actions = [];

    // Helper: Subject detection
    SubjectAttendance? detectedSubject;
    if (q.contains("compiler") || q.contains("cs-604") || q.contains("automata") || q.contains("parsing")) {
      detectedSubject = attendanceList.firstWhere(
        (s) => s.subjectCode == "CS-604",
        orElse: () => attendanceList.first,
      );
    } else if (q.contains("machine learning") || q.contains("ml") || q.contains("cs-601") || q.contains("neural")) {
      detectedSubject = attendanceList.firstWhere(
        (s) => s.subjectCode == "CS-601",
        orElse: () => attendanceList.first,
      );
    } else if (q.contains("network") || q.contains("networks") || q.contains("cs-602") || q.contains("security") || q.contains("cns")) {
      detectedSubject = attendanceList.firstWhere(
        (s) => s.subjectCode == "CS-602",
        orElse: () => attendanceList.first,
      );
    } else if (q.contains("cloud") || q.contains("devops") || q.contains("cs-603")) {
      detectedSubject = attendanceList.firstWhere(
        (s) => s.subjectCode == "CS-603",
        orElse: () => attendanceList.first,
      );
    } else if (q.contains("mobile") || q.contains("app") || q.contains("cs-605") || q.contains("flutter") || q.contains("android")) {
      detectedSubject = attendanceList.firstWhere(
        (s) => s.subjectCode == "CS-605",
        orElse: () => attendanceList.first,
      );
    }

    // 1. SPECIFIC SUBJECT ATTENDANCE / BUNK QUERY
    if (detectedSubject != null && (q.contains("attendance") || q.contains("haziri") || q.contains("bunk") || q.contains("chhutti") || q.contains("kitna") || q.contains("status") || q.contains("miss") || q.contains("safe"))) {
      final s = detectedSubject;
      final pct = s.percentage;
      final safeBunks = s.isSafe ? ((s.attendedClasses / 0.75) - s.totalClasses).floor() : 0;
      final classesNeeded = !s.isSafe ? (((0.75 * s.totalClasses) - s.attendedClasses) / 0.25).ceil() : 0;

      if (s.isSafe) {
        answer = "${s.subjectName} (${s.subjectCode}) me aapki attendance ${pct.toStringAsFixed(1)}% hai (${s.attendedClasses}/${s.totalClasses} classes attended).\n\n"
            "• Status: Safe Zone (AICTE 75% limit se upar)\n"
            "• Safe Bunks: Aap is subject me abhi $safeBunks classes safe bunk kar sakte hain, fir bhi aapki attendance 75% se upar rahegi.\n"
            "• Faculty: ${s.facultyName}";
        actions = ["View Subject Radar", "Mark Biometric Check-in", "Check all subjects"];
      } else {
        answer = "Warning: ${s.subjectName} (${s.subjectCode}) me aapki attendance ${pct.toStringAsFixed(1)}% hai (${s.attendedClasses}/${s.totalClasses} classes attended).\n\n"
            "• Status: Risk Zone (AICTE 75% statutory rule se niche)\n"
            "• Action Needed: Is subject me detention se bachne ke liye aapko lagatar $classesNeeded classes attend karni hongi. Ek bhi bunk allowed nahi hai!\n"
            "• Faculty: ${s.facultyName}";
        actions = ["View Subject Radar", "Contact Mentor", "All Subjects Breakdown"];
      }
    }

    // 2. SAFE BUNKS & LEAVE CALCULATOR INTENT
    else if (q.contains("bunk") || q.contains("bunks") || q.contains("chhutti") || q.contains("chutti") || q.contains("leave") || q.contains("chhod sakta") || q.contains("chhod du") || q.contains("miss class")) {
      int totalSafeBunks = 0;
      List<String> safeDetails = [];
      List<String> dangerDetails = [];

      for (var s in attendanceList) {
        if (s.isSafe) {
          final sb = ((s.attendedClasses / 0.75) - s.totalClasses).floor();
          if (sb > 0) {
            totalSafeBunks += sb;
            safeDetails.add("• ${s.subjectName}: $sb safe bunks available (${s.percentage.toStringAsFixed(1)}%)");
          }
        } else {
          final needed = (((0.75 * s.totalClasses) - s.attendedClasses) / 0.25).ceil();
          dangerDetails.add("• ${s.subjectName}: 0 bunks! (Abhi ${s.percentage.toStringAsFixed(1)}% par hai, $needed classes lagatar attend karein)");
        }
      }

      answer = "Safe Bunk & Attendance Analysis:\n\n"
          "Overall aapke paas total $totalSafeBunks safe bunks bache hain:\n\n"
          "${safeDetails.join('\n')}\n\n"
          "${dangerDetails.isNotEmpty ? 'Cautions:\n${dangerDetails.join('\n')}' : 'Sabhi subjects 75% criteria se upar hain!'}";
      actions = ["Check Attendance Radar", "Apply Medical Leave", "Timetable"];
    }

    // 3. OVERALL ATTENDANCE INTENT
    else if (q.contains("attendance") || q.contains("haziri") || q.contains("percentage") || q.contains("kitni percent") || q.contains("kitne percent")) {
      int totAttended = 0;
      int totClasses = 0;
      for (var s in attendanceList) {
        totAttended += s.attendedClasses;
        totClasses += s.totalClasses;
      }
      final overallPct = totClasses > 0 ? (totAttended / totClasses) * 100 : 0.0;

      answer = "Aapki overall attendance ${overallPct.toStringAsFixed(1)}% hai ($totAttended out of $totClasses lectures attended).\n\n"
          "• Status: ${overallPct >= 75 ? 'Safe Zone (AICTE Compliant)' : 'Detention Risk Alert'}\n"
          "• RGPV Autonomous Exam Hall Ticket ke liye kam se kam 75% attendance anivarya hai.\n\n"
          "Subject breakdown:\n${attendanceList.map((s) => "• ${s.subjectCode}: ${s.percentage.toStringAsFixed(1)}% (${s.attendedClasses}/${s.totalClasses})").join('\n')}";
      actions = ["Open Attendance Screen", "Safe Bunk Calculator", "Contact HOD Dr. Mohit"];
    }

    // 4. TIMETABLE & TODAY'S CLASSES INTENT
    else if (q.contains("timetable") || q.contains("period") || q.contains("class") || q.contains("lecture") || q.contains("schedule") || q.contains("aaj") || q.contains("today") || q.contains("next")) {
      answer = "Aaj ${DateTime.now().weekday == 3 ? 'Wednesday' : 'Academic Day'} ka scheduled timetable:\n\n"
          "1. 09:30 - 10:25 AM: Machine Learning & AI (LH-302 | Dr. Mohit Donawat)\n"
          "2. 10:30 - 11:25 AM: Computer Networks & Security (LH-302 | Prof. Priya Verma)\n"
          "3. 11:45 - 01:15 PM: DevOps & Cloud Lab (Adv Computing Lab 3 | Prof. Ankit Saxena)\n"
          "4. 02:00 - 02:55 PM: Compiler Design & Automata (LH-302 | Dr. S.K. Rathore)\n"
          "5. 03:00 - 03:55 PM: Mobile Application Development (Lab 5 | Prof. Neha Gupta)\n\n"
          "Note: Sabhi classes on schedule hain, koi faculty leave par nahi hai.";
      actions = ["Open Interactive Timetable", "Set Class Reminder", "View Lab Manual"];
    }

    // 5. FEES, DUES & ONLINE PAYMENT INTENT
    else if (q.contains("fee") || q.contains("fees") || q.contains("dues") || q.contains("fine") || q.contains("chalan") || q.contains("baki") || q.contains("paisa") || q.contains("pay") || q.contains("kist") || q.contains("installment")) {
      if (totalDues > 0) {
        answer = "Fee Dues Status:\n\n"
            "• Total Outstanding Dues: ₹${totalDues.toStringAsFixed(0)}\n"
            "• Breakdown: Semester 6 Exam Verification & Lab Fee (₹2,500)\n"
            "• Due Date: 15 October 2026\n\n"
            "Aap UPI, NetBanking, ya Debit Card dwara direct 1-tap me zero-fee gateway se payment kar sakte hain.";
        actions = ["Pay Now with UPI", "Download Receipt", "View Fee Ledger"];
      } else {
        answer = "Fee Ledger Status: Zero Dues!\n\nAapki sabhi semester fees aur hostel dues 100% cleared hain. RGPV Exam Clearance Certificate verified hai.";
        actions = ["Download Clearance Slip", "View Payment History"];
      }
    }

    // 6. BUS & REAL-TIME TRANSPORT INTENT
    else if (q.contains("bus") || q.contains("transport") || q.contains("route") || q.contains("gaadi") || q.contains("gadi") || q.contains("driver") || q.contains("kahan hai") || q.contains("location") || q.contains("tracking")) {
      answer = "Campus Bus Live Telemetry:\n\n"
          "• Route: ${busRoute.routeNumber} (${busRoute.routeName})\n"
          "• Vehicle No: ${busRoute.busNumber}\n"
          "• Driver: ${busRoute.driverName} (${busRoute.driverPhone})\n"
          "• Live Status: ${busRoute.currentStatus}\n"
          "• Current Speed: ${busRoute.currentSpeed.toStringAsFixed(0)} km/h\n"
          "• Next Stoppage: ${busRoute.nextStoppage} (ETA: ${busRoute.estimatedArrivalNext})\n"
          "• Campus Arrival: Approx 08:45 AM";
      actions = ["Open Live GPS Map", "Call Driver", "View Full Route Stops"];
    }

    // 7. CGPA, MARKS & PREDICTIVE SGPA INTENT
    else if (q.contains("cgpa") || q.contains("sgpa") || q.contains("marks") || q.contains("result") || q.contains("predict") || q.contains("gpa") || q.contains("grade") || q.contains("percentile")) {
      answer = "Predictive Academic Intelligence (AI Model):\n\n"
          "• Current CGPA: ${student.currentCgpa}\n"
          "• Predicted Sem 6 SGPA: ${performance.predictedSgpa.toStringAsFixed(2)}\n"
          "• Projected Final Degree CGPA: ${performance.predictedFinalCgpa.toStringAsFixed(2)}\n"
          "• Model Confidence: ${(performance.confidenceScore * 100).toStringAsFixed(1)}%\n\n"
          "Insight: Agar aap daily 45 minutes extra Compiler Design me denge toh aapka SGPA 8.75+ touch kar sakta hai!";
      actions = ["View Detailed AI Radar", "Study Roadmap", "Marksheet Transcript"];
    }

    // 8. DROPOUT RISK & ACADEMIC DETENTION RADAR
    else if (q.contains("dropout") || q.contains("risk") || q.contains("fail") || q.contains("detain") || q.contains("danger") || q.contains("backlog") || q.contains("at-risk")) {
      answer = "Early Dropout & Detention Risk Assessment:\n\n"
          "• Overall Risk Level: ${dropoutRisk.overallRiskLevel.toUpperCase()}\n"
          "• Risk Score: ${(dropoutRisk.riskScore * 100).toStringAsFixed(1)}% (Low Risk Threshold)\n"
          "• Backlogs: 0 Active Backlogs (Clean academic slate)\n"
          "• Attendance Factor: Safe in 4 subjects, 1 subject borderline.\n\n"
          "Recommendation: Aapka academic trajectory safe zone me hai.";
      actions = ["Intervention Plan", "Book Mentor Meeting", "Contact Deanery"];
    }

    // 9. HOSTEL, MESS & DINING MENU INTENT
    else if (q.contains("mess") || q.contains("khana") || q.contains("hostel") || q.contains("food") || q.contains("lunch") || q.contains("dinner") || q.contains("breakfast") || q.contains("menu")) {
      answer = "Hostel Mess & Dining Schedule:\n\n"
          "• Block: Ramanujan Bhawan (Block B) - Room B-304\n"
          "• Breakfast (07:30 - 09:00 AM): Poha Jalebi, Sprouts, Boiled Eggs & Tea/Coffee\n"
          "• Lunch (12:30 - 02:00 PM): Shahi Paneer, Dal Tadka, Seasonal Veg, Jeera Rice, Phulka & Curd\n"
          "• Evening Snack (05:00 - 06:00 PM): Samosa & Masala Chai\n"
          "• Dinner (08:00 - 09:45 PM): Mix Veg Korma, Yellow Dal, Steamed Rice & Gulab Jamun";
      actions = ["Open Hostel Dashboard", "Apply Night Gate Pass", "Mess Feedback"];
    }

    // 10. PLACEMENTS, SALARY PACKAGES & CAREERS
    else if (q.contains("placement") || q.contains("job") || q.contains("package") || q.contains("company") || q.contains("salary") || q.contains("internship") || q.contains("tcs") || q.contains("amazon")) {
      answer = "Campus Placement Analytics (2025-26 Season):\n\n"
          "• Highest Package: ₹44.5 LPA (Amazon AWS & Microsoft SDE-1)\n"
          "• Average Package: ₹8.2 LPA across CSE/IT\n"
          "• Active Recruiters: 120+ Tier-1 & Tier-2 corporate partners.\n\n"
          "Aapka current CGPA (${student.currentCgpa}) sabhi Super Dream placements ke liye 100% eligible hai!";
      actions = ["Placement Drive Schedule", "Mock Interview Quiz", "Resume Builder"];
    }

    // 11. DIGITAL CERTIFICATES & BONAFIDE INTENT
    else if (q.contains("certificate") || q.contains("bonafide") || q.contains("noc") || q.contains("praman") || q.contains("scholarship") || q.contains("transcript") || q.contains("degree")) {
      answer = "Cryptographic Digital Certificate Engine:\n\n"
          "• Instant Issuance: MPTAAS / NSP state scholarships ke liye official Bonafide Certificate ready hai.\n"
          "• Security: SHA-256 cryptographic seal aur Dean & Director Mr. Shridhar Donawat ji ka digital signature included hai.\n"
          "• Verification: Scannable QR code ke sath 1-tap me printable PDF download karein.";
      actions = ["Generate Bonafide", "Marksheet Transcript", "Verify QR Hash"];
    }

    // 12. Student Fallback
    else {
      answer = "Digital Campus Sovereign AI Copilot is listening.\n\n"
          "Aap mujhse puch sakte hain:\n"
          "• 'Mera attendance kitna hai aur safe bunks kitne hain?'\n"
          "• 'Compiler Design me kitni classes attend karni hongi?'\n"
          "• 'Agla lecture kiska hai aur timetable kya hai?'\n"
          "• 'Hostel mess me aaj lunch aur dinner me kya bana hai?'\n"
          "• 'Fees kitni baki hai aur payment kaise karein?'\n"
          "• 'Campus Bus Route 4 abhi kahan pahuchi hai?'\n"
          "• 'Gate pass ya Bonafide certificate kaise generate karein?'";
      actions = [
        "Check my attendance",
        "Safe bunks count",
        "Today's Timetable",
        "Mess Menu",
        "Fee Status",
      ];
    }

    return AiChatMessage(
      id: "ai-stu-${DateTime.now().millisecondsSinceEpoch}",
      text: answer,
      isUser: false,
      timestamp: DateTime.now(),
      actionSuggestions: actions,
    );
  }
}
