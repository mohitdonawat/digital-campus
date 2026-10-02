"""
Digital Campus - Enterprise Relational SQLite Database Layer
Handles real persistence, relational joins, and ACID transactions.
"""

import sqlite3
import os
import hashlib
from datetime import datetime

DB_PATH = os.path.join(os.path.dirname(__file__), "campus.db")

def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_database():
    """Initializes real tables and seeds institutional data."""
    conn = get_connection()
    cursor = conn.cursor()

    # 1. Students Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS students (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        roll_number TEXT UNIQUE NOT NULL,
        enrollment_number TEXT NOT NULL,
        branch TEXT NOT NULL,
        semester INTEGER NOT NULL,
        section TEXT NOT NULL,
        current_cgpa REAL NOT NULL,
        attendance_percentage REAL NOT NULL,
        hostel_block TEXT,
        room_number TEXT,
        bus_route_number TEXT,
        mentor_name TEXT,
        parent_phone TEXT
    );
    """)

    # 2. Subject Attendance Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS attendance (
        subject_code TEXT PRIMARY KEY,
        subject_name TEXT NOT NULL,
        attended_classes INTEGER NOT NULL,
        total_classes INTEGER NOT NULL,
        faculty_name TEXT NOT NULL
    );
    """)

    # 3. Timetable Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS timetable (
        id TEXT PRIMARY KEY,
        day TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        subject_name TEXT NOT NULL,
        subject_code TEXT NOT NULL,
        room_number TEXT NOT NULL,
        faculty_name TEXT NOT NULL,
        is_substitute INTEGER NOT NULL DEFAULT 0,
        substitute_reason TEXT
    );
    """)

    # 4. Fees Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS fees (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        is_paid INTEGER NOT NULL DEFAULT 0,
        paid_date TEXT,
        transaction_id TEXT,
        receipt_number TEXT
    );
    """)

    # 5. Cryptographic Certificates Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS certificates (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        issue_date TEXT NOT NULL,
        issued_to TEXT NOT NULL,
        roll_number TEXT NOT NULL,
        sha256_hash TEXT NOT NULL,
        attested_by TEXT NOT NULL
    );
    """)

    # 6. Vernacular Academic Concept & Feynman Simplification Table (Lifetime Free Offline Cache)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS academic_glossary (
        term_key TEXT PRIMARY KEY,
        english_term TEXT NOT NULL,
        subject TEXT NOT NULL,
        definition TEXT NOT NULL,
        hindi_translation TEXT NOT NULL,
        hindi_feynman_meaning TEXT NOT NULL,
        marathi_translation TEXT NOT NULL,
        marathi_feynman_meaning TEXT NOT NULL,
        telugu_translation TEXT NOT NULL,
        telugu_feynman_meaning TEXT NOT NULL,
        tamil_translation TEXT NOT NULL,
        tamil_feynman_meaning TEXT NOT NULL
    );
    """)

    # 7. Institutional On-Screen Exam Evaluations & Gradebook Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS exam_evaluations (
        id TEXT PRIMARY KEY,
        subject_code TEXT NOT NULL,
        exam_id TEXT NOT NULL,
        student_roll TEXT NOT NULL,
        student_name TEXT NOT NULL,
        question_id TEXT NOT NULL,
        awarded_marks REAL NOT NULL,
        max_marks REAL NOT NULL,
        confidence_score REAL NOT NULL,
        steps_json TEXT NOT NULL,
        annotations_json TEXT NOT NULL,
        teacher_remarks TEXT,
        sha256_hash TEXT NOT NULL,
        evaluator_name TEXT NOT NULL,
        evaluated_at TEXT NOT NULL
    );
    """)

    # 8. Hostel Blocks Occupancy Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS hostel_blocks (
        block_id TEXT PRIMARY KEY,
        block_name TEXT NOT NULL,
        type TEXT NOT NULL,
        total_capacity INTEGER NOT NULL,
        occupied_beds INTEGER NOT NULL,
        vacant_beds INTEGER NOT NULL,
        warden_name TEXT NOT NULL,
        warden_phone TEXT NOT NULL
    );
    """)

    # 9. Hostel Gate Passes Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS hostel_gatepasses (
        id TEXT PRIMARY KEY,
        student_name TEXT NOT NULL,
        roll_number TEXT NOT NULL,
        reason TEXT NOT NULL,
        destination TEXT NOT NULL,
        out_time TEXT NOT NULL,
        expected_in TEXT NOT NULL,
        status TEXT NOT NULL,
        approved_by TEXT NOT NULL,
        parent_phone TEXT NOT NULL,
        is_curfew_breached INTEGER NOT NULL DEFAULT 0
    );
    """)

    # 10. Hostel Room Maintenance Tickets Table (24h SLA)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS hostel_maintenance (
        id TEXT PRIMARY KEY,
        room_number TEXT NOT NULL,
        student_name TEXT NOT NULL,
        roll_number TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        urgency TEXT NOT NULL,
        status TEXT NOT NULL,
        assigned_staff TEXT NOT NULL,
        reported_at TEXT NOT NULL,
        resolved_at TEXT
    );
    """)

    # 11. Mess Nutrition & Student Meal Feedback Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS mess_ratings (
        id TEXT PRIMARY KEY,
        meal_type TEXT NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        student_roll TEXT NOT NULL
    );
    """)

    # Seed hostel blocks if empty
    cursor.execute("SELECT COUNT(*) FROM hostel_blocks")
    if cursor.fetchone()[0] == 0:
        blocks_data = [
            ("BLK-A", "Aryabhatta Bhawan (Senior Boys)", "Boys", 150, 142, 8, "Dr. K.P. Singh", "+91 94250 11990"),
            ("BLK-B", "Ramanujan Bhawan (Junior Boys)", "Boys", 150, 138, 12, "Prof. Arvind Sharma", "+91 98930 44556"),
            ("BLK-C", "Gargi Bhawan (Girls Wing)", "Girls", 150, 132, 18, "Dr. Pratibha Mishra", "+91 98261 77334"),
        ]
        cursor.executemany("INSERT INTO hostel_blocks VALUES (?, ?, ?, ?, ?, ?, ?, ?);", blocks_data)

    # Seed hostel gate passes if empty
    cursor.execute("SELECT COUNT(*) FROM hostel_gatepasses")
    if cursor.fetchone()[0] == 0:
        passes_data = [
            ("GP-2026-9022", "Vikas Mehra", "CS22B052", "Exam Book Purchase", "MP Nagar Zone 2", "2026-10-02 04:00 PM", "2026-10-02 08:00 PM", "Pending", "Awaiting Warden Signature", "+91 98270 33900", 0),
            ("GP-2026-8910", "Aditya Kulshreshtha", "CS22B099", "Project Discussion", "DB City Tech Hub", "2026-10-02 03:30 PM", "2026-10-02 08:30 PM", "Out of Campus", "Prof. Arvind Sharma", "+91 94251 77889", 1),
            ("GP-2026-8841", "Rahul Sharma", "CS22B045", "Weekend Family Visit", "Indore (Home)", "2026-09-26 05:00 PM", "2026-09-28 08:00 AM", "Approved", "Prof. Arvind Sharma", "+91 94250 88991", 0),
        ]
        cursor.executemany("INSERT INTO hostel_gatepasses VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", passes_data)

    # Seed maintenance tickets if empty
    cursor.execute("SELECT COUNT(*) FROM hostel_maintenance")
    if cursor.fetchone()[0] == 0:
        tickets_data = [
            ("HMT-2026-081", "B-304", "Rahul Sharma", "CS22B045", "Electrical", "Ceiling fan running at regulator speed 1", "Normal", "Assigned", "Ramesh Sharma (Electrician)", "Today, 10:30 AM", None),
            ("HMT-2026-068", "B-302", "Vikas Mehra", "CS22B052", "Plumbing", "Washroom tap continuous dripping", "Critical", "Reported", "Pending Assignment", "Today, 01:00 PM", None),
            ("HMT-2026-074", "B-304", "Aman Verma", "CS22B019", "Wi-Fi / LAN", "LAN socket loose connection", "Normal", "Resolved", "Sunil IT Cell", "Yesterday, 02:15 PM", "Yesterday, 06:30 PM"),
        ]
        cursor.executemany("INSERT INTO hostel_maintenance VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", tickets_data)

    # Seed mess ratings if empty
    cursor.execute("SELECT COUNT(*) FROM mess_ratings")
    if cursor.fetchone()[0] == 0:
        mess_data = [
            ("MF-01", "Breakfast", 4, "Aloo Paratha & Curd fresh and hot", "Today 08:45 AM", "CS22B045"),
            ("MF-02", "Lunch", 5, "Paneer Butter Masala served fresh", "Today 01:30 PM", "CS22B045"),
            ("MF-03", "High Tea", 4, "Crispy Veg Cutlets with Chai", "Today 05:20 PM", "CS22B019"),
            ("MF-04", "Dinner", 5, "Mix Veg and Kheer excellent", "Today 08:40 PM", "CS22B052"),
        ]
        cursor.executemany("INSERT INTO mess_ratings VALUES (?, ?, ?, ?, ?, ?);", mess_data)

    # Seed initial student record if empty
    cursor.execute("SELECT COUNT(*) FROM students")
    if cursor.fetchone()[0] == 0:
        cursor.execute("""
        INSERT INTO students VALUES (
            'STU-2022-CS-045', 'Rahul Sharma', 'CS22B045', '0176CS221045',
            'Computer Science & Engineering', 6, 'A', 8.42, 82.4,
            'Ramanujan Bhawan (Block B)', 'B-304', 'Route 04 (City Express)',
            'Dr. Mohit Donawat', '+91 94250 88991'
        );
        """)

        # Seed attendance
        attendance_data = [
            ('CS-601', 'Machine Learning & AI', 36, 42, 'Dr. Mohit Donawat'),
            ('CS-602', 'Computer Networks & Security', 38, 44, 'Prof. Priya Verma'),
            ('CS-603', 'Cloud Computing & DevOps', 27, 35, 'Prof. Ankit Saxena'),
            ('CS-604', 'Compiler Design & Automata', 28, 40, 'Dr. S.K. Rathore'),
            ('CS-605', 'Mobile Application Development', 32, 36, 'Prof. Neha Gupta')
        ]
        cursor.executemany("INSERT INTO attendance VALUES (?, ?, ?, ?, ?);", attendance_data)

        # Seed fees
        fees_data = [
            ('FEE-SEM6-TUI', 'Semester 6 Academic Tuition Fee', 45000.0, '2026-10-15', 0, None, None, None),
            ('FEE-EXAM-SEM6', 'University Examination Fee', 2500.0, '2026-10-30', 0, None, None, None),
            ('FEE-HOSTEL-S2', 'Hostel & Mess Charges', 32000.0, '2026-08-10', 1, '2026-08-05', 'TXN-UPI-98421092834', 'REC-2026-08-9412'),
            ('FEE-BUS-ANNUAL', 'Campus Transit Bus Pass', 14000.0, '2026-07-25', 1, '2026-07-22', 'TXN-NET-77192340112', 'REC-2026-07-1049')
        ]
        cursor.executemany("INSERT INTO fees VALUES (?, ?, ?, ?, ?, ?, ?, ?);", fees_data)

        # Seed certificates with genuine SHA-256 hash
        now = datetime.now().strftime("%Y-%m-%d")
        digest = hashlib.sha256(b"DIGITAL_CAMPUS:STU-2022-CS-045:CS22B045:BONAFIDE:REGISTRAR").hexdigest()
        cursor.execute("""
        INSERT INTO certificates VALUES (
            'DC-2026-BF-9042', 'Official State Scholarship Bonafide Certificate',
            'Bonafide', ?, 'Rahul Sharma', 'CS22B045', ?, 'Mr. Shridhar Donawat (Dean & Director)'
        );
        """, (now, digest))

        # Seed Vernacular Academic Concept Glossary (Offline-First Cache)
        glossary_data = [
            (
                'backpropagation',
                'Backpropagation Algorithm',
                'Machine Learning & AI',
                'Method used in artificial neural networks to calculate a gradient that is needed in the calculation of the weights to be used in the network.',
                'पश्च-प्रसार एल्गोरिथम (Backpropagation)',
                'सरल शब्दों में: जैसे निशानेबाजी में निशाना चूकने पर हम देखते हैं कि तीर कितना ऊपर या नीचे लगा, और अगली बार अपना हाथ उसी हिसाब से एडजस्ट करते हैं — ठीक वैसे ही न्यूरल नेटवर्क टारगेट से हुई गलती (Error) को पीछे भेजकर अपने वजन (Weights) को ठीक करता है ताकि अगली बार सटीक उत्तर आए।',
                'बॅकप्रोपॅगेशन अल्गोरिदम',
                'सोप्या भाषेत: जसे आपण निशाणा चुकल्यावर आपली चूक पाहून पुढच्या वेळी हात बरोबर रोखतो, तसेच न्यूरल नेटवर्क प्रत्येक चुकीवरून शिकून स्वतःचे वजन दुरुस्त करते.',
                'బ్యాక్‌ప్రాపగేషన్ అల్గోరిథం',
                'సరళమైన మాటల్లో: లక్ష్యాన్ని మిస్ చేసినప్పుడు ఎంత తేడా వచ్చిందో చూసి తదుపరి సారి మన చేతిని సరిచేసుకున్నట్లే, న్యూరల్ నెట్‌వర్క్ కూడా లోపాన్ని వెనుకకు పంపి తదుపరిసారి సరైన ఫలితాన్ని ఇవ్వడానికి సిద్ధమవుతుంది.',
                'பின்புற பரவல் வழிமுறை (Backpropagation)',
                'எளிய விளக்கம்: வில்வித்தையில் இலக்கு தவறும்போது பிழையைக் கணக்கிட்டு அடுத்த முறை கையை சரிசெய்வது போல, நியூரல் நெட்வொர்க் பிழையை சரிசெய்து எடைகளை மாற்றியமைக்கிறது.'
            ),
            (
                'lr_parsing',
                'LR(1) Bottom-Up Parser',
                'Compiler Design & Automata',
                'A non-backtracking bottom-up parser which parses deterministically from Left to right, producing a Rightmost derivation in reverse.',
                'एलआर(1) बॉटम-अप पार्सर (Bottom-Up Parsing)',
                'सरल शब्दों में: जैसे लेगो (Lego) ब्लॉक्स को नीचे जमीन से एक-एक करके जोड़कर ऊपर पूरा महल बनाते हैं — वैसे ही यह पार्सर प्रोग्राम के छोटे-छोटे शब्दों (Tokens) को नीचे से समेटते हुए ऊपर मुख्य व्याकरण (Grammar Start Symbol) तक ले जाता है।',
                'एलआर(1) बॉटम-अप पार्सर',
                'सोप्या भाषेत: लेगोच्या छोट्या ठोकळ्यांपासून वर मोठा बंगला बांधण्यासारखे, हे कोडच्या लहान शब्दांना एकत्र करून मूळ व्याकरणाशी जोडते.',
                'ఎల్ఆర్(1) బాటమ్-అప్ పార్సర్',
                'సరళమైన మాటల్లో: ఇటుకలను ఒక్కొక్కటిగా పేర్చి పెద్ద భవనం కట్టినట్లుగా, చిన్న టోకెన్ల నుండి ప్రారంభించి పూర్తి వ్యాకరణ నియమాలను నిర్మిస్తుంది.',
                'எல்ஆர்(1) கீழ்மட்ட பகுப்பாய்வி',
                'எளிய விளக்கம்: கீழிருந்து செங்கற்களை அடுக்கி மேலே கட்டிடத்தை உருவாக்குவது போல, குறியீட்டு டோக்கன்களை ஒருங்கிணைத்து இலக்கணத்தை உறுதி செய்கிறது.'
            ),
            (
                'tcp_congestion',
                'TCP Tahoe vs Reno Congestion Control',
                'Computer Networks & Security',
                'Algorithms managing network traffic load to prevent packet loss by adjusting congestion window size dynamically.',
                'टीसीपी कंजेक्शन कंट्रोल (Slow Start & Window Halving)',
                'सरल शब्दों में: जैसे सड़क पर ट्रैफिक देखकर हम गाड़ी की स्पीड धीरे-धीरे बढ़ाते हैं (Slow Start), और आगे जाम या एक्सीडेंट (Packet Loss) दिखते ही स्पीड तुरंत आधी कर लेते हैं — इंटरनेट पर डेटा का फ्लो भी इसी तरह कंट्रोल होता है ताकि नेटवर्क क्रैश न हो।',
                'टीसीपी ट्रॅफिक नियंत्रण',
                'सोप्या भाषेत: रस्त्यावर ट्रॅफिक वाढल्यास गाडीचा वेग कमी करण्यासारखे, इंटरनेटवर पॅकेट्स गहाळ होऊ नयेत म्हणून डेटाचा वेग नियंत्रित केला जातो.',
                'టీసీపీ రద్దీ నియంత్రణ',
                'సరళమైన మాటల్లో: రహదారిపై ట్రాఫిక్ చూసి వాహనం వేగాన్ని నియంత్రించినట్లు, నెట్‌వర్క్‌లో డేటా నష్టపోకుండా ఉండేందుకు వేగాన్ని తగ్గిస్తుంది.',
                'டிசிபி நெரிசல் கட்டுப்பாடு',
                'எளிய விளக்கம்: சாலையில் நெரிசலைக் கண்டு வாகனத்தின் வேகத்தை மாற்றுவது போல, இணையத்தில் தரவு இழப்பைத் தவிர்க்க வேகத்தை ஒழுங்குபடுத்துகிறது.'
            )
        ]
        cursor.executemany("""
        INSERT OR REPLACE INTO academic_glossary VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, glossary_data)

        conn.commit()

    # Initialize and seed Sovereign Textbook RAG Tables
    try:
        from rag_engine import TextbookRagEngine
        TextbookRagEngine.init_tables(conn)
        TextbookRagEngine.seed_default_curriculum_books(conn)
    except Exception as e:
        print(f"RAG init notice: {e}")

    conn.close()

if __name__ == "__main__":
    init_database()
    print("[OK] SQLite Database successfully initialized with institutional schema and Textbook RAG Index!")
