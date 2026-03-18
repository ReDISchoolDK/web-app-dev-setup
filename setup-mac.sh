#!/usr/bin/env bash

# ============================================================
# ReDI Web Development Course — macOS / Linux Setup
# ============================================================
#
# This script installs the tools you need for the course:
#   1. Git
#   2. Volta — a Node.js version manager
#   3. Node.js (LTS) — the JavaScript runtime
#   4. GitHub CLI (gh) — for working with GitHub from the terminal
#   5. VS Code — code editor
#   6. VS Code extensions — linting, formatting, Tailwind, Copilot
#
# It also configures Git so your personal email stays private.
#
# Safe to run multiple times — it skips anything already installed.
#
# Usage:
#   curl -fsSL <raw-url>/setup-mac.sh -o /tmp/setup.sh && bash /tmp/setup.sh
#
# ============================================================

# Stop the script if any command fails.
set -euo pipefail

# ── Helper functions for colored output ───────────────────────
green()  { echo -e "\033[0;32m  ✓ $1\033[0m"; }
yellow() { echo -e "\033[0;33m  → $1\033[0m"; }
red()    { echo -e "\033[0;31m  ✗ $1\033[0m"; }

echo ""
echo "========================================"
echo " ReDI Course Setup — macOS / Linux"
echo "========================================"
echo ""

# ── Detect operating system ───────────────────────────────────
# We need to know if this is macOS or Linux because they use
# different package managers.
OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
  PLATFORM="mac"
elif [[ "$OS" == "Linux" ]]; then
  PLATFORM="linux"
else
  red "Unsupported OS: $OS"
  echo "  On Windows, use setup-windows.ps1 instead."
  exit 1
fi

# ── 1. Install Git ───────────────────────────────────────────
echo "Checking Git..."
if command -v git &>/dev/null; then
  green "Git $(git --version | awk '{print $3}')"
else
  yellow "Installing Git..."

  if [[ "$PLATFORM" == "mac" ]]; then
    # On macOS we install Git via Homebrew. This also ensures Homebrew
    # is available for later steps (gh, VS Code).
    if ! command -v brew &>/dev/null; then
      yellow "Installing Homebrew first (macOS package manager)..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
      else
        eval "$(/usr/local/bin/brew shellenv)"       # Intel
      fi
    fi
    brew install git
  else
    sudo apt-get update -qq
    sudo apt-get install -y -qq git
  fi

  green "Git $(git --version | awk '{print $3}')"
fi

# ── 2. Install Volta ─────────────────────────────────────────
# Volta manages Node.js versions. It makes sure everyone on
# the team uses the same version of Node.
echo ""
echo "Checking Volta..."
if command -v volta &>/dev/null; then
  green "Volta $(volta --version)"
else
  yellow "Installing Volta..."
  # This downloads and runs the official Volta installer.
  # It adds Volta to your shell profile (~/.bashrc, ~/.zshrc, etc.).
  curl -fsSL https://get.volta.sh -o /tmp/volta-install.sh && bash /tmp/volta-install.sh

  # Make Volta available in this script right now
  # (normally you'd need to restart your terminal).
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"

  green "Volta $(volta --version)"
  echo "  Note: restart your terminal after this script for Volta to work everywhere."
fi

# ── 3. Install Node.js ───────────────────────────────────────
# Node.js is the JavaScript runtime. We install the LTS (Long-Term
# Support) release via Volta so the version is stable and managed
# automatically.
echo ""
echo "Checking Node.js..."
if command -v node &>/dev/null; then
  green "Node.js $(node --version)"
else
  yellow "Installing Node.js LTS via Volta..."
  volta install node@lts
  green "Node.js $(node --version)"
fi

# ── 4. Install GitHub CLI ────────────────────────────────────
# The GitHub CLI lets you log into GitHub from the terminal,
# which also sets up Git credentials for pushing code.
# We install and authenticate here, before configuring email,
# so we can fetch your numeric GitHub user ID to build the
# correct noreply address.
echo ""
echo "Checking GitHub CLI..."

if command -v gh &>/dev/null; then
  green "GitHub CLI $(gh --version | head -1 | awk '{print $3}')"
else
  yellow "Installing GitHub CLI..."

  if [[ "$PLATFORM" == "mac" ]]; then
    # On macOS we use Homebrew. If it's not installed, we install it first.
    if ! command -v brew &>/dev/null; then
      yellow "Installing Homebrew first (macOS package manager)..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Make brew available in this script right now.
      if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
      else
        eval "$(/usr/local/bin/brew shellenv)"       # Intel
      fi
    fi
    brew install gh
  else
    # On Linux we add GitHub's official package repository and install via apt.
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq gh
  fi

  green "GitHub CLI $(gh --version | head -1 | awk '{print $3}')"
fi

# ── 5. GitHub authentication ─────────────────────────────────
# Log in if we aren't already. We do this before setting up email
# so we can call the API to get the correct noreply address.
echo ""
if ! gh auth status &>/dev/null; then
  echo "========================================"
  echo " GitHub login"
  echo "========================================"
  echo ""
  echo "Let's log you into GitHub."
  echo "Follow the prompts — it will open your browser."
  echo ""
  gh auth login
else
  green "GitHub CLI already authenticated"
fi

