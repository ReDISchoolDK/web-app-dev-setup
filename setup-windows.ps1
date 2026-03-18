# ============================================================
# ReDI Web Development Course — Windows Setup
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
# Uses winget (Windows Package Manager), which is built into
# Windows 10 and 11.
#
# Safe to run multiple times — it skips anything already installed.
#
# Usage (run in PowerShell):
#   irm <raw-url>/setup-windows.ps1 | iex
#
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Helper functions for colored output ───────────────────────

function Write-Ok   { param($msg) Write-Host "   $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "   $msg" -ForegroundColor Yellow }
function Write-Fail { param($msg) Write-Host "   $msg" -ForegroundColor Red }

# Check if a command exists on this system.
function Test-Command { param($cmd) $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue) }

# After installing something with winget, the PATH doesn't update
# in the current session. This function refreshes it.
function Update-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

$needsRerun = $false
$githubUsername = $null

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host " ReDI Course Setup — Windows" -ForegroundColor White
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# ── Check winget ──────────────────────────────────────────────
# winget is the Windows package manager. It comes with Windows 10/11.
# If it's missing, the student needs to update Windows or install
# "App Installer" from the Microsoft Store.
if (-not (Test-Command "winget")) {
    Write-Fail "winget not found."
    Write-Host "  Install 'App Installer' from the Microsoft Store,"
    Write-Host "  or update Windows to the latest version."
    exit 1
}

# ── 1. Install Git ───────────────────────────────────────────
Write-Host "Checking Git..." -ForegroundColor White
if (Test-Command "git") {
    Write-Ok "Git $(git --version)"
} else {
    Write-Info "Installing Git..."
    winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
    Update-Path

    if (Test-Command "git") {
        Write-Ok "Git $(git --version)"
    } else {
        Write-Info "Git installed — not yet visible in this session."
        $needsRerun = $true
    }
}

# ── 2. Install Volta ─────────────────────────────────────────
# Volta manages Node.js versions. It makes sure everyone on
# the team uses the same version of Node.
Write-Host ""
Write-Host "Checking Volta..." -ForegroundColor White
if (Test-Command "volta") {
    Write-Ok "Volta $(volta --version)"
} else {
    Write-Info "Installing Volta..."
    winget install --id Volta.Volta -e --accept-source-agreements --accept-package-agreements
    Update-Path

    if (Test-Command "volta") {
        Write-Ok "Volta $(volta --version)"
    } else {
        Write-Info "Volta installed — not yet visible in this session."
        $needsRerun = $true
    }
}

# ── 3. Install Node.js ───────────────────────────────────────
# Node.js is the JavaScript runtime. We install the LTS (Long-Term
# Support) release via Volta so the version is stable and managed
# automatically.
Write-Host ""
Write-Host "Checking Node.js..." -ForegroundColor White
if (Test-Command "node") {
    Write-Ok "Node.js $(node --version)"
} elseif (Test-Command "volta") {
    Write-Info "Installing Node.js LTS via Volta..."
    volta install node@lts
    Write-Ok "Node.js $(node --version)"
} else {
    Write-Info "Skipping Node.js — needs Volta (will be set up on re-run)."
}

# ── 4. Install GitHub CLI ────────────────────────────────────
# The GitHub CLI lets you log into GitHub from the terminal,
# which also sets up Git credentials for pushing code.
# We install and authenticate here, before configuring email,
# so we can fetch your numeric GitHub user ID to build the
# correct noreply address.
Write-Host ""
Write-Host "Checking GitHub CLI..." -ForegroundColor White
if (Test-Command "gh") {
    Write-Ok "GitHub CLI $(gh --version | Select-Object -First 1)"
} else {
    Write-Info "Installing GitHub CLI..."
    winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements
    Update-Path

    if (Test-Command "gh") {
        Write-Ok "GitHub CLI $(gh --version | Select-Object -First 1)"
    } else {
        Write-Info "GitHub CLI installed — not yet visible in this session."
        $needsRerun = $true
    }
}

