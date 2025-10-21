#!/bin/bash

echo "🚀 Starting 42Sports Full Stack..."
echo ""

# Start backend server
echo "📦 Starting Backend Server..."
cd /home/reda/Desktop/hackathon/backend
npm start &
BACKEND_PID=$!

# Wait for backend to start
sleep 2

# Serve Flutter web app
echo ""
echo "🌐 Starting Flutter Web App..."
cd /home/reda/Desktop/hackathon/42Sports/build/web

# Use Python's built-in HTTP server
python3 -m http.server 8080 &
WEB_PID=$!

sleep 2

# Get local IP
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "✅ 42Sports is now running!"
echo "================================="
echo "📱 Backend API: http://$LOCAL_IP:3000"
echo "🌐 Web App:     http://$LOCAL_IP:8080"
echo "================================="
echo ""
echo "📝 On your phone (connected to same WiFi):"
echo "   Open browser and go to: http://$LOCAL_IP:8080"
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

# Wait for Ctrl+C
trap "kill $BACKEND_PID $WEB_PID; exit" INT
wait
