@echo off
setlocal enabledelayedexpansion

REM ═══════════════════════════════════════════════════════════════
REM  Vue 2 to Vue 3 Migration Tool Installer
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

REM Check if PowerShell is available and use it (supports full checkbox UI)
where powershell >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Launching PowerShell installer...
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install.ps1" -TargetPath "%TARGET_DIR%"
    goto :end
)

REM ═══════════════════════════════════════════════════════════════
REM  Batch fallback (no PowerShell available)
REM  Uses toggle-by-number for multi-select
REM ═══════════════════════════════════════════════════════════════

echo.
echo  ===========================================================
echo    VUE MIGRATION TOOL  ^|  Vue 2 =^> Vue 3  ^|  v1.0
echo  ===========================================================
echo.
echo  Target: %TARGET_DIR%
echo.

REM ─────────────────────────────────────────────────────────────────────────
REM Install skills globally (covers all platforms at once)
REM ─────────────────────────────────────────────────────────────────────────
echo  ---------------------------------------------------------
echo    Step 1  Installing Agent Skills  (global, all platforms)
echo  ---------------------------------------------------------
echo.

where npx >nul 2>&1
if %ERRORLEVEL%==0 (
    echo  Installing vue  (Vue 3 Composition API best practices)...
    npx skills add antfu/skills@vue -g -y >nul 2>&1
    if %ERRORLEVEL%==0 (echo  [OK] vue) else (echo  [WARN] Could not install antfu/skills@vue - skipping)

    echo  Installing vue-i18n-skilld  (vue-i18n v8-^>v9 breaking changes)...
    npx skills add harlan-zw/vue-ecosystem-skills@vue-i18n-skilld -g -y >nul 2>&1
    if %ERRORLEVEL%==0 (echo  [OK] vue-i18n-skilld) else (echo  [WARN] Could not install vue-i18n-skilld - skipping)

    echo  Installing vitest-testing  (Vitest test patterns)...
    npx skills add existential-birds/beagle@vitest-testing -g -y >nul 2>&1
    if %ERRORLEVEL%==0 (echo  [OK] vitest-testing) else (echo  [WARN] Could not install vitest-testing - skipping)

    echo.
    echo       Skills installed to %%USERPROFILE%%\.agents\skills\
    echo       Available to all platforms automatically
) else (
    echo  [WARN] npx not found - skipping skill installation
    echo        Install manually after setup:
    echo          npx skills add antfu/skills@vue -g -y
    echo          npx skills add harlan-zw/vue-ecosystem-skills@vue-i18n-skilld -g -y
    echo          npx skills add existential-birds/beagle@vitest-testing -g -y
)
echo.

REM Checkbox state (0=unchecked, 1=checked)
set "C1=0"
set "C2=0"
set "C3=0"
set "C4=0"
set "C5=0"
set "C6=0"
set "C7=0"

:menu_loop
echo  -----------------------------------------------------------
echo    SELECT PLATFORMS TO INSTALL
echo  -----------------------------------------------------------
echo.

REM Display checkboxes
if "!C1!"=="1" (echo    [X] 1. Claude Code        - Anthropic's CLI) else (echo    [ ] 1. Claude Code        - Anthropic's CLI)
if "!C2!"=="1" (echo    [X] 2. GitHub Copilot     - GitHub's AI) else (echo    [ ] 2. GitHub Copilot     - GitHub's AI)
if "!C3!"=="1" (echo    [X] 3. Codex CLI          - OpenAI's Codex) else (echo    [ ] 3. Codex CLI          - OpenAI's Codex)
if "!C4!"=="1" (echo    [X] 4. Gemini CLI         - Google's Gemini) else (echo    [ ] 4. Gemini CLI         - Google's Gemini)
if "!C5!"=="1" (echo    [X] 5. OpenCode           - Open source AI) else (echo    [ ] 5. OpenCode           - Open source AI)
if "!C6!"=="1" (echo    [X] 6. Cursor             - Cursor editor) else (echo    [ ] 6. Cursor             - Cursor editor)
if "!C7!"=="1" (echo    [X] 7. Antigravity        - Google's Antigravity) else (echo    [ ] 7. Antigravity        - Google's Antigravity)
echo.

REM Count selected
set /a "SEL_COUNT=C1+C2+C3+C4+C5+C6"
if !SEL_COUNT! GTR 0 (
    echo    !SEL_COUNT! selected
) else (
    echo    No platforms selected
)
echo.
echo    Type number to toggle ^| A=all ^| Enter=install ^| 0=exit
echo.
set "choice="
set /p choice="  ^> "

