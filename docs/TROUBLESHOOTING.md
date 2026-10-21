# Samsung Tizen Sideloading Troubleshooting Guide

## 1. SDB Connection Refused or Timed Out (`port 26101 unreachable`)

### Symptoms
```
connecting to <TV_IP>:26101 ...
failed to connect to <TV_IP>:26101
```

### Root Causes & Fixes
- **TV was not cold rebooted**: Turning on Developer Mode in the GUI does not spawn the `sdbd` background service until a full hardware reboot.
  - *Fix*: Hold down the physical remote **Power** button for 8 seconds until the boot logo displays, or pull the AC cord.
- **TV IP Address changed**: DHCP lease renewal gave the TV a new IP address.
  - *Fix*: Check TV Settings $\rightarrow$ Network $\rightarrow$ Network Status $\rightarrow$ IP Settings, or configure a DHCP reservation on your router.
- **Developer Mode switched off**: Samsung TV firmware updates often silently toggle Developer Mode to **Off**.
  - *Fix*: Re-enter `1 2 3 4 5` on the Apps screen and turn it back on.

---

## 2. Tailscale Subnet Route Hijacking

### Symptoms
- Workstation cannot ping or connect to TV over Wi-Fi (`<TV_IP>`).
- Traceroute shows packets heading toward `tailscale0` instead of the local Wi-Fi interface (e.g., `wlan0` / `wlp9s0`).

### Root Cause
Tailscale's subnet router features advertise local LAN subnets. If your local machine runs Tailscale with `--accept-routes=true`, your kernel routing table prioritizes the Tailscale virtual tunnel over the physical Wi-Fi interface.

### Fix
Temporarily or permanently disable accepting subnet routes on the workstation:
```bash
tailscale set --accept-routes=false
```
Verify route:
```bash
ip route get <TV_IP>
# Output should show: via ... dev wlan0 / wlp9s0
```

---

## 3. "closed by author signature" / Installation Refused

### Symptoms
```
Processing...
Error code: FATAL_ERROR
Error message: closed by author signature
```

### Root Causes & Fixes
- **Missing Partner Certificate**: You used a Public developer certificate, but the application requests Partner-level privileges (`avplay`, `productinfo`).
  - *Fix*: Re-sign using a **Partner** certificate generated with your specific TV DUID.
- **Modified files without removing signatures**: Modifying app files broke existing signature checksums.
  - *Fix*: Delete `author-signature.xml` and `signature1.xml`, then re-sign.
- **DUID Mismatch**: The certificate was signed for a different TV DUID than the physical unit attached to SDB.
  - *Fix*: Query current TV DUID via `sdb capability | grep duid` and update `device-profile.xml`.

---

## 4. App Installs but Does Not Appear on Smart Hub

### Symptoms
`sdb install` exits with code 0 (`100% installed`), but no icon appears on the Smart Hub bar.

### Root Cause & Fix
- Newly installed developer apps appear at the very far end of the **Apps** gallery.
- Open **Apps** $\rightarrow$ scroll to **Downloaded Apps** $\rightarrow$ highlight app $\rightarrow$ select **Add to Home**.
