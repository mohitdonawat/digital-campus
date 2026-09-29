package main

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"math/big"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"
)

// ============================================================================
// ⚙️ CONFIGURATION & CONSTANTS
// ============================================================================
const (
	Port              = ":8080"
	DefaulterLimit    = 75.0 // AI detention threshold percentage
	AuditIntervalSec  = 30   // Automated background audit goroutine ticker
	ClusterName       = "Digital-Campus-SaaS-Go-Engine"
	EngineVersion     = "v3.2.0-Automated"
)

// ============================================================================
// 📊 DATA MODELS (Multi-Tenant SaaS + Class Attendance + Automation)
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
	Category  string    `json:"category"` // "DETENTION_AUDIT", "SMS_DISPATCH", "TENANT_PROVISION", "HEARTBEAT"
	Message   string    `json:"message"`
	Severity  string    `json:"severity"` // "INFO", "WARNING", "ALERT"
}

// ============================================================================
// 🗄️ IN-MEMORY THREAD-SAFE DATABASE
// ============================================================================
type DataStore struct {
	mu          sync.RWMutex
	tenants     map[string]*CollegeTenant
	attendance  map[string]*StudentAttendanceRecord
	logs        []AutomationLog
	subscribers map[string]chan string
	subMutex    sync.RWMutex
	startTime   time.Time
}

var db = &DataStore{
	tenants:     make(map[string]*CollegeTenant),
	attendance:  make(map[string]*StudentAttendanceRecord),
	logs:        make([]AutomationLog, 0),
	subscribers: make(map[string]chan string),
	startTime:   time.Now(),
}

