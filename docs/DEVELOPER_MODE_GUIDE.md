# Samsung Tizen Developer Mode Activation Guide

## Overview
Samsung Smart TVs (Tizen OS 2.4 through 8.0+) do not permit direct sideloading or open ADB/SSH access out of the box. To communicate with the TV via the Samsung Smart Development Bridge (`sdb`) on port `26101`, **Developer Mode** must be explicitly unlocked using a physical remote sequence.

---

## Prerequisites
1. A physical Samsung Smart Remote or IR Remote control.
2. The TV and your development machine must be on the same local network subnet (or routeable LAN).
3. Know your workstation's LAN IP address (e.g., `ip route get 1.1.1.1 | awk '{print $7}'`).

---

## Step-by-Step Activation

### Step 1: Open the Apps Menu (and Apps Settings)
1. Turn on the TV and press the **Home** button on the remote.
2. Navigate horizontally to the **Apps** icon and press **Select / Enter**.
3. > [!TIP]
   > **Model-Specific Nuance (Crucial!):**  
   > On older Tizen TVs, you can enter the sequence on the main Apps screen. However, on **newer Tizen models (Tizen 5.5+, Crystal UHD, QLED/OLED)**, pressing the numbers on the Apps homepage does nothing.  
   > **You must navigate to the Settings (Gear Icon) in the top-right corner of the Apps screen first.** Open **Apps Settings** (where your list of installed downloaded apps is displayed).

### Step 2: Trigger the Developer Sequence
1. Once inside the **Apps panel** (or inside **Apps Settings** on newer models), do not launch any app.
2. Using the physical remote control, press the numeric keys in rapid succession:
   ```
   1 -> 2 -> 3 -> 4 -> 5
   ```
   *(Note: If using a minimalist Samsung Smart Remote without physical number buttons, press the **123** button on the remote to summon the on-screen numeric keypad, or use a universal/IR remote).*

### Step 3: Enter Host PC IP
1. A blue popup dialogue titled **Developer Mode Configuration** will appear.
2. Toggle the switch from **Off** to **On**.
3. In the **Host PC IP** field, enter your development computer's local IP address (e.g., `192.168.1.50`).
4. Click **OK**.

### Step 4: Perform a Cold Reboot (Crucial!)
> [!IMPORTANT]
> The SDB daemon on port `26101` will **not** start until the TV performs a cold hardware reboot. Simply putting the TV into standby will fail to activate the port.

1. Point your remote at the TV and **press and hold the Power button for 5 to 8 seconds**.
2. Keep holding until the screen turns completely off and powers back on displaying the **Samsung / Tizen Logo**.
3. Alternatively, unplug the physical AC power cord from the wall outlet, wait 10 seconds, and plug it back in.

### Step 5: Verification
1. Open the **Apps** panel again.
2. In the top-right corner, you should now see red developer text:
   ```
   Develop Mode: ON
   ```
3. Test port connectivity from your workstation:
   ```bash
   nc -zv <TV_IP> 26101
   ```
   If open, you will see `Connection to <TV_IP> 26101 port [tcp/*] succeeded!`.
