---
description: "Use when working on MikroTik backup automation in this workspace. Routers: isp=172.26.0.1 and backend=172.26.32.1. Username is always admin. Passwords must be loaded from the workspace .env file."
applyTo: "scripts/**/*.py"
---

# MikroTik backup context

- Router `isp` IP: `172.26.0.1`
- Router `backend` IP: `172.26.32.1`
- Router user: `admin`
- Password source: workspace `.env`

When editing backup scripts in this repository:
- Keep raw exports in `config/raw/`.
- Keep sanitized exports in `config/sanitized/`.
- Never write plaintext credentials to files tracked by git.