if "%choice%"=="1" (if "!C1!"=="1" (set "C1=0") else (set "C1=1")) & goto :menu_loop
if "%choice%"=="2" (if "!C2!"=="1" (set "C2=0") else (set "C2=1")) & goto :menu_loop
if "%choice%"=="3" (if "!C3!"=="1" (set "C3=0") else (set "C3=1")) & goto :menu_loop
if "%choice%"=="4" (if "!C4!"=="1" (set "C4=0") else (set "C4=1")) & goto :menu_loop
if "%choice%"=="5" (if "!C5!"=="1" (set "C5=0") else (set "C5=1")) & goto :menu_loop
if "%choice%"=="6" (if "!C6!"=="1" (set "C6=0") else (set "C6=1")) & goto :menu_loop
if "%choice%"=="7" (if "!C7!"=="1" (set "C7=0") else (set "C7=1")) & goto :menu_loop
if /i "%choice%"=="a" (
    set /a "ALL_COUNT=C1+C2+C3+C4+C5+C6+C7"
    if !ALL_COUNT!==7 (
        set "C1=0" & set "C2=0" & set "C3=0" & set "C4=0" & set "C5=0" & set "C6=0" & set "C7=0"
    ) else (
        set "C1=1" & set "C2=1" & set "C3=1" & set "C4=1" & set "C5=1" & set "C6=1" & set "C7=1"
    )
    goto :menu_loop
)
if "%choice%"=="0" goto :exit

REM Enter pressed (empty choice) - proceed with installation
if "%choice%"=="" goto :install_selected

echo  Invalid option. Try again.
goto :menu_loop

:install_selected
set /a "SEL_COUNT=C1+C2+C3+C4+C5+C6+C7"
if !SEL_COUNT!==0 (
    echo  No platforms selected. Exiting.
    goto :end
)

if "!C1!"=="1" call :claude
if "!C2!"=="1" call :copilot
if "!C3!"=="1" call :codex
if "!C4!"=="1" call :gemini
if "!C5!"=="1" call :opencode
if "!C6!"=="1" call :cursor
if "!C7!"=="1" call :antigravity
goto :done

:claude
echo.
echo  ---------------------------------------------------------
echo    Installing Claude Code
echo  ---------------------------------------------------------
echo.
if not exist "%TARGET_DIR%\.claude\agents" mkdir "%TARGET_DIR%\.claude\agents"
if not exist "%TARGET_DIR%\.claude\commands" mkdir "%TARGET_DIR%\.claude\commands"
xcopy /Y /Q "%SCRIPT_DIR%platforms\claude-code\agents\*" "%TARGET_DIR%\.claude\agents\" >nul 2>&1
xcopy /Y /Q "%SCRIPT_DIR%platforms\claude-code\commands\*" "%TARGET_DIR%\.claude\commands\" >nul 2>&1
set "GLOBAL_SKILLS=%USERPROFILE%\.agents\skills"
if exist "%GLOBAL_SKILLS%\vue" xcopy /E /I /Y "%GLOBAL_SKILLS%\vue" "%TARGET_DIR%\.claude\skills\vue\" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vue-i18n-skilld" xcopy /E /I /Y "%GLOBAL_SKILLS%\vue-i18n-skilld" "%TARGET_DIR%\.claude\skills\vue-i18n-skilld\" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vitest-testing" xcopy /E /I /Y "%GLOBAL_SKILLS%\vitest-testing" "%TARGET_DIR%\.claude\skills\vitest-testing\" >nul 2>&1
echo  [OK] Claude Code installation complete!
echo       Agents:   %TARGET_DIR%\.claude\agents\
echo       Commands: %TARGET_DIR%\.claude\commands\
echo       Skills:   %TARGET_DIR%\.claude\skills\
echo       Usage: Run /vue-migrate in Claude Code
goto :eof

:copilot
echo.
echo  ---------------------------------------------------------
echo    Installing GitHub Copilot
echo  ---------------------------------------------------------
echo.
if not exist "%TARGET_DIR%\.github\agents" mkdir "%TARGET_DIR%\.github\agents"
xcopy /Y /Q "%SCRIPT_DIR%platforms\github-copilot\agents\*" "%TARGET_DIR%\.github\agents\" >nul 2>&1
set "GLOBAL_SKILLS=%USERPROFILE%\.agents\skills"
if exist "%GLOBAL_SKILLS%\vue" xcopy /E /I /Y "%GLOBAL_SKILLS%\vue" "%TARGET_DIR%\.github\skills\vue\" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vue-i18n-skilld" xcopy /E /I /Y "%GLOBAL_SKILLS%\vue-i18n-skilld" "%TARGET_DIR%\.github\skills\vue-i18n-skilld\" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vitest-testing" xcopy /E /I /Y "%GLOBAL_SKILLS%\vitest-testing" "%TARGET_DIR%\.github\skills\vitest-testing\" >nul 2>&1
echo  [OK] GitHub Copilot installation complete!
echo       Agents: %TARGET_DIR%\.github\agents\
echo       Skills: %TARGET_DIR%\.github\skills\
echo       Usage: Ask Copilot to "migrate to Vue 3"
goto :eof

