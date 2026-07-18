#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
failures=0

check_command() {
  local label="$1"
  local command_path="$2"

  if [[ -x "$command_path" ]] || command -v "$command_path" >/dev/null 2>&1; then
    printf '[OK] %s\n' "$label"
  else
    printf '[FALTA] %s\n' "$label"
    failures=$((failures + 1))
  fi
}

check_file() {
  local label="$1"
  local file_path="$2"

  if [[ -f "$file_path" ]]; then
    printf '[OK] %s\n' "$label"
  else
    printf '[FALTA] %s\n' "$label"
    failures=$((failures + 1))
  fi
}

printf 'ECOS - verificacion de entorno\n'
printf 'Proyecto: %s\n' "$PROJECT_ROOT"
printf 'Android SDK: %s\n\n' "$ANDROID_SDK_ROOT"

check_command 'Git' git
check_command 'Java' java
check_command 'Godot 4' "$HOME/.local/bin/godot4"
check_command 'ADB' "$ANDROID_SDK_ROOT/platform-tools/adb"
check_command 'SDK Manager' "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
check_file 'Android Platform 36' "$ANDROID_SDK_ROOT/platforms/android-36/android.jar"
check_file 'Android Build Tools 36.0.0' "$ANDROID_SDK_ROOT/build-tools/36.0.0/apksigner"
check_file 'Plantilla Android debug' "$HOME/.local/share/godot/export_templates/4.7.1.stable/android_debug.apk"

if (( failures > 0 )); then
  printf '\nEntorno incompleto: %d requisito(s) pendiente(s).\n' "$failures"
  exit 1
fi

printf '\nEntorno base completo.\n'