# ── 5. GitHub authentication ─────────────────────────────────
# Log in if we aren't already. We do this before setting up email
# so we can call the API to get the correct noreply address.
Write-Host ""
if (Test-Command "gh") {
    $ghStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "========================================" -ForegroundColor White
        Write-Host " GitHub login" -ForegroundColor White
        Write-Host "========================================" -ForegroundColor White
        Write-Host ""
        Write-Host "Let's log you into GitHub."
        Write-Host "You'll be asked a few questions — pick these options:"
        Write-Host ""
        Write-Host "  - Where do you use GitHub?       -> GitHub.com"
        Write-Host "  - Preferred protocol?             -> HTTPS"
        Write-Host "  - Authenticate Git with GitHub?   -> Yes"
        Write-Host "  - How to authenticate?            -> Login with a web browser"
        Write-Host ""
        gh auth login
    } else {
        Write-Ok "GitHub CLI already authenticated"
    }
} else {
    Write-Info "Skipping GitHub login — needs GitHub CLI (will be set up on re-run)."
}

# ── 6. Check VS Code ─────────────────────────────────────────
# VS Code is the code editor we use in this course.
Write-Host ""
Write-Host "Checking VS Code..." -ForegroundColor White
if (Test-Command "code") {
    Write-Ok "VS Code"
} else {
    Write-Info "Installing VS Code..."
    winget install --id Microsoft.VisualStudioCode -e --accept-source-agreements --accept-package-agreements
    Update-Path

    if (Test-Command "code") {
        Write-Ok "VS Code"
    } else {
        Write-Info "VS Code installed — not yet visible in this session."
        $needsRerun = $true
    }
}

# ── 7. VS Code extensions ────────────────────────────────────
# These extensions help with code quality and productivity.
Write-Host ""
Write-Host "Installing VS Code extensions..." -ForegroundColor White
if (Test-Command "code") {

    # List of extensions for the course:
    #   - ESLint: catches code errors
    #   - Prettier: auto-formats your code
    #   - Tailwind CSS IntelliSense: autocomplete for Tailwind classes
    #   - GitHub Copilot: AI coding assistant
    #   - GitHub Copilot Chat: chat with Copilot
    $extensions = @(
        "dbaeumer.vscode-eslint"
        "esbenp.prettier-vscode"
        "bradlc.vscode-tailwindcss"
        "GitHub.copilot"
        "GitHub.copilot-chat"
    )

    # Get the installed extensions as an array (one entry per line).
    # We split on newlines to get exact IDs for comparison — using
    # -match on the raw string would treat dots as regex wildcards
    # and could produce false positives (e.g. "dbaeumerXvscode-eslint").
    [string[]]$installed = @(code --list-extensions 2>$null)

    foreach ($ext in $extensions) {
        # Case-insensitive exact match against the array of IDs.
        if ($installed -icontains $ext) {
            Write-Ok "$ext (already installed)"
        } else {
            Write-Info "Installing $ext..."
            code --install-extension $ext --force 2>$null | Out-Null
            Write-Ok $ext
        }
    }
} else {
    Write-Fail "VS Code not found — install it, then re-run this script."
}