:codex
echo.
echo  ---------------------------------------------------------
echo    Installing Codex CLI
echo  ---------------------------------------------------------
echo.
if not exist "%TARGET_DIR%\.codex\skills\vue-migrator" mkdir "%TARGET_DIR%\.codex\skills\vue-migrator"
if not exist "%TARGET_DIR%\.codex\skills\vue-migration-planner" mkdir "%TARGET_DIR%\.codex\skills\vue-migration-planner"
if not exist "%TARGET_DIR%\.codex\skills\vue-migration-executor" mkdir "%TARGET_DIR%\.codex\skills\vue-migration-executor"
if not exist "%TARGET_DIR%\.codex\skills\vue-migration-reviewer" mkdir "%TARGET_DIR%\.codex\skills\vue-migration-reviewer"
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migrator\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migrator\" >nul 2>&1
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migration-planner\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migration-planner\" >nul 2>&1
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migration-executor\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migration-executor\" >nul 2>&1
copy /Y "%SCRIPT_DIR%platforms\codex\skills\vue-migration-reviewer\SKILL.md" "%TARGET_DIR%\.codex\skills\vue-migration-reviewer\" >nul 2>&1
set "GLOBAL_SKILLS=%USERPROFILE%\.agents\skills"
if exist "%GLOBAL_SKILLS%\vue" (
    xcopy /E /I /Y "%GLOBAL_SKILLS%\vue" "%TARGET_DIR%\.codex\skills\vue\" >nul 2>&1
)
if exist "%GLOBAL_SKILLS%\vue-i18n-skilld" (
    xcopy /E /I /Y "%GLOBAL_SKILLS%\vue-i18n-skilld" "%TARGET_DIR%\.codex\skills\vue-i18n-skilld\" >nul 2>&1
)
if exist "%GLOBAL_SKILLS%\vitest-testing" (
    xcopy /E /I /Y "%GLOBAL_SKILLS%\vitest-testing" "%TARGET_DIR%\.codex\skills\vitest-testing\" >nul 2>&1
)
echo  [OK] Codex CLI installation complete!
echo       Skills: %TARGET_DIR%\.codex\skills\
echo         - vue-migrator
echo         - vue-migration-planner
echo         - vue-migration-executor
echo         - vue-migration-reviewer
echo         - vue  ^|  vue-i18n-skilld  ^|  vitest-testing  (agent skills)
echo       Usage: Ask Codex to "migrate to Vue 3"
goto :eof

:gemini
echo.
echo  ---------------------------------------------------------
echo    Installing Gemini CLI
echo  ---------------------------------------------------------
echo.
if not exist "%TARGET_DIR%\.gemini\agents" mkdir "%TARGET_DIR%\.gemini\agents"
xcopy /Y /Q "%SCRIPT_DIR%platforms\gemini\agents\*" "%TARGET_DIR%\.gemini\agents\" >nul 2>&1
set "GLOBAL_SKILLS=%USERPROFILE%\.agents\skills"
if exist "%GLOBAL_SKILLS%\vue" xcopy /E /I /Y "%GLOBAL_SKILLS%\vue" "%TARGET_DIR%\.gemini\skills\vue\" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vue-i18n-skilld" xcopy /E /I /Y "%GLOBAL_SKILLS%\vue-i18n-skilld" "%TARGET_DIR%\.gemini\skills\vue-i18n-skilld\" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vitest-testing" xcopy /E /I /Y "%GLOBAL_SKILLS%\vitest-testing" "%TARGET_DIR%\.gemini\skills\vitest-testing\" >nul 2>&1
echo  [OK] Gemini CLI installation complete!
echo       Agents: %TARGET_DIR%\.gemini\agents\
echo       Skills: %TARGET_DIR%\.gemini\skills\
echo       Usage: Ask Gemini to "migrate to Vue 3"
goto :eof

