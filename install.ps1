# Vue 2 to Vue 3 Migration Tool Installer for Windows
# Installs Vue migration agents for: Claude Code, GitHub Copilot, Codex, Gemini, OpenCode

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$TargetPath,

    [ValidateSet("claude", "copilot", "codex", "gemini", "opencode", "cursor", "antigravity", "all", "")]
    [string]$Platform = ""
)

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Symbols (using [char] codes for safe cross-locale rendering)
$SYMBOL_SUCCESS = [char]0x2713  # checkmark
$SYMBOL_ERROR   = [char]0x2717  # X mark
$SYMBOL_ARROW   = [char]0x25B6  # play arrow
$SYMBOL_DOT     = [char]0x25CF  # filled circle
$SYMBOL_CHECK   = [char]0x2714  # heavy checkmark
$SYMBOL_STAR    = [char]0x2605  # star

function Write-Banner {
    Write-Host ""
    Write-Host "  ===========================================================" -ForegroundColor Cyan
    Write-Host "    " -NoNewline
    Write-Host "VUE MIGRATION TOOL" -ForegroundColor Green -NoNewline
    Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
    Write-Host "Vue 2" -ForegroundColor Yellow -NoNewline
    Write-Host " => " -ForegroundColor DarkGray -NoNewline
    Write-Host "Vue 3" -ForegroundColor Green -NoNewline
    Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
    Write-Host "v1.0" -ForegroundColor DarkGray
    Write-Host "  ===========================================================" -ForegroundColor Cyan
}

function Write-Step($message) {
    Write-Host "[" -ForegroundColor Cyan -NoNewline
    Write-Host $SYMBOL_ARROW -ForegroundColor Blue -NoNewline
    Write-Host "] " -ForegroundColor Cyan -NoNewline
    Write-Host $message
}

function Write-Success($message) {
    Write-Host "[" -ForegroundColor Cyan -NoNewline
    Write-Host $SYMBOL_SUCCESS -ForegroundColor Green -NoNewline
    Write-Host "] " -ForegroundColor Cyan -NoNewline
    Write-Host $message -ForegroundColor Green
}

function Write-ErrorMsg($message) {
    Write-Host "[" -ForegroundColor Cyan -NoNewline
    Write-Host $SYMBOL_ERROR -ForegroundColor Red -NoNewline
    Write-Host "] " -ForegroundColor Cyan -NoNewline
    Write-Host $message -ForegroundColor Red
}

function Write-Info($message) {
    Write-Host "    $SYMBOL_DOT " -ForegroundColor DarkGray -NoNewline
    Write-Host $message
}

