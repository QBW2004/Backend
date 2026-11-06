"""Local-only network dashboard. No production files or business data are changed."""
import argparse
import base64
import csv
import io
import ipaddress
import json
import logging
import math
from logging.handlers import RotatingFileHandler
import os
from pathlib import Path
import queue
import re
import socket
import subprocess
import threading
import time
import uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlsplit

from probes import WindowsPing, http_probe, result
from storage import History, bucket_points, summarize

ROOT = Path(__file__).resolve().parent
SERVICE = "mth-network-monitor-v1"


def now_ms():
    return int(time.time() * 1000)


def load_config(path):
    config = json.loads(Path(path).read_text(encoding="utf-8-sig"))
    for key in ("relay_ip", "source_ip"):
        ipaddress.IPv4Address(config[key])
    for key in ("relay_domain", "source_ssh_alias"):
        if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9.-]*", config[key]):
            raise ValueError("Invalid " + key)
    for key in ("port", "source_http_port"):
        if not 1024 <= config[key] <= 65535:
            raise ValueError("Invalid " + key)
    for key in ("ping_interval_seconds", "http_interval_seconds"):
        if not 1 <= config[key] <= 60:
            raise ValueError("Invalid " + key)
    if not 200 <= config["ping_timeout_ms"] <= 5000:
        raise ValueError("Invalid ping timeout")
    if not 1 <= config["http_timeout_seconds"] <= 10 or not 1 <= config["retention_days"] <= 30:
        raise ValueError("Invalid timeout or retention")
    return config


def routes_for(config):
    ping_interval = config["ping_interval_seconds"]
    http_interval = config["http_interval_seconds"]
    return [
        {"id": "local_relay", "name": "本机 → 中转", "method": "ICMP", "color": "#176cda",
         "interval": ping_interval, "target": config["relay_ip"],
         "description": "本机发出 Ping，测量往返时延与 ICMP 未回包率。"},
        {"id": "source_relay", "name": "源站 → 中转", "method": "ICMP", "color": "#009a87",
         "interval": ping_interval, "target": config["source_ip"] + " → " + config["relay_ip"],
         "description": "源站发起反向 Ping；RTT 在源站计时，不含 SSH 传输耗时。"},
        {"id": "via_relay", "name": "本机 → 中转 → 源站", "method": "HTTP", "color": "#8053d4",
         "interval": http_interval, "target": config["relay_domain"] + ":443 → 源站:8080",
         "description": "HTTPS HEAD /，从发起到响应头；包含 TLS、转发和网页处理。"},
        {"id": "direct_source", "name": "本机 → 源站直连", "method": "HTTP", "color": "#d78924",
         "interval": http_interval, "target": config["source_ip"] + ":" + str(config["source_http_port"]),
         "description": "HTTP HEAD / 作为直连对照；不经过中转，不含 TLS。"},
    ]


def source_script(config, token="validation"):
    # IP and interval are validated configuration, not HTTP request parameters.
    return """
$ErrorActionPreference='Stop';$ProgressPreference='SilentlyContinue'
$probeToken='PROBE_TOKEN'
[Console]::OutputEncoding=New-Object System.Text.UTF8Encoding($false)
$ping=New-Object System.Net.NetworkInformation.Ping
$lease=[Diagnostics.Stopwatch]::StartNew()
try {
 while($lease.Elapsed.TotalSeconds -lt 60) {
  $timer=[Diagnostics.Stopwatch]::StartNew()
  $rtt=$null;$state='unknown';$detail='PingException'
  try {
   $reply=$ping.Send('RELAY_ADDRESS',PING_TIMEOUT)
   $detail=[string]$reply.Status
   if($reply.Status -eq 'Success'){$state='ok';$rtt=$reply.RoundtripTime}
   elseif($reply.Status -in @('TimedOut','DestinationNetworkUnreachable','DestinationHostUnreachable','DestinationProtocolUnreachable','DestinationPortUnreachable','TtlExpired')){$state='failed'}
  } catch {}
  $stamp=[DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
  $line=@{ts=$stamp;status=$state;rtt=$rtt;detail=$detail;pid=$PID}|ConvertTo-Json -Compress
  [Console]::WriteLine($line);[Console]::Out.Flush()
  $wait=PING_INTERVAL-$timer.ElapsedMilliseconds
  if($wait -gt 0){Start-Sleep -Milliseconds $wait}
 }
} finally {$ping.Dispose()}
""".replace("PROBE_TOKEN", token).replace("RELAY_ADDRESS", config["relay_ip"]).replace(
        "PING_TIMEOUT", str(config["ping_timeout_ms"])).replace(
        "PING_INTERVAL", str(config["ping_interval_seconds"] * 1000))