:opencode
echo.
echo  ---------------------------------------------------------
echo    Installing OpenCode
echo  ---------------------------------------------------------
echo.
if not exist "%TARGET_DIR%\.opencode\agents" mkdir "%TARGET_DIR%\.opencode\agents"
xcopy /Y /Q "%SCRIPT_DIR%platforms\opencode\agents\*.md" "%TARGET_DIR%\.opencode\agents\" >nul 2>&1
set "GLOBAL_SKILLS=%USERPROFILE%\.agents\skills"
if exist "%GLOBAL_SKILLS%\vue" xcopy /E /I /Y "%GLOBAL_SKILLS%\vue" "%TARGET_DIR%\.opencode\skills\vue\" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vue-i18n-skilld" xcopy /E /I /Y "%GLOBAL_SKILLS%\vue-i18n-skilld" "%TARGET_DIR%\.opencode\skills\vue-i18n-skilld\" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vitest-testing" xcopy /E /I /Y "%GLOBAL_SKILLS%\vitest-testing" "%TARGET_DIR%\.opencode\skills\vitest-testing\" >nul 2>&1
echo  [OK] OpenCode installation complete!
echo       Agents: %TARGET_DIR%\.opencode\agents\
echo       Skills: %TARGET_DIR%\.opencode\skills\
echo       Usage: Ask OpenCode to "migrate vue" or use @vue-migrator
goto :eof

:cursor
echo.
echo  ---------------------------------------------------------
echo    Installing Cursor
echo  ---------------------------------------------------------
echo.
if not exist "%TARGET_DIR%\.cursor\rules" mkdir "%TARGET_DIR%\.cursor\rules"
copy /Y "%SCRIPT_DIR%platforms\cursor\rules\vue-migration.mdc" "%TARGET_DIR%\.cursor\rules\" >nul 2>&1
set "GLOBAL_SKILLS=%USERPROFILE%\.agents\skills"
if exist "%GLOBAL_SKILLS%\vue\SKILL.md" copy /Y "%GLOBAL_SKILLS%\vue\SKILL.md" "%TARGET_DIR%\.cursor\rules\vue.mdc" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vue-i18n-skilld\SKILL.md" copy /Y "%GLOBAL_SKILLS%\vue-i18n-skilld\SKILL.md" "%TARGET_DIR%\.cursor\rules\vue-i18n-skilld.mdc" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vitest-testing\SKILL.md" copy /Y "%GLOBAL_SKILLS%\vitest-testing\SKILL.md" "%TARGET_DIR%\.cursor\rules\vitest-testing.mdc" >nul 2>&1
echo  [OK] Cursor installation complete!
echo       Rules: %TARGET_DIR%\.cursor\rules\
echo       Usage: Ask Cursor to "migrate to Vue 3"
goto :eof

:antigravity
echo.
echo  ---------------------------------------------------------
echo    Installing Antigravity
echo  ---------------------------------------------------------
echo.
if not exist "%TARGET_DIR%\.agents\rules" mkdir "%TARGET_DIR%\.agents\rules"
copy /Y "%SCRIPT_DIR%platforms\antigravity\rules\vue-migration.md" "%TARGET_DIR%\.agents\rules\" >nul 2>&1
set "GLOBAL_SKILLS=%USERPROFILE%\.agents\skills"
if exist "%GLOBAL_SKILLS%\vue" xcopy /E /I /Y "%GLOBAL_SKILLS%\vue" "%TARGET_DIR%\.agents\skills\vue\" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vue-i18n-skilld" xcopy /E /I /Y "%GLOBAL_SKILLS%\vue-i18n-skilld" "%TARGET_DIR%\.agents\skills\vue-i18n-skilld\" >nul 2>&1
if exist "%GLOBAL_SKILLS%\vitest-testing" xcopy /E /I /Y "%GLOBAL_SKILLS%\vitest-testing" "%TARGET_DIR%\.agents\skills\vitest-testing\" >nul 2>&1
echo  [OK] Antigravity installation complete!
echo       Rules:  %TARGET_DIR%\.agents\rules\
echo       Skills: %TARGET_DIR%\.agents\skills\
echo       Usage: Ask Antigravity to "migrate to Vue 3"
goto :eof

:done
echo.
echo  ===========================================================
echo    INSTALLATION COMPLETE
echo  ===========================================================
echo.
echo  Next steps:
echo    1. Open your Vue 2 project in your AI assistant
echo    2. Ask it to migrate your project to Vue 3
echo    3. Review and approve the migration plan
echo    4. Let the assistant execute the migration
echo.
goto :end

:exit
echo  Exiting...
goto :end

:end
endlocal
