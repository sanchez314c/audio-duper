@echo off
setlocal enabledelayedexpansion

REM AudioDUPER Windows Installation Script
REM Automatically installs dependencies and sets up the application

echo.
echo 🎵 AudioDUPER Installation Script (Windows)
echo ==========================================
echo.

REM Color definitions (limited in batch)
set "INFO=[INFO]"
set "SUCCESS=[SUCCESS]"
set "WARNING=[WARNING]"
set "ERROR=[ERROR]"

REM Check if Node.js is installed
echo %INFO% Checking Node.js installation...
node --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Node.js is not installed
    echo Please install Node.js 16+ from https://nodejs.org/
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

REM Get Node.js version
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
set NODE_VERSION=%NODE_VERSION:~1%
echo %SUCCESS% Node.js %NODE_VERSION% detected

REM Check Node.js version (simplified check)
for /f "tokens=1 delims=." %%a in ("%NODE_VERSION%") do set MAJOR_VERSION=%%a
if %MAJOR_VERSION% LSS 16 (
    echo %ERROR% Node.js version %NODE_VERSION% is too old
    echo Please upgrade to Node.js 16 or higher
    pause
    exit /b 1
)

REM Check if npm is available
echo %INFO% Checking npm installation...
npm --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% npm is not installed
    echo Please install npm (usually comes with Node.js)
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
echo %SUCCESS% npm %NPM_VERSION% detected

REM Check if package.json exists
if not exist "package.json" (
    echo %ERROR% package.json not found. Are you in the AudioDUPER directory?
    pause
    exit /b 1
)

REM Install chromaprint dependencies
echo %INFO% Installing system dependencies...
echo %WARNING% You may need to manually install chromaprint:
echo   1. Download chromaprint from https://acoustid.org/chromaprint
echo   2. Extract to a folder in your PATH
echo   3. Or use Chocolatey: choco install chromaprint
echo.

REM Clean npm cache
echo %INFO% Cleaning npm cache...
npm cache clean --force >nul 2>&1

REM Install Node.js dependencies
echo %INFO% Installing Node.js dependencies...
npm install --no-audit --no-fund
if errorlevel 1 (
    echo %ERROR% Failed to install dependencies
    echo Please check the error messages above
    pause
    exit /b 1
)

echo %SUCCESS% Node.js dependencies installed

REM Verify installation
echo %INFO% Verifying installation...
if not exist "node_modules" (
    echo %ERROR% node_modules directory not found
    pause
    exit /b 1
)

REM Check for main dependencies
if not exist "node_modules\electron" (
    echo %ERROR% Electron not found in node_modules
    pause
    exit /b 1
)

if not exist "node_modules\fpcalc" (
    echo %ERROR% fpcalc not found in node_modules
    pause
    exit /b 1
)

if not exist "node_modules\music-metadata" (
    echo %ERROR% music-metadata not found in node_modules
    pause
    exit /b 1
)

echo %SUCCESS% Installation verified successfully

REM Create desktop shortcut
echo %INFO% Creating desktop shortcut...
set "CURRENT_DIR=%CD%"
set "DESKTOP=%USERPROFILE%\Desktop"
set "SHORTCUT_PATH=%DESKTOP%\AudioDUPER.bat"

echo @echo off > "%SHORTCUT_PATH%"
echo cd /d "%CURRENT_DIR%" >> "%SHORTCUT_PATH%"
echo npm start >> "%SHORTCUT_PATH%"
echo pause >> "%SHORTCUT_PATH%"

echo %SUCCESS% Desktop shortcut created: %SHORTCUT_PATH%

REM Installation complete
echo.
echo %SUCCESS% ✅ AudioDUPER installation completed successfully!
echo.
echo %INFO% To start the application, run:
echo   npm start
echo.
echo %INFO% Or double-click the desktop shortcut: AudioDUPER.bat
echo.
echo %INFO% For development mode with debugging:
echo   npm run dev
echo.
echo %INFO% To build for distribution:
echo   npm run build
echo.
echo %INFO% IMPORTANT: Make sure chromaprint is installed for audio fingerprinting!
echo %INFO% Download from: https://acoustid.org/chromaprint
echo.
echo %INFO% Enjoy organizing your music collection! 🎵
echo.
pause