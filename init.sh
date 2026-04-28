#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLORS_JS="$SCRIPT_DIR/colors.js"
BIN_DIR="$HOME/.local/bin"
BASHRC="$HOME/.bashrc"

echo "setting up colors palette..."

# 1. Create hard link in $HOME
if [ ! -f "$HOME/colors.js" ]; then
  ln "$COLORS_JS" "$HOME/colors.js"
  echo "  ✓ Hard link created: ~/colors.js -> $COLORS_JS"
else
  echo "  ~ ~/colors.js already exists, skipping"
fi

# 2. Install the colors command
mkdir -p "$BIN_DIR"
if [ ! -f "$BIN_DIR/colors" ]; then
  cat >"$BIN_DIR/colors" <<'EOF'
#!/bin/bash
nvim $HOME/colors.js
EOF
  chmod +x "$BIN_DIR/colors"
  echo "  ✓ Installed: $BIN_DIR/colors"
else
  echo "  ~ $BIN_DIR/colors already exists, skipping"
fi

# 3. Ensure ~/.local/bin is in PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo "" >>"$BASHRC"
  echo "# local bin" >>"$BASHRC"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$BASHRC"
  echo "  ✓ Added ~/.local/bin to PATH in .bashrc"
fi

# 4. Add aliases and completion if not present
ALIASES=(
  "complete -W \"colors\" col"
  "alias col='colors'"
  "alias palette='colors'"
  "alias pallete='colors'"
)

MARKER="# colors-palette aliases"

if ! grep -q "$MARKER" "$BASHRC"; then
  echo "" >>"$BASHRC"
  echo "$MARKER" >>"$BASHRC"
  for alias_line in "${ALIASES[@]}"; do
    echo "$alias_line" >>"$BASHRC"
  done
  echo "added to .bashrc"
else
  echo "already present in .bashrc, skipped"
fi

echo ""
echo "done, Run 'source ~/.bashrc' or open a new terminal."
