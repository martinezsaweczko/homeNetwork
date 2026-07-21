# Network Evolution Project

This repository documents and automates the evolution of a home/lab network toward a more professional, maintainable setup.

## Main Purpose

Build the network step by step into a cleaner and more professional architecture, while keeping operations simple and safe.

Current high-level approach:
- **Room A router (ISP edge)** handles WAN, NAT, and Internet-facing firewalling.
- **Room B router (rack side)** handles internal routing/firewalling for rack networks.
- **Managed switch in the rack** provides VLAN-based segmentation for servers and other devices.

## Current Migration Status

Completed:
- [x] Disabled legacy chained NAT path to backend transit IP (`172.26.40.2`) on ISP.
- [x] Disabled legacy backend `dstnat` publish rules from `UPLINK-A`.
- [x] Moved WAN publishing on ISP to VLAN20 webserver (`172.26.20.254`, ports `443` and `4000`).
- [x] Added/cleaned static routes on ISP to Room B networks via `172.26.40.2`:
  - `172.26.10.0/24`
  - `172.26.20.0/24`
  - `172.26.30.0/24`
  - `172.26.32.0/24`
- [x] Created backend VLAN L3 gateways and DHCP scopes:
  - VLAN10 MGMT (`172.26.10.1/24`)
  - VLAN20 SERVERS (`172.26.20.1/24`)
  - VLAN30 USERS (`172.26.30.1/24`)
- [x] Fixed overlapping subnet issue on ISP router (changed from `/19` to `/24`).
- [x] Added firewall rules on backend router to allow ISP network traffic to VLANs.
- [x] Backend LAG to managed switch (`LAG-SWITCH-V2`, `balance-xor`, ether7–10).
- [x] Bridge VLAN filtering on backend (`BRIDGE-LAN`) with tagged trunk on LAG.

Pending:
- [ ] Disable backend `srcnat masquerade` on `UPLINK-A` (still active → double NAT today).
- [ ] Access port assignment / validation per VLAN on managed switch.
- [ ] Inter-VLAN firewall policy (default deny + explicit allow rules).
- [ ] Gradual server/client migration from legacy subnet (`172.26.32.0/24`) to VLANs.
- [ ] Align ISP DHCP pool ranges with `/24` network (pool still spans old `/19` range).

## Live Topology Snapshot (Latest Router Exports)

Source: `config/sanitized/*-20260720-211212.sanitized.rsc`

