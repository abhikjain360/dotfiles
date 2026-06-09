#!/usr/bin/env python3
import json
import os
import shlex
import sys
from pathlib import Path


HOOK_MARKER = "CODEX_NIX_HOOK_ACTIVE"


def find_flake_root(start: Path) -> Path | None:
    path = start.resolve()
    for candidate in (path, *path.parents):
        if (candidate / "flake.nix").is_file():
            return candidate
    return None


def already_routed(command: str) -> bool:
    stripped = command.lstrip()
    return (
        stripped.startswith("CODEX_NIX_WRAPPER_ACTIVE=")
        or stripped.startswith("nix develop ")
        or stripped.startswith("direnv exec ")
        or stripped.startswith("env CODEX_NIX_HOOK_ACTIVE=")
        or stripped.startswith("env CODEX_NIX_WRAPPER_ACTIVE=")
        or stripped.startswith("CODEX_NIX_HOOK_ACTIVE=")
    )


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0

    tool_input = event.get("tool_input")
    if not isinstance(tool_input, dict):
        return 0

    command_key = "command" if "command" in tool_input else "cmd"
    command = tool_input.get(command_key)
    if not isinstance(command, str) or not command.strip():
        return 0

    if os.environ.get("IN_NIX_SHELL") or os.environ.get(HOOK_MARKER):
        return 0

    if already_routed(command):
        return 0

    cwd_value = tool_input.get("workdir") or tool_input.get("cwd") or event.get("cwd")
    if not isinstance(cwd_value, str) or not cwd_value:
        cwd_value = os.getcwd()

    cwd = Path(cwd_value).expanduser()
    flake_root = find_flake_root(cwd)
    if flake_root is None:
        return 0

    inner = f"cd {shlex.quote(str(cwd.resolve()))} && {command}"
    routed_env = (
        f"{HOOK_MARKER}=1 "
    )
    if (flake_root / ".envrc").is_file():
        routed = (
            f"{routed_env} direnv exec {shlex.quote(str(flake_root))} "
            f"bash -c {shlex.quote(inner)}"
        )
    else:
        routed = (
            f"{routed_env} nix develop {shlex.quote(str(flake_root))} "
            f"--command bash -c {shlex.quote(inner)}"
        )
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
            "updatedInput": {command_key: routed},
        }
    }
    print(json.dumps(output, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
