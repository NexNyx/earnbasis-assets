#!/bin/bash
# Gebruik: ./newasset.sh 013 "prop-firm-survival"

set -euo pipefail  # strikter: -u en pipefail

ASSET_NUM="${1:-}"
ASSET_SLUG="${2:-}"

if [ -z "$ASSET_NUM" ] || [ -z "$ASSET_SLUG" ]; then
  echo "❌ Gebruik: ./newasset.sh <nummer> <slug>"
  echo "   Voorbeeld: ./newasset.sh 013 prop-firm-survival"
  exit 1
fi

# Unieke ID (fallback als openssl ontbreekt)
if command -v openssl >/dev/null 2>&1; then
  RAND_HEX="$(openssl rand -hex 4)"
else
  RAND_HEX="$(LC_ALL=C tr -dc 'a-f0-9' </dev/urandom | head -c 8)"
fi
UNIQUE_ID="${ASSET_NUM}-${RAND_HEX}"

# Slug -> Title Case
TITLE_WORDS=$(echo "$ASSET_SLUG" | tr '-' ' ')
ASSET_TITLE=$(echo "$TITLE_WORDS" | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1')

ASSET_DIR="assets/${ASSET_NUM}-${ASSET_SLUG}"
THANKYOU_DIR="${ASSET_DIR}/thank-you"
ACCESS_DIR="access/${ASSET_NUM}-${ASSET_SLUG}/${UNIQUE_ID}"
PDF_NAME="${ASSET_NUM}-${ASSET_SLUG}.pdf"
IMAGE_PATH="/images/${ASSET_NUM}-${ASSET_SLUG}.jpg"
CANONICAL_URL="https://earnbasis.com/${ASSET_DIR}/"
TODAY=$(date '+%Y-%m-%d')

# 1) Mappen
mkdir -p "${THANKYOU_DIR}"
mkdir -p "${ACCESS_DIR}"

# 1b) PDF source map (voor renderen van de PDF)
PDF_SRC_DIR="pdf-source"
PDF_SRC_FILE="${PDF_SRC_DIR}/${ASSET_NUM}-${ASSET_SLUG}-draft.html"
mkdir -p "${PDF_SRC_DIR}"

# 2) Placeholder PDF
: > "${ACCESS_DIR}/${PDF_NAME}"

# 3) index.html (SEO-skelet)
cat > "${ASSET_DIR}/index.html" <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>${ASSET_NUM} – ${ASSET_TITLE} | EarnBasis</title>
  <meta name="description" content="Description for Asset ${ASSET_NUM} – ${ASSET_TITLE} goes here. Keep it ~150 chars, action-oriented, with the core keywords." />
  <link rel="canonical" href="${CANONICAL_URL}" />
  <meta name="robots" content="index,follow" />

  <!-- Open Graph / Twitter -->
  <meta property="og:title" content="${ASSET_TITLE} (Asset ${ASSET_NUM})" />
  <meta property="og:description" content="Short value prop for ${ASSET_TITLE}. Add 1–2 key benefits + use-cases." />
  <meta property="og:image" content="https://earnbasis.com${IMAGE_PATH}" />
  <meta property="og:type" content="product" />
  <meta property="og:url" content="${CANONICAL_URL}" />
  <meta name="twitter:card" content="summary_large_image" />

  <link rel="icon" href="/images/favicon.ico" />
  <style>
    :root{--bg:#0b0d12;--text:#e9eefc;--muted:#9aa4c7;--card:#121520;--line:#1f2740;--brand1:#22d3ee;--brand2:#a78bfa;--brandtxt:#0b0d12}
    *{box-sizing:border-box}
    body{margin:0;background:var(--bg);color:var(--text);font:16px/1.65 system-ui,Inter,Segoe UI,Roboto,Arial}
    a{color:inherit;text-decoration:none}
    .wrap{max-width:980px;margin:0 auto;padding:28px 20px}
    header{display:flex;align-items:center;gap:10px;margin-bottom:16px}
    .logo{height:32px}
    .grid{display:grid;grid-template-columns:1.1fr .9fr;gap:24px}
    @media (max-width:900px){ .grid{grid-template-columns:1fr} }
    .card{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:18px}
    h1{margin:.25rem 0 0;font-size:28px;line-height:1.25}
    .lead{color:var(--muted);margin:8px 0 14px}
    .btn{display:inline-flex;align-items:center;justify-content:center;font-weight:800;border-radius:12px;padding:14px 18px;background:linear-gradient(90deg,var(--brand1),var(--brand2));color:var(--brandtxt);margin-right:10px}
    .btn-alt{background:#0e1220;border:1px solid var(--line);color:#dbeafe;border-radius:12px;padding:14px 18px;font-weight:800}
    .thumb{width:100%;border-radius:14px;border:1px solid #17223a;box-shadow:0 10px 28px rgba(0,0,0,.35)}
    ul{margin:0;padding-left:18px}
    li{margin:.35rem 0}
    .section{margin-top:24px}
    .muted{color:var(--muted)}
    footer{opacity:.85;margin-top:28px;padding:30px 0 40px}
  </style>
</head>
<body>
  <main class="wrap" itemscope itemtype="https://schema.org/Product">
    <header>
      <img src="/images/earnbasis_logo.png" alt="EarnBasis" class="logo" />
      <strong>EarnBasis</strong>
    </header>

    <section class="grid">
      <div class="card">
        <div style="display:inline-block;background:#0b1423;border:1px dashed #20314a;color:#cfe;padding:6px 10px;border-radius:10px;font-size:.85rem;margin-bottom:8px">
          Asset ${ASSET_NUM}
        </div>
        <h1 itemprop="name">${ASSET_TITLE}</h1>
        <p class="lead" itemprop="description">Short intro for ${ASSET_TITLE}. Explain who it's for, the key outcome, and time-to-apply.</p>

        <div style="margin:10px 0 16px">
          <strong>€5</strong> <span class="muted">• One-time • Instant access</span>
        </div>

        <div>
          <!-- TODO: vervang met je echte PayPal-link -->
          <a class="btn" href="https://www.paypal.com/ncp/payment/REPLACE_WITH_LINK" target="_blank" rel="noopener nofollow">💸 Buy Now — €5</a>
          <a class="btn-alt" href="/assets/000-ltd-access/">💼 Or get the Lifetime Deal</a>
        </div>

        <div class="section">
          <h2 style="margin:0 0 8px 0">What’s inside</h2>
          <ul>
            <li>Bullet 1 — concrete benefit</li>
            <li>Bullet 2 — checklist/template</li>
            <li>Bullet 3 — example/diagram</li>
            <li>Bullet 4 — bonus or routine</li>
          </ul>
        </div>

        <div class="section">
          <h2 style="margin:0 0 8px 0">Who this is for</h2>
          <p class="muted">Describe ideal user/persona & markets (Forex, Gold, Crypto).</p>
        </div>

        <div class="section">
          <h2 style="margin:0 0 8px 0">Refer & earn</h2>
          <p class="muted">Invite traders, unlock assets. Simple link, instant rewards.</p>
          <p><a class="btn-alt" href="/invite">🔗 Get your referral link</a></p>
        </div>

        <p class="muted" style="margin-top:12px">No financial advice. Educational content only.</p>
      </div>

      <aside>
        <img class="thumb" src="${IMAGE_PATH}" alt="${ASSET_TITLE} cover" />
        <div class="card section">
          <strong>Also in the Lifetime Deal</strong>
          <ul class="muted">
            <li>#011 — Forex Day Trading Playbook (27 pages)</li>
            <li>#003 — BTC Scalping Strategy Pack</li>
            <li>#005 — London Breakout Strategy</li>
          </ul>
          <p><a class="btn" href="/assets/000-ltd-access/">🔓 Unlock the Lifetime Deal</a></p>
        </div>
      </aside>
    </section>

    <script type="application/ld+json">
    {
      "@context":"https://schema.org",
      "@type":"Product",
      "name":"${ASSET_TITLE} (Asset ${ASSET_NUM})",
      "description":"Short value prop for ${ASSET_TITLE}.",
      "image":"https://earnbasis.com${IMAGE_PATH}",
      "brand":{"@type":"Brand","name":"EarnBasis"},
      "offers":{
        "@type":"Offer",
        "price":"5.00",
        "priceCurrency":"EUR",
        "url":"https://www.paypal.com/ncp/payment/REPLACE_WITH_LINK",
        "availability":"https://schema.org/InStock"
      }
    }
    </script>

    <footer class="muted">
      © EarnBasis — Trading education assets. No financial advice.
    </footer>
  </main>
</body>
</html>
EOF

# 3b) PDF SOURCE: draft HTML voor PDF-rendering
cat > "${PDF_SRC_FILE}" <<'EOF_DRAFT'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>[DRAFT] Asset ASSET_NUM_PLACEHOLDER — ASSET_TITLE_PLACEHOLDER | EarnBasis</title>

  <!-- IMPORTANT: This is a draft source file for PDF generation only -->
  <meta name="robots" content="noindex,nofollow" />

  <style>
    :root { --ink:#0b0d12; --muted:#465067; --brand:#22d3ee; --accent:#a78bfa; }
    body { margin: 0; font: 15px/1.6 system-ui, -apple-system, Segoe UI, Roboto, Inter, Arial; color: var(--ink); }
    .page { max-width: 860px; margin: 28px auto; padding: 0 20px; }
    h1, h2, h3 { margin: 0 0 8px; line-height: 1.2; }
    h1 { font-size: 28px; }
    h2 { font-size: 20px; margin-top: 18px; }
    h3 { font-size: 16px; margin-top: 14px; }
    p { margin: 8px 0; }
    ul { margin: 8px 0 8px 20px; }
    .eyebrow { text-transform: uppercase; letter-spacing: .12em; color: var(--accent); font-weight: 800; font-size: 12px; }
    .meta { color: var(--muted); font-size: 13px; }
    .box { border: 1px solid #e5e8f0; border-radius: 10px; padding: 14px; margin: 14px 0; }
    .check li::marker { content: "✔ "; color: #16a34a; }
    .warn li::marker { content: "⚠ "; color: #d97706; }
    .table { width: 100%; border-collapse: collapse; margin: 8px 0; font-size: 13.5px; }
    .table th, .table td { border: 1px solid #e5e8f0; padding: 8px 10px; text-align: left; }
    .muted { color: var(--muted); }
    .cta { text-align: center; margin: 20px 0; }
    hr { border: 0; border-top: 1px solid #e5e8f0; margin: 18px 0; }
    .center { text-align: center; }
    img.logo { max-width: 200px; margin-bottom: 20px; }
    img.cover { max-width: 100%; border-radius: 14px; border: 1px solid #ccc; box-shadow: 0 4px 16px rgba(0,0,0,0.25); }
    .pagebreak { page-break-before: always; }
    .small { font-size: 12.5px; color: var(--muted); }
    .btn { display:inline-block;padding:10px 16px;border-radius:10px;font-weight:700;background:linear-gradient(90deg,#22d3ee,#a78bfa);color:#0b0d12;text-decoration:none }
  </style>
</head>
<body>
  <!-- Cover page -->
  <div class="page center">
    <img src="/images/earnbasis_logo.png" alt="EarnBasis logo" class="logo" />
    <img src="IMAGE_PATH_PLACEHOLDER" alt="ASSET_TITLE_PLACEHOLDER cover" class="cover" />
  </div>

  <!-- Content starts on new page -->
  <div class="page pagebreak">
    <div class="eyebrow">Asset ASSET_NUM_PLACEHOLDER</div>
    <h1>🛡️ ASSET_TITLE_PLACEHOLDER</h1>
    <p class="meta">Time to apply: ~15 minutes · Target audience: prop firm challenge takers · Theme: survival rules, consistency, rule-proof execution</p>

    <div class="box">
      <strong>What this pack gives you</strong>
      <ul class="check">
        <li>Daily loss cap templates (1–2% max drawdown)</li>
        <li>Risk-per-trade tables for €10k, €25k, €50k accounts</li>
        <li>Pre-trade checklist to avoid rule violations</li>
        <li>Psychology tips to keep you calm during challenges</li>
      </ul>
    </div>

    <h2>1) Why Most Traders Fail Prop Firms</h2>
    <p>90%+ fail not because of bad setups, but because of <strong>rule violations</strong>. The killers:</p>
    <ul class="warn">
      <li>Hitting daily loss limits by revenge trading</li>
      <li>Ignoring high-impact news and blowing stops</li>
      <li>Overleveraging on “perfect” setups</li>
      <li>Trading every session instead of waiting for A+ setups</li>
    </ul>

    <h2>2) Core Survival Rules</h2>
    <ul class="check">
      <li>Risk 0.25–0.5% per trade (small but consistent)</li>
      <li>Set a hard daily loss cap at 1–1.5% — stop if hit</li>
      <li>Max 2–3 trades per day — walk away after that</li>
      <li>Ban-list: avoid trading during red-folder news</li>
      <li>Always log setups — violations kill faster than losses</li>
    </ul>

    <h2>3) Daily Pre-Trade Checklist</h2>
    <ol>
      <li>✅ Bias confirmed on Daily & 4H</li>
      <li>✅ No high-impact news in the next 60 minutes</li>
      <li>✅ Risk calculated at ≤0.5%</li>
      <li>✅ Entry setup matches one of your 3 playbooks</li>
      <li>✅ Stop after max 3 trades (win or lose)</li>
    </ol>

    <h2>4) Risk Templates (Example)</h2>
    <table class="table">
      <thead><tr><th>Account</th><th>1% Risk</th><th>0.5% Risk</th><th>0.25% Risk</th></tr></thead>
      <tbody>
        <tr><td>€10,000</td><td>€100</td><td>€50</td><td>€25</td></tr>
        <tr><td>€25,000</td><td>€250</td><td>€125</td><td>€62.5</td></tr>
        <tr><td>€50,000</td><td>€500</td><td>€250</td><td>€125</td></tr>
      </tbody>
    </table>

    <h2>5) Psychology & Survival Mindset</h2>
    <ul class="check">
      <li>Do NOT “make back” losses same day — stop trading</li>
      <li>Use affirmations: “Survival > Profit”</li>
      <li>Trade less → survive longer → higher odds of passing</li>
    </ul>

    <h2>6) Tools to Support Prop Survival</h2>
    <table class="table">
      <thead><tr><th>Tool</th><th>Use Case</th><th>Link</th></tr></thead>
      <tbody>
        <tr>
          <td>TradingView</td>
          <td>HTF charting & alerts</td>
          <td><a href="https://www.tradingview.com/?aff_id=155969&aff_sub=earnbasis">tradingview.com</a></td>
        </tr>
        <tr>
          <td>Tradesanta</td>
          <td>Automated crypto bots (low screen time setups)</td>
          <td><a href="http://tradesanta.com/site/set-referral-cookie?referral_id=419212">tradesanta.com</a></td>
        </tr>
        <tr>
          <td>Bybit</td>
          <td>Trading environment with risk management features</td>
          <td><a href="https://www.bybit.com/invite?ref=XYGPM2">bybit.com</a></td>
        </tr>
        <tr>
          <td>EarnBasis LTD</td>
          <td>Unlock all assets + premium playbooks</td>
          <td><a href="/assets/000-ltd-access/">earnbasis.com LTD</a></td>
        </tr>
      </tbody>
    </table>

    <div class="cta">
      <a class="btn" href="/assets/000-ltd-access/">🔓 Unlock the Lifetime Deal</a>
      <p class="small muted">All assets. Lifetime updates. One payment.</p>
    </div>

    <hr />

    <h2>Affiliate Disclosure</h2>
    <p class="small">Some links in this guide are affiliate links. If you sign up or purchase through them, EarnBasis may receive a commission at no extra cost to you. We only recommend tools we trust and actively use.</p>

    <p class="small muted">© EarnBasis — Educational content only. No financial advice. Results vary.</p>
  </div>
</body>
</html>
EOF_DRAFT

# variabelen in draft injecteren (eenvoudige placeholder-replace)
sed -i '' -e "s/ASSET_NUM_PLACEHOLDER/${ASSET_NUM}/g" "${PDF_SRC_FILE}" 2>/dev/null || sed -i "s/ASSET_NUM_PLACEHOLDER/${ASSET_NUM}/g" "${PDF_SRC_FILE}"
sed -i '' -e "s/ASSET_TITLE_PLACEHOLDER/${ASSET_TITLE}/g" "${PDF_SRC_FILE}" 2>/dev/null || sed -i "s/ASSET_TITLE_PLACEHOLDER/${ASSET_TITLE}/g" "${PDF_SRC_FILE}"
sed -i '' -e "s#IMAGE_PATH_PLACEHOLDER#${IMAGE_PATH}#g" "${PDF_SRC_FILE}" 2>/dev/null || sed -i "s#IMAGE_PATH_PLACEHOLDER#${IMAGE_PATH}#g" "${PDF_SRC_FILE}"

# 4) thank-you/index.html
cat > "${THANKYOU_DIR}/index.html" <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Thank You – Asset ${ASSET_NUM} | EarnBasis</title>
  <meta name="robots" content="noindex,nofollow" />
  <style>
    body{margin:0;padding:40px;font-family:system-ui,Arial;background:#0b0d12;color:#e9eefc;text-align:center}
    h1{font-size:28px;margin-bottom:10px}
    p{color:#9aa4c7;line-height:1.6}
    .btn{display:inline-block;margin:18px 0;padding:14px 22px;border-radius:10px;font-weight:700;text-decoration:none;background:linear-gradient(90deg,#22d3ee,#a78bfa);color:#0b0d12;box-shadow:0 4px 14px rgba(0,0,0,0.3)}
    .section{margin-top:40px;padding-top:20px;border-top:1px solid #1f2740}
    .logo{max-width:160px;margin-bottom:20px}
  </style>
</head>
<body>
  <img class="logo" src="/images/earnbasis_logo.png" alt="EarnBasis logo" />
  <h1>✅ Thank you — your asset is ready</h1>
  <p>You now have access to <strong>Asset ${ASSET_NUM} – ${ASSET_TITLE}</strong>.</p>

  <p><a class="btn" href="/${ACCESS_DIR}/${PDF_NAME}" target="_blank" rel="noopener nofollow">📥 Download Your PDF</a></p>

  <div class="section">
    <h2>🔓 Want More?</h2>
    <p>Unlock <strong>all current & future assets</strong> with the Lifetime Deal.</p>
    <p><a class="btn" href="/assets/000-ltd-access/">💼 Get the Lifetime Deal</a></p>
  </div>

  <div class="section">
    <h2>👥 Refer & Earn</h2>
    <p>Share EarnBasis with your friends. Every referral gives you rewards & free assets.</p>
    <p><a class="btn" href="/invite">🎯 Join Referral Program</a></p>
  </div>

  <p style="margin-top:30px;color:#9aa4c7">© EarnBasis — Educational content only. No financial advice.</p>
</body>
</html>
EOF

# 5) sitemap.xml bijwerken (voegt 1 entry toe)
SITEMAP="sitemap.xml"
if [ -f "$SITEMAP" ]; then
  if grep -q '</urlset>' "$SITEMAP"; then
    # verwijder laatste regel </urlset> (BSD/GNU compat)
    sed -i '' -e '$ d' "$SITEMAP" 2>/dev/null || sed -i '$ d' "$SITEMAP"
  fi
  cat >> "$SITEMAP" <<EOF
  <url>
    <loc>${CANONICAL_URL}</loc>
    <lastmod>${TODAY}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
EOF
else
  cat > "$SITEMAP" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>${CANONICAL_URL}</loc>
    <lastmod>${TODAY}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
EOF
fi

echo "✅ Asset ${ASSET_NUM} aangemaakt"
echo "   - Pagina:     ${ASSET_DIR}/index.html"
echo "   - Thank-you:  ${THANKYOU_DIR}/index.html"
echo "   - Download:   /${ACCESS_DIR}/${PDF_NAME}"
echo "   - PDF source: ${PDF_SRC_FILE}"
echo "   - Afbeelding: ${IMAGE_PATH}"
echo "   - Sitemap:    sitemap.xml bijgewerkt"
echo "ℹ️ Vergeet niet: PayPal-link & SEO-tekst invullen. Tip: zet 'Disallow: /pdf-source/' in robots.txt en voeg 'pdf-source/' toe aan .gitignore."
