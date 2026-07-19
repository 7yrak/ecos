#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
SIGNING_ENV="${ECOS_SIGNING_ENV:-$HOME/.local/share/ecos/signing/release.env}"
OUTPUT_PATH="$PROJECT_ROOT/build/android/ECOS-0.2.4-android.apk"

if [[ ! -f "$SIGNING_ENV" ]]; then
  printf 'No existe la configuracion de firma: %s\n' "$SIGNING_ENV" >&2
  exit 1
fi

# La configuracion contiene secretos locales y nunca debe entrar al repositorio.
source "$SIGNING_ENV"
: "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:?Falta la ruta del keystore release}"
: "${GODOT_ANDROID_KEYSTORE_RELEASE_USER:?Falta el alias del keystore release}"
: "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:?Falta la clave del keystore release}"

export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_SDK_ROOT
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk-amd64}"
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH
export GODOT_ANDROID_KEYSTORE_RELEASE_USER
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD

"$PROJECT_ROOT/scripts/dev/check_environment.sh"
mkdir -p "$(dirname "$OUTPUT_PATH")"
rm -f "$OUTPUT_PATH"

"$PROJECT_ROOT/scripts/dev/godot.sh" \
  --headless \
  --path "$PROJECT_ROOT" \
  --export-release 'Android' \
  "$OUTPUT_PATH"

if [[ ! -s "$OUTPUT_PATH" ]]; then
  printf 'La exportacion no genero %s.\n' "$OUTPUT_PATH" >&2
  exit 1
fi

"$ANDROID_SDK_ROOT/build-tools/36.0.0/apksigner" verify "$OUTPUT_PATH"
if "$ANDROID_SDK_ROOT/build-tools/36.0.0/aapt2" dump xmltree "$OUTPUT_PATH" \
  --file AndroidManifest.xml 2>/dev/null | rg -q 'debuggable.*true'; then
  printf 'La APK release quedo marcada como depurable.\n' >&2
  exit 1
fi

printf 'APK release generada: %s\n' "$OUTPUT_PATH"
