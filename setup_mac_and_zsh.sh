#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MAC_SCRIPT="$SCRIPT_DIR/mac"
SOURCE_ZSHRC="$SCRIPT_DIR/.zshrc"
SOURCE_ALIASES="$SCRIPT_DIR/.zsh_aliases"
TARGET_ZSHRC="$HOME/.zshrc"
TARGET_ALIASES="$HOME/.zsh_aliases"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

echo "Starting macOS setup and zsh configuration..."

if [ ! -f "$MAC_SCRIPT" ]; then
  echo "Error: mac script not found at $MAC_SCRIPT"
  exit 1
fi

if [ ! -f "$SOURCE_ZSHRC" ]; then
  echo "Error: source .zshrc not found at $SOURCE_ZSHRC"
  exit 1
fi

if [ ! -f "$SOURCE_ALIASES" ]; then
  echo "Error: source .zsh_aliases not found at $SOURCE_ALIASES"
  exit 1
fi

echo "Running mac setup script..."
sh "$MAC_SCRIPT"

echo "Backing up existing zsh files (if present)..."
if [ -f "$TARGET_ZSHRC" ]; then
  cp "$TARGET_ZSHRC" "$TARGET_ZSHRC.backup.$TIMESTAMP"
fi

if [ -f "$TARGET_ALIASES" ]; then
  cp "$TARGET_ALIASES" "$TARGET_ALIASES.backup.$TIMESTAMP"
fi

echo "Installing zsh files..."
cp "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
cp "$SOURCE_ALIASES" "$TARGET_ALIASES"

if ! grep -Fqs 'source "$HOME/.zsh_aliases"' "$TARGET_ZSHRC"; then
  {
    echo ""
    echo "# Load custom aliases"
    echo 'source "$HOME/.zsh_aliases"'
  } >> "$TARGET_ZSHRC"
fi

echo "Setup complete."
echo "Restart your terminal or run: source ~/.zshrc"
