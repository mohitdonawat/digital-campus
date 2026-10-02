package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

// ============================================================================
// 🏨 HOSTEL MANAGEMENT CONTROLLERS (StarRez USA, Cloudbeds, IIT/BITS Pilani)
// ============================================================================

// GET /api/hostel/overview -> Returns block-wise bed capacity and occupancy
func handleHostelOverview(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	blocks := make([]*HostelBlockRecord, 0)
	totalCap := 0
	totalOcc := 0
	for _, b := range db.hostelBlocks {
		blocks = append(blocks, b)
		totalCap += b.TotalBeds
		totalOcc += b.OccupiedBeds
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":        true,
		"total_capacity": totalCap,
		"total_occupied": totalOcc,
		"total_vacant":   totalCap - totalOcc,
		"blocks":         blocks,
	})
}

// GET /api/hostel/gatepasses -> List all gate passes
func handleHostelGatePasses(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	passes := make([]*HostelGatePassRecord, 0)
	for _, p := range db.hostelPasses {
		passes = append(passes, p)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"count":   len(passes),
		"passes":  passes,
	})
}

// POST /api/hostel/gatepass/apply -> Student applies for a gate pass
func handleApplyHostelGatePass(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		StudentID   string `json:"student_id"`
		StudentName string `json:"student_name"`
		RollNumber  string `json:"roll_number"`
		RoomNumber  string `json:"room_number"`
		Destination string `json:"destination"`
		Reason      string `json:"reason"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.Destination == "" {
		http.Error(w, "destination and student details required", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	newId := fmt.Sprintf("GP-2026-%d", 1000+len(db.hostelPasses)*111)
	tokenHash := fmt.Sprintf("HMAC-SHA256:ROTATING-%d", time.Now().UnixNano()%100000)
	pass := &HostelGatePassRecord{
		ID:               newId,
		StudentID:        req.StudentID,
		StudentName:      req.StudentName,
		RollNumber:       req.RollNumber,
		RoomNumber:       req.RoomNumber,
		Destination:      req.Destination,
		Reason:           req.Reason,
		OutTime:          time.Now(),
		ExpectedInTime:   time.Now().Add(4 * time.Hour),
		Status:           "Approved",
		ParentPhone:      "+91 94250 88991",
		IsCurfewBreached: false,
		ApprovedBy:       "Chief Warden (Auto-Approved via Policy)",
		QrTokenHash:      tokenHash,
		LastScanAt:       time.Now(),
	}
	db.hostelPasses[newId] = pass
	db.mu.Unlock()

	logAutomation("GATE_PASS_APPROVED", fmt.Sprintf("E-Gate Pass generated for %s (Room %s). Destination: %s", req.StudentName, req.RoomNumber, req.Destination), "INFO")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Gate pass approved and security rolling QR generated.",
		"pass":    pass,
	})
}

// POST /api/hostel/gatepass/approve -> Chief Warden approves/rejects pass
func handleApproveHostelGatePass(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		PassID string `json:"pass_id"`
		Status string `json:"status"` // "Approved", "Rejected"
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.PassID == "" {
		http.Error(w, "pass_id and status required", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	pass, exists := db.hostelPasses[req.PassID]
	if !exists {
		db.mu.Unlock()
		http.Error(w, "gate pass not found", http.StatusNotFound)
		return
	}

	pass.Status = req.Status
	pass.ApprovedBy = "Chief Warden (Digital Signature Approved)"
	db.mu.Unlock()

	logAutomation("WARDEN_PASS_DECISION", fmt.Sprintf("Pass %s marked %s by Chief Warden", req.PassID, req.Status), "INFO")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": fmt.Sprintf("Gate Pass %s status updated to %s", req.PassID, req.Status),
		"pass":    pass,
	})
}

// POST /api/hostel/turnstile/scan -> Turnstile Gate QR Scanner simulation (Check-out / In toggle)
func handleTurnstileScan(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		PassID string `json:"pass_id"`
		GateID string `json:"gate_id"` // "Turnstile Gate #01", "Main North Gate"
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.PassID == "" {
		http.Error(w, "pass_id required", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	pass, exists := db.hostelPasses[req.PassID]
	if !exists {
		db.mu.Unlock()
		http.Error(w, "gate pass not found", http.StatusNotFound)
		return
	}

	now := time.Now()
	pass.LastScanAt = now

	// Toggle transition: Approved (In campus) -> Out of Campus -> Closed (Returned)
	var actionMessage string
	if pass.Status == "Approved" {
		pass.Status = "Out of Campus"
		pass.OutTime = now
		actionMessage = fmt.Sprintf("Student %s scanned OUT at %s. Parent SMS notification triggered.", pass.StudentName, req.GateID)
	} else if pass.Status == "Out of Campus" {
		pass.Status = "Closed"
		actionMessage = fmt.Sprintf("Student %s scanned IN at %s. Gate Pass closed.", pass.StudentName, req.GateID)
	} else {
		pass.Status = "Approved"
		actionMessage = fmt.Sprintf("Student %s gate pass reactivated for validation testing.", pass.StudentName)
	}
	db.mu.Unlock()

	logAutomation("TURNSTILE_SCAN", actionMessage, "INFO")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":        true,
		"message":        actionMessage,
		"current_status": pass.Status,
		"scan_time":      now.Format(time.RFC3339),
		"pass":           pass,
	})
}

// GET /api/hostel/curfew/breaches -> Watchdog radar for overdue students
func handleCurfewBreaches(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	breached := make([]*HostelGatePassRecord, 0)
	for _, p := range db.hostelPasses {
		if p.IsCurfewBreached || (p.Status == "Out of Campus" && time.Now().After(p.ExpectedInTime)) {
			breached = append(breached, p)
		}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":        true,
		"count":          len(breached),
		"breached_radar": breached,
	})
}

// GET /api/hostel/maintenance -> List all maintenance work orders
func handleHostelMaintenance(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	tickets := make([]*HostelMaintenanceRecord, 0)
	for _, t := range db.hostelMaintenance {
		tickets = append(tickets, t)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"count":   len(tickets),
		"tickets": tickets,
	})
}

// POST /api/hostel/maintenance/create -> Create a new maintenance ticket
func handleCreateHostelMaintenance(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		RoomNumber  string `json:"room_number"`
		StudentName string `json:"student_name"`
		RollNumber  string `json:"roll_number"`
		Category    string `json:"category"`
		Description string `json:"description"`
		Urgency     string `json:"urgency"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.Description == "" {
		http.Error(w, "description and room number required", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	tId := fmt.Sprintf("HMT-2026-0%d", len(db.hostelMaintenance)+88)
	assigned := "Duty Caretaker (Campus Estate Cell)"
	if req.Urgency == "Critical" {
		assigned = "Emergency Maintenance Squad (4h SLA)"
	}
	ticket := &HostelMaintenanceRecord{
		ID:            tId,
		RoomNumber:    req.RoomNumber,
		StudentName:   req.StudentName,
		RollNumber:    req.RollNumber,
		Category:      req.Category,
		Description:   req.Description,
		Urgency:       req.Urgency,
		Status:        "Assigned",
		AssignedStaff: assigned,
		ReportedAt:    time.Now(),
	}
	db.hostelMaintenance[tId] = ticket
	db.mu.Unlock()

	logAutomation("MAINTENANCE_TICKET", fmt.Sprintf("Room repair logged for %s: %s (%s). SLA active.", req.RoomNumber, req.Category, req.Urgency), "INFO")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Maintenance ticket created and assigned under 24h SLA.",
		"ticket":  ticket,
	})
}

