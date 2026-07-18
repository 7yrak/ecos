#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
OUTPUT_PATH="$PROJECT_ROOT/build/android/ecos-debug.apk"

export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_SDK_ROOT
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk-amd64}"

"$PROJECT_ROOT/scripts/dev/check_environment.sh"
mkdir -p "$(dirname "$OUTPUT_PATH")"
rm -f "$OUTPUT_PATH"

"$PROJECT_ROOT/scripts/dev/godot.sh" \
  --headless \
  --path "$PROJECT_ROOT" \
  --export-debug 'Android Debug' \
  "$OUTPUT_PATH"

if [[ ! -s "$OUTPUT_PATH" ]]; then
  printf 'La exportacion no genero %s.\n' "$OUTPUT_PATH" >&2
  exit 1
fi

"$ANDROID_SDK_ROOT/build-tools/36.0.0/apksigner" verify "$OUTPUT_PATH"
printf 'APK debug generada: %s\n' "$OUTPUT_PATH"
