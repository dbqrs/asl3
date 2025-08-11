<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>AllStarLink 3 Debian PC Installer</title>
  <meta name="description" content="AllStarLink 3 Debian PC Installer — quick start and static IP configuration for Debian 12." />
  <style>
    :root{
      --bg: #0b0d10;
      --panel: #12161a;
      --text: #e8ecf1;
      --muted: #a9b3be;
      --accent: #4cc2ff;
      --accent-2: #67e8a6;
      --border: #1f252b;
      --code-bg: #0f1317;
      --warn-bg: #1a1111;
      --warn-border: #402222;
      --shadow: 0 10px 30px rgba(0,0,0,.25);
      --radius: 16px;
    }
    @media (prefers-color-scheme: light){
      :root{
        --bg:#f6f8fb; --panel:#ffffff; --text:#0f1720; --muted:#475569;
        --accent:#0077ff; --accent-2:#059669; --border:#e5e7eb; --code-bg:#0f1720;
        --warn-bg:#fff6f6; --warn-border:#ffd6d6; --shadow:0 10px 30px rgba(0,0,0,.08);
      }
    }

    * { box-sizing: border-box; }
    html, body { height: 100%; }
    body {
      margin: 0;
      font: 16px/1.6 system-ui, -apple-system, Segoe UI, Roboto, "Helvetica Neue", Arial, "Noto Sans", "Apple Color Emoji","Segoe UI Emoji";
      color: var(--text);
      background: radial-gradient(1200px 600px at 20% -10%, rgba(76,194,255,.2), transparent 60%),
                  radial-gradient(900px 500px at 120% 20%, rgba(103,232,166,.18), transparent 60%),
                  var(--bg);
    }

    .container {
      max-width: 980px;
      margin: 40px auto 80px;
      padding: 0 20px;
    }

    header {
      text-align: center;
      margin-bottom: 28px;
    }
    .brand {
      display: inline-flex;
      align-items: center;
      gap: 16px;
      padding: 18px 22px;
      background: linear-gradient(180deg, rgba(255,255,255,.05), rgba(255,255,255,0));
      border: 1px solid var(--border);
      border-radius: 999px;
      box-shadow: var(--shadow);
    }
    .brand img {
      width: 52px; height: 50px; border-radius: 12px;
    }
    h1.title {
      font-size: clamp(26px, 4vw, 40px);
      margin: 18px 0 4px;
      letter-spacing: .2px;
    }
    .subtitle { color: var(--muted); margin: 0; font-size: 15px; }

    .panel {
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      overflow: hidden;
      margin-top: 22px;
    }

    .panel > .content { padding: 22px; }
    .panel h2 {
      font-size: clamp(20px, 2.4vw, 28px);
      margin: 0 0 14px;
    }
    .panel h3 {
      font-size: 18px;
      margin: 22px 0 8px;
    }

    p, li { color: var(--text); }
    .muted { color: var(--muted); }

    .callout {
      display: grid;
      grid-template-columns: 28px 1fr;
      gap: 12px;
      padding: 14px 16px;
      border-radius: 12px;
      border: 1px solid var(--border);
      background: linear-gradient(0deg, rgba(103,232,166,.08), rgba(103,232,166,.08)) border-box;
      margin: 14px 0 8px;
    }
    .callout .icon { font-size: 20px; line-height: 1; margin-top: 1px; }
    .callout a { color: var(--accent-2); text-decoration: none; border-bottom: 1px dashed currentColor; }
    .callout a:hover { opacity: .85; }

    /* Code blocks with copy buttons */
    pre {
      position: relative;
      margin: 12px 0 20px;
      background: var(--code-bg);
      color: #e5f0ff;
      border: 1px solid var(--border);
      border-radius: 12px;
      overflow: auto;
      padding: 14px 16px;
      font: 13.5px/1.5 ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace;
    }
    code { white-space: pre; }
    .code-head {
      display: flex; justify-content: space-between; align-items: center;
      gap: 8px; margin-top: 6px; margin-bottom: 6px;
    }
    .code-label {
      font-size: 12px; color: var(--muted); letter-spacing: .3px; text-transform: uppercase;
    }
    .copy-btn {
      appearance: none;
      border: 1px solid var(--border);
      background: linear-gradient(180deg, rgba(255,255,255,.06), rgba(255,255,255,0));
      color: var(--text);
      font-size: 12.5px;
      padding: 6px 10px;
      border-radius: 9px;
      cursor: pointer;
    }
    .copy-btn:hover { filter: brightness(1.05); }
    .copy-btn:active { transform: translateY(1px); }

    .step {
      border-left: 3px solid var(--accent);
      padding-left: 14px;
      margin: 22px 0;
    }
    .step h4 {
      margin: 0 0 6px;
      font-size: 16px;
      letter-spacing: .2px;
    }

    .footer-note {
      text-align: center;
      color: var(--muted);
      font-size: 13px;
      margin-top: 28px;
    }

    a { color: var(--accent); text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <span class="brand">
        <img src="logo200.png" alt="AllStarLink unofficial logo" width="131" height="125">
        <strong>ASL3 / Debian</strong>
      </span>
      <h1 class="title">AllStarLink 3 Debian PC Installer</h1>
      <p class="subtitle">Quick start and static IP configuration for Debian 12</p>
    </header>

    <!-- INSTALLATION -->
    <section class="panel">
      <div class="content">
        <h2>Installation</h2>
        <p class="muted">Make sure you’re logged in as the <strong>root</strong> user.</p>

        <div class="callout" role="note" aria-label="Recommendation">
          <div class="icon">🔎</div>
          <div>
            Before running the installer, <strong>review the script</strong> at
            <a href="https://asl.dbqrs.com" target="_blank" rel="noopener">asl.dbqrs.com</a>.
          </div>
        </div>

        <div class="step">
          <h4>1) Install <code>curl</code></h4>
          <div class="code-head">
            <span class="code-label">bash</span>
            <button class="copy-btn" data-copy="apt install curl">Copy</button>
          </div>
          <pre><code>apt install curl</code></pre>
        </div>

        <div class="step">
          <h4>2) Run the installer</h4>
          <p>After reviewing the code, run:</p>
          <div class="code-head">
            <span class="code-label">bash</span>
            <button class="copy-btn" data-copy="curl -sSL https://asl.dbqrs.com">Copy</button>
          </div>
          <pre><code>curl -sSL https://asl.dbqrs.com</code></pre>
        </div>
      </div>
    </section>

    <!-- STATIC IP -->
    <section class="panel">
      <div class="content">
        <h2>Configure a Static IP Address (Debian 12)</h2>
        <p class="muted">This switches your network interface from DHCP to a static IP.</p>

        <div class="step">
          <h4>1) Open the network configuration file</h4>
          <div class="code-head">
            <span class="code-label">bash</span>
            <button class="copy-btn" data-copy="nano /etc/network/interfaces">Copy</button>
          </div>
          <pre><code>nano /etc/network/interfaces</code></pre>
        </div>

        <div class="step">
          <h4>2) Find the current configuration</h4>
          <pre><code>iface eth0 inet dhcp</code></pre>
        </div>

        <div class="step">
          <h4>3) Change DHCP to static</h4>
          <p>Replace the DHCP line with a static configuration. Update values for your network.</p>
          <div class="code-head">
            <span class="code-label">/etc/network/interfaces</span>
            <button class="copy-btn" data-copy="auto eth0