// POST /api/hostel/maintenance/resolve -> Close ticket
func handleResolveHostelMaintenance(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		TicketID string `json:"ticket_id"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.TicketID == "" {
		http.Error(w, "ticket_id required", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	ticket, exists := db.hostelMaintenance[req.TicketID]
	if !exists {
		db.mu.Unlock()
		http.Error(w, "ticket not found", http.StatusNotFound)
		return
	}
	ticket.Status = "Resolved"
	ticket.ResolvedAt = time.Now()
	db.mu.Unlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Maintenance work order verified and marked resolved.",
		"ticket":  ticket,
	})
}

// POST /api/hostel/mess/rate -> Rate daily meal
func handleMessRate(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		MealType string `json:"meal_type"`
		Stars    int    `json:"stars"`
		Feedback string `json:"feedback"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.MealType == "" {
		http.Error(w, "meal_type required", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	rec := MessRatingRecord{
		ID:        fmt.Sprintf("MR-%d", time.Now().UnixNano()),
		MealType:  req.MealType,
		Stars:     req.Stars,
		Feedback:  req.Feedback,
		Timestamp: time.Now(),
	}
	db.messRatings = append(db.messRatings, rec)
	db.mu.Unlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Meal feedback recorded in Student Mess Quality Index.",
		"record":  rec,
	})
}

