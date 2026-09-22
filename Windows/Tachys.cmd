@echo off
setlocal enabledelayedexpansion
title TACHYS - Portable Diagnostic Toolkit (Windows)
color 0A
chcp 65001 >nul

:: ============================================================
:: SCRIPT_DIR = folder tempat file .bat ini berada
:: FLASHDISK_ROOT = satu level di atas folder Batch (sesuaikan
::                  jika struktur foldermu berbeda)
:: ============================================================
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "FLASHDISK_ROOT=%%~fI"

:: Path default keyboard tester (relatif terhadap flashdisk).
:: Kalau ternyata exe-nya selalu ada di path tetap, tinggal ganti
:: baris di bawah ini dengan path absolut kamu, contoh:
::   set "KEYTEST_APP=D:\VSCODE\TACHYS\Application\WINDOWS\KeyboardTestUtility.exe"
set "KEYTEST_APP=%FLASHDISK_ROOT%\Application\WINDOWS\KeyboardTestUtility.exe"

set "TMP_DIR=%TEMP%\Tachys"
if not exist "%TMP_DIR%" mkdir "%TMP_DIR%" >nul 2>&1

goto :main

:: ============================================================
:: BANNER
:: ============================================================
:show_banner
cls
echo ================================================================================
echo.
echo   _______  _______  _______  _______  _______  _______  _______  _______
echo  |  _   _ ||  _   _ ||  _   _ ||  _   _ ||  _   _ ||  _   _ ||  _   _ ||  _   _ |
echo  | | | | || | | | || | | | || | | | || | | | || | | | || | | | || | | | |
echo  | |_| |_|| |_| |_|| |_| |_|| |_| |_|| |_| |_|| |_| |_|| |_| |_|| |_| |_|
echo  |  ___  ||  ___  ||  ___  ||  ___  ||  ___  ||  ___  ||  ___  ||  ___  |
echo  | |   | || |   | || |   | || |   | || |   | || |   | || |   | || |   | |
echo  | |___| || |___| || |___| || |___| || |___| || |___| || |___| || |___| |
echo  |  ___  ||  ___  ||  ___  ||  ___  ||  ___  ||  ___  ||  ___  ||  ___  |
echo  | |   | || |   | || |   | || |   | || |   | || |   | || |   | || |   | |
echo  | |   | || |   | || |   | || |   | || |   | || |   | || |   | || |   | |
echo  | |___| || |___| || |___| || |___| || |___| || |___| || |___| || |___| |
echo  |_______||_______||_______||_______||_______||_______||_______||_______|
echo.
echo ================================================================================
echo         TACHYS - Portable Diagnostic Toolkit (Windows)
echo ================================================================================
echo.
echo Author      : Ali Rahman
echo Student ID  : 24020115 / 3085417291
echo Grade       : Grade 12 - Computer and Network Engineering
echo Repository  : https://github.com/Ali-Rahman-BJB/TACHYS
echo.
goto :eof

:: ============================================================
:: MENU
:: ============================================================
:show_menu
echo ================================================================================
echo         Pilih tool yang ingin dijalankan:
echo.
echo   1. Cek Kesehatan HDD/SSD (Storage Reliability)
echo   2. Cek Status WiFi Card
echo   3. Keyboard Tester
echo   4. Audio Output
echo   5. Cek Kesehatan Baterai
echo   6. Cek Antivirus / Proses Berat
echo   0. Keluar
echo.
echo ================================================================================
echo.
goto :eof

:: ============================================================
:: 1. DISK HEALTH (SSD/HDD) via Get-StorageReliabilityCounter
:: ============================================================
:run_disk_health
echo [INFO] Memeriksa kesehatan HDD/SSD (Storage Reliability Counter) ...
echo.

powershell -NoProfile -Command "$disks = Get-PhysicalDisk; if (-not $disks) { Write-Host '[ERROR] Tidak ada disk yang terdeteksi di sistem ini.' } else { foreach ($d in $disks) { Write-Host '===================================================='; Write-Host ('Device        : ' + $d.DeviceId + ' - ' + $d.FriendlyName); Write-Host ('Media Type    : ' + $d.MediaType); Write-Host ('Health Status : ' + $d.HealthStatus); Write-Host ('Ukuran        : ' + [math]::Round($d.Size/1GB,1) + ' GB'); try { $rel = $d | Get-StorageReliabilityCounter -ErrorAction Stop; if ($null -ne $rel.Wear) { Write-Host ('Wear Level    : ' + $rel.Wear + '%% (persentase keausan SSD)') } else { Write-Host 'Wear Level    : tidak tersedia dari device ini' }; Write-Host ('Read Errors   : ' + $rel.ReadErrorsTotal); Write-Host ('Write Errors  : ' + $rel.WriteErrorsTotal); if ($rel.Temperature) { Write-Host ('Suhu          : ' + $rel.Temperature + ' C') } } catch { Write-Host '[WARN] Data reliability counter tidak tersedia untuk device ini.'; Write-Host '       (Perlu dijalankan sebagai Administrator, atau device tidak mendukung fitur ini.)' } } }"