def stop_remote_probe(alias, process_id, token):
    # PID reuse cannot stop another process: the encoded script must contain this run's UUID.
    code = """$ErrorActionPreference='Stop';$ProgressPreference='SilentlyContinue'
$candidate=Get-CimInstance Win32_Process -Filter 'ProcessId=PROBE_PID'
if($candidate.Name -eq 'powershell.exe' -and $candidate.CommandLine -match '-EncodedCommand\\s+(\\S+)') {
 $script=[Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($Matches[1]))
 if($script.Contains('PROBE_TOKEN')){Stop-Process -Id PROBE_PID}
}""".replace("PROBE_PID", str(int(process_id))).replace("PROBE_TOKEN", token)
    encoded = base64.b64encode(code.encode("utf-16le")).decode("ascii")
    try:
        subprocess.run(["ssh.exe", "-T", "-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=yes",
                        "-o", "ConnectTimeout=5", alias, "powershell", "-NoProfile", "-NonInteractive",
                        "-EncodedCommand", encoded], stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL, timeout=8, creationflags=subprocess.CREATE_NO_WINDOW)
    except (OSError, subprocess.TimeoutExpired):
        logging.warning("Probe stop unavailable; the 60-second remote lease will expire")


def parse_remote_sample(line, received):
    data = json.loads(line)
    if data.get("status") not in ("ok", "failed", "unknown"):
        raise ValueError("Unknown remote status")
    if abs(received - int(data["ts"])) > 10000:
        return result("unknown", detail="远端时钟偏差或样本传输延迟超过 10 秒")
    rtt = data.get("rtt")
    if data["status"] == "ok" and (not isinstance(rtt, (float, int)) or not 0 <= rtt <= 60000):
        raise ValueError("Invalid remote RTT")
    return result(data["status"], rtt if data["status"] == "ok" else None, str(data.get("detail", ""))[:120])