# ─────────────────────────────────────────────────────────────────────────────
# Interactive checkbox menu using Console API (no scroll, in-place redraw)
# ─────────────────────────────────────────────────────────────────────────────
function Show-CheckboxMenu {
    # Platform definitions
    $names  = @("claude",           "copilot",          "codex",            "gemini",           "opencode",         "cursor",           "antigravity")
    $labels = @("Claude Code",      "GitHub Copilot",   "Codex CLI",        "Gemini CLI",       "OpenCode",         "Cursor",           "Antigravity")
    $descs  = @("Anthropic's CLI",  "GitHub's AI",      "OpenAI's Codex",   "Google's Gemini",  "Open source AI",   "Cursor editor",    "Google's Antigravity")
    $checked = @($false,            $false,             $false,             $false,             $false,             $false,             $false)

    $count  = $names.Count
    $cursor = 0

    # Print static header (written once, never redrawn)
    Write-Host ""
    Write-Host "  -----------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "    $SYMBOL_STAR " -ForegroundColor Yellow -NoNewline
    Write-Host "SELECT PLATFORMS TO INSTALL" -ForegroundColor White
    Write-Host "  -----------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    Up/Down " -ForegroundColor DarkGray -NoNewline
    Write-Host "Navigate" -ForegroundColor Gray -NoNewline
    Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
    Write-Host "Space " -ForegroundColor DarkGray -NoNewline
    Write-Host "Toggle" -ForegroundColor Gray -NoNewline
    Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
    Write-Host "A " -ForegroundColor DarkGray -NoNewline
    Write-Host "All" -ForegroundColor Gray -NoNewline
    Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
    Write-Host "Enter " -ForegroundColor DarkGray -NoNewline
    Write-Host "Install" -ForegroundColor Gray -NoNewline
    Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
    Write-Host "Esc " -ForegroundColor DarkGray -NoNewline
    Write-Host "Exit" -ForegroundColor Gray
    Write-Host ""

    # Save cursor position where the dynamic menu starts
    $menuTop = [Console]::CursorTop

    # Reserve space: 5 options + 1 blank + 1 status line = 7 lines
    for ($i = 0; $i -lt ($count + 2); $i++) { Write-Host "" }

    [Console]::CursorVisible = $false

    try {
        while ($true) {
            # ── Redraw menu in-place ──
            [Console]::SetCursorPosition(0, $menuTop)

            for ($i = 0; $i -lt $count; $i++) {
                $isCursor = ($i -eq $cursor)

                # Pointer
                if ($isCursor) {
                    Write-Host "  > " -ForegroundColor Cyan -NoNewline
                } else {
                    Write-Host "    " -NoNewline
                }

                # Checkbox
                if ($checked[$i]) {
                    Write-Host "[X]" -ForegroundColor Green -NoNewline
                } else {
                    Write-Host "[ ]" -ForegroundColor DarkGray -NoNewline
                }

                # Label + description
                $paddedLabel = $labels[$i].PadRight(18)
                if ($isCursor) {
                    Write-Host " $paddedLabel" -ForegroundColor White -NoNewline
                    Write-Host $descs[$i] -ForegroundColor Gray
                } else {
                    Write-Host " $paddedLabel" -ForegroundColor Gray -NoNewline
                    Write-Host $descs[$i] -ForegroundColor DarkGray
                }
            }

            # Status line
            $selectedCount = 0
            for ($i = 0; $i -lt $count; $i++) { if ($checked[$i]) { $selectedCount++ } }

            Write-Host ""
            if ($selectedCount -gt 0) {
                Write-Host "    $selectedCount selected  " -ForegroundColor Yellow -NoNewline
                Write-Host "- press Enter to install   " -ForegroundColor DarkGray
            } else {
                Write-Host "    No platforms selected                  " -ForegroundColor DarkGray
            }

            # ── Read key ──
            $key = [Console]::ReadKey($true)

            switch ($key.Key) {
                "UpArrow" {
                    if ($cursor -gt 0) { $cursor-- } else { $cursor = $count - 1 }
                }
                "DownArrow" {
                    if ($cursor -lt ($count - 1)) { $cursor++ } else { $cursor = 0 }
                }
                "Spacebar" {
                    $checked[$cursor] = -not $checked[$cursor]
                }
                "A" {
                    # Toggle all: if all checked -> uncheck all, else check all
                    $allChecked = $true
                    for ($i = 0; $i -lt $count; $i++) { if (-not $checked[$i]) { $allChecked = $false; break } }
                    $newVal = -not $allChecked
                    for ($i = 0; $i -lt $count; $i++) { $checked[$i] = $newVal }
                }
                "Enter" {
                    $selected = @()
                    for ($i = 0; $i -lt $count; $i++) {
                        if ($checked[$i]) { $selected += $names[$i] }
                    }
                    # Move cursor below the menu area
                    [Console]::SetCursorPosition(0, $menuTop + $count + 2)
                    Write-Host ""
                    return ,$selected
                }
                "Escape" {
                    [Console]::SetCursorPosition(0, $menuTop + $count + 2)
                    Write-Host ""
                    return ,@()
                }
            }
        }
    } finally {
        [Console]::CursorVisible = $true
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# Installation functions
# ─────────────────────────────────────────────────────────────────────────────

function Install-ClaudeCode {
    Write-Host ""
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "    Installing " -ForegroundColor Blue -NoNewline
    Write-Host "Claude Code" -ForegroundColor White
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""

    Write-Step "Creating directories..."
    $agentsDir = Join-Path $TargetPath ".claude\agents"
    $commandsDir = Join-Path $TargetPath ".claude\commands"
    New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
    New-Item -ItemType Directory -Force -Path $commandsDir | Out-Null
    Start-Sleep -Milliseconds 300

    Write-Step "Copying agent files..."
    $sourceAgents = Join-Path $ScriptDir "platforms\claude-code\agents\*.md"
    if (Test-Path $sourceAgents) {
        Get-ChildItem $sourceAgents | Copy-Item -Destination $agentsDir -Force
    }
    Start-Sleep -Milliseconds 200

    Write-Step "Copying command files..."
    $sourceCommands = Join-Path $ScriptDir "platforms\claude-code\commands\*.md"
    if (Test-Path $sourceCommands) {
        Get-ChildItem $sourceCommands | Copy-Item -Destination $commandsDir -Force
    }
    Start-Sleep -Milliseconds 200

    Write-Host ""
    Write-Success "Claude Code installation complete!"
    Write-Info "Agents   -> $agentsDir"
    Write-Info "Commands -> $commandsDir"
    Write-Host ""
    Write-Host "    Usage: " -ForegroundColor Yellow -NoNewline
    Write-Host "Run " -NoNewline
    Write-Host "/vue-migrate" -ForegroundColor Green -NoNewline
    Write-Host " in Claude Code"
}

function Install-GitHubCopilot {
    Write-Host ""
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "    Installing " -ForegroundColor Blue -NoNewline
    Write-Host "GitHub Copilot" -ForegroundColor White
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""

    Write-Step "Creating directories..."
    $agentsDir = Join-Path $TargetPath ".github\agents"
    New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
    Start-Sleep -Milliseconds 300

    Write-Step "Copying agent files..."
    $sourceAgents = Join-Path $ScriptDir "platforms\github-copilot\agents\*.md"
    if (Test-Path $sourceAgents) {
        Get-ChildItem $sourceAgents | Copy-Item -Destination $agentsDir -Force
    }
    Start-Sleep -Milliseconds 200

    Write-Host ""
    Write-Success "GitHub Copilot installation complete!"
    Write-Info "Agents -> $agentsDir"
    Write-Host ""
    Write-Host "    Usage: " -ForegroundColor Yellow -NoNewline
    Write-Host "Ask Copilot to " -NoNewline
    Write-Host "'migrate to Vue 3'" -ForegroundColor Green
}

function Install-Codex {
    Write-Host ""
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "    Installing " -ForegroundColor Blue -NoNewline
    Write-Host "Codex CLI" -ForegroundColor White
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""

    Write-Step "Creating skill directories..."
    $skillsDir = Join-Path $TargetPath ".codex\skills"
    New-Item -ItemType Directory -Force -Path (Join-Path $skillsDir "vue-migrator") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $skillsDir "vue-migration-planner") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $skillsDir "vue-migration-executor") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $skillsDir "vue-migration-reviewer") | Out-Null
    Start-Sleep -Milliseconds 300

    Write-Step "Copying skill files..."
    $skills = @("vue-migrator", "vue-migration-planner", "vue-migration-executor", "vue-migration-reviewer")
    foreach ($skill in $skills) {
        $source = Join-Path $ScriptDir "platforms\codex\skills\$skill\SKILL.md"
        $dest = Join-Path $skillsDir "$skill\SKILL.md"
        if (Test-Path $source) {
            Copy-Item $source -Destination $dest -Force
        }
    }
    Start-Sleep -Milliseconds 200

    Write-Host ""
    Write-Success "Codex CLI installation complete!"
    Write-Info ("Skills -> " + $skillsDir)
    Write-Info "  vue-migrator"
    Write-Info "  vue-migration-planner"
    Write-Info "  vue-migration-executor"
    Write-Info "  vue-migration-reviewer"
    Write-Host ""
    Write-Host "    Usage: " -ForegroundColor Yellow -NoNewline
    Write-Host "Ask Codex to " -NoNewline
    Write-Host "'migrate to Vue 3'" -ForegroundColor Green
    Write-Host "    Note:  Codex uses skills (subagent -> skill mapping)" -ForegroundColor DarkGray
}

