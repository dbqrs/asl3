#!/bin/bash
set -euo pipefail

# Script: install.sh
# Purpose: Installs and configures AllStarLink (ASL3) with Allmon3, Cockpit, and custom branding
# Usage: sudo ./install.sh
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

#Adduser allmon3
/sbin/adduser allmon3

# Install ASL3, Allmon3, Cockpit tools, Python serial, and sudo
apt install -y asl3 asl3-update-nodelist asl3-menu allmon3 \
cockpit cockpit-networkmanager cockpit-packagekit cockpit-sosreport \
cockpit-storaged cockpit-system cockpit-ws python3-serial sudo asl3-pi-appliance

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

#########
# Inform user and delete the existing allmon3 password
# echo "Deleting existing password for allmon3..."
# allmon3-passwd --delete allmon3

# Wait for user input before setting the new password
# read -p "Press [Enter] to set the new password for user 'allmon3'..."

# Launch password prompt for allmon3
# allmon3-passwd allmon3
#########

# Restart the allmon3 service
# systemctl restart allmon3

# Restart the apache service
systemctl restart apache2

# SSL Certs
# Generic Debian 12 HTTPS bootstrap (self-driving):
# - Auto-detect primary IPv4 and hostname; builds SANs automatically if -d not given
# - Heuristically detects STATIC vs DHCP (NetworkManager / systemd-networkd / ifupdown)
# - Creates a local CA (10y) and host cert (10y)
# - Installs CA into THIS machine's trust store
# - Replaces Apache defaults with a host-wide HTTPS vhost + HTTP->HTTPS redirect
# - Publishes CA at /var/www/html/host-local-ca.crt for client download

DOMAINS=""                             # -d "ip1,host1" overrides auto-detect
SITE_NAME="host-ssl"
WEBROOT="/var/www/html"
PUBLISH_CA=true
DAYS_CA=3650
DAYS_SRV=3650
COUNTRY="US"; STATE="State"; LOCALITY="City"; ORG="Local HTTPS"; OU="IT"
CA_NAME="Host Local CA"
KEY_BITS=2048

usage() {
  cat <<EOF
Usage: $0 [-d ip1,host1] [-n]
  -d  Comma-separated SANs (IP and/or DNS). First entry becomes CN.
      If omitted, the script auto-detects primary IPv4 and hostname.
  -n  Do NOT publish CA file to ${WEBROOT}
  -h  Help
EOF
}

while getopts ":d:nh" opt; do
  case "$opt" in
    d) DOMAINS="$OPTARG" ;;
    n) PUBLISH_CA=false ;;
    h) usage; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG"; usage; exit 1 ;;
  esac
done

log() { echo -e "==> $*"; }
warn() { echo -e "!!  $*" >&2; }

