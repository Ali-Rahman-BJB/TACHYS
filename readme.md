# TACHYS SCRIPTING

▄█████ ██▄  ▄██ ██ ▄█▀   █████▄  ▄████  █████▄  ██   ▄██   ██▄  ▄██ ▄████▄ █████▄  ██████ ▄████▄ █████▄ ██  ██ █████▄  ▄████▄ 
▀▀▀▄▄▄ ██ ▀▀ ██ ████     ██▄▄█▀ ██  ▄▄▄ ██▄▄██▄ ██    ██   ██ ▀▀ ██ ██▄▄██ ██▄▄██▄   ██   ██▄▄██ ██▄▄█▀ ██  ██ ██▄▄██▄ ██▄▄██ 
█████▀ ██    ██ ██ ▀█▄   ██      ▀███▀  ██   ██ ██    ██   ██    ██ ██  ██ ██   ██   ██   ██  ██ ██     ▀████▀ ██   ██ ██  ██

**TACHYS** is a portable diagnostic toolkit designed to help technicians, students, and interns perform basic computer component checks through the terminal.

* **Author:** Ali Rahman
* **Repository:** https://github.com/Ali-Rahman-BJB/TACHYS
* **School:** SMK PGRI 1 Martapura
* **Project Status:** Windows support is ready and available; Linux support is provided through installation and uninstallation scripts.

---

## Project Overview

TACHYS is designed to check basic hardware and software conditions in a simple, fast, and practical way, especially in lab environments, flash drives, or customer service scenarios.

Core features currently available include:

- HDD/SSD health check
- WiFi status and connectivity check
- Keyboard test
- Audio output test
- Battery health and cycle count check
- Heavy process / antivirus monitoring
- Windows Fast Startup disabling
- Windows Security settings access

---

## Folder Structure

```text
TACHYS/
├── Linux/
│   ├── Install.sh
│   ├── Tachys.sh
│   └── Uninstall.sh
├── Windows/
│   ├── Tachys.cmd
│   └── KMS5.0.cmd
├── Application/
│   ├── LINUX/
│   └── WINDOWS/
├── readme.md
├── CONTRIBUTING.md
├── LICENSE
└── ...
```

### Important folders

- `Linux/Install.sh`  : prepares a desktop launcher so the `.sh` file can be opened in the terminal.
- `Linux/Uninstall.sh`: removes the launcher that was previously created.
- `Linux/Tachys.sh`   : main diagnostic script for Linux.
- `Windows/Tachys.cmd`: main Windows diagnostic script.
- `Windows/KMS5.0.cmd`: additional Windows/Office activation utility, not part of the main diagnostic menu.
- `Application/`: contains supporting tools used by the scripts, such as `KeyboardTestUtility.exe` for Windows and the Linux keyboard tester.

---

## Requirements

### Windows

Basic requirements:

- Windows 10 / 11
- PowerShell available by default on Windows
- Command Prompt / PowerShell with enough privileges for certain checks
- For features like Fast Startup and system settings, it is recommended to run as Administrator
- For the keyboard tester, the file `KeyboardTestUtility.exe` must exist in `Application\WINDOWS` or in the appropriate location

Notes:

- The main Windows script is `Windows/Tachys.cmd`
- Some features will ask for Administrator rights or open Windows security settings
- Disk and battery checks are more accurate when run as Administrator

### Linux

Basic requirements:

- Ubuntu/Debian-based Linux or a broadly compatible distribution
- Bash shell
- Desktop environment supporting file manager launcher integration
- `alsa-utils` package if using the audio test via `speaker-test`
- Write access to `~/.local/share/applications` for the installer launcher

Important notes:

- The main Linux script is `Linux/Tachys.sh`
- The Linux installer does not install a global app; it only creates a launcher so the `.sh` file can be opened correctly in the terminal

---

## Usage Flow

### 1. Clone or obtain the project

```bash
git clone https://github.com/Ali-Rahman-BJB/TACHYS.git
cd TACHYS
```

You can also copy the project folder to a flash drive or removable media for use on target computers.

---

### 2. Windows usage flow

1. Open the `Windows` folder.
2. Run `Tachys.cmd`.
3. Choose an option from the menu:
   - `1` Check HDD/SSD health
   - `2` Check WiFi card status
   - `3` Keyboard test
   - `4` Audio test
   - `5` Battery health check
   - `6` Heavy process / antivirus check
   - `7` Disable Fast Startup
   - `s` Open Windows Security
   - `0` Exit
4. Some features will automatically open PowerShell or relevant Windows settings.
5. If `KeyboardTestUtility.exe` is missing, the script will guide you to the correct location and solution.

Notes:

- The `Windows` folder already contains the active diagnostic script ready for Windows use.
- `KMS5.0.cmd` is an additional utility and is not part of the main TACHYS diagnostic menu.

---

### 3. Linux usage flow

1. Open a terminal in the project folder.
2. Run:

```bash
bash Linux/Install.sh
```

3. After installation finishes, open `Linux/Tachys.sh` by:
   - right-clicking and choosing `Open With` → `Other Application` → select `Tachys (Run in Terminal)`, or
   - running directly from the terminal:

```bash
bash Linux/Tachys.sh
```

4. When no longer needed, run the uninstall script:

```bash
bash Linux/Uninstall.sh
```

5. The Linux script checks things such as:
   - battery health
   - WiFi card status
   - audio output
   - keyboard tester
   - basic system / hardware information

---

## Features Already Available

### Windows

- HDD/SSD health checks using `Get-PhysicalDisk` and `Get-StorageReliabilityCounter`
- WiFi and internet connectivity checks
- Keyboard test using an external utility moved to a temp folder for safety
- Audio output test via the Windows sound system
- Battery health and cycle count evaluation
- Detection of heavy processes and antivirus/security software
- Fast Startup disabling to normalize shutdown/restart behavior
- Quick access to Windows Security settings

### Linux

- Runs the keyboard tester from `Application/LINUX/keyboard-tester`
- Battery checks from `/sys/class/power_supply` and `upower`
- Audio test using `speaker-test`
- WiFi interface and link status detection
- Basic hardware and system information summary

---

## Limitations

TACHYS is still a portable diagnostic toolkit intended for basic troubleshooting. Some limitations should be considered:

- Linux has mainly been tested on Ubuntu and similar distributions
- Some Windows features require Administrator rights
- Hardware data may vary depending on drivers, device type, and system configuration
- Some external tools, such as the keyboard tester, may require additional files inside `Application/`

---

## Project Status

**Development Status:** Active / Ready for practical use

At the moment:

- The Windows diagnostic flow is available and ready in the `Windows` folder
- Linux already includes an installer, uninstaller, and main script
- The project continues to evolve with improvements in compatibility and additional features

---

## Final Note

TACHYS was created to make computer diagnostics faster, more structured, and more practical, especially for technicians, interns, and school-based learning activities such as **SMK PGRI 1 Martapura**.

It is intended to support basic computer inspection and troubleshooting in a more efficient and organized way.