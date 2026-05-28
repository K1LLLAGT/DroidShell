<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>DroidShell – System Overview</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;500;700;800&family=Share+Tech+Mono&display=swap" rel="stylesheet">
<style>
  :root {
    --bg:        #0a0c0b;
    --bg2:       #0e1210;
    --bg3:       #131916;
    --green:     #00e676;
    --green-dim: #1a3d2b;
    --green-mid: #4caf7a;
    --green-lo:  #2a5c3e;
    --amber:     #ffb300;
    --red:       #f44336;
    --text:      #b2dfcc;
    --text-dim:  #5a8a6e;
    --border:    #1e3b2a;
    --border-hi: #2e6645;
    --mono:      'JetBrains Mono', 'Share Tech Mono', monospace;
  }

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  html { scroll-behavior: smooth; }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: var(--mono);
    font-size: 13px;
    line-height: 1.7;
    min-height: 100vh;
    overflow-x: hidden;
  }

  /* ── SCANLINE OVERLAY ── */
  body::before {
    content: '';
    position: fixed;
    inset: 0;
    background: repeating-linear-gradient(
      0deg,
      transparent,
      transparent 2px,
      rgba(0,0,0,0.06) 2px,
      rgba(0,0,0,0.06) 4px
    );
    pointer-events: none;
    z-index: 9999;
  }

  /* ── NOISE TEXTURE ── */
  body::after {
    content: '';
    position: fixed;
    inset: 0;
    background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.03'/%3E%3C/svg%3E");
    pointer-events: none;
    opacity: 0.4;
    z-index: 9998;
  }

  /* ── LAYOUT ── */
  .page {
    max-width: 900px;
    margin: 0 auto;
    padding: 60px 32px 100px;
    position: relative;
  }

  /* ── HEADER ── */
  .header {
    border-bottom: 2px solid var(--green);
    padding-bottom: 32px;
    margin-bottom: 48px;
    position: relative;
  }

  .header::before {
    content: '// DroidShell v2.x';
    display: block;
    color: var(--text-dim);
    font-size: 11px;
    letter-spacing: 0.12em;
    margin-bottom: 16px;
    animation: fade-in 0.6s ease both;
  }

  .title {
    font-size: clamp(22px, 5vw, 40px);
    font-weight: 800;
    letter-spacing: 0.08em;
    color: var(--green);
    text-shadow:
      0 0 12px rgba(0,230,118,0.5),
      0 0 40px rgba(0,230,118,0.15);
    animation: fade-in 0.7s 0.1s ease both;
    line-height: 1.15;
  }

  .title span {
    color: var(--text-dim);
    font-weight: 300;
  }

  .subtitle {
    margin-top: 8px;
    font-size: 11px;
    letter-spacing: 0.18em;
    color: var(--text-dim);
    text-transform: uppercase;
    animation: fade-in 0.7s 0.2s ease both;
  }

  .desc {
    margin-top: 20px;
    color: var(--text);
    font-size: 13px;
    max-width: 680px;
    line-height: 1.8;
    animation: fade-in 0.7s 0.3s ease both;
  }

  /* ── SECTION ── */
  .section {
    margin-bottom: 52px;
    animation: slide-up 0.6s ease both;
  }

  .section:nth-child(2)  { animation-delay: 0.05s; }
  .section:nth-child(3)  { animation-delay: 0.10s; }
  .section:nth-child(4)  { animation-delay: 0.15s; }
  .section:nth-child(5)  { animation-delay: 0.20s; }
  .section:nth-child(6)  { animation-delay: 0.25s; }
  .section:nth-child(7)  { animation-delay: 0.30s; }
  .section:nth-child(8)  { animation-delay: 0.35s; }

  .section-label {
    font-size: 10px;
    letter-spacing: 0.22em;
    color: var(--text-dim);
    text-transform: uppercase;
    margin-bottom: 14px;
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .section-label::after {
    content: '';
    flex: 1;
    height: 1px;
    background: var(--border);
  }

  .section-title {
    font-size: 15px;
    font-weight: 700;
    letter-spacing: 0.12em;
    color: var(--green);
    text-transform: uppercase;
    margin-bottom: 24px;
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .section-title::before {
    content: '▸';
    color: var(--green-mid);
    font-size: 12px;
  }

  /* ── TIER GRID ── */
  .tier-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 12px;
  }

  .tier-card {
    background: var(--bg2);
    border: 1px solid var(--border);
    border-left: 3px solid var(--green-lo);
    padding: 16px 18px;
    transition: border-color 0.2s, background 0.2s, box-shadow 0.2s;
    position: relative;
    overflow: hidden;
  }

  .tier-card::before {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(135deg, rgba(0,230,118,0.03) 0%, transparent 60%);
    opacity: 0;
    transition: opacity 0.3s;
  }

  .tier-card:hover {
    border-color: var(--green);
    background: var(--bg3);
    box-shadow: 0 0 20px rgba(0,230,118,0.08), inset 0 0 30px rgba(0,230,118,0.02);
  }

  .tier-card:hover::before { opacity: 1; }

  .tier-num {
    font-size: 9px;
    letter-spacing: 0.15em;
    color: var(--text-dim);
    margin-bottom: 4px;
  }

  .tier-name {
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 0.1em;
    color: var(--green-mid);
    text-transform: uppercase;
    margin-bottom: 10px;
  }

  .tier-items {
    list-style: none;
    padding: 0;
  }

  .tier-items li {
    font-size: 11.5px;
    color: var(--text-dim);
    padding: 2px 0;
    padding-left: 12px;
    position: relative;
    transition: color 0.15s;
  }

  .tier-items li::before {
    content: '–';
    position: absolute;
    left: 0;
    color: var(--green-lo);
  }

  .tier-card:hover .tier-items li { color: var(--text); }

  /* ── DIRECTORY TREE ── */
  .tree-block {
    background: var(--bg2);
    border: 1px solid var(--border);
    border-left: 3px solid var(--green-lo);
    padding: 24px 28px;
    font-size: 12px;
    line-height: 2;
    position: relative;
  }

  .tree-block .dir  { color: var(--green); font-weight: 600; }
  .tree-block .sub  { color: var(--green-mid); }
  .tree-block .file { color: var(--text); }
  .tree-block .cmt  { color: var(--text-dim); font-style: italic; }

  /* ── CODE / COMMAND BLOCKS ── */
  .cmd-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .cmd-item {
    background: var(--bg2);
    border: 1px solid var(--border);
    border-left: 3px solid var(--amber);
    padding: 13px 18px;
    display: flex;
    flex-direction: column;
    gap: 4px;
    transition: border-color 0.2s, background 0.2s;
    cursor: default;
  }

  .cmd-item:hover {
    background: var(--bg3);
    border-left-color: var(--green);
  }

  .cmd-desc {
    font-size: 10.5px;
    color: var(--text-dim);
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  .cmd-code {
    font-size: 12.5px;
    color: var(--green);
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .cmd-code::before {
    content: '$';
    color: var(--amber);
    font-size: 11px;
  }

  /* ── PHILOSOPHY ── */
  .pillars {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 8px;
  }

  .pillar {
    background: var(--bg2);
    border: 1px solid var(--border);
    padding: 14px 16px;
    text-align: center;
    font-size: 11.5px;
    font-weight: 700;
    letter-spacing: 0.14em;
    color: var(--green-mid);
    text-transform: uppercase;
    transition: all 0.2s;
    position: relative;
  }

  .pillar:hover {
    background: var(--bg3);
    border-color: var(--green);
    color: var(--green);
    text-shadow: 0 0 12px rgba(0,230,118,0.5);
    transform: translateY(-2px);
    box-shadow: 0 4px 20px rgba(0,230,118,0.1);
  }

  .prose {
    color: var(--text-dim);
    font-size: 12.5px;
    line-height: 1.85;
    margin-bottom: 20px;
  }

  /* ── FOOTER ── */
  .footer {
    border-top: 1px solid var(--border);
    padding-top: 28px;
    margin-top: 60px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
  }

  .footer-left {
    font-size: 11px;
    color: var(--text-dim);
    letter-spacing: 0.1em;
  }

  .footer-right {
    font-size: 10px;
    color: var(--text-dim);
    letter-spacing: 0.1em;
    opacity: 0.5;
  }

  .license-tags {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    margin-top: 12px;
  }

  .tag {
    background: var(--bg2);
    border: 1px solid var(--border);
    padding: 4px 12px;
    font-size: 10px;
    letter-spacing: 0.12em;
    color: var(--text-dim);
    text-transform: uppercase;
    transition: all 0.2s;
  }

  .tag:hover {
    border-color: var(--green-mid);
    color: var(--green-mid);
  }

  /* ── CURSOR BLINK ── */
  .cursor {
    display: inline-block;
    width: 8px;
    height: 14px;
    background: var(--green);
    margin-left: 4px;
    vertical-align: middle;
    animation: blink 1s step-end infinite;
    box-shadow: 0 0 6px rgba(0,230,118,0.8);
  }

  /* ── DIVIDER ── */
  .divider {
    border: none;
    border-top: 1px solid var(--border);
    margin: 48px 0;
  }

  /* ── BADGE ROW ── */
  .badges {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    margin-top: 16px;
    animation: fade-in 0.7s 0.4s ease both;
  }

  .badge {
    font-size: 9.5px;
    letter-spacing: 0.15em;
    text-transform: uppercase;
    padding: 3px 10px;
    border: 1px solid;
  }

  .badge-green  { color: var(--green);   border-color: var(--green-lo);  }
  .badge-amber  { color: var(--amber);   border-color: rgba(255,179,0,0.3); }
  .badge-dim    { color: var(--text-dim); border-color: var(--border);   }

  /* ── ANIMATIONS ── */
  @keyframes fade-in {
    from { opacity: 0; }
    to   { opacity: 1; }
  }

  @keyframes slide-up {
    from { opacity: 0; transform: translateY(14px); }
    to   { opacity: 1; transform: translateY(0); }
  }

  @keyframes blink {
    0%, 100% { opacity: 1; }
    50%       { opacity: 0; }
  }

  /* ── RESPONSIVE ── */
  @media (max-width: 600px) {
    .page { padding: 36px 18px 80px; }
    .tier-grid { grid-template-columns: 1fr; }
    .pillars   { grid-template-columns: repeat(2, 1fr); }
  }
</style>
</head>
<body>
<div class="page">

  <!-- ══ HEADER ══ -->
  <header class="header">
    <div class="title">DROID<span>SHELL</span><span class="cursor"></span></div>
    <div class="subtitle">System Overview &amp; Architecture Reference</div>
    <p class="desc">
      DroidShell is a modular, script-driven automation and diagnostic framework.
      Built around a clean, deterministic <code style="color:var(--green);background:var(--bg2);padding:1px 5px;">ds-*</code> module ecosystem designed for
      Android, Linux, embedded systems, and technician-grade workflows.
    </p>
    <div class="badges">
      <span class="badge badge-green">Android</span>
      <span class="badge badge-green">Linux</span>
      <span class="badge badge-green">Embedded</span>
      <span class="badge badge-amber">Modular</span>
      <span class="badge badge-dim">ds-* ecosystem</span>
      <span class="badge badge-dim">Technician-grade</span>
    </div>
  </header>

  <!-- ══ ARCHITECTURE ══ -->
  <section class="section">
    <div class="section-label">Architecture</div>
    <div class="section-title">System Tiers</div>
    <div class="tier-grid">

      <div class="tier-card">
        <div class="tier-num">TIER 01</div>
        <div class="tier-name">Core Maintenance</div>
        <ul class="tier-items">
          <li>Environment bootstrap</li>
          <li>Naming lint</li>
          <li>Legacy cleanup</li>
        </ul>
      </div>

      <div class="tier-card">
        <div class="tier-num">TIER 02</div>
        <div class="tier-name">Module Framework</div>
        <ul class="tier-items">
          <li>Module registry</li>
          <li>Metadata system</li>
          <li>Documentation generator</li>
          <li>Search engine</li>
          <li>Category classifier</li>
          <li>Dependency graph</li>
          <li>Versioning system</li>
          <li>Installer</li>
          <li>Sandbox permissions</li>
        </ul>
      </div>

      <div class="tier-card">
        <div class="tier-num">TIER 03</div>
        <div class="tier-name">Distribution Layer</div>
        <ul class="tier-items">
          <li>Export / import</li>
          <li>Profiles</li>
          <li>Presets</li>
        </ul>
      </div>

      <div class="tier-card">
        <div class="tier-num">TIER 04</div>
        <div class="tier-name">Developer UX</div>
        <ul class="tier-items">
          <li>Interactive TUI</li>
          <li>Fuzzy launcher</li>
          <li>Help browser</li>
        </ul>
      </div>

      <div class="tier-card">
        <div class="tier-num">TIER 05</div>
        <div class="tier-name">Observability</div>
        <ul class="tier-items">
          <li>Metrics logging</li>
          <li>Timing analysis</li>
          <li>History viewer</li>
          <li>Profiler</li>
        </ul>
      </div>

      <div class="tier-card">
        <div class="tier-num">TIER 06</div>
        <div class="tier-name">Policy &amp; Safety</div>
        <ul class="tier-items">
          <li>Guardrails</li>
          <li>Invariant checks</li>
          <li>Preflight checks</li>
          <li>Rollback</li>
        </ul>
      </div>

      <div class="tier-card">
        <div class="tier-num">TIER 07</div>
        <div class="tier-name">Integrity &amp; Auto-Ops</div>
        <ul class="tier-items">
          <li>Integrity snapshots</li>
          <li>Snapshot comparison</li>
          <li>Integrity daemon</li>
          <li>Auto-update</li>
          <li>Auto-hardening</li>
          <li>Auto-sync</li>
        </ul>
      </div>

      <div class="tier-card">
        <div class="tier-num">TIER 08</div>
        <div class="tier-name">Lab / Experimentation</div>
        <ul class="tier-items">
          <li>Environment snapshots</li>
          <li>Snapshot diff</li>
          <li>Experiment harness</li>
        </ul>
      </div>

      <div class="tier-card">
        <div class="tier-num">TIER 09</div>
        <div class="tier-name">Ops &amp; Control Layer</div>
        <ul class="tier-items">
          <li>Job queue</li>
          <li>Worker engine</li>
          <li>Locking and unlocking</li>
          <li>Event bus</li>
          <li>Snapshot rotation</li>
          <li>Backup rotation</li>
        </ul>
      </div>

    </div>
  </section>

  <hr class="divider">

  <!-- ══ DIRECTORY STRUCTURE ══ -->
  <section class="section">
    <div class="section-label">Filesystem</div>
    <div class="section-title">Directory Structure</div>
    <div class="tree-block">
<span class="dir">DroidShell/</span><br>
&nbsp;&nbsp;<span class="sub">scripts/</span><br>
&nbsp;&nbsp;&nbsp;&nbsp;<span class="file">ds-*.sh</span>  <span class="cmt">(all modular system scripts)</span><br>
&nbsp;&nbsp;&nbsp;&nbsp;<span class="file">ds-generate-*.sh</span>  <span class="cmt">(suite generators)</span><br>
&nbsp;&nbsp;<span class="sub">registry/</span><br>
&nbsp;&nbsp;&nbsp;&nbsp;<span class="file">queue/</span>  <span class="cmt">(job queue)</span><br>
&nbsp;&nbsp;&nbsp;&nbsp;<span class="file">locks/</span>  <span class="cmt">(concurrency locks)</span><br>
&nbsp;&nbsp;&nbsp;&nbsp;<span class="file">events/</span>  <span class="cmt">(event bus)</span><br>
&nbsp;&nbsp;&nbsp;&nbsp;<span class="file">versions/</span>  <span class="cmt">(module versioning)</span><br>
&nbsp;&nbsp;&nbsp;&nbsp;<span class="file">meta/</span>  <span class="cmt">(module metadata)</span><br>
&nbsp;&nbsp;<span class="sub">out/</span>  <span class="cmt">(exports, backups, artifacts)</span><br>
&nbsp;&nbsp;<span class="file">droidshell-tree.txt</span>  <span class="cmt">(system tree snapshot)</span>
    </div>
  </section>

  <hr class="divider">

  <!-- ══ QUICK START ══ -->
  <section class="section">
    <div class="section-label">Usage</div>
    <div class="section-title">Quick Start</div>
    <div class="cmd-list">
      <div class="cmd-item">
        <div class="cmd-desc">Bootstrap the entire system</div>
        <div class="cmd-code">bash scripts/ds-bootstrap-all.sh</div>
      </div>
      <div class="cmd-item">
        <div class="cmd-desc">Generate module registry</div>
        <div class="cmd-code">bash scripts/ds-module-registry.sh</div>
      </div>
      <div class="cmd-item">
        <div class="cmd-desc">Run the developer TUI</div>
        <div class="cmd-code">bash scripts/ds-dev-tui.sh</div>
      </div>
      <div class="cmd-item">
        <div class="cmd-desc">Export the entire environment</div>
        <div class="cmd-code">bash scripts/ds-dist-export.sh</div>
      </div>
    </div>
  </section>

  <hr class="divider">

  <!-- ══ PHILOSOPHY ══ -->
  <section class="section">
    <div class="section-label">Design Principles</div>
    <div class="section-title">Philosophy</div>
    <p class="prose">
      Every script is standalone, auditable, and replaceable.
      DroidShell is built to be understood, modified, and trusted.
    </p>
    <div class="pillars">
      <div class="pillar">Determinism</div>
      <div class="pillar">Modularity</div>
      <div class="pillar">Reproducibility</div>
      <div class="pillar">Transparency</div>
      <div class="pillar">Technician-grade tooling</div>
    </div>
  </section>

  <hr class="divider">

  <!-- ══ DOCUMENTATION ══ -->
  <section class="section">
    <div class="section-label">Docs</div>
    <div class="section-title">Documentation</div>
    <p class="prose">Generate module documentation using the built-in docs generator:</p>
    <div class="cmd-list">
      <div class="cmd-item">
        <div class="cmd-desc">Generate module documentation</div>
        <div class="cmd-code">bash scripts/ds-module-docs.sh</div>
      </div>
    </div>
  </section>

  <!-- ══ FOOTER / LICENSE ══ -->
  <footer class="footer">
    <div class="footer-left">
      <div style="color:var(--green);font-weight:700;letter-spacing:0.1em;margin-bottom:6px;">LICENSE</div>
      <div style="color:var(--text-dim);font-size:11px;">Choose your preferred open-source or proprietary license.</div>
      <div class="license-tags">
        <span class="tag">MIT</span>
        <span class="tag">Apache 2.0</span>
        <span class="tag">Proprietary</span>
      </div>
    </div>
    <div class="footer-right">
      DroidShell &nbsp;·&nbsp; github.com/K1LLLAGT/DroidShell
    </div>
  </footer>

</div>
</body>
</html>
