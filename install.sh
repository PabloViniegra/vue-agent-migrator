#!/bin/bash

#######################################
# Vue 2 to Vue 3 Migration Tool Installer
# Supports: Claude Code, GitHub Copilot, Codex, Gemini, OpenCode
#######################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Symbols
SYMBOL_SUCCESS="✓"
SYMBOL_ERROR="✗"
SYMBOL_ARROW="▶"
SYMBOL_DOT="●"
SYMBOL_CHECK="✔"
SYMBOL_STAR="★"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directory (required parameter)
if [ -z "$1" ]; then
    echo -e "${RED}Error: Target directory is required${NC}"
    echo ""
    echo "Usage:"
    echo "  ./install.sh <path-to-vue2-project>"
    echo ""
    echo "Example:"
    echo "  ./install.sh /home/user/my-vue-app"
    echo "  ./install.sh ~/projects/vue-project"
    exit 1
fi

TARGET_DIR="$1"

print_banner() {
    echo ""
    echo -e "${CYAN}  ===========================================================${NC}"
    echo -e "    ${GREEN}VUE MIGRATION TOOL${NC}  ${GRAY}|${NC}  ${YELLOW}Vue 2${NC} ${GRAY}=>${NC} ${GREEN}Vue 3${NC}  ${GRAY}|  v1.0${NC}"
    echo -e "${CYAN}  ===========================================================${NC}"
}

print_step() {
    echo -e "${CYAN}[${BLUE}${SYMBOL_ARROW}${CYAN}]${NC} $1"
}

print_success() {
    echo -e "${CYAN}[${GREEN}${SYMBOL_SUCCESS}${CYAN}]${NC} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "${CYAN}[${RED}${SYMBOL_ERROR}${CYAN}]${NC} ${RED}$1${NC}"
}

print_info() {
    echo -e "${GRAY}    ${SYMBOL_DOT}${NC} $1"
}

