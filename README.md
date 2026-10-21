---
created: 2026-10-21
project: Homelab Refactor 2026
tags: [homelab, tizen, samsung-tv, reverse-engineering, streaming]
keywords:
  - samsung-tv
  - tizen-os
  - sdb
  - moonfin
  - moonlight
  - sideloading
---

# 📺 Samsung Tizen TV Sideloading & Reverse Engineering Toolkit

> **Platform:** Samsung Tizen OS (v2.4 - v8.0+)  
> **Target Device Architecture:** ARMv7 / AArch64 (Samsung UHD / Crystal / QLED / OLED)  
> **Primary Tools:** Samsung Smart Development Bridge (`sdb`), `Apps2Samsung`, `zip`/`unzip`  
> **Status:** Production Verified (`UA43U8000FKXXS`)  

---

## 🎯 Executive Overview

This repository provides a standardized, repeatable engineering toolkit for **inspecting, reverse engineering, customizing, signing, and sideloading native applications** on Samsung Smart TVs running Tizen OS.

Instead of fighting hardware constraints, DRM boundaries (Widevine L1), or closed bootloaders, this methodology exploits Samsung's native **Developer Mode** and **Partner Certificate Architecture** to deliver high-performance hardware-accelerated playback (`AVPlay`), zero-lag streaming, and custom web applications over LAN.

---

## 📂 Repository Layout

```
samsung-tizen-toolkit/
├── docs/
│   ├── DEVELOPER_MODE_GUIDE.md    <-- Remote sequence (1-2-3-4-5) & cold reboot procedures
│   ├── CERTIFICATES_AND_SIGNING.md <-- DUID pairing, Partner vs Public security profiles
│   ├── SOURCE_EDITING_GUIDE.md    <-- Decompiling .wgt, editing HTML/CSS/JS, repackaging
│   └── TROUBLESHOOTING.md         <-- Port 26101 timeouts, Tailscale route conflicts
├── scripts/
│   ├── tv-connect.sh              <-- SDB connection and route diagnostics
│   ├── wgt-unpack.sh              <-- Decompress .wgt into an editable source tree
│   ├── wgt-pack.sh                <-- Clean signatures & repackage into .wgt
│   └── tv-install.sh              <-- Push and sideload signed package onto TV
├── templates/
│   └── config.xml.example         <-- Standard Tizen TV web manifest with AVPlay privileges
├── .gitignore                     <-- Keeps keys, certs, and large AppImages out of VCS
└── README.md
```

---

## 🚀 Quickstart Workflow

### 1. Enable Developer Mode on the TV
1. On your Samsung TV, navigate to **Apps**.
2. Press remote sequence: `1 -> 2 -> 3 -> 4 -> 5`.
3. Toggle Developer Mode to **On**, input your development PC's IP, and click **OK**.
4. **Cold reboot the TV**: Hold the physical remote Power button for 8 seconds until the Samsung boot logo displays.
   *(See [docs/DEVELOPER_MODE_GUIDE.md](docs/DEVELOPER_MODE_GUIDE.md) for full instructions).*

### 2. Connect via SDB
```bash
# Connect to TV (default IP: 192.168.4.27, port: 26101)
./scripts/tv-connect.sh 192.168.4.27
```

### 3. Decompile & Inspect an App
```bash
# Unpack any .wgt into a source directory
./scripts/wgt-unpack.sh ./Moonfin.wgt ./moonfin_src
```
- Edit JavaScript bundles to point default API endpoints to your LAN media server (`nucmediaserver`).
- Inject custom CSS in `index.html` for subtitle contrast or theme styling.
- Add permissions in `config.xml` (e.g., `avplay`, `network.public`).

### 4. Clean & Repackage
```bash
# Strips obsolete signature XMLs and builds clean package
./scripts/wgt-pack.sh ./moonfin_src ./moonfin-custom.wgt
```

### 5. Sign & Sideload
1. Sign the generated `.wgt` using your Samsung Partner certificate profile (`Apps2Samsung.AppImage`).
2. Sideload onto the TV:
   ```bash
   ./scripts/tv-install.sh ./moonfin-custom.wgt
   ```

---

## 🛠️ Essential Pre-requisites

- **`sdb` (Samsung Smart Development Bridge)**: Extract into `~/.local/bin/sdb`.
- **Samsung Partner Certificate**: Required for hardware video decoders (`avplay`). Public certificates will fail on video playback.
- **Tailscale Routing Caution**: If host machine runs Tailscale with `--accept-routes=true`, disable it via `tailscale set --accept-routes=false` to prevent hijacking local Wi-Fi SDB packets.

---

## 📖 Deep-Dive Documentation Links

- **[Developer Mode Guide](docs/DEVELOPER_MODE_GUIDE.md)**
- **[Certificates & Signing Architecture](docs/CERTIFICATES_AND_SIGNING.md)**
- **[Source Code Modification & Re-packaging](docs/SOURCE_EDITING_GUIDE.md)**
- **[Troubleshooting Matrix](docs/TROUBLESHOOTING.md)**
