#!/usr/bin/env bash
# Generates ios/Runner/Secrets.xcconfig from CI environment variables.
# Run this as a Codemagic pre-build script (before `flutter build ios` / pod install).
# Requires GOOGLE_PLACES_API_KEY to be set as a secure environment variable in Codemagic.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -z "${GOOGLE_PLACES_API_KEY:-}" ]; then
  echo "warning: GOOGLE_PLACES_API_KEY is not set; Secrets.xcconfig will not be written." >&2
  exit 0
fi

cat > "$REPO_ROOT/ios/Runner/Secrets.xcconfig" <<XCCONFIG
GOOGLE_PLACES_API_KEY=${GOOGLE_PLACES_API_KEY}
XCCONFIG

echo "Wrote ios/Runner/Secrets.xcconfig"
