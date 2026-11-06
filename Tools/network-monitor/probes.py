"""Network measurements. Probe failures and collector failures are distinct."""
import ctypes
import http.client
import socket
import ssl
import struct
import time


def result(status, rtt=None, detail=""):
    return {"status": status, "rtt": rtt, "detail": detail}


class WindowsPing:
    def __init__(self):
        self.api = ctypes.WinDLL("iphlpapi", use_last_error=True)
        self.api.IcmpCreateFile.restype = ctypes.c_void_p
        self.api.IcmpCloseHandle.argtypes = [ctypes.c_void_p]
        self.api.IcmpSendEcho.argtypes = [
            ctypes.c_void_p, ctypes.c_uint32, ctypes.c_void_p, ctypes.c_ushort,
            ctypes.c_void_p, ctypes.c_void_p, ctypes.c_uint32, ctypes.c_uint32,
        ]
        self.api.IcmpSendEcho.restype = ctypes.c_uint32
        self.handle = self.api.IcmpCreateFile()
        if self.handle in (None, ctypes.c_void_p(-1).value):
            raise OSError("ICMP handle unavailable")

    def send(self, address, timeout_ms):
        payload = ctypes.create_string_buffer(b"MTH-network-observation".ljust(32, b"."))
        reply = ctypes.create_string_buffer(512)
        target = struct.unpack("<I", socket.inet_aton(address))[0]
        count = self.api.IcmpSendEcho(self.handle, target, payload, 32, None,
                                      reply, len(reply), timeout_ms)
        code = struct.unpack_from("<I", reply, 4)[0] if count else ctypes.get_last_error()
        if code == 0 and count:
            return result("ok", struct.unpack_from("<I", reply, 8)[0], "ICMP reply")
        # Local API/resource errors are not transmitted packet losses.
        if code == 11010 or code in (11002, 11003, 11004, 11005, 11013):
            return result("failed", detail="ICMP status " + str(code))
        return result("unknown", detail="ICMP collector error " + str(code))

    def close(self):
        if self.handle:
            self.api.IcmpCloseHandle(self.handle)
            self.handle = None


class PinnedHTTPSConnection(http.client.HTTPSConnection):
    """Connect to the verified relay IP, retaining TLS SNI/certificate validation."""
    def __init__(self, hostname, address, timeout):
        super().__init__(hostname, timeout=timeout, context=ssl.create_default_context())
        self.address = address

    def connect(self):
        began = time.perf_counter()
        raw = socket.create_connection((self.address, self.port), self.timeout)
        try:
            raw.settimeout(max(.01, self.timeout - (time.perf_counter() - began)))
            self.sock = self._context.wrap_socket(raw, server_hostname=self.host)
        except BaseException:
            raw.close()
            raise


def http_probe(host, port, timeout, address=None):
    connection = (PinnedHTTPSConnection(host, address, timeout) if address else
                  http.client.HTTPConnection(host, port, timeout=timeout))
    began = time.perf_counter()
    try:
        # HEAD / is the anonymous login redirect: no account, SQL query or gameplay.
        connection.request("HEAD", "/", headers={
            "User-Agent": "UnityPlayer/2021.3 (MTH Network Monitor)",
            "Connection": "close", "Cache-Control": "no-cache",
        })
        remaining = timeout - (time.perf_counter() - began)
        if remaining <= 0:
            raise TimeoutError("request deadline")
        connection.sock.settimeout(remaining)
        response = connection.getresponse()
        elapsed = round((time.perf_counter() - began) * 1000, 2)
        status = "ok" if response.status in (200, 301, 302, 303, 307, 308) else "failed"
        return result(status, elapsed if status == "ok" else None,
                      "HTTP " + str(response.status))
    except (OSError, http.client.HTTPException) as exc:
        return result("failed", detail=type(exc).__name__)
    finally:
        connection.close()