```mermaid
flowchart TB
    subgraph WAN["WAN edge"]
        I[Internet]
        ONT[ONT / ISP fiber]
        I --- ONT
    end

    subgraph RoomA["Room A — ISP Router RB4011 Internet Router"]
        DIGI["PPPoE Digi\nvia VLAN_DIGI id 20 on WAN ether1\nadd-default-route + peer DNS"]
        A["ISP Router\nidentity: Internet Router"]
        ETHB["ETH-BRIDGE\n172.26.0.1/24\nDHCP + DNS"]
        A4["ether4\n172.26.40.1/30\nLink to Router B"]
        ONT --> DIGI --> A
        A --- ETHB
        A --- A4
        LAN0["Room A LAN clients\n172.26.0.0/24\nether2,3,5–10 on bridge"]
        ETHB --- LAN0
        PI["pi.martinez-saweczko.es\n172.26.0.25"]
        ETHB --- PI
    end

    subgraph Transit["Transit link /30"]
        T["172.26.40.0/30\nA: 172.26.40.1 ↔ B: 172.26.40.2"]
    end

    subgraph RoomB["Room B — Backend Router RB4011 MikroRouter"]
        B["Backend Router\nidentity: MikroRouter"]
        UA["UPLINK-A ether1\n172.26.40.2/30\ndefault GW 172.26.40.1"]
        BL["BRIDGE-LAN\nvlan-filtering=yes\n172.26.32.1/24 legacy"]
        V10["VLAN10-MGMT\n172.26.10.1/24\nDHCP 10.100–10.254"]
        V20["VLAN20-GW SERVERS\n172.26.20.1/24\nDHCP 20.100–20.254"]
        V30["VLAN30-USERS\n172.26.30.1/24\nDHCP 30.100–30.254"]
        LAG["LAG-SWITCH-V2\nbalance-xor\nslaves ether7–10\ntagged trunk 10,20,30"]
        E2["ether2/3 access\nPVID 10 untagged"]
        E5["ether5 access\nPVID 20 untagged"]
        B --- UA
        B --- BL
        BL --- V10
        BL --- V20
        BL --- V30
        BL --- LAG
        BL --- E2
        BL --- E5
    end

    subgraph Switch["Managed switch"]
        SW["Switch L2\nMGMT 172.26.10.250"]
        SW10["VLAN 10 access ports"]
        SW20["VLAN 20 access ports"]
        SW30["VLAN 30 access ports"]
        SW --- SW10
        SW --- SW20
        SW --- SW30
    end

    subgraph Hosts["Key hosts"]
        WEB["Webserver / services\n172.26.20.254\nDNS: server, registry,\nperiodico, impresora"]
        FED["Fedora Server\n172.26.20.250"]
        LEG["Legacy / PXE path\n172.26.32.250 next-server\nleases e.g. .130 .240"]
    end

    A4 --> T --> UA
    LAG --> SW
    SW20 --> WEB
    SW20 --> FED
    BL -.-> LEG

    DIGI -->|"dst-nat WAN TCP 443,4000\n→ 172.26.20.254:443"| WEB
    A -->|"static routes via 172.26.40.2"| V10
    A -->|"static routes via 172.26.40.2"| V20
    A -->|"static routes via 172.26.40.2"| V30
    A -->|"static route via 172.26.40.2"| BL

    classDef edge fill:#1f2937,color:#fff,stroke:#60a5fa,stroke-width:2px;
    classDef router fill:#0b3d2e,color:#fff,stroke:#34d399,stroke-width:2px;
    classDef net fill:#172554,color:#fff,stroke:#60a5fa,stroke-width:1.5px;
    classDef host fill:#3f1d2e,color:#fff,stroke:#f472b6,stroke-width:1.5px;
    classDef switch fill:#3a2e0b,color:#fff,stroke:#fbbf24,stroke-width:1.5px;
    classDef lag fill:#422006,color:#fff,stroke:#fb923c,stroke-width:1.5px;

    class I,ONT,DIGI edge;
    class A,B,ETHB,A4,UA,BL router;
    class V10,V20,V30,LAN0,T net;
    class WEB,FED,LEG,PI host;
    class SW,SW10,SW20,SW30 switch;
    class LAG,E2,E5 lag;
```

### Addressing & L3 summary

| Segment | CIDR | Gateway / device | Notes |
|--------|------|------------------|--------|
| Room A LAN | `172.26.0.0/24` | ISP `172.26.0.1` on `ETH-BRIDGE` | DHCP + DNS on ISP |
| Transit A↔B | `172.26.40.0/30` | A `ether4` / B `UPLINK-A` | Point-to-point |
| VLAN10 MGMT | `172.26.10.0/24` | Backend `172.26.10.1` | Switch MGMT `172.26.10.250` |
| VLAN20 SERVERS | `172.26.20.0/24` | Backend `172.26.20.1` | WAN publish target `.254` |
| VLAN30 USERS | `172.26.30.0/24` | Backend `172.26.30.1` | |
| Legacy LAN | `172.26.32.0/24` | Backend `172.26.32.1` on `BRIDGE-LAN` | Still active |

### Routing & NAT (as of export)

| Item | State |
|------|--------|
| ISP default route | PPPoE `Digi` (`add-default-route=yes`) |
| ISP → rack nets | Static via `172.26.40.2` for `10/20/30/32` |
| Backend default route | `0.0.0.0/0` → `172.26.40.1` |
| ISP edge NAT | `srcnat masquerade` out `Digi` **active** |
| ISP WAN dst-nat | `443,4000` → `172.26.20.254:443` **active** |
| ISP legacy dst-nat to `172.26.40.2` / `172.26.32.250` | **disabled** |
| Backend `srcnat masquerade` out `UPLINK-A` | **still active** (double NAT) |
| Backend legacy `dstnat` from uplink | **disabled** |

### L2 / switch path (backend)

| Port / iface | Role |
|--------------|------|
| `UPLINK-A` (`ether1`) | To ISP `ether4` |
| `ether2`, `ether3` | Access VLAN10 (PVID 10) |
| `ether5` | Access VLAN20 (PVID 20) |
| `LAG-SWITCH-V2` (`ether7–10`, `balance-xor`) | Tagged trunk VLANs 10,20,30 to managed switch |

