package main

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

// ============================================================================
// 🛡️ MIDDLEWARE & CORS
// ============================================================================

// enableCORS sets open headers for Flutter Mobile, Web, and Desktop apps
func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With, X-Tenant-ID")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

// logAutomation appends an automated event into memory and broadcasts over SSE
func logAutomation(category, message, severity string) {
	logBytes := make([]byte, 4)
	rand.Read(logBytes)
	id := fmt.Sprintf("LOG-%s", hex.EncodeToString(logBytes))

	entry := AutomationLog{
		ID:        id,
		Timestamp: time.Now(),
		Category:  category,
		Message:   message,
		Severity:  severity,
	}

	db.mu.Lock()
	db.logs = append([]AutomationLog{entry}, db.logs...)
	if len(db.logs) > 200 {
		db.logs = db.logs[:200]
	}
	db.mu.Unlock()

	log.Printf("[%s] [%s] %s\n", severity, category, message)

	payload, err := json.Marshal(entry)
	if err == nil {
		broadcastEvent(string(payload))
	}
}

// broadcastEvent sends live JSON payload to all connected SSE browser clients
func broadcastEvent(msg string) {
	db.subMutex.RLock()
	defer db.subMutex.RUnlock()

	for _, ch := range db.subscribers {
		select {
		case ch <- msg:
		default:
		}
	}
}

// ============================================================================
// 📡 SYSTEM TELEMETRY & SSE ENDPOINTS
// ============================================================================

// GET /api/health -> Server uptime, tenant count, memory state
func handleHealth(w http.ResponseWriter, r *http.Request) {
	db.mu.RLock()
	tCount := len(db.tenants)
	sCount := len(db.attendance)
	pCount := len(db.hostelPasses)
	bCount := len(db.hostelBlocks)
	lCount := len(db.logs)
	db.mu.RUnlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":          "HEALTHY",
		"cluster":         ClusterName,
		"version":         EngineVersion,
		"uptime_seconds":  int(time.Since(db.startTime).Seconds()),
		"active_tenants":  tCount,
		"active_students": sCount,
		"hostel_blocks":   bCount,
		"active_passes":   pCount,
		"total_logs":      lCount,
		"timestamp":       time.Now().Format(time.RFC3339),
	})
}

// GET /api/automation/logs -> List recent background automation events
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

// GET /api/broadcast/live -> Server-Sent Events (SSE) stream for instant UI updates
func handleLiveEventsSSE(w http.ResponseWriter, r *http.Request) {
	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "Streaming unsupported", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	clientChan := make(chan string, 10)
	clientID := fmt.Sprintf("sub_%d", time.Now().UnixNano())

	db.subMutex.Lock()
	db.subscribers[clientID] = clientChan
	db.subMutex.Unlock()

	defer func() {
		db.subMutex.Lock()
		delete(db.subscribers, clientID)
		close(clientChan)
		db.subMutex.Unlock()
	}()

	fmt.Fprintf(w, "data: {\"event\": \"CONNECTED\", \"client_id\": \"%s\"}\n\n", clientID)
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
