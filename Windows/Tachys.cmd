@echo off
setlocal
title TACHYS - Portable Diagnostic Toolkit (Windows)
color 0A
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "DRIVE_ROOT=%~d0\"

if /i "%~1"=="__KEEP_OPEN__" goto :setup_paths
if "%~1"=="" (
    echo Menyiapkan Tachys, mohon tunggu sebentar...
    start "" /max "%ComSpec%" /k ""%~f0" __KEEP_OPEN__"
    exit /b 0
)

:setup_paths
set "TMP_DIR=%TEMP%\Tachys"
if not exist "%TMP_DIR%" mkdir "%TMP_DIR%" >nul 2>&1

goto :main

:get_term_size
set "TERM_H="
set "TERM_W="
for /f "usebackq tokens=1,2" %%a in (`powershell -NoProfile -Command "$s = $Host.UI.RawUI.WindowSize; Write-Output ($s.Height.ToString() + ' ' + $s.Width.ToString())" 2^>nul`) do (
    set "TERM_H=%%a"
    set "TERM_W=%%b"
)
if not defined TERM_H set "TERM_H=30"
if not defined TERM_W set "TERM_W=100"
goto :eof

:show_banner
cls
call :get_term_size
set "TIER=compact"
if %TERM_H% GEQ 34 if %TERM_W% GEQ 64 set "TIER=full"
if %TERM_H% LSS 17 set "TIER=mini"
goto :banner_%TIER%

:banner_full
echo =====================================================
echo   ████ █   █ █   █   ████   ████ ████  █████     █   
echo  █     ██ ██ █  █    █   █ █     █   █   █      ██   
echo   ███  █ █ █ ███     ████  █  ██ ████    █       █   
echo      █ █   █ █  █    █     █   █ █  █    █       █   
echo  ████  █   █ █   █   █      ███  █   █ █████    ███  
echo.
echo █   █  ███  ████  █████  ███  ████  █   █ ████   ███ 
echo ██ ██ █   █ █   █   █   █   █ █   █ █   █ █   █ █   █
echo █ █ █ █████ ████    █   █████ ████  █   █ ████  █████
echo █   █ █   █ █  █    █   █   █ █     █   █ █  █  █   █
echo █   █ █   █ █   █   █   █   █ █      ███  █   █ █   █
echo =====================================================
echo    TACHYS - Portable Diagnostic Toolkit (Windows)
echo -----------------------------------------------------
echo Author      : Ali Rahman
echo Student ID  : 24020115 / 3085417291
echo Grade       : Grade 12 - Computer and Network Engineering
echo Repository  : https://github.com/Ali-Rahman-BJB/TACHYS
goto :eof

:banner_compact
echo ==============================================================
echo   TACHYS - Portable Diagnostic Toolkit (Windows)
echo --------------------------------------------------------------
echo   Author : Ali Rahman  ^|  Student ID : 24020115 / 3085417291
echo   Grade  : Grade 12 - Computer and Network Engineering
echo   Repo   : https://github.com/Ali-Rahman-BJB/TACHYS
echo ==============================================================
goto :eof

:banner_mini
echo  TACHYS - Portable Diagnostic Toolkit (Windows) ^| Ali Rahman
goto :eof

:show_menu
goto :menu_%TIER%

:menu_full
echo -----------------------------------------------------
echo         Pilih tool yang ingin dijalankan:
echo  [s] Buka Windows Security Virus ^& threat protection Settings
echo   1. Cek Kesehatan HDD/SSD
echo   2. Cek Status WiFi Card ^& Adapter Detection
echo   3. Tes Keyboard Input
echo   4. Tes Audio Output
echo   5. Cek Kesehatan Baterai
echo   6. Cek Program Berat
echo   7. Nonaktifkan Fast Startup Control Panel
echo   0. Keluar
echo -----------------------------------------------------
goto :eof

:menu_compact
echo   Pilih tool yang ingin dijalankan:
echo   [s] Buka Windows Security (Virus ^& threat protection)
echo   1. Cek Kesehatan HDD/SSD         5. Cek Kesehatan Baterai
echo   2. Cek WiFi ^& Adapter            6. Cek Program Berat
echo   3. Tes Keyboard Input            7. Nonaktifkan Fast Startup
echo   4. Tes Audio Output              0. Keluar
echo ==============================================================
goto :eof

