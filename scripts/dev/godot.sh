#!/usr/bin/env bash

set -euo pipefail

if command -v godot4 >/dev/null 2>&1; then
  GODOT_BIN="$(command -v godot4)"
elif [[ -x "$HOME/.local/bin/godot4" ]]; then
  GODOT_BIN="$HOME/.local/bin/godot4"
else
  printf 'Godot 4 no esta instalado. Consulte docs/ENTORNO.md.\n' >&2
  exit 1
fi

exec "$GODOT_BIN" "$@"