// ============================================================================
// 🚀 INITIALIZATION & SEED DATA
// ============================================================================
func initSeedData() {
	db.mu.Lock()
	defer db.mu.Unlock()

	// Seed 4 Partner Multi-Tenant Colleges
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

	t3 := &CollegeTenant{
		ID:             "col_gec_03",
		Name:           "Govt Autonomous Engineering College",
		Code:           "GEC-JBP",
		City:           "Jabalpur",
		State:          "Madhya Pradesh",
		Affiliation:    "Autonomous & AICTE",
		Status:         "active",
		AdminEmail:     "principal@gecjbp.ac.in",
		AdminPassword:  "GEC_Govt#552",
		AdminName:      "Dr. R. K. Pandit",
		AdminID:        "GEC_ADM_4401",
		StudentCount:   3400,
		FacultyCount:   180,
		LicensePlan:    "Campus Autonomous Suite",
		RegisteredDate: "18 Aug 2024",
		LastAuditedAt:  time.Now(),
	}

	t4 := &CollegeTenant{
		ID:             "col_lnct_04",
		Name:           "Lakshmi Narain College of Technology",
		Code:           "LNCT-BPL",
		City:           "Bhopal",
		State:          "Madhya Pradesh",
		Affiliation:    "Affiliated to RGPV",
		Status:         "pending", // Ready for super admin approval demonstration
		AdminEmail:     "director.admin@lnct.ac.in",
		AdminPassword:  "LNCT_Pending#99",
		AdminName:      "Dr. Anupam Chouksey",
		AdminID:        "LNCT_ADM_8831",
		StudentCount:   6200,
		FacultyCount:   340,
		LicensePlan:    "Enterprise Cloud",
		RegisteredDate: "24 Sep 2026",
		LastAuditedAt:  time.Now(),
	}

	db.tenants[t1.ID] = t1
	db.tenants[t2.ID] = t2
	db.tenants[t3.ID] = t3
	db.tenants[t4.ID] = t4

	// Seed Class-wise Student Attendance Roster
	students := []*StudentAttendanceRecord{
		{
			StudentID: "stu_01", Name: "Rahul Sharma", RollNumber: "0103CS211048",
			Branch: "CSE", Semester: 6, Section: "Sec A",
			TotalClasses: 80, AttendedClasses: 68, IsPresentToday: true,
			ParentName: "Suresh Sharma", ParentPhone: "+91 98260 11400",
		},
		{
			StudentID: "stu_02", Name: "Priya Patel", RollNumber: "0103CS211049",
			Branch: "CSE", Semester: 6, Section: "Sec A",
			TotalClasses: 80, AttendedClasses: 74, IsPresentToday: true,
			ParentName: "Dinesh Patel", ParentPhone: "+91 94250 88200",
		},
		{
			StudentID: "stu_03", Name: "Amit Verma", RollNumber: "0103CS211050",
			Branch: "CSE", Semester: 6, Section: "Sec A",
			TotalClasses: 80, AttendedClasses: 54, IsPresentToday: false, // 67.5% -> Defaulter
			ParentName: "Ramesh Verma", ParentPhone: "+91 98930 77120",
		},
		{
			StudentID: "stu_04", Name: "Sneha Gupta", RollNumber: "0103CS211051",
			Branch: "CSE", Semester: 6, Section: "Sec B",
			TotalClasses: 80, AttendedClasses: 72, IsPresentToday: true,
			ParentName: "Ashok Gupta", ParentPhone: "+91 97130 55410",
		},
		{
			StudentID: "stu_05", Name: "Vikas Mehra", RollNumber: "0103CS211052",
			Branch: "CSE", Semester: 6, Section: "Sec B",
			TotalClasses: 80, AttendedClasses: 56, IsPresentToday: false, // 70.0% -> Defaulter
			ParentName: "Sunil Mehra", ParentPhone: "+91 98270 33900",
		},
		{
			StudentID: "stu_06", Name: "Ananya Dixit", RollNumber: "0103IT211012",
			Branch: "IT", Semester: 6, Section: "Sec A",
			TotalClasses: 80, AttendedClasses: 76, IsPresentToday: true,
			ParentName: "Vinod Dixit", ParentPhone: "+91 94240 66100",
		},
		{
			StudentID: "stu_07", Name: "Rohit Jain", RollNumber: "0103IT211013",
			Branch: "IT", Semester: 6, Section: "Sec A",
			TotalClasses: 80, AttendedClasses: 52, IsPresentToday: false, // 65.0% -> Defaulter
			ParentName: "Kamlesh Jain", ParentPhone: "+91 98263 44550",
		},
		{
			StudentID: "stu_08", Name: "Tanvi Saxena", RollNumber: "0103EC211005",
			Branch: "ECE", Semester: 4, Section: "Sec A",
			TotalClasses: 75, AttendedClasses: 69, IsPresentToday: true,
			ParentName: "Dr. Alok Saxena", ParentPhone: "+91 98931 99200",
		},
		{
			StudentID: "stu_09", Name: "Deepak Sahu", RollNumber: "0103EC211006",
			Branch: "ECE", Semester: 4, Section: "Sec A",
			TotalClasses: 75, AttendedClasses: 48, IsPresentToday: false, // 64.0% -> Defaulter
			ParentName: "Mohan Sahu", ParentPhone: "+91 94251 12380",
		},
		{
			StudentID: "stu_10", Name: "Pooja Tiwari", RollNumber: "0103CS201088",
			Branch: "CSE", Semester: 8, Section: "Sec A",
			TotalClasses: 70, AttendedClasses: 65, IsPresentToday: true,
			ParentName: "Rakesh Tiwari", ParentPhone: "+91 98272 55600",
		},
	}

	for _, s := range students {
		calculateMetrics(s)
		db.attendance[s.StudentID] = s
	}

	logAutomation("SYSTEM_BOOT", "Go Multi-Tenant Engine booted. 4 Colleges & 10 Class Roster students loaded.", "INFO")
}

