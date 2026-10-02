package main

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
	"time"
)

// ============================================================================
// 🏛️ MULTI-TENANT SAAS CONTROLLERS
// ============================================================================

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
		StudentCount int    `json:"student_count"`
		FacultyCount int    `json:"faculty_count"`
		LicensePlan  string `json:"license_plan"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid payload", http.StatusBadRequest)
		return
	}

	if req.Name == "" || req.AdminEmail == "" {
		http.Error(w, "Name and AdminEmail are mandatory", http.StatusBadRequest)
		return
	}

	idBytes := make([]byte, 3)
	rand.Read(idBytes)
	tenantID := fmt.Sprintf("col_%s_%s", req.Code, hex.EncodeToString(idBytes))

	randNum, _ := rand.Int(rand.Reader, big.NewInt(8999))
	genPassword := fmt.Sprintf("%s_Admin#%d", req.Code, randNum.Int64()+1000)
	adminID := fmt.Sprintf("%s_ADM_%04d", req.Code, randNum.Int64()%1000)

	tenant := &CollegeTenant{
		ID:             tenantID,
		Name:           req.Name,
		Code:           req.Code,
		City:           req.City,
		State:          req.State,
		Affiliation:    req.Affiliation,
		Status:         "pending", // Requires Super-Admin Approval demonstration
		AdminEmail:     req.AdminEmail,
		AdminPassword:  genPassword,
		AdminName:      req.AdminName,
		AdminID:        adminID,
		StudentCount:   req.StudentCount,
		FacultyCount:   req.FacultyCount,
		LicensePlan:    req.LicensePlan,
		RegisteredDate: time.Now().Format("02 Jan 2006"),
		LastAuditedAt:  time.Now(),
	}

	db.mu.Lock()
	db.tenants[tenantID] = tenant
	db.mu.Unlock()

	logAutomation(
		"TENANT_PROVISION",
		fmt.Sprintf("New institution onboarded: %s (%s). Credentials generated for %s.", tenant.Name, tenant.Code, tenant.AdminEmail),
		"INFO",
	)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Institution registered successfully. Awaiting Super-Admin license grant.",
		"tenant":  tenant,
	})
}

// POST /api/tenants/approve -> Super Admin 1-click tenant verification
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
	defer db.mu.Unlock()

	tenant, exists := db.tenants[req.TenantID]
	if !exists {
		http.Error(w, "tenant not found", http.StatusNotFound)
		return
	}

	tenant.Status = "active"
	tenant.LastAuditedAt = time.Now()

	logAutomation(
		"TENANT_PROVISION",
		fmt.Sprintf("Super-Admin activated tenant license: %s (%s) [Tier: %s]", tenant.Name, tenant.Code, tenant.LicensePlan),
		"INFO",
	)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Institution tenant activated into Production Cloud SaaS.",
		"tenant":  tenant,
	})
}
