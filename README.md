<p align="center">
  <img
    src="logo200.png"
    alt="Unofficial ASL3/Debian Logo"
    title="ASL3 / Debian"
    width="131"
    height="125"
  />
</p>

<h1 align="center">AllStarLink 3 Debian PC Installer</h1>

> \[!IMPORTANT]
> If you didn’t set a static IP during install of Debian, I highly recommend you do that **before** running the installer.
> See [this guide](https://github.com/dbqrs/asl3/wiki/Configure-a-Static-IP-Address-in-Debian-12-Linux) for an easy how to.

> \[!WARNING]
> Review the installer script before running it: [https://asl.dbqrs.com](https://asl.dbqrs.com)

> \[!NOTE]
> This script installs AllStarlink 3, Allmon 3, Cockpit, Sudo, and required dependencies. It automates the creation of a self-signed SSL certificate to enable HTTPS, valid for 10 years. It adds necessary system paths and creates a logfile located at /var/log/asl3_setup.log

## Download Links
[debian-12.11.0-amd64-netinst.iso](https://cdimage.debian.org/cdimage/archive/12.11.0/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso) - Debain 13 was released on 2025/08/09, but is not yet compatible with the current AllStarLink packages. Debian 12 users can expect security updates and support until 2028/06/30.

[Rufus bootable USB creator](https://rufus.ie/en/)

---

## Install Debian 12 for AllStarLink
[![Watch the video](https://img.youtube.com/vi/OND_Ea3YM8o/hqdefault.jpg)](https://www.youtube.com/watch?v=OND_Ea3YM8o)

This video will walk you through the installation of Debian. 

---

## Install AllStarLink 3

> \[!IMPORTANT]
> You **must** be logged in as the **root** user. At the command line type: **su -**  then enter the root passowrd you created when you installed Debian.

### 1) Install `curl`

```bash
apt update
apt install -y curl
```

### 2) Run the installer

```bash
curl -sSL https://asl.dbqrs.com | bash
```

---

## Setting up AllStarLink 3 on Shari PI

For a great tutorial on setting up AllStarLink 3 with your Shari PI, watch this video from [GraymanPOTA](https://graymanpota.com/):

[![Setting up AllStarLink 3 on Shari PI](https://img.youtube.com/vi/NPgTRa5bpnY/0.jpg)](https://www.youtube.com/watch?v=NPgTRa5bpnY)

---

## Configure a Static IP Address in Debian 12 Linux

This guide walks you through changing the network configuration from DHCP to a static IP.

### 1) Open the network configuration file

```bash
nano /etc/network/interfaces
```

### 2) Find the current configuration

```ini
iface eth0 inet dhcp
```

### 3) Change DHCP to static

Replace with the following (adjust for your network):

```ini
auto eth0
iface eth0 inet static
    address 192.168.1.55
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8
```

> \[!NOTE]
> Your interface name might not be `eth0`. It could be something like `enp0s3` or `ens33`.
> Replace `eth0` with your actual interface name.

### 4) Save and exit nano

* Press `CTRL+X` to begin saving.
* Press `Y` to confirm changes.
* Press `Enter` to write the file and exit.

### 5) Restart the networking service

```bash
systemctl restart networking
```

### 6) Verify the IP address

```bash
ip addr
```

Look for your configured IP (e.g., `192.168.1.55`).