:menu_mini
echo  [s] Win Security  1. HDD/SSD  2. WiFi  3. Keyboard  4. Audio
echo  5. Baterai  6. Program Berat  7. Fast Startup  0. Keluar
goto :eof

:: ============================================================
:: 1. DISK HEALTH (SSD/HDD) via Get-StorageReliabilityCounter
:: ============================================================
:run_disk_health
echo [INFO] Memeriksa kesehatan HDD/SSD (Storage Reliability Counter) ...
echo.

powershell -NoProfile -Command ^
    "$disks = @(Get-PhysicalDisk);" ^
    "if ($disks.Count -eq 0) { Write-Host '[ERROR] Tidak ada disk yang terdeteksi di sistem ini.'; exit 0 };" ^
    "foreach ($d in $disks) {" ^
    "  Write-Host '====================================================';" ^
    "  Write-Host ('Device        : ' + $d.DeviceId + ' - ' + $d.FriendlyName);" ^
    "  Write-Host ('Media Type    : ' + $d.MediaType + ' (' + $d.BusType + ')');" ^
    "  Write-Host ('Health Status : ' + $d.HealthStatus);" ^
    "  if ($d.HealthStatus -ne 'Healthy') { Write-Host '[WARN] Status disk bukan Healthy! Segera backup data.' };" ^
    "  Write-Host ('Ukuran        : ' + [math]::Round($d.Size/1GB,1) + ' GB');" ^
    "  try {" ^
    "    $rel = $d | Get-StorageReliabilityCounter -ErrorAction Stop;" ^
    "    if ($null -ne $rel.Wear) { Write-Host ('Wear Level    : ' + $rel.Wear + '%% (persentase keausan HDD/SSD)'); if ($rel.Wear -ge 80) { Write-Host '[WARN] Keausan sudah tinggi, pertimbangkan backup/penggantian.' } } else { Write-Host 'Wear Level    : tidak tersedia dari device ini' };" ^
    "    if ($null -ne $rel.PowerOnHours) { Write-Host ('Power-On Hours: ' + $rel.PowerOnHours + ' jam') };" ^
    "    Write-Host ('Read Errors   : ' + $rel.ReadErrorsTotal);" ^
    "    Write-Host ('Write Errors  : ' + $rel.WriteErrorsTotal);" ^
    "    if ($rel.Temperature) { Write-Host ('Suhu          : ' + $rel.Temperature + ' C') }" ^
    "  } catch {" ^
    "    Write-Host '[WARN] Data reliability counter tidak tersedia untuk device ini.';" ^
    "    Write-Host '       (Perlu dijalankan sebagai Administrator, atau device tidak mendukung fitur ini.)'" ^
    "  }" ^
    "}"

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
call :wifi_adapter_detect
echo [INFO] Detail koneksi WiFi ^(netsh^):
echo.

if not exist "%TMP_DIR%" mkdir "%TMP_DIR%" >nul 2>&1
netsh wlan show interfaces > "%TMP_DIR%\wifi.txt" 2>nul

findstr /i /c:"tidak dapat ditemukan" /c:"tidak ada antarmuka" /c:"not running" /c:"no wireless interface" "%TMP_DIR%\wifi.txt" >nul 2>&1
if not errorlevel 1 (
    echo [WARN] Tidak ditemukan interface WiFi pada sistem ini.
    echo        ^(Wajar jika laptop/PC ini tidak memiliki WiFi card, atau adapter/driver-nya mati.^)
    exit /b 1
)

findstr /i /c:"Name" /c:"Nama" /c:"State" /c:"Status" /c:"SSID" /c:"Signal" /c:"Sinyal" /c:"Radio status" /c:"Receive rate" /c:"Transmit rate" /c:"Laju" /c:"Channel" /c:"Saluran" /c:"Band" "%TMP_DIR%\wifi.txt"

echo.
echo [INFO] Uji konektivitas ke Google.com via ping ...
ping -n 3 google.com
if errorlevel 1 (
    echo [WARN] Ping ke Google gagal atau koneksi internet tidak tersedia.
) else (
    echo [INFO] Koneksi internet ke Google berhasil terdeteksi.
)

echo.
echo [INFO] Pemeriksaan WiFi selesai.
echo        Jika "State" menunjukkan "disconnected", coba sambungkan ke jaringan terlebih dahulu.
exit /b 0

