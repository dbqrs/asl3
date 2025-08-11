## AllStarLink 3 Debian PC Installer

<p align="center">
  <img src="logo200.png" alt="unofficial logo" title="ASL3/Debian" width="131" height="125" />
</p>

> [!IMPORTANT]
> Make sure you’re logged in as the **root** user.

> [!TIP]
> Review the installer script before running it: <https://asl.dbqrs.com>

---

### Step 1 — Install `curl`

<button class="copy-btn">Copy</button>
<pre><code class="language-bash">apt install curl</code></pre>

---

### Step 2 — Run the installer

<button class="copy-btn">Copy</button>
<pre><code class="language-bash">curl -sSL https://asl.dbqrs.com</code></pre>

> If you didn’t set a static IP during Debian install, it’s recommended to do that now. Follow Steps 3–8.

---

## Step 3 — Open the network configuration file

<button class="copy-btn">Copy</button>
<pre><code class="language-bash">nano /etc/network/interfaces</code></pre>

---

### Step 4 — Find the current configuration

Look for this line:

```bash
iface eth0 inet dhcp
```

---

### Step 5 — Switch from DHCP to Static

Replace the DHCP line with a static config that fits your network:

<button class="copy-btn">Copy</button>

<pre><code class="language-ini">auto eth0
iface eth0 inet static
    address 192.168.1.55
    network 192.168.1.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8</code></pre>

> \[!NOTE]
> Your interface name may differ (e.g., `enp0s3`, `ens33`). Replace `eth0` with your actual interface.

---

### Step 6 — Save and exit `nano`

* Press **CTRL+X**
* Press **Y** to confirm
* Press **Enter** to write the file and exit

---

## Step 7 — Restart networking

<button class="copy-btn">Copy</button>

<pre><code class="language-bash">systemctl restart networking</code></pre>

---

### Step 8 — Verify the IP address

<button class="copy-btn">Copy</button>

<pre><code class="language-bash">ip a</code></pre>

Look for your configured IP (e.g., `192.168.1.55`).

---

<script>
document.addEventListener('click', async (e) => {
  const btn = e.target.closest('.copy-btn');
  if (!btn) return;
  const pre = btn.nextElementSibling;
  const code = pre && pre.querySelector('code');
  if (!code) return;
  try {
    await navigator.clipboard.writeText(code.innerText);
    const original = btn.textContent;
    btn.textContent = 'Copied!';
    setTimeout(() => (btn.textContent = original), 1200);
  } catch (err) {
    console.error('Copy failed:', err);
  }
});
</script>

---

## Configure a Static IP Address in Debian 12 Linux

This guide will walk you through changing the network configuration from DHCP to a static IP.

---

### **1) Open the network configuration file**

```bash
# Copy:
nano /etc/network/interfaces
```

---

### **2) Find the current configuration**

```bash
iface eth0 inet dhcp
```

---

### **3) Change DHCP to Static**

Replace with the following (adjust for your network):

```plaintext
# Copy:
auto eth0
iface eth0 inet static
    address 192.168.1.55
    network 192.168.1.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8
```

---

### **4) Save and exit nano**

* Press `CTRL+X` to begin saving.
* Press `Y` to confirm changes.
* Press `Enter` to write the file and exit.

---

### **5) Restart the networking service**

```bash
# Copy:
systemctl restart networking
```

---

### **6) Verify the IP address**

```bash
# Copy:
ip a
```

Look for your configured IP (e.g., `192.168.1.55`).

---

> \[!NOTE]
> Your interface name might not be `eth0`. It could be something like `enp0s3` or `ens33`.
> Replace `eth0` with your actual interface name.

---