function Install-Gemini {
    Write-Host ""
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "    Installing " -ForegroundColor Blue -NoNewline
    Write-Host "Gemini CLI" -ForegroundColor White
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""

    Write-Step "Creating directories..."
    $agentsDir = Join-Path $TargetPath ".gemini\agents"
    New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
    Start-Sleep -Milliseconds 300

    Write-Step "Copying agent files..."
    $sourceAgents = Join-Path $ScriptDir "platforms\gemini\agents\*.md"
    if (Test-Path $sourceAgents) {
        Get-ChildItem $sourceAgents | Copy-Item -Destination $agentsDir -Force
    }
    Start-Sleep -Milliseconds 200

    Write-Host ""
    Write-Success "Gemini CLI installation complete!"
    Write-Info "Agents -> $agentsDir"
    Write-Host ""
    Write-Host "    Usage: " -ForegroundColor Yellow -NoNewline
    Write-Host "Ask Gemini to " -NoNewline
    Write-Host "'migrate to Vue 3'" -ForegroundColor Green
}

function Install-OpenCode {
    Write-Host ""
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "    Installing " -ForegroundColor Blue -NoNewline
    Write-Host "OpenCode" -ForegroundColor White
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""

    Write-Step "Creating directories..."
    $agentsDir = Join-Path $TargetPath ".opencode\agents"
    New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
    Start-Sleep -Milliseconds 300

    Write-Step "Copying agent files..."
    $sourceAgents = Join-Path $ScriptDir "platforms\opencode\agents\*.md"
    if (Test-Path $sourceAgents) {
        Get-ChildItem $sourceAgents | Copy-Item -Destination $agentsDir -Force
    }
    Start-Sleep -Milliseconds 200

    Write-Host ""
    Write-Success "OpenCode installation complete!"
    Write-Info "Agents -> $agentsDir"
    Write-Info "  vue-migrator.md (mode: primary)"
    Write-Info "  vue-migration-planner.md (mode: subagent)"
    Write-Info "  vue-migration-executor.md (mode: subagent)"
    Write-Info "  vue-migration-reviewer.md (mode: subagent)"
    Write-Host ""
    Write-Host "    Usage: " -ForegroundColor Yellow -NoNewline
    Write-Host "Ask OpenCode to " -NoNewline
    Write-Host "'migrate vue'" -ForegroundColor Green -NoNewline
    Write-Host " or use " -NoNewline
    Write-Host "@vue-migrator" -ForegroundColor Cyan
}