:: ============================================================
:: 2b. ADAPTER DETECTION (dipanggil dari menu WiFi)
:: ============================================================
:wifi_adapter_detect
echo [INFO] Adapter Detection ^(PnP, driver, link speed, signal, gateway ping, packet loss^) ...
echo.

powershell -NoProfile -Command ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "$ads = @(Get-NetAdapter -Physical);" ^
    "if ($ads.Count -eq 0) { Write-Host '[WARN] Tidak ada network adapter fisik yang terdeteksi.'; Write-Host '       (Adapter mungkin nonaktif di BIOS/Device Manager atau driver belum terpasang.)'; exit 0 };" ^
    "$sig = @{}; $cur = '';" ^
    "foreach ($l in @(netsh wlan show interfaces)) { if ($l -match '^\s*(Name|Nama)\s*:\s*(.+?)\s*$') { $cur = $Matches[2] } elseif ($l -match '^\s*(Signal|Sinyal)\s*:\s*(\d+)') { $sig[$cur] = [int]$Matches[2] } };" ^
    "foreach ($a in $ads) {" ^
    "  Write-Host '====================================================';" ^
    "  Write-Host ('Adapter        : ' + $a.Name + ' - ' + $a.InterfaceDescription);" ^
    "  $pnp = Get-PnpDevice -InstanceId $a.PnPDeviceID;" ^
    "  if ($pnp) { $ps = [string]$pnp.Status; $ec = [int]$pnp.ConfigManagerErrorCode; if ($ps -eq 'OK' -and $ec -eq 0) { $pt = 'OK (berfungsi normal)' } elseif ($ec -gt 0) { $pt = $ps + ' (kode error Device Manager: ' + $ec + ')' } else { $pt = $ps } } else { $pt = 'Tidak diketahui (device tidak ditemukan di PnP)' };" ^
    "  Write-Host ('PnP Status     : ' + $pt);" ^
    "  $dd = if ($a.DriverDate) { $a.DriverDate.ToString('yyyy-MM-dd') } else { '-' };" ^
    "  $dv = if ($a.DriverVersionString) { $a.DriverVersionString } else { '-' };" ^
    "  Write-Host ('Driver         : ' + $a.DriverProvider + ' | versi ' + $dv + ' | tanggal ' + $dd);" ^
    "  Write-Host ('Status Link    : ' + $a.Status);" ^
    "  Write-Host ('Link Speed     : ' + $a.LinkSpeed);" ^
    "  $isWifi = ($a.PhysicalMediaType -match '802.11|Wireless') -or $sig.ContainsKey($a.Name);" ^
    "  if (-not $isWifi) { Write-Host 'Signal         : N/A (bukan adapter WiFi)' } elseif ($sig.ContainsKey($a.Name)) { $v = $sig[$a.Name]; $q = if ($v -ge 70) { 'Bagus' } elseif ($v -ge 40) { 'Cukup' } else { 'Lemah' }; Write-Host ('Signal         : ' + $v + '%% (' + $q + ')') } else { Write-Host 'Signal         : tidak tersedia (WiFi belum terhubung ke jaringan)' };" ^
    "  $gw = $null; $cfg = Get-NetIPConfiguration -InterfaceIndex $a.ifIndex; if ($cfg -and $cfg.IPv4DefaultGateway) { $gw = [string]$cfg.IPv4DefaultGateway.NextHop };" ^
    "  if ($a.Status -ne 'Up') { Write-Host 'Gateway Ping   : dilewati (adapter tidak aktif/terhubung)'; Write-Host 'Packet Loss    : N/A' }" ^
    "  elseif (-not $gw) { Write-Host 'Gateway Ping   : tidak ada default gateway (belum dapat IP/DHCP bermasalah)'; Write-Host 'Packet Loss    : N/A' }" ^
    "  else { $p = New-Object System.Net.NetworkInformation.Ping; $n = 10; $ok = 0; $rt = @();" ^
    "    for ($i = 0; $i -lt $n; $i++) { try { $r = $p.Send($gw, 1000); if ($r.Status -eq 'Success') { $ok++; $rt += $r.RoundtripTime } } catch { }; Start-Sleep -Milliseconds 100 };" ^
    "    if ($ok -gt 0) { $avg = [math]::Round(($rt | Measure-Object -Average).Average, 1); Write-Host ('Gateway Ping   : ' + $gw + ' - balasan ' + $ok + '/' + $n + ', rata-rata ' + $avg + ' ms') } else { Write-Host ('Gateway Ping   : ' + $gw + ' - TIDAK ada balasan (0/' + $n + ')') };" ^
    "    $loss = [math]::Round(($n - $ok) / $n * 100, 0); $lq = if ($loss -eq 0) { 'Baik' } elseif ($loss -le 5) { 'Ringan' } else { 'Buruk' };" ^
    "    Write-Host ('Packet Loss    : ' + $loss + '%% (' + ($n - $ok) + ' dari ' + $n + ' paket hilang, ' + $lq + ')') }" ^
    "};" ^
    "Write-Host '===================================================='"

