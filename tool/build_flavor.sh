#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Qalam — flavored release build (docs/40 §28, docs/46, docs/51 P7.1).
#
# Builds a single flavor + artifact with the matching dart_defines file, Dart
# obfuscation, and split debug symbols. This is the ONE bridge that ties a native
# build flavor to its --dart-define-from-file config so the two never drift.
#
# Usage:
#   tool/build_flavor.sh <development|qa|staging|production> <apk|appbundle|ipa>
#
# Examples:
#   tool/build_flavor.sh production appbundle        # Play Store upload (.aab)
#   tool/build_flavor.sh qa apk                      # sideloadable QA build
#   tool/build_flavor.sh production ipa              # App Store archive
#   BUILD_NUMBER=42 tool/build_flavor.sh staging appbundle
#
# Environment:
#   BUILD_NUMBER   overrides the build number (CI sets this; defaults to a
#                  UTC timestamp so local builds are always monotonic).
#
# Signing / secrets:
#   Android release signing comes from android/key.properties (git-ignored); when
#   absent the build falls back to debug signing (android/app/build.gradle.kts).
#   The crash-reporting DSN is NOT committed in dart_defines/*.json — CI injects it
#   by appending, e.g.:  --dart-define=QALAM_SENTRY_DSN=<dsn>  (later define wins).
#
# Symbols:
#   --split-debug-info writes an obfuscation map to build/symbols/<flavor>. ARCHIVE
#   IT per release — it is required to de-obfuscate crash stack traces later.
#
# ── Store build notes ────────────────────────────────────────────────────────
# Google Play (App Bundle):
#   • Upload the .aab from the printed path to Play Console → Internal testing.
#   • Complete the Data safety form: Qalam collects account data (email/profile)
#     and content the user creates; auth tokens live in Keystore-backed secure
#     storage; no advertising ID; crash data only when a DSN is configured.
#   • Play App Signing re-signs with the app key; you upload with the upload key.
# Apple App Store (IPA):
#   • Build the ipa, then upload via Xcode Organizer or `xcrun altool`/Transporter.
#   • Complete App Privacy: contact info (email), user content, identifiers (user
#     id), and diagnostics (crash data, only when a DSN is configured).
#   • Production uses bundle id com.qalam.qalam_mobile (ios/Flutter/flavors).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

FLAVOR="${1:-}"
ARTIFACT="${2:-}"

usage() {
  echo "usage: tool/build_flavor.sh <development|qa|staging|production> <apk|appbundle|ipa>" >&2
  exit 64
}

case "$FLAVOR" in
  development | qa | staging | production) ;;
  *) echo "error: unknown flavor '${FLAVOR}'" >&2; usage ;;
esac

case "$ARTIFACT" in
  apk | appbundle | ipa) ;;
  *) echo "error: unknown artifact '${ARTIFACT}'" >&2; usage ;;
esac

# Resolve repo root from this script's location so it runs from anywhere.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

DEFINES_FILE="dart_defines/${FLAVOR}.json"
if [[ ! -f "${DEFINES_FILE}" ]]; then
  echo "error: missing ${DEFINES_FILE}" >&2
  exit 66
fi

BUILD_NUMBER="${BUILD_NUMBER:-$(date -u +%Y%m%d%H%M)}"
SYMBOLS_DIR="build/symbols/${FLAVOR}"

echo "▶ Building ${ARTIFACT} · flavor=${FLAVOR} · build=${BUILD_NUMBER}"
echo "  defines=${DEFINES_FILE} · symbols=${SYMBOLS_DIR}"

flutter build "${ARTIFACT}" \
  --release \
  --flavor "${FLAVOR}" \
  --dart-define-from-file="${DEFINES_FILE}" \
  --obfuscate \
  --split-debug-info="${SYMBOLS_DIR}" \
  --build-number="${BUILD_NUMBER}"

# Report the produced artifact path (best-effort — matches Flutter's output dirs).
case "$ARTIFACT" in
  apk)       OUT="build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk" ;;
  appbundle) OUT="build/app/outputs/bundle/${FLAVOR}Release/app-${FLAVOR}-release.aab" ;;
  ipa)       OUT="build/ios/ipa" ;;
esac

echo "✅ Done."
if [[ -e "${OUT}" ]]; then
  echo "   artifact: ${OUT}"
else
  echo "   artifact: see Flutter output above (expected near: ${OUT})"
fi
echo "   symbols : ${SYMBOLS_DIR}  (archive for crash de-obfuscation)"