echo.
echo [INFO] Pemeriksaan selesai.
echo        Wear Level mendekati 100%% berarti SSD sudah sangat aus, pertimbangkan backup/penggantian.
echo        Untuk hasil paling akurat, jalankan Command Prompt sebagai Administrator.
echo.
echo [TIP] Perintah manual yang setara jika ingin dijalankan sendiri di PowerShell:
echo       Get-PhysicalDisk ^| Get-StorageReliabilityCounter ^| Select-Object DeviceId, Wear, ReadErrorsTotal, WriteErrorsTotal
exit /b 0

:: ============================================================
:: 2. WIFI CHECK
:: ============================================================
:run_wifi_check
echo [INFO] Memeriksa status WiFi Card ...
echo.

if not exist "%TMP_DIR%" mkdir "%TMP_DIR%" >nul 2>&1
netsh wlan show interfaces > "%TMP_DIR%\wifi.txt" 2>nul

findstr /i /c:"tidak dapat ditemukan" /c:"not run on" /c:"no wireless interface" "%TMP_DIR%\wifi.txt" >nul 2>&1
if not errorlevel 1 (
    echo [WARN] Tidak ditemukan interface WiFi pada sistem ini.
    echo        ^(Wajar jika laptop/PC ini tidak memiliki WiFi card, atau adapter/driver-nya mati.^)
    exit /b 1
)

for /f "usebackq tokens=* delims=" %%L in ("%TMP_DIR%\wifi.txt") do (
    echo %%L | findstr /i /c:"Name" /c:"State" /c:"SSID" /c:"Signal" /c:"Radio status" /c:"Receive rate" /c:"Transmit rate" >nul
    if not errorlevel 1 echo %%L
)

echo.
echo [INFO] Pemeriksaan WiFi selesai.
echo        Jika "State" menunjukkan "disconnected", coba sambungkan ke jaringan terlebih dahulu.
exit /b 0

:: ============================================================
:: 3. KEYBOARD TESTER
:: ============================================================
:run_keyboard_tester
echo [INFO] Menyiapkan Keyboard Tester ...

if not exist "%KEYTEST_APP%" (
    echo [ERROR] File KeyboardTestUtility.exe tidak ditemukan di:
    echo         %KEYTEST_APP%
    echo         Pastikan struktur folder flashdisk masih sesuai:
    echo         TACHYS\Application\WINDOWS\KeyboardTestUtility.exe
    exit /b 1
)

if not exist "%TMP_DIR%" (
    mkdir "%TMP_DIR%" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Gagal membuat direktori sementara: %TMP_DIR%
        exit /b 1
    )
)

copy /y "%KEYTEST_APP%" "%TMP_DIR%\KeyboardTestUtility.exe" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Gagal menyalin file ke %TMP_DIR%
    echo         Kemungkinan penyebab: flashdisk terlepas, ruang disk penuh,
    echo         atau tidak ada izin tulis ke folder temp.
    exit /b 1
)

echo [INFO] Menjalankan Keyboard Tester ...
start "" /wait "%TMP_DIR%\KeyboardTestUtility.exe"
if errorlevel 1 (
    echo [ERROR] Keyboard Tester keluar dengan error.
    exit /b 1
)

echo [INFO] Keyboard Tester selesai.
exit /b 0

:: ============================================================
:: 4. AUDIO OUTPUT
:: ============================================================
:run_audio_output_test
echo [INFO] Membuka pengaturan Audio Output ...
start "" ms-settings:sound
if errorlevel 1 (
    echo [WARN] Gagal membuka via ms-settings, mencoba mmsys.cpl ...
    start "" control mmsys.cpl
)
exit /b 0

:: ============================================================
:: 5. BATTERY HEALTH
:: ============================================================
:run_battery_health
echo [INFO] Memeriksa kesehatan baterai ...
echo.

powershell -NoProfile -Command "$b = Get-CimInstance -ClassName Win32_Battery; if (-not $b) { Write-Host '[WARN] Tidak ditemukan baterai di sistem ini.'; Write-Host '       (Wajar jika ini adalah PC desktop tanpa baterai.)' } else { foreach ($x in $b) { Write-Host ('Status          : ' + $x.Status); Write-Host ('Estimasi charge : ' + $x.EstimatedChargeRemaining + '%%') } }"

