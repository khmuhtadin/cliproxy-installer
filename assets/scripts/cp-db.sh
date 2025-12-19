#!/bin/bash

# CLIProxy Dashboard Launcher
# Checks if server is running, starts if needed, then opens dashboard

DASHBOARD_URL="http://localhost:8317/dashboard.html"
PORT=8317

echo "🔮 CLIProxy Dashboard Launcher"
echo ""

# Check if server is already running
if lsof -i :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    PID=$(lsof -i :$PORT -sTCP:LISTEN -t)
    echo "✅ Server already running (PID: $PID)"
else
    echo "⚠️  Server not running, starting now..."
    
    # Determine start command
    CP_START_CMD=""
    if command -v cp-start >/dev/null 2>&1; then
        CP_START_CMD="cp-start"
    elif [ -x "$HOME/.cli-proxy-api/scripts/start.sh" ]; then
        CP_START_CMD="$HOME/.cli-proxy-api/scripts/start.sh"
    fi

    if [ -n "$CP_START_CMD" ]; then
        "$CP_START_CMD" &
        echo "⏳ Waiting for server to start..."
        
        # Wait up to 10 seconds for server to start
        for i in {1..10}; do
            sleep 1
            if lsof -i :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
                PID=$(lsof -i :$PORT -sTCP:LISTEN -t)
                echo "✅ Server started successfully (PID: $PID)"
                break
            fi
            if [ $i -eq 10 ]; then
                echo "❌ Server failed to start. Please check logs."
                exit 1
            fi
        done
    else
        echo "❌ cp-start command not found. Please install CLIProxy first."
        exit 1
    fi
fi

echo ""
echo "🌐 Opening dashboard: $DASHBOARD_URL"
echo ""

# Open dashboard in default browser
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "$DASHBOARD_URL"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$DASHBOARD_URL"
    elif command -v gnome-open >/dev/null 2>&1; then
        gnome-open "$DASHBOARD_URL"
    else
        echo "Please open manually: $DASHBOARD_URL"
    fi
else
    echo "Please open manually: $DASHBOARD_URL"
fi

echo "✨ Dashboard opened successfully!"
