#!/usr/bin/env bash
# move-apks.sh — prepare moving the repo-root APKs to a GitHub Release.
#
# This script does NOT delete anything and does NOT change gps-download.html.
# It is a preparation step only, because the APKs must stay downloadable
# until a Release actually exists.
#
# What it does:
#   1. Lists the APKs currently in the repo root.
#   2. Creates a GitHub Release (via the gh CLI) containing those APKs,
#      IF you run it with --do-release. Without that flag it only prints
#      the commands, so you can review them first.
#   3. Prints the exact git rm commands and the link change needed in
#      gps-download.html, to run AFTER you confirm the Release exists.
#
# Usage:
#   bash scripts/move-apks.sh            # dry run: print only
#   bash scripts/move-apks.sh --do-release   # actually create the Release
#
# Requirements for --do-release: gh CLI logged in to github.com/malwar77,
# with permission to create releases in malwar77.github.io.
set -euo pipefail
cd "$(dirname "$0")/.."

APKS="KelickFakeGPS-v1.2.apk KelickFakeGPS-v1.3.apk kelGPS-v1.8-diag.apk"
RELEASE_TAG="apk-downloads"
RELEASE_TITLE="Android APK downloads"

echo "APKs in repo root:"
for apk in $APKS; do
  if [ -f "$apk" ]; then
    ls -lh "$apk"
  else
    echo "  MISSING: $apk"
  fi
done
echo

if [ "${1:-}" = "--do-release" ]; then
  echo "Creating GitHub Release $RELEASE_TAG ..."
  gh release create "$RELEASE_TAG" $APKS \
    --repo malwar77/malwar77.github.io \
    --title "$RELEASE_TITLE" \
    --notes "Android APK downloads for Kelick Tech Hub (kelGPS / KelickFakeGPS). Previously served from the site root; moved here so the github.io site is not used as a file host."
  echo
  echo "Release created. Verify it at:"
  echo "  https://github.com/malwar77/malwar77.github.io/releases/tag/$RELEASE_TAG"
  echo
else
  echo "DRY RUN — no Release created. To create it, run:"
  echo "  bash scripts/move-apks.sh --do-release"
  echo "Or create it by hand with:"
  echo "  gh release create $RELEASE_TAG $APKS --repo malwar77/malwar77.github.io --title \"$RELEASE_TITLE\" --notes \"Android APK downloads for Kelick Tech Hub.\""
  echo
fi

echo "AFTER you confirm the Release exists, run these (in a branch, not main):"
for apk in $APKS; do
  echo "  git rm $apk"
done
echo
echo "Then update gps-download.html: replace each root APK link with its Release asset URL, for example:"
echo "  kelGPS-v1.8-diag.apk"
echo "    -> https://github.com/malwar77/malwar77.github.io/releases/download/$RELEASE_TAG/kelGPS-v1.8-diag.apk"
echo "  KelickFakeGPS-v1.3.apk"
echo "    -> https://github.com/malwar77/malwar77.github.io/releases/download/$RELEASE_TAG/KelickFakeGPS-v1.3.apk"
echo "  KelickFakeGPS-v1.2.apk"
echo "    -> https://github.com/malwar77/malwar77.github.io/releases/download/$RELEASE_TAG/KelickFakeGPS-v1.2.apk"
echo
echo "Do NOT run the git rm step until the Release URLs return 200."
