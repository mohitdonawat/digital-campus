import '../models/campus_models.dart';

/// Digital Campus Official Institutional Database & Entity Registry
/// Live data records synchronized with SQLite & Cloud Firestore
class CampusDatabase {
  // Active Student Profile
  static const StudentProfile student = StudentProfile(
    id: "STU-2022-CS-045",
    name: "Rahul Sharma",
    rollNumber: "CS22B045",
    enrollmentNumber: "0176CS221045",
    branch: "Computer Science & Engineering",
    semester: 6,
    section: "A",
    currentCgpa: 8.42,
    attendancePercentage: 82.4,
    hostelBlock: "Ramanujan Bhawan (Block B)",
    roomNumber: "B-304",
    busRouteNumber: "Route 04 (City Express)",
    mentorName: "Dr. Mohit Donawat",
    mentorContact: "+91 98260 11223",
    parentName: "Suresh Sharma",
    parentPhone: "+91 94250 88991",
    lifecycleStage: "Core Specialization & Pre-Placement",
  );

  // Subject Attendance Records
  static final List<SubjectAttendance> initialAttendance = [
    const SubjectAttendance(
      subjectCode: "CS-601",
      subjectName: "Machine Learning & AI",
      attendedClasses: 36,
      totalClasses: 42,
      facultyName: "Dr. Mohit Donawat",
    ),
    const SubjectAttendance(
      subjectCode: "CS-602",
      subjectName: "Computer Networks & Security",
      attendedClasses: 38,
      totalClasses: 44,
      facultyName: "Prof. Priya Verma",
    ),
    const SubjectAttendance(
      subjectCode: "CS-603",
      subjectName: "Cloud Computing & DevOps",
      attendedClasses: 27,
      totalClasses: 35,
      facultyName: "Prof. Ankit Saxena",
    ),
    const SubjectAttendance(
      subjectCode: "CS-604",
      subjectName: "Compiler Design & Automata",
      attendedClasses: 28,
      totalClasses: 40,
      facultyName: "Dr. S.K. Rathore",
    ),
    const SubjectAttendance(
      subjectCode: "CS-605",
      subjectName: "Mobile Application Development",
      attendedClasses: 32,
      totalClasses: 36,
      facultyName: "Prof. Neha Gupta",
    ),
  ];

  // Daily Master Timetable
  static final List<TimetablePeriod> todayTimetable = [
    const TimetablePeriod(
      id: "TT-01",
      day: "Today",
      startTime: "09:30 AM",
      endTime: "10:30 AM",
      subjectName: "Machine Learning & AI",
      subjectCode: "CS-601",
      roomNumber: "LH-302",
      facultyName: "Dr. Mohit Donawat",
      isSubstitute: false,
    ),
    const TimetablePeriod(
      id: "TT-02",
      day: "Today",
      startTime: "10:30 AM",
      endTime: "11:30 AM",
      subjectName: "Computer Networks",
      subjectCode: "CS-602",
      roomNumber: "LH-302",
      facultyName: "Prof. Vikram Sen",
      isSubstitute: true,
      originalFacultyName: "Prof. Priya Verma",
      substituteReason: "Faculty on Medical Leave (Official substitute arranged)",
    ),
    const TimetablePeriod(
      id: "TT-03",
      day: "Today",
      startTime: "11:45 AM",
      endTime: "01:15 PM",
      subjectName: "DevOps & Cloud Lab",
      subjectCode: "CS-603L",
      roomNumber: "Advanced Computing Lab 3",
      facultyName: "Prof. Ankit Saxena",
      isSubstitute: false,
    ),
    const TimetablePeriod(
      id: "TT-04",
      day: "Today",
      startTime: "02:00 PM",
      endTime: "03:00 PM",
      subjectName: "Compiler Design",
      subjectCode: "CS-604",
      roomNumber: "LH-302",
      facultyName: "Dr. S.K. Rathore",
      isSubstitute: false,
    ),
    const TimetablePeriod(
      id: "TT-05",
      day: "Today",
      startTime: "03:00 PM",
      endTime: "04:30 PM",
      subjectName: "AI Project Mentorship & Doubt Session",
      subjectCode: "PROJ-6",
      roomNumber: "Innovation Center Room 1",
      facultyName: "Dr. Mohit Donawat",
      isSubstitute: false,
    ),
  ];

