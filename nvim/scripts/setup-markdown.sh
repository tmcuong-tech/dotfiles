#!/usr/bin/env bash
# Install the optional LaTeX dependency for render-markdown.nvim.
# Idempotent: safe to run again on a fresh clone or after an update.
set -euo pipefail

if command -v latex2text >/dev/null 2>&1; then
  echo "latex2text already installed"
  exit 0
fi

if command -v pipx >/dev/null 2>&1; then
  pipx install pylatexenc
elif command -v uv >/dev/null 2>&1; then
  uv tool install pylatexenc
else
  echo "Install pipx or uv, then re-run scripts/setup-markdown.sh" >&2
  exit 1
fi

command -v latex2text >/dev/null 2>&1 || {
  echo "latex2text not on PATH; add ~/.local/bin to PATH and re-run" >&2
  exit 1
}
echo "latex2text installed"