function Install-Antigravity {
    Write-Host ""
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "    Installing " -ForegroundColor Blue -NoNewline
    Write-Host "Antigravity" -ForegroundColor White
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""

    Write-Step "Creating directories..."
    $rulesDir = Join-Path $TargetPath ".agents\rules"
    New-Item -ItemType Directory -Force -Path $rulesDir | Out-Null
    Start-Sleep -Milliseconds 300

    Write-Step "Copying rule file..."
    $sourceRule = Join-Path $ScriptDir "platforms\antigravity\rules\vue-migration.md"
    if (Test-Path $sourceRule) {
        Copy-Item $sourceRule -Destination $rulesDir -Force
    }
    Start-Sleep -Milliseconds 200

    Write-Host ""
    Write-Success "Antigravity installation complete!"
    Write-Info "Rules -> $rulesDir"
    Write-Host ""
    Write-Host "    Usage: " -ForegroundColor Yellow -NoNewline
    Write-Host "Ask Antigravity to " -NoNewline
    Write-Host "'migrate to Vue 3'" -ForegroundColor Green
}

function Install-Cursor {
    Write-Host ""
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "    Installing " -ForegroundColor Blue -NoNewline
    Write-Host "Cursor" -ForegroundColor White
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""

    Write-Step "Creating directories..."
    $rulesDir = Join-Path $TargetPath ".cursor\rules"
    New-Item -ItemType Directory -Force -Path $rulesDir | Out-Null
    Start-Sleep -Milliseconds 300

    Write-Step "Copying rule file..."
    $sourceRule = Join-Path $ScriptDir "platforms\cursor\rules\vue-migration.mdc"
    if (Test-Path $sourceRule) {
        Copy-Item $sourceRule -Destination $rulesDir -Force
    }
    Start-Sleep -Milliseconds 200

    Write-Host ""
    Write-Success "Cursor installation complete!"
    Write-Info "Rules -> $rulesDir"
    Write-Host ""
    Write-Host "    Usage: " -ForegroundColor Yellow -NoNewline
    Write-Host "Ask Cursor to " -NoNewline
    Write-Host "'migrate to Vue 3'" -ForegroundColor Green
    Write-Host "    Note:  Rule activates automatically when Vue migration is requested" -ForegroundColor DarkGray
}