class Monitor:
    def __init__(self, config, data_dir):
        self.config = config
        self.routes = routes_for(config)
        self.history = History(data_dir / "history.sqlite3")
        self.stopping = threading.Event()
        self.lock = threading.Lock()
        self.health = {r["id"]: {"state": "waiting", "updated": None} for r in self.routes}
        self.threads = []

    def record(self, route, measurement, ts=None):
        timestamp = ts or now_ms()
        self.history.add(route, timestamp, measurement)
        with self.lock:
            self.health[route] = {"state": measurement["status"], "updated": timestamp,
                                  "detail": measurement["detail"]}

    def start(self):
        for task in (self.local_ping, self.remote_ping, self.relay_http, self.direct_http, self.cleanup):
            thread = threading.Thread(target=task, name=task.__name__, daemon=True)
            self.threads.append(thread)
            thread.start()

    def periodic(self, route, interval, probe):
        while not self.stopping.is_set():
            began = time.monotonic()
            try:
                self.record(route, probe())
            except Exception:
                logging.exception("Collector error: %s", route)
                self.record(route, result("unknown", detail="采集器错误，请查看本地日志"))
            self.stopping.wait(max(.1, interval - (time.monotonic() - began)))

    def local_ping(self):
        try:
            ping = WindowsPing()
        except OSError:
            self.record("local_relay", result("unknown", detail="本机 ICMP API 不可用"))
            return
        try:
            self.periodic("local_relay", self.config["ping_interval_seconds"],
                          lambda: ping.send(self.config["relay_ip"], self.config["ping_timeout_ms"]))
        finally:
            ping.close()

    def relay_http(self):
        self.periodic("via_relay", self.config["http_interval_seconds"], lambda: http_probe(
            self.config["relay_domain"], 443, self.config["http_timeout_seconds"], self.config["relay_ip"]))

    def direct_http(self):
        self.periodic("direct_source", self.config["http_interval_seconds"], lambda: http_probe(
            self.config["source_ip"], self.config["source_http_port"], self.config["http_timeout_seconds"]))

    def remote_ping(self):
        token = uuid.uuid4().hex
        encoded = base64.b64encode(source_script(self.config, token).encode("utf-16le")).decode("ascii")
        command = ["ssh.exe", "-T", "-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=yes",
                   "-o", "ConnectTimeout=8", "-o", "ServerAliveInterval=5", "-o", "ServerAliveCountMax=2",
                   self.config["source_ssh_alias"], "powershell", "-NoProfile", "-NonInteractive", "-EncodedCommand", encoded]
        while not self.stopping.is_set():
            try:
                completed = self.consume_remote(command, token)
            except (OSError, ValueError):
                logging.exception("Remote collector unavailable")
                completed = False
            if not self.stopping.is_set():
                if completed:
                    continue
                self.record("source_relay", result("unknown", detail="SSH 采集连接中断；10 秒后重连"))
                self.stopping.wait(10)

    def consume_remote(self, command, token):
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                                   stdin=subprocess.DEVNULL, creationflags=subprocess.CREATE_NO_WINDOW)
        lines = queue.Queue(maxsize=100)
        remote_pid = None

        def read_lines():
            try:
                for line in process.stdout:
                    if self.stopping.is_set():
                        return
                    lines.put(line, timeout=2)
            except (OSError, ValueError, queue.Full):
                pass
            finally:
                try:
                    lines.put_nowait(None)
                except queue.Full:
                    pass

        reader = threading.Thread(target=read_lines, daemon=True)
        reader.start()
        last_received = time.monotonic()
        try:
            while not self.stopping.is_set():
                try:
                    line = lines.get(timeout=.5)
                except queue.Empty:
                    if time.monotonic() - last_received > 15:
                        return False
                    continue
                if line is None:
                    return process.wait(timeout=3) == 0
                if not line.lstrip().startswith(b"{"):
                    continue
                measurement = parse_remote_sample(line.decode("utf-8-sig"), now_ms())
                remote_pid = int(json.loads(line)["pid"])
                self.record("source_relay", measurement)
                last_received = time.monotonic()
        finally:
            if remote_pid and process.poll() is None:
                stop_remote_probe(self.config["source_ssh_alias"], remote_pid, token)
            if process.poll() is None:
                process.terminate()
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                process.terminate()
                try:
                    process.wait(timeout=2)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=2)
            reader.join(timeout=2)
            process.stdout.close()

    def cleanup(self):
        while not self.stopping.is_set():
            self.history.prune(now_ms() - self.config["retention_days"] * 86400000)
            self.stopping.wait(3600)

    def snapshot(self, seconds, end):
        start = end - seconds * 1000
        rows = self.history.read(start, end)
        grouped = {r["id"]: [] for r in self.routes}
        for row in rows:
            if row["route"] in grouped:
                grouped[row["route"]].append(row)
        current = now_ms()
        with self.lock:
            health = {k: dict(v) for k, v in self.health.items()}
        entries = []
        step = max(2000, math.ceil(seconds / 420) * 1000)
        for route in self.routes:
            sample_rows = grouped[route["id"]]
            live = health[route["id"]]
            live["stale"] = not live["updated"] or current - live["updated"] > max(8000, route["interval"] * 3000)
            entries.append({**route, "health": live, "stats": summarize(sample_rows, route["interval"] * 1000),
                            "points": bucket_points(sample_rows, start, end, step)})
        return {"service": SERVICE, "now": current, "start": start, "end": end, "bucketMs": step,
                "hostname": socket.gethostname(), "relay": self.config["relay_ip"], "source": self.config["source_ip"],
                "retentionDays": self.config["retention_days"], "routes": entries,
                "pingTimeoutMs": self.config["ping_timeout_ms"], "httpTimeoutSeconds": self.config["http_timeout_seconds"],
                "events": [r for r in reversed(rows) if r["status"] != "ok"][:15]}

    def close(self):
        self.stopping.set()
        for thread in self.threads:
            thread.join(timeout=20)
        self.history.close()


