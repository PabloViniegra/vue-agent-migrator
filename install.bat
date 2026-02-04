@echo off
setlocal enabledelayedexpansion

REM ═══════════════════════════════════════════════════════════════
REM  Vue 2 → Vue 3 Migration Tool Installer
REM  Supports: Claude Code, GitHub Copilot, Codex, Gemini, OpenCode
REM ═══════════════════════════════════════════════════════════════

set "SCRIPT_DIR=%~dp0"
set "TARGET_DIR=%~1"

REM Check if target directory is provided
if "%TARGET_DIR%"=="" (
    echo [ERROR] Target directory is required
    echo.
    echo Usage:
    echo   install.bat ^<path-to-vue2-project^>
    echo.
    echo Example:
    echo   install.bat C:\Projects\my-vue-app
    echo.
    goto :end
)

REM Check if target directory exists
if not exist "%TARGET_DIR%" (
    echo [ERROR] Target directory does not exist: %TARGET_DIR%
    echo.
    goto :end
)

REM Check if PowerShell is available and use it
where powershell >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Launching PowerShell installer...
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install.ps1" -TargetPath "%TARGET_DIR%"
    goto :end
)

REM Fallback to batch script if PowerShell not available
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║       Vue 2 → Vue 3 Migration Tool Installer             ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

echo Target directory: %TARGET_DIR%
echo.

:menu
echo Select your AI coding assistant:
echo.
echo   1) Claude Code      - Anthropic's CLI tool
echo   2) GitHub Copilot   - GitHub's AI assistant
echo   3) Codex            - OpenAI's Codex CLI
echo   4) Gemini           - Google's Gemini CLI
echo   5) OpenCode         - Open source AI CLI
echo   6) All              - Install for all platforms
echo.
echo   0) Exit
echo.

set /p choice="Enter your choice [1-6]: "

if "%choice%"=="1" goto :claude
if "%choice%"=="2" goto :copilot
if "%choice%"=="3" goto :codex
if "%choice%"=="4" goto :gemini
if "%choice%"=="5" goto :opencode
if "%choice%"=="6" goto :all
if "%choice%"=="0" goto :exit

echo Invalid choice. Please try again.
goto :menu

:claude
echo.
echo Installing for Claude Code...
if not exist "%TARGET_DIR%\.claude\agents" mkdir "%TARGET_DIR%\.claude\agents"
if not exist "%TARGET_DIR%\.claude\commands" mkdir "%TARGET_DIR%\.claude\commands"
xcopy /Y /Q "%SCRIPT_DIR%platforms\claude-code\agents\*" "%TARGET_DIR%\.claude\agents\" >nul 2>&1
xcopy /Y /Q "%SCRIPT_DIR%platforms\claude-code\commands\*" "%TARGET_DIR%\.claude\commands\" >nul 2>&1
echo [OK] Claude Code configuration installed
echo     Agents:   %TARGET_DIR%\.claude\agents\
echo     Commands: %TARGET_DIR%\.claude\commands\
echo     Usage: Run /vue-migrate in Claude Code
goto :done

:copilot
echo.
echo Installing for GitHub Copilot...
if not exist "%TARGET_DIR%\.github\agents" mkdir "%TARGET_DIR%\.github\agents"
xcopy /Y /Q "%SCRIPT_DIR%platforms\github-copilot\agents\*" "%TARGET_DIR%\.github\agents\" >nul 2>&1
echo [OK] GitHub Copilot configuration installed
echo     Agents: %TARGET_DIR%\.github\agents\
echo     Usage: Ask Copilot to "migrate to Vue 3"
goto :done

:codex
echo.
echo Installing for Codex CLI...
if not exist "%TARGET_DIR%\.codex\skills\vue-migrator" mkdir "%TARGET_DIR%\.codex\skills\vue-migrator"
if not exist "%TARGET_DIR%\.codex\skills\vue-migration-planner" mkdir "%TARGET_DIR%\.codex\skills\vue-migration-planner"
if not exist "%TARGET_DIR%\.codex\skills\vue-migration-executor" mkdir "%TARGET_DIR%\.codex\skills\vue-migration-executor"
if not exist "%TARGET_DIR%\.codex\skills\vue-migration-reviewer" mkdir "%TARGET_DIR%\.codex\skills\vue-migration-reviewer"
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migrator\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migrator\" >nul 2>&1
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migration-planner\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migration-planner\" >nul 2>&1
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migration-executor\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migration-executor\" >nul 2>&1
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migration-reviewer\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migration-reviewer\" >nul 2>&1
echo [OK] Codex CLI configuration installed
echo     Skills: %TARGET_DIR%\.codex\skills\
echo       - vue-migrator
echo       - vue-migration-planner
echo       - vue-migration-executor
echo       - vue-migration-reviewer
echo     Usage: Ask Codex to "migrate to Vue 3"
echo     Note: Codex uses skills (subagent -^> skill mapping)
goto :done

