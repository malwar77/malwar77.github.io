#!/usr/bin/env bash
# build-sitemap.sh — regenerate sitemap.xml for malwar77.github.io
#
# Usage: bash scripts/build-sitemap.sh
# Run from the repo root. Requires git (for per-file last commit dates).
#
# Includes every indexable HTML page:
#   - index.html            -> https://malwar77.github.io/
#   - projects.html, news.html, repo-guides.html, linux.html, gps-download.html
#   - projects/*.html       -> https://malwar77.github.io/projects/<file>
# Excludes (do not add these back without a reason):
#   - classic.html          (canonicalised to the homepage)
#   - design-lab.html       (noindex)
#   - google*.html          (search verification files)
#   - BingSiteAuth.xml      (not an HTML page)
#   - data/*.json           (JSON data files for the homepage loader;
#                            they are not pages and must never be sitemapped)
#
# <lastmod> is the date of the last git commit that touched each file.
# Rerun this script after committing, so changed files pick up the
# new commit date, and again after merging if the merge date differs.
# No <changefreq> or <priority> — crawlers ignore them on this site.
set -euo pipefail
cd "$(dirname "$0")/.."

BASE="https://malwar77.github.io"
OUT="sitemap.xml"

{
  printf '<?xml version="1.0" encoding="UTF-8"?>\n'
  printf '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'

  # Homepage first
  lastmod="$(git log -1 --format=%ad --date=short -- index.html 2>/dev/null || date +%F)"
  printf '  <url>\n    <loc>%s/</loc>\n    <lastmod>%s</lastmod>\n  </url>\n' "$BASE" "$lastmod"

  # Main pages, alphabetical
  for file in gps-download.html linux.html news.html projects.html repo-guides.html; do
    if [ -f "$file" ]; then
      lastmod="$(git log -1 --format=%ad --date=short -- "$file" 2>/dev/null || date +%F)"
      printf '  <url>\n    <loc>%s/%s</loc>\n    <lastmod>%s</lastmod>\n  </url>\n' "$BASE" "$file" "$lastmod"
    fi
  done

  # Project pages, alphabetical
  for file in projects/*.html; do
    lastmod="$(git log -1 --format=%ad --date=short -- "$file" 2>/dev/null || date +%F)"
    printf '  <url>\n    <loc>%s/%s</loc>\n    <lastmod>%s</lastmod>\n  </url>\n' "$BASE" "$file" "$lastmod"
  done

  printf '</urlset>\n'
} > "$OUT"

echo "Wrote $OUT with $(grep -c '<loc>' "$OUT") URLs"