class DashboardServer(ThreadingHTTPServer):
    daemon_threads = True
    allow_reuse_address = False


def make_handler(monitor):
    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *_):
            pass

        def allowed(self):
            host = self.headers.get("Host", "")
            expected = {"127.0.0.1:" + str(self.server.server_port), "localhost:" + str(self.server.server_port)}
            return host in expected and self.headers.get("Sec-Fetch-Site") != "cross-site"

        def send(self, code, content, content_type="application/json; charset=utf-8", attachment=None):
            raw = content if isinstance(content, bytes) else content.encode("utf-8")
            self.send_response(code)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(raw)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Content-Security-Policy", "default-src 'self'; script-src 'self'; style-src 'self'; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'")
            if attachment:
                self.send_header("Content-Disposition", 'attachment; filename="' + attachment + '"')
            self.end_headers()
            self.wfile.write(raw)

        def do_GET(self):
            if not self.allowed():
                return self.send(403, '{}')
            url = urlsplit(self.path)
            if url.path == "/api/health":
                return self.send(200, json.dumps({"service": SERVICE, "pid": os.getpid()}))
            if url.path in ("/api/snapshot", "/api/export"):
                try:
                    query = parse_qs(url.query)
                    seconds = int(query.get("seconds", [900])[0])
                    end = int(query.get("end", [now_ms()])[0])
                    if seconds not in (300, 900, 3600, 21600, 86400) or not 0 < end <= now_ms() + 10000:
                        raise ValueError("Invalid range")
                except (ValueError, OverflowError):
                    return self.send(400, '{"error":"invalid range"}')
                if url.path == "/api/snapshot":
                    return self.send(200, json.dumps(monitor.snapshot(seconds, end), ensure_ascii=False, allow_nan=False))
                rows = monitor.history.read(end - seconds * 1000, end)
                buffer = io.StringIO(newline="")
                writer = csv.DictWriter(buffer, fieldnames=["ts", "route", "status", "rtt", "detail"])
                writer.writeheader()
                writer.writerows(rows)
                return self.send(200, b"\xef\xbb\xbf" + buffer.getvalue().encode("utf-8"),
                                 "text/csv; charset=utf-8", "mth-network-" + str(end) + ".csv")
            paths = {"/": "index.html", "/app.js": "app.js", "/style.css": "style.css"}
            if url.path not in paths:
                return self.send(404, '{}')
            filename = paths[url.path]
            mime = {"html": "text/html", "js": "text/javascript", "css": "text/css"}[filename.split('.')[-1]]
            return self.send(200, (ROOT / "web" / filename).read_bytes(), mime + "; charset=utf-8")

        def do_POST(self):
            if not self.allowed() or self.headers.get("X-MTH-Control") != "local":
                return self.send(403, '{}')
            if self.path != "/api/shutdown":
                return self.send(404, '{}')
            self.send(200, '{"stopping":true}')
            threading.Thread(target=self.server.shutdown, daemon=True).start()

    return Handler


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", default=str(ROOT / "config.json"))
    parser.add_argument("--data-dir", default=str(ROOT.parents[1] / ".build" / "network-monitor"))
    args = parser.parse_args()
    config = load_config(args.config)
    data_dir = Path(args.data_dir)
    data_dir.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(level=logging.WARNING, handlers=[RotatingFileHandler(
        data_dir / "monitor.log", maxBytes=1024 * 1024, backupCount=2, encoding="utf-8")])
    monitor = Monitor(config, data_dir)
    server = DashboardServer(("127.0.0.1", config["port"]), make_handler(monitor))
    try:
        monitor.start()
        server.serve_forever(poll_interval=.25)
    finally:
        server.server_close()
        monitor.close()


if __name__ == "__main__":
    main()