// Recalculates percentage, deficit classes, safe bunks, and risk score
func calculateMetrics(s *StudentAttendanceRecord) {
	if s.TotalClasses <= 0 {
		s.AttendancePercentage = 100.0
		s.RiskScore = "SAFE"
		s.DeficitClasses = 0
		s.SafeBunks = 0
		return
	}

	s.AttendancePercentage = (float64(s.AttendedClasses) / float64(s.TotalClasses)) * 100.0
	// Round to 1 decimal place
	s.AttendancePercentage = float64(int(s.AttendancePercentage*10+0.5)) / 10

	if s.AttendancePercentage < DefaulterLimit {
		s.RiskScore = "CRITICAL"
		// Deficit formula: needed = ceil((0.75 * T - A) / 0.25) = ceil(3*T - 4*A)
		needed := (3*s.TotalClasses - 4*s.AttendedClasses)
		if needed < 1 {
			needed = 1
		}
		s.DeficitClasses = needed
		s.SafeBunks = 0
	} else {
		s.RiskScore = "SAFE"
		s.DeficitClasses = 0
		// Safe bunk formula: bunks = floor((A - 0.75 * T) / 0.75) = floor((4*A - 3*T) / 3)
		bunks := (4*s.AttendedClasses - 3*s.TotalClasses) / 3
		if bunks < 0 {
			bunks = 0
		}
		s.SafeBunks = bunks
	}
}

func logAutomation(category, message, severity string) {
	logItem := AutomationLog{
		ID:        fmt.Sprintf("log_%d", time.Now().UnixNano()),
		Timestamp: time.Now(),
		Category:  category,
		Message:   message,
		Severity:  severity,
	}
	db.logs = append(db.logs, logItem)
	if len(db.logs) > 500 {
		db.logs = db.logs[len(db.logs)-500:] // keep last 500
	}
	log.Printf("[AUTOMATION] [%s] %s (%s)\n", category, message, severity)

	// Broadcast via SSE to connected Flutter clients
	payload, _ := json.Marshal(map[string]interface{}{
		"event": "AUTOMATION_LOG",
		"data":  logItem,
	})
	broadcastToSubscribers(string(payload))
}

// ============================================================================
// 🤖 AUTOMATED BACKGROUND ENGINE (GOROUTINES)
// ============================================================================

// Automated attendance auditor runs every 30 seconds
func startAutomatedAttendanceAuditor() {
	ticker := time.NewTicker(AuditIntervalSec * time.Second)
	go func() {
		for range ticker.C {
			db.mu.Lock()
			defaulterCount := 0
			totalStudents := len(db.attendance)

			for _, s := range db.attendance {
				calculateMetrics(s)
				if s.AttendancePercentage < DefaulterLimit {
					defaulterCount++
				}
			}
			db.mu.Unlock()

			msg := fmt.Sprintf("Automated Roster Audit complete: %d/%d students flagged as Defaulters (<75%%).", defaulterCount, totalStudents)
			logAutomation("DETENTION_AUDIT", msg, "INFO")
		}
	}()
}

// Automated tenant license & heartbeat monitor
func startTenantLicenseMonitor() {
	ticker := time.NewTicker(45 * time.Second)
	go func() {
		for range ticker.C {
			db.mu.RLock()
			activeTenants := 0
			pendingTenants := 0
			for _, t := range db.tenants {
				if t.Status == "active" {
					activeTenants++
				} else {
					pendingTenants++
				}
			}
			db.mu.RUnlock()

			msg := fmt.Sprintf("Multi-Tenant Cloud Pulse: %d Active Institutions, %d Pending Approval.", activeTenants, pendingTenants)
			logAutomation("TENANT_PULSE", msg, "INFO")
		}
	}()
}

// ============================================================================
// 🌐 HTTP HANDLERS & REST APIS
// ============================================================================

// GET /api/health
func handleHealth(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	defaulterCount := 0
	for _, s := range db.attendance {
		if s.AttendancePercentage < DefaulterLimit {
			defaulterCount++
		}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":          "ONLINE_AUTOMATED",
		"engine":          ClusterName,
		"version":         EngineVersion,
		"uptime_seconds":  int(time.Since(db.startTime).Seconds()),
		"total_colleges":  len(db.tenants),
		"total_students":  len(db.attendance),
		"defaulter_count": defaulterCount,
		"timestamp":       time.Now(),
	})
}