iface eth0 inet static
    address 192.168.1.55
    network 192.168.1.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8">Copy</button>
          </div>
          <pre><code>auto eth0
iface eth0 inet static
    address 192.168.1.55
    network 192.168.1.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8</code></pre>
        </div>

        <div class="step">
          <h4>4) Save and exit <code>nano</code></h4>
          <ul>
            <li>Press <kbd>Ctrl</kbd> + <kbd>X</kbd></li>
            <li>Press <kbd>Y</kbd> to confirm</li>
            <li>Press <kbd>Enter</kbd> to write the file</li>
          </ul>
        </div>

        <div class="step">
          <h4>5) Restart networking</h4>
          <div class="code-head">
            <span class="code-label">bash</span>
            <button class="copy-btn" data-copy="systemctl restart networking">Copy</button>
          </div>
          <pre><code>systemctl restart networking</code></pre>
        </div>

        <div class="step">
          <h4>6) Verify the IP address</h4>
          <div class="code-head">
            <span class="code-label">bash</span>
            <button class="copy-btn" data-copy="ip a">Copy</button>
          </div>
          <pre><code>ip a</code></pre>
          <p class="muted">Look for your configured IP (e.g., <code>192.168.1.55</code>).</p>
        </div>

        <div class="callout" role="note" aria-label="Tip">
          <div class="icon">💡</div>
          <div>
            Interface name may differ (e.g., <code>enp0s3</code> or <code>ens33</code>). Replace <code>eth0</code> with your actual interface.
          </div>
        </div>
      </div>
    </section>

    <p class="footer-note">© AllStarLink 3 • This page is an unofficial helper for Debian setup.</p>
  </div>

  <script>
    // Add copy-to-clipboard for code blocks
    document.querySelectorAll('.copy-btn').forEach(btn => {
      btn.addEventListener('click', async () => {
        const text = btn.getAttribute('data-copy');
        try {
          await navigator.clipboard.writeText(text);
          const old = btn.textContent;
          btn.textContent = 'Copied!';
          setTimeout(() => (btn.textContent = old), 1200);
        } catch (e) {
          // Fallback: select the adjacent code text
          const pre = btn.closest('.step')?.querySelector('pre code');
          if (pre) {
            const range = document.createRange();
            range.selectNodeContents(pre);
            const sel = window.getSelection();
            sel.removeAllRanges();
            sel.addRange(range);
          }
        }
      });
    });
  </script>
</body>
</html>
