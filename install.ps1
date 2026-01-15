# Vue 2 to Vue 3 Migration Tool Installer for Windows
# Installs Vue migration agents for: Claude Code, GitHub Copilot, Codex, Gemini, OpenCode

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$TargetPath,

    [ValidateSet("claude", "copilot", "codex", "gemini", "opencode", "all", "")]
    [string]$Platform = ""
)

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Banner {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "       Vue 2 to Vue 3 Migration Tool Installer" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step($message) {
    Write-Host "> " -ForegroundColor Blue -NoNewline
    Write-Host $message
}

function Write-Success($message) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $message
}

function Write-ErrorMsg($message) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host $message
}

function Show-Menu {
    Write-Host ""
    Write-Host "Select your AI coding assistant:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1) Claude Code      - Anthropic's CLI tool"
    Write-Host "  2) GitHub Copilot   - GitHub's AI assistant"
    Write-Host "  3) Codex            - OpenAI's Codex CLI"
    Write-Host "  4) Gemini           - Google's Gemini CLI"
    Write-Host "  5) OpenCode         - Open source AI CLI"
    Write-Host "  6) All              - Install for all platforms"
    Write-Host ""
    Write-Host "  0) Exit"
    Write-Host ""

    $choice = Read-Host "Enter your choice [1-6]"
    return $choice
}

function Install-ClaudeCode {
    Write-Step "Installing for Claude Code..."

    $agentsDir = Join-Path $TargetPath ".claude\agents"
    $commandsDir = Join-Path $TargetPath ".claude\commands"

    New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
    New-Item -ItemType Directory -Force -Path $commandsDir | Out-Null

    $sourceAgents = Join-Path $ScriptDir "platforms\claude-code\agents\*.md"
    $sourceCommands = Join-Path $ScriptDir "platforms\claude-code\commands\*.md"

    if (Test-Path $sourceAgents) {
        Get-ChildItem $sourceAgents | Copy-Item -Destination $agentsDir -Force
    }
    if (Test-Path $sourceCommands) {
        Get-ChildItem $sourceCommands | Copy-Item -Destination $commandsDir -Force
    }

    Write-Success "Claude Code configuration installed"
    Write-Host "    Agents:   $agentsDir"
    Write-Host "    Commands: $commandsDir"
    Write-Host ""
    Write-Host "    Usage: Run " -NoNewline
    Write-Host "/vue-migrate" -ForegroundColor Yellow -NoNewline
    Write-Host " in Claude Code"
}

function Install-GitHubCopilot {
    Write-Step "Installing for GitHub Copilot..."

    $githubDir = Join-Path $TargetPath ".github"
    New-Item -ItemType Directory -Force -Path $githubDir | Out-Null

    $source = Join-Path $ScriptDir "platforms\github-copilot\copilot-instructions.md"
    if (Test-Path $source) {
        Copy-Item $source -Destination $githubDir -Force
    }

    Write-Success "GitHub Copilot configuration installed"
    Write-Host "    Instructions: $githubDir\copilot-instructions.md"
    Write-Host ""
    Write-Host "    Usage: Ask Copilot to 'migrate to Vue 3'"
}

function Install-Codex {
    Write-Step "Installing for Codex CLI..."

    $codexDir = Join-Path $TargetPath ".codex"
    New-Item -ItemType Directory -Force -Path $codexDir | Out-Null

    $source = Join-Path $ScriptDir "platforms\codex\instructions.md"
    if (Test-Path $source) {
        Copy-Item $source -Destination $codexDir -Force
    }

    Write-Success "Codex CLI configuration installed"
    Write-Host "    Instructions: $codexDir\instructions.md"
    Write-Host ""
    Write-Host "    Usage: Ask Codex to 'migrate to Vue 3'"
}

function Install-Gemini {
    Write-Step "Installing for Gemini CLI..."

    $geminiDir = Join-Path $TargetPath ".gemini"
    New-Item -ItemType Directory -Force -Path $geminiDir | Out-Null

    $source = Join-Path $ScriptDir "platforms\gemini\GEMINI.md"
    if (Test-Path $source) {
        Copy-Item $source -Destination $geminiDir -Force
    }

    Write-Success "Gemini CLI configuration installed"
    Write-Host "    Instructions: $geminiDir\GEMINI.md"
    Write-Host ""
    Write-Host "    Usage: Ask Gemini to 'migrate to Vue 3'"
}

function Install-OpenCode {
    Write-Step "Installing for OpenCode..."

    $opencodeDir = Join-Path $TargetPath ".opencode\agents"
    New-Item -ItemType Directory -Force -Path $opencodeDir | Out-Null

    $source = Join-Path $ScriptDir "platforms\opencode\agents\*.md"
    if (Test-Path $source) {
        Get-ChildItem $source | Copy-Item -Destination $opencodeDir -Force
    }

    Write-Success "OpenCode configuration installed"
    Write-Host "    Agents: $opencodeDir"
    Write-Host ""
    Write-Host "    Usage: Ask OpenCode to 'migrate vue'"
}

function Install-All {
    Write-Step "Installing for all platforms..."
    Write-Host ""
    Install-ClaudeCode
    Write-Host ""
    Install-GitHubCopilot
    Write-Host ""
    Install-Codex
    Write-Host ""
    Install-Gemini
    Write-Host ""
    Install-OpenCode
}

function Write-FinalInstructions {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "Installation complete!" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Open your Vue 2 project in your AI assistant"
    Write-Host "  2. Ask it to migrate your project to Vue 3"
    Write-Host "  3. Review and approve the migration plan"
    Write-Host "  4. Let the assistant execute the migration"
    Write-Host ""
}

# Main
function Main {
    Write-Banner

    # Check if platforms directory exists
    $platformsDir = Join-Path $ScriptDir "platforms"
    if (-not (Test-Path $platformsDir)) {
        Write-ErrorMsg "Platforms directory not found."
        Write-Host "Make sure you are running this script from the vue-agent-migrator directory."
        exit 1
    }

    # Validate and resolve target path
    if (-not (Test-Path $TargetPath)) {
        Write-ErrorMsg "Target directory does not exist: $TargetPath"
        Write-Host ""
        Write-Host "Usage:"
        Write-Host "  .\install.ps1 <path-to-vue2-project>"
        Write-Host ""
        Write-Host "Example:"
        Write-Host "  .\install.ps1 C:\Projects\my-vue-app"
        exit 1
    }

    $script:TargetPath = Resolve-Path $TargetPath

    Write-Host "Target directory: " -NoNewline
    Write-Host $TargetPath -ForegroundColor Cyan

    # If platform specified via parameter, use it
    if ($Platform) {
        switch ($Platform) {
            "claude" { Install-ClaudeCode }
            "copilot" { Install-GitHubCopilot }
            "codex" { Install-Codex }
            "gemini" { Install-Gemini }
            "opencode" { Install-OpenCode }
            "all" { Install-All }
        }
        Write-FinalInstructions
        return
    }

    # Interactive menu
    $choice = Show-Menu

    switch ($choice) {
        "1" { Install-ClaudeCode }
        "2" { Install-GitHubCopilot }
        "3" { Install-Codex }
        "4" { Install-Gemini }
        "5" { Install-OpenCode }
        "6" { Install-All }
        "0" {
            Write-Host "Exiting..."
            exit 0
        }
        default {
            Write-ErrorMsg "Invalid choice. Please run the script again."
            exit 1
        }
    }

    Write-FinalInstructions
}

# Run
Main
