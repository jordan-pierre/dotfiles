#!/usr/bin/env python3
"""
PreToolUse guard hook for Claude Code.

Bash tool:
  Block outright: rm -rf targeting home/root/system paths, sudo + destructive combos,
                  any command touching ~/Documents
  Confirm:        rm -rf in project dir, writes/moves outside cwd, sudo generally,
                  git destructive ops

Write / Edit / Read tools:
  Block outright: any file path under ~/Documents
"""

import json
import os
import re
import sys
from pathlib import Path

data = json.load(sys.stdin)
tool_name = data.get("tool_name", "")
tool_input = data.get("tool_input", {})
cwd = data.get("cwd", os.getcwd())

DOCUMENTS = str(Path.home() / "Documents")


def deny(reason: str) -> None:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": f"[guard] BLOCKED: {reason}",
        }
    }))
    sys.exit(0)


def ask(reason: str) -> None:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": f"[guard] {reason}",
        }
    }))
    sys.exit(0)


# ── File tools: Write, Edit, Read ─────────────────────────────────────────────

if tool_name in ("Write", "Edit", "Read"):
    file_path = str(Path(tool_input.get("file_path", "")).expanduser().resolve())
    if file_path.startswith(DOCUMENTS):
        deny(f"Access to ~/Documents is not permitted.\nPath: {file_path}")
    sys.exit(0)


# ── Bash tool ─────────────────────────────────────────────────────────────────

if tool_name != "Bash":
    sys.exit(0)

command = tool_input.get("command", "")

# Block outright
BLOCK_PATTERNS = [
    # Anything referencing ~/Documents or $HOME/Documents
    (r"(~/Documents|[\"']?" + re.escape(DOCUMENTS) + r"[\"']?)",
     "Access to ~/Documents is not permitted."),
    # rm -rf targeting home, root, or system dirs
    (r"rm\s+(-\S*r\S*f|-\S*f\S*r)\s+(~[/\s]|~$|/home|/root|/usr|/etc|/var|/bin|/sbin|/lib|/boot|/sys|/proc)",
     "Recursive delete targeting system or home directory is not allowed."),
    # sudo rm anything
    (r"sudo\s+rm\b",
     "sudo rm is not allowed."),
    # sudo chmod/chown -R on system paths
    (r"sudo\s+(chmod|chown)\s+-R\s+/",
     "Recursive privilege change on system paths is not allowed."),
]

for pattern, reason in BLOCK_PATTERNS:
    if re.search(pattern, command):
        deny(f"{reason}\nCommand: {command}")

# Confirm
CONFIRM_PATTERNS = [
    (r"rm\s+(-\S*r\S*f|-\S*f\S*r)",
     "Recursive delete detected."),
    (r"\bsudo\b",
     "sudo usage requires confirmation."),
    (r"git\s+(reset\s+--hard|clean\s+-\S*f|push\s+.*--force)",
     "Destructive git operation detected."),
    (r"(mv|cp|tee|>\s*|>>)\s+(/(?!" + re.escape(cwd.lstrip("/")) + r"))",
     "Write or move targeting a path outside the project directory."),
]

for pattern, reason in CONFIRM_PATTERNS:
    if re.search(pattern, command):
        ask(f"{reason}\nCommand: {command}")

sys.exit(0)