is_ip() {
  local ip="$1"
  [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
  for o in $o1 $o2 $o3 $o4; do
    (( o >= 0 && o <= 255 )) || return 1
  done
  return 0
}

detect_primary_ip_iface() {
  # Uses the route to 1.1.1.1 to determine egress interface & IP
  if ! command -v ip >/dev/null 2>&1; then
    apt-get update -y && apt-get install -y iproute2 >/dev/null
  fi
  local out
  if ! out="$(ip -o route get 1.1.1.1 2>/dev/null)"; then
    return 1
  fi
  # Example: "1.1.1.1 via 192.168.1.1 dev eth0 src 192.168.1.50 uid 0"
  PRIMARY_IP="$(awk '/src/ {for(i=1;i<=NF;i++) if ($i=="src") {print $(i+1); exit}}' <<<"$out")"
  PRIMARY_IF="$(awk '/dev/ {for(i=1;i<=NF;i++) if ($i=="dev") {print $(i+1); exit}}' <<<"$out")"
  [[ -n "${PRIMARY_IP:-}" && -n "${PRIMARY_IF:-}" ]]
}

detect_static_vs_dhcp() {
  STATIC_STATE="unknown"

  # Prefer NetworkManager if present
  if command -v nmcli >/dev/null 2>&1 && systemctl is-active --quiet NetworkManager 2>/dev/null; then
    # Find active connection mapped to PRIMARY_IF
    local con
    con="$(nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | awk -F: -v dev="$PRIMARY_IF" '$2==dev {print $1; exit}')"
    if [[ -n "$con" ]]; then
      local method
      method="$(nmcli -g ipv4.method connection show "$con" 2>/dev/null || true)"
      # Values: auto=DHCP, manual=static, disabled/shared/… possible
      if [[ "$method" == "manual" ]]; then STATIC_STATE="static"
      elif [[ "$method" == "auto" ]]; then STATIC_STATE="dhcp"
      fi
    fi
  fi

  # systemd-networkd heuristic
  if [[ "$STATIC_STATE" == "unknown" ]] && systemctl is-active --quiet systemd-networkd 2>/dev/null; then
    if command -v networkctl >/dev/null 2>&1; then
      local dhcp_line
      dhcp_line="$(networkctl status "$PRIMARY_IF" 2>/dev/null | awk -F: '/^\s*DHCP/ {gsub(/^[ \t]+/,"",$2); print tolower($2); exit}')"
      # Looks like "yes (ipv4)" or "no"
      if [[ "$dhcp_line" == no* ]]; then STATIC_STATE="static"
      elif [[ "$dhcp_line" == yes* ]]; then STATIC_STATE="dhcp"
      fi
    fi
  fi

  # ifupdown (/etc/network/interfaces) heuristic
  if [[ "$STATIC_STATE" == "unknown" && -f /etc/network/interfaces ]]; then
    local st
    st="$(awk -v dev="$PRIMARY_IF" '
      $1=="iface" && $2==dev && $3=="inet" { print $4 }
    ' /etc/network/interfaces 2>/dev/null || true)"
    if [[ "$st" == "dhcp" ]]; then STATIC_STATE="dhcp"
    elif [[ "$st" == "static" ]]; then STATIC_STATE="static"
    fi
  fi

  echo "$STATIC_STATE"
}

auto_domains() {
  local hn
  hn="$(hostname -f 2>/dev/null || hostname 2>/dev/null || true)"
  local entries=()

  if [[ -n "${PRIMARY_IP:-}" ]]; then entries+=("$PRIMARY_IP"); fi
  if [[ -n "$hn" && "$hn" != "(none)" ]]; then entries+=("$hn"); fi

  # Deduplicate while preserving order
  local seen=""
  local out=()
  for e in "${entries[@]}"; do
    if [[ -z "$seen" || ! " $seen " =~ " $e " ]]; then
      out+=("$e"); seen="$seen $e"
    fi
  done
  (IFS=','; echo "${out[*]}")
}

# --- MAIN ---

log "Installing packages…"
apt-get update -y
apt-get install -y apache2 openssl ca-certificates >/dev/null

if [[ -z "$DOMAINS" ]]; then
  if detect_primary_ip_iface; then
    STATE="$(detect_static_vs_dhcp)"
    DOMAINS="$(auto_domains)"
    log "Auto-detected interface: $PRIMARY_IF"
    log "Auto-detected primary IPv4: $PRIMARY_IP (assessed: ${STATE})"
    log "Using SANs: $DOMAINS"
    if [[ "$STATE" == "dhcp" ]]; then
      warn "Primary IP appears to be via DHCP. The cert will still work, but may break if the IP changes."
    fi
  else
    warn "Could not auto-detect primary IP/interface. Falling back to hostname only."
    hn="$(hostname -f 2>/dev/null || hostname 2>/dev/null || echo localhost)"
    DOMAINS="$hn"
  fi
fi

# Paths
SSL_DIR="/etc/ssl"
CA_DIR="${SSL_DIR}/localca"
CA_KEY="${CA_DIR}/rootCA.key"
CA_CRT="${CA_DIR}/rootCA.crt"
SRV_KEY="${SSL_DIR}/private/${SITE_NAME}.key"
SRV_CSR="${SSL_DIR}/csr/${SITE_NAME}.csr"
SRV_CRT="${SSL_DIR}/certs/${SITE_NAME}.crt"
APACHE_SITE="/etc/apache2/sites-available/${SITE_NAME}.conf"
ACCESS_LOG="\${APACHE_LOG_DIR}/${SITE_NAME}-access.log"
ERROR_LOG="\${APACHE_LOG_DIR}/${SITE_NAME}-error.log"

mkdir -p "${CA_DIR}" "${SSL_DIR}/private" "${SSL_DIR}/certs" "${SSL_DIR}/csr" "${WEBROOT}"

# Build SANs
IFS=',' read -r -a SAN_ARR <<< "${DOMAINS}"
if [[ ${#SAN_ARR[@]} -eq 0 || -z "${SAN_ARR[0]}" ]]; then
  echo "Error: no SANs available after detection. Use -d to specify."; exit 1
fi
CN="$(echo "${SAN_ARR[0]}" | xargs)"

SAN_ENTRIES=()
for entry in "${SAN_ARR[@]}"; do
  e="$(echo "$entry" | xargs)"; [[ -z "$e" ]] && continue
  if is_ip "$e"; then SAN_ENTRIES+=("IP:${e}"); else SAN_ENTRIES+=("DNS:${e}"); fi
done
SAN_BLOCK="$(IFS=, ; echo "${SAN_ENTRIES[*]}")"

log "Creating local CA (10y) if missing…"
if [[ ! -f "$CA_KEY" || ! -f "$CA_CRT" ]]; then
  openssl genrsa -out "${CA_KEY}" ${KEY_BITS}
  openssl req -x509 -new -nodes -key "${CA_KEY}" -sha256 -days "${DAYS_CA}" \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORG}/OU=${OU}/CN=${CA_NAME}" \
    -out "${CA_CRT}"
else
  log "Existing CA found: ${CA_CRT}"
fi

log "Issuing server cert (CN=${CN}, 10y)…"
TMP_CNF="$(mktemp)"
cat > "${TMP_CNF}" <<EOF
[ req ]
default_bits       = ${KEY_BITS}
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C  = ${COUNTRY}
ST = ${STATE}
L  = ${LOCALITY}
O  = ${ORG}
OU = ${OU}
CN = ${CN}

[ req_ext ]
subjectAltName = ${SAN_BLOCK}

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = ${SAN_BLOCK}
EOF

openssl genrsa -out "${SRV_KEY}" ${KEY_BITS}
chmod 600 "${SRV_KEY}"
openssl req -new -key "${SRV_KEY}" -out "${SRV_CSR}" -config "${TMP_CNF}"
openssl x509 -req -in "${SRV_CSR}" -CA "${CA_CRT}" -CAkey "${CA_KEY}" -CAcreateserial \
  -out "${SRV_CRT}" -days "${DAYS_SRV}" -sha256 -extfile "${TMP_CNF}" -extensions v3_ext
rm -f "${TMP_CNF}" "${CA_DIR}/rootCA.srl" 2>/dev/null || true

log "Trusting CA on THIS machine…"
install -m 0644 "${CA_CRT}" /usr/local/share/ca-certificates/host-local-ca.crt
update-ca-certificates >/dev/null

log "Enabling Apache modules…"
a2enmod ssl headers rewrite >/dev/null

log "Replacing Apache defaults with host-wide HTTPS site…"
a2dissite 000-default.conf >/dev/null 2>&1 || true
a2dissite default-ssl.conf >/dev/null 2>&1 || true

cat > "${APACHE_SITE}" <<EOF
# Host-wide HTTPS site (replaces Apache defaults)
<VirtualHost *:80>
    ServerName ${CN}
    DocumentRoot ${WEBROOT}
    RewriteEngine On
    RewriteCond %{HTTPS} !=on
    RewriteRule ^/(.*)$ https://%{HTTP_HOST}/\$1 [R=301,L]
    ErrorLog ${ERROR_LOG}
    CustomLog ${ACCESS_LOG} combined
</VirtualHost>

<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName ${CN}
    DocumentRoot ${WEBROOT}

    SSLEngine on
    SSLCertificateFile ${SRV_CRT}
    SSLCertificateKeyFile ${SRV_KEY}
    SSLCACertificateFile ${CA_CRT}

    <Directory ${WEBROOT}>
        Require all granted
        AllowOverride All
        Options FollowSymLinks
        DirectoryIndex index.html index.php
    </Directory>

    Header always set X-Frame-Options SAMEORIGIN
    Header always set X-Content-Type-Options nosniff
    Header always set Referrer-Policy "strict-origin-when-cross-origin"

    ErrorLog ${ERROR_LOG}
    CustomLog ${ACCESS_LOG} combined
</VirtualHost>
</IfModule>
EOF

a2ensite "${SITE_NAME}.conf" >/dev/null
apache2ctl configtest
systemctl reload apache2

if ${PUBLISH_CA}; then
  log "Publishing CA for client download at ${WEBROOT}/host-local-ca.crt"
  install -m 0644 "${CA_CRT}" "${WEBROOT}/host-local-ca.crt"
fi

# --- Cockpit TLS hookup (port 9090) ---
log "Configuring Cockpit to use the same TLS cert…"
COCKPIT_DIR="/etc/cockpit/ws-certs.d"
COCKPIT_CERT="${COCKPIT_DIR}/99-host.cert"
COCKPIT_KEY="${COCKPIT_DIR}/99-host.key"

mkdir -p "${COCKPIT_DIR}"
# Cockpit accepts either a single .cert containing cert+key, or a .cert/.key pair.
# We'll supply a matching pair so it stays clean.
install -m 0644 "${SRV_CRT}" "${COCKPIT_CERT}"
install -m 0600 "${SRV_KEY}" "${COCKPIT_KEY}"

# Make sure our files sort last so Cockpit prefers them.
# Restart the socket (service is socket-activated).
systemctl restart cockpit.socket 2>/dev/null || true
systemctl restart cockpit 2>/dev/null || true

log "Cockpit set to use ${COCKPIT_CERT} and ${COCKPIT_KEY} (port 9090)."

echo
echo "============================================================"
echo " Done."
echo "  - HTTPS URL(s):"
IFS=',' read -r -a _tmp <<< "$DOMAINS"
for n in "${_tmp[@]}"; do echo "    https://$(echo "$n" | xargs)/"; done
${PUBLISH_CA} && echo "  - Install this CA on client devices: http://${CN}/host-local-ca.crt"
echo "  - Cert SANs: ${SAN_BLOCK}"
echo "  - IP assignment detected: ${STATE:-unknown}"
echo "============================================================"
