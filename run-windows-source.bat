@echo off
REM Run AudioDUPER from source on Windows
REM For development and testing purposes

setlocal EnableDelayedExpansion

echo [INFO] Starting AudioDUPER from source on Windows...

REM Check if we're in the right directory
if not exist "package.json" (
    echo [ERROR] No package.json found. Please run this script from the AudioDUPER root directory.
    pause
    exit /b 1
)

REM Check for Node.js
where node >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] Node.js is not installed. Please install Node.js first.
    echo [INFO] Download from: https://nodejs.org/
    pause
    exit /b 1
)

REM Check for npm
where npm >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] npm is not installed. Please install npm first.
    pause
    exit /b 1
)

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo [INFO] Installing dependencies...
    call npm install
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to install dependencies
        pause
        exit /b 1
    )
)

REM Check for system dependencies
echo [INFO] Checking system dependencies...

REM Check for chromaprint (fpcalc.exe should be in PATH or node_modules)
where fpcalc >nul 2>&1
if !errorlevel! neq 0 (
    echo [WARNING] chromaprint (fpcalc.exe) not found in PATH.
    echo [INFO] Checking node_modules for bundled fpcalc...
    if not exist "node_modules\fpcalc\bin\fpcalc.exe" (
        echo [WARNING] fpcalc not found. Audio fingerprinting may not work properly.
        echo [INFO] Download chromaprint from: https://acoustid.org/chromaprint
        echo [INFO] Or ensure the 'fpcalc' npm package is properly installed.
    ) else (
        echo [SUCCESS] Found bundled fpcalc in node_modules
    )
) else (
    echo [SUCCESS] Found system fpcalc in PATH
)

echo [SUCCESS] Dependencies verified

REM Start the application in development mode
echo [INFO] Launching AudioDUPER in development mode...
echo [INFO] Press Ctrl+C to stop the application
echo.

REM Run with development environment
set NODE_ENV=development
call npm run dev

echo [SUCCESS] AudioDUPER closed successfully
pause