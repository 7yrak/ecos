#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
ADB="$ANDROID_SDK_ROOT/platform-tools/adb"
APK_PATH="$PROJECT_ROOT/build/android/ecos-debug.apk"

if [[ ! -s "$APK_PATH" ]]; then
  printf 'No existe %s. Ejecute export_android_debug.sh primero.\n' "$APK_PATH" >&2
  exit 1
fi

if [[ "$("$ADB" devices | sed -n '2,$p' | rg -c $'\tdevice$' || true)" -eq 0 ]]; then
  printf 'No hay un dispositivo Android disponible en ADB.\n' >&2
  exit 1
fi

"$ADB" install -r "$APK_PATH"
"$ADB" shell monkey -p com.tyrak.ecos -c android.intent.category.LAUNCHER 1
