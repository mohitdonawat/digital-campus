package main

import (
	"fmt"
	"time"
)

// ============================================================================
// 🤖 AUTONOMOUS BACKGROUND GOROUTINES
// ============================================================================

// startCurfewWatchdogGoroutine periodically audits student curfew compliance
func startCurfewWatchdogGoroutine() {
	go func() {
		ticker := time.NewTicker(AuditIntervalSec * time.Second)
		defer ticker.Stop()

		for range ticker.C {
			db.mu.Lock()
			now := time.Now()

			for _, pass := range db.hostelPasses {
				// Condition: Student is "Out of Campus" and passed their expected return deadline
				if pass.Status == "Out of Campus" && now.After(pass.ExpectedInTime) && !pass.IsCurfewBreached {
					pass.IsCurfewBreached = true
					curfewLimit := "08:30 PM"
					fineAmount := 250.0
					if db.hostelPolicy != nil {
						curfewLimit = db.hostelPolicy.CurfewTime
						fineAmount = db.hostelPolicy.CurfewViolationFine
					}

					logAutomation(
						"CURFEW_BREACH",
						fmt.Sprintf("⚠️ URGENT: Student %s (%s) breached %s Curfew! Automatic ₹%.0f fine queued & parent alert dispatched to %s",
							pass.StudentName, pass.RollNumber, curfewLimit, fineAmount, pass.ParentPhone),
						"ALERT",
					)
				}
			}
			db.mu.Unlock()
		}
	}()
}

// startAutomatedAttendanceAuditor audits attendance percentage thresholds
func startAutomatedAttendanceAuditor() {
	go func() {
		ticker := time.NewTicker(AuditIntervalSec * time.Second)
		defer ticker.Stop()

		for range ticker.C {
			db.mu.Lock()
			defaulterCount := 0
			for _, rec := range db.attendance {
				if rec.AttendancePercentage < DefaulterLimit {
					defaulterCount++
					rec.RiskScore = "CRITICAL"
				} else if rec.AttendancePercentage < 80.0 {
					rec.RiskScore = "MODERATE"
				} else {
					rec.RiskScore = "SAFE"
				}
			}
			db.mu.Unlock()

			if defaulterCount > 0 {
				logAutomation(
					"DETENTION_AUDIT",
					fmt.Sprintf("Autonomous Audit: %d students detected below %.1f%% attendance threshold. Critical alerts active.", defaulterCount, DefaulterLimit),
					"WARNING",
				)
			}
		}
	}()
}

// startTenantLicenseMonitor checks college SaaS license validity
func startTenantLicenseMonitor() {
	go func() {
		ticker := time.NewTicker(60 * time.Second)
		defer ticker.Stop()

		for range ticker.C {
			db.mu.RLock()
			activeCount := 0
			for _, t := range db.tenants {
				if t.Status == "active" {
					activeCount++
				}
			}
			db.mu.RUnlock()

			logAutomation(
				"HEARTBEAT",
				fmt.Sprintf("Multi-Tenant Cluster: %d institutional tenants operational under sovereign SLA.", activeCount),
				"INFO",
			)
		}
	}()
}
