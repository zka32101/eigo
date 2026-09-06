#!/bin/bash

# Android Emulator Setup Script
# This script configures the Android emulator for testing

set -e

echo "Setting up Android emulator for testing..."

# Verify emulator is running
if ! adb devices | grep -q emulator; then
    echo "Error: Android emulator is not running"
    exit 1
fi

# Get emulator device ID
DEVICE_ID=$(adb devices | grep emulator | head -1 | awk '{print $1}')
echo "Using device: $DEVICE_ID"

# Enable mock location provider (if needed)
adb -s "$DEVICE_ID" shell settings put secure mock_location 1

# Set device language to English (optional)
adb -s "$DEVICE_ID" shell setprop persist.sys.locale en-US

# Install required packages
echo "Installing required packages..."
adb -s "$DEVICE_ID" install-multiple \
    $(find . -name "*.apk" -type f | head -5) 2>/dev/null || true

# Disable animations for faster testing
adb -s "$DEVICE_ID" shell settings put global window_animation_scale 0
adb -s "$DEVICE_ID" shell settings put global transition_animation_scale 0
adb -s "$DEVICE_ID" shell settings put global animator_duration_scale 0

# Grant necessary permissions
echo "Granting permissions..."
for permission in android.permission.INTERNET \
                  android.permission.ACCESS_FINE_LOCATION \
                  android.permission.ACCESS_COARSE_LOCATION \
                  android.permission.READ_EXTERNAL_STORAGE \
                  android.permission.WRITE_EXTERNAL_STORAGE; do
    adb -s "$DEVICE_ID" shell pm grant "$(adb -s "$DEVICE_ID" shell pm list packages | cut -d: -f2)" "$permission" 2>/dev/null || true
done

# Wait for system to be ready
echo "Waiting for system to be ready..."
sleep 5

# Verify setup
adb -s "$DEVICE_ID" shell getprop ro.build.version.release
echo "Android emulator setup completed successfully!"
