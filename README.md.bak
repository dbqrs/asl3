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
> You **must** be logged in as the **root** user.

> \[!IMPORTANT]
> If you didn’t set a static IP during install of Debian, I highly recommend you do that **before** running the installer.
> See [this guide](#configure-a-static-ip-address-in-debian-12-linux) for an easy how to.

> \[!TIP]
> Review the installer script before running it: [https://asl.dbqrs.com](https://asl.dbqrs.com)

---

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
