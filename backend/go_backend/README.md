# 🚀 Digital Campus — Autonomous High-Speed Go Backend

Modular enterprise-grade backend built with **Go (Golang)** providing sub-millisecond API response times, native goroutine concurrency, and low RAM footprint (~25MB) for smart campus operations.

Designed to match tier-1 university systems (StarRez USA, Cloudbeds, and IIT/BITS Pilani SWD).

---

## 📁 Clean File Architecture

```
backend/go_backend/
├── go.mod                 # Go module definition (digitalcampus/go-backend)
├── main.go                # Server entry point, configuration & route mounting
├── models.go              # Data models (SaaS Tenants, Attendance, Hostel, IoT Facilities, SOS)
├── datastore.go           # Thread-safe in-memory RWMutex store & seed records
├── curfew_watchdog.go     # Autonomous Goroutines (30s Curfew breach watchdog & detention auditor)
├── hostel_handlers.go     # All 17 StarRez/IIT Hostel endpoints (Turnstile, SOS, Swaps, Rebates)
├── attendance_handlers.go # Classroom attendance, bulk mark, detention analytics
├── tenant_handlers.go     # Multi-tenant SaaS onboarding, licensing & approvals
└── middleware.go          # CORS headers, Request logging, Health telemetry, SSE live stream hub
```

---

## ⚡ How to Run

```bash
cd backend/go_backend
go run .
```

The server will start on `http://localhost:8080`.

---

## 📡 Key API Endpoints

### 🏨 Smart Hostel & Residence (StarRez / Cloudbeds / IIT SWD)
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/hostel/overview` | Bed capacity & occupancy matrix (450 total beds) |
| `GET` | `/api/hostel/gatepasses` | List active & past digital gate passes |
| `POST` | `/api/hostel/gatepass/apply` | Student applies for pass with rolling TOTP QR |
| `POST` | `/api/hostel/gatepass/approve` | Chief Warden 1-tap approval/rejection |
| `POST` | `/api/hostel/turnstile/scan` | Turnstile gate scanner simulation (In/Out toggle) |
| `GET` | `/api/hostel/curfew/breaches` | Watchdog radar for overdue students |
| `GET` | `/api/hostel/maintenance` | 24h SLA room repair work-order queue |
| `POST` | `/api/hostel/maintenance/create` | Report room issue (4h critical / 24h normal SLA) |
| `POST` | `/api/hostel/maintenance/resolve` | Mark ticket resolved with audit timestamp |
| `POST` | `/api/hostel/mess/rate` | 5-Star student meal feedback |
| `POST` | `/api/hostel/mess/rebate` | Leave meal refund claim (auto-credited to ledger) |
| `GET/POST`| `/api/hostel/room-swap` | Mutual room swap proposal & Chief Warden digital NOC |
| `GET/POST`| `/api/hostel/facilities` | IoT Speed Queen washers & silent study pod booking |
| `POST` | `/api/hostel/sos/trigger` | Emergency Red SOS panic beacon broadcast |
| `POST` | `/api/hostel/sos/resolve` | Warden clears emergency incident |
| `GET` | `/api/hostel/energy` | Green Dorm IoT power meter telemetry |
| `GET/POST`| `/api/hostel/policy` | Dynamic fee tariffs, mess rates & curfew fine engine |

### 👨‍🎓 Attendance & Defaulters
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/attendance/records` | All student attendance percentages & risk scores |
| `POST` | `/api/attendance/toggle` | Toggle single student present/absent |
| `POST` | `/api/attendance/bulk` | Bulk mark section present/absent |
| `GET` | `/api/attendance/defaulters` | List students below 75% detention threshold |
| `POST` | `/api/attendance/alert-parents` | Automated parent SMS alerts dispatch |

### 🏛️ Multi-Tenant SaaS
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/tenants` | List onboarded colleges (IES, RGPV, GEC, LNCT) |
| `POST` | `/api/tenants/register` | Onboard new college with credentials |
| `POST` | `/api/tenants/approve` | Super-Admin license activation |

### 📡 Telemetry & Live Events
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/health` | Server uptime, memory metrics & status |
| `GET` | `/api/broadcast/live` | Server-Sent Events (SSE) live stream |
| `GET` | `/api/automation/logs` | Autonomous background event logs |
