# 🏛️ Digital Campus — Unified Higher Education Operating System
### Enterprise Campus ERP 4.0, Digital Governance & Sovereign Applied AI Platform

[![Platform](https://img.shields.io/badge/Platform-Flutter%203.x%20%7C%20Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-02569B?logo=flutter)](https://flutter.dev)
[![Architect](https://img.shields.io/badge/Architect-Mr.%20Mohit%20Donawat-orange?logo=github)](https://github.com/mohitdonawat)
[![Architecture](https://img.shields.io/badge/Architecture-Decoupled%20Modular%20ERP-4CAF50)](#-system-architecture)
[![AI Engine](https://img.shields.io/badge/AI%20Engine-Sovereign%20Campus%20NLU%20(Zero%20API%20Cost)-7C3AED)](#-sovereign-applied-ai-subsystems)
[![Compliance](https://img.shields.io/badge/Compliance-AICTE%20%7C%20UGC%2048h%20SLA%20%7C%20NEP%202020-blue)](#-statutory-compliance--governance)
[![Security](https://img.shields.io/badge/Security-SHA--256%20Cryptographic%20Verification-critical)](#-cryptographic-credentials--digital-governance)

---

## 📌 Executive Overview & Scope

**Digital Campus** is a comprehensive, production-grade **Higher Education Operating System (OS)** engineered to unify the fragmented digital landscape of modern universities, autonomous technical institutes, and polytechnics. 

Traditional campus management suffers from departmental data silos: attendance, semester examination registration, fee processing, hostel allocations, transit telemetry, and grievance redressal operate on disconnected, legacy software. **Digital Campus** unifies these critical institutional services into a cohesive, high-performance ecosystem powered by an **in-house, sovereign Applied AI engine** that operates with sub-millisecond response latency and zero third-party token billing.

### 🌐 Key Scope & Capabilities:
- **Unified Academic Administration:** Real-time tracking of student academic journey from Day-1 KYC admission to degree conferral.
- **Statutory Regulatory Automation:** Enforces AICTE 75% attendance limits, UGC 48-Hour grievance resolution SLAs, and NEP 2020 mother-tongue learning assistance.
- **Sovereign, Edge-First AI:** Built-in Natural Language Understanding (NLU) and predictive statistical regression engines that run deterministically without external cloud API dependencies.
- **Multi-Tenant SaaS Readiness:** Capable of provisioning autonomous colleges and university departments with isolated state and administrative controls.
- **Role-Based Experience:** Native experiences tailored for four key personas: **Students**, **Faculty/Mentors**, **Institutional Administrators**, and **Parents/Guardians**.

---

## 🏛️ System Architecture

Digital Campus follows an **Offline-First, Decoupled Modular Architecture** designed for high concurrency, zero data loss, and uninterrupted operation in bandwidth-constrained environments:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        MULTI-ROLE CLIENT INTERFACES (FLUTTER 3.x)                      │
│      Student Portal   │   Faculty Cockpit   │   Admin ERP   │   Parent Guardian App    │
└──────────────────────────────────────────┬─────────────────────────────────────────────┘
                                           │
                    ┌──────────────────────┴──────────────────────┐
                    │                                             │
                    ▼                                             ▼
   ┌────────────────────────────────┐            ┌────────────────────────────────┐
   │    SOVEREIGN CLIENT ENGINE     │            │    HIGH-PERFORMANCE BACKEND    │
   │  • VoiceNlpEngine (Campus NLU) │            │  • Go Concurrency Core (:8080) │
   │  • Dynamic Math & Bunk Solver  │            │  • FastAPI ML Engine (:8000)   │
   │  • Provider State Management   │            │  • SQLite Sovereign Data Vault │
   │  • Offline-First Fallback Bus  │            │  • Redis Real-Time Channel Hub │
   └────────────────────────────────┘            └────────────────────────────────┘
```

### Architectural Highlights:
1. **Frontend Layer (Flutter 3.x & Dart 3.5+):** Multiplatform reactive client rendering at 60–120 FPS across Android, iOS, Web, Windows, and macOS.
2. **State & Cache Management:** Centralized `CampusProvider` utilizing reactive state notification with instant optimistic UI updates and resilient fallback adapters.
3. **Go Concurrency Engine:** Microservice written in Go supporting 100,000+ simultaneous connections with less than 25MB baseline memory footprint for peak registration traffic.
4. **Python Applied ML Pipeline:** Scikit-Learn based multi-variate regression models and inverted-index textbook RAG search over local SQLite storage.

---

## 🧠 Sovereign Applied AI Subsystems

Digital Campus features a suite of applied machine learning and natural language processing engines designed specifically for the higher education domain:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                               SOVEREIGN CAMPUS AI SUITE                                │
├──────────────────────┬──────────────────────┬───────────────────┬──────────────────────┤
│  01. Voice Assistant │ 02. Performance ML   │ 03. Early Warning │ 04. Adaptive Learning│
│  Bilingual NLU Model │ Multivariate SGPA    │ 4-Pillar Dropout  │ Skill-Gap Diagnostic │
│  20+ Domain Intents  │ Regression (R²=0.91) │ Risk Prevention   │ 14-Day Exam Roadmap  │
└──────────────────────┴──────────────────────┴───────────────────┴──────────────────────┘
```

### 1. Bilingual Campus NLU Voice & Text Copilot
- **Zero-Cloud Dependency:** Complete natural language understanding operating directly within the application runtime.
- **Deep Language Flexibility:** Native handling of natural English, Hindi, and colloquial Hinglish phrasings.
- **Live State Reasoning:** Rather than returning generic static canned responses, queries dynamically evaluate live student records:
  - *Subject-Specific Math:* Computes exact attendance percentages, classes held, and required consecutive attendances to attain 75% compliance.
  - *Dynamic Safe Bunks:* Evaluates margin across each individual course to calculate exact permissible leaves without triggering detention.
  - *Timetable & Substitution Awareness:* Alerts students to faculty medical leaves and assigned substitute professors in real-time.
  - *Accounts & Transit Integration:* Delivers pending fee balances, receipt confirmations, and real-time GPS telemetry for campus transit.

### 2. Predictive Academic Performance Engine
- **Statistical Model:** Multi-variate gradient-boosted linear regression ($R^2 = 0.91$) modeling historical cohort outcomes against ongoing internal assessments and attendance velocity.
- **Confidence Modeling:** Generates projected Semester SGPA with bounded 95% confidence intervals ($[SGPA_{lower}, SGPA_{upper}]$).
- **Interactive "What-If" Sandbox:** Allows students to simulate grade scenarios by interactively adjusting daily study hours and targeted class attendance.

### 3. Early Warning Dropout & Detention System (EWS)
- **4-Pillar Risk Matrix:** Proactively evaluates student vulnerability before end-semester exam disqualification:
  1. *Attendance Velocity:* 30-day attendance decay slope.
  2. *Academic Backlog Arrears:* Historical and active course arrears.
  3. *Financial Stress Index:* Delinquent institutional fees and installment default duration.
  4. *LMS Engagement Metrics:* Participation in online discussion boards and practical lab doubt portals.
- **Automated Interventions:** 1-click administrative workflows to trigger counselor appointments, parent alerts, or peer mentoring.

### 4. Adaptive Learning & Diagnostic Remediation
- Diagnostic analysis of test errors and concept gaps.
- Generates individualized 14-day exam preparation roadmaps with milestone checkboxes.
- Curated technical concept summaries and topic-specific practice quizzes.

---

## 📦 Core Campus Subsystems & ERP Modules

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                   CAMPUS ERP MODULES                                   │
├────────────────────┬─────────────────────┬────────────────────┬────────────────────────┤
│ 📋 Lifecycle & PVC │ 📊 Attendance Radar │ 🕒 Dynamic Roster  │ 📜 Cryptographic Certs │
├────────────────────┼─────────────────────┼────────────────────┼────────────────────────┤
│ 💳 Fee Management  │ 🏠 Hostel & Mess    │ 🚌 Transit Fleet   │ 🛡️ Statutory Helpdesk  │
└────────────────────┴─────────────────────┴────────────────────┴────────────────────────┘
```

### 1. Student Lifecycle Management & 3D Smart PVC ID Card
- Comprehensive record management covering Academic Stage, Branch, Semester, Roll Number, Enrollment UID, and APAAR IDs.
- **3D Smart PVC ID Card:** Verifiable digital identity card with double-sided flip animation, integrated RFID badge simulation, barcode scanner UID, and Registrar digital seal.

### 2. Smart Biometric Attendance & Anti-Proxy Engine
- Automated compliance tracking against the statutory 75% AICTE threshold.
- Subject-by-subject radar analytics highlighting safe and danger zones.
- Geofenced biometric check-in integration to eliminate proxy punching.

### 3. Master Dynamic Timetable & Faculty Substitution Engine
- Weekly lecture schedule with classroom allocations (e.g., LH-302, Advanced Computing Lab 3).
- Real-time administrative broadcast for faculty leaves and verified proxy substitutions.
- Integrated digital lecture notes and syllabus outlines.

### 4. Cryptographic Digital Credentials (SHA-256)
- On-demand generation of official Bonafide, NOC, Character, and Transcript Certificates.
- Sealed with cryptographic SHA-256 digital hashes and scannable QR verification proofs for tamper-evident validation by scholarship authorities and passport offices.

### 5. Institutional Fee Ledger & Payment System
- Transparent accounting ledger tracking semester tuition, examination assessments, hostel fees, and transit passes.
- Simulated instant payment gateway (UPI, NetBanking, Cards) with automated GST tax invoice receipt generation.

### 6. Hostel Residence & Nutrition Mess Management
- Room allotment telemetry (Block, Floor, Sharing configuration, Roommates, Warden directory).
- 4-Meal Daily Mess Nutrition Schedule (Breakfast, Lunch, High Tea, Dinner).
- **Automated E-Gate Pass System:** Warden approval workflow with timed security gate QR validation for campus entry/exit.

### 7. Campus Transit & Fleet Telemetry System
- Multi-route bus scheduling with active stop sequences and route maps.
- Live GPS simulation featuring real-time vehicle speed telemetry, countdown ETA, and direct driver contact hotlines.

### 8. Statutory Helpdesk & UGC Grievance Redressal
- Enforces statutory 48-Hour SLA resolution deadlines for student concerns.
- Specialized Anti-Ragging Statutory Cell and 24x7 Women's Campus Safety escalation hotline.
- Transparent grievance ticket audit logs from submission to resolution.

---

## 👥 Multi-Role Persona Portals

Digital Campus provides distinct operational views tailored for every campus stakeholder:

| Persona | Primary Focus & Capabilities |
| :--- | :--- |
| **Student** | Personal academic radar, safe bunks calculator, lecture schedules, digital PVC card, fee payments, gate pass generation, and AI Copilot interaction. |
| **Faculty & Mentors** | Class attendance marking, student risk telemetry, substitute lecture acceptances, syllabus notes publishing, and mentorship counseling logs. |
| **Administrator / Registrar** | Institutional enrollment KPIs, multi-tenant college onboarding, fee collection audits, fee ledger verification, and statutory grievance SLA monitoring. |
| **Parent & Guardian** | Real-time monitoring of ward's biometric punch times, semester examination scorecards, pending fee dues, and direct mentor calling access. |

---

## 📜 Statutory Compliance & Governance

Digital Campus is engineered to align strictly with the regulatory framework governing Indian higher education:

- **AICTE Norms:** Automated early warnings prior to semester exam detention for attendance falling below 75%.
- **UGC Grievance Redressal Regulations (2023):** Built-in 48-hour SLA deadline tracking with automated escalation matrices.
- **NAAC A++ Criteria Alignment:** Direct digital documentation supporting Criteria 2 (Teaching-Learning & Evaluation) and Criteria 5 (Student Support & Progression).
- **NEP 2020 Guidelines:** Vernacular multilingual study support and mother-tongue conversational AI capabilities.

---

## 💻 Technology Stack Specifications

| Layer | Technologies |
| :--- | :--- |
| **Client Framework** | Flutter 3.x (SDK ^3.5.0) |
| **Programming Languages** | Dart 3.5+, Go (Golang 1.22+), Python 3.11+ |
| **State Management** | Provider 6.1.2 (Decoupled Reactive Pattern) |
| **UI & Visual Design** | Google Fonts (Inter/Outfit), FL Chart 0.68, Lottie, Shimmer, Percent Indicator |
| **Document Processing** | PDF 3.11, Printing 5.13, Path Provider, Open File |
| **Cryptographic Security** | Crypto (SHA-256 verification), Local Geofencing, Role-Based Access Control |
| **Backend & Microservices** | Go Concurrent HTTP Engine, FastAPI Python ML, SQLite, Redis |
| **Code Push & Updates** | Shorebird Over-The-Air (OTA) Bytecode CodePush |

---

## 📂 Repository Directory Layout

```text
digital_campus/
├── assets/                    # Static brand emblems, vector icons, and animations
│   ├── images/                # Clean institutional branding & UI artwork
│   ├── icons/                 # System glyphs & navigation icons
│   └── logo.webp              # Digital Campus official vector brand emblem
├── backend/                   # Microservices & Sovereign ML pipelines
│   ├── main.go                # Go high-concurrency micro-engine (:8080)
│   ├── server.py              # FastAPI Python analytics & RAG service (:8000)
│   ├── ml_engine.py           # Scikit-Learn regression & dropout classifiers
│   └── database.py            # SQLite schema initialization & database adapters
├── lib/                       # Core Flutter Client Application
│   ├── core/                  # Shared architecture & utilities
│   │   ├── ai/                # Sovereign VoiceNlpEngine & ML inference modules
│   │   ├── constants/         # Institutional constants & tenant configuration
│   │   ├── services/          # API, GoBackend, and Document PDF services
│   │   ├── theme/             # Material 3 Design System & Theme tokens
│   │   └── widgets/           # BrandLogo, StatCards, RoleSwitchBar, CustomChips
│   ├── data/                  # Live Campus Database registry & mock schemas
│   ├── features/              # Feature modules (Clean Architecture)
│   │   ├── ai_analytics/      # Predictive Performance & Early Dropout screens
│   │   ├── ai_assistant/      # Voice & Chat Assistant with soundwave visualizer
│   │   ├── attendance/        # Attendance Radar & Biometric Check-in
│   │   ├── certificates/      # Cryptographic Certificate generator & QR validator
│   │   ├── dashboard/         # Role-specific views (Student, Faculty, Admin, Parent)
│   │   ├── fees/              # Fee Ledger, UPI Payment & GST Receipts
│   │   ├── helpdesk/          # UGC 48-Hour SLA Grievance & Anti-Ragging Cell
│   │   ├── hostel/            # Room allotment, Nutrition Mess & E-Gate Passes
│   │   ├── lifecycle/         # Student Lifecycle & 3D Smart PVC ID Card
│   │   ├── shell/             # Main application shell & AI Studio hub
│   │   ├── timetable/         # Dynamic Schedule & Faculty Substitution alerts
│   │   └── transport/         # Campus Bus GPS simulator & Transit Pass
│   ├── models/                # Strongly-typed domain models & data entities
│   ├── providers/             # Centralized CampusProvider state management
│   └── main.dart              # Application entry point & service bootstrap
└── pubspec.yaml               # Project dependencies and asset declarations
```

---

## 🚀 Setup & Execution Guide

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.24.0 or newer)
- Android Studio / VS Code with Flutter extensions
- Android Device / Emulator (API Level 26+) or Chrome for Web

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mohitdonawat/digital-campus.git
   cd digital-campus
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify environment health:**
   ```bash
   flutter doctor
   flutter analyze
   ```

4. **Launch the application:**
   - **For Chrome (Web):**
     ```bash
     flutter run -d chrome
     ```
   - **For Windows Desktop:**
     ```bash
     flutter run -d windows
     ```
   - **For Android Device/Emulator:**
     ```bash
     flutter run -d android
     ```

---

## 🔒 Security & Data Privacy

- **Zero Third-Party Telemetry:** Student grades, attendance statistics, and fee balances are processed locally on the client and sovereign backend without uploading sensitive data to external AI servers.
- **Tamper-Evident Hashing:** Official documents and certificates embed irreversible SHA-256 verification hashes.
- **Role Isolation:** Strict interface and data separation between students, parents, faculty, and administrative authorities.

---

## 👨‍💻 Engineering Leadership & Author

**Designed, Architected & Built by:**  
### **Mr. Mohit Donawat**
- **Role:** Lead System Architect & Full-Stack AI Engineer
- **GitHub:** [@mohitdonawat](https://github.com/mohitdonawat)
- **Project:** Digital Campus Unified Operating System (ERP 4.0 & Applied AI)

---

## 📄 License & Attribution

Developed & Maintained by **Mr. Mohit Donawat** (Digital Campus Technologies). All rights reserved.  
Engineered for modernization, statutory regulatory compliance, and institutional governance across higher education institutions.
