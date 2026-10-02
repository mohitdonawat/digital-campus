package main

import "time"

// ============================================================================
// 📊 DATA MODELS (Multi-Tenant SaaS + Class Attendance + Autonomous Automation)
// ============================================================================

// CollegeTenant represents an institution onboarded into the SaaS platform
type CollegeTenant struct {
	ID             string    `json:"id"`
	Name           string    `json:"name"`
	Code           string    `json:"code"`
	City           string    `json:"city"`
	State          string    `json:"state"`
	Affiliation    string    `json:"affiliation"`
	Status         string    `json:"status"` // "active", "pending", "suspended"
	AdminEmail     string    `json:"admin_email"`
	AdminPassword  string    `json:"admin_password"`
	AdminName      string    `json:"admin_name"`
	AdminID        string    `json:"admin_id"`
	StudentCount   int       `json:"student_count"`
	FacultyCount   int       `json:"faculty_count"`
	LicensePlan    string    `json:"license_plan"` // "Enterprise Cloud", "State University", "Standard"
	RegisteredDate string    `json:"registered_date"`
	LastAuditedAt  time.Time `json:"last_audited_at"`
}

// StudentAttendanceRecord represents class-wise student attendance
type StudentAttendanceRecord struct {
	StudentID            string  `json:"student_id"`
	Name                 string  `json:"name"`
	RollNumber           string  `json:"roll_number"`
	Branch               string  `json:"branch"`   // "CSE", "IT", "ECE"
	Semester             int     `json:"semester"` // 4, 6, 8
	Section              string  `json:"section"`  // "Sec A", "Sec B"
	AttendancePercentage float64 `json:"attendance_percentage"`
	IsPresentToday       bool    `json:"is_present_today"`
	TotalClasses         int     `json:"total_classes"`
	AttendedClasses      int     `json:"attended_classes"`
	ParentPhone          string  `json:"parent_phone"`
	ParentName           string  `json:"parent_name"`
	RiskScore            string  `json:"risk_score"` // "CRITICAL", "MODERATE", "SAFE"
	DeficitClasses       int     `json:"deficit_classes"`
	SafeBunks            int     `json:"safe_bunks"`
}

// AutomationLog represents background automated actions executed by Go goroutines
type AutomationLog struct {
	ID        string    `json:"id"`
	Timestamp time.Time `json:"timestamp"`
	Category  string    `json:"category"` // "CURFEW_BREACH", "SOS_DISPATCH", "DETENTION_AUDIT", "SMS_DISPATCH"
	Message   string    `json:"message"`
	Severity  string    `json:"severity"` // "INFO", "WARNING", "ALERT"
}

// ============================================================================
// 🏨 HOSTEL MANAGEMENT MODELS (StarRez USA, Cloudbeds, IIT/BITS Pilani SWD)
// ============================================================================

// HostelBlockRecord represents a residential hall building
type HostelBlockRecord struct {
	BlockID      string `json:"block_id"`
	BlockName    string `json:"block_name"`
	Type         string `json:"type"` // "Boys", "Girls"
	TotalBeds    int    `json:"total_beds"`
	OccupiedBeds int    `json:"occupied_beds"`
	VacantBeds   int    `json:"vacant_beds"`
	WardenName   string `json:"warden_name"`
	WardenPhone  string `json:"warden_phone"`
}

// HostelGatePassRecord represents an electronic exit/entry pass with rolling cryptographic token
type HostelGatePassRecord struct {
	ID               string    `json:"id"`
	StudentID        string    `json:"student_id"`
	StudentName      string    `json:"student_name"`
	RollNumber       string    `json:"roll_number"`
	RoomNumber       string    `json:"room_number"`
	Destination      string    `json:"destination"`
	Reason           string    `json:"reason"`
	OutTime          time.Time `json:"out_time"`
	ExpectedInTime   time.Time `json:"expected_in_time"`
	Status           string    `json:"status"` // "Approved", "Pending", "Out of Campus", "Closed"
	ParentPhone      string    `json:"parent_phone"`
	IsCurfewBreached bool      `json:"is_curfew_breached"`
	ApprovedBy       string    `json:"approved_by"`
	QrTokenHash      string    `json:"qr_token_hash"`
	LastScanAt       time.Time `json:"last_scan_at"`
}

// HostelMaintenanceRecord represents a 24h SLA room repair ticket
type HostelMaintenanceRecord struct {
	ID            string    `json:"id"`
	RoomNumber    string    `json:"room_number"`
	StudentName   string    `json:"student_name"`
	RollNumber    string    `json:"roll_number"`
	Category      string    `json:"category"` // "Electrical", "Plumbing", "Wi-Fi / LAN", "Housekeeping"
	Description   string    `json:"description"`
	Urgency       string    `json:"urgency"` // "Normal" (24h SLA), "Critical" (4h Emergency SLA)
	Status        string    `json:"status"`  // "Reported", "Assigned", "Resolved"
	AssignedStaff string    `json:"assigned_staff"`
	ReportedAt    time.Time `json:"reported_at"`
	ResolvedAt    time.Time `json:"resolved_at"`
}