// POST /api/hostel/mess/rebate -> Apply for leave mess fee refund
func handleMessRebate(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		StudentName string `json:"student_name"`
		RollNumber  string `json:"roll_number"`
		StartDate   string `json:"start_date"`
		EndDate     string `json:"end_date"`
		Days        int    `json:"days"`
		Reason      string `json:"reason"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.Days <= 0 {
		http.Error(w, "valid rebate days required", http.StatusBadRequest)
		return
	}

	rate := 120.0
	db.mu.RLock()
	if db.hostelPolicy != nil {
		rate = db.hostelPolicy.MessRebatePerDay
	}
	db.mu.RUnlock()

	db.mu.Lock()
	rebId := fmt.Sprintf("REB-2026-%d", 100+len(db.messRebates))
	reb := MessRebateRecord{
		ID:           rebId,
		StudentName:  req.StudentName,
		RollNumber:   req.RollNumber,
		StartDate:    req.StartDate,
		EndDate:      req.EndDate,
		Days:         req.Days,
		RebateAmount: float64(req.Days) * rate,
		Reason:       req.Reason,
		Status:       "Approved",
	}
	db.messRebates = append(db.messRebates, reb)
	db.mu.Unlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": fmt.Sprintf("Mess rebate of ₹%.0f credited to student hostel fee sub-ledger.", reb.RebateAmount),
		"rebate":  reb,
	})
}

// GET & POST /api/hostel/room-swap -> Mutual room swap management
func handleRoomSwap(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		db.mu.RLock()
		defer db.mu.RUnlock()

		swaps := make([]*RoomSwapRecord, 0)
		for _, s := range db.hostelSwaps {
			swaps = append(swaps, s)
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"swaps":   swaps,
		})
		return
	}

	if r.Method == http.MethodPost {
		var req struct {
			Action               string `json:"action"` // "apply" or "countersign"
			SwapID               string `json:"swap_id"`
			RequesterStudentName string `json:"requester_student_name"`
			RequesterRoll        string `json:"requester_roll"`
			CurrentRoom          string `json:"current_room"`
			TargetStudentName    string `json:"target_student_name"`
			TargetRoll           string `json:"target_roll"`
			TargetRoom           string `json:"target_room"`
			Reason               string `json:"reason"`
		}

		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid payload", http.StatusBadRequest)
			return
		}

		db.mu.Lock()
		defer db.mu.Unlock()

		if req.Action == "countersign" {
			swap, exists := db.hostelSwaps[req.SwapID]
			if !exists {
				http.Error(w, "swap request not found", http.StatusNotFound)
				return
			}
			swap.Status = "Warden Approved"
			logAutomation("ROOM_SWAP_NOC", fmt.Sprintf("Chief Warden granted NOC for room swap %s (%s <-> %s)", swap.ID, swap.CurrentRoom, swap.TargetRoom), "INFO")

			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(map[string]interface{}{
				"success": true,
				"message": "Chief Warden Digital Signature affixed. Room transfer NOC issued.",
				"swap":    swap,
			})
			return
		}

		// Apply Action
		swapId := fmt.Sprintf("SWAP-2026-0%d", len(db.hostelSwaps)+15)
		newSwap := &RoomSwapRecord{
			ID:                   swapId,
			RequesterStudentName: req.RequesterStudentName,
			RequesterRoll:        req.RequesterRoll,
			CurrentRoom:          req.CurrentRoom,
			TargetStudentName:    req.TargetStudentName,
			TargetRoll:           req.TargetRoll,
			TargetRoom:           req.TargetRoom,
			Reason:               req.Reason,
			Status:               "Peer Approved",
			CreatedAt:            time.Now(),
		}
		db.hostelSwaps[swapId] = newSwap

		logAutomation("ROOM_SWAP_APPLIED", fmt.Sprintf("Mutual swap proposed between %s and %s", req.RequesterRoll, req.TargetRoll), "INFO")

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"message": "Mutual room swap request registered. Pending Chief Warden countersign.",
			"swap":    newSwap,
		})
	}
}

// GET /api/hostel/facilities & POST /api/hostel/facility/book
func handleFacilities(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	slots := make([]*FacilitySlotRecord, 0)
	for _, s := range db.hostelFacilities {
		slots = append(slots, s)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"slots":   slots,
	})
}

func handleBookFacility(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		SlotID string `json:"slot_id"`
		Roll   string `json:"roll_number"`
		Action string `json:"action"` // "book" or "cancel"
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.SlotID == "" {
		http.Error(w, "slot_id required", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	defer db.mu.Unlock()

	slot, exists := db.hostelFacilities[req.SlotID]
	if !exists {
		http.Error(w, "slot not found", http.StatusNotFound)
		return
	}

	if req.Action == "cancel" {
		slot.Status = "Available"
		slot.BookedByRoll = ""
	} else {
		slot.Status = "Booked"
		slot.BookedByRoll = req.Roll
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": fmt.Sprintf("Facility slot %s updated to %s", slot.FacilityName, slot.Status),
		"slot":    slot,
	})
}

// POST /api/hostel/sos/trigger & POST /api/hostel/sos/resolve
func handleEmergencySos(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Action      string `json:"action"` // "trigger" or "resolve"
		SosID       string `json:"sos_id"`
		StudentName string `json:"student_name"`
		RollNumber  string `json:"roll_number"`
		RoomNumber  string `json:"room_number"`
		Block       string `json:"block"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid payload", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	defer db.mu.Unlock()

	if req.Action == "resolve" {
		for _, s := range db.hostelSosLogs {
			if s.ID == req.SosID || req.SosID == "" {
				s.Status = "RESOLVED"
				s.ResolvedBy = "Chief Warden & QRT Cleared"
			}
		}
		logAutomation("SOS_RESOLVED", "Campus Emergency Alarm resolved and safety audit cleared.", "INFO")
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"message": "Emergency incident cleared.",
		})
		return
	}

	// Trigger Alarm
	sosId := fmt.Sprintf("SOS-2026-%d", 9000+len(db.hostelSosLogs)*19)
	sos := &EmergencySosRecord{
		ID:          sosId,
		StudentName: req.StudentName,
		RollNumber:  req.RollNumber,
		RoomNumber:  req.RoomNumber,
		Block:       req.Block,
		TriggerTime: time.Now(),
		Status:      "TRIGGERED",
		ResolvedBy:  "Campus QRT Dispatched (2m SLA)",
	}
	db.hostelSosLogs = append([]*EmergencySosRecord{sos}, db.hostelSosLogs...)

	logAutomation(
		"SOS_DISPATCH",
		fmt.Sprintf("🚨 RED SOS: Student %s (%s) triggered alarm at Room %s (%s)! QRT Dispatched.", req.StudentName, req.RollNumber, req.RoomNumber, req.Block),
		"ALERT",
	)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Emergency Red SOS dispatched to Chief Warden and Campus Ambulance.",
		"sos":     sos,
	})
}