# ─────────────────────────────────────────────────────────────────────────────
# Interactive checkbox menu using tput + read -rsn1
# ─────────────────────────────────────────────────────────────────────────────
show_checkbox_menu() {
    local names=("claude" "copilot" "codex" "gemini" "opencode" "cursor" "antigravity")
    local labels=("Claude Code" "GitHub Copilot" "Codex CLI" "Gemini CLI" "OpenCode" "Cursor" "Antigravity")
    local descs=("Anthropic's CLI" "GitHub's AI" "OpenAI's Codex" "Google's Gemini" "Open source AI" "Cursor editor" "Google's Antigravity")
    local checked=(0 0 0 0 0 0 0)
    local count=${#names[@]}
    local cursor=0
    local total_lines=$((count + 2))  # options + blank + status

    # Static header (printed once)
    echo ""
    echo -e "${CYAN}  -----------------------------------------------------------${NC}"
    echo -e "    ${YELLOW}${SYMBOL_STAR}${NC} ${WHITE}SELECT PLATFORMS TO INSTALL${NC}"
    echo -e "${CYAN}  -----------------------------------------------------------${NC}"
    echo ""
    echo -e "    ${GRAY}Up/Down${NC} Navigate  ${GRAY}|  Space${NC} Toggle  ${GRAY}|  A${NC} All  ${GRAY}|  Enter${NC} Install  ${GRAY}|  Esc${NC} Exit"
    echo ""

    # Reserve lines for the dynamic area
    for ((i = 0; i < total_lines; i++)); do echo ""; done

    # Hide cursor
    tput civis 2>/dev/null || true

    # Cleanup on exit
    trap 'tput cnorm 2>/dev/null || true' EXIT

    while true; do
        # Move cursor up to menu start
        printf "\033[${total_lines}A"

        # Draw each option
        for ((i = 0; i < count; i++)); do
            # Clear line
            printf "\033[2K"

            local is_cursor=0
            [[ $i -eq $cursor ]] && is_cursor=1

            # Pointer
            if [[ $is_cursor -eq 1 ]]; then
                printf "  ${CYAN}>${NC} "
            else
                printf "    "
            fi

            # Checkbox
            if [[ ${checked[$i]} -eq 1 ]]; then
                printf "${GREEN}[X]${NC}"
            else
                printf "${GRAY}[ ]${NC}"
            fi

            # Label (padded to 18 chars)
            local padded
            padded=$(printf "%-18s" "${labels[$i]}")
            if [[ $is_cursor -eq 1 ]]; then
                printf " ${WHITE}%s${NC} ${GRAY}%s${NC}\n" "$padded" "${descs[$i]}"
            else
                printf " ${GRAY}%s${NC} ${GRAY}%s${NC}\n" "$padded" "${descs[$i]}"
            fi
        done

        # Status line
        local selected_count=0
        for ((i = 0; i < count; i++)); do
            [[ ${checked[$i]} -eq 1 ]] && ((selected_count++))
        done

        printf "\033[2K\n"  # blank line
        printf "\033[2K"
        if [[ $selected_count -gt 0 ]]; then
            printf "    ${YELLOW}%d selected${NC}  ${GRAY}- press Enter to install${NC}\n" "$selected_count"
        else
            printf "    ${GRAY}No platforms selected${NC}\n"
        fi

        # Read key
        local key
        IFS= read -rsn1 key

        case "$key" in
            $'\x1b')
                # Escape sequence - read remaining chars
                local seq
                IFS= read -rsn2 -t 0.1 seq || true
                case "$seq" in
                    '[A')  # Up arrow
                        if [[ $cursor -gt 0 ]]; then
                            ((cursor--))
                        else
                            cursor=$((count - 1))
                        fi
                        ;;
                    '[B')  # Down arrow
                        if [[ $cursor -lt $((count - 1)) ]]; then
                            ((cursor++))
                        else
                            cursor=0
                        fi
                        ;;
                    '')  # Just Escape (no sequence)
                        tput cnorm 2>/dev/null || true
                        trap - EXIT
                        SELECTED_PLATFORMS=()
                        return
                        ;;
                esac
                ;;
            ' ')  # Space - toggle
                if [[ ${checked[$cursor]} -eq 1 ]]; then
                    checked[$cursor]=0
                else
                    checked[$cursor]=1
                fi
                ;;
            'a'|'A')  # Toggle all
                local all_checked=1
                for ((i = 0; i < count; i++)); do
                    [[ ${checked[$i]} -eq 0 ]] && all_checked=0 && break
                done
                local new_val=$((1 - all_checked))
                for ((i = 0; i < count; i++)); do
                    checked[$i]=$new_val
                done
                ;;
            '')  # Enter - confirm
                tput cnorm 2>/dev/null || true
                trap - EXIT
                SELECTED_PLATFORMS=()
                for ((i = 0; i < count; i++)); do
                    if [[ ${checked[$i]} -eq 1 ]]; then
                        SELECTED_PLATFORMS+=("${names[$i]}")
                    fi
                done
                echo ""
                return
                ;;
        esac
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Skill installation (global — covers all platforms at once)
# ─────────────────────────────────────────────────────────────────────────────