Notes from latest exports:
- WAN services publish straight to VLAN20 host `172.26.20.254` (not legacy `172.26.32.250`).
- Backend still masquerades toward ISP uplink — remove when pure routed path is fully trusted.
- Backend legacy `dstnat` rules remain present but disabled.
- ISP DHCP network is `/24`, but pool `dhcp_pool0` still lists `172.26.0.2–172.26.31.254` (cleanup pending).

## Target Network Design (After Switch/VLAN Cutover)

```mermaid
flowchart TD
    I2[Internet] --> A2[Room A ISP Router\nWAN + single NAT + WAN firewall]
    A2 -->|Transit /30\n172.26.40.1 ↔ 172.26.40.2\nno NAT on backend| B2[Room B rack router\nInter-VLAN routing + LAN firewall]
    B2 -->|LAG trunk tagged 10,20,30\nbalance-xor or LACP| S2[Managed switch]
    S2 --> M2[VLAN 10 MGMT\n172.26.10.0/24]
    S2 --> V202[VLAN 20 SERVERS\n172.26.20.0/24]
    S2 --> U2[VLAN 30 USERS\n172.26.30.0/24]
    V202 --> W2[Published services\n172.26.20.254]

    classDef edge2 fill:#1f2937,color:#fff,stroke:#60a5fa,stroke-width:2px;
    classDef router2 fill:#0b3d2e,color:#fff,stroke:#34d399,stroke-width:2px;
    classDef switch2 fill:#3a2e0b,color:#fff,stroke:#fbbf24,stroke-width:1.5px;
    classDef vlan2 fill:#172554,color:#fff,stroke:#60a5fa,stroke-width:1.5px;
    classDef host2 fill:#3f1d2e,color:#fff,stroke:#f472b6,stroke-width:1.5px;

    class I2 edge2;
    class A2,B2 router2;
    class S2 switch2;
    class M2,V202,U2 vlan2;
    class W2 host2;
```

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

## Configuration Backup History

### 2026-07-20 21:12:12 UTC
**File:** `isp-20260720-211212.sanitized.rsc` / `backend-20260720-211212.sanitized.rsc`

**Changes Applied:**
1. **ISP Router Subnet Fix**: Changed ISP network from `/19` to `/24`
   - Previous: `172.26.0.1/19` (covered 172.26.0.0 – 172.26.31.255)
   - Current: `172.26.0.1/24` (covers only 172.26.0.0 – 172.26.0.255)
   - **Reason:** Overlapping netmask was preventing clients from routing to VLAN networks via gateway
   - **Impact:** Clients now correctly identify VLAN20, VLAN30, etc. as non-local and route through gateway

2. **Backend Router Firewall Rules Added**: Allow ISP network traffic to VLANs 20 & 30
   - Rule: `Allow from ISP to VLAN20 via uplink` (dst-address 172.26.20.0/24, in-interface UPLINK-A)
   - Rule: `Allow ISP network to VLAN20` (src 172.26.0.0/16 → dst 172.26.20.0/24)
   - Rule: `Allow from ISP to VLAN30 via uplink` (dst-address 172.26.30.0/24, in-interface UPLINK-A)
   - Rule: `Allow ISP network to VLAN30` (src 172.26.0.0/16 → dst 172.26.30.0/24)
   - **Reason:** Enable SSH and other services from ISP network to VLAN20/30 devices
   - **Impact:** Connectivity from ISP clients to VLAN20 devices (e.g., 172.26.20.254) now works

**Testing Verified:**
- ✅ `ping 172.26.20.254` from ISP client succeeds
- ✅ `ssh admin@172.26.20.254` from ISP client succeeds
- ✅ Backend router can ping VLAN20 devices directly

---

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

## Troubleshooting Guide

### DHCP Not Working with Multiple Bonding Cables

#### Symptom
When bonding multiple cables between a MikroTik router and a managed switch:
- ✅ Static IPs work fine
- ✅ Ping works fine
- ❌ DHCP Discover fails (no lease obtained)
- ✅ Single cable works perfectly

#### Root Cause
This issue typically occurs when there is a **mismatch between link aggregation modes** on the two devices:

| Device       | Configuration                    | Negotiation                              |
|--------------|----------------------------------|------------------------------------------|
| **MikroTik** | `mode=802.3ad` (LACP)            | Expects dynamic negotiation with partner |
| **Switch** LG-SWG24-WEB  | Static Port Trunk / Port Bonding | **No LACP handshake**                    |