  // Cryptographic Digital Certificates
  static final List<DigitalCertificate> certificates = [
    const DigitalCertificate(
      id: "DC-2026-BF-9042",
      title: "Official Bonafide Certificate",
      type: "Bonafide",
      issueDate: "2026-09-15",
      issuedTo: "Rahul Sharma",
      rollNumber: "CS22B045",
      sha256Hash: "8f4a7c2b9e1103d85d7f198b2c4e339a0ef61899e31d45bc8120fa264e1c9e54",
      verificationUrl: "https://verify.digitalcampus.edu/cert/DC-2026-BF-9042",
      isAttested: true,
      attestedBy: "Dr. R.K. Saxena (Registrar & COE)",
    ),
    const DigitalCertificate(
      id: "DC-2026-MS-5512",
      title: "Semester 5 Grade Sheet & Transcript",
      type: "Marksheet",
      issueDate: "2026-07-20",
      issuedTo: "Rahul Sharma",
      rollNumber: "CS22B045",
      sha256Hash: "4b92c81da53341b899ef3104e76d8b671a80c32490dfac138e6e5a0723ff4119",
      verificationUrl: "https://verify.digitalcampus.edu/cert/DC-2026-MS-5512",
      isAttested: true,
      attestedBy: "Examination Controller Office",
    ),
    const DigitalCertificate(
      id: "DC-2025-CS-1120",
      title: "AI & Deep Learning Skill Micro-Credential",
      type: "Course Completion",
      issueDate: "2025-12-10",
      issuedTo: "Rahul Sharma",
      rollNumber: "CS22B045",
      sha256Hash: "d1947bfa92305ca7b649d21e8e503b22cf9487192ca820ff569d82e11894b9aa",
      verificationUrl: "https://verify.digitalcampus.edu/cert/DC-2025-CS-1120",
      isAttested: true,
      attestedBy: "Center of Academic Excellence",
    ),
  ];

  // Fee Ledger
  static final List<FeeItem> fees = [
    const FeeItem(
      id: "FEE-SEM6-TUI",
      title: "Semester 6 Academic Tuition Fee",
      amount: 45000.0,
      dueDate: "2026-10-15",
      isPaid: false,
    ),
    const FeeItem(
      id: "FEE-EXAM-SEM6",
      title: "University Examination & Assessment Fee",
      amount: 2500.0,
      dueDate: "2026-10-30",
      isPaid: false,
    ),
    const FeeItem(
      id: "FEE-HOSTEL-S2",
      title: "Hostel & Mess Charges (Term 2)",
      amount: 32000.0,
      dueDate: "2026-08-10",
      isPaid: true,
      paidDate: "2026-08-05",
      transactionId: "TXN-UPI-98421092834",
      receiptNumber: "REC-2026-08-9412",
    ),
    const FeeItem(
      id: "FEE-BUS-ANNUAL",
      title: "Annual Campus Transit Pass (Route 4)",
      amount: 14000.0,
      dueDate: "2026-07-25",
      isPaid: true,
      paidDate: "2026-07-22",
      transactionId: "TXN-NET-77192340112",
      receiptNumber: "REC-2026-07-1049",
    ),
  ];

  // Hostel Information
  static const HostelDetails hostel = HostelDetails(
    blockName: "Ramanujan Bhawan (Block B)",
    roomNumber: "B-304 (AC Triple Sharing)",
    floor: 3,
    wardenName: "Prof. Arvind Sharma",
    wardenPhone: "+91 98930 44556",
    roommates: ["Aman Verma (CS)", "Rohan Joshi (IT)"],
  );

  // Digital E-Gate Passes
  static final List<GatePass> gatePasses = [
    const GatePass(
      id: "GP-2026-8841",
      reason: "Weekend Family Visit & Medical Checkup",
      destination: "Indore (Home)",
      outDateTime: "2026-09-26 05:00 PM",
      expectedInDateTime: "2026-09-28 08:00 AM",
      status: "Approved",
      approvedBy: "Warden Prof. Arvind Sharma",
      qrPayload: "DIGITAL_CAMPUS_GP_8841_STU_CS22B045_AUTHORIZED",
    ),
    const GatePass(
      id: "GP-2026-8712",
      reason: "Evening City Market & Hardware Purchase",
      destination: "New Market, Bhopal",
      outDateTime: "2026-09-20 04:30 PM",
      expectedInDateTime: "2026-09-20 08:30 PM",
      status: "Closed",
      approvedBy: "Security Desk Scan",
      qrPayload: "DIGITAL_CAMPUS_GP_8712_COMPLETED",
    ),
  ];

