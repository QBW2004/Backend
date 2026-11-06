import json
from pathlib import Path
import socket
import tempfile
import threading
import time
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from monitor import (DashboardServer, Monitor, load_config, make_handler, now_ms,
                     parse_remote_sample, source_script)
from probes import WindowsPing, http_probe, result
from storage import History, bucket_points, summarize


def row(ts, status="ok", rtt=10):
    return {"ts": ts, "status": status, "rtt": rtt if status == "ok" else None,
            "route": "local_relay", "detail": "fixture"}


class StatisticsTests(unittest.TestCase):
    def test_missing_and_collector_errors_do_not_become_packet_loss(self):
        stats = summarize([row(0), row(2000, "unknown"), row(4000, "failed")], 2000)
        self.assertEqual((stats["sent"], stats["received"], stats["failed"], stats["unknown"], stats["loss"]), (2, 1, 1, 1, 50))

    def test_no_samples_or_only_collector_errors_have_no_loss_percentage(self):
        for rows in ([], [row(0, "unknown")]):
            self.assertIsNone(summarize(rows, 2000)["loss"])
            self.assertIsNone(summarize(rows, 2000)["avg"])

    def test_p95_is_nearest_rank_and_jitter_does_not_bridge_missing_time(self):
        rows = [row(i * 2000, rtt=i + 1) for i in range(20)]
        self.assertEqual(summarize(rows, 2000)["p95"], 19)
        self.assertEqual(summarize(rows, 2000)["jitter"], 1)
        self.assertIsNone(summarize([row(0), row(10000, rtt=300)], 2000)["jitter"])
        self.assertIsNone(summarize([row(0), row(2000, "failed"), row(4000)], 2000)["jitter"])

    def test_zero_rtt_is_valid_and_failed_latest_does_not_reuse_latency(self):
        stats = summarize([row(0, rtt=0), row(2000, "failed")], 2000)
        self.assertEqual(stats["min"], 0)
        self.assertIsNone(stats["latest"]["rtt"])

    def test_buckets_keep_gaps_failures_and_peaks(self):
        rows = [row(100, rtt=10), row(200, rtt=90), row(500, "failed"), row(2100, "unknown")]
        points = bucket_points(rows, 0, 3000, 1000)
        self.assertEqual((points[0]["avg"], points[0]["max"], points[0]["sent"]), (50, 90, 3))
        self.assertIsNone(points[1]["avg"])
        self.assertIsNone(points[1]["loss"])
        self.assertEqual(points[2]["unknown"], 1)
        self.assertIsNone(points[2]["loss"])


class RemoteTests(unittest.TestCase):
    def test_reported_rtt_excludes_ssh_delivery_time(self):
        data = parse_remote_sample(json.dumps({"ts": 1000, "status": "ok", "rtt": 35}), 1100)
        self.assertEqual(data["rtt"], 35)

    def test_stale_remote_report_is_not_a_probe_failure(self):
        data = parse_remote_sample(json.dumps({"ts": 1000, "status": "ok", "rtt": 35}), 20000)
        self.assertEqual(data["status"], "unknown")
        self.assertIsNone(data["rtt"])

    def test_invalid_rtt_and_status_rejected(self):
        for rtt in (None, -1, 999999, "35"):
            with self.assertRaises(ValueError):
                parse_remote_sample(json.dumps({"ts": 1000, "status": "ok", "rtt": rtt}), 1000)
        with self.assertRaises(ValueError):
            parse_remote_sample('{"ts":1000,"status":"invented"}', 1000)

    def test_config_rejects_shell_injection_and_invalid_intervals(self):
        config = load_config(Path(__file__).with_name("config.json"))
        for key, value in (("source_ssh_alias", "x; whoami"), ("relay_ip", "x'"), ("http_interval_seconds", 0)):
            with tempfile.TemporaryDirectory() as path:
                file = Path(path) / "config.json"
                file.write_text(json.dumps({**config, key: value}))
                with self.assertRaises(ValueError):
                    load_config(file)
        self.assertIn("$ping.Send('185.180.17.57'", source_script(config))