echo.
echo [INFO] Catatan: sebagian router memblokir ICMP, sehingga gateway ping bisa
echo        tampak gagal padahal koneksi normal. PnP Status selain "OK" atau
echo        kode error di Device Manager menandakan masalah driver/hardware.
echo.
exit /b 0

:: ============================================================
:: HELPER: cari KeyboardTestUtility.exe (dipanggil hanya dari menu [3])
:: ============================================================
:find_keytest
if defined KEYTEST_APP if exist "%KEYTEST_APP%" exit /b 0
set "KEYTEST_APP="
for %%P in (
    "%SCRIPT_DIR%\Application\WINDOWS\KeyboardTestUtility.exe"
    "%SCRIPT_DIR%\..\Application\WINDOWS\KeyboardTestUtility.exe"
    "%DRIVE_ROOT%Application\WINDOWS\KeyboardTestUtility.exe"
    "%DRIVE_ROOT%TACHYS\Application\WINDOWS\KeyboardTestUtility.exe"
) do (
    if not defined KEYTEST_APP if exist "%%~fP" set "KEYTEST_APP=%%~fP"
)

if not defined KEYTEST_APP (
    if /i "%DRIVE_ROOT%"=="%SystemDrive%\" (
        echo [INFO] Dijalankan dari drive sistem ^(%SystemDrive%^), pencarian otomatis ke
        echo        seluruh drive dilewati karena akan memakan waktu sangat lama.
    ) else (
        echo [INFO] Mencari KeyboardTestUtility.exe ke seluruh %DRIVE_ROOT% , mohon tunggu...
        for /f "delims=" %%F in ('dir "%DRIVE_ROOT%KeyboardTestUtility.exe" /s /b 2^>nul') do (
            if not defined KEYTEST_APP set "KEYTEST_APP=%%~fF"
        )
    )
)

if not defined KEYTEST_APP set "KEYTEST_APP=%DRIVE_ROOT%TACHYS\Application\WINDOWS\KeyboardTestUtility.exe"
exit /b 0

:: ============================================================
:: 3. KEYBOARD TESTER
:: ============================================================
:run_keyboard_tester
echo [INFO] Menyiapkan Keyboard Tester ...
call :find_keytest

if not exist "%KEYTEST_APP%" (
    echo [ERROR] File KeyboardTestUtility.exe tidak ditemukan di flashdisk ini.
    echo         Sudah dicoba beberapa lokasi umum, termasuk pencarian otomatis
    echo         ke seluruh drive %DRIVE_ROOT%, tapi file tidak ditemukan.
    echo.
    echo [INFO]  Jika file sebelumnya ada lalu hilang, kemungkinan file terhapus
    echo         atau dikarantina oleh Windows Security ^(Windows Security^).
    echo.
    echo [SOLUSI]
    echo 1. Unduh ulang aplikasinya melalui tautan berikut:
    echo    https://www.softpedia.com/get/System/System-Info/Keyboard-Test-Utility.shtml#download
    echo.
    echo 2. Ekstrak/simpan file KeyboardTestUtility.exe ke dalam folder:
    echo    %DRIVE_ROOT%Application\WINDOWS
    echo.
    echo 3. Pastikan untuk menambahkan 'Exclusion' di Windows Security agar file
    echo    tidak terhapus kembali secara otomatis.
    echo.
    exit /b 1
)

echo [INFO] Memeriksa status Windows Security ^(Real-Time Protection^) SEBELUM menyentuh file ...
set "RTP_STATUS=2"
for /f %%R in ('powershell -NoProfile -Command "try { $s = Get-MpComputerStatus -ErrorAction Stop; if ($s.RealTimeProtectionEnabled) { Write-Output 1 } else { Write-Output 0 } } catch { Write-Output 2 }" 2^>nul') do set "RTP_STATUS=%%R"