// MessRatingRecord represents 5-star student food quality rating
type MessRatingRecord struct {
	ID        string    `json:"id"`
	MealType  string    `json:"meal_type"` // "Breakfast", "Lunch", "Snacks", "Dinner"
	Stars     int       `json:"stars"`     // 1 to 5
	Feedback  string    `json:"feedback"`
	Timestamp time.Time `json:"timestamp"`
}

// MessRebateRecord represents leave meal fee deduction credit
type MessRebateRecord struct {
	ID           string  `json:"id"`
	StudentName  string  `json:"student_name"`
	RollNumber   string  `json:"roll_number"`
	StartDate    string  `json:"start_date"`
	EndDate      string  `json:"end_date"`
	Days         int     `json:"days"`
	RebateAmount float64 `json:"rebate_amount"`
	Reason       string  `json:"reason"`
	Status       string  `json:"status"` // "Approved", "Credited"
}

// RoomSwapRecord represents mutual peer room transfer (IIT & BITS Pilani SWD)
type RoomSwapRecord struct {
	ID                   string    `json:"id"`
	RequesterStudentName string    `json:"requester_student_name"`
	RequesterRoll        string    `json:"requester_roll"`
	CurrentRoom          string    `json:"current_room"`
	TargetStudentName    string    `json:"target_student_name"`
	TargetRoll           string    `json:"target_roll"`
	TargetRoom           string    `json:"target_room"`
	Reason               string    `json:"reason"`
	Status               string    `json:"status"` // "Peer Approved", "Warden Approved", "Rejected"
	CreatedAt            time.Time `json:"created_at"`
}

// FacilitySlotRecord represents Cloudbeds / StarRez smart amenity scheduling
type FacilitySlotRecord struct {
	ID           string `json:"id"`
	FacilityName string `json:"facility_name"`
	SlotTime     string `json:"slot_time"`
	BookedByRoll string `json:"booked_by_roll"`
	Status       string `json:"status"` // "Available", "Booked", "Active"
}

// EmergencySosRecord represents Red SOS beacon panic event
type EmergencySosRecord struct {
	ID          string    `json:"id"`
	StudentName string    `json:"student_name"`
	RollNumber  string    `json:"roll_number"`
	RoomNumber  string    `json:"room_number"`
	Block       string    `json:"block"`
	TriggerTime time.Time `json:"trigger_time"`
	Status      string    `json:"status"` // "TRIGGERED", "RESOLVED"
	ResolvedBy  string    `json:"resolved_by"`
}

// EnergyMeterRecord represents IoT Green Dorm live electric power telemetry
type EnergyMeterRecord struct {
	RoomNumber      string  `json:"room_number"`
	CurrentKwhToday float64 `json:"current_kwh_today"`
	MonthlyKwh      float64 `json:"monthly_kwh"`
	LiveLoadWatts   float64 `json:"live_load_watts"`
	IsOverloadAlert bool    `json:"is_overload_alert"`
}

// HostelPolicyRecord represents Chief Warden dynamic tariff & curfew governance
type HostelPolicyRecord struct {
	SingleRoomAcRent      float64 `json:"single_room_ac_rent"`
	DoubleRoomAcRent      float64 `json:"double_room_ac_rent"`
	TripleRoomAcRent      float64 `json:"triple_room_ac_rent"`
	NonAcRoomRent         float64 `json:"non_ac_room_rent"`
	MessDailyRate         float64 `json:"mess_daily_rate"`
	MessRebatePerDay      float64 `json:"mess_rebate_per_day"`
	MinLeaveDaysForRebate int     `json:"min_leave_days_for_rebate"`
	CautionDeposit        float64 `json:"caution_deposit"`
	WifiAndAmenitiesFee   float64 `json:"wifi_and_amenities_fee"`
	FreeElectricityUnits  int     `json:"free_electricity_units"`
	ElectricityUnitRate   float64 `json:"electricity_unit_rate"`
	CurfewTime            string  `json:"curfew_time"`
	CurfewViolationFine   float64 `json:"curfew_violation_fine"`
}

// ============================================================================
// 🚀 6 ULTRA-SMART NEXT-GEN HOSTEL INNOVATION MODELS (Go Modular Server)
// ============================================================================

// 1. AI Stable-Marriage Roommate Quiz Record (Gale-Shapley Algorithm)
type RoommateQuizRecord struct {
	RollNumber          string   `json:"roll_number"`
	StudentName         string   `json:"student_name"`
	Branch              string   `json:"branch"`
	SleepCycle          string   `json:"sleep_cycle"`
	StudyEnvironment    string   `json:"study_environment"`
	AcPreference        string   `json:"ac_preference"`
	Cleanliness         string   `json:"cleanliness"`
	Interests           []string `json:"interests"`
	CompatibilityScore  int      `json:"compatibility_score"`
	MatchedRoommateRoll string   `json:"matched_roommate_roll"`
	MatchedRoommateName string   `json:"matched_roommate_name"`
	AssignedRoom        string   `json:"assigned_room"`
}

