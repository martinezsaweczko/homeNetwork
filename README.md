# Network Evolution Project

This repository documents and automates the evolution of a home/lab network toward a more professional, maintainable setup.

## Main Purpose

Build the network step by step into a cleaner and more professional architecture, while keeping operations simple and safe.

Current high-level approach:
- **Room A router (ISP edge)** handles WAN, NAT, and Internet-facing firewalling.
- **Room B router (rack side)** handles internal routing/firewalling for rack networks.
- **Managed switch in the rack** provides VLAN-based segmentation for servers and other devices.

## Repository Structure

- `.github/instructions/mikrotik-backup.instructions.md`
  Workspace instructions for router backup automation context.
- `scripts/backup_mikrotik_configs.py`
  Pulls config exports from routers and produces sanitized versions.
- `config/raw/`
  Raw exports (sensitive, not tracked by git).
- `config/sanitized/`
  Sanitized exports intended for version control review.
- `.env`
  Local credentials file (ignored by git).

## Automated Router Backup & Sanitization

The script connects to:
- `isp`: `172.26.0.1`
- `backend`: `172.26.32.1`
- user: `admin`

Passwords are loaded from `.env`.

### 1) Configure `.env`

Create/update:

```env
ROUTER_ISP_PASSWORD=your_password_here
ROUTER_BACKEND_PASSWORD=your_password_here
```

Optional host overrides:

```env
ROUTER_ISP_HOST=172.26.0.1
ROUTER_BACKEND_HOST=172.26.32.1
```

### 2) Run backup

```bash
./scripts/backup_mikrotik_configs.py
```

Output:
- raw: `config/raw/<router>-<timestamp>.rsc`
- sanitized: `config/sanitized/<router>-<timestamp>.sanitized.rsc`

## Security Rules

- Never commit `config/raw/`.
- Never commit real credentials.
- Review sanitized files before commit.
- If a secret is ever exposed, rotate it immediately.

## Professionalization Roadmap (Practical)

1. Keep **single NAT boundary** at ISP edge router.
2. Use **clear VLAN segmentation** (management, servers, users, optional guest/iot).
3. Enforce **least-privilege firewall rules** between VLANs.
4. Centralize and version-control **sanitized config snapshots**.
5. Add monitoring/observability (latency, packet loss, service reachability).
6. Document each change with before/after notes.

## Notes

This repo is meant to evolve with the network. Keep changes incremental, tested, and easy to roll back.