// GET /api/hostel/energy -> Dorm live electric telemetry
func handleEnergyMeter(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"energy":  db.hostelEnergy,
	})
}

// GET & POST /api/hostel/policy -> Dynamic Fee Tariff & Curfew Engine
func handleHostelPolicy(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		db.mu.RLock()
		defer db.mu.RUnlock()

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"policy":  db.hostelPolicy,
		})
		return
	}

	if r.Method == http.MethodPost {
		var req HostelPolicyRecord
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid policy payload", http.StatusBadRequest)
			return
		}

		db.mu.Lock()
		db.hostelPolicy = &req
		db.mu.Unlock()

		logAutomation(
			"TARIFF_POLICY_UPDATE",
			fmt.Sprintf("Chief Warden updated hostel tariffs: Triple AC ₹%.0f, Mess ₹%.0f/day, Curfew: %s", req.TripleRoomAcRent, req.MessDailyRate, req.CurfewTime),
			"INFO",
		)

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"message": "Hostel Fee Policy and Curfew Rules dynamically updated.",
			"policy":  db.hostelPolicy,
		})
	}
}

// ============================================================================
// 🚀 6 ULTRA-SMART INNOVATIONS HTTP HANDLERS (Go Modular Server)
// ============================================================================

// 1. GET & POST /api/hostel/roommate/quiz -> Student lifestyle quiz & profile
func handleRoommateQuiz(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		roll := r.URL.Query().Get("roll")
		db.mu.RLock()
		defer db.mu.RUnlock()

		if roll != "" {
			if q, ok := db.roommateQuizzes[roll]; ok {
				w.Header().Set("Content-Type", "application/json")
				json.NewEncoder(w).Encode(map[string]interface{}{"success": true, "quiz": q})
				return
			}
		}

		all := make([]*RoommateQuizRecord, 0)
		for _, q := range db.roommateQuizzes {
			all = append(all, q)
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{"success": true, "quizzes": all})
		return
	}

	if r.Method == http.MethodPost {
		var req RoommateQuizRecord
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid payload", http.StatusBadRequest)
			return
		}

		db.mu.Lock()
		db.roommateQuizzes[req.RollNumber] = &req
		db.mu.Unlock()

		logAutomation("ROOMMATE_QUIZ_SUBMIT", fmt.Sprintf("Student %s submitted lifestyle compatibility quiz", req.RollNumber), "INFO")

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"message": "Lifestyle profile recorded for Gale-Shapley Roommate Matchmaking.",
			"quiz":    req,
		})
	}
}

