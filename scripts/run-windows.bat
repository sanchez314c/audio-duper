@echo off
REM Run AudioDUPER from built application on Windows
REM Locates and launches the built executable

setlocal EnableDelayedExpansion

echo [INFO] Starting AudioDUPER from built application on Windows...

REM Look for built application in common locations
set "APP_PATHS=dist\win-unpacked\AudioDUPER.exe;dist\win-ia32-unpacked\AudioDUPER.exe;dist\AudioDUPER.exe"
set "APP_FOUND="

for %%i in (%APP_PATHS%) do (
    if exist "%%i" (
        set "APP_FOUND=%%i"
        echo [SUCCESS] Found AudioDUPER.exe at: %%i
        goto :found
    )
)

:found
if "%APP_FOUND%"=="" (
    echo [ERROR] AudioDUPER.exe not found. Please build the application first:
    echo [INFO] Run: npm run build
    echo [INFO] Or: compile-build-dist-comprehensive.sh --platform win
    pause
    exit /b 1
)

REM Check if the executable exists and is valid
if not exist "%APP_FOUND%" (
    echo [ERROR] Executable not found at %APP_FOUND%
    echo [INFO] Please rebuild the application
    pause
    exit /b 1
)

REM Launch the application
echo [INFO] Launching AudioDUPER...
start "" "%APP_FOUND%"

if !errorlevel! equ 0 (
    echo [SUCCESS] AudioDUPER launched successfully
    echo [INFO] Application running independently. You can close this window.
) else (
    echo [ERROR] Failed to launch AudioDUPER
    echo [INFO] Error code: !errorlevel!
    pause
    exit /b 1
)

timeout /t 3 /nobreak >nul