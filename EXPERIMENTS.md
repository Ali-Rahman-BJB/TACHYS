# Experiments & Results

This document collects the data, test results, tables, and diagrams from the development and testing of **Tachys** (ταχύς, Greek for "fast"), a portable, script-based diagnostic toolkit for the initial inspection of laptops. It was developed during a vocational internship (PKL) at Bandung Computer Banjarbaru, Indonesia, and tested from **8 to 21 October 2026**.

> **Note:** The flowcharts and screenshots in this document are taken from the original (Indonesian) internship report, so the text inside the images is in Indonesian. All tables and explanations here are in English.

## Table of Contents

1. [Background](#1-background)
2. [Methodology](#2-methodology)
3. [Test Devices](#3-test-devices)
4. [Feature Support by Operating System](#4-feature-support-by-operating-system)
5. [Functional Test Results](#5-functional-test-results)
6. [Time Efficiency: Manual vs Tachys](#6-time-efficiency-manual-vs-tachys)
7. [Issues Found in the Field](#7-issues-found-in-the-field)
8. [Design: Computational Thinking](#8-design-computational-thinking)
9. [Design: Flowcharts](#9-design-flowcharts)
10. [Development Environment & Dependencies](#10-development-environment--dependencies)
11. [Limitations](#11-limitations)
12. [Conclusions & Future Work](#12-conclusions--future-work)

---

## 1. Background

Before Tachys, the initial inspection of a customer's laptop was done manually, one step at a time. Each device went through the same set of steps:

| # | Manual inspection step | How it was done |
|---|------------------------|-----------------|
| 1 | Storage health (SSD/HDD) | Portable Hard Disk Sentinel run from a USB flash drive; slow because it scans all drives first |
| 2 | Wi-Fi adapter | Check that the driver is installed, then open the internet / YouTube to test the connection |
| 3 | Keyboard | Open a keyboard-tester website in a browser |
| 4 | Audio output | Use the *Sounds* tab in Audio Settings, or play a video |
| 5 | Battery health | Run the laptop on battery for at least 10 minutes and watch for abnormal drops |
| 6 | Resource-intensive programs | Inspect Task Manager and stop heavy processes manually |
| 7 | Windows Security / Fast Startup | Temporarily disable Virus & Threat Protection and Fast Startup through Windows settings / Control Panel |

**Problems with the manual process:**

- Steps are separate and repetitive, so total time grows with the number of devices.
- Results depend on the technician's care, so they can be inconsistent.
- There is no logging, which makes it hard to trace what was done to a customer's laptop.
- Using USB drives and external tools on many laptops risks spreading malware.
- Inspection happens on the customer's device, so data privacy must be respected.

**Goal:** a lightweight, portable, non-destructive toolkit that runs the checks from a single menu and returns short, easy-to-read results.

---

## 2. Methodology

### 2.1 Objectives

1. Verify that every menu option works as designed on Windows and Linux Ubuntu.
2. Check that results are accurate on laptops with different conditions and complaints.
3. Compare inspection time: manual vs Tachys.
4. Identify field problems (security software, old OS versions) and their fixes.

### 2.2 Test setup

| Item | Detail |
|------|--------|
| Location | Bandung Computer Banjarbaru |
| Period | 8–21 October 2026 |
| Devices | 18 laptops (17 Windows, 1 Linux Ubuntu), from customers, the shop, and the author |
| Conditions | Healthy laptops, laptops with system faults, laptops with hardware faults |
| Complaints | Weak Wi-Fi adapter, slow performance, HDD/SSD problems |
| Preparation | *Virus & Threat Protection* was disabled on each laptop beforehand, except laptops with third-party antivirus, which were left active on purpose to observe their effect |

### 2.3 Time measurement

- **Tool:** stopwatch in the Clock app of an OPPO A5 phone.
- **Sample:** 5 laptops (ID01–ID05) with different conditions, each measured **once per method** (manual and Tachys), always by the same person.
- **Steps measured (6):**
  1. Run HDD Sentinel from the shop's USB flash drive
  2. Connect the laptop to Wi-Fi
  3. Test the keyboard through a keyboard-tester website
  4. Test audio output through Sound Settings
  5. Open Task Manager to look for antivirus / heavy programs
  6. Disable Fast Startup through Control Panel
- **Excluded:** the 10-minute battery check, because its duration is fixed and independent of the method.
- **Start / stop rule:** the stopwatch starts at the Windows desktop with no apps open, together with the first action of each step. It stops when the manual step is finished, or when Tachys displays its result.
- **Reset:** the laptop was returned to the same starting state before each measurement.
- **Recording:** step durations were logged in Microsoft Excel and summed per laptop.

### 2.4 Efficiency formula

Time efficiency is computed per laptop and then averaged:

```
E = (Tm − Ta) / Tm × 100%
```

| Symbol | Meaning |
|--------|---------|
| `E` | Time efficiency (%) |
| `Tm` | Manual inspection time (seconds) |
| `Ta` | Automated (Tachys) inspection time (seconds) |

---

## 3. Test Devices

### 3.1 Laptop brands (n = 18)

| Brand | Frequency | Percent |
|-------|----------:|--------:|
| Acer | 6 | 33.3% |
| Lenovo | 5 | 27.8% |
| ASUS | 4 | 22.2% |
| Advan | 1 | 5.6% |
| HP | 1 | 5.6% |
| Axioo | 1 | 5.6% |
| **Total** | **18** | **100.0%** |

Acer, Lenovo, and ASUS together make up 15 of 18 laptops (83.3%), which matches the brands that commonly come into a service shop.

![Proportion of laptop brands tested](docs/images/chart-laptop-brands.png)

### 3.2 Operating systems (n = 18)

| Operating system | Frequency | Percent |
|------------------|----------:|--------:|
| Windows 11 Home | 6 | 33.3% |
| Windows 10 Pro | 4 | 22.2% |
| Windows 7 Ultimate | 3 | 16.7% |
| Windows 10 Home | 2 | 11.1% |
| Windows 11 Pro | 2 | 11.1% |
| Linux Ubuntu | 1 | 5.6% |
| **Total** | **18** | **100.0%** |

- Windows 10 and 11 (supported): **14 laptops (77.8%)**
- Windows 7 (additional, unsupported test): **3 laptops (16.7%)**
- Linux Ubuntu: **1 laptop (5.6%)**, because Linux laptops are rare in a service shop

![Number of laptops tested by operating system](docs/images/chart-operating-systems.png)

---

## 4. Feature Support by Operating System

Tachys is written in **Bash** (Linux) and **Batch** (Windows), so it needs no extra runtime and can run straight from a USB flash drive.

| Menu | Feature | Linux (`Tachys.sh`) | Windows (`Tachys.cmd`) |
|:----:|---------|:-------------------:|:----------------------:|
| – | Install scripts (`Install.sh`, `Uninstall.sh`) | ✅ | ❌ |
| `1` | SSD/HDD health check | ✅ | ✅ |
| `2` | Wi-Fi adapter / connectivity check | ✅ | ✅ |
| `3` | Keyboard test | ✅ | ✅ |
| `4` | Audio output test | ✅ | ✅ |
| `5` | Battery health check | ✅ | ✅ |
| `6` | Resource-intensive process check | ✅ | ✅ |
| `7` | Disable Fast Startup | ❌ | ✅ |
| `S` | Open Windows Security | ❌ | ✅ |
| `0` | Exit | ✅ | ✅ |

**Scope:** Windows 10, Windows 11, and Ubuntu Linux on **laptops**. Desktop PCs, other Linux distributions, macOS, and older Windows versions are out of scope. Tachys contains no destructive commands (no data deletion or formatting).

---

## 5. Functional Test Results

Every menu option (`S`, `1`–`7`, `0`) was run on each device. A dash (`–`) means the option does not exist on that OS.

### 5.1 Supported operating systems (15 laptops)

**Result: 13 of 15 laptops ran every available option with no problems.** Failures occurred on only two Windows laptops, and no laptop failed on all options.

| # | Laptop model | Operating system | S | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 0 |
|--:|--------------|------------------|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 1 | Advan Soulmate 1405 | Linux Ubuntu 26.04.1 LTS | – | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | – | ✅ |
| 2 | Acer Aspire Lite 14-37P | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3 | Acer Aspire A314-21 | Windows 10 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 4 | ASUSTek X441BA | Windows 10 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 5 | Acer Aspire A314-22 | Windows 10 Pro | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 6 | Lenovo 83DV | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 7 | ASUSTek TUF Gaming F15 FX506HCC | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ |
| 8 | Lenovo 81X7 | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 9 | ASUSTek TUF Gaming FX504GE FX80GE 323 | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 10 | Lenovo 82V6 | Windows 11 Pro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 11 | ASUSTeK TUF GAMING FX504GD.322 | Windows 11 Pro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 12 | Lenovo 82KT | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 13 | Lenovo 20LNS0BN00 | Windows 10 Pro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 14 | HP ProBook 430 G1 | Windows 10 Pro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 15 | Acer Aspire A314-41 | Windows 10 Pro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**Menu legend:** `S` Windows Security · `1` SSD/HDD · `2` Wi-Fi · `3` Keyboard · `4` Audio output · `5` Battery · `6` Heavy processes · `7` Fast Startup · `0` Exit

**Test breakdown:** 14 Windows laptops (8 × Windows 11, 6 × Windows 10) and 1 Linux Ubuntu laptop.

**Both failures involved security software** (see [Section 7](#7-issues-found-in-the-field)):

| Laptop | Failed option(s) | Cause |
|--------|------------------|-------|
| Acer Aspire A314-22 (Windows 10 Pro) | `S` | Third-party antivirus (Smadav) and limited access to Windows Security |
| ASUS TUF Gaming F15 FX506HCC (Windows 11 Home) | `5`, `6` | RAV Endpoint Protection flagged PowerShell as a suspicious process |

### 5.2 Additional test: Windows 7 (3 laptops)

Windows 7 is **not supported**. These laptops were tested only to find the compatibility limit.

| # | Laptop model | Operating system | S | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 0 |
|--:|--------------|------------------|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 1 | Acer Aspire E1-432 | Windows 7 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 2 | Acer Aspire 4349 | Windows 7 Ultimate | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3 | Axioo Pico | Windows 7 Ultimate | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

Tachys is not compatible with Windows 7. It does not fail completely, but results are inconsistent between devices.

### 5.3 Summary

| Group | Laptops | Fully passed | Partial failure | Total failure |
|-------|--------:|-------------:|----------------:|--------------:|
| Windows 10 / 11 + Linux (supported) | 15 | 13 | 2 | 0 |
| Windows 7 (unsupported) | 3 | 0 | 1 | 2 |

---

## 6. Time Efficiency: Manual vs Tachys

### 6.1 Manual inspection baseline

| ID | Laptop | Condition | Duration (s) | Duration (min) |
|----|--------|-----------|-------------:|---------------:|
| ID01 | Acer Aspire L14-37P | Very good | 226 | 3.77 |
| ID02 | Lenovo 20LNS0BN00 | Good | 212 | 3.53 |
| ID03 | ASUSTeK TUF GAMING FX504GD.322 | Screen display glitch | 364 | 6.07 |
| ID04 | Acer Aspire A314-22 | Unstable OS, frequent crashes | 248 | 4.13 |
| ID05 | HP ProBook 430 G1 | Slow Windows, touchpad and keyboard not working | 226 | 3.77 |
| | **Average** | | **255** | **4.25** |

### 6.2 Manual vs Tachys

| ID | Manual (s) | Tachys (s) | Difference (s) | Efficiency (%) |
|----|-----------:|-----------:|---------------:|---------------:|
| ID01 | 226 | 85.67 | 140 | 62.09 |
| ID02 | 212 | 105.50 | 107 | 50.24 |
| ID03 | 364 | 84.57 | 279 | 76.77 |
| ID04 | 248 | 97.08 | 151 | 60.85 |
| ID05 | 226 | 143.09 | 83 | 36.69 |
| **Average** | **255** | **103** | **152** | **57.33** |

```
Manual   ██████████████████████████  255 s
Tachys   ██████████                  103 s
```

### 6.3 Observations

- Tachys was faster than manual inspection on **all five laptops**. Average time dropped from **255 s to 103 s**, an average saving of **152 s** and an average efficiency of **57.33%**.
- The highest efficiency was on **ID03 (76.77%)**, which also had the slowest manual check (364 s) because of the screen glitch.
- The lowest efficiency was on **ID05 (36.69%)**, which had the slowest Tachys run (143.09 s). That laptop had slow Windows plus a non-working keyboard and touchpad, which probably lengthened processing (this is an assumption and was not measured).
- Efficiency is not determined by manual duration alone: ID01 and ID05 both took 226 s manually but had very different efficiency (62.09% vs 36.69%).

> The 10-minute battery check is not included, since it takes the same time with either method.

---

## 7. Issues Found in the Field

### 7.1 Security software

**Smadav USB Protect blocks `Tachys.cmd`** (Acer Aspire A314-22)
Smadav detected and blocked the script when it was run from the USB drive.
**Fix:** run `Tachys.cmd` with *Run as administrator*.

![Tachys.cmd blocked by Smadav USB Protect](docs/images/issue-01-smadav-block.jpg)

**Virus & Threat Protection page not accessible** (Windows 10 Pro)
Real-time protection could not be disabled through the usual page, because the `gpedit.msc` option is only available on certain Windows editions.
**Fix:** after real-time protection was disabled through the available settings, option `S` in Tachys worked without reopening Windows Security.

![Virus & Threat Protection could not be accessed](docs/images/issue-02-threat-protection-inaccessible.jpg)

**RAV Endpoint Protection flags PowerShell** (ASUS TUF Gaming F15 FX506HCC)
Options `5` and `6` failed because PowerShell was detected as a *suspicious process*.
**Fix:** choose *Resume process* in the notification window; options `5` and `6` then ran normally.

![RAV Endpoint Protection suspicious process notification](docs/images/issue-03-rav-suspicious-process.jpg)

### 7.2 Operating system version

**Linux coverage is limited.** Only one Linux Ubuntu laptop could be tested because Linux laptops rarely come into the shop.

**Acer Aspire E1-432, Windows 7 (2017): total failure.**
The main menu appeared, but it was small and had no banner, and no option could run.

![Tachys.cmd menu on Windows 7](docs/images/issue-04-windows7-menu.jpg)

**Acer Aspire 4349, Windows 7 Ultimate (2011): partial failure.**

| Option | Result | Likely cause |
|:------:|--------|--------------|
| `S` | Opens Windows Security, which does not exist on Windows 7 | Feature not available on this OS |
| `1` | Fails and reports "no disk detected" even though a disk exists | PowerShell does not recognize `Get-PhysicalDisk` (cmdlet probably missing from the built-in Windows 7 PowerShell) |
| `2`, `3`, `4` | Work | – |
| `5` | Reports "battery not found" although the laptop has a removable battery | Battery commands differ on Windows 7 |
| `6`, `7` | Work | – |

![Option 1 failing on Windows 7 because Get-PhysicalDisk is not recognized](docs/images/issue-05-windows7-get-physicaldisk.jpg)

### 7.3 Problems unrelated to Tachys

Some customer laptops had cyber-attacks, motherboard damage, tampered systems, or other faults that stopped Windows from booting. These were fixed by reinstalling Windows from bootable media (DLC Boot) after deleting the old partitions.

---

## 8. Design: Computational Thinking

Tachys was designed with the four concepts of computational thinking:

| # | Concept | How it is applied in Tachys |
|--:|---------|-----------------------------|
| 1 | **Decomposition** | Tachys is split into small functions, one per feature (disk, Wi-Fi, keyboard, audio, battery, heavy processes, Fast Startup, Windows Security), joined by one main menu. Linux adds install / uninstall. |
| 2 | **Pattern recognition** | `Tachys.sh` (Bash) and `Tachys.cmd` (Batch) follow the same pattern: show menu → user picks a feature → run it → show result → return to menu. |
| 3 | **Abstraction** | Raw command output is hidden, filtered, and reduced to short results such as good/bad status or a health value. |
| 4 | **Algorithm** | Each feature has a clear step-by-step flow (condition checks, Yes/No branches, final result) modeled in a flowchart before being written as a script. |

Output is grouped into three labels: `[INFO]` information, `[WARN]` warning, and `[ERROR]` failure.

---

## 9. Design: Flowcharts

Each flowchart was drawn before the matching script was written. The text inside the images is in Indonesian.

### 9.1 Linux

**`Install.sh`** registers a launcher (desktop entry) so `Tachys.sh` can be opened with a double click, even on FAT32 / exFAT / NTFS drives that do not support Unix execute permission. It also converts CRLF to LF if needed.

![Install.sh flowchart](docs/images/flowchart-01-linux-install.png)

**`Uninstall.sh`** removes the desktop entry and wrapper created by `Install.sh`.

![Uninstall.sh flowchart](docs/images/flowchart-02-linux-uninstall.png)

**`Tachys.sh` main flow** covers initialization (CRLF check, temp directory with `trap cleanup`, terminal sizing) and the main menu loop.

![Tachys.sh main flowchart](docs/images/flowchart-03-linux-main.png)

### 9.2 Windows

**`Tachys.cmd` main flow** covers initialization (UTF-8, `KEEP_OPEN` relaunch, `%TEMP%\Tachys` directory) and the main menu. The display mode depends on terminal size: *mini* (height < 17 rows), *full* (height ≥ 34 rows and width ≥ 64 columns), or *compact* (everything else).

![Tachys.cmd main flowchart](docs/images/flowchart-04-windows-main.png)

### 9.3 Feature flowcharts

#### Option 1: SSD/HDD health

- **Linux:** uses `smartctl` (`smartctl --scan`, with `lsblk` as a fallback, then `smartctl -i -H -A`, retrying with `-d sat`). Falls back to eMMC data if SMART is unsupported.
- **Windows:** `Get-PhysicalDisk` for `HealthStatus`, plus *Storage Reliability Counter* for wear level, power-on hours, error count, and temperature. Warns if health is not *Healthy* or wear level is **≥ 80%**.

![SSD/HDD health flowchart](docs/images/flowchart-05-storage-health.png)

#### Option 2: Wi-Fi connectivity

- **Linux:** detects the interface through `/sys` (phy80211), `iw dev`, and `nmcli`; checks `rfkill`; pings the gateway **10×** (packet loss and quality), then `google.com` **3×**.
- **Windows:** `Get-NetAdapter`, gateway ping, `netsh wlan show interfaces` (state, SSID, signal, channel, band), then `google.com` **3×**.

![Wi-Fi connectivity flowchart](docs/images/flowchart-06-wifi.png)

#### Option 3: Keyboard test

- **Linux:** finds or builds the `keyboard-tester` binary (compiled with `gcc`, source downloaded via `git` / `curl` / `wget` if missing), checks libraries with `ldd`, then runs it. Exit codes 126 / 127 suggest deleting the old binary and retrying.
- **Windows:** locates `KeyboardTestUtility.exe`, checks Real-Time Protection status, copies the app to a temp directory, and runs it.

![Keyboard test flowchart](docs/images/flowchart-07-keyboard.png)

#### Option 4: Audio output

- **Linux:** `speaker-test` (from `alsa-utils`) plays a stereo test tone. Left-then-right means normal.
- **Windows:** PowerShell plays a system WAV file twice, falls back to `SystemSounds`, then to a two-tone beep, and offers to open Sound Settings.

![Audio output flowchart](docs/images/flowchart-08-audio.png)

#### Option 5: Battery health

Battery health is `full charge capacity ÷ design capacity`, classified as:

| Battery health | Category |
|:--------------:|----------|
| ≥ 80% | Good |
| 60% – < 80% | Fair, starting to decline |
| < 60% | Poor, consider replacing the battery |

- **Linux:** reads `/sys/class/power_supply/BAT*` (plus `upower` if available).
- **Windows:** PowerShell plus a `powercfg` XML report (capacity in mWh), cycle count from `powercfg` / WMI, and an optional HTML battery report.

![Battery health flowchart](docs/images/flowchart-09-battery.png)

#### Option 6: Resource-intensive processes

| | Linux | Windows |
|---|-------|---------|
| Data source | `ps` | `Get-Process` (1 s CPU sample) |
| "Heavy" threshold | CPU **or** memory **> 20%** | Memory **> 500 MB** or CPU **> 50%** |
| Kill command | `kill` | `Stop-Process` |
| Shown | Top 10 by CPU + antivirus/security processes | Top 10 by CPU + antivirus from Security Center |

Entered PIDs are validated (must be numeric, must exist, and must not be a system process, Tachys itself, a kernel thread, or a zombie process) and the user must confirm (Y/N) before a process is stopped.

![Heavy process check flowchart](docs/images/flowchart-10-heavy-processes.png)

#### Option 7: Disable Fast Startup (Windows only)

Checks administrator rights with `fltmc`, reads the `HiberbootEnabled` registry value, sets it to `0` if needed, and reminds the user to restart.

![Fast Startup flowchart](docs/images/flowchart-11-fast-startup.png)

#### Option S: Windows Security (Windows only)

Opens the *Virus & threat protection* page via `windowsdefender://threatsettings` (fallback: `ms-settings:windowsdefender`) and reminds the user to turn off Real-Time Protection manually.

![Windows Security flowchart](docs/images/flowchart-12-windows-security.png)

---

## 10. Development Environment & Dependencies

### 10.1 Development environment

| Tool | Purpose |
|------|---------|
| Windows 11 and Linux Ubuntu laptops | Developing and testing on both OSes |
| Visual Studio Code | Code editor |
| Windows Terminal, GNOME Terminal | Running and observing the scripts |
| Git / GitHub | Version control and distribution |
| USB flash drive | Portable distribution to customer devices |
| Internet connection | References and repository access |

### 10.2 Runtime dependencies

No extra runtime is needed. Bash and Batch are built into Linux and Windows.

| System | Dependency | Used for |
|--------|------------|----------|
| Linux | `smartmontools` (`smartctl`) | SSD/HDD health |
| Linux | `alsa-utils` (`speaker-test`) | Audio output test |
| Linux | `gcc`, `git` / `curl` / `wget` | Building / downloading the keyboard tester |
| Linux | `nmcli`, `iw`, `rfkill` | Wi-Fi connectivity |
| Linux | `upower` | Extra battery info |
| Windows | PowerShell 5.1 (built in) | Disk, battery, and process checks |
| Windows | `netsh`, `powercfg` (built in) | Wi-Fi (`netsh`) and battery (`powercfg`) |
| Windows | `KeyboardTestUtility.exe` | Keyboard test (bundled in the app folder) |

Supported storage formats for the USB drive: FAT32, exFAT, NTFS, Btrfs, XFS, and ext4.

---

## 11. Limitations

- **Small timing sample:** only 5 laptops, each measured once per method. Results are indicative and should not be generalized.
- **Manual stopwatch timing:** small errors from human reaction time are possible, although the same person did all measurements.
- **Limited Linux testing:** only 1 Linux Ubuntu laptop was tested.
- **Not supported:** Windows 7 and older, macOS, other Linux distributions, and desktop PCs.
- **Security software:** some third-party antivirus tools may flag or block the scripts.
- **No automatic logging** of inspection results yet.

---

## 12. Conclusions & Future Work

**Conclusions**

- Tachys ran on Windows 10, Windows 11, and Linux Ubuntu across many brands, models, and Windows editions. **13 of 15** supported laptops passed every available option.
- Average inspection time fell from **255 s** (manual) to **103 s** (Tachys), a **57.33%** average time saving.
- The failures found came from third-party security software and unsupported OS versions, and the security-software issues had working fixes.

**Future work**

- Add macOS support.
- Extend to other Linux distributions, desktop PCs, and older Windows versions such as Windows 7.
- Test on more devices and more Linux variants.
- Reduce false detections by third-party antivirus (Smadav, RAV Endpoint Protection).
- Add automatic logging of inspection results.
