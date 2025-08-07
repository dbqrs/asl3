#!/bin/bash
set -euo pipefail

# Script: setup_asl3.sh
# Purpose: Installs and configures AllStarLink (ASL3) with Allmon3, Cockpit, and custom branding
# Usage: sudo ./setup_asl3.sh
# Log file
LOGFILE="/var/log/asl3_setup.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

# Function to run commands with error checking
run_command() {
    log_message "Running: $1"
    eval "$1"
    if [ $? -ne 0 ]; then
        log_message "Error: Failed to execute '$1'"
        exit 1
    fi
}


# Ensure the script is run as root
[ "$(id -u)" -ne 0 ] && echo "Run as root." && exit 1

# Change to temporary directory
cd /tmp

# Download the AllStarLink repository package and exit if it fails
wget https://repo.allstarlink.org/public/asl-apt-repos.deb12_all.deb || exit 1

# Install the downloaded AllStarLink repo package
dpkg -i asl-apt-repos.deb12_all.deb

# Update the package index
apt update

# Install ASL3, Allmon3, Cockpit tools, Python serial, and sudo
apt install -y asl3 asl3-update-nodelist asl3-menu allmon3 \
cockpit cockpit-networkmanager cockpit-packagekit cockpit-sosreport \
cockpit-storaged cockpit-system cockpit-ws python3-serial sudo

# Download the HTML and branding tarballs for customization
wget -c https://github.com/dbqrs/asl3/raw/refs/heads/main/html.tar.gz
wget -c https://github.com/dbqrs/asl3/raw/refs/heads/main/branding.tar.gz

# Extract HTML files to the web server root
tar -xvzf html.tar.gz -C /var/www/html

# Extract branding files to Cockpit's branding directory
tar -xvzf branding.tar.gz -C /usr/share/cockpit/branding/debian

# Inform user and delete the existing allmon3 password
echo "Deleting existing password for allmon3..."
allmon3-passwd --delete allmon3

# Wait for user input before setting the new password
read -p "Press [Enter] to set the new password for user 'allmon3'..."

# Launch password prompt for allmon3
allmon3-passwd allmon3

# Restart the allmon3 service
systemctl restart allmon3

# Restart the apache service
systemctl restart apache2
