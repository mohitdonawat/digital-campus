package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

// ============================================================================
// 👨‍🎓 CLASS-WISE ATTENDANCE CONTROLLERS
// ============================================================================

// GET /api/attendance/records -> Returns list of all students with metrics
func handleGetAttendanceRecords(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	records := make([]*StudentAttendanceRecord, 0, len(db.attendance))
	for _, rec := range db.attendance {
		records = append(records, rec)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"count":   len(records),
		"records": records,
	})
}

// POST /api/attendance/toggle -> Toggle single student today's attendance
func handleToggleAttendance(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		RollNumber string `json:"roll_number"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.RollNumber == "" {
		http.Error(w, "roll_number required", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	defer db.mu.Unlock()

	student, exists := db.attendance[req.RollNumber]
	if !exists {
		http.Error(w, "student not found", http.StatusNotFound)
		return
	}

	student.IsPresentToday = !student.IsPresentToday
	if student.IsPresentToday {
		student.AttendedClasses++
	} else {
		student.AttendedClasses--
	}

	if student.TotalClasses > 0 {
		student.AttendancePercentage = (float64(student.AttendedClasses) / float64(student.TotalClasses)) * 100.0
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": fmt.Sprintf("Attendance toggled for %s", student.Name),
		"student": student,
	})
}

// POST /api/attendance/bulk -> Mark whole section Present/Absent
func handleBulkAttendance(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Action  string `json:"action"` // "MARK_ALL_PRESENT", "RESET"
		Section string `json:"section"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request", http.StatusBadRequest)
		return
	}

	db.mu.Lock()
	defer db.mu.Unlock()

	updatedCount := 0
	for _, s := range db.attendance {
		if req.Section == "" || s.Section == req.Section {
			if req.Action == "MARK_ALL_PRESENT" {
				if !s.IsPresentToday {
					s.IsPresentToday = true
					s.AttendedClasses++
				}
			} else {
				if s.IsPresentToday {
					s.IsPresentToday = false
					s.AttendedClasses--
				}
			}
			s.AttendancePercentage = (float64(s.AttendedClasses) / float64(s.TotalClasses)) * 100.0
			updatedCount++
		}
	}

	logAutomation(
		"ATTENDANCE_BULK",
		fmt.Sprintf("Bulk attendance action [%s] applied to %d students in %s", req.Action, updatedCount, req.Section),
		"INFO",
	)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"updated": updatedCount,
		"action":  req.Action,
	})
}

// GET /api/attendance/defaulters -> List students < 75%
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
		"success":         true,
		"threshold_limit": DefaulterLimit,
		"count":           len(defaulters),
		"defaulters":      defaulters,
	})
}

// POST /api/attendance/alert-parents -> Simulate WhatsApp/SMS dispatch
func handleAlertParents(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	db.mu.RLock()
	dispatched := 0
	for _, s := range db.attendance {
		if s.AttendancePercentage < DefaulterLimit {
			dispatched++
			logAutomation(
				"SMS_DISPATCH",
				fmt.Sprintf("Automated SMS to %s (%s): Ward %s attendance is critical (%.1f%%). Remedial class required.", s.ParentName, s.ParentPhone, s.Name, s.AttendancePercentage),
				"INFO",
			)
		}
	}
	db.mu.RUnlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":         true,
		"message":         fmt.Sprintf("SMS/WhatsApp alerts successfully sent to %d parent guardians", dispatched),
		"dispatched_count": dispatched,
	})
}