if "%RTP_STATUS%"=="1" (
    echo.
    echo [PERINGATAN] Real-Time Protection Windows Security sedang AKTIF.
    echo              KeyboardTestUtility.exe TIDAK akan disalin/dijalankan, supaya
    echo              file aslinya di flashdisk tidak ikut dihapus/dikarantina.
    echo              ^(Menyalin file saja sudah bisa memicu Windows Security
    echo              memindai lalu menghapus filenya.^)
    echo.
    echo [SOLUSI] Nonaktifkan sementara Real-Time Protection ^(menu 's' di
    echo          menu utama^), atau tambahkan Exclusion untuk folder %TMP_DIR%
    echo          dan folder aplikasi ini, lalu coba jalankan kembali.
    echo.
    exit /b 1
)

if "%RTP_STATUS%"=="2" (
    echo [WARN] Tidak bisa memastikan status Real-Time Protection ^(mungkin bukan Windows Security/AV lain, atau perlu Administrator^).
    echo        Tachys akan tetap mencoba menjalankan Keyboard Tester, tapi jika file
    echo        tiba-tiba hilang/dihapus, kemungkinan penyebabnya adalah antivirus.
    echo.
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
    echo         tidak ada izin tulis ke folder temp, atau file baru saja
    echo         dihapus/dikarantina oleh antivirus lain saat proses ini berjalan.
    echo.
    echo [SOLUSI] Solusi: Matikan Real-time Protection di Windows Security/Antivirus.
    echo.
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
echo [INFO] Memutar suara tes langsung dari komputer, tidak perlu buka Settings ...
echo.

powershell -NoProfile -Command ^
    "try {" ^
    "  $dir = Join-Path $env:WINDIR 'Media';" ^
    "  $f = @('Windows Notify System Generic.wav','Windows Ding.wav','Alarm01.wav','chimes.wav','ding.wav') | ForEach-Object { Join-Path $dir $_ } | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1;" ^
    "  if ($f) { $sp = New-Object System.Media.SoundPlayer $f; $sp.PlaySync(); Start-Sleep -Milliseconds 300; $sp.PlaySync() }" ^
    "  else { [System.Media.SystemSounds]::Asterisk.Play(); Start-Sleep -Milliseconds 700; [System.Media.SystemSounds]::Exclamation.Play(); Start-Sleep -Milliseconds 700 };" ^
    "  exit 0" ^
    "} catch {" ^
    "  exit 1" ^
    "}"

if errorlevel 1 (
    echo [WARN] Gagal memutar suara sistem, mencoba system beep sebagai gantinya ...
    powershell -NoProfile -Command "[console]::beep(800,400); Start-Sleep -Milliseconds 100; [console]::beep(1000,400)" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Tidak bisa memutar suara test sama sekali di sistem ini.
        echo         Kemungkinan tidak ada output audio yang aktif/terpasang.
        exit /b 1
    )
    echo [INFO] Jika Anda mendengar bunyi beep barusan, output audio berfungsi
    echo        ^(minimal lewat speaker internal/PC speaker^).
) else (
    echo [INFO] Jika Anda mendengar 2 kali bunyi notifikasi barusan, output audio berfungsi normal.
    echo         Tidak dengar suara? Cek volume/mute, kabel/headphone tersambung
    echo         dengan benar, dan pastikan default output device sudah benar.
)

echo.
choice /c YN /n /m "Buka pengaturan Sound untuk cek/ganti default device? [Y/N]: "
if errorlevel 2 exit /b 0

start "" ms-settings:sound
if errorlevel 1 start "" control mmsys.cpl
exit /b 0

:: ============================================================
:: 5. BATTERY HEALTH
:: ============================================================
:run_battery_health
echo [INFO] Memeriksa kesehatan baterai ...
echo.

set "BATXML=%TMP_DIR%\battery-report.xml"
set "BATREPORT=%TMP_DIR%\battery-report.html"
if exist "%BATXML%" del /q "%BATXML%" >nul 2>&1

