#!/bin/bash

# Check if running as root, if not, advise to run as root and exit
if (( $EUID != 0 )); then
    echo "This script must be run as root. Try running with 'sudo'."
    exit 1
fi

# Define the locations and names of the files and directories used
LOGDIR="/var/log/pacman-auto-update"
AUTOPAC="/usr/bin/autopac"
SERVICE_FILE="/etc/systemd/system/autopac.service"
TIMER_FILE="/etc/systemd/system/autopac.timer"

# Disable and remove the systemd service and timer
echo "Disabling and removing systemd service and timer..."
systemctl stop autopac.timer && systemctl disable autopac.timer
rm -f "$SERVICE_FILE" "$TIMER_FILE"
systemctl daemon-reload

# Remove the autopac script
echo "Removing the autopac script..."
rm -f "$AUTOPAC"

# Optional: Ask the user if they want to remove the log directory
read -p "Do you want to remove the log directory at $LOGDIR? (y/N): " response
if [[ $response =~ ^[Yy]$ ]]; then
    echo "Removing log directory..."
    rm -rf "$LOGDIR"
fi

echo "Uninstallation complete!"
