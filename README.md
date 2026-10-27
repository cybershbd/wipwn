<div align="center">

# ⚡ WIPWN (WiFi Pwnage Suite)
### *Next-Gen Automated Wireless WPS / WPA Security Auditor for Android (Termux) & Linux*

[![Python](https://img.shields.io/badge/Python-3.8%2B-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/Platform-Termux%20%7C%20Linux-000000?style=for-the-badge&logo=android&logoColor=white)](https://termux.dev/)
[![Root Support](https://img.shields.io/badge/Root-KernelSU%20%7C%20Magisk%20%7C%20APatch-red?style=for-the-badge&logo=superuser&logoColor=white)](#-prerequisites)
[![License](https://img.shields.io/badge/License-GPLv3-green?style=for-the-badge)](LICENSE)
[![Telegram](https://img.shields.io/badge/Telegram-CYBERSHBD-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/cybersh_official)

<br/>

```
  ██     ██ ██ ██████  ██     ██ ███    ██ 
  ██     ██ ██ ██   ██ ██     ██ ████   ██ 
  ██  █  ██ ██ ██████  ██  █  ██ ██ ██  ██ 
  ██ ███ ██ ██ ██      ██ ███ ██ ██  ██ ██ 
   ███ ███  ██ ██       ███ ███  ██   ████ 
   Wireless WPS / WPA PixieDust & PIN Auditor
```

<p align="center">
  <a href="#-overview">Overview</a> •
  <a href="#-key-features">Key Features</a> •
  <a href="#-prerequisites">Prerequisites</a> •
  <a href="#-installation--setup">Installation</a> •
  <a href="#-quick-start--usage">Usage</a> •
  <a href="#-command-line-options">Arguments</a> •
  <a href="#-troubleshooting">Troubleshooting</a> •
  <a href="#-credits">Credits</a>
</p>

---

</div>

## 📖 Overview

**WIPWN** is an ultra-fast, responsive wireless penetration testing suite built specifically for Android devices running **Termux** (with Root) and Linux systems. It executes automated **Pixie Dust WPS attacks** and online PIN brute-force recovery without requiring an external monitor-mode Wi-Fi dongle on supported internal chipsets.

Fully optimized for **Android 12, 13, 14, 15** with native compatibility for **KernelSU**, **Magisk**, and **APatch**.

---

## ✨ Key Features

- ⚡ **Instant Global Shortcut (`wipwn`):** Run the tool from anywhere in Termux simply by typing `wipwn` and hitting Enter.
- 🛡️ **Universal Root Compatibility:** Eradicates the notorious `"No Binary detected, Are you rooted?"` error across Magisk, KernelSU, and APatch.
- 🔄 **Smart Auto Wi-Fi State Management:** Automatically deactivates Android/Linux system Wi-Fi before testing to prevent `-16 Device or resource busy` interface locks, and seamlessly restores Wi-Fi on completion or `Ctrl+C`.
- 📱 **Adaptive Terminal Card UI:** Automatically measures terminal viewport width and draws clean, bordered rectangular cards. East Asian Wide Unicode characters (e.g. `『`, `』`) and emojis never break card alignment.
- 🎨 **Dynamic Status Colors:**
  - 🟢 **`[VULN]`** — Vulnerable Access Points with verified WPS exploits.
  - 🔴 **`[LOCKED]`** — WPS is locked or rate-limited.
  - 🟡 **`[STORED]`** — Networks previously audited and saved in database.
  - 🔵 **`[OPEN]`** — Standard WPS-enabled networks.
- 💾 **Intelligent Deduplication Database:** Automatically stores recovered credentials across `/sdcard/wipwn/`, `$PREFIX/bin/`, and local `reports/`. Re-auditing an SSID automatically updates existing records without creating duplicates.
- 🎯 **Algorithmic PIN Calculation:** Calculates high-probability default WPS PINs using BSSID MAC checksums.

---

## 📋 Prerequisites

1. **Root Access:** A rooted Android device running **KernelSU**, **Magisk (v25+)**, or **APatch** (or Linux with `sudo`).
2. **Termux Application:** Installed from [F-Droid](https://f-droid.org/en/packages/com.termux/) or GitHub Releases *(do **not** use the outdated Google Play Store release)*.
3. **Turn on Mobile Hotspot:** Enable Personal Hotspot on your Android device before scanning (keeps wireless firmware awake on Qualcomm / MediaTek chipsets).

---

## 🚀 Installation & Setup

Choose between the **Automated 1-Click Setup** (Recommended) or the **Manual Step-by-Step Installation**:

### Option 1: Automated 1-Click Setup *(Recommended)*

> [!TIP]
> **Why Recommended?** The automated installer fixes `"No Binary detected"`, injects the universal `sudo` environment for KernelSU / Magisk / APatch, installs all required network tools, and creates the global `wipwn` shortcut.

```bash
#Git Installation
pkg install git -y

# Clone the repository
git clone https://github.com/cybershbd/wipwn.git
cd wipwn

# Run the automated installer
bash installer.sh
```

*(You can also simply run `python wipwn.py` — if root or dependencies are missing, it will automatically trigger `installer.sh` for you!)*

---

### Option 2: Manual Installation

If you prefer to install packages and configure dependencies manually step-by-step:

```bash
# 1. Update repositories and install root packages
pkg update && pkg upgrade -y
pkg install root-repo -y

# 2. Install required network tools and dependencies
pkg install git tsu python termux-api wpa-supplicant pixiewps iw -y

# 3. Clone the official repository
git clone https://github.com/cybershbd/wipwn.git
cd wipwn

# 4. Grant execution permissions
chmod +x wipwn.py
# 5. Grant Root execution permissions
bash installer.sh
```

> [!NOTE]
> If you run into `[!] No Binary detected, Are you rooted?` when using `tsu` on modern Android versions, execute `bash installer.sh` once to inject the universal root wrapper.

---

## 💻 Quick Start & Usage

### 🚀 The 1-Click Global Shortcut
Once installed, you don't even need to navigate to the folder! Just type:

```bash
wipwn
```

*This automatically launches `sudo python $HOME/wipwn/wipwn.py -i wlan0 -K`.*

---

### 📡 Standard Command Examples

#### 1. Interactive AP Scan & Pixie Dust Attack
Scans all in-range WPS networks, displays styled card list, and prompts for selection:
```bash
sudo python wipwn.py -i wlan0 -K
```

#### 2. Target a Specific BSSID (Access Point)
Bypasses interactive prompt and directly attacks the target MAC address:
```bash
sudo python wipwn.py -i wlan0 -b 00:91:4C:C3:AC:28 -K
```

#### 3. Online PIN Brute-force Attack
Brute-forces online WPS PINs (e.g., with a known 4-digit prefix):
```bash
sudo python wipwn.py -i wlan0 -b 50:0F:F5:B0:08:05 -B -p 1234
```

#### 4. Continuous Loop Mode
Continuously scans and audits multiple networks in sequence without restarting:
```bash
sudo python wipwn.py -i wlan0 -K -l
```

---

## 🛠️ Command-Line Options

| Flag | Long Option | Description |
| :--- | :--- | :--- |
| `-i` | `--interface` | Wireless network interface (default: `wlan0`) |
| `-b` | `--bssid` | Target Access Point BSSID MAC address |
| `-p` | `--pin` | Target WPS PIN (4 or 8 digits, or arbitrary string) |
| `-K` | `--pixie-dust` | Execute automated offline Pixie Dust WPS attack |
| `-B` | `--bruteforce` | Launch online PIN brute-force attack |
| `-d` | `--delay` | Delay in seconds between PIN attempts (default: `0`) |
| `-w` | `--write` | Save recovered credentials to database file |
| `-F` | `--pixie-force` | Force full-range keyspace bruteforce in Pixiewps |
| `-X` | `--show-pixie-cmd` | Print executed `pixiewps` shell command |
| `-l` | `--loop` | Continuous audit loop mode across discovered APs |
| `-r` | `--reverse-scan` | Reverse AP list order (weakest to strongest signal) |
| `-v` | `--verbose` | Output detailed verbose debugging logs |
| `-h` | `--help` | Display full help menu and argument guide |

---

## 🔧 Troubleshooting

### ❓ "No Binary detected, Are you rooted?"
* **Cause:** The old Termux `tsu` package fails to locate `su` in modern Magisk (v25+), KernelSU, or APatch isolated namespaces.
* **Fix:** Run the automated installer:
  ```bash
  bash installer.sh
  ```
  This removes conflicting `tsu` files and injects a universal `sudo` wrapper that directly binds to your root manager.

### ❓ "Device or resource busy (-16)"
* **Cause:** Android OS wireless daemon is holding the Wi-Fi interface.
* **Fix:** Turn **Personal Hotspot ON**, then toggle **Wi-Fi ON and OFF** once. WIPWN's built-in state manager will take care of the rest.

### ❓ "Unable to bring interface 'wlan0' up"
* **Cause:** Your device uses a custom wireless interface name (e.g. `wlan1`, `p2p0`).
* **Fix:** Check available interfaces:
  ```bash
  sudo ip link
  ```
  Then pass your interface explicitly:
  ```bash
  wipwn -i wlan1
  ```

---

## 🎥 Video Tutorial

Watch a full step-by-step video setup and demonstration on Telegram:

👉 **[Watch Video Tutorial on Telegram](https://t.me/cybersh_official/127)**

---

## 📜 Credits & Modifications

- **Original Engine:** OneShotPin (c) 2017 by [rofl0r](https://github.com/rofl0r)
- **Modded & Maintained by:** **SH TASRIF** ([CYBERSHBD](https://github.com/cybershbd))
  - Universal KernelSU / Magisk / APatch root escalation framework.
  - Zero-config auto installer and global `wipwn` launcher shortcut.
  - East Asian Wide Unicode padding & adaptive mobile card UI.
  - Automated Android OS Wi-Fi conflict releasing and restoration.
  - Credential storage engine with auto-deduplication.

---

## ⚠️ Disclaimer

> [!CAUTION]
> This software is designed strictly for educational purposes and authorized penetration testing. Auditing wireless networks without explicit prior written authorization from the network owner is strictly illegal. The author assumes no responsibility or liability for any misuse of this tool.

---

<div align="center">

### 👥 Connect With Me

<a href="https://fb.com/cybershbd" target="_blank"><img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/facebook.svg" alt="Facebook" height="32" width="40" /></a>
<a href="https://t.me/cybersh_official" target="_blank"><img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/telegram.svg" alt="Telegram" height="32" width="40" /></a>
<a href="https://twitter.com/cybershbd" target="_blank"><img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/twitter.svg" alt="Twitter" height="32" width="40" /></a>
<a href="https://instagram.com/cybershbd" target="_blank"><img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/instagram.svg" alt="Instagram" height="32" width="40" /></a>

<br/><br/>

<img src="https://profile-counter.glitch.me/ShTasrif/count.svg" alt="Visitors">

</div>

---

## 📸 Screenshots

### 1. Wi-Fi Scanning in Progress After Launching the Tool
<p align="center">
  <img src="https://gitlab.com/ShTasrif/wipwn/-/raw/main/images/scanning-wifi.png" alt="Wi-Fi scanning in progress after launching the tool" width="800">
</p>

### 2. Available Networks Detected After Scan Completion
<p align="center">
  <img src="https://gitlab.com/ShTasrif/wipwn/-/raw/main/images/founded-wps-ssid.png" alt="Available networks detected after scan completion" width="800">
</p>

### 3. Successful WPS PIN & Wi-Fi Password Recovery via Pixie Dust Attack
<p align="center">
  <img src="https://gitlab.com/ShTasrif/wipwn/-/raw/main/images/pixiedust-success.png" alt="Successful WPS PIN and Wi-Fi password recovery via Pixie Dust attack" width="800">
</p>

### 4. Successful Authentication Using a Custom PIN
<p align="center">
  <img src="https://gitlab.com/ShTasrif/wipwn/-/raw/main/images/custompin-success.png" alt="Successful authentication using a custom PIN" width="800">
</p>

### 5. "wlan0 Not Found" Error When Hotspot is Disabled
<p align="center">
  <img src="https://gitlab.com/ShTasrif/wipwn/-/raw/main/images/hotspot-off-issue.png" alt="wlan0 not found error when hotspot is disabled" width="800">
</p>
