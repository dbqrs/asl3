#!/bin/bash
set -euo pipefail

# Script: install.sh
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

# Define the paths to add
PATHS_TO_ADD="/usr/local/sbin:/usr/sbin:/sbin"

# Check if the paths are already in root's PATH
if [[ ":$PATH:" != *":/usr/local/sbin:/usr/sbin:/sbin:"* ]]; then
  # Append the paths to /root/.bashrc to persist across sessions
  echo "export PATH=\$PATH:$PATHS_TO_ADD" >> /root/.bashrc
  echo "Added $PATHS_TO_ADD to root's PATH in /root/.bashrc"
else
  echo "The paths $PATHS_TO_ADD are already in root's PATH."
fi

# Source the .bashrc to apply changes immediately in the current session
source /root/.bashrc

# Verify that ldconfig and start-stop-daemon are now accessible
echo "Checking for ldconfig and start-stop-daemon..."
if command -v ldconfig >/dev/null 2>&1; then
  echo "ldconfig found at: $(which ldconfig)"
else
  echo "Error: ldconfig not found. Ensure it is installed (e.g., part of libc-bin)."
fi

if command -v start-stop-daemon >/dev/null 2>&1; then
  echo "start-stop-daemon found at: $(which start-stop-daemon)"
else
  echo "Error: start-stop-daemon not found. Ensure it is installed (e.g., part of dpkg)."
fi

# Display the updated PATH
echo "Root's PATH is now: $PATH"

# Suggest next steps if tools are missing
if ! command -v ldconfig >/dev/null 2>&1 || ! command -v start-stop-daemon >/dev/null 2>&1; then
  echo "One or both tools are missing. Try reinstalling the required packages:"
  echo "Run: apt-get update && apt-get install --reinstall libc-bin dpkg"
fi

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
wget -c https://raw.githubusercontent.com/dbqrs/asl3/refs/heads/main/html.tar.gz
wget -c https://raw.githubusercontent.com/dbqrs/asl3/refs/heads/main/branding.tar.gz
wget -c https://raw.githubusercontent.com/dbqrs/asl3/refs/heads/main/bg-plain.jpg

# Extract HTML files to the web server root
tar -xvzf html.tar.gz -C /var/www/html

# Extract branding files to Cockpit's branding directory
tar -xvzf branding.tar.gz -C /usr/share/cockpit/branding/debian

# Overwrite default background
cp bg-plain.jpg /usr/share/cockpit/branding/default/bg-plain.jpg

# Inform user and delete the existing allmon3 password
echo "Deleting existing password for allmon3..."
allmon3-passwd --delete allmon3

# Wait for user input before setting the new password
read -p "Press [Enter] to set the new password for user 'allmon3'..."

# Launch password prompt for allmon3
allmon3-passwd allmon3

# Restart the allmon3 service
# systemctl restart allmon3

# Restart the apache service
systemctl restart apache2
