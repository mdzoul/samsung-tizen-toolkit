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
│   ├── DEVELOPER_MODE_GUIDE.md        <-- Remote sequence (1-2-3-4-5) & Apps Settings nuance
│   ├── CERTIFICATES_AND_SIGNING.md    <-- DUID pairing, Partner vs Public security profiles
│   ├── SOURCE_EDITING_GUIDE.md        <-- Decompiling .wgt, editing HTML/CSS/JS, repackaging
│   ├── TAILSCALE_AND_REMOTE_ACCESS.md <-- Remote TV sideloading via Subnet Routers & route gotchas
│   └── TROUBLESHOOTING.md             <-- Port 26101 timeouts, Tailscale route conflicts
├── scripts/
│   ├── tv-connect.sh                  <-- SDB connection and route diagnostics
│   ├── wgt-unpack.sh                  <-- Decompress .wgt into an editable source tree
│   ├── wgt-pack.sh                    <-- Clean signatures & repackage into .wgt
│   └── tv-install.sh                  <-- Push and sideload signed package onto TV
├── templates/
│   └── config.xml.example             <-- Standard Tizen TV web manifest with AVPlay privileges
├── .gitignore                         <-- Keeps keys, certs, and large AppImages out of VCS
└── README.md
```

---

## 🚀 Sideloading Workflows: Two Ways to Do It

Choose the path that fits what you want to achieve:

### 🌟 Path A: The Fast 1-Click GUI Method (Recommended for 95% of Users)
If you simply want to get **Moonfin** (Jellyfin client) and **Moonlight** (game streaming) running natively on your TV:

1. **Enable Developer Mode on the TV:**
   - Navigate to **Apps** $\rightarrow$ select the **Settings (Gear Icon)** at the top-right corner.
   - Using your remote, press in rapid succession: `1 -> 2 -> 3 -> 4 -> 5`.
   - Set Developer Mode to **On**, input your development PC's IP, and click **OK**.
   - **Cold reboot the TV (Crucial):** Hold the physical remote **Power** button for 8 seconds until the Samsung boot logo displays.  
     *(See [docs/DEVELOPER_MODE_GUIDE.md](docs/DEVELOPER_MODE_GUIDE.md) for step-by-step photos/details).*

2. **Launch `Apps2Samsung`:**
   - Download and run the `Apps2Samsung.AppImage` tool on your computer.
   - Enter your TV's IP address and click **Scan/Connect** (it will auto-detect your TV model and DUID).

3. **Select Apps & Click Install:**
   - The GUI provides a browser-like catalog of tested developer apps.
   - Select **Moonfin** and/or **Moonlight** (or any other available app).
   - Click **Install**.

4. **One-Time Samsung Sign-In:**
   - A Samsung login prompt will appear. Sign in with your standard Samsung account.
   - The tool automatically requests official Samsung Partner certificates for your TV's DUID, signs the apps, transfers them over SDB port 26101, and installs them directly to your Smart Hub.
   - **Done!** You can now stream with zero-latency hardware acceleration (`AVPlay`).

---

### 🛠️ Path B: The Advanced Track (Custom Source Editing & Reverse Engineering)
For developers who want to inspect the source code, modify JS/HTML/CSS, add custom permissions in `config.xml`, or sideload a custom third-party `.wgt` not available in the catalog:

1. **Connect via SDB CLI:**
   ```bash
   ./scripts/tv-connect.sh <TV_IP>
   ```

2. **Decompile & Unpack any `.wgt`:**
   ```bash
   ./scripts/wgt-unpack.sh ./Moonfin.wgt ./moonfin_src
   ```

3. **Inspect & Edit Source Code:**
   - Edit JavaScript bundles to point default API endpoints to your LAN media server.
   - Inject custom CSS in `index.html` for subtitle styling, font scaling, or custom themes.
   - Add elevated permissions in `config.xml` (e.g., `avplay`, `network.public`).

4. **Clean Obsolete Signatures & Repackage:**
   ```bash
   # Strips old signature checksums and builds clean .wgt
   ./scripts/wgt-pack.sh ./moonfin_src ./moonfin-modified.wgt
   ```

5. **Sign & Sideload:**
   - Sign the generated package with your Samsung Partner certificate profile (`~/.config/Apps2Samsung/Certificate/`).
   - Sideload onto the TV:
   ```bash
   ./scripts/tv-install.sh ./moonfin-modified.wgt
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
- **[Tailscale Subnet Routing & Remote Sideloading](docs/TAILSCALE_AND_REMOTE_ACCESS.md)**
- **[Troubleshooting Matrix](docs/TROUBLESHOOTING.md)**

---

## ⚖️ Legal & Responsible Use Disclaimer

> **Notice:** This toolkit utilizes officially supported Samsung Tizen Developer Mode interfaces and standard W3C Widget specifications documented by Samsung Electronics for application developers.
> 
> - This project **does not** circumvent DRM (such as Widevine or PlayReady), crack hardware encryption, bypass paywalls, or modify protected TV firmware.
> - This repository **does not** host, redistribute, or license proprietary Samsung binaries or copyrighted third-party media.
> - All scripts and documentation are provided strictly for educational, personal research, and open-source homelab development purposes under the MIT License.

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