  // Transit Bus Route 4
  static const BusRoute busRoute = BusRoute(
    routeNumber: "Route 04",
    routeName: "MP Nagar ➔ Apex Digital Campus",
    busPlateNumber: "MP-04-HE-7821",
    driverName: "Dinesh Kumar",
    driverPhone: "+91 97550 33441",
    currentStop: "Board Office Square",
    nextStop: "Prabhat Petrol Pump",
    etaMinutes: 6,
    speedKmph: 34.5,
    stopList: [
      "MP Nagar Zone 1 (07:45 AM)",
      "Board Office Square (07:55 AM)",
      "Prabhat Petrol Pump (08:05 AM)",
      "Ashoka Garden (08:18 AM)",
      "Ayodhya Bypass (08:30 AM)",
      "Apex Digital Campus Gate 1 (08:45 AM)",
    ],
  );

  // Grievance Helpdesk
  static final List<GrievanceTicket> grievances = [
    const GrievanceTicket(
      id: "GRV-2026-0419",
      category: "Academic & Lab",
      subject: "PyTorch GPU drivers update request in Lab 3",
      description: "Machines in Row B need CUDA 12.4 update for Deep Learning practicals.",
      createdAt: "2026-09-22",
      status: "In Progress",
      priority: "Medium",
      remainingSlaHours: 18,
      assignedOfficer: "Mr. Rajesh Kumar (Lab Admin)",
    ),
    const GrievanceTicket(
      id: "GRV-2026-0390",
      category: "Hostel Facility",
      subject: "Wi-Fi access point bandwidth issue on 3rd floor Block B",
      description: "Signal drops frequently during 8 PM - 11 PM study hours.",
      createdAt: "2026-09-18",
      status: "Resolved",
      priority: "High",
      remainingSlaHours: 0,
      assignedOfficer: "Campus IT Network Cell",
    ),
    const GrievanceTicket(
      id: "GRV-STATUTORY-001",
      category: "Anti-Ragging Statutory Cell",
      subject: "Zero Tolerance Campus Safety Audit",
      description: "Mandatory bi-weekly safety patrol and helpline verification.",
      createdAt: "2026-09-01",
      status: "Resolved",
      priority: "Critical",
      remainingSlaHours: 0,
      assignedOfficer: "Dean of Student Welfare & AICTE Liaison",
    ),
  ];

  // Daily Mess Menu
  static const Map<String, String> messMenuToday = {
    "Breakfast (07:30 - 09:00 AM)": "Aloo Paratha, Curd, Poha, Boiled Eggs / Sprouts, Tea & Coffee",
    "Lunch (12:30 - 02:30 PM)": "Dal Tadka, Shahi Paneer, Jeera Rice, Phulke, Cucumber Salad, Gulab Jamun",
    "High Tea (05:00 - 06:00 PM)": "Veg Cutlets, Green Chutney, Masala Chai, Biscuits",
    "Dinner (08:00 - 09:45 PM)": "Mix Veg, Chana Dal, Steamed Rice, Butter Roti, Kheer",
  };

  // Personalized Adaptive Learning Recommendations
  static final List<LearningRecommendation> learningRecommendations = [
    const LearningRecommendation(
      id: "LR-CD-01",
      subject: "Compiler Design",
      topic: "Bottom-Up Parsing: Shift-Reduce & LR(1) Parsers",
      reason: "Diagnostic flagged error pattern in Mid-Term Question 3; high weightage in university exams.",
      resourceType: "Interactive Video Lecture",
      durationOrPages: "28 mins",
      difficulty: "Intermediate",
    ),
    const LearningRecommendation(
      id: "LR-ML-02",
      subject: "Machine Learning",
      topic: "Backpropagation & Gradient Descent Intuition",
      reason: "Advanced enrichment module to maintain Grade A+ standing in neural network practicals.",
      resourceType: "Visual Cheatsheet Handout",
      durationOrPages: "6 pages",
      difficulty: "Foundational",
    ),
    const LearningRecommendation(
      id: "LR-CN-03",
      subject: "Computer Networks",
      topic: "TCP Congestion Control (Slow Start, Tahoe, Reno)",
      reason: "Frequent campus placement interview topic for Tier-1 engineering roles.",
      resourceType: "Adaptive Practice Quiz",
      durationOrPages: "15 MCQs",
      difficulty: "Advanced",
    ),
  ];
}