// RoommateSettingsRecord for Admin toggle of Self-Discovery vs Auto-Allocation
type RoommateSettingsRecord struct {
	IsSelfDiscoveryEnabled bool    `json:"is_self_discovery_enabled"`
	IsAutoAllocationActive bool    `json:"is_auto_allocation_active"`
	TotalQuizSubmissions   int     `json:"total_quiz_submissions"`
	MatchedPairsCount      int     `json:"matched_pairs_count"`
	AverageMatchScore      float64 `json:"average_match_score"`
}

// 2. DiningIntentGoRecord (Daily 6 PM Toggle)
type DiningIntentGoRecord struct {
	ID          string    `json:"id"`
	StudentRoll string    `json:"student_roll"`
	StudentName string    `json:"student_name"`
	Date        string    `json:"date"`
	MealType    string    `json:"meal_type"`
	Intent      string    `json:"intent"` // "ATTENDING", "SKIPPING", "OUT_PASS_AUTO_SKIPPED"
	UpdatedAt   time.Time `json:"updated_at"`
}

// MessForecastRecord (AI Predictive Mess Headcount & Food Waste Minimizer)
type MessForecastRecord struct {
	Date                   string  `json:"date"`
	MealType               string  `json:"meal_type"`
	TotalHostellers        int     `json:"total_hostellers"`
	ExpectedDiningCount    int     `json:"expected_dining_count"`
	GatePassOutCount       int     `json:"gate_pass_out_count"`
	VoluntarySkippingCount int     `json:"voluntary_skipping_count"`
	RecommendedRiceKg      float64 `json:"recommended_rice_kg"`
	BaselineRiceKg         float64 `json:"baseline_rice_kg"`
	FoodSavedKg            float64 `json:"food_saved_kg"`
	DailyRupeesSaved       float64 `json:"daily_rupees_saved"`
	AnnualProjectedSavings float64 `json:"annual_projected_savings"`
	ChefAlertMessage       string  `json:"chef_alert_message"`
}

// 3. SilentDuressRecord (Secret 9999 Panic PIN)
type SilentDuressRecord struct {
	ID                 string    `json:"id"`
	StudentRoll        string    `json:"student_roll"`
	StudentName        string    `json:"student_name"`
	RoomNumber         string    `json:"room_number"`
	BlockName          string    `json:"block_name"`
	SecretDuressPin    string    `json:"secret_duress_pin"`
	IsDuressTriggered  bool      `json:"is_duress_triggered"`
	GpsCoordinates     string    `json:"gps_coordinates"`
	TriggeredAt        time.Time `json:"triggered_at"`
	DispatchStatus     string    `json:"dispatch_status"`
}

// 4. RoomAssetRecord (AI Computer Vision Room Damage & Caution Deposit Audit)
type RoomAssetRecord struct {
	ID                string  `json:"id"`
	RoomNumber        string  `json:"room_number"`
	AssetName         string  `json:"asset_name"`
	CheckInDate       string  `json:"check_in_date"`
	CheckInCondition  string  `json:"check_in_condition"`
	CheckInSha256Hash string  `json:"check_in_sha256_hash"`
	CheckOutDate      string  `json:"check_out_date"`
	CheckOutCondition string  `json:"check_out_condition"`
	CheckOutHash      string  `json:"check_out_hash"`
	DamageScore       float64 `json:"damage_score"`
	CautionDeduction  float64 `json:"caution_deduction"`
	AuditStatus       string  `json:"audit_status"`
}

// 5. GreenDormEcoRecord (Green Dorm IoT Energy Quota & Eco-Credits Leaderboard)
type GreenDormEcoRecord struct {
	RoomNumber         string  `json:"room_number"`
	MonthlyQuotaUnits  float64 `json:"monthly_quota_units"`
	ConsumedUnits      float64 `json:"consumed_units"`
	RemainingUnits     float64 `json:"remaining_units"`
	LiveLoadWatts      float64 `json:"live_load_watts"`
	EcoCredits         int     `json:"eco_credits"`
	Co2SavedKg         float64 `json:"co2_saved_kg"`
	WingRank           string  `json:"wing_rank"`
	PerkReward         string  `json:"perk_reward"`
}

// 6. CurfewExtensionRecord (Curfew Auto-Extension with Parent WhatsApp 1-Click Consent)
type CurfewExtensionRecord struct {
	ID                        string    `json:"id"`
	GatePassID                string    `json:"gate_pass_id"`
	StudentRoll               string    `json:"student_roll"`
	StudentName               string    `json:"student_name"`
	RoomNumber                string    `json:"room_number"`
	OriginalCurfewTime        string    `json:"original_curfew_time"`
	RequestedExtensionMinutes int       `json:"requested_extension_minutes"`
	ExtendedCurfewTime        string    `json:"extended_curfew_time"`
	Reason                    string    `json:"reason"`
	ParentConsentStatus       string    `json:"parent_consent_status"` // "PENDING", "APPROVED", "REJECTED"
	ParentConsentTimestamp    time.Time `json:"parent_consent_timestamp"`
	WardenApprovalStatus      string    `json:"warden_approval_status"`
	IsFineWaived              bool      `json:"is_fine_waived"`
}