# ── 8. Configure Git email privacy ───────────────────────────
# GitHub provides a private noreply email address for each account.
# For accounts created after July 2017 (almost everyone) it has the
# form:  ID+USERNAME@users.noreply.github.com
# where ID is a numeric user ID.
#
# We fetch that ID from the GitHub API so the address is correct —
# using only the username (without the ID) will be rejected by
# GitHub when "Block command line pushes" is enabled.
Write-Host ""
if ((Test-Command "git") -and (Test-Command "gh")) {
    Write-Host "========================================" -ForegroundColor White
    Write-Host " Git email privacy setup" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor White
    Write-Host ""
    Write-Host "We'll configure Git so your personal email stays private."
    Write-Host "Your commits will use GitHub's noreply email instead."
    Write-Host ""

    # Ask for the student's full name (used in commit messages).
    $studentName = Read-Host "  Enter your full name"

    # Fetch the GitHub username and numeric user ID from the CLI.
    # If the API call fails (e.g. bad credentials), re-run login
    # and try again instead of making the student restart.
    # PowerShell treats native-command stderr as a terminating error
    # when ErrorActionPreference is "Stop", so we use try/catch.
    try {
        $githubUsername = gh api user --jq '.login' 2>$null
    } catch {
        $githubUsername = $null
    }
    try {
        $githubUserId = gh api user --jq '.id' 2>$null
    } catch {
        $githubUserId = $null
    }

    if (-not $githubUsername -or -not $githubUserId) {
        Write-Info "GitHub session expired or invalid — let's log in again."
        gh auth login
        try {
            $githubUsername = gh api user --jq '.login' 2>$null
        } catch {
            $githubUsername = $null
        }
        try {
            $githubUserId = gh api user --jq '.id' 2>$null
        } catch {
            $githubUserId = $null
        }
    }

    if (-not $githubUsername -or -not $githubUserId) {
        Write-Fail "Still could not fetch your GitHub info."
        Write-Host "  Try running this setup script again."
        exit 1
    }

    # Build the correct ID-based noreply address.
    $noreplyEmail = "$githubUserId+$githubUsername@users.noreply.github.com"

    git config --global user.name  $studentName
    git config --global user.email $noreplyEmail

    Write-Ok "Git name set to:  $studentName"
    Write-Ok "Git email set to: $noreplyEmail"

    Write-Host ""
    Write-Host "  IMPORTANT: Also do this on GitHub's website:" -ForegroundColor Yellow
    Write-Host "  1. Go to https://github.com/settings/emails"
    Write-Host "  2. Check 'Keep my email addresses private'"
    Write-Host "  3. Check 'Block command line pushes that expose my email'"
    Write-Host ""
} else {
    Write-Info "Skipping Git email setup — needs Git and GitHub CLI (will be set up on re-run)."
}

# ── Done! ─────────────────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host " Summary" -ForegroundColor White
Write-Host "========================================" -ForegroundColor White
Write-Host ""
if (Test-Command "git")   { Write-Ok "Git" }        else { Write-Fail "Git" }
if (Test-Command "volta") { Write-Ok "Volta" }      else { Write-Fail "Volta" }
if (Test-Command "node")  { Write-Ok "Node.js" }    else { Write-Fail "Node.js" }
if (Test-Command "gh")    { Write-Ok "GitHub CLI" } else { Write-Fail "GitHub CLI" }
if (Test-Command "code")  { Write-Ok "VS Code" }    else { Write-Fail "VS Code" }

if ($githubUsername) {
    Write-Host ""
    Write-Host "  Git name:  $(git config --global user.name)"
    Write-Host "  Git email: $(git config --global user.email)"
}

if ($needsRerun) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host " Almost there!" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Some tools were installed but aren't visible yet."
    Write-Host "  Close this terminal, open a new one, and run"
    Write-Host "  the same setup command again. It will pick up"
    Write-Host "  where it left off."
    Write-Host ""
} elseif ($githubUsername) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor White
    Write-Host " Next steps" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. Make sure email privacy is enabled on GitHub:"
    Write-Host "     https://github.com/settings/emails" -ForegroundColor Cyan
    Write-Host "     - Check 'Keep my email addresses private'"
    Write-Host "     - Check 'Block command line pushes that expose my email'"
    Write-Host ""
    Write-Host "  2. Post your GitHub username in the course Slack channel:"
    Write-Host "     Your username is:  $githubUsername"
    Write-Host ""
    Write-Host "  Once we add you, you'll get an invite to make"
    Write-Host "  your first Pull Request!"
    Write-Host ""
}