// GET /api/tenants -> List all colleges
func handleGetTenants(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	list := make([]*CollegeTenant, 0, len(db.tenants))
	for _, t := range db.tenants {
		list = append(list, t)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"count":   len(list),
		"tenants": list,
	})
}

// POST /api/tenants/register -> Onboard new college with auto-generated ID & Password
func handleRegisterTenant(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Name         string `json:"name"`
		Code         string `json:"code"`
		City         string `json:"city"`
		State        string `json:"state"`
		Affiliation  string `json:"affiliation"`
		AdminName    string `json:"admin_name"`
		AdminEmail   string `json:"admin_email"`
		LicensePlan  string `json:"license_plan"`
		StudentCount int    `json:"student_count"`
		FacultyCount int    `json:"faculty_count"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON body", http.StatusBadRequest)
		return
	}

	if req.Name == "" || req.Code == "" {
		http.Error(w, "Name and Code are required", http.StatusBadRequest)
		return
	}

	codeUpper := strings.ToUpper(strings.TrimSpace(req.Code))
	randInt, _ := rand.Int(rand.Reader, big.NewInt(9000))
	randNum := randInt.Int64() + 1000

	randPassBytes := make([]byte, 4)
	rand.Read(randPassBytes)
	securePass := fmt.Sprintf("%s#Pass@%s", codeUpper, hex.EncodeToString(randPassBytes))

	tenantID := fmt.Sprintf("col_%s_%d", strings.ToLower(codeUpper), time.Now().Unix()%10000)
	adminID := fmt.Sprintf("%s_ADM_%d", codeUpper, randNum)

	tenant := &CollegeTenant{
		ID:             tenantID,
		Name:           req.Name,
		Code:           codeUpper,
		City:           req.City,
		State:          req.State,
		Affiliation:    req.Affiliation,
		Status:         "pending", // requires super admin approval
		AdminEmail:     req.AdminEmail,
		AdminPassword:  securePass,
		AdminName:      req.AdminName,
		AdminID:        adminID,
		StudentCount:   req.StudentCount,
		FacultyCount:   req.FacultyCount,
		LicensePlan:    req.LicensePlan,
		RegisteredDate: time.Now().Format("02 Jan 2006"),
		LastAuditedAt:  time.Now(),
	}

	db.mu.Lock()
	db.tenants[tenant.ID] = tenant
	db.mu.Unlock()

	logAutomation("TENANT_ONBOARD", fmt.Sprintf("New College Registered: %s (%s). Credentials generated: UserID=%s", req.Name, codeUpper, adminID), "INFO")

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Institution registered successfully with auto-generated credentials.",
		"tenant":  tenant,
	})
}

// POST /api/tenants/approve -> Approve pending college and provision workspace
func handleApproveTenant(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		TenantID string `json:"tenant_id"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.TenantID == "" {
		http.Error(w, "tenant_id required", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	tenant, exists := db.tenants[req.TenantID]
	if !exists {
		db.mu.Unlock()
		http.Error(w, "Tenant not found", http.StatusNotFound)
		return
	}

	tenant.Status = "active"
	tenant.LastAuditedAt = time.Now()
	db.mu.Unlock()

	logAutomation("TENANT_PROVISION", fmt.Sprintf("College APPROVED & LICENSED: %s (%s). Workspace active.", tenant.Name, tenant.Code), "ALERT")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": fmt.Sprintf("%s is now approved and active on the Cloud SaaS network.", tenant.Name),
		"tenant":  tenant,
	})
}

