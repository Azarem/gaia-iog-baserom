#!/usr/bin/env python3
"""Minimal stdio client for the Mesen2 MCP host (server 0.5.0+), for harness scenarios and CI-style runs.

It speaks newline-delimited JSON-RPC (the framing the host uses) and returns tool results as parsed
JSON where the server returns JSON text. It exists so that a scenario can be run from a shell with no
IDE attached; inside Cursor the same tool calls are made through the registered MCP server.

usage (library):
    from mcp_client import Mesen
    with Mesen() as m:
        m.call("load_rom", path=...)
"""
import base64
import json
import os
import queue
import re
import subprocess
import threading
import time

DEFAULT_HOST = r"C:\Work\mesen2-mcp\McpHost\bin\Release\net8.0\MesenMcpHost.dll"


class McpError(RuntimeError):
    def __init__(self, tool, payload):
        super().__init__(f"{tool}: {payload}")
        self.tool = tool
        self.payload = payload


class ScriptRunError(RuntimeError):
    def __init__(self, tool, message):
        super().__init__(f"{tool}: {message}")
        self.tool = tool


class Mesen:
    def __init__(self, host=DEFAULT_HOST, args=(), debug=False):
        env = dict(os.environ, MESEN_MCP_DEBUG="1" if debug else "0")
        self.proc = subprocess.Popen(["dotnet", host, *args], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE, env=env)
        self.stderr_lines = []
        threading.Thread(target=self._drain, daemon=True).start()
        self._lines = queue.Queue()
        threading.Thread(target=self._read_stdout, daemon=True).start()
        self._id = 0
        self.notifications = []
        self.non_json = []
        init = self._rpc("initialize", {"protocolVersion": "2024-11-05", "capabilities": {},
                                        "clientInfo": {"name": "gaia-harness", "version": "1"}})
        self.server_info = init["result"].get("serverInfo", {})
        self._send({"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}})

    # -- transport -------------------------------------------------------------------------------
    def _drain(self):
        for line in self.proc.stderr:
            self.stderr_lines.append(line.decode("utf-8", "replace").rstrip())

    def _send(self, msg):
        self.proc.stdin.write((json.dumps(msg) + "\n").encode())
        self.proc.stdin.flush()

    def _read_stdout(self):
        for line in self.proc.stdout:
            self._lines.put(line)
        self._lines.put(None)

    def _objects(self, text):
        """Yield every JSON object on a line. The host can glue two objects together or put a
        `Content-Length: n` header in front of the first one when a ROM is preloaded (T-20)."""
        dec = json.JSONDecoder()
        i = text.find("{")
        while 0 <= i < len(text):
            try:
                obj, j = dec.raw_decode(text, i)
            except json.JSONDecodeError:
                self.non_json.append(text[i:i + 200])
                return
            yield obj
            i = text.find("{", j)

    def _rpc(self, method, params=None, timeout=1800):
        self._id += 1
        msg = {"jsonrpc": "2.0", "id": self._id, "method": method}
        if params is not None:
            msg["params"] = params
        self._send(msg)
        deadline = time.time() + timeout
        while True:
            left = deadline - time.time()
            if left <= 0:
                raise TimeoutError(f"timeout waiting for {method} ({timeout}s)")
            try:
                line = self._lines.get(timeout=left)
            except queue.Empty:
                raise TimeoutError(f"timeout waiting for {method} ({timeout}s)") from None
            if line is None:
                raise RuntimeError("host closed stdout; stderr: " + " | ".join(self.stderr_lines[-5:]))
            text = line.decode("utf-8", "replace").strip()
            if not text:
                continue
            if "{" not in text:
                self.non_json.append(text)
                continue
            for payload in self._objects(text):
                if payload.get("id") == self._id and ("result" in payload or "error" in payload):
                    self._pending_done = True
                    result = payload
                else:
                    self.notifications.append(payload)
            if getattr(self, "_pending_done", False):
                self._pending_done = False
                return result

    # -- tools -----------------------------------------------------------------------------------
    def tools(self):
        return self._rpc("tools/list")["result"]["tools"]

    def raw(self, tool, **arguments):
        """Return (isError, text, content[]) without raising."""
        resp = self._rpc("tools/call", {"name": tool, "arguments": arguments})
        if "error" in resp:
            return True, json.dumps(resp["error"]), []
        result = resp["result"]
        text = "\n".join(c.get("text", "") for c in result.get("content", []) if c.get("type") == "text")
        return result.get("isError", False), text, result.get("content", [])

    def call(self, tool, **arguments):
        """Return the parsed JSON result (or the text when it is not JSON). Raises McpError on isError."""
        err, text, _ = self.raw(tool, **arguments)
        try:
            data = json.loads(text)
        except (json.JSONDecodeError, TypeError):
            data = text
        if err:
            raise McpError(tool, data)
        return data

    # Lua errors reach the caller only as log rows (T-24, MCP-34): `se:1: syntax error near 'is'`, `re:1: boom`.
    _LUA_ERROR = re.compile(r"(^|\s)[\w.\-]+:\d+:\s|syntax error|attempt to |stack traceback|Maximum execution time", re.I)
    _LOG_CUT = re.compile(r"buffer .*full|may have been cut|truncat", re.I)

    def run_script_checked(self, code, ok_stop=("script_done",), **kw):
        """`run_script` that cannot fail silently. Returns the reply; raises ScriptRunError when

        - `stopReason` is not in `ok_stop` (default only `script_done`: a frame budget that ran out is a failure for a
          scenario that ends itself with `kit.finish` / `final`), or
        - a log row looks like a Lua error (syntax or runtime; the server returns `isError:false` for both, T-24), or
        - the reply has no result although the script was expected to produce one (`hasResult` false).

        A log row that reports the 100,000-byte script-output cap (T-31) is returned in `reply["__warnings__"]` and
        printed; check `filesWritten` against the expected size before trusting a census file.
        """
        reply = self.call("run_script", code=code, **kw)
        if not isinstance(reply, dict):
            raise ScriptRunError("run_script", f"non-JSON reply: {str(reply)[:300]}")
        rows = [e.get("text", "") for e in (reply.get("log") or {}).get("entries", [])]
        errs = [t for t in rows if self._LUA_ERROR.search(t)]
        warns = [t for t in rows if self._LOG_CUT.search(t)]
        reply["__warnings__"] = warns
        for w in warns:
            print("WARNING (script log cap, T-31):", w)
        if errs:
            raise ScriptRunError("run_script", "Lua error: " + " | ".join(errs[:3]))
        if reply.get("stopReason") not in ok_stop:
            raise ScriptRunError("run_script", f"stopReason {reply.get('stopReason')!r} (expected {ok_stop}); last log rows: {rows[-3:]}")
        if "hasResult" in reply and not reply["hasResult"]:
            raise ScriptRunError("run_script", "script ended without emu.mcp.result / kit.finish")
        return reply

    def try_call(self, tool, **arguments):
        try:
            return self.call(tool, **arguments)
        except McpError as e:
            return {"__error__": e.payload}

    # -- memory helpers (WRAM offsets by default; see plan section 2.3) ------------------------------
    def mem(self, addr, length, type="workRam"):
        """Read up to 65536 bytes as `bytes` (read_memory format=base64)."""
        out = bytearray()
        while length > 0:
            n = min(length, 65536)
            r = self.call("read_memory", address=addr, length=n, type=type, format="base64")
            out += base64.b64decode(r["data"])
            addr += n
            length -= n
        return bytes(out)

    def u8(self, addr, type="workRam"):
        return self.mem(addr, 1, type)[0]

    def u16(self, addr, type="workRam"):
        b = self.mem(addr, 2, type)
        return b[0] | (b[1] << 8)

    def poke(self, addr, data, type="workRam"):
        """Write an int (as 2 bytes LE) or a bytes/list."""
        if isinstance(data, int):
            data = [data & 0xFF, (data >> 8) & 0xFF]
        return self.call("write_memory", address=addr, data=list(data), type=type)

    def shot(self, label, **kw):
        """Screenshot to <results>/screenshots/<label>_<frame>.png without returning the image."""
        return self.call("take_screenshot", label=label, returnImage=False, **kw)

    # -- lifecycle -------------------------------------------------------------------------------
    def close(self):
        try:
            self.call("stop", exitCode=0)
        except Exception:
            pass
        try:
            self.proc.stdin.close()
        except Exception:
            pass
        try:
            return self.proc.wait(timeout=15)
        except subprocess.TimeoutExpired:
            self.proc.kill()
            return None

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()