powershell -NoProfile -Command ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "$w = @(Get-CimInstance -ClassName Win32_Battery);" ^
    "$s = @(Get-CimInstance -Namespace 'root\wmi' -ClassName BatteryStatus);" ^
    "if ($w.Count -eq 0 -and $s.Count -eq 0) { Write-Host '[WARN] Tidak ditemukan baterai di sistem ini.'; Write-Host '       (Wajar jika ini PC desktop tanpa baterai, atau driver baterai tidak melaporkan data via WMI.)'; exit 2 };" ^
    "$map = @{1='Discharging (memakai baterai)';2='Tersambung AC';3='Terisi penuh';4='Low';5='Critical';6='Charging';7='Charging';8='Charging';9='Charging';11='Terisi sebagian'};" ^
    "Write-Host '=== Status Saat Ini ===';" ^
    "foreach ($x in $w) { $st = $map[[int]$x.BatteryStatus]; if (-not $st) { $st = 'Tidak diketahui' }; Write-Host ('Status          : ' + $st); Write-Host ('Estimasi charge : ' + $x.EstimatedChargeRemaining + '%%'); $rt = [int]$x.EstimatedRunTime; if ($x.BatteryStatus -eq 1 -and $rt -gt 0 -and $rt -lt 71582788) { $hh = [math]::Floor($rt/60); Write-Host ('Estimasi sisa   : ' + $hh + ' jam ' + ($rt - $hh*60) + ' menit') } };" ^
    "if ($w.Count -eq 0) { foreach ($x in $s) { $t = if ($x.Charging) { 'Charging' } elseif ($x.Discharging) { 'Discharging' } elseif ($x.PowerOnline) { 'Tersambung AC / Terisi penuh' } else { 'Tidak diketahui' }; Write-Host ('Status          : ' + $t) } };" ^
    "$xml = $env:BATXML;" ^
    "& powercfg /batteryreport /xml /output $xml 2>&1 | Out-Null;" ^
    "$bats = @();" ^
    "if (Test-Path -LiteralPath $xml) { [xml]$doc = Get-Content -LiteralPath $xml -Raw; $bats = @($doc.GetElementsByTagName('Battery') | Where-Object { $_.DesignCapacity }) };" ^
    "Write-Host '';" ^
    "Write-Host '=== Kesehatan Baterai ===';" ^
    "if ($bats.Count -eq 0) { Write-Host '[WARN] Laporan powercfg tidak menghasilkan data kapasitas. Coba jalankan sebagai Administrator.' };" ^
    "$i = 0;" ^
    "foreach ($b in $bats) { $i++; $d = [double]$b.DesignCapacity; $f = [double]$b.FullChargeCapacity; $cc = 0 + $b.CycleCount;" ^
    "if ($cc -le 0) { $wc = Get-CimInstance -Namespace 'root\wmi' -ClassName BatteryCycleCount | Select-Object -First 1; if ($wc -and $wc.CycleCount -gt 0) { $cc = [int]$wc.CycleCount } };" ^
    "$h = if ($d -gt 0) { [math]::Round($f/$d*100,1) } else { $null };" ^
    "$rate = if ($null -eq $h) { 'Tidak diketahui' } elseif ($h -ge 80) { 'Baik' } elseif ($h -ge 60) { 'Cukup, mulai menurun' } else { 'Buruk, pertimbangkan ganti baterai' };" ^
    "Write-Host ('--- Baterai #' + $i + ' ---');" ^
    "if ($b.Manufacturer) { Write-Host ('Produsen        : ' + $b.Manufacturer) };" ^
    "if ($b.Chemistry) { Write-Host ('Kimia           : ' + $b.Chemistry) };" ^
    "Write-Host ('Design Capacity : ' + $d + ' mWh');" ^
    "Write-Host ('Full Charge Cap : ' + $f + ' mWh');" ^
    "if ($null -ne $h) { Write-Host ('Kesehatan       : ' + $h + '%% (' + $rate + ')'); Write-Host ('Tingkat keausan : ' + [math]::Round(100-$h,1) + '%%') };" ^
    "if ($cc -gt 0) { Write-Host ('Cycle Count     : ' + $cc + ' siklus') } else { Write-Host 'Cycle Count     : tidak dilaporkan oleh baterai/driver ini (nilai 0 atau kosong)' } };" ^
    "exit 0"

if "%errorlevel%"=="2" exit /b 1

echo.
echo [INFO] Laporan lengkap (riwayat pemakaian, dll) tersedia dalam format HTML.
choice /c YN /n /m "Buka laporan lengkap di browser? [Y/N]: "
if errorlevel 2 exit /b 0

