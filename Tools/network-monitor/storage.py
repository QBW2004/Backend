"""Bounded local history with explicit missing-data semantics."""
import math
import sqlite3
import statistics
import threading


class History:
    def __init__(self, path):
        self.lock = threading.RLock()
        self.db = sqlite3.connect(path, check_same_thread=False)
        self.db.row_factory = sqlite3.Row
        self.db.execute("PRAGMA journal_mode=WAL")
        self.db.execute("CREATE TABLE IF NOT EXISTS samples (id INTEGER PRIMARY KEY, "
                        "ts INTEGER NOT NULL, route TEXT NOT NULL, status TEXT NOT NULL, "
                        "rtt REAL, detail TEXT NOT NULL)")
        self.db.execute("CREATE INDEX IF NOT EXISTS samples_time ON samples(ts)")
        self.db.commit()

    def add(self, route, ts, measurement):
        with self.lock:
            self.db.execute("INSERT INTO samples(ts,route,status,rtt,detail) VALUES (?,?,?,?,?)",
                            (ts, route, measurement["status"], measurement["rtt"], measurement["detail"]))
            self.db.commit()

    def read(self, start, end):
        with self.lock:
            return [dict(row) for row in self.db.execute(
                "SELECT ts,route,status,rtt,detail FROM samples WHERE ts>=? AND ts<=? ORDER BY ts,id",
                (start, end))]

    def prune(self, before):
        with self.lock:
            self.db.execute("DELETE FROM samples WHERE ts<?", (before,))
            self.db.commit()

    def close(self):
        with self.lock:
            self.db.close()


def rounded(value):
    return round(value, 2) if value is not None else None


def summarize(rows, interval_ms):
    successes = [r["rtt"] for r in rows if r["status"] == "ok"]
    failures = sum(r["status"] == "failed" for r in rows)
    attempts = len(successes) + failures
    ordered = sorted(successes)
    diffs = [abs(b["rtt"] - a["rtt"]) for a, b in zip(rows, rows[1:])
             if a["status"] == b["status"] == "ok" and b["ts"] - a["ts"] <= interval_ms * 2.5]
    return {"sent": attempts, "received": len(successes), "failed": failures,
            "unknown": len(rows) - attempts,
            "loss": rounded(100 * failures / attempts) if attempts else None,
            "avg": rounded(statistics.mean(successes)) if successes else None,
            "min": min(successes) if successes else None,
            "p95": ordered[max(0, math.ceil(len(ordered) * .95) - 1)] if ordered else None,
            "jitter": rounded(statistics.mean(diffs)) if diffs else None,
            "latest": rows[-1] if rows else None}


def bucket_points(rows, start, end, step):
    buckets = {}
    for row in rows:
        bucket = (row["ts"] - start) // step
        entry = buckets.setdefault(bucket, {"ts": start + bucket * step, "values": [],
                                            "failed": 0, "unknown": 0})
        if row["status"] == "ok":
            entry["values"].append(row["rtt"])
        else:
            entry[row["status"]] += 1
    points = []
    for offset in range(0, end - start + 1, step):
        entry = buckets.get(offset // step)
        if not entry:
            points.append({"ts": start + offset, "avg": None, "max": None,
                           "failed": 0, "unknown": 0, "sent": 0, "loss": None})
            continue
        values = entry["values"]
        sent = len(values) + entry["failed"]
        points.append({"ts": entry["ts"], "avg": rounded(statistics.mean(values)) if values else None,
                       "max": max(values) if values else None, "failed": entry["failed"],
                       "unknown": entry["unknown"], "sent": sent,
                       "loss": rounded(100 * entry["failed"] / sent) if sent else None})
    return points