:gemini
echo.
echo Installing for Gemini CLI...
if not exist "%TARGET_DIR%\.gemini\agents" mkdir "%TARGET_DIR%\.gemini\agents"
xcopy /Y /Q "%SCRIPT_DIR%platforms\gemini\agents\*" "%TARGET_DIR%\.gemini\agents\" >nul 2>&1
echo [OK] Gemini CLI configuration installed
echo     Agents: %TARGET_DIR%\.gemini\agents\
echo     Usage: Ask Gemini to "migrate to Vue 3"
goto :done

:opencode
echo.
echo Installing for OpenCode...
if not exist "%TARGET_DIR%\.opencode\agents" mkdir "%TARGET_DIR%\.opencode\agents"
xcopy /Y /Q "%SCRIPT_DIR%platforms\opencode\agents\*.md" "%TARGET_DIR%\.opencode\agents\" >nul 2>&1
echo [OK] OpenCode configuration installed
echo     Agents: %TARGET_DIR%\.opencode\agents\
echo       - vue-migrator.md (mode: primary)
echo       - vue-migration-planner.md (mode: subagent)
echo       - vue-migration-executor.md (mode: subagent)
echo       - vue-migration-reviewer.md (mode: subagent)
echo     Usage: Ask OpenCode to "migrate vue" or use @vue-migrator
echo     Subagents: @vue-migration-planner, @vue-migration-executor, @vue-migration-reviewer
goto :done

:all
echo.
echo Installing for all platforms...
echo.
call :claude_silent
call :copilot_silent
call :codex_silent
call :gemini_silent
call :opencode_silent
echo.
echo [OK] All platforms installed successfully
goto :done

:claude_silent
if not exist "%TARGET_DIR%\.claude\agents" mkdir "%TARGET_DIR%\.claude\agents"
if not exist "%TARGET_DIR%\.claude\commands" mkdir "%TARGET_DIR%\.claude\commands"
xcopy /Y /Q "%SCRIPT_DIR%platforms\claude-code\agents\*" "%TARGET_DIR%\.claude\agents\" >nul 2>&1
xcopy /Y /Q "%SCRIPT_DIR%platforms\claude-code\commands\*" "%TARGET_DIR%\.claude\commands\" >nul 2>&1
echo   [OK] Claude Code
goto :eof

:copilot_silent
if not exist "%TARGET_DIR%\.github\agents" mkdir "%TARGET_DIR%\.github\agents"
xcopy /Y /Q "%SCRIPT_DIR%platforms\github-copilot\agents\*" "%TARGET_DIR%\.github\agents\" >nul 2>&1
echo   [OK] GitHub Copilot
goto :eof

:codex_silent
if not exist "%TARGET_DIR%\.codex\skills\vue-migrator" mkdir "%TARGET_DIR%\.codex\skills\vue-migrator"
if not exist "%TARGET_DIR%\.codex\skills\vue-migration-planner" mkdir "%TARGET_DIR%\.codex\skills\vue-migration-planner"
if not exist "%TARGET_DIR%\.codex\skills\vue-migration-executor" mkdir "%TARGET_DIR%\.codex\skills\vue-migration-executor"
if not exist "%TARGET_DIR%\.codex\skills\vue-migration-reviewer" mkdir "%TARGET_DIR%\.codex\skills\vue-migration-reviewer"
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migrator\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migrator\" >nul 2>&1
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migration-planner\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migration-planner\" >nul 2>&1
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migration-executor\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migration-executor\" >nul 2>&1
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migration-reviewer\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migration-reviewer\" >nul 2>&1
echo   [OK] Codex CLI
goto :eof

:gemini_silent
if not exist "%TARGET_DIR%\.gemini\agents" mkdir "%TARGET_DIR%\.gemini\agents"
xcopy /Y /Q "%SCRIPT_DIR%platforms\gemini\agents\*" "%TARGET_DIR%\.gemini\agents\" >nul 2>&1
echo   [OK] Gemini CLI
goto :eof

:opencode_silent
if not exist "%TARGET_DIR%\.opencode\agents" mkdir "%TARGET_DIR%\.opencode\agents"
xcopy /Y /Q "%SCRIPT_DIR%platforms\opencode\agents\*.md" "%TARGET_DIR%\.opencode\agents\" >nul 2>&1
echo   [OK] OpenCode
goto :eof

:done
echo.
echo ════════════════════════════════════════════════════════════
echo Installation complete!
echo ════════════════════════════════════════════════════════════
echo.
echo Next steps:
echo   1. Open your Vue 2 project in your AI assistant
echo   2. Ask it to migrate your project to Vue 3
echo   3. Review and approve the migration plan
echo   4. Let the assistant execute the migration
echo.
goto :end

:exit
echo Exiting...
goto :end

:end
endlocal
