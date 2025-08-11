<h1 align="center">
  AllStarLink 3 Debian PC Installer  
</h1>

<p align="center">
  <img
    src="logo200.png"
    alt="unofficial logo"
    title="ASL3/Debian"
    width="131"
    height="125"
  />
</p>

> [!IMPORTANT]
> Make sure you’re logged in as the **root** user.

>[!IMPORTANT]
>If you didn’t set a static IP during Debian install, it’s recommended to do that now. See this [installation guide](#configure-a-static-ip-address-in-debian-12-linux).

> [!TIP]
> Review the installer script before running it: <https://asl.dbqrs.com>

---

#### 1) Install `curl`

<button class=" -btn"> </button>
<pre><code class="language-bash">apt install curl</code></pre>

---

#### 2) Run the installer

<button class=" -btn"> </button>
<pre><code class="language-bash">curl -sSL https://asl.dbqrs.com</code></pre>

---
---

## Setting up AllStar Link 3 on Shari PI
For a detailed tutorial on setting up AllStar Link 3 on your Shari PI, watch this video from GraymanPOTA:

[![Setting up AllStar Link 3 on Shari PIHat](https://img.youtube.com/vi/NPgTRa5bpnY/0.jpg)](https://www.youtube.com/watch?v=NPgTRa5bpnY)

---
---

### Configure a Static IP Address in Debian 12 Linux

This guide will walk you through changing the network configuration from DHCP to a static IP.

---

#### **1) Open the network configuration file**

```bash
nano /etc/network/interfaces
```

---

#### **2) Find the current configuration**

```bash
iface eth0 inet dhcp
```

---

#### **3) Change DHCP to Static**

Replace with the following (adjust for your network):

```plaintext
auto eth0
iface eth0 inet static
    address 192.168.1.55
    network 192.168.1.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8
```
> \[!NOTE]
> Your interface name might not be `eth0`. It could be something like `enp0s3` or `ens33`.
> Replace `eth0` with your actual interface name.
---

#### **4) Save and exit nano**

* Press `CTRL+X` to begin saving.
* Press `Y` to confirm changes.
* Press `Enter` to write the file and exit.

---

#### **5) Restart the networking service**
```bash
systemctl restart networking
```

---

#### **6) Verify the IP address**
```bash
ip a
```

#### Look for your configured IP (e.g., `192.168.1.55`).
