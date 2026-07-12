#!/usr/bin/env python3

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def load_dotenv(dotenv_path: Path) -> None:
    if not dotenv_path.exists():
        return

    for raw_line in dotenv_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        if not key:
            continue
        os.environ.setdefault(key, value.strip())


def sanitize_config(text: str) -> str:
    replacements = [
        (
            re.compile(
                r'(?i)\b(password|passphrase|secret|token|api[-_]?key|private-key|public-key|preshared-key|key-file)\s*=\s*(\\\s*\n\s*)?(".*?"|\S+)'
            ),
            r"\1=__REDACTED__",
        ),
        (
            re.compile(
                r'(?i)(:local\s+\S*(pass|secret|token|key|user)\S*\s+)(\\?"[^"\n]*\\?"|\S+)'
            ),
            r'\1"__REDACTED__"',
        ),
        (
            re.compile(
                r'(?i)(:?local\s+ddns(user|pass|host)\s+)(\\"[^"\n]*\\"|\\?"[^"\n]*\\?"|\S+)'
            ),
            r'\1"__REDACTED__"',
        ),
        (
            re.compile(r"(?i)(\buser=\s*)(\\\s*\n\s*)?\S+"),
            r"\1__REDACTED__",
        ),
        (
            re.compile(r"(?i)(mac-address=\s*)(\\\s*\n\s*)?[0-9A-F:]{17}"),
            r"\1__REDACTED__",
        ),
        (re.compile(r"(?i)(#\s*serial number\s*=\s*).+"), r"\1__REDACTED__"),
        (re.compile(r'(?i)(url=)"[^"]+"'), r'\1"__REDACTED_URL__"'),
    ]

    updated = text
    for pattern, replacement in replacements:
        updated = pattern.sub(replacement, updated)
    return updated if updated.endswith("\n") else updated + "\n"


def export_router(name: str, host: str, password: str) -> str:
    cmd = [
        "sshpass",
        "-p",
        password,
        "ssh",
        "-o",
        "StrictHostKeyChecking=accept-new",
        "-o",
        "ConnectTimeout=10",
        f"admin@{host}",
        "/export show-sensitive",
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(
            f"Failed to export {name} ({host}). ssh exit code {result.returncode}.\n"
            f"stderr:\n{result.stderr.strip()}"
        )
    if not result.stdout.strip():
        raise RuntimeError(f"Export for {name} ({host}) returned empty output.")
    return result.stdout


def main() -> int:
    if shutil.which("sshpass") is None:
        print("Error: sshpass is required but not installed.", file=sys.stderr)
        print("Install it with: sudo apt install sshpass", file=sys.stderr)
        return 1

    repo_root = Path(__file__).resolve().parent.parent
    load_dotenv(repo_root / ".env")

    routers = {
        "isp": {
            "host": os.getenv("ROUTER_ISP_HOST", "172.26.0.1"),
            "password": os.getenv("ROUTER_ISP_PASSWORD", ""),
        },
        "backend": {
            "host": os.getenv("ROUTER_BACKEND_HOST", "172.26.32.1"),
            "password": os.getenv("ROUTER_BACKEND_PASSWORD", ""),
        },
    }

    missing_passwords = [name for name, cfg in routers.items() if not cfg["password"]]
    if missing_passwords:
        print(
            "Error: missing passwords in .env for: " + ", ".join(missing_passwords),
            file=sys.stderr,
        )
        print(
            "Expected variables: ROUTER_ISP_PASSWORD, ROUTER_BACKEND_PASSWORD",
            file=sys.stderr,
        )
        return 1

    raw_dir = repo_root / "config" / "raw"
    sanitized_dir = repo_root / "config" / "sanitized"
    raw_dir.mkdir(parents=True, exist_ok=True)
    sanitized_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")

    for name, cfg in routers.items():
        host = str(cfg["host"])
        password = str(cfg["password"])
        raw_text = export_router(name, host, password)

        raw_path = raw_dir / f"{name}-{timestamp}.rsc"
        raw_path.write_text(raw_text, encoding="utf-8")

        sanitized_text = sanitize_config(raw_text)
        sanitized_path = sanitized_dir / f"{name}-{timestamp}.sanitized.rsc"
        sanitized_path.write_text(sanitized_text, encoding="utf-8")

        print(f"[ok] {name}: raw={raw_path} sanitized={sanitized_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
