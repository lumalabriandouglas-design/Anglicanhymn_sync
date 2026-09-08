#!/usr/bin/env bash
set -euo pipefail

# Vercel does not ship Flutter. Download a pinned stable Linux SDK, then build web.
# Pin avoids `git pull` on a cached SDK, which often 404s engine artifacts on Vercel.
FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.35.7}"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if [[ ! -x "$FLUTTER_DIR/bin/flutter" ]]; then
  echo "Downloading Flutter ${FLUTTER_VERSION}..."
  curl -L --fail --retry 3 -o /tmp/flutter.tar.xz "$FLUTTER_URL"
  tar -xJf /tmp/flutter.tar.xz -C "$HOME"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
export PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
export CI=true

flutter --version
flutter config --no-analytics --enable-web
flutter pub get
flutter build web --release
