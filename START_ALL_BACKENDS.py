"""
╔══════════════════════════════════════════════════════════════════════════════╗
║          🚀 DIGITAL CAMPUS — ONE-CLICK BACKEND LAUNCHER 🚀                ║
║                                                                            ║
║   Double-click this file to start ALL backend servers at once:             ║
║     • Python FastAPI  (AI/ML/RAG/Vision/Tutor)  →  localhost:8000          ║
║     • Go SaaS Engine  (Multi-Tenant/Attendance)  →  localhost:8080         ║
║                                                                            ║
║   Author: Digital Campus Team                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import subprocess
import sys
import os
import time
import signal
import threading
import urllib.request
import json
from pathlib import Path

# Fix Windows encoding: force UTF-8 output for emojis and box-drawing chars
if sys.platform == "win32":
    os.environ["PYTHONIOENCODING"] = "utf-8"
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════
SCRIPT_DIR = Path(__file__).parent.resolve()
BACKEND_DIR = SCRIPT_DIR / "backend"

# Python FastAPI Config
PYTHON_SERVER_FILE = BACKEND_DIR / "server.py"
PYTHON_HOST = "127.0.0.1"
PYTHON_PORT = 8000
PYTHON_HEALTH_URL = f"http://{PYTHON_HOST}:{PYTHON_PORT}/api/health"

# Go Engine Config — prefer pre-built .exe, fallback to `go run`
GO_ENGINE_EXE = BACKEND_DIR / "go_node_engine" / "node_engine.exe"
GO_MAIN_FILE = BACKEND_DIR / "main.go"
GO_HOST = "127.0.0.1"
GO_PORT = 8080
GO_HEALTH_URL = f"http://{GO_HOST}:{GO_PORT}/api/health"

# Health check settings
HEALTH_CHECK_TIMEOUT = 2        # seconds per check
HEALTH_CHECK_RETRIES = 15       # max retries before giving up
HEALTH_CHECK_INTERVAL = 2       # seconds between retries

# ═══════════════════════════════════════════════════════════════════════════════
# COLORS & UI HELPERS (Windows CMD / PowerShell compatible)
# ═══════════════════════════════════════════════════════════════════════════════

# Enable ANSI colors on Windows
if sys.platform == "win32":
    os.system("color")

class C:
    """ANSI color codes for terminal output."""
    RESET   = "\033[0m"
    BOLD    = "\033[1m"
    RED     = "\033[91m"
    GREEN   = "\033[92m"
    YELLOW  = "\033[93m"
    BLUE    = "\033[94m"
    MAGENTA = "\033[95m"
    CYAN    = "\033[96m"
    WHITE   = "\033[97m"
    DIM     = "\033[2m"
    BG_GREEN  = "\033[42m"
    BG_RED    = "\033[41m"
    BG_BLUE   = "\033[44m"
    BG_YELLOW = "\033[43m"


def banner():
    print(f"""
{C.CYAN}{C.BOLD}╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   {C.WHITE}🚀  DIGITAL CAMPUS — BACKEND LAUNCHER  🚀{C.CYAN}                     ║
║                                                                  ║
║   {C.YELLOW}Python FastAPI  {C.DIM}(AI/ML/RAG/Vision){C.RESET}{C.CYAN}    →  {C.GREEN}localhost:8000{C.CYAN}     ║
║   {C.MAGENTA}Go SaaS Engine  {C.DIM}(Tenants/Attendance){C.RESET}{C.CYAN}  →  {C.GREEN}localhost:8080{C.CYAN}     ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝{C.RESET}
""")


def print_step(emoji, msg, color=C.WHITE):
    print(f"  {emoji}  {color}{msg}{C.RESET}")


def print_status(name, status, detail=""):
    if status == "ONLINE":
        icon = f"{C.BG_GREEN}{C.WHITE}{C.BOLD} ✓ ONLINE  {C.RESET}"
    elif status == "STARTING":
        icon = f"{C.BG_YELLOW}{C.WHITE}{C.BOLD} ⟳ STARTING {C.RESET}"
    elif status == "OFFLINE":
        icon = f"{C.BG_RED}{C.WHITE}{C.BOLD} ✗ OFFLINE  {C.RESET}"
    else:
        icon = f"{C.DIM}[{status}]{C.RESET}"
    detail_str = f"  {C.DIM}{detail}{C.RESET}" if detail else ""
    print(f"  {icon}  {C.BOLD}{name}{C.RESET}{detail_str}")


# ═══════════════════════════════════════════════════════════════════════════════
# PORT CHECK — Kill anything already on our ports
# ═══════════════════════════════════════════════════════════════════════════════

def kill_port(port):
    """Kill any process already using the given port (Windows)."""
    try:
        result = subprocess.run(
            ["netstat", "-ano"],
            capture_output=True, text=True, timeout=5
        )
        for line in result.stdout.splitlines():
            if f":{port}" in line and "LISTENING" in line:
                parts = line.split()
                pid = parts[-1]
                if pid.isdigit() and int(pid) > 0:
                    subprocess.run(["taskkill", "/F", "/PID", pid],
                                   capture_output=True, timeout=5)
                    print_step("🔪", f"Killed existing process on port {port} (PID {pid})", C.YELLOW)
                    time.sleep(0.5)
                    return True
    except Exception:
        pass
    return False


# ═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECK
# ═══════════════════════════════════════════════════════════════════════════════

def check_health(url, timeout=HEALTH_CHECK_TIMEOUT):
    """Returns (True, response_data) if healthy, (False, None) otherwise."""
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            if resp.status == 200:
                data = json.loads(resp.read().decode())
                return True, data
    except Exception:
        pass
    return False, None


def wait_for_health(name, url, max_retries=HEALTH_CHECK_RETRIES, interval=HEALTH_CHECK_INTERVAL):
    """Wait until the server is healthy or max retries reached."""
    for attempt in range(1, max_retries + 1):
        ok, data = check_health(url)
        if ok:
            return True, data
        dots = "." * (attempt % 4)
        print(f"\r  {C.YELLOW}⏳  Waiting for {name}{dots.ljust(4)}{C.DIM}(attempt {attempt}/{max_retries}){C.RESET}", end="", flush=True)
        time.sleep(interval)
    print()  # newline after retries
    return False, None


# ═══════════════════════════════════════════════════════════════════════════════
# SERVER LAUNCHERS
# ═══════════════════════════════════════════════════════════════════════════════

processes = []  # Track all child processes for cleanup

def start_python_server():
    """Start Python FastAPI server via uvicorn."""
    if not PYTHON_SERVER_FILE.exists():
        print_step("❌", f"Python server not found: {PYTHON_SERVER_FILE}", C.RED)
        return None

    print_step("🐍", f"Starting Python FastAPI on port {PYTHON_PORT}...", C.YELLOW)

    # Use the same Python interpreter that's running this script
    python_exe = sys.executable

    proc = subprocess.Popen(
        [python_exe, "-m", "uvicorn", "server:app",
         "--host", PYTHON_HOST,
         "--port", str(PYTHON_PORT),
         "--reload",
         "--log-level", "warning"],
        cwd=str(BACKEND_DIR),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if sys.platform == "win32" else 0,
    )
    processes.append(("Python FastAPI", proc))
    return proc


def start_go_server():
    """Start Go SaaS Engine — prefer pre-built .exe, fallback to go run."""
    print_step("🟢", f"Starting Go SaaS Engine on port {GO_PORT}...", C.MAGENTA)

    if GO_ENGINE_EXE.exists():
        # Use pre-built executable (faster startup)
        print_step("⚡", "Using pre-built Go executable (fast start)", C.DIM)
        proc = subprocess.Popen(
            [str(GO_ENGINE_EXE)],
            cwd=str(GO_ENGINE_EXE.parent),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if sys.platform == "win32" else 0,
        )
    elif GO_MAIN_FILE.exists():
        # Fallback: compile and run from source
        print_step("🔨", "Compiling Go from source (may take a moment)...", C.DIM)
        proc = subprocess.Popen(
            ["go", "run", str(GO_MAIN_FILE)],
            cwd=str(BACKEND_DIR),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if sys.platform == "win32" else 0,
        )
    else:
        print_step("❌", f"Go server not found at {GO_ENGINE_EXE} or {GO_MAIN_FILE}", C.RED)
        return None

    processes.append(("Go SaaS Engine", proc))
    return proc


# ═══════════════════════════════════════════════════════════════════════════════
# LIVE MONITORING DASHBOARD
# ═══════════════════════════════════════════════════════════════════════════════

stop_monitor = threading.Event()

def live_monitor():
    """Background thread that periodically checks both servers are still alive."""
    while not stop_monitor.is_set():
        stop_monitor.wait(30)  # Check every 30 seconds
        if stop_monitor.is_set():
            break

        py_ok, _ = check_health(PYTHON_HEALTH_URL)
        go_ok, _ = check_health(GO_HEALTH_URL)

        if not py_ok or not go_ok:
            print(f"\n{C.YELLOW}{'═' * 60}{C.RESET}")
            print(f"  {C.BOLD}⚠️  HEALTH CHECK UPDATE{C.RESET}")
            print_status("Python FastAPI :8000", "ONLINE" if py_ok else "OFFLINE")
            print_status("Go SaaS Engine :8080", "ONLINE" if go_ok else "OFFLINE")
            print(f"{C.YELLOW}{'═' * 60}{C.RESET}\n")


# ═══════════════════════════════════════════════════════════════════════════════
# GRACEFUL SHUTDOWN
# ═══════════════════════════════════════════════════════════════════════════════

def cleanup(signum=None, frame=None):
    """Kill all child processes on exit."""
    stop_monitor.set()
    print(f"\n\n{C.CYAN}{'═' * 60}{C.RESET}")
    print(f"  {C.BOLD}🛑  Shutting down all backends...{C.RESET}")
    print(f"{C.CYAN}{'═' * 60}{C.RESET}")

    for name, proc in processes:
        try:
            if proc and proc.poll() is None:
                if sys.platform == "win32":
                    subprocess.run(["taskkill", "/F", "/T", "/PID", str(proc.pid)],
                                   capture_output=True, timeout=5)
                else:
                    os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
                print_step("✓", f"{name} stopped (PID {proc.pid})", C.GREEN)
        except Exception as e:
            print_step("⚠", f"Could not stop {name}: {e}", C.YELLOW)

    print(f"\n  {C.GREEN}{C.BOLD}All backends stopped. Goodbye! 👋{C.RESET}\n")
    sys.exit(0)


# Register signal handlers
signal.signal(signal.SIGINT, cleanup)
signal.signal(signal.SIGTERM, cleanup)
if sys.platform == "win32":
    signal.signal(signal.SIGBREAK, cleanup)


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    banner()

    # ── Step 1: Check prerequisites ──────────────────────────────────────────
    print(f"  {C.BOLD}{C.CYAN}[ STEP 1 ] Checking prerequisites...{C.RESET}")
    print()

    has_python_server = PYTHON_SERVER_FILE.exists()
    has_go_server = GO_ENGINE_EXE.exists() or GO_MAIN_FILE.exists()

    print_step("📁", f"Backend directory: {BACKEND_DIR}", C.DIM)
    print_step("🐍" if has_python_server else "❌",
               f"Python server.py: {'Found ✓' if has_python_server else 'NOT FOUND ✗'}", 
               C.GREEN if has_python_server else C.RED)
    print_step("🟢" if has_go_server else "❌",
               f"Go engine: {'Found ✓' if has_go_server else 'NOT FOUND ✗'}",
               C.GREEN if has_go_server else C.RED)
    print()

    if not has_python_server and not has_go_server:
        print_step("💀", "No backend servers found! Check your backend/ directory.", C.RED)
        input("\nPress Enter to exit...")
        return

    # ── Step 2: Free up ports ────────────────────────────────────────────────
    print(f"  {C.BOLD}{C.CYAN}[ STEP 2 ] Freeing up ports...{C.RESET}")
    print()

    if has_python_server:
        kill_port(PYTHON_PORT)
    if has_go_server:
        kill_port(GO_PORT)
    print()

    # ── Step 3: Launch servers ───────────────────────────────────────────────
    print(f"  {C.BOLD}{C.CYAN}[ STEP 3 ] Launching backend servers...{C.RESET}")
    print()

    py_proc = None
    go_proc = None

    if has_python_server:
        py_proc = start_python_server()
    if has_go_server:
        go_proc = start_go_server()
    print()

    # ── Step 4: Wait for health checks ───────────────────────────────────────
    print(f"  {C.BOLD}{C.CYAN}[ STEP 4 ] Waiting for servers to become healthy...{C.RESET}")
    print()

    py_healthy = False
    go_healthy = False

    if py_proc:
        py_healthy, py_data = wait_for_health("Python FastAPI", PYTHON_HEALTH_URL)
        print()
    if go_proc:
        go_healthy, go_data = wait_for_health("Go SaaS Engine", GO_HEALTH_URL)
        print()

    # ── Step 5: Final Status Dashboard ───────────────────────────────────────
    print()
    print(f"{C.CYAN}{C.BOLD}╔══════════════════════════════════════════════════════════════════╗")
    print(f"║                    📊  CONNECTION DASHBOARD                     ║")
    print(f"╠══════════════════════════════════════════════════════════════════╣{C.RESET}")
    print()

    if has_python_server:
        print_status(
            "Python FastAPI  →  localhost:8000",
            "ONLINE" if py_healthy else "OFFLINE",
            "AI/ML/RAG/Vision/Tutor Ready" if py_healthy else "Server failed to start"
        )
    else:
        print_status("Python FastAPI  →  localhost:8000", "OFFLINE", "server.py not found")

    if has_go_server:
        print_status(
            "Go SaaS Engine  →  localhost:8080",
            "ONLINE" if go_healthy else "OFFLINE",
            "Multi-Tenant/Attendance/Automation Ready" if go_healthy else "Server failed to start"
        )
    else:
        print_status("Go SaaS Engine  →  localhost:8080", "OFFLINE", "main.go / .exe not found")

    print()
    online_count = sum([py_healthy, go_healthy])
    total_count = sum([has_python_server, has_go_server])

    if online_count == total_count and total_count > 0:
        print(f"  {C.GREEN}{C.BOLD}🎉  ALL {online_count} BACKENDS ONLINE — Flutter App Can Connect!{C.RESET}")
        print()
        print(f"  {C.DIM}Now run your Flutter app:  flutter run{C.RESET}")
    elif online_count > 0:
        print(f"  {C.YELLOW}{C.BOLD}⚠️  {online_count}/{total_count} backends online. Check logs above for errors.{C.RESET}")
    else:
        print(f"  {C.RED}{C.BOLD}💀  No backends could start. Check Python/Go installations.{C.RESET}")

    print()
    print(f"{C.CYAN}{C.BOLD}╠══════════════════════════════════════════════════════════════════╣")
    print(f"║   {C.WHITE}Press Ctrl+C to stop all servers and exit{C.CYAN}                      ║")
    print(f"╚══════════════════════════════════════════════════════════════════╝{C.RESET}")
    print()

    # ── Step 6: Start live monitoring & keep alive ───────────────────────────
    monitor_thread = threading.Thread(target=live_monitor, daemon=True)
    monitor_thread.start()

    # Keep the main process alive — servers run as children
    try:
        while True:
            # Check if any process died unexpectedly
            for name, proc in processes:
                if proc and proc.poll() is not None:
                    print(f"\n  {C.RED}{C.BOLD}⚠️  {name} exited unexpectedly (code {proc.returncode}){C.RESET}")
                    # Read stderr for error info
                    try:
                        stderr_output = proc.stderr.read().decode(errors="ignore")
                        if stderr_output.strip():
                            print(f"  {C.DIM}Error: {stderr_output[:500]}{C.RESET}")
                    except Exception:
                        pass
            time.sleep(5)
    except KeyboardInterrupt:
        cleanup()


if __name__ == "__main__":
    main()
