package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"time"
)

// ============================================================================
// ⚙️ CONFIGURATION & CONSTANTS
// ============================================================================
const (
	Port             = ":8080"
	DefaulterLimit   = 75.0 // AI detention threshold percentage
	AuditIntervalSec = 30   // Automated background audit goroutine ticker
	ClusterName      = "Digital-Campus-SaaS-Go-Engine"
	EngineVersion    = "v3.5.0-Enterprise-Modular"
)

// ============================================================================
// 🏁 MAIN ENTRY POINT (Clean Modular Go Backend Server)
// ============================================================================
func main() {
	log.Println("=======================================================================")
	log.Printf("🚀 %s [%s] Starting\n", ClusterName, EngineVersion)
	log.Printf("📡 Listening on port %s (CORS Enabled for Flutter Mobile/Web/Desktop)\n", Port)
	log.Println("=======================================================================")

	// 1. Initialize Seed Data
	initSeedData()

	// 2. Start Background Autonomous Goroutines
	startAutomatedAttendanceAuditor()
	startTenantLicenseMonitor()
	startCurfewWatchdogGoroutine()

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

	// 🏨 Smart Hostel & Biometric Residence Engine (StarRez USA, Cloudbeds, IIT/BITS)
	mux.HandleFunc("/api/hostel/overview", handleHostelOverview)
	mux.HandleFunc("/api/hostel/gatepasses", handleHostelGatePasses)
	mux.HandleFunc("/api/hostel/gatepass/apply", handleApplyHostelGatePass)
	mux.HandleFunc("/api/hostel/gatepass/approve", handleApproveHostelGatePass)
	mux.HandleFunc("/api/hostel/turnstile/scan", handleTurnstileScan)
	mux.HandleFunc("/api/hostel/curfew/breaches", handleCurfewBreaches)
	mux.HandleFunc("/api/hostel/maintenance", handleHostelMaintenance)
	mux.HandleFunc("/api/hostel/maintenance/create", handleCreateHostelMaintenance)
	mux.HandleFunc("/api/hostel/maintenance/resolve", handleResolveHostelMaintenance)
	mux.HandleFunc("/api/hostel/mess/rate", handleMessRate)
	mux.HandleFunc("/api/hostel/mess/rebate", handleMessRebate)
	mux.HandleFunc("/api/hostel/room-swap", handleRoomSwap)
	mux.HandleFunc("/api/hostel/facilities", handleFacilities)
	mux.HandleFunc("/api/hostel/facility/book", handleBookFacility)
	mux.HandleFunc("/api/hostel/sos/trigger", handleEmergencySos)
	mux.HandleFunc("/api/hostel/sos/resolve", handleEmergencySos)
	mux.HandleFunc("/api/hostel/energy", handleEnergyMeter)
	mux.HandleFunc("/api/hostel/policy", handleHostelPolicy)

	// 🚀 6 Ultra-Smart Innovation Endpoints
	mux.HandleFunc("/api/hostel/roommate/quiz", handleRoommateQuiz)
	mux.HandleFunc("/api/hostel/roommate/match", handleRoommateMatch)
	mux.HandleFunc("/api/hostel/roommate/settings", handleRoommateSettings)
	mux.HandleFunc("/api/hostel/mess/dining-intent", handleDiningIntent)
	mux.HandleFunc("/api/hostel/mess/food-waste-forecast", handleMessForecast)
	mux.HandleFunc("/api/hostel/duress/alarm", handleSilentDuress)
	mux.HandleFunc("/api/hostel/assets/inspect", handleRoomAssetInspection)
	mux.HandleFunc("/api/hostel/energy/eco-leaderboard", handleGreenDormEco)
	mux.HandleFunc("/api/hostel/curfew/extension", handleCurfewExtension)
	mux.HandleFunc("/api/hostel/curfew/extension/parent-consent", handleCurfewParentConsent)

	// Reverse-Proxy to Python AI, Vision OCR & Socratic Teaching Engine (:8000)
	pythonTarget, err := url.Parse("http://localhost:8000")
	if err == nil {
		pyProxy := httputil.NewSingleHostReverseProxy(pythonTarget)
		mux.Handle("/api/vision/", pyProxy)
		mux.Handle("/api/tutor/", pyProxy)
		mux.Handle("/api/classroom/", pyProxy)
		mux.Handle("/api/redis/", pyProxy)
	}

	handler := enableCORS(mux)

	server := &http.Server{
		Addr:         Port,
		Handler:      handler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 20 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Printf("✅ Modular Go Backend is LIVE on http://localhost%s\n", Port)
	log.Println("⚡ Real-time Background Goroutines are actively monitoring curfews & audits.")

	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server stopped: %v", err)
	}
}
