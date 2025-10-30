#!/bin/bash

# AudioDUPER Quick Start Script
# Simple launcher for the application

set -e

echo "🎵 Starting AudioDUPER..."

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Dependencies not found. Running installation..."
    ./install.sh
fi

# Start the application
echo "Launching AudioDUPER interface..."
npm start