# ── 6. Install VS Code ──────────────────────────────────────
# VS Code is the code editor we use in this course.
echo ""
echo "Checking VS Code..."
if command -v code &>/dev/null; then
  green "VS Code"
else
  yellow "Installing VS Code..."

  if [[ "$PLATFORM" == "mac" ]]; then
    # On macOS we use Homebrew casks for GUI apps.
    if ! command -v brew &>/dev/null; then
      yellow "Installing Homebrew first (macOS package manager)..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
      else
        eval "$(/usr/local/bin/brew shellenv)"       # Intel
      fi
    fi
    brew install --cask visual-studio-code
  else
    # On Linux (Debian/Ubuntu) we add Microsoft's official apt repository.
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
      | sudo gpg --yes --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
      | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq code
  fi

  if command -v code &>/dev/null; then
    green "VS Code"
  else
    red "VS Code installation failed."
    echo "  Download it manually from https://code.visualstudio.com/"
    echo "  After installing, re-run this script to install extensions."
  fi
fi

# ── 7. VS Code extensions ────────────────────────────────────
# These extensions help with code quality and productivity.
# If VS Code isn't installed, we skip this step.
echo ""
echo "Checking VS Code extensions..."
if command -v code &>/dev/null; then
  echo ""
  echo "Installing VS Code extensions..."

  # List of extensions for the course:
  #   - ESLint: catches code errors
  #   - Prettier: auto-formats your code
  #   - Tailwind CSS IntelliSense: autocomplete for Tailwind classes
  #   - GitHub Copilot: AI coding assistant
  #   - GitHub Copilot Chat: chat with Copilot
  EXTENSIONS=(
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "bradlc.vscode-tailwindcss"
    "GitHub.copilot"
    "GitHub.copilot-chat"
  )

  # Get the list of already-installed extensions once,
  # so we don't check one by one (faster).
  INSTALLED=$(code --list-extensions 2>/dev/null || echo "")

  for ext in "${EXTENSIONS[@]}"; do
    if echo "$INSTALLED" | grep -qi "^${ext}$"; then
      green "$ext (already installed)"
    else
      yellow "Installing $ext..."
      code --install-extension "$ext" --force &>/dev/null
      green "$ext"
    fi
  done
else
  red "VS Code not found."
  echo "  Download it from https://code.visualstudio.com/"
  echo "  After installing, re-run this script to install extensions."
fi

# ── 8. Configure Git email privacy ───────────────────────────
# GitHub provides a private noreply email address for each account.
# For accounts created after July 2017 (almost everyone) it has the
# form:  ID+USERNAME@users.noreply.github.com
# where ID is a numeric user ID.
#
# We fetch that ID from the GitHub API so the address is correct —
# using only the username (without the ID) will be rejected by
# GitHub when "Block command line pushes" is enabled.
echo ""
echo "========================================"
echo " Git email privacy setup"
echo "========================================"
echo ""
echo "We'll configure Git so your personal email stays private."
echo "Your commits will use GitHub's noreply email instead."
echo ""

# Ask for the student's full name (used in commit messages).
read -rp "  Enter your full name: " STUDENT_NAME

# Fetch the GitHub username and numeric user ID from the CLI.
# This requires the gh auth step above to have succeeded.
GITHUB_USERNAME=$(gh api user --jq '.login') || true
GITHUB_USER_ID=$(gh api user --jq '.id') || true

if [[ -z "$GITHUB_USERNAME" || -z "$GITHUB_USER_ID" ]]; then
  red "Could not fetch your GitHub info. Are you logged in?"
  echo "  Run: gh auth login"
  exit 1
fi

# Build the correct ID-based noreply address.
NOREPLY_EMAIL="${GITHUB_USER_ID}+${GITHUB_USERNAME}@users.noreply.github.com"

git config --global user.name  "$STUDENT_NAME"
git config --global user.email "$NOREPLY_EMAIL"

green "Git name set to:  $STUDENT_NAME"
green "Git email set to: $NOREPLY_EMAIL"

echo ""
echo "  IMPORTANT: Also do this on GitHub's website:"
echo "  1. Go to https://github.com/settings/emails"
echo "  2. Check 'Keep my email addresses private'"
echo "  3. Check 'Block command line pushes that expose my email'"
echo ""

# ── Done! ─────────────────────────────────────────────────────
echo "========================================"
echo " Summary"
echo "========================================"
echo ""
command -v git   &>/dev/null && green "Git"        || red "Git"
command -v volta &>/dev/null && green "Volta"      || red "Volta"
command -v node  &>/dev/null && green "Node.js"    || red "Node.js"
command -v gh    &>/dev/null && green "GitHub CLI" || red "GitHub CLI"
command -v code  &>/dev/null && green "VS Code"    || red "VS Code"
echo ""
echo "  Git name:  $(git config --global user.name)"
echo "  Git email: $(git config --global user.email)"
echo ""
echo "========================================"
echo " Next steps"
echo "========================================"
echo ""
echo "  1. Make sure email privacy is enabled on GitHub:"
echo "     https://github.com/settings/emails"
echo "     - Check 'Keep my email addresses private'"
echo "     - Check 'Block command line pushes that expose my email'"
echo ""
echo "  2. Post your GitHub username in the course Slack channel:"
echo "     Your username is:  $GITHUB_USERNAME"
echo ""
echo "  Once we add you, you'll get an invite to make"
echo "  your first Pull Request!"
echo ""