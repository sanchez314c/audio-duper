@echo off
REM AudioDUPER Quick Start Script (Windows)
REM Simple launcher for the application

echo 🎵 Starting AudioDUPER...

REM Check if node_modules exists
if not exist "node_modules" (
    echo Dependencies not found. Running installation...
    call install.bat
    if errorlevel 1 (
        echo Installation failed. Please check the error messages.
        pause
        exit /b 1
    )
)

REM Start the application
echo Launching AudioDUPER interface...
npm start