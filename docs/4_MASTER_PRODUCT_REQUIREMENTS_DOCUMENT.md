# 📖 IES E-CAMPUS: MASTER PRODUCT REQUIREMENT DOCUMENT (PRD)
## Unified System Architecture, Functional Specifications & Cross-Role Operational Workflows
> **Document Status:** Final Approved Baseline (Enterprise Academic Edition)  
> **Target Institution:** IES College of Technology / IES University, Bhopal (RGPV & AICTE Approved)  
> **Product Name:** IES E-Campus ERP Ecosystem  
> **Technology Foundation:** Flutter Multi-Platform (Android / iOS / Web) + Cloud Firestore (Zero Cloud Storage Cost Architecture)  
> **Version:** 2.4.0 (Production Release)  

---

## 📑 Master Document Table of Contents
1. [Executive Summary & Product Vision](#1-executive-summary--product-vision)
2. [Stakeholder Personas & Cross-Role Interaction Matrix](#2-stakeholder-personas--cross-role-interaction-matrix)
3. [Unified Information Architecture & Screen Navigation Hierarchy](#3-unified-information-architecture--screen-navigation-hierarchy)
4. [Deep Functional Specifications (12 Subsystems)](#4-deep-functional-specifications-12-subsystems)
   - 4.1. [Authentication & Two-Tier Security Gate](#41-authentication--two-tier-security-gate)
   - 4.2. [Hanging Lanyard PVC Identity Card Engine](#42-hanging-lanyard-pvc-identity-card-engine)
   - 4.3. [Official Semester Registration & Course Enrollment System](#43-official-semester-registration--course-enrollment-system)
   - 4.4. [Digital Bonafide Certificate Generator & Attestation Desk](#44-digital-bonafide-certificate-generator--attestation-desk)
   - 4.5. [Classroom Attendance Engine & 75% RGPV Criteria Radar](#45-classroom-attendance-engine--75-rgpv-criteria-radar)
   - 4.6. [Master Timetable Architecture (Weekly Default vs Today's Substitute)](#46-master-timetable-architecture-weekly-default-vs-todays-substitute)
   - 4.7. [Live Interactive Classroom Studio (PhysicsWallah / Unacademy Style)](#47-live-interactive-classroom-studio-physicswallah--unacademy-style)
   - 4.8. [Digital Library & Academic Handouts Repository](#48-digital-library--academic-handouts-repository)
   - 4.9. [Timed Online Quiz & Automated Examination Engine](#49-timed-online-quiz--automated-examination-engine)
   - 4.10. [Assignment Publishing & 6-Month Review Archive Desk](#410-assignment-publishing--6-month-review-archive-desk)
   - 4.11. [Anti-Tamper Class Discussion Groups & Batch Mentorship](#411-anti-tamper-class-discussion-groups--batch-mentorship)
   - 4.12. [Statutory Grievance Redressal & Anti-Ragging Cell](#412-statutory-grievance-redressal--anti-ragging-cell)
5. [UI/UX Design System, Color Tokens & Typography](#5-uiux-design-system-color-tokens--typography)
6. [Institutional Document Verification & Security Standards](#6-institutional-document-verification--security-standards)
7. [Non-Functional Requirements, Cloud Economics & Security](#7-non-functional-requirements-cloud-economics--security)
8. [Master End-to-End User Scenarios & Cross-Role Flows](#8-master-end-to-end-user-scenarios--cross-role-flows)
9. [Executive Presentation Guide for Evaluators & Management](#9-executive-presentation-guide-for-evaluators--management)

---

## 1. Executive Summary & Product Vision

### 1.1 The Core Problem
Most technical universities and engineering institutions across India still rely on fragmented, paper-based administrative workflows:
- **Attendance**: Physical paper register books waste 15 minutes of every lecture; students shout proxies; manual calculation of monthly percentages leads to errors.
- **Certificates**: Bonafide certificates and semester registration forms take 3 to 7 days of routing across clerk, HOD, and principal offices.
- **Identity Cards**: Simple horizontal paper/plastic cards without security stamps or lanyards fail basic campus gate verification.
- **Class Schedules**: Stagnant notice board paper printouts fail to inform students when a professor is on leave or an extra lab is scheduled.
- **Academics**: Study notes are shared haphazardly on WhatsApp groups where messages get deleted, personal phone numbers are exposed, and files are lost.

### 1.2 The IES E-Campus Solution
**IES E-Campus** is a unified, paperless Enterprise Campus Operating System designed ground-up for Indian engineering institutions (specifically aligned with **IES College of Technology, Bhopal**, affiliated with **RGPV** and governed by **AICTE** norms).

```
┌────────────────────────────────────────────────────────────────────────┐
│                     IES E-CAMPUS ECOSYSTEM ARCHITECTURE                │
├────────────────────────────────────────────────────────────────────────┤
│                           CENTRALIZED DATA LAYER                       │
│    (Cloud Firestore • Realtime Streams • Local Memory Caching)         │
├───────────────────────┬────────────────────────┬───────────────────────┤
│    STUDENT PORTAL     │     FACULTY PORTAL     │   ADMIN REGISTRAR     │
│ • Attendance Meter    │ • 1-Tap Attendance     │ • Student Approvals   │
│ • Lanyard PVC ID Card │ • Timetable Manager    │ • Detention Audits    │
│ • Sem Registration    │ • Sem Reg Approval     │ • Circular Broadcast  │
│ • Instant Bonafide    │ • Live Class Broadcast │ • Grievance Tribunal  │
│ • Batch Doubts Forum  │ • Notes & Quiz Engine  │ • Role Administration │
└───────────────────────┴────────────────────────┴───────────────────────┘
```

---

## 2. Stakeholder Personas & Cross-Role Interaction Matrix

### 2.1 Persona 1: The Student (Candidate Rahul Sharma)
- **Role**: 3rd Year (5th Semester) B.Tech in Computer Science & Engineering, Section A.
- **Goals**: Stay above the 75% attendance threshold, download study materials without cost, obtain instant bonafide certificates for state scholarships (MPTAAS), and stay updated on daily timetable changes.
- **Pain Points**: Long administrative queues, unexpected detention lists, losing track of assignment deadlines.

### 2.2 Persona 2: The Faculty Member (Prof. Mohit Donawat)
- **Role**: Head of Department (H.O.D.) / Associate Professor, Computer Science.
- **Goals**: Conduct lectures without wasting time on paper roll calls, schedule substitute teachers when on leave, review semester registration applications in 1 tap, and moderate class doubts safely.
- **Pain Points**: Paper registers, manual attendance percentage calculations, students submitting incomplete registration forms.

### 2.3 Persona 3: The Administrator / Registrar (Dr. R.K. Saxena)
- **Role**: College Registrar & Chief Examination Officer.
- **Goals**: Ensure institutional compliance with RGPV/AICTE guidelines, audit detention lists before issuing university exam admit cards, monitor campus grievances, and prevent identity fraud.
- **Pain Points**: Forged physical bonafides, lack of real-time attendance transparency, chaotic grievance records during AICTE inspections.

### 2.4 Cross-Role Cascading Interaction Matrix

| Initiating Action | Triggered By | Immediate Impact on Student | Immediate Impact on Faculty | Immediate Impact on Admin |
| :--- | :--- | :--- | :--- | :--- |
| **Mark Class Attendance** | Faculty Member | Student's attendance % updates in <1 sec; status badge changes to Green/Amber/Red. | Lecture record stored in faculty history; statistics update. | College-wide daily attendance KPI updates on Master Dashboard. |
| **Update Daily Timetable** | Faculty Member | Student daily routine highlights substitute period with teacher name and room. | Schedule conflicts prevented; substitutes clearly noted. | Real-time classroom utilization visible to management. |
| **Submit Sem Registration** | Student | Receives auto-populated PDF with unique ref number; waits for HOD sign-off. | HOD receives applicant card in review queue; inspects SGPA/backlogs. | Registration counter increments towards 100% target; fee status tracked. |
| **Attest Bonafide Certificate** | Faculty / HOD | Student mobile app receives instant download link for sealed PDF with QR code. | Application marked resolved; audit trail recorded. | Validated bonafide logged with unique reference number for scholarship verification. |
| **Broadcast Urgent Notice** | Administrator | High-priority banner and push alert display on student devices instantly. | Faculty notified of institutional decisions (e.g. holiday, exams). | Complete audit trail of message dispatch timestamp. |

---

## 3. Unified Information Architecture & Screen Navigation Hierarchy

```
┌────────────────────────────────────────────────────────────────────────┐
│                     APPLICATION TAXONOMY & ROUTING                     │
├────────────────────────────────────────────────────────────────────────┤
│ ├── / (Splash & Root Gateway)                                          │
│ ├── /auth/role_select (Role Selection: Student / Teacher / Admin)      │
│ ├── /auth/login (Unified Login Gateway)                                │
│ ├── /auth/signup/student (Student Registration Form)                   │
│ ├── /auth/signup/teacher (Faculty Registration Form)                   │
│ ├── /auth/pending (Pending Account Verification Gate)                  │
│ │                                                                      │
│ ├── /student/dashboard (Student Operating System)                      │
│ │   ├── /student/id_card (Hanging Lanyard ID Card View & PVC Print)   │
│ │   ├── /student/registration (Semester Enrollment Form & PDF)        │
│ │   ├── /student/bonafide (Official Bonafide Generator & QR)           │
│ │   ├── /student/attendance (Subject-wise Attendance & 75% Calc)       │
│ │   ├── /student/timetable (Daily Class Routine & Notice Photo)        │
│ │   ├── /student/live_classes (PhysicsWallah Style Video Room)         │
│ │   ├── /student/library (Course Handouts & PYQ Downloads)             │
│ │   ├── /student/quiz (Timed Online Tests & Result Cards)              │
│ │   ├── /student/assignments (Assignment Upload & 6-Month Review)      │
│ │   ├── /chat/groups (Class Discussion Hub & Doubt Channels)           │
│ │   ├── /student/grievance (UGC Grievance Redressal Portal)            │
│ │   └── /announcements (Institutional Circulars & Hall of Fame)        │
│ │                                                                      │
│ ├── /teacher/dashboard (Faculty Operating System)                      │
│ │   ├── /teacher/attendance/mark (1-Tap Lecture Attendance Roll)       │
│ │   ├── /teacher/attendance/lookup (Student Attendance Search)         │
│ │   ├── /teacher/timetable/send (Timetable Manager & Slot Editor)      │
│ │   ├── /teacher/registration/approvals (Sem Reg HOD Attestation)      │
│ │   ├── /teacher/bonafide/approvals (Bonafide Verification Desk)       │
│ │   ├── /teacher/live/broadcast (Live Classroom Broadcasting Studio)   │
│ │   ├── /teacher/library/upload (Notes & Material Publisher)           │
│ │   ├── /teacher/quiz/create (Quiz Builder & Automated Evaluator)      │
│ │   ├── /teacher/assignments/grade (Assignment Review Desk)            │
│ │   ├── /chat/groups/create (Batch Discussion Group Formulation)       │
│ │   └── /announcements/post (Circular Broadcaster)                     │
│ │                                                                      │
│ └── /admin/dashboard (College Command Center)                          │
│     ├── /admin/users/approval (User Verification & Role Roster)        │
│     ├── /admin/attendance/report (Campus-Wide Attendance Audit)        │
│     └── /admin/grievance/oversight (Grievance Tribunal Desk)           │
└────────────────────────────────────────────────────────┘
```

---

## 4. Deep Functional Specifications (12 Subsystems)

### 4.1. Authentication & Two-Tier Security Gate
- **Input Data**: Full Name, University Roll Number, RGPV Enrollment Number, Department, Year, Semester, Section, Email, Password, Profile Photo.
- **Processing**:
  - Writes new document to `users` collection with `isApproved = false`.
  - Student app locks on `PendingApprovalScreen`.
  - Dispatches alert notification to faculty dashboard.
  - Faculty inspects roll number and taps **Approve**.
  - Database updates `isApproved = true`, unlocking student app automatically in real time.
- **Output**: Authenticated session with role-based routing.

### 4.2. Hanging Lanyard PVC Identity Card Engine
- **Visual Design**: Vertical ID card with a top metallic lanyard punch hole band, institution crest, golden session ribbon, passport photo with holographic security border, credentials table, crimson circular seal, registrar signature, and barcode.
- **Back Side**: Emergency contacts, blood group, guardian details, return campus address, and 5-point institutional discipline rules.
- **Export Formats**:
  1. **Gallery PNG**: Flutter `RepaintBoundary` rasterizes pixels at **300+ DPI** directly to device gallery.
  2. **Print-Ready A4 PVC PDF**: Renders Front and Back side-by-side with alignment crop markers for PVC printing machines.

### 4.3. Official Semester Registration & Course Enrollment System
- **Real-College Mandate**: Matches standard Indian university semester promotion forms (Part A to Part E).
- **Required Inputs**:
  - Auto-populated: Student Name, Enrollment, Roll No, Branch, Year, Father's Name, Phone, Email.
  - Student Enters: Target Semester, Academic Session, Previous Semester SGPA, Cumulative CGPA, Backlog/ATKT flag (with subject codes), Co-curricular Achievements, Elective Course Choices, Fee Receipt Ref Number.
  - Legal Undertaking: Mandatory agreement to maintain 75% attendance and adhere to anti-ragging policies.
- **Approval Workflow**:
  - Form appears in HOD's review desk.
  - HOD inspects credentials and taps **"Approve & Sign"**.
  - Digital HOD signature and crimson red college seal are applied.
- **Output**: Official print-ready A4 PDF document (`IES/REG/[YEAR]/[ENROLL]`).

### 4.4. Digital Bonafide Certificate Generator & Attestation Desk
- **Purpose Selection**: Templates for NSP/MPTAAS Scholarships, Bank Education Loans, Passport/Visa, Bus/Train Pass, and Custom Purposes.
- **Attestation Elements**:
  - Phrasing: *"This is to certify that [Name], Son of [Father's Name]..."*
  - Attested student passport photograph.
  - Crimson red double-ring college seal stamp with 12 stars.
  - Vector Registrar / Principal signature block.
  - Dynamic verification QR code encoding candidate UID, enrollment number, and timestamp.
  - Authoritative guarantee banner confirming validity for all government and banking submissions.
- **Output**: Instantly downloadable and shareable A4 PDF.

### 4.5. Classroom Attendance Engine & 75% RGPV Criteria Radar
- **Teacher Workflow**:
  - Select Branch, Semester, Section, Subject, and Period.
  - Tap **"Mark All Present"** (turns 60 students green in 1 second).
  - Tap absent students to turn them red.
  - Tap **"Submit Attendance"** (takes less than 20 seconds total).
- **Mathematical Formulas**:
  - **Live Attendance Percentage**:
    $$\text{Percentage} = \left( \frac{\text{Total Attended}}{\text{Total Held}} \right) \times 100$$
  - **Smart Prediction Formula (When Below 75%)**:
    $$\text{Classes Needed} = \left\lceil \frac{0.75 \times \text{Total Held} - \text{Total Attended}}{0.25} \right\rceil$$
- **Admin Audit**:
  - Cross-department detention radar.
  - 1-click export of defaulter lists for RGPV examination admit card withholding.

### 4.6. Master Timetable Architecture (Weekly Default vs Today's Substitute)
- **Class Filtering**: Specific timetable for every Branch, Year, Semester, and Section.
- **Dual Mode**:
  1. **Weekly Master Schedule (Daily Default)**: Permanent Monday-to-Saturday routine.
  2. **Today's Reschedule / Substitute**: Day-specific modifications (e.g. substitute professor, rescheduled timing, or extra lab).
- **Auto-Fill AICTE/RGPV Curriculum**: 1-click button populates core semester subjects automatically (OS, DBMS, CN, SE, Labs), saving hours of manual data entry.
- **Period Cards**: Displays Period Number (1 to 8), Time range, Subject name, Room/Lab, and Faculty in-charge with Edit/Delete buttons.
- **Notice Board Photo**: Optional camera upload of physical department notice board.

### 4.7. Live Interactive Classroom Studio (PhysicsWallah / Unacademy Style)
- **Broadcasting Engine**: Embedded HD video streaming player supporting live lectures and recorded archives.
- **Live Doubts Chat**: Real-time Q&A feed between students and faculty during the lecture.
- **Role Badges**: Faculty responses stand out in golden cards with verified professor tags.
- **Lecture Handouts**: Attached slide presentations (PPT/PDF) available for download below the video player.

### 4.8. Digital Library & Academic Handouts Repository
- **Categorization**: Filtered by Department, Year, and Subject.
- **Document Types**: Lecture Notes, Syllabus Copy, Lab Manuals, Previous Year Question Papers (PYQs with solutions).
- **In-App Viewer & Offline Download**: Students can read documents inside the app or download them for offline study.

### 4.9. Timed Online Quiz & Automated Examination Engine
- **Faculty Builder**: Create multiple-choice questions with 4 options, correct answer key, and countdown timer.
- **Student Testing**: Clean test-taking interface with timer, answer tracking, and review status.
- **Instant Auto-Grading**: Grades are calculated immediately upon submission, with scorecards and batch leaderboard rankings.

### 4.10. Assignment Publishing & 6-Month Review Archive Desk
- **Faculty Desk**: Post assignment problems with deadlines and reference sheets; monitor real-time submission counter (`X / Y Students Submitted`).
- **Student Portal**: Upload handwritten scans or typed PDF reports with automatic timestamp verification.
- **6-Month Archive**: Retains graded submissions, scores, and faculty remarks for half a year for academic audit compliance.

### 4.11. Anti-Tamper Class Discussion Groups & Batch Mentorship
- **Targeted Batch Groups**: Automatically channels students into groups matching their Branch, Year, Semester, and Section.
- **Canonical Matching**: Intelligently matches abbreviations (`CSE` $\leftrightarrow$ `Computer Science & Engineering`, `3rd Year` $\leftrightarrow$ `3`, `5th Sem` $\leftrightarrow$ `5`).
- **Anti-Tamper Protocol**:
  - **No Deletion**: Messages cannot be deleted once posted, maintaining academic decorum.
  - **60-Second Edit Window**: Typos can only be corrected within 1 minute, displaying an `[edited]` tag.
- **Instant Messaging**: Optimistic local rendering delivers messages in <1 ms.

### 4.12. Statutory Grievance Redressal & Anti-Ragging Cell
- **Compliance**: Adheres to mandatory UGC (Grievance Redressal) Regulations and AICTE Anti-Ragging Directives.
- **Confidential Submission**: Option to file anonymously or with verified identity.
- **Lifecycle Tracking**: `SUBMITTED` ➔ `ASSIGNED` ➔ `INVESTIGATION` ➔ `ACTION TAKEN REPORT (ATR)` ➔ `RESOLVED`.

---

## 5. UI/UX Design System, Color Tokens & Typography

### 5.1 Color Tokens
- **Background**: `#0F0C20` (Deep Space Midnight)
- **Surface**: `#1A1635` (Sleek Dark Glassmorphism)
- **Surface Variant**: `#252048` (Elevated Container)
- **Primary Brand**: `#1E1B4B` (Royal Academic Navy)
- **Secondary Accent**: `#F59E0B` (Academic Gold / Amber)
- **Success / Safe Zone**: `#10B981` (Emerald Green)
- **Warning / Condonation Zone**: `#F59E0B` (Amber Orange)
- **Error / Detention Zone**: `#EF4444` (Crimson Red)
- **Info / Engineering Blue**: `#38BDF8` (Sky Cyan)
- **Card Gradients**: Linear gradient from `#1E1B4B` to `#2E1065`.

### 5.2 Typography Standards
- **Display Headings**: Bold sans-serif with slight letter spacing (`letterSpacing: 0.8`).
- **Body Text**: High-legibility sans-serif with calibrated line height (`height: 1.4`).
- **Status Chips**: 9px to 11px uppercase bold badges (`fontWeight: FontWeight.w800`).

---

## 6. Institutional Document Verification & Security Standards

### 6.1 Authentic Crimson Red College Seal Stamp
- Double-ring concentric circle design in deep maroon ink (`#8B0000` / `#991B1B`).
- Outer perimeter: 12 decorative stars.
- Arching text: `"★ IES UNIVERSITY ★"` (top) and `"BHOPAL (M.P.)"` (bottom).
- Inner ribbon: `"OFFICIAL SEAL • GOVT APPROVED"`.

### 6.2 Registrar Signature Block
- Stylized vector cursive signature of the authorized institutional signatory.
- Designation pill: `"REGISTRAR / PRINCIPAL AUTHORIZED SIGNATORY"`.

### 6.3 Security Verification QR Code Schema
Every generated certificate carries a structured JSON payload:
```json
{
  "ref": "IES/BONA/2024/7819",
  "enroll": "0103CS221045",
  "name": "Rahul Sharma",
  "branch": "CSE",
  "sem": "5th Sem",
  "inst": "IES College of Technology, Bhopal",
  "issued": "2024-09-08T10:30:00Z"
}
```

---

## 7. Non-Functional Requirements, Cloud Economics & Security

### 7.1 Free-Tier Architecture (Zero Cloud Storage Bucket Costs)
- Large external cloud storage buckets often incur monthly bandwidth fees and CORS configuration issues.
- **IES E-Campus Innovation**: Document scans and photo attachments are compressed and encoded as **Base64 Data URIs** stored directly in Cloud Firestore.
- **Zero-Index Query Model**: Data queries use in-memory stream filtering, eliminating the need for composite indexes that can fail in unindexed Firestore databases.

### 7.2 Anti-Tamper Protocol
- Discussion group messages cannot be deleted.
- Edits are limited to 60 seconds with an audit tag.
- Attendance records can only be submitted by verified faculty accounts.

---

## 8. Master End-to-End User Scenarios & Cross-Role Flows

### Scenario: Monday Morning Lecture & Timetable Reschedule
1. **08:15 AM (Faculty Reschedule)**: Prof. Mohit Donawat has a department meeting at 10:00 AM. He opens `SendTimetableScreen`, selects *Today's Substitute*, and assigns Prof. Sharma to cover Period 2 in Computer Lab 2.
2. **08:16 AM (Student Notification)**: Rahul Sharma opens his student dashboard. Period 2 displays a yellow `[⚡ SUBSTITUTE]` badge indicating Prof. Sharma in Lab 2.
3. **10:05 AM (Lecture Attendance)**: Prof. Sharma takes the class, opens `MarkAttendanceScreen`, taps `Mark All Present`, unchecks 2 absentees, and submits in 14 seconds.
4. **10:06 AM (Real-Time Recalculation)**: Rahul's attendance meter updates to 82.4% (Green zone). The 2 absentees receive attendance warning notifications.
5. **10:45 AM (Doubt Clearing)**: In `GroupChatRoomScreen`, student Priya asks a question using the quick chip *"❓ Ask Question"*. Prof. Sharma replies with an authoritative golden `👨‍🏫 FACULTY` badge.
6. **11:00 AM (Admin Oversight)**: The Registrar opens the admin dashboard and sees today's CSE 3rd Year attendance logged at 96.7%, with zero paper registers required.

---

## 9. Executive Presentation Guide for Evaluators & Management

When presenting this system to college authorities, evaluators, or investors, use this structured narrative:

1. **The Hook**: *"Every semester, over 2,000 students wait in queues for Bonafide certificates, semester registration, and attendance verification. Professors waste 15 minutes of every lecture taking roll calls on paper."*
2. **The Demonstration**:
   - **Show Student Portal**: The live circular attendance meter, instant Bonafide generator with QR code, and vertical hanging lanyard ID card.
   - **Show Faculty Portal**: The 20-second "Mark All Present" attendance roll call and the master timetable substitute manager.
   - **Show Admin Portal**: Campus-wide 75% detention radar and 1-tap parent calling/emailing.
3. **The Technical Innovation**: *"We built this entire system with zero cloud storage costs by leveraging direct Base64 Firestore persistence, eliminating recurring cloud hosting bills for the institution."*
4. **The Regulatory Compliance**: *"Every document complies with RGPV Ordinance 12, AICTE norms, and UGC anti-ragging mandates, complete with authenticated crimson seals and QR verification."*

---
*End of Master Product Requirements Document • IES E-Campus Enterprise Edition*
