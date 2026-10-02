package main

import (
	"sync"
	"time"
)

// ============================================================================
// 🗄️ IN-MEMORY THREAD-SAFE DATABASE
// ============================================================================
type DataStore struct {
	mu                sync.RWMutex
	tenants           map[string]*CollegeTenant
	attendance        map[string]*StudentAttendanceRecord
	hostelBlocks      map[string]*HostelBlockRecord
	hostelPasses      map[string]*HostelGatePassRecord
	hostelMaintenance map[string]*HostelMaintenanceRecord
	messRatings       []MessRatingRecord
	messRebates       []MessRebateRecord
	hostelSwaps       map[string]*RoomSwapRecord
	hostelFacilities  map[string]*FacilitySlotRecord
	hostelSosLogs     []*EmergencySosRecord
	hostelEnergy      *EnergyMeterRecord
	hostelPolicy      *HostelPolicyRecord

	// 6 Ultra-Smart Innovation Repositories
	roommateQuizzes   map[string]*RoommateQuizRecord
	roommateSettings  *RoommateSettingsRecord
	diningIntents     map[string]*DiningIntentGoRecord
	messForecast      *MessForecastRecord
	silentDuress      *SilentDuressRecord
	roomAssets        map[string]*RoomAssetRecord
	greenDormEco      *GreenDormEcoRecord
	curfewExtensions  map[string]*CurfewExtensionRecord

	logs              []AutomationLog
	subscribers       map[string]chan string
	subMutex          sync.RWMutex
	startTime         time.Time
}

var db = &DataStore{
	tenants:           make(map[string]*CollegeTenant),
	attendance:        make(map[string]*StudentAttendanceRecord),
	hostelBlocks:      make(map[string]*HostelBlockRecord),
	hostelPasses:      make(map[string]*HostelGatePassRecord),
	hostelMaintenance: make(map[string]*HostelMaintenanceRecord),
	messRatings:       make([]MessRatingRecord, 0),
	messRebates:       make([]MessRebateRecord, 0),
	hostelSwaps:       make(map[string]*RoomSwapRecord),
	hostelFacilities:  make(map[string]*FacilitySlotRecord),
	hostelSosLogs:     make([]*EmergencySosRecord, 0),

	roommateQuizzes:   make(map[string]*RoommateQuizRecord),
	diningIntents:     make(map[string]*DiningIntentGoRecord),
	roomAssets:        make(map[string]*RoomAssetRecord),
	curfewExtensions:  make(map[string]*CurfewExtensionRecord),

	logs:              make([]AutomationLog, 0),
	subscribers:       make(map[string]chan string),
	startTime:         time.Now(),
}