function Write-FinalInstructions {
    Write-Host ""
    Write-Host ""
    Write-Host "  =========================================================" -ForegroundColor Green
    Write-Host "    $SYMBOL_CHECK " -ForegroundColor Green -NoNewline
    Write-Host "INSTALLATION COMPLETE" -ForegroundColor Green
    Write-Host "  =========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    1. " -ForegroundColor Cyan -NoNewline
    Write-Host "Open your Vue 2 project in your AI assistant"
    Write-Host "    2. " -ForegroundColor Cyan -NoNewline
    Write-Host "Ask it to migrate your project to Vue 3"
    Write-Host "    3. " -ForegroundColor Cyan -NoNewline
    Write-Host "Review and approve the migration plan"
    Write-Host "    4. " -ForegroundColor Cyan -NoNewline
    Write-Host "Let the assistant execute the migration"
    Write-Host ""
    Write-Host "  ---------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "    $SYMBOL_DOT " -ForegroundColor DarkGray -NoNewline
    Write-Host "https://github.com/anthropics/vue-agent-migrator" -ForegroundColor DarkGray
    Write-Host "  ---------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
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

    Write-Host ""
    Write-Host "  Target: " -ForegroundColor DarkGray -NoNewline
    Write-Host $TargetPath -ForegroundColor Cyan

    # ── Non-interactive mode (parameter) ──
    if ($Platform) {
        switch ($Platform) {
            "claude"   { Install-ClaudeCode }
            "copilot"  { Install-GitHubCopilot }
            "codex"    { Install-Codex }
            "gemini"   { Install-Gemini }
            "opencode" { Install-OpenCode }
            "cursor"       { Install-Cursor }
            "antigravity"  { Install-Antigravity }
            "all" {
                Install-ClaudeCode
                Install-GitHubCopilot
                Install-Codex
                Install-Gemini
                Install-OpenCode
                Install-Cursor
                Install-Antigravity
            }
        }
        Write-FinalInstructions
        return
    }

    # ── Interactive mode (checkbox menu) ──
    $selected = Show-CheckboxMenu

    if ($selected.Count -eq 0) {
        Write-Host "  No platforms selected. Exiting." -ForegroundColor DarkGray
        Write-Host ""
        exit 0
    }

    foreach ($platform in $selected) {
        switch ($platform) {
            "claude"   { Install-ClaudeCode }
            "copilot"  { Install-GitHubCopilot }
            "codex"    { Install-Codex }
            "gemini"   { Install-Gemini }
            "opencode" { Install-OpenCode }
            "cursor"      { Install-Cursor }
            "antigravity" { Install-Antigravity }
        }
    }

    Write-FinalInstructions
}

# Run
Main