powercfg /batteryreport /output "%BATREPORT%" >nul 2>&1
if exist "%BATREPORT%" (
    echo [INFO] Laporan tersimpan di: %BATREPORT%
    start "" "%BATREPORT%"
) else (
    echo [WARN] Gagal membuat laporan HTML.
)
exit /b 0

:: ============================================================
:: 6. ANTIVIRUS / PROSES BERAT
:: ============================================================
:run_process_monitor
echo [INFO] Memeriksa proses antivirus / program berat yang berjalan ...
echo.

powershell -NoProfile -Command ^
    "$n = [Environment]::ProcessorCount;" ^
    "$base = @{}; foreach ($p in Get-Process) { if ($null -ne $p.CPU) { $base[$p.Id] = $p.CPU } };" ^
    "Write-Host '[INFO] Mengambil sampel penggunaan CPU selama 1 detik ...'; Start-Sleep -Seconds 1;" ^
    "$rows = foreach ($p in Get-Process) { $pct = 0; if ($base.ContainsKey($p.Id) -and $null -ne $p.CPU) { $pct = [math]::Round(($p.CPU - $base[$p.Id]) / $n * 100, 1) }; [pscustomobject]@{ Id = $p.Id; Name = $p.ProcessName; 'CPU(%%)' = $pct; 'Mem(MB)' = [math]::Round($p.WorkingSet / 1MB, 1) } };" ^
    "Write-Host '';" ^
    "Write-Host '--- 10 proses dengan beban CPU tertinggi (sampel 1 detik) ---';" ^
    "$rows | Sort-Object 'CPU(%%)' -Descending | Select-Object -First 10 | Format-Table Id, Name, 'CPU(%%)', 'Mem(MB)' -AutoSize;" ^
    "Write-Host '--- Produk antivirus / security terdaftar (Security Center) ---';" ^
    "try { $av = Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntiVirusProduct -ErrorAction Stop; if ($av) { $av | Select-Object displayName | Format-Table -AutoSize } else { Write-Host 'Tidak ditemukan produk antivirus yang terdaftar di Security Center.' } } catch { Write-Host 'Tidak bisa membaca data Security Center (coba jalankan sebagai Administrator).' };" ^
    "Write-Host '';" ^
    "Write-Host '--- Proses berat (memori lebih dari 500MB atau CPU lebih dari 50%%) ---';" ^
    "$heavy = @($rows | Where-Object { $_.'Mem(MB)' -gt 500 -or $_.'CPU(%%)' -gt 50 } | Sort-Object 'Mem(MB)' -Descending);" ^
    "if ($heavy.Count -eq 0) { Write-Host 'Tidak ada proses yang terdeteksi memakai resource sangat berat saat ini.'; exit 0 };" ^
    "$heavy | Format-Table Id, Name, 'CPU(%%)', 'Mem(MB)' -AutoSize;" ^
    "$protect = @('System','Idle','Registry','smss','csrss','wininit','winlogon','lsass','services','svchost','dwm','explorer','fontdrvhost','MsMpEng','Memory Compression','conhost','cmd','powershell');" ^
    "while ($true) {" ^
    "  $pidInput = Read-Host 'Masukkan PID yang ingin dimatikan (kosongkan untuk selesai)';" ^
    "  if ([string]::IsNullOrWhiteSpace($pidInput)) { break };" ^
    "  if ($pidInput -notmatch '^[0-9]+$') { Write-Host '[ERROR] PID tidak valid, harus berupa angka.'; continue };" ^
    "  $proc = Get-Process -Id $pidInput -ErrorAction SilentlyContinue;" ^
    "  if (-not $proc) { Write-Host ('[ERROR] PID ' + $pidInput + ' tidak ditemukan (mungkin sudah berhenti).'); continue };" ^
    "  if (($protect -contains $proc.ProcessName) -or ([int]$pidInput -eq $PID)) { Write-Host ('[ERROR] ' + $proc.ProcessName + ' adalah proses sistem penting atau Tachys sendiri, tidak boleh dimatikan.'); continue };" ^
    "  $confirm = Read-Host ('Yakin ingin mematikan proses ' + $proc.ProcessName + ' (PID ' + $pidInput + ')? [Y/N]');" ^
    "  if ($confirm -match '^[Yy]') { try { Stop-Process -Id $pidInput -Force -ErrorAction Stop; Write-Host ('[INFO] Proses ' + $proc.ProcessName + ' (PID ' + $pidInput + ') berhasil dihentikan.') } catch { Write-Host '[ERROR] Gagal menghentikan proses. Mungkin perlu izin Administrator.' } } else { Write-Host '[INFO] Dilewati, proses tidak dimatikan.' }" ^
    "}"

