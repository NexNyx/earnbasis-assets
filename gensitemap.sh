#!/bin/bash
# Genereert sitemap.xml op basis van /assets en /blogs mappen.
# Pakt index.html en *.html bestanden. Datum = file mtime.

set -e

SITE="https://earnbasis.com"
OUT="sitemap.xml"

echo '<?xml version="1.0" encoding="UTF-8"?>' > "$OUT"
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> "$OUT"

# Home
echo "  <url><loc>${SITE}/</loc><changefreq>weekly</changefreq><priority>1.0</priority></url>" >> "$OUT"

# Assets (000–012 die al bestaan)
if [ -d assets ]; then
  # index.html binnen elke asset-map
  while IFS= read -r -d '' file; do
    url_path=$(dirname "$file" | sed 's|^.|/|')'/'   # map pad
    lastmod=$(date -r "$file" "+%Y-%m-%d")
    echo "  <url><loc>${SITE}${url_path}</loc><lastmod>${lastmod}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>" >> "$OUT"
  done < <(find ./assets -mindepth 2 -maxdepth 2 -name "index.html" -print0)

  # losse .html bestanden direct onder assets submappen (optioneel)
  while IFS= read -r -d '' file; do
    url_path=$(echo "$file" | sed 's|^.|/|')
    url_path="${url_path#./}"
    lastmod=$(date -r "$file" "+%Y-%m-%d")
    echo "  <url><loc>${SITE}/${url_path}</loc><lastmod>${lastmod}</lastmod><changefreq>weekly</changefreq><priority>0.6</priority></url>" >> "$OUT"
  done < <(find ./assets -mindepth 2 -maxdepth 2 -type f -name "*.html" ! -name "index.html" -print0)
fi

# Blogs
if [ -d blogs ]; then
  # blog index
  if [ -f blogs/index.html ]; then
    lastmod=$(date -r blogs/index.html "+%Y-%m-%d")
    echo "  <url><loc>${SITE}/blogs/</loc><lastmod>${lastmod}</lastmod><changefreq>weekly</changefreq><priority>0.7</priority></url>" >> "$OUT"
  fi
  # individuele blogposts
  while IFS= read -r -d '' file; do
    url_path=$(echo "$file" | sed 's|^.|/|')
    url_path="${url_path#./}"
    lastmod=$(date -r "$file" "+%Y-%m-%d")
    echo "  <url><loc>${SITE}/${url_path}</loc><lastmod>${lastmod}</lastmod><changefreq>weekly</changefreq><priority>0.7</priority></url>" >> "$OUT"
  done < <(find ./blogs -type f -name "*.html" ! -path "./blogs/index.html" -print0)
fi

echo '</urlset>' >> "$OUT"

echo "✅ sitemap.xml gegenereerd."
