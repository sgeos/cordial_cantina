#!/bin/sh
#
# setup.sh
#
# Sets up the development environment for Cordial Cantina.
# Run this script after cloning the repository.
#
# Usage: ./scripts/setup.sh

set -e

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "Setting up Cordial Cantina development environment..."
echo "Repository root: $REPO_ROOT"
echo ""

# Install git hooks
echo "Installing git hooks..."
if [ -d "$REPO_ROOT/.git/hooks" ]; then
    ln -sf ../../hooks/pre-commit "$REPO_ROOT/.git/hooks/pre-commit"
    chmod +x "$REPO_ROOT/hooks/pre-commit"
    echo "  Installed pre-commit hook"
else
    echo "  Warning: .git/hooks directory not found. Are you in a git repository?"
fi
echo ""

# Make scripts executable
echo "Making scripts executable..."
chmod +x "$REPO_ROOT/scripts/"*.sh 2>/dev/null || true
echo "  Done"
echo ""

# Check for required tools
echo "Checking dependencies..."

# Check for git
if command -v git >/dev/null 2>&1; then
    echo "  git: $(git --version)"
else
    echo "  ERROR: git not found. Install git to use this repository."
fi

# Check for gh (GitHub CLI)
if command -v gh >/dev/null 2>&1; then
    echo "  gh: $(gh --version | head -1)"
    if gh auth status >/dev/null 2>&1; then
        echo "  gh auth: authenticated"
    else
        echo "  gh auth: not authenticated (run 'gh auth login')"
    fi
else
    echo "  Warning: gh (GitHub CLI) not found. Install gh for issue management."
    echo "           https://cli.github.com/"
fi

# Check for Elixir
if command -v elixir >/dev/null 2>&1; then
    echo "  Elixir: $(elixir --version | head -1)"
else
    echo "  Warning: Elixir not found. Install Elixir to work on the Phoenix app."
fi

# Check for Rust
if command -v cargo >/dev/null 2>&1; then
    echo "  Rust: $(cargo --version)"
else
    echo "  Warning: Rust not found. Install Rust to work on the joltshark crate."
fi
echo ""

# Install Elixir dependencies if mix is available
if command -v mix >/dev/null 2>&1; then
    echo "Installing Elixir dependencies..."
    cd "$REPO_ROOT/cordial_cantina"
    mix deps.get
    echo ""
fi

echo "Setup complete."
echo ""
echo "Next steps:"
echo "  1. Review docs/README.md for documentation"
echo "  2. Run 'cd cordial_cantina && mix precommit' to verify setup"
echo "  3. Run 'cd cordial_cantina && mix phx.server' to start the app"
echo ""
echo "Optional: Review docs/reference/MASTER_CLAUDE_MD_REFERENCE.md"
echo "          for Claude Code configuration recommendations."