Many inexpensive switches (e.g., Realtek-based) have **two separate features**:
1. **Static Trunk / Port Trunk** – Groups ports without protocol negotiation
2. **LACP / 802.3ad** – Dynamic link aggregation (separate menu/page on most switches)

When the switch uses static trunking while MikroTik expects LACP, broadcasts (like DHCP Discover) are often the first to fail because the trunk isn't agreed upon properly between both ends.

#### Solution

**Step 1:** Verify your switch configuration.
Check if your switch has a separate **LACP**, **Link Aggregation**, or **802.3ad** menu page.
- **If it does:** Enable LACP on the switch trunk and keep MikroTik's `mode=802.3ad`.
- **If it doesn't:** Proceed to Step 2.

**Step 2:** Change MikroTik bonding mode from LACP to static aggregation.

Update your bonding interface to use `balance-xor` mode (designed for static trunks):

```
/interface bonding
set LAG-SWITCH-V2 mode=balance-xor transmit-hash-policy=layer-2-and-3
```

Or in separate commands:
```
/interface bonding
set LAG-SWITCH-V2 mode=balance-xor
set LAG-SWITCH-V2 transmit-hash-policy=layer-2-and-3
```

**Explanation of parameters:**
- `mode=balance-xor` – Distributes traffic using XOR of MAC addresses; works with static trunks
- `transmit-hash-policy=layer-2-and-3` – Better distribution than `layer-2` alone; uses MAC + IP to select outgoing port

**Step 3 (Optional):** Verify bonding status.
Run:
```
/interface bonding monitor LAG-SWITCH-V2 once
```

- **With LACP:** You'll see `actor-key`, `partner-key`, and detailed state information
- **Without LACP:** You'll only see `active-port` and `inactive-port` — confirming static mode

#### Why DHCP Fails First

DHCP is **broadcast traffic**:
```
Source: 0.0.0.0
Destination: 255.255.255.255
Flags: BROADCAST
```

When a trunk isn't properly negotiated:
- **Unicast traffic** (ping, SSH) may work because it flows through one cable at a time
- **Broadcast traffic** (DHCP Discover, ARP broadcasts) fails because:
  - The trunk may not properly flood frames across all bundled ports
  - Frames may be duplicated or dropped inconsistently
  - The switch and MikroTik disagree on trunk membership

Removing the bond and using a single cable bypasses the trunk entirely, which is why single-cable configurations work.

---

## Professionalization Roadmap (Practical)

1. Keep **single NAT boundary** at ISP edge router.
2. Use **clear VLAN segmentation** (management, servers, users, optional guest/iot).
3. Enforce **least-privilege firewall rules** between VLANs.
4. Centralize and version-control **sanitized config snapshots**.
5. Add monitoring/observability (latency, packet loss, service reachability).
6. Document each change with before/after notes.

## Notes

This repo is meant to evolve with the network. Keep changes incremental, tested, and easy to roll back.

## Session Resume Checklist

Use this checklist at the beginning of the next session:

1. Pull latest backups:
   ```bash
   ./scripts/backup_mikrotik_configs.py
   ```
2. Read, in order:
   - this `README.md`
   - latest `config/sanitized/isp-*.sanitized.rsc`
   - latest `config/sanitized/backend-*.sanitized.rsc`
3. Confirm current state:
   - ISP direct publish to `172.26.20.254` (`443`, `4000` → to-ports `443`)
   - backend `srcnat masquerade` on `UPLINK-A` still **enabled** (pending removal)
   - backend legacy `dstnat` disabled
   - ISP static routes to `172.26.10/20/30/32` via `172.26.40.2`
   - backend LAG `LAG-SWITCH-V2` trunk tagged 10/20/30
 4. Continue from `Pending` checklist under **Current Migration Status**.

Starter prompt for next time:

```text
Continue Network project.
Read README.md and latest config/sanitized/*.sanitized.rsc first.
Then continue from the Pending checklist.
```

## Diagram Format

This project standard is **Mermaid** diagrams in Markdown.

- Keep the network topology diagram directly in `README.md` using Mermaid code blocks.
- Update the Mermaid diagram whenever topology, VLANs, or routing changes.
- Prefer Mermaid over image-based diagrams to keep reviews and diffs simple.
