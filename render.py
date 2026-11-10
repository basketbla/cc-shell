#!/usr/bin/env python3
"""Render `claude -p --output-format stream-json` inline in a terminal."""
import json, sys

DIM, ORANGE, RED, RESET = "\033[2m", "\033[38;5;208m", "\033[31m", "\033[0m"
at_line_start = True


def out(s):
    global at_line_start
    if s:
        sys.stdout.write(s)
        sys.stdout.flush()
        at_line_start = s.endswith("\n")


def newline():
    if not at_line_start:
        out("\n")


def tool_summary(name, inp):
    for key in ("command", "file_path", "pattern", "url", "query", "description", "prompt"):
        if key in inp:
            v = str(inp[key]).split("\n")[0]
            return f"{name}: {v[:100]}{'…' if len(v) > 100 else ''}"
    return name


for raw in sys.stdin:
    try:
        ev = json.loads(raw)
    except ValueError:
        newline(); out(f"{DIM}{raw.rstrip()}{RESET}\n")
        continue
    t = ev.get("type")
    if t == "stream_event" and not ev.get("parent_tool_use_id"):
        e = ev.get("event", {})
        if e.get("type") == "content_block_delta" and e.get("delta", {}).get("type") == "text_delta":
            out(e["delta"]["text"])
        elif e.get("type") == "message_stop":
            newline()
    elif t == "assistant" and not ev.get("parent_tool_use_id"):
        for b in ev.get("message", {}).get("content", []):
            if b.get("type") == "tool_use":
                newline(); out(f"{DIM}  ↳ {tool_summary(b['name'], b.get('input', {}))}{RESET}\n")
    elif t == "result":
        newline()
        if ev.get("is_error") or ev.get("subtype") != "success":
            out(f"{RED}{ev.get('result') or ev.get('subtype')}{RESET}\n")
newline()