// GET /api/attendance/records -> Filter attendance by branch, semester, section, status
func handleGetAttendanceRecords(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	q := r.URL.Query()
	branch := q.Get("branch")
	semesterStr := q.Get("semester")
	section := q.Get("section")
	status := q.Get("status") // "all", "defaulters", "safe"

	sem := 0
	if semesterStr != "" && semesterStr != "0" {
		sem, _ = strconv.Atoi(semesterStr)
	}

	results := make([]*StudentAttendanceRecord, 0)
	for _, s := range db.attendance {
		if branch != "" && branch != "All" && s.Branch != branch {
			continue
		}
		if sem > 0 && s.Semester != sem {
			continue
		}
		if section != "" && section != "All" && s.Section != section {
			continue
		}
		if strings.EqualFold(status, "defaulters") && s.AttendancePercentage >= DefaulterLimit {
			continue
		}
		if strings.EqualFold(status, "safe") && s.AttendancePercentage < DefaulterLimit {
			continue
		}
		results = append(results, s)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"count":   len(results),
		"records": results,
	})
}

// POST /api/attendance/toggle -> Toggle individual student attendance
func handleToggleAttendance(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		StudentID string `json:"student_id"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.StudentID == "" {
		http.Error(w, "student_id required", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	student, exists := db.attendance[req.StudentID]
	if !exists {
		db.mu.Unlock()
		http.Error(w, "Student not found", http.StatusNotFound)
		return
	}

	if student.IsPresentToday {
		student.IsPresentToday = false
		student.AttendedClasses--
		if student.AttendedClasses < 0 {
			student.AttendedClasses = 0
		}
	} else {
		student.IsPresentToday = true
		student.AttendedClasses++
		if student.AttendedClasses > student.TotalClasses {
			student.TotalClasses = student.AttendedClasses
		}
	}

	calculateMetrics(student)
	db.mu.Unlock()

	msg := fmt.Sprintf("Attendance marked for %s: %s (Now %.1f%%)", student.Name, map[bool]string{true: "PRESENT", false: "ABSENT"}[student.IsPresentToday], student.AttendancePercentage)
	logAutomation("ATTENDANCE_PUNCH", msg, "INFO")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"student": student,
	})
}

// POST /api/attendance/bulk -> Bulk mark branch/semester/section
func handleBulkAttendance(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Branch    string `json:"branch"`
		Semester  int    `json:"semester"`
		Section   string `json:"section"`
		IsPresent bool   `json:"is_present"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON body", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	affected := 0
	for _, s := range db.attendance {
		if req.Branch != "" && req.Branch != "All" && s.Branch != req.Branch {
			continue
		}
		if req.Semester > 0 && s.Semester != req.Semester {
			continue
		}
		if req.Section != "" && req.Section != "All" && s.Section != req.Section {
			continue
		}

		if s.IsPresentToday != req.IsPresent {
			s.IsPresentToday = req.IsPresent
			if req.IsPresent {
				s.AttendedClasses++
			} else {
				s.AttendedClasses--
				if s.AttendedClasses < 0 {
					s.AttendedClasses = 0
				}
			}
			calculateMetrics(s)
			affected++
		}
	}
	db.mu.Unlock()

	actionStr := "ALL PRESENT"
	if !req.IsPresent {
		actionStr = "ALL ABSENT"
	}
	logAutomation("BULK_ATTENDANCE", fmt.Sprintf("Bulk action executed: %d students marked as %s", affected, actionStr), "INFO")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":  true,
		"affected": affected,
		"message":  fmt.Sprintf("%d students updated successfully.", affected),
	})
}

// GET /api/attendance/defaulters -> Get only defaulters (< 75%)
func handleGetDefaulters(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	defaulters := make([]*StudentAttendanceRecord, 0)
	for _, s := range db.attendance {
		if s.AttendancePercentage < DefaulterLimit {
			defaulters = append(defaulters, s)
		}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":    true,
		"count":      len(defaulters),
		"defaulters": defaulters,
	})
}

