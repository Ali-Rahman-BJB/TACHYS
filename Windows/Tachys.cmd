@echo off
setlocal enabledelayedexpansion
title TACHYS - Portable Diagnostic Toolkit (Windows)
color 0A

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

goto :main

:: ============================================================
:: BANNER
:: ============================================================
:show_banner
cls
echo ================================================================================
echo.
echo  ░██████╗███╗░░░███╗██╗░░██╗  ██████╗░░██████╗░██████╗░██╗  ░░███╗░░
echo  ██╔════╝████╗░████║██║░██╔╝  ██╔══██╗██╔════╝░██╔══██╗██║  ░████║░░
echo  ╚█████╗░██╔████╔██║█████═╝░  ██████╔╝██║░░██╗░██████╔╝██║  ██╔██║░░
echo  ░╚═══██╗██║╚██╔╝██║██╔═██╗░  ██╔═══╝░██║░░╚██╗██╔══██╗██║  ╚═╝██║░░
echo  ██████╔╝██║░╚═╝░██║██║░╚██╗  ██║░░░░░╚██████╔╝██║░░██║██║  ███████╗
echo  ╚═════╝░╚═╝░░░░░╚═╝╚═╝░░╚═╝  ╚═╝░░░░░░╚═════╝░╚═╝░░╚═╝╚═╝  ╚══════╝
echo  ███╗░░░███╗░█████╗░██████╗░████████╗░█████╗░██████╗░██╗░░░██╗██████╗░░█████╗░
echo  ████╗░████║██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██║░░░██║██╔══██╗██╔══██╗
echo  ██╔████╔██║███████║██████╔╝░░░██║░░░███████║██████╔╝██║░░░██║██████╔╝███████║
echo  ██║╚██╔╝██║██╔══██║██╔══██╗░░░██║░░░██╔══██║██╔═══╝░██║░░░██║██╔══██╗██╔══██║
echo  ██║░╚═╝░██║██║░░██║██║░░██║░░░██║░░░██║░░██║██║░░░░░╚██████╔╝██║░░██║██║░░██║
echo  ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░░░░░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝
echo.
echo ================================================================================
echo         TACHYS - Portable Diagnostic Toolkit (Windows)
echo ================================================================================
echo.
echo Author      : Ali Rahman
echo Student ID  : 24020115 / 3085417291
echo Grade       : Grade 12 - Computer and Network Engineering
echo GitHub      : https://github.com/Ali-Rahman-BJB
echo.
goto :eof

:: ============================================================
:: MENU
:: ============================================================
:show_menu
echo ================================================================================
echo         Pilih tool yang ingin dijalankan:
echo.
echo   1. Keyboard Tester
echo   2. Cek Kesehatan Baterai
echo   3. Audio Output
echo   4. Touchpad
echo   0. Keluar
echo.
echo ================================================================================
echo.
goto :eof

:: ============================================================
:: 1. KEYBOARD TESTER
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
:: 2. BATTERY HEALTH
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
    start "" "%BATREPORT%"
) else (
    echo [WARN] Gagal membuat laporan powercfg. Perangkat mungkin tidak memiliki baterai.
)

exit /b 0

:: ============================================================
:: 3. AUDIO OUTPUT
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
:: 4. TOUCHPAD
:: ============================================================
:run_touchpad_settings
echo [INFO] Membuka pengaturan Touchpad ...
start "" ms-settings:devices-touchpad
if errorlevel 1 (
    echo [WARN] Gagal membuka pengaturan touchpad khusus, mencoba pengaturan mouse ...
    start "" control main.cpl
)
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

set /p pilihan="Masukkan pilihan [0-4]: "
echo.

if "%pilihan%"=="1" (
    call :run_keyboard_tester
) else if "%pilihan%"=="2" (
    call :run_battery_health
) else if "%pilihan%"=="3" (
    call :run_audio_output_test
) else if "%pilihan%"=="4" (
    call :run_touchpad_settings
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