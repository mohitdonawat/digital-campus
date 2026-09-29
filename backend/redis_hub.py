"""
Digital Campus - Enterprise Redis Hub
Provides:
1. Sub-Millisecond Token & Session Caching
2. Attendance & 75% Safe Bunk Invariant Cache
3. Real-Time Classroom Doubts & Live Lecture Pub/Sub
4. Anti-Proxy Geofence Rate Limiting
5. Graceful In-Memory Fallback if Redis daemon is offline
"""

import json
import time
from typing import Dict, Any, Optional, List
from datetime import datetime

class RedisHub:
    """
    Enterprise Redis caching & Pub/Sub management for Digital Campus SaaS.
    Auto-detects live Redis service or seamlessly activates memory cache fallback.
    """
    _instance = None
    _in_memory_store: Dict[str, Any] = {}
    _in_memory_channels: Dict[str, List[Dict[str, Any]]] = {}
    _is_live_redis_connected = False
    _redis_client = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(RedisHub, cls).__new__(cls)
            cls._instance._init_redis()
        return cls._instance

    def _init_redis(self):
        try:
            import redis
            self._redis_client = redis.Redis(
                host="localhost",
                port=6379,
                db=0,
                decode_responses=True,
                socket_timeout=1.5
            )
            # Ping test
            self._redis_client.ping()
            self._is_live_redis_connected = True
            print("[RedisHub] Connected to Live Redis 7.2 Daemon at localhost:6379!")
        except Exception as e:
            self._is_live_redis_connected = False
            self._redis_client = None
            print(f"[RedisHub] Live Redis daemon not detected ({e}). Activating High-Speed In-Memory L1 Cache Fallback.")

    def set_session(self, user_id: str, session_data: Dict[str, Any], ttl_seconds: int = 86400) -> bool:
        """Stores authenticated user session and role credentials."""
        key = f"campus:session:{user_id}"
        payload = json.dumps(session_data)
        if self._is_live_redis_connected and self._redis_client:
            try:
                self._redis_client.setex(key, ttl_seconds, payload)
                return True
            except Exception:
                pass
        # In-memory fallback
        self._in_memory_store[key] = {
            "value": session_data,
            "expires_at": time.time() + ttl_seconds
        }
        return True

    def get_session(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Retrieves user session in sub-millisecond latency."""
        key = f"campus:session:{user_id}"
        if self._is_live_redis_connected and self._redis_client:
            try:
                val = self._redis_client.get(key)
                return json.loads(val) if val else None
            except Exception:
                pass
        item = self._in_memory_store.get(key)
        if item and item["expires_at"] > time.time():
            return item["value"]
        return None

    def cache_attendance_metrics(self, student_id: str, metrics: Dict[str, Any], ttl_seconds: int = 1800) -> bool:
        """Caches 75% safe bunks and attendance calculations."""
        key = f"campus:att:{student_id}"
        payload = json.dumps(metrics)
        if self._is_live_redis_connected and self._redis_client:
            try:
                self._redis_client.setex(key, ttl_seconds, payload)
                return True
            except Exception:
                pass
        self._in_memory_store[key] = {
            "value": metrics,
            "expires_at": time.time() + ttl_seconds
        }
        return True

    def get_cached_attendance(self, student_id: str) -> Optional[Dict[str, Any]]:
        key = f"campus:att:{student_id}"
        if self._is_live_redis_connected and self._redis_client:
            try:
                val = self._redis_client.get(key)
                return json.loads(val) if val else None
            except Exception:
                pass
        item = self._in_memory_store.get(key)
        if item and item["expires_at"] > time.time():
            return item["value"]
        return None

    def publish_classroom_doubt(self, subject_code: str, doubt_payload: Dict[str, Any]) -> int:
        """Publishes real-time question / doubt to live classroom channel."""
        channel = f"campus:channel:classroom:{subject_code}"
        payload_str = json.dumps(doubt_payload)
        subscribers_reached = 1

        if self._is_live_redis_connected and self._redis_client:
            try:
                subscribers_reached = self._redis_client.publish(channel, payload_str)
            except Exception:
                pass

        # Also store in channel history buffer
        if channel not in self._in_memory_channels:
            self._in_memory_channels[channel] = []
        self._in_memory_channels[channel].append(doubt_payload)
        if len(self._in_memory_channels[channel]) > 50:
            self._in_memory_channels[channel].pop(0)

        return subscribers_reached

    def get_classroom_doubts(self, subject_code: str) -> List[Dict[str, Any]]:
        channel = f"campus:channel:classroom:{subject_code}"
        return self._in_memory_channels.get(channel, [])

    def check_rate_limit(self, action_key: str, max_requests: int = 5, window_seconds: int = 60) -> bool:
        """Anti-proxy and brute-force geofence rate limiter."""
        key = f"campus:rate:{action_key}"
        now = time.time()

        if key not in self._in_memory_store:
            self._in_memory_store[key] = {"count": 1, "window_start": now}
            return True

        record = self._in_memory_store[key]
        if now - record["window_start"] > window_seconds:
            record["count"] = 1
            record["window_start"] = now
            return True

        if record["count"] < max_requests:
            record["count"] += 1
            return True

        return False

    def get_diagnostics(self) -> Dict[str, Any]:
        """Returns health and performance metrics for the Redis hub."""
        return {
            "status": "online",
            "is_live_redis_daemon": self._is_live_redis_connected,
            "engine": "Redis 7.2 L1 Cache + Memory Ring" if self._is_live_redis_connected else "Sovereign In-Memory L1 Cache Hub",
            "cached_keys_count": len(self._in_memory_store),
            "active_channels": list(self._in_memory_channels.keys()),
            "timestamp": datetime.now().isoformat()
        }

# Global Singleton Accessor
redis_hub = RedisHub()