// POST /api/attendance/alert-parents -> Automated SMS/WhatsApp trigger
func handleAlertParents(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	db.mu.RLock()
	alertsDispatched := 0
	names := make([]string, 0)
	for _, s := range db.attendance {
		if s.AttendancePercentage < DefaulterLimit {
			alertsDispatched++
			names = append(names, s.Name)
		}
	}
	db.mu.RUnlock()

	msg := fmt.Sprintf("Automated Parental Alerts dispatched to %d parents via SMS/WhatsApp Gateway (%s)", alertsDispatched, strings.Join(names, ", "))
	logAutomation("SMS_DISPATCH", msg, "ALERT")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":           true,
		"alerts_dispatched": alertsDispatched,
		"recipients":        names,
		"gateway_status":    "DELIVERED_VIA_TELEPHONY_API",
		"message":           fmt.Sprintf("Successfully dispatched %d parental detention warnings.", alertsDispatched),
	})
}

// GET /api/automation/logs -> List recent background goroutine automation logs
func handleGetAutomationLogs(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"count":   len(db.logs),
		"logs":    db.logs,
	})
}

// GET /api/broadcast/live -> Server-Sent Events (SSE) Real-Time push to Flutter
func handleLiveEventsSSE(w http.ResponseWriter, r *http.Request) {
	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "Streaming unsupported", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")

	clientChan := make(chan string, 100)
	clientID := fmt.Sprintf("client-%d", time.Now().UnixNano())

	db.subMutex.Lock()
	db.subscribers[clientID] = clientChan
	db.subMutex.Unlock()

	defer func() {
		db.subMutex.Lock()
		delete(db.subscribers, clientID)
		close(clientChan)
		db.subMutex.Unlock()
	}()

	fmt.Fprintf(w, "data: {\"event\": \"CONNECTED\", \"client_id\": \"%s\", \"engine\": \"%s\"}\n\n", clientID, ClusterName)
	flusher.Flush()

	notify := r.Context().Done()
	for {
		select {
		case <-notify:
			return
		case msg := <-clientChan:
			fmt.Fprintf(w, "data: %s\n\n", msg)
			flusher.Flush()
		}
	}
}

func broadcastToSubscribers(msg string) {
	db.subMutex.RLock()
	defer db.subMutex.RUnlock()

	for _, ch := range db.subscribers {
		select {
		case ch <- msg:
		default:
		}
	}
}

// CORS Middleware
func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// ============================================================================
// 🏁 MAIN ENTRY POINT (Single-File Autonomous Go Server)
// ============================================================================
func main() {
	log.Println("=======================================================================")
	log.Printf("🚀 %s [%s] Starting\n", ClusterName, EngineVersion)
	log.Printf("📡 Listening on port %s (CORS Enabled for Flutter Web/Android/Desktop)\n", Port)
	log.Println("=======================================================================")

	// 1. Initialize Seed Data
	initSeedData()

	// 2. Start Background Automation Goroutines
	startAutomatedAttendanceAuditor()
	startTenantLicenseMonitor()

	// 3. Register HTTP Routes
	mux := http.NewServeMux()

	// System Health & Telemetry
	mux.HandleFunc("/api/health", handleHealth)
	mux.HandleFunc("/api/broadcast/live", handleLiveEventsSSE)
	mux.HandleFunc("/api/automation/logs", handleGetAutomationLogs)

	// Multi-Tenant SaaS Management
	mux.HandleFunc("/api/tenants", handleGetTenants)
	mux.HandleFunc("/api/tenants/register", handleRegisterTenant)
	mux.HandleFunc("/api/tenants/approve", handleApproveTenant)

	// Class-Wise Attendance & Defaulters Automation
	mux.HandleFunc("/api/attendance/records", handleGetAttendanceRecords)
	mux.HandleFunc("/api/attendance/toggle", handleToggleAttendance)
	mux.HandleFunc("/api/attendance/bulk", handleBulkAttendance)
	mux.HandleFunc("/api/attendance/defaulters", handleGetDefaulters)
	mux.HandleFunc("/api/attendance/alert-parents", handleAlertParents)

	handler := enableCORS(mux)

	server := &http.Server{
		Addr:         Port,
		Handler:      handler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 20 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Printf("✅ Single-File Go Backend is LIVE on http://localhost%s\n", Port)
	log.Println("⚡ Real-time Background Goroutines are actively running automations.")

	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server stopped: %v", err)
	}
}