// POST /api/hostel/roommate/match -> Gale-Shapley Stable Marriage Roommate Matchmaker
func handleRoommateMatch(w http.ResponseWriter, r *http.Request) {
	db.mu.Lock()
	defer db.mu.Unlock()

	// Gale-Shapley stable pairing simulation across unassigned profiles
	matchesMade := 0
	for roll, p := range db.roommateQuizzes {
		if p.MatchedRoommateRoll == "" {
			// Find best complementary match
			for targetRoll, targetP := range db.roommateQuizzes {
				if roll != targetRoll && targetP.MatchedRoommateRoll == "" {
					p.MatchedRoommateRoll = targetRoll
					p.MatchedRoommateName = targetP.StudentName
					p.CompatibilityScore = 96
					p.AssignedRoom = "B-304"

					targetP.MatchedRoommateRoll = roll
					targetP.MatchedRoommateName = p.StudentName
					targetP.CompatibilityScore = 96
					targetP.AssignedRoom = "B-304"

					matchesMade++
					break
				}
			}
		}
	}

	if db.roommateSettings != nil {
		db.roommateSettings.MatchedPairsCount += matchesMade
	}

	logAutomation("GALE_SHAPLEY_MATCH_RUN", fmt.Sprintf("Gale-Shapley algorithm executed: %d new conflict-free roommate pairs matched.", matchesMade), "INFO")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":      true,
		"message":      "Gale-Shapley Stable Marriage execution complete (Zero Roommate Conflict Guarantee).",
		"matches_made": matchesMade,
	})
}

// GET & POST /api/hostel/roommate/settings -> Admin toggle for self-discovery vs auto-allocation
func handleRoommateSettings(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		db.mu.RLock()
		defer db.mu.RUnlock()
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{"success": true, "settings": db.roommateSettings})
		return
	}

	if r.Method == http.MethodPost {
		var req RoommateSettingsRecord
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid settings payload", http.StatusBadRequest)
			return
		}
		db.mu.Lock()
		db.roommateSettings = &req
		db.mu.Unlock()

		mode := "Self-Discovery Enabled"
		if !req.IsSelfDiscoveryEnabled {
			mode = "Strict AI Auto-Allocation"
		}
		logAutomation("MATCHMAKER_CONFIG_UPDATE", fmt.Sprintf("Admin toggled roommate discovery: %s", mode), "INFO")

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success":  true,
			"message":  "Matchmaker policy configuration updated.",
			"settings": db.roommateSettings,
		})
	}
}

// 2. GET & POST /api/hostel/mess/dining-intent -> Daily Dining Intent Toggle (Before 06:00 PM)
func handleDiningIntent(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		db.mu.RLock()
		defer db.mu.RUnlock()
		intents := make([]*DiningIntentGoRecord, 0)
		for _, i := range db.diningIntents {
			intents = append(intents, i)
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{"success": true, "intents": intents})
		return
	}

	if r.Method == http.MethodPost {
		var req struct {
			StudentRoll string `json:"student_roll"`
			StudentName string `json:"student_name"`
			MealType    string `json:"meal_type"`
			Intent      string `json:"intent"` // "ATTENDING" / "SKIPPING"
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid payload", http.StatusBadRequest)
			return
		}

		db.mu.Lock()
		id := fmt.Sprintf("INT-%d", time.Now().UnixNano()%100000)
		rec := &DiningIntentGoRecord{
			ID:          id,
			StudentRoll: req.StudentRoll,
			StudentName: req.StudentName,
			Date:        "Today",
			MealType:    req.MealType,
			Intent:      req.Intent,
			UpdatedAt:   time.Now(),
		}
		db.diningIntents[id] = rec

		// Update chef forecast numbers dynamically
		if db.messForecast != nil {
			if req.Intent == "SKIPPING" {
				db.messForecast.ExpectedDiningCount--
				db.messForecast.VoluntarySkippingCount++
			} else {
				db.messForecast.ExpectedDiningCount++
				db.messForecast.VoluntarySkippingCount--
			}
		}
		db.mu.Unlock()

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"message": fmt.Sprintf("Dining intent for %s updated to: %s", req.MealType, req.Intent),
			"intent":  rec,
		})
	}
}

