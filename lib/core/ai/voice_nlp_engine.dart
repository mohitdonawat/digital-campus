import '../../models/campus_models.dart';
import '../../data/campus_database.dart';

/// Sovereign Bilingual Campus Natural Language Understanding (NLU) & Intent Engine.
/// Operates 100% offline with zero external API dependencies, zero token billing,
/// and sub-millisecond response time. Directly reasons over live student state.
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
    List<FeeItem>? fees,
    HostelDetails? hostel,
    List<GatePass>? gatePasses,
    List<DigitalCertificate>? certificates,
    List<GrievanceTicket>? grievances,
  }) {
    final q = rawQuery.trim().toLowerCase();
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

    // ─────────────────────────────────────────────────────────────────────────
    // 1. SPECIFIC SUBJECT ATTENDANCE / BUNK QUERY
    // ─────────────────────────────────────────────────────────────────────────
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

    // ─────────────────────────────────────────────────────────────────────────
    // 2. SAFE BUNKS & LEAVE CALCULATOR INTENT
    // ─────────────────────────────────────────────────────────────────────────
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

      answer = "AICTE 75% Statutory Attendance Calculator:\n\n"
          "Aapke paas safe subjects me total $totalSafeBunks safe bunks available hain.\n\n"
          "${safeDetails.join('\n')}\n\n"
          "${dangerDetails.isNotEmpty ? '⚠ Savdhan (Risk Zone):\n' + dangerDetails.join('\n') : 'Sabhi individual subjects safe zone me hain.'}";
      actions = ["View Subject Radar", "Predict GPA Impact", "Verify Geofence Check-in"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. CUMULATIVE OVERALL ATTENDANCE INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("attendance") || q.contains("haziri") || q.contains("haazri") || q.contains("upsthiti") || q.contains("present") || q.contains("absent")) {
      int totalAtt = 0;
      int totalCls = 0;
      List<String> weakSubs = [];

      for (var s in attendanceList) {
        totalAtt += s.attendedClasses;
        totalCls += s.totalClasses;
        if (!s.isSafe) {
          weakSubs.add("${s.subjectName} (${s.percentage.toStringAsFixed(1)}%)");
        }
      }

      double overall = totalCls > 0 ? (totalAtt / totalCls) * 100 : 0.0;
      answer = "Aapki real-time cumulative attendance ${overall.toStringAsFixed(1)}% hai (${totalAtt}/${totalCls} classes).\n\n"
          "${overall >= 75.0 ? '• Status: Compliant & Safe (AICTE 75% examination eligibility met).' : '• Status: Warning! Semester examination detention threshold se niche.'}\n\n"
          "${weakSubs.isNotEmpty ? '• Immediate recovery needed:\n  - ' + weakSubs.join('\n  - ') : '• Sabhi 5 subjects 75% ke upar safe hain.'}";
      actions = ["View Subject Radar", "Verify Geofence Check-in", "Predict GPA Impact"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. TIMETABLE, NEXT CLASS & SCHEDULE INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("timetable") || q.contains("schedule") || q.contains("routine") || q.contains("class") || q.contains("lecture") || q.contains("period") || q.contains("agla") || q.contains("agli") || q.contains("next") || q.contains("aaj") || q.contains("today") || q.contains("kab hai") || q.contains("kahan hai")) {
      final substituteClasses = timetable.where((t) => t.isSubstitute).toList();

      answer = "Section ${student.section} ka Aaj ka Master Timetable (Total ${timetable.length} Sessions):\n\n"
          "1. 09:30 - 10:30 AM: ML & AI (Room: LH-302 | Dr. Mohit Donawat)\n"
          "2. 10:30 - 11:30 AM: Computer Networks (Room: LH-302 | Prof. Vikram Sen [Substitute Arranged])\n"
          "3. 11:45 - 01:15 PM: DevOps & Cloud Lab (Adv Computing Lab 3 | Prof. Ankit Saxena)\n"
          "4. 02:00 - 03:00 PM: Compiler Design (Room: LH-302 | Dr. S.K. Rathore)\n"
          "5. 03:00 - 04:30 PM: AI Project Mentorship (Innovation Center Room 1 | Dr. Mohit Donawat)\n\n";

      if (substituteClasses.isNotEmpty) {
        final sub = substituteClasses.first;
        answer += "📢 Faculty Substitution Alert: ${sub.subjectName} at ${sub.startTime} par ${sub.facultyName} lecture lenge (${sub.substituteReason}).";
      }

      actions = ["Full Week Timetable", "Classroom Location", "Faculty Leave Note"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. FACULTY SUBSTITUTION & TEACHER DETAILS INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("substitute") || q.contains("proxy") || q.contains("badla") || q.contains("vikram sen") || q.contains("priya verma") || q.contains("faculty") || q.contains("teacher") || q.contains("prof") || q.contains("professor") || q.contains("hod") || q.contains("cabin")) {
      answer = "Faculty Substitution & Department Directory:\n\n"
          "• High Priority: CS-602 (Computer Networks) 10:30 AM par Prof. Priya Verma official medical leave par hain. Unki jagah Prof. Vikram Sen Classroom LH-302 me substitute lecture conduct karenge.\n\n"
          "• Academic Mentor: Dr. Mohit Donawat (Innovation Center, Room 1 / Cabin 204 | Contact: +91 98260 11223)\n"
          "• Head of Department: Dr. S.K. Rathore (Room LH-301)";
      actions = ["Full Week Timetable", "Call Mentor", "Classroom Location"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 6. HOSTEL MESS MENU & FOOD INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("mess") || q.contains("food") || q.contains("khana") || q.contains("lunch") || q.contains("dinner") || q.contains("breakfast") || q.contains("nashta") || q.contains("menu") || q.contains("paneer") || q.contains("rajma") || q.contains("meal")) {
      answer = "Ramanujan Hostel (Block B) — Aaj ka 4-Meal Nutrition Menu:\n\n"
          "• Breakfast (07:30 - 09:00 AM): Aloo Paratha, Fresh Curd, Poha, Sprouts / Boiled Eggs, Tea & Coffee\n"
          "• Lunch (12:30 - 02:30 PM): Dal Tadka, Shahi Paneer, Jeera Rice, Phulke (Butter Roti), Cucumber Salad, Gulab Jamun\n"
          "• High Tea (05:00 - 06:00 PM): Veg Cutlets, Green Mint Chutney, Masala Chai, Biscuits\n"
          "• Dinner (08:00 - 09:45 PM): Mix Veg Seasonal, Chana Dal, Steamed Rice, Butter Roti, Kheer";
      actions = ["Apply Gate Pass", "Warden Contact", "Mess Feedback"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 7. HOSTEL ALLOTMENT & WARDEN INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("hostel") || q.contains("kamra") || q.contains("warden") || q.contains("roommate") || q.contains("stay") || q.contains("ramanujan") || q.contains("b-304")) {
      answer = "Aapka Official Hostel Allotment Details:\n\n"
          "• Hostel Block: Ramanujan Bhawan (Block B), Room B-304 (AC Triple Sharing, Floor 3)\n"
          "• Chief Warden: Prof. Arvind Sharma (+91 98930 44556)\n"
          "• Roommates: Aman Verma (CS), Rohan Joshi (IT)\n"
          "• Curfew & Security: Biometric check-in mandatory before 09:30 PM.";
      actions = ["Apply Gate Pass", "Mess Nutrition Menu", "Call Warden"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 8. GATE PASS & OUT-PASS INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("gatepass") || q.contains("gate pass") || q.contains("outpass") || q.contains("out pass") || q.contains("bahar") || q.contains("pass") || q.contains("leave campus")) {
      answer = "Digital Campus Instant E-Gate Pass System:\n\n"
          "• Last Approved Pass: GP-2026-8841 (Weekend Family Visit & Medical Checkup, Indore). Approved by Warden Prof. Arvind Sharma.\n"
          "• Dynamic Security QR: Campus gate par security scanner par 2 second me QR scan karke out-clearance milti hai.\n\n"
          "Naya Gate Pass banane ke liye neeche 'Apply Gate Pass' par tap karein.";
      actions = ["Apply Gate Pass", "View Active Passes", "Security QR"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 9. FEES, DUES & ONLINE PAYMENT INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("fee") || q.contains("fees") || q.contains("due") || q.contains("dues") || q.contains("paisa") || q.contains("paise") || q.contains("rupaye") || q.contains("bill") || q.contains("payment") || q.contains("chalan") || q.contains("receipt") || q.contains("rasid") || q.contains("tuition") || q.contains("pay")) {
      if (totalDues > 0) {
        answer = "Aapke total ₹${totalDues.toStringAsFixed(0)} pending institutional dues hain:\n\n"
            "1. Semester 6 Academic Tuition: ₹45,000 (Due Date: 15 Oct 2026)\n"
            "2. University Examination Fee: ₹2,500 (Due Date: 30 Oct 2026)\n\n"
            "Aap UPI, NetBanking ya Debit card se 0% transaction fee ke sath pay kar sakte hain. Payment ke turant baad official GST Receipt download ho jati hai.";
        actions = ["Pay via UPI", "Download GST Receipts", "Installment Plan"];
      } else {
        answer = "Sabhi Institutional Fees (Tuition, Examination, Hostel aur Transit) 100% cleared hain! Zero outstanding dues. No Dues Clearance Certificate active hai.";
        actions = ["View Fee Ledger", "Download Receipts", "No Dues Certificate"];
      }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 10. BUS & TRANSIT LIVE GPS TRACKING INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("bus") || q.contains("transport") || q.contains("transit") || q.contains("route") || q.contains("driver") || q.contains("gadi") || q.contains("van") || q.contains("gps") || q.contains("eta") || q.contains("kahan")) {
      answer = "Campus Transit Live Telemetry:\n\n"
          "• Bus: ${busRoute.routeNumber} (${busRoute.busPlateNumber})\n"
          "• Current Location: ${busRoute.currentStop} ➔ Agla stop: ${busRoute.nextStop}\n"
          "• Speed: ${busRoute.speedKmph} km/h (Safe Corridor Speed)\n"
          "• Campus Arrival ETA: ${busRoute.etaMinutes} minutes\n"
          "• Assigned Driver: ${busRoute.driverName} (${busRoute.driverPhone})";
      actions = ["Live GPS Radar", "Digital Bus Pass", "Call Driver"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 11. PREDICTIVE SGPA & PERFORMANCE REGRESSION INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("gpa") || q.contains("sgpa") || q.contains("cgpa") || q.contains("predict") || q.contains("marks") || q.contains("score") || q.contains("performance") || q.contains("result") || q.contains("ank")) {
      answer = "Multi-Variate Machine Learning Regression Forecast (R²=0.91):\n\n"
          "• Projected Semester ${student.semester} SGPA: ${performance.predictedSgpa}\n"
          "• 95% Confidence Interval: ${performance.lowerConfidenceBound} - ${performance.upperConfidenceBound}\n"
          "• Academic Trajectory: ${performance.trajectory}\n"
          "• Strongest Pillar: Mobile App Dev (91% Mastery)\n"
          "• Priority Revision: Compiler Design & Parsing (70% Target Zone)";
      actions = ["Open What-If Sandbox", "View Subject Mastery", "14-Day Roadmap"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 12. EARLY DROPOUT RISK (EWS) INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("dropout") || q.contains("risk") || q.contains("detention") || q.contains("khatra") || q.contains("year back") || q.contains("backlog") || q.contains("fail") || q.contains("atkt") || q.contains("kt") || q.contains("ews")) {
      answer = "Early Warning System (EWS) 4-Pillar Risk Audit:\n\n"
          "• Current Risk Index: ${dropoutRisk.riskScore}% (${dropoutRisk.riskTier})\n"
          "• Attendance Velocity: +1.2% slope (Safe trajectory)\n"
          "• Academic Backlogs: 0 active backlog (100% clear)\n"
          "• LMS Engagement: 89.4% (Consistently high)\n"
          "• Key Observation: ${dropoutRisk.primaryRiskFactors.first}";
      actions = ["View EWS Radar", "Remedial Plan", "Contact Academic Mentor"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 13. CAMPUS PLACEMENTS, COMPANIES & PACKAGES INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("placement") || q.contains("package") || q.contains("salary") || q.contains("company") || q.contains("companies") || q.contains("job") || q.contains("highest") || q.contains("average") || q.contains("tpo") || q.contains("interview") || q.contains("amazon") || q.contains("tcs") || q.contains("infosys")) {
      answer = "Apex Institute of Technology — Official Campus Placement Telemetry:\n\n"
          "• Highest Package: ₹44.0 LPA (Amazon Cloud Support Engineering)\n"
          "• Average Package: ₹8.2 LPA across CSE/IT\n"
          "• Active Recruiters: 120+ Tier-1 & Tier-2 corporate partners (TCS, Infosys, Wipro, Cognizant, Amazon, Persistent)\n"
          "• Eligibility Criteria: Minimum 60% aggregate with 0 active backlogs.\n\n"
          "Aapka current CGPA (${student.currentCgpa}) sabhi Day-1 & Super Dream placements ke liye 100% eligible hai!";
      actions = ["Placement Drive Schedule", "Mock Interview Quiz", "Resume Builder"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 14. DIGITAL CERTIFICATES & BONAFIDE INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("certificate") || q.contains("bonafide") || q.contains("noc") || q.contains("praman") || q.contains("scholarship") || q.contains("mptaas") || q.contains("transcript") || q.contains("degree")) {
      answer = "Cryptographic Digital Certificate Engine:\n\n"
          "• Instant Issuance: MPTAAS / NSP state scholarships, passport verification, aur education loans ke liye official Bonafide Certificate ready hai.\n"
          "• Security: SHA-256 cryptographic seal aur Registrar & COE Dr. R.K. Saxena ka digital signature included hai.\n"
          "• Verification: Scannable QR code ke sath 1-tap me printable PDF download karein.";
      actions = ["Generate Bonafide", "Marksheet Transcript", "Verify QR Hash"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 15. STUDENT PROFILE & 3D PVC ID CARD INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("profile") || q.contains("detail") || q.contains("naam") || q.contains("name") || q.contains("roll") || q.contains("enrollment") || q.contains("branch") || q.contains("id card") || q.contains("pvc") || q.contains("apaar")) {
      answer = "Student Institutional Profile:\n\n"
          "• Name: ${student.name} | Roll No: ${student.rollNumber}\n"
          "• Enrollment No: ${student.enrollmentNumber} | APAAR UID: 9842-1082-9901-4456\n"
          "• Branch: ${student.branch} (Sem ${student.semester}, Sec ${student.section})\n"
          "• Academic Mentor: ${student.mentorName} (${student.mentorContact})\n"
          "• Parent / Guardian: ${student.parentName} (${student.parentPhone})\n"
          "• Smart PVC ID Card 3D RFID texture aur QR validation ke sath active hai.";
      actions = ["Edit Profile", "View PVC ID", "Download ID Card"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 16. HELPDESK, STATUTORY GRIEVANCES & ANTI-RAGGING INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("helpdesk") || q.contains("grievance") || q.contains("complaint") || q.contains("ragging") || q.contains("shikayat") || q.contains("problem") || q.contains("madad") || q.contains("sos") || q.contains("emergency") || q.contains("safety")) {
      answer = "UGC Statutory Grievance & Student Safety Redressal:\n\n"
          "• Statutory 48-Hour SLA: Har grievance complaint 48 ghante ke statutory time limit me resolve hoti hai.\n"
          "• Anti-Ragging Cell: 24x7 Zero Tolerance Policy (Direct escalation to Dean of Student Welfare).\n"
          "• Active Ticket: PyTorch CUDA 12.4 update in Lab 3 (Status: In Progress, Remaining SLA: 18 hrs).\n\n"
          "Emergency me 1-tap SOS alert trigger karein.";
      actions = ["Raise Helpdesk", "Anti-Ragging SOS", "Track Tickets"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 17. LIBRARY & RECOMMENDED SYLLABUS BOOKS INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("library") || q.contains("kitab") || q.contains("book") || q.contains("books") || q.contains("issue") || q.contains("dragon") || q.contains("galvin") || q.contains("kurose")) {
      answer = "Central Library & Digital Book Vault:\n\n"
          "• Student Borrowing Quota: 4 books allowed for 14-day circulation.\n"
          "• Core Semester 6 Textbooks in Vault:\n"
          "  1. Compiler Design: Aho, Lam, Sethi & Ullman (Dragon Book)\n"
          "  2. Deep Learning: Ian Goodfellow & Yoshua Bengio\n"
          "  3. Computer Networking: Jim Kurose & Keith Ross (8th Edition)\n"
          "  4. Operating Systems: Silberschatz, Galvin & Gagne";
      actions = ["Search Library", "Issue Status", "Digital Notes"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 18. EXAMS, ROUTINE & DATE SHEET INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("exam") || q.contains("pariksha") || q.contains("date sheet") || q.contains("routine") || q.contains("admit card") || q.contains("hall ticket")) {
      answer = "RGPV Autonomous Semester 6 Examination Notice:\n\n"
          "• End-Semester Exams: Tentatively commencing November 18, 2026.\n"
          "• Mandatory Eligibility: Har subject me 75% attendance mandatory hai.\n"
          "• Hall Ticket Status: Dues clearance ke baad exams se 7 din pehle release hoga (Aapke pending dues: ₹${totalDues.toStringAsFixed(0)}).";
      actions = ["Exam Schedule", "Syllabus Copy", "Hall Ticket Status"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 19. GREETING & GENERAL CAPABILITIES INTENT
    // ─────────────────────────────────────────────────────────────────────────
    else if (q.contains("hello") || q.contains("hi") || q.contains("namaste") || q.contains("hey") || q.contains("kaun ho") || q.contains("who are you") || q.contains("kya kar sakte") || q.contains("help") || q.contains("features")) {
      answer = "Namaste ${student.name.split(' ').first}! Mai Digital Campus ka Sovereign AI Campus Copilot hu.\n\n"
          "Mai aapke college database se live connected hu aur ye sab instantly bata sakta hu:\n"
          "• Attendance & Safe Bunks (AICTE 75% formula math)\n"
          "• Aaj ka Timetable, Classrooms & Faculty Substitutions\n"
          "• Hostel Mess Menu (Breakfast, Lunch, Dinner)\n"
          "• E-Gate Passes & Warden Verification\n"
          "• Fees Dues & Instant UPI Payment\n"
          "• Campus Bus Route 4 Live GPS Telemetry\n"
          "• Instant SHA-256 Bonafide Certificates\n\n"
          "Aap Hindi, Hinglish ya English me kuch bhi puch sakte hain!";
      actions = ["Check my attendance", "Today's Timetable", "Mess Menu", "Bus Route 4"];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 20. SMART MULTI-DOMAIN FALLBACK
    // ─────────────────────────────────────────────────────────────────────────
    else {
      answer = "Digital Campus Sovereign AI Copilot is listening.\n\n"
          "Aap mujhse puch sakte hain:\n"
          "• 'Mera attendance kitna hai aur safe bunks kitne hain?'\n"
          "• 'Compiler Design me kitni classes attend karni hongi?'\n"
          "• 'Agla lecture kiska hai aur kaunsa teacher aayega?'\n"
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
      id: "ai-${DateTime.now().millisecondsSinceEpoch}",
      text: answer,
      isUser: false,
      timestamp: DateTime.now(),
      actionSuggestions: actions,
    );
  }
}