exit /b 0

:: ============================================================
:: 7. NONAKTIFKAN FAST STARTUP
:: ============================================================
:run_disable_control_panel_startup
echo [INFO] Mengecek status Fast Startup dan hak akses Administrator ...
echo.

fltmc >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Fitur Fast Startup diatur lewat registry HKLM, jadi butuh
    echo         hak akses Administrator untuk mengubahnya.
    echo.
    echo [INFO] Jalankan ulang Tachys dengan cara klik kanan file ini lalu
    echo        pilih "Run as administrator", kemudian pilih menu [7] lagi.
    exit /b 1
)

powershell -NoProfile -Command ^
    "$key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power';" ^
    "$current = (Get-ItemProperty -Path $key -Name HiberbootEnabled -ErrorAction SilentlyContinue).HiberbootEnabled;" ^
    "if ($null -eq $current) { Write-Host '[INFO] Fast Startup sepertinya sudah tidak aktif di sistem ini (key tidak ditemukan).'; exit 3 };" ^
    "if ($current -eq 0) { Write-Host '[INFO] Fast Startup memang sudah nonaktif sebelumnya.'; exit 3 };" ^
    "Write-Host ('[INFO] Fast Startup saat ini AKTIF (HiberbootEnabled=' + $current + '), sedang dinonaktifkan...');" ^
    "try { Set-ItemProperty -Path $key -Name HiberbootEnabled -Value 0 -Type DWord -ErrorAction Stop; Write-Host '[OK] Fast Startup berhasil dinonaktifkan (HiberbootEnabled=0).'; exit 0 } catch { Write-Host '[ERROR] Gagal mengubah registry. Pastikan dijalankan sebagai Administrator.'; Write-Host $_.Exception.Message; exit 1 }"

if errorlevel 3 exit /b 0
if errorlevel 1 exit /b 1

echo.
echo [INFO] Perubahan berlaku penuh setelah komputer RESTART (bukan cukup shutdown biasa,
echo        karena Fast Startup sendiri yang membuat shutdown biasa tidak benar-benar restart).
echo [INFO] Untuk verifikasi manual: Control Panel ^> Power Options ^>
echo        "Choose what the power buttons do" ^> opsi "Turn on fast startup" seharusnya
echo        sudah tidak tersedia/tercentang.
echo.
exit /b 0

:: ============================================================
:: 8. BUKA PENGATURAN REAL-TIME PROTECTION (MANUAL, menu [s])
:: ============================================================
:run_open_defender_settings
echo [INFO] Membuka halaman Virus ^& threat protection settings di Windows Security ...
echo.
echo [PENTING] Tachys TIDAK mematikan Real-Time Protection secara otomatis.
echo           Halaman pengaturan akan dibuka agar Anda bisa menonaktifkannya
echo           SENDIRI secara manual jika memang diperlukan, lalu jangan lupa
echo           mengaktifkannya kembali setelah selesai untuk menjaga keamanan
echo           perangkat.
echo.

start "" windowsdefender://threatsettings
if errorlevel 1 (
    echo [WARN] Gagal membuka via windowsdefender://, mencoba cara alternatif ...
    start "" ms-settings:windowsdefender
)

echo.
echo [INFO] Jika halaman tidak terbuka otomatis, buka manual lewat:
echo        Windows Security ^> Virus ^& threat protection ^> Manage settings
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

set "pilihan="
set /p pilihan="Masukkan pilihan [0-7, s]: "
echo.
if not defined pilihan goto :main
set "pilihan=%pilihan:"=%"

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
) else if "%pilihan%"=="7" (
    call :run_disable_control_panel_startup
) else if /i "%pilihan%"=="s" (
    call :run_open_defender_settings
) else if "%pilihan%"=="0" (
    echo [INFO] Menutup Tachys. Sampai jumpa^!
    call :cleanup
    exit 0
) else (
    echo [ERROR] Pilihan tidak dikenali: %pilihan%
)

echo.
echo Tekan sembarang tombol untuk kembali ke menu...
pause >nul
goto :main