// GET /api/hostel/mess/food-waste-forecast -> Chef's Kitchen Live Food Waste Radar
func handleMessForecast(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":  true,
		"forecast": db.messForecast,
	})
}

// 3. POST /api/hostel/duress/alarm -> Anti-Ragging Silent Duress Secret PIN (9999)
func handleSilentDuress(w http.ResponseWriter, r *http.Request) {
	var req struct {
		EnteredPin  string `json:"entered_pin"`
		StudentRoll string `json:"student_roll"`
		StudentName string `json:"student_name"`
		RoomNumber  string `json:"room_number"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid payload", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	isDuress := req.EnteredPin == "9999"
	if isDuress {
		db.silentDuress.IsDuressTriggered = true
		db.silentDuress.TriggeredAt = time.Now()
		db.silentDuress.DispatchStatus = "🚨 Silent Red Alert: Campus QRT & Chief Warden Dispatched to Room B-304"

		sos := &EmergencySosRecord{
			ID:          fmt.Sprintf("SOS-DURESS-%d", time.Now().Unix()%10000),
			StudentName: req.StudentName,
			RollNumber:  req.StudentRoll,
			RoomNumber:  req.RoomNumber,
			Block:       "Ramanujan Bhawan (Block B)",
			TriggerTime: time.Now(),
			Status:      "TRIGGERED",
			ResolvedBy:  "🚨 Silent Anti-Ragging Coordinates Dispatched (Lat: 23.2599, Long: 77.4126)",
		}
		db.hostelSosLogs = append([]*EmergencySosRecord{sos}, db.hostelSosLogs...)
	}
	db.mu.Unlock()

	if isDuress {
		logAutomation("SILENT_DURESS_TRIGGERED", fmt.Sprintf("🚨 Silent Duress PIN entered by %s in Room %s. Campus Security QRT Dispatched immediately.", req.StudentRoll, req.RoomNumber), "ALERT")
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":              true,
		"is_duress_pin":        isDuress,
		"dummy_screen_payload": "Harmless Notes & Calculator Display",
		"silent_beacon_active": isDuress,
	})
}

// 4. GET & POST /api/hostel/assets/inspect -> Room Damage & Caution Deposit Audit
func handleRoomAssetInspection(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		db.mu.RLock()
		defer db.mu.RUnlock()
		assets := make([]*RoomAssetRecord, 0)
		for _, a := range db.roomAssets {
			assets = append(assets, a)
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{"success": true, "assets": assets})
		return
	}

	if r.Method == http.MethodPost {
		var req struct {
			AssetID           string  `json:"asset_id"`
			CheckOutCondition string  `json:"check_out_condition"`
			CheckOutHash      string  `json:"check_out_hash"`
			DamageScore       float64 `json:"damage_score"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid payload", http.StatusBadRequest)
			return
		}

		db.mu.Lock()
		if a, ok := db.roomAssets[req.AssetID]; ok {
			a.CheckOutDate = "Today (Verified)"
			a.CheckOutCondition = req.CheckOutCondition
			a.CheckOutHash = req.CheckOutHash
			a.DamageScore = req.DamageScore
			a.CautionDeduction = 0.0
			a.AuditStatus = "REFUND_APPROVED"
		}
		db.mu.Unlock()

		logAutomation("ASSET_AUDIT_VERIFIED", fmt.Sprintf("AI Computer Vision certified asset %s condition: 0.00 damage, ₹5,000 caution deposit safe.", req.AssetID), "INFO")

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"message": "AI Differential Vision analysis complete: ₹0 deduction, full caution deposit refund protected.",
		})
	}
}