echo.
echo [INFO] Membuat laporan kesehatan baterai lengkap (powercfg) ...
set "BATREPORT=%TMP_DIR%\battery-report.html"
if not exist "%TMP_DIR%" mkdir "%TMP_DIR%" >nul 2>&1
powercfg /batteryreport /output "%BATREPORT%" >nul 2>&1
if exist "%BATREPORT%" (
    echo [INFO] Laporan tersimpan di: %BATREPORT%
    echo [INFO] Membuka laporan di browser ...
    echo        ^(Laporan ini berisi Design Capacity, Full Charge Capacity, dan Cycle Count - setara dengan info "Kesehatan" di versi Linux.^)
    start "" "%BATREPORT%"
) else (
    echo [WARN] Gagal membuat laporan powercfg. Perangkat mungkin tidak memiliki baterai.
)

exit /b 0

:: ============================================================
:: 6. ANTIVIRUS / PROSES BERAT
:: ============================================================
:run_process_monitor
echo [INFO] Memeriksa proses antivirus / program berat yang berjalan ...
echo.

powershell -NoProfile -Command "Write-Host '--- 10 proses dengan penggunaan CPU tertinggi ---'; Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Id,ProcessName,CPU,@{Name='Mem(MB)';Expression={[math]::Round($_.WorkingSet/1MB,1)}} | Format-Table -AutoSize; Write-Host ''; Write-Host '--- Produk antivirus / security terdaftar (Security Center) ---'; try { $av = Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntiVirusProduct -ErrorAction Stop; if ($av) { $av | Select-Object displayName | Format-Table -AutoSize } else { Write-Host 'Tidak ditemukan produk antivirus yang terdaftar di Security Center.' } } catch { Write-Host 'Tidak bisa membaca data Security Center (coba jalankan sebagai Administrator).' }; Write-Host ''; Write-Host '--- Proses dengan pemakaian memori sangat besar (lebih dari 500MB) ---'; $heavy = Get-Process | Where-Object { $_.WorkingSet -gt 500MB } | Sort-Object WorkingSet -Descending; if (-not $heavy) { Write-Host 'Tidak ada proses yang terdeteksi memakai memori sangat besar saat ini.' } else { $heavy | Select-Object Id,ProcessName,@{Name='Mem(MB)';Expression={[math]::Round($_.WorkingSet/1MB,1)}} | Format-Table -AutoSize; while ($true) { $pidInput = Read-Host 'Masukkan PID yang ingin dimatikan (kosongkan untuk selesai)'; if ([string]::IsNullOrWhiteSpace($pidInput)) { break }; if ($pidInput -notmatch '^[0-9]+$') { Write-Host '[ERROR] PID tidak valid, harus berupa angka.'; continue }; $proc = Get-Process -Id $pidInput -ErrorAction SilentlyContinue; if (-not $proc) { Write-Host ('[ERROR] PID ' + $pidInput + ' tidak ditemukan (mungkin sudah berhenti).'); continue }; $confirm = Read-Host ('Yakin ingin mematikan proses ' + $proc.ProcessName + ' (PID ' + $pidInput + ')? [Y/N]'); if ($confirm -match '^[Yy]') { try { Stop-Process -Id $pidInput -Force -ErrorAction Stop; Write-Host ('[INFO] Proses ' + $proc.ProcessName + ' (PID ' + $pidInput + ') berhasil dihentikan.') } catch { Write-Host '[ERROR] Gagal menghentikan proses. Mungkin perlu izin Administrator.' } } else { Write-Host '[INFO] Dilewati, proses tidak dimatikan.' } } }"

exit /b 0

:: ============================================================
:: CLEANUP
:: ============================================================
:cleanup
if exist "%TMP_DIR%" (
    rmdir /s /q "%TMP_DIR%" >nul 2>&1
)
goto :eof

:: ============================================================
:: MAIN LOOP
:: ============================================================
:main
call :show_banner
call :show_menu

set /p pilihan="Masukkan pilihan [0-6]: "
echo.

if "%pilihan%"=="1" (
    call :run_disk_health
) else if "%pilihan%"=="2" (
    call :run_wifi_check
) else if "%pilihan%"=="3" (
    call :run_keyboard_tester
) else if "%pilihan%"=="4" (
    call :run_audio_output_test
) else if "%pilihan%"=="5" (
    call :run_battery_health
) else if "%pilihan%"=="6" (
    call :run_process_monitor
) else if "%pilihan%"=="0" (
    echo [INFO] Keluar dari Tachys. Sampai jumpa!
    call :cleanup
    exit /b 0
) else (
    echo [ERROR] Pilihan tidak dikenali: %pilihan%
)

echo.
pause
goto :main