Here’s your installer guide converted to **Markdown** so it’s readable, styled with headings, and keeps the code formatting intact.

````markdown
# AllStarLink 3 Debian PC Installer

<p align="center">
  <img src="logo200.png" alt="unofficial logo" title="ASL3/Debian" width="131" height="125" />
</p>

---

## Installation

> **Note:** Make sure you are logged in as the **root** user.

If you did not set a static IP when installing Debian, it is highly recommended you do it now. See the section below for static IP configuration instructions.

Before starting, ensure `curl` is installed:

```bash
apt install curl
````

Before running the installation command, it’s **highly recommended** you view the code first:
[https://asl.dbqrs.com](https://asl.dbqrs.com)

To install:

```bash
curl -sSL https://asl.dbqrs.com
```

---

## Configure a Static IP Address in Debian 12 Linux

This guide will walk you through changing the network configuration from DHCP to a static IP.

### 1. Open the Network Configuration File

```bash
nano /etc/network/interfaces
```

---

### 2. Find the Current Configuration

Look for:

```bash
iface eth0 inet dhcp
```

---

### 3. Change DHCP to Static

Replace with the following (adjust values for your network):

```plaintext
auto eth0
iface eth0 inet static
    address 192.168.1.55
    network 192.168.1.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8
```

---

### 4. Save and Exit `nano`

* Press `CTRL+X` to begin saving.
* Press `Y` to confirm changes.
* Press `Enter` to write the file and exit.

---

### 5. Restart the Networking Service

```bash
systemctl restart networking
```

---

### 6. Verify the IP Address

```bash
ip a
```

Look for your configured IP (e.g., `192.168.1.55`).

---

**Tip:** Your network interface name might not be `eth0`. It could be `enp0s3` or `ens33`. Use the correct interface name for your system.

```
```