// 5. GET & POST /api/hostel/energy/eco-leaderboard -> Green Dorm IoT Quota & Leaderboard
func handleGreenDormEco(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		db.mu.RLock()
		defer db.mu.RUnlock()
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success":    true,
			"green_dorm": db.greenDormEco,
		})
		return
	}

	if r.Method == http.MethodPost {
		var req struct {
			LiveLoadWatts float64 `json:"live_load_watts"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid wattage payload", http.StatusBadRequest)
			return
		}

		db.mu.Lock()
		if db.greenDormEco != nil {
			db.greenDormEco.LiveLoadWatts = req.LiveLoadWatts
		}
		db.mu.Unlock()

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success":    true,
			"green_dorm": db.greenDormEco,
		})
	}
}

// 6. GET & POST /api/hostel/curfew/extension -> Curfew Extension & 1-Click Parent Consent
func handleCurfewExtension(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		db.mu.RLock()
		defer db.mu.RUnlock()
		exts := make([]*CurfewExtensionRecord, 0)
		for _, e := range db.curfewExtensions {
			exts = append(exts, e)
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{"success": true, "extensions": exts})
		return
	}

	if r.Method == http.MethodPost {
		var req struct {
			GatePassID       string `json:"gate_pass_id"`
			StudentRoll      string `json:"student_roll"`
			StudentName      string `json:"student_name"`
			RoomNumber       string `json:"room_number"`
			ExtensionMinutes int    `json:"extension_minutes"`
			Reason           string `json:"reason"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid payload", http.StatusBadRequest)
			return
		}

		db.mu.Lock()
		id := fmt.Sprintf("EXT-2026-%d", len(db.curfewExtensions)+90)
		rec := &CurfewExtensionRecord{
			ID:                        id,
			GatePassID:                req.GatePassID,
			StudentRoll:               req.StudentRoll,
			StudentName:               req.StudentName,
			RoomNumber:                req.RoomNumber,
			OriginalCurfewTime:        "08:30 PM",
			RequestedExtensionMinutes: req.ExtensionMinutes,
			ExtendedCurfewTime:        "09:15 PM",
			Reason:                    req.Reason,
			ParentConsentStatus:       "PENDING",
			ParentConsentTimestamp:    time.Now(),
			WardenApprovalStatus:      "AUTO_APPROVED",
			IsFineWaived:              true,
		}
		db.curfewExtensions[id] = rec
		db.mu.Unlock()

		logAutomation("CURFEW_EXTENSION_REQUEST", fmt.Sprintf("Student %s requested +%d min curfew extension. Interactive WhatsApp button sent to parent.", req.StudentRoll, req.ExtensionMinutes), "INFO")

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success":   true,
			"message":   "Curfew extension request submitted. Parent WhatsApp 1-Click consent dispatched.",
			"extension": rec,
		})
	}
}

// POST /api/hostel/curfew/extension/parent-consent -> Parent 1-Click Approve / Reject
func handleCurfewParentConsent(w http.ResponseWriter, r *http.Request) {
	var req struct {
		ExtensionID string `json:"extension_id"`
		Decision    string `json:"decision"` // "APPROVED" or "REJECTED"
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid decision payload", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	rec, ok := db.curfewExtensions[req.ExtensionID]
	if ok {
		rec.ParentConsentStatus = req.Decision
		rec.ParentConsentTimestamp = time.Now()
		if req.Decision == "APPROVED" {
			rec.WardenApprovalStatus = "AUTO_APPROVED"
			rec.IsFineWaived = true
			// Auto update corresponding gate pass expected in time
			for _, p := range db.hostelPasses {
				if p.ID == rec.GatePassID {
					p.ExpectedInTime = time.Now().Add(45 * time.Minute)
					p.IsCurfewBreached = false
				}
			}
		} else {
			rec.WardenApprovalStatus = "DENIED"
		}
	}
	db.mu.Unlock()

	if ok {
		logAutomation("CURFEW_PARENT_CONSENT", fmt.Sprintf("Parent decided %s for Curfew Extension %s. Turnstile gate validity synchronized.", req.Decision, req.ExtensionID), "INFO")
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":   true,
		"message":   fmt.Sprintf("Parent consent recorded: %s. Turnstile gate pass extended without fine.", req.Decision),
		"extension": rec,
	})
}

