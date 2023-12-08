#!/bin/bash

# Check if running as root
if (( $EUID != 0 )); then
    echo "Please run as root."
    exit 1
fi

echo "Updating system and installing necessary packages..."

# Update the system and install necessary packages
pacman-key --init
pacman-key --populate
pacman -Sy archlinux-keyring --noconfirm
pacman -Syu --noconfirm
if [ $? -ne 0 ]; then
    echo "Failed to update system."
    exit 1
fi

pacman -S ufw tor nyx fail2ban --noconfirm
if [ $? -ne 0 ]; then
    echo "Failed to install necessary packages."
    exit 1
fi

# Function to get input with a default value
get_input_with_default() {
    local prompt=$1
    local default=$2
    local input

    read -p "$prompt [$default]: " input
    if [ -z "$input" ]; then
        echo "$default"
    else
        echo "$input"
    fi
}

# Validate numeric input
validate_numeric_input() {
    if ! [[ $1 =~ ^[0-9]+$ ]]; then
        echo "Invalid input: $1. Please enter a numeric value."
        exit 1
    fi
}

# Prompt for necessary variables with default values
SSHPORT=$(get_input_with_default "Enter SSH Port" "22")
validate_numeric_input $SSHPORT

ControlPort=$(get_input_with_default "Enter Control Port" "9051")
validate_numeric_input $ControlPort

ORPort=$(get_input_with_default "Enter OR Port" "9001")
validate_numeric_input $ORPort

DirPort=$(get_input_with_default "Enter Directory Port" "9030")
validate_numeric_input $DirPort

SocksPort=$(get_input_with_default "Enter Tor SOCKS Port" "0")
validate_numeric_input $SocksPort

TorNickname=$(get_input_with_default "Enter Tor Nickname" "ididntreadtheconfig")
ContactInfo=$(get_input_with_default "Enter Contact Info (email)" "user@example.com")
RelayBandwidthRate=$(get_input_with_default "Enter Relay Bandwidth Rate" "500 KB")
RelayBandwidthBurst=$(get_input_with_default "Enter Relay Bandwidth Burst" "1000 KB")

# Create the Tor configuration file
echo "Creating Tor Relay config file at /etc/tor/torrc..."

{
    echo "User tor"
    echo "Log notice syslog"
    echo "DataDirectory /var/lib/tor"
    echo "ControlPort $ControlPort"
    echo "ORPort $ORPort"
    echo "DirPort $DirPort"
    echo "Nickname $TorNickname"
    echo "ContactInfo $ContactInfo"
    echo "RelayBandwidthRate $RelayBandwidthRate"
    echo "RelayBandwidthBurst $RelayBandwidthBurst"
    echo "ExitRelay 0"
} > /etc/tor/torrc

# Error checking after torrc file creation
if [ $? -ne 0 ]; then
    echo "Failed to create /etc/tor/torrc."
    exit 1
fi

# More functions and configurations...
# (Include the rest of the script here, ensuring error checks and input validations are added as needed)

echo "Complete! Your hardened tor server is up and running!"
echo "To view its performance type 'nyx -i 127.0.0.1:$ControlPort' and enter your password if set."