class StorageTests(unittest.TestCase):
    def test_restart_query_boundaries_and_retention(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "history.sqlite3"
            store = History(path)
            for ts in (1000, 2000, 3000):
                store.add("local_relay", ts, result("ok", 10))
            store.close()
            store = History(path)
            self.assertEqual(len(store.read(2000, 3000)), 2)
            store.prune(2000)
            self.assertEqual([r["ts"] for r in store.read(0, 9000)], [2000, 3000])
            store.close()


class ProbeTests(unittest.TestCase):
    def test_actual_windows_icmp_loopback(self):
        probe = WindowsPing()
        try:
            response = probe.send("127.0.0.1", 1000)
            self.assertEqual(response["status"], "ok")
            self.assertGreaterEqual(response["rtt"], 0)
        finally:
            probe.close()

    def test_http_uses_head_and_treats_login_redirect_as_success(self):
        requests = []
        class Endpoint(BaseHTTPRequestHandler):
            def do_HEAD(self):
                requests.append(self.command)
                self.send_response(self.server.reply_code)
                self.end_headers()
            def log_message(self, *_):
                pass
        server = ThreadingHTTPServer(("127.0.0.1", 0), Endpoint)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        try:
            server.reply_code = 302
            self.assertEqual(http_probe("127.0.0.1", server.server_port, 1)["status"], "ok")
            server.reply_code = 503
            response = http_probe("127.0.0.1", server.server_port, 1)
            self.assertEqual(response["status"], "failed")
            self.assertIsNone(response["rtt"])
            self.assertEqual(requests, ["HEAD", "HEAD"])
        finally:
            server.shutdown()
            server.server_close()

    def test_http_refused_connection_is_request_failure(self):
        with socket.socket() as sock:
            sock.bind(("127.0.0.1", 0))
            response = http_probe("127.0.0.1", sock.getsockname()[1], .2)
        self.assertEqual(response["status"], "failed")


class HttpApiTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.monitor = Monitor(load_config(Path(__file__).with_name("config.json")), Path(self.temp.name))
        self.monitor.record("local_relay", result("ok", 75))
        self.server = DashboardServer(("127.0.0.1", 0), make_handler(self.monitor))
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.url = "http://127.0.0.1:" + str(self.server.server_port)

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.monitor.close()
        self.temp.cleanup()

    def test_snapshot_real_json_and_bounded_history(self):
        with urlopen(self.url + "/api/snapshot?seconds=300") as response:
            body = json.load(response)
            self.assertEqual(body["routes"][0]["stats"]["received"], 1)
            self.assertTrue(body["routes"][1]["health"]["stale"])
            self.assertIsNone(body["routes"][1]["stats"]["loss"])
            self.assertIn("frame-ancestors 'none'", response.headers["Content-Security-Policy"])
        for query in ("seconds=99999999", "seconds=bad", "end=-1"):
            with self.assertRaises(HTTPError) as err:
                urlopen(self.url + "/api/snapshot?" + query)
            self.assertEqual(err.exception.code, 400)
            err.exception.close()

    def test_csv_has_real_raw_samples_and_static_traversal_is_rejected(self):
        with urlopen(self.url + "/api/export?seconds=300") as response:
            body = response.read().decode("utf-8-sig")
            self.assertIn("local_relay,ok,75", body)
            self.assertIn("attachment", response.headers["Content-Disposition"])
        with self.assertRaises(HTTPError) as err:
            urlopen(self.url + "/../config.json")
        self.assertEqual(err.exception.code, 404)
        err.exception.close()

    def test_cross_site_and_foreign_host_are_rejected(self):
        for headers in ({"Host": "attacker.example"}, {"Sec-Fetch-Site": "cross-site"}):
            with self.assertRaises(HTTPError) as err:
                urlopen(Request(self.url + "/api/snapshot", headers=headers))
            self.assertEqual(err.exception.code, 403)
            err.exception.close()
        with self.assertRaises(HTTPError) as err:
            urlopen(Request(self.url + "/api/shutdown", method="POST"))
        self.assertEqual(err.exception.code, 403)
        err.exception.close()

    def test_authenticated_local_shutdown_returns_before_stopping(self):
        request = Request(self.url + "/api/shutdown", method="POST", headers={"X-MTH-Control": "local"})
        with urlopen(request) as response:
            self.assertTrue(json.load(response)["stopping"])
        self.thread.join(2)
        self.assertFalse(self.thread.is_alive())


if __name__ == "__main__":
    unittest.main(verbosity=2)