// ============================================================================
// 🚀 INITIALIZATION & SEED DATA
// ============================================================================
func initSeedData() {
	db.mu.Lock()
	defer db.mu.Unlock()

	// 1. Seed Partner Multi-Tenant Colleges
	t1 := &CollegeTenant{
		ID:             "col_ies_01",
		Name:           "IES College of Technology",
		Code:           "IES-TECH",
		City:           "Bhopal",
		State:          "Madhya Pradesh",
		Affiliation:    "Autonomous RGPV & AICTE",
		Status:         "active",
		AdminEmail:     "registrar@iesbhopal.ac.in",
		AdminPassword:  "IES_Admin#2026",
		AdminName:      "Dr. Sunita Saxena",
		AdminID:        "IES_ADM_1092",
		StudentCount:   4280,
		FacultyCount:   210,
		LicensePlan:    "Enterprise Cloud Tier-1",
		RegisteredDate: "12 Jan 2024",
		LastAuditedAt:  time.Now(),
	}

	t2 := &CollegeTenant{
		ID:             "col_rgpv_02",
		Name:           "Rajiv Gandhi Proudyogiki Vishwavidyalaya",
		Code:           "RGPV-STATE",
		City:           "Bhopal",
		State:          "Madhya Pradesh",
		Affiliation:    "State Statutory University",
		Status:         "active",
		AdminEmail:     "controller@rgpv.ac.in",
		AdminPassword:  "RGPV_Univ@891",
		AdminName:      "Prof. M. K. Verma",
		AdminID:        "RGPV_ADM_001",
		StudentCount:   85000,
		FacultyCount:   1800,
		LicensePlan:    "State University Master SaaS",
		RegisteredDate: "05 Nov 2023",
		LastAuditedAt:  time.Now(),
	}

	db.tenants[t1.ID] = t1
	db.tenants[t2.ID] = t2

	// 2. Seed Class-Wise Attendance Records
	db.attendance["CS22B045"] = &StudentAttendanceRecord{
		StudentID:            "STU_045",
		Name:                 "Rahul Sharma",
		RollNumber:           "CS22B045",
		Branch:               "CSE",
		Semester:             6,
		Section:              "Sec A",
		AttendancePercentage: 88.5,
		IsPresentToday:       true,
		TotalClasses:         120,
		AttendedClasses:      106,
		ParentPhone:          "+91 94250 88991",
		ParentName:           "Suresh Sharma",
		RiskScore:            "SAFE",
		DeficitClasses:       0,
		SafeBunks:            16,
	}

	db.attendance["CS22B019"] = &StudentAttendanceRecord{
		StudentID:            "STU_019",
		Name:                 "Aman Verma",
		RollNumber:           "CS22B019",
		Branch:               "CSE",
		Semester:             6,
		Section:              "Sec A",
		AttendancePercentage: 68.2,
		IsPresentToday:       false,
		TotalClasses:         120,
		AttendedClasses:      82,
		ParentPhone:          "+91 98260 44551",
		ParentName:           "Rajesh Verma",
		RiskScore:            "CRITICAL",
		DeficitClasses:       8,
		SafeBunks:            0,
	}

	// 3. Seed Hostel Blocks (450 Total Bed Capacity)
	db.hostelBlocks["BLK-A"] = &HostelBlockRecord{
		BlockID:      "BLK-A",
		BlockName:    "Aryabhatta Bhawan (Senior Boys)",
		Type:         "Boys",
		TotalBeds:    150,
		OccupiedBeds: 142,
		VacantBeds:   8,
		WardenName:   "Dr. K.P. Singh",
		WardenPhone:  "+91 94250 11990",
	}

	db.hostelBlocks["BLK-B"] = &HostelBlockRecord{
		BlockID:      "BLK-B",
		BlockName:    "Ramanujan Bhawan (Junior Boys)",
		Type:         "Boys",
		TotalBeds:    150,
		OccupiedBeds: 138,
		VacantBeds:   12,
		WardenName:   "Prof. Arvind Sharma",
		WardenPhone:  "+91 98930 44556",
	}

	db.hostelBlocks["BLK-C"] = &HostelBlockRecord{
		BlockID:      "BLK-C",
		BlockName:    "Gargi Bhawan (Girls Wing)",
		Type:         "Girls",
		TotalBeds:    150,
		OccupiedBeds: 132,
		VacantBeds:   18,
		WardenName:   "Dr. Pratibha Mishra",
		WardenPhone:  "+91 98261 77334",
	}

	// 4. Seed Gate Passes with Rolling Token Hashes
	db.hostelPasses["GP-2026-8841"] = &HostelGatePassRecord{
		ID:               "GP-2026-8841",
		StudentID:        "STU_045",
		StudentName:      "Rahul Sharma",
		RollNumber:       "CS22B045",
		RoomNumber:       "B-304",
		Destination:      "Indore (Home Visit)",
		Reason:           "Weekend Family Function & Medical Review",
		OutTime:          time.Now().Add(-48 * time.Hour),
		ExpectedInTime:   time.Now().Add(24 * time.Hour),
		Status:           "Approved",
		ParentPhone:      "+91 94250 88991",
		IsCurfewBreached: false,
		ApprovedBy:       "Chief Warden Prof. Arvind Sharma",
		QrTokenHash:      "HMAC-SHA256:8841-ROTATING-KEY-V1",
		LastScanAt:       time.Now().Add(-48 * time.Hour),
	}

	db.hostelPasses["GP-2026-8712"] = &HostelGatePassRecord{
		ID:               "GP-2026-8712",
		StudentID:        "STU_045",
		StudentName:      "Rahul Sharma",
		RollNumber:       "CS22B045",
		RoomNumber:       "B-304",
		Destination:      "New Market, Bhopal",
		Reason:           "Hardware Purchase for Major Project",
		OutTime:          time.Now().Add(-5 * time.Hour),
		ExpectedInTime:   time.Now().Add(-1 * time.Hour),
		Status:           "Closed",
		ParentPhone:      "+91 94250 88991",
		IsCurfewBreached: false,
		ApprovedBy:       "Turnstile Gate Scanner #01",
		QrTokenHash:      "HMAC-SHA256:8712-VERIFIED",
		LastScanAt:       time.Now().Add(-1 * time.Hour),
	}

	// 5. Seed Maintenance Tickets
	db.hostelMaintenance["HMT-2026-081"] = &HostelMaintenanceRecord{
		ID:            "HMT-2026-081",
		RoomNumber:    "B-304",
		StudentName:   "Rahul Sharma",
		RollNumber:    "CS22B045",
		Category:      "Electrical",
		Description:   "Ceiling fan speed regulator faulty, stuck at speed 1.",
		Urgency:       "Normal",
		Status:        "Assigned",
		AssignedStaff: "Ramesh Sharma (Campus Electrician)",
		ReportedAt:    time.Now().Add(-3 * time.Hour),
	}

	// 6. Seed Mess Ratings & Rebate
	db.messRatings = append(db.messRatings, MessRatingRecord{
		ID:        "MR-01",
		MealType:  "Breakfast",
		Stars:     4,
		Feedback:  "Aloo Paratha & Fresh Curd was hygienic and warm.",
		Timestamp: time.Now().Add(-6 * time.Hour),
	})

	db.messRebates = append(db.messRebates, MessRebateRecord{
		ID:           "REB-2026-104",
		StudentName:  "Rahul Sharma",
		RollNumber:   "CS22B045",
		StartDate:    "2026-10-10",
		EndDate:      "2026-10-14",
		Days:         4,
		RebateAmount: 480.0,
		Reason:       "Diwali Fest Family Visit",
		Status:       "Approved",
	})

	// 7. Seed Mutual Room Swap (IIT/BITS SWD)
	db.hostelSwaps["SWAP-2026-012"] = &RoomSwapRecord{
		ID:                   "SWAP-2026-012",
		RequesterStudentName: "Rahul Sharma",
		RequesterRoll:        "CS22B045",
		CurrentRoom:          "B-304 (Block B)",
		TargetStudentName:    "Amit Verma",
		TargetRoll:           "CS22B088",
		TargetRoom:           "A-210 (Block A)",
		Reason:               "Closer to High-Performance Computing Research Lab",
		Status:               "Peer Approved",
		CreatedAt:            time.Now().Add(-24 * time.Hour),
	}

	// 8. Seed IoT Facility Slots (Cloudbeds / StarRez)
	db.hostelFacilities["FAC-LAUNDRY-01"] = &FacilitySlotRecord{
		ID:           "FAC-LAUNDRY-01",
		FacilityName: "Smart IoT Washer 01 (Speed Queen 12kg)",
		SlotTime:     "Today 05:00 PM - 05:45 PM",
		BookedByRoll: "CS22B019",
		Status:       "Active",
	}

	db.hostelFacilities["FAC-LAUNDRY-02"] = &FacilitySlotRecord{
		ID:           "FAC-LAUNDRY-02",
		FacilityName: "Smart IoT Washer 02 (Speed Queen 12kg)",
		SlotTime:     "Today 06:00 PM - 06:45 PM",
		BookedByRoll: "",
		Status:       "Available",
	}

	db.hostelFacilities["FAC-STUDY-04"] = &FacilitySlotRecord{
		ID:           "FAC-STUDY-04",
		FacilityName: "Acoustic Quiet Study Pod #04",
		SlotTime:     "Tonight 09:00 PM - 11:00 PM",
		BookedByRoll: "CS22B045",
		Status:       "Booked",
	}

	// 9. Seed Green Dorm IoT Power Meter
	db.hostelEnergy = &EnergyMeterRecord{
		RoomNumber:      "B-304",
		CurrentKwhToday: 4.2,
		MonthlyKwh:      114.6,
		LiveLoadWatts:   340.0,
		IsOverloadAlert: false,
	}

	// 10. Seed Autonomous Fee Tariff & Curfew Policy
	db.hostelPolicy = &HostelPolicyRecord{
		SingleRoomAcRent:      48000.0,
		DoubleRoomAcRent:      38000.0,
		TripleRoomAcRent:      16000.0,
		NonAcRoomRent:         12000.0,
		MessDailyRate:         120.0,
		MessRebatePerDay:      120.0,
		MinLeaveDaysForRebate: 3,
		CautionDeposit:        5000.0,
		WifiAndAmenitiesFee:   1600.0,
		FreeElectricityUnits:  100,
		ElectricityUnitRate:   8.0,
		CurfewTime:            "08:30 PM",
		CurfewViolationFine:   250.0,
	}

	// 11. Seed AI Stable-Marriage Roommate Matchmaker
	db.roommateQuizzes["CS22B045"] = &RoommateQuizRecord{
		RollNumber:          "CS22B045",
		StudentName:         "Rahul Sharma",
		Branch:              "Computer Science & Engineering",
		SleepCycle:          "Night Owl (02:00 AM)",
		StudyEnvironment:    "Background Lo-Fi Music",
		AcPreference:        "Moderate (24°C)",
		Cleanliness:         "Minimalist Clean",
		Interests:           []string{"Competitive Coding", "System Architecture", "Gym"},
		CompatibilityScore:  96,
		MatchedRoommateRoll: "IT22B019",
		MatchedRoommateName: "Rohan Joshi",
		AssignedRoom:        "B-304",
	}

	db.roommateQuizzes["IT22B019"] = &RoommateQuizRecord{
		RollNumber:          "IT22B019",
		StudentName:         "Rohan Joshi",
		Branch:              "Information Technology",
		SleepCycle:          "Night Owl (01:30 AM)",
		StudyEnvironment:    "Background Lo-Fi Music",
		AcPreference:        "Moderate (23°C)",
		Cleanliness:         "Minimalist Clean",
		Interests:           []string{"System Architecture", "Open Source", "Gaming"},
		CompatibilityScore:  96,
		MatchedRoommateRoll: "CS22B045",
		MatchedRoommateName: "Rahul Sharma",
		AssignedRoom:        "B-304",
	}

	db.roommateSettings = &RoommateSettingsRecord{
		IsSelfDiscoveryEnabled: true,
		IsAutoAllocationActive: true,
		TotalQuizSubmissions:   240,
		MatchedPairsCount:      112,
		AverageMatchScore:      93.4,
	}

	// 12. Seed AI Predictive Mess Headcount & Food Waste Minimizer
	db.diningIntents["INT-2026-001"] = &DiningIntentGoRecord{
		ID:          "INT-2026-001",
		StudentRoll: "CS22B045",
		StudentName: "Rahul Sharma",
		Date:        "Today",
		MealType:    "Dinner",
		Intent:      "ATTENDING",
		UpdatedAt:   time.Now(),
	}

	db.messForecast = &MessForecastRecord{
		Date:                   "Today (Dinner Service)",
		MealType:               "Dinner",
		TotalHostellers:        450,
		ExpectedDiningCount:    284,
		GatePassOutCount:       68,
		VoluntarySkippingCount: 48,
		RecommendedRiceKg:      35.0,
		BaselineRiceKg:         50.0,
		FoodSavedKg:            15.0,
		DailyRupeesSaved:       3720.0,
		AnnualProjectedSavings: 680000.0,
		ChefAlertMessage:       "Chef Alert: 284 students dining tonight (68 out-pass, 48 skipping). Cook 35kg rice instead of 50kg. Target savings: ₹3,720 tonight!",
	}

	// 13. Seed Anti-Ragging Silent Duress Secret PIN
	db.silentDuress = &SilentDuressRecord{
		ID:                "DURESS-001",
		StudentRoll:       "CS22B045",
		StudentName:       "Rahul Sharma",
		RoomNumber:        "B-304",
		BlockName:         "Ramanujan Bhawan (Block B)",
		SecretDuressPin:   "9999",
		IsDuressTriggered: false,
		GpsCoordinates:    "Lat: 23.2599, Long: 77.4126 (Ramanujan Bhawan Room B-304)",
		TriggeredAt:       time.Now(),
		DispatchStatus:    "STANDBY_READY",
	}

	// 14. Seed AI Room Asset Inspection & Caution Deposit Audit
	db.roomAssets["AST-B304-01"] = &RoomAssetRecord{
		ID:                "AST-B304-01",
		RoomNumber:        "B-304",
		AssetName:         "Solid Teak Study Table & Ergonomic Chair",
		CheckInDate:       "15 Jul 2024",
		CheckInCondition:  "Pristine factory condition, zero scratch, polish intact",
		CheckInSha256Hash: "SHA256:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069",
		CheckOutDate:      "May 2026 (Upcoming)",
		CheckOutCondition: "Clean, zero structural defect, normal wear cleared",
		DamageScore:       0.01,
		CautionDeduction:  0.0,
		AuditStatus:       "VERIFIED_SAFE",
	}

	// 15. Seed Green Dorm IoT Power & Eco-Credits
	db.greenDormEco = &GreenDormEcoRecord{
		RoomNumber:        "B-304",
		MonthlyQuotaUnits: 120.0,
		ConsumedUnits:     82.4,
		RemainingUnits:    37.6,
		LiveLoadWatts:     340.0,
		EcoCredits:        450,
		Co2SavedKg:        28.5,
		WingRank:          "Floor 2 (#1 Eco-Champion Wing)",
		PerkReward:        "Free Sunday Dinner Dessert & 500Mbps High-Speed Wi-Fi",
	}

	// 16. Seed Curfew Auto-Extension with Parent WhatsApp Consent
	db.curfewExtensions["EXT-2026-088"] = &CurfewExtensionRecord{
		ID:                        "EXT-2026-088",
		GatePassID:                "GP-2026-089",
		StudentRoll:               "CS22B045",
		StudentName:               "Rahul Sharma",
		RoomNumber:                "B-304",
		OriginalCurfewTime:        "08:30 PM",
		RequestedExtensionMinutes: 45,
		ExtendedCurfewTime:        "09:15 PM",
		Reason:                    "Late Lab Coding Hackathon evaluation & MP Nagar traffic jam",
		ParentConsentStatus:       "PENDING",
		ParentConsentTimestamp:    time.Now(),
		WardenApprovalStatus:      "AUTO_APPROVED",
		IsFineWaived:              true,
	}
}
