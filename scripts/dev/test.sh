#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

"$PROJECT_ROOT/scripts/dev/godot.sh" \
  --headless \
  --path "$PROJECT_ROOT" \
  --script res://tests/test_runner.gd