install_skills() {
    echo ""
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo -e "    ${MAGENTA}Step 1${NC}  ${WHITE}Installing Agent Skills${NC}  ${GRAY}(global · all platforms)${NC}"
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo ""

    if ! command -v npx &> /dev/null; then
        echo -e "    ${YELLOW}⚠  npx not found${NC} — skipping skill installation"
        echo -e "    ${GRAY}Install manually after setup:${NC}"
        echo -e "    ${GRAY}  npx skills add antfu/skills@vue -g -y${NC}"
        echo -e "    ${GRAY}  npx skills add harlan-zw/vue-ecosystem-skills@vue-i18n-skilld -g -y${NC}"
        echo -e "    ${GRAY}  npx skills add existential-birds/beagle@vitest-testing -g -y${NC}"
        echo ""
        return 0
    fi

    local -a SKILLS=(
        "antfu/skills@vue"
        "harlan-zw/vue-ecosystem-skills@vue-i18n-skilld"
        "existential-birds/beagle@vitest-testing"
    )
    local -a LABELS=(
        "vue               Vue 3 Composition API best practices"
        "vue-i18n-skilld   vue-i18n v8->v9 breaking changes"
        "vitest-testing    Vitest test patterns"
    )

    for i in "${!SKILLS[@]}"; do
        print_step "Installing ${LABELS[$i]}..."
        if npx skills add "${SKILLS[$i]}" -g -y > /dev/null 2>&1; then
            print_success "${LABELS[$i]}"
        else
            echo -e "    ${YELLOW}⚠  Could not install ${SKILLS[$i]} — skipping${NC}"
        fi
        sleep 0.1
    done

    echo ""
    print_info "Skills installed to ${CYAN}~/.agents/skills/${NC}"
    print_info "Available to all platforms automatically"
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Helper: copy agent background skills from global to a local project directory
# Usage: copy_agent_skills_local <local_dir> [mdc]
#   Pass "mdc" as second arg to copy SKILL.md as <name>.mdc (for Cursor rules)
# ─────────────────────────────────────────────────────────────────────────────

copy_agent_skills_local() {
    local local_dir="$1"
    local mode="${2:-dir}"
    local global_skills_dir="$HOME/.agents/skills"
    local bg_skills=("vue" "vue-i18n-skilld" "vitest-testing")
    local copied_any=0

    mkdir -p "$local_dir"

    for bg_skill in "${bg_skills[@]}"; do
        local src="$global_skills_dir/$bg_skill"
        if [ -d "$src" ]; then
            if [ "$mode" = "mdc" ]; then
                local skill_file="$src/SKILL.md"
                if [ -f "$skill_file" ]; then
                    cp "$skill_file" "$local_dir/$bg_skill.mdc" 2>/dev/null || true
                    print_info "${GREEN}${SYMBOL_CHECK}${NC} $bg_skill.mdc (agent skill)"
                fi
            else
                cp -r "$src" "$local_dir/" 2>/dev/null || true
                print_info "${GREEN}${SYMBOL_CHECK}${NC} $bg_skill (agent skill)"
            fi
            copied_any=1
        fi
    done

    if [ $copied_any -eq 0 ]; then
        echo -e "    ${YELLOW}⚠  Agent skills not found in $global_skills_dir${NC}"
        echo -e "    ${GRAY}Run install with npm/npx available so Step 1 can install them${NC}"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Installation functions
# ─────────────────────────────────────────────────────────────────────────────

install_claude_code() {
    echo ""
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo -e "    ${BLUE}Installing${NC} ${WHITE}Claude Code${NC}"
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo ""

    print_step "Creating directories..."
    mkdir -p "$TARGET_DIR/.claude/agents"
    mkdir -p "$TARGET_DIR/.claude/commands"
    sleep 0.3

    print_step "Copying agent files..."
    cp "$SCRIPT_DIR/platforms/claude-code/agents/"*.md "$TARGET_DIR/.claude/agents/" 2>/dev/null || true
    sleep 0.2

    print_step "Copying command files..."
    cp "$SCRIPT_DIR/platforms/claude-code/commands/"*.md "$TARGET_DIR/.claude/commands/" 2>/dev/null || true
    sleep 0.2

    print_step "Copying agent background skills to project..."
    copy_agent_skills_local "$TARGET_DIR/.claude/skills"
    sleep 0.2

    echo ""
    print_success "Claude Code installation complete!"
    print_info "Agents   -> ${CYAN}$TARGET_DIR/.claude/agents/${NC}"
    print_info "Commands -> ${CYAN}$TARGET_DIR/.claude/commands/${NC}"
    print_info "Skills   -> ${CYAN}$TARGET_DIR/.claude/skills/${NC}"
    echo ""
    echo -e "    ${YELLOW}Usage:${NC} Run ${GREEN}/vue-migrate${NC} in Claude Code"
}

install_github_copilot() {
    echo ""
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo -e "    ${BLUE}Installing${NC} ${WHITE}GitHub Copilot${NC}"
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo ""

    print_step "Creating directories..."
    mkdir -p "$TARGET_DIR/.github/agents"
    sleep 0.3

    print_step "Copying agent files..."
    cp "$SCRIPT_DIR/platforms/github-copilot/agents/"*.md "$TARGET_DIR/.github/agents/" 2>/dev/null || true
    sleep 0.2

    print_step "Copying agent background skills to project..."
    copy_agent_skills_local "$TARGET_DIR/.github/skills"
    sleep 0.2

    echo ""
    print_success "GitHub Copilot installation complete!"
    print_info "Agents -> ${CYAN}$TARGET_DIR/.github/agents/${NC}"
    print_info "Skills -> ${CYAN}$TARGET_DIR/.github/skills/${NC}"
    echo ""
    echo -e "    ${YELLOW}Usage:${NC} Ask Copilot to ${GREEN}'migrate to Vue 3'${NC}"
}

install_codex() {
    echo ""
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo -e "    ${BLUE}Installing${NC} ${WHITE}Codex CLI${NC}"
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo ""

    print_step "Creating skill directories..."
    mkdir -p "$TARGET_DIR/.codex/skills/vue-migrator"
    mkdir -p "$TARGET_DIR/.codex/skills/vue-migration-planner"
    mkdir -p "$TARGET_DIR/.codex/skills/vue-migration-executor"
    mkdir -p "$TARGET_DIR/.codex/skills/vue-migration-reviewer"
    sleep 0.3

    print_step "Copying skill files..."
    local skills=("vue-migrator" "vue-migration-planner" "vue-migration-executor" "vue-migration-reviewer")
    for skill in "${skills[@]}"; do
        cp "$SCRIPT_DIR/platforms/codex/skills/$skill/SKILL.md" "$TARGET_DIR/.codex/skills/$skill/" 2>/dev/null || true
        print_info "${GREEN}${SYMBOL_CHECK}${NC} $skill"
        sleep 0.1
    done

    print_step "Copying agent background skills to project..."
    copy_agent_skills_local "$TARGET_DIR/.codex/skills"

    echo ""
    print_success "Codex CLI installation complete!"
    print_info "Skills -> ${CYAN}$TARGET_DIR/.codex/skills/${NC}"
    echo ""
    echo -e "    ${YELLOW}Usage:${NC} Ask Codex to ${GREEN}'migrate to Vue 3'${NC}"
    echo -e "    ${GRAY}Note:  Codex uses skills (subagent -> skill mapping)${NC}"
}

install_gemini() {
    echo ""
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo -e "    ${BLUE}Installing${NC} ${WHITE}Gemini CLI${NC}"
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo ""

    print_step "Creating directories..."
    mkdir -p "$TARGET_DIR/.gemini/agents"
    sleep 0.3

    print_step "Copying agent files..."
    cp "$SCRIPT_DIR/platforms/gemini/agents/"*.md "$TARGET_DIR/.gemini/agents/" 2>/dev/null || true
    sleep 0.2

    print_step "Copying agent background skills to project..."
    copy_agent_skills_local "$TARGET_DIR/.gemini/skills"
    sleep 0.2

    echo ""
    print_success "Gemini CLI installation complete!"
    print_info "Agents -> ${CYAN}$TARGET_DIR/.gemini/agents/${NC}"
    print_info "Skills -> ${CYAN}$TARGET_DIR/.gemini/skills/${NC}"
    echo ""
    echo -e "    ${YELLOW}Usage:${NC} Ask Gemini to ${GREEN}'migrate to Vue 3'${NC}"
}

install_opencode() {
    echo ""
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo -e "    ${BLUE}Installing${NC} ${WHITE}OpenCode${NC}"
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo ""

    print_step "Creating directories..."
    mkdir -p "$TARGET_DIR/.opencode/agents"
    sleep 0.3

    print_step "Copying agent files..."
    cp "$SCRIPT_DIR/platforms/opencode/agents/"*.md "$TARGET_DIR/.opencode/agents/" 2>/dev/null || true
    sleep 0.2

    print_step "Copying agent background skills to project..."
    copy_agent_skills_local "$TARGET_DIR/.opencode/skills"
    sleep 0.2

    echo ""
    print_success "OpenCode installation complete!"
    print_info "Agents -> ${CYAN}$TARGET_DIR/.opencode/agents/${NC}"
    print_info "Skills -> ${CYAN}$TARGET_DIR/.opencode/skills/${NC}"
    echo ""
    echo -e "    ${YELLOW}Usage:${NC} Ask OpenCode to ${GREEN}'migrate vue'${NC} or use ${CYAN}@vue-migrator${NC}"
}

install_antigravity() {
    echo ""
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo -e "    ${BLUE}Installing${NC} ${WHITE}Antigravity${NC}"
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo ""

    print_step "Creating directories..."
    mkdir -p "$TARGET_DIR/.agents/rules"
    sleep 0.3

    print_step "Copying rule file..."
    cp "$SCRIPT_DIR/platforms/antigravity/rules/vue-migration.md" "$TARGET_DIR/.agents/rules/" 2>/dev/null || true
    sleep 0.2

    print_step "Copying agent background skills to project..."
    copy_agent_skills_local "$TARGET_DIR/.agents/skills"
    sleep 0.2

    echo ""
    print_success "Antigravity installation complete!"
    print_info "Rules  -> ${CYAN}$TARGET_DIR/.agents/rules/${NC}"
    print_info "Skills -> ${CYAN}$TARGET_DIR/.agents/skills/${NC}"
    echo ""
    echo -e "    ${YELLOW}Usage:${NC} Ask Antigravity to ${GREEN}'migrate to Vue 3'${NC}"
}

install_cursor() {
    echo ""
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo -e "    ${BLUE}Installing${NC} ${WHITE}Cursor${NC}"
    echo -e "${CYAN}  ---------------------------------------------------------${NC}"
    echo ""

    print_step "Creating directories..."
    mkdir -p "$TARGET_DIR/.cursor/rules"
    sleep 0.3

    print_step "Copying rule file..."
    cp "$SCRIPT_DIR/platforms/cursor/rules/vue-migration.mdc" "$TARGET_DIR/.cursor/rules/" 2>/dev/null || true
    sleep 0.2

    print_step "Copying agent background skills to project..."
    copy_agent_skills_local "$TARGET_DIR/.cursor/rules" "mdc"
    sleep 0.2

    echo ""
    print_success "Cursor installation complete!"
    print_info "Rules -> ${CYAN}$TARGET_DIR/.cursor/rules/${NC}"
    echo ""
    echo -e "    ${YELLOW}Usage:${NC} Ask Cursor to ${GREEN}'migrate to Vue 3'${NC}"
    echo -e "    ${GRAY}Note:  Rule activates automatically when Vue migration is requested${NC}"
}

print_final_instructions() {
    echo ""
    echo ""
    echo -e "${GREEN}  =========================================================${NC}"
    echo -e "    ${GREEN}${SYMBOL_CHECK}${NC} ${GREEN}INSTALLATION COMPLETE${NC}"
    echo -e "${GREEN}  =========================================================${NC}"
    echo ""
    echo -e "  ${YELLOW}Next steps:${NC}"
    echo ""
    echo -e "    ${CYAN}1.${NC} Open your Vue 2 project in your AI assistant"
    echo -e "    ${CYAN}2.${NC} Ask it to migrate your project to Vue 3"
    echo -e "    ${CYAN}3.${NC} Review and approve the migration plan"
    echo -e "    ${CYAN}4.${NC} Let the assistant execute the migration"
    echo ""
    echo -e "  ${GRAY}---------------------------------------------------------${NC}"
    echo -e "    ${GRAY}${SYMBOL_DOT} https://github.com/anthropics/vue-agent-migrator${NC}"
    echo -e "  ${GRAY}---------------------------------------------------------${NC}"
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
main() {
    print_banner

    # Check if platforms directory exists
    if [ ! -d "$SCRIPT_DIR/platforms" ]; then
        print_error "Platforms directory not found. Make sure you're running from the correct location."
        exit 1
    fi

    # Convert target to absolute path
    TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
        echo ""
        print_error "Target directory does not exist: $TARGET_DIR"
        echo ""
        exit 1
    }

    echo ""
    echo -e "  ${GRAY}Target:${NC} ${CYAN}$TARGET_DIR${NC}"

    # Install skills globally (covers all platforms at once)
    install_skills

    # Interactive checkbox menu
    SELECTED_PLATFORMS=()
    show_checkbox_menu

    if [ ${#SELECTED_PLATFORMS[@]} -eq 0 ]; then
        echo -e "  ${GRAY}No platforms selected. Exiting.${NC}"
        echo ""
        exit 0
    fi

    for platform in "${SELECTED_PLATFORMS[@]}"; do
        case "$platform" in
            claude)   install_claude_code ;;
            copilot)  install_github_copilot ;;
            codex)    install_codex ;;
            gemini)   install_gemini ;;
            opencode) install_opencode ;;
            cursor)       install_cursor ;;
            antigravity) install_antigravity ;;
        esac
    done

    print_final_instructions
}

# Run
main
