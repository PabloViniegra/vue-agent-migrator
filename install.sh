#!/bin/bash

#######################################
# Vue 2 → Vue 3 Migration Tool Installer
# Supports: Claude Code, GitHub Copilot, Codex, Gemini, OpenCode
#######################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directory (current working directory by default)
TARGET_DIR="${1:-.}"

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║       Vue 2 → Vue 3 Migration Tool Installer             ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✔${NC} $1"
}

print_error() {
    echo -e "${RED}✖${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

show_menu() {
    echo ""
    echo -e "${YELLOW}Select your AI coding assistant:${NC}"
    echo ""
    echo "  1) Claude Code      - Anthropic's CLI tool"
    echo "  2) GitHub Copilot   - GitHub's AI assistant"
    echo "  3) Codex            - OpenAI's Codex CLI"
    echo "  4) Gemini           - Google's Gemini CLI"
    echo "  5) OpenCode         - Open source AI CLI"
    echo "  6) All              - Install for all platforms"
    echo ""
    echo "  0) Exit"
    echo ""
    read -p "Enter your choice [1-6]: " choice
}

install_claude_code() {
    print_step "Installing for Claude Code..."

    mkdir -p "$TARGET_DIR/.claude/agents"
    mkdir -p "$TARGET_DIR/.claude/commands"

    cp "$SCRIPT_DIR/platforms/claude-code/agents/"*.md "$TARGET_DIR/.claude/agents/" 2>/dev/null || true
    cp "$SCRIPT_DIR/platforms/claude-code/commands/"*.md "$TARGET_DIR/.claude/commands/" 2>/dev/null || true

    print_success "Claude Code configuration installed"
    echo "    Agents:   $TARGET_DIR/.claude/agents/"
    echo "    Commands: $TARGET_DIR/.claude/commands/"
    echo ""
    echo -e "    ${CYAN}Usage: Run ${YELLOW}/vue-migrate${CYAN} in Claude Code${NC}"
}

install_github_copilot() {
    print_step "Installing for GitHub Copilot..."

    mkdir -p "$TARGET_DIR/.github"

    cp "$SCRIPT_DIR/platforms/github-copilot/copilot-instructions.md" "$TARGET_DIR/.github/" 2>/dev/null || true

    print_success "GitHub Copilot configuration installed"
    echo "    Instructions: $TARGET_DIR/.github/copilot-instructions.md"
    echo ""
    echo -e "    ${CYAN}Usage: Ask Copilot to ${YELLOW}\"migrate to Vue 3\"${NC}"
}

install_codex() {
    print_step "Installing for Codex CLI..."

    mkdir -p "$TARGET_DIR/.codex"

    cp "$SCRIPT_DIR/platforms/codex/instructions.md" "$TARGET_DIR/.codex/" 2>/dev/null || true

    print_success "Codex CLI configuration installed"
    echo "    Instructions: $TARGET_DIR/.codex/instructions.md"
    echo ""
    echo -e "    ${CYAN}Usage: Ask Codex to ${YELLOW}\"migrate to Vue 3\"${NC}"
}

install_gemini() {
    print_step "Installing for Gemini CLI..."

    mkdir -p "$TARGET_DIR/.gemini"

    cp "$SCRIPT_DIR/platforms/gemini/GEMINI.md" "$TARGET_DIR/.gemini/" 2>/dev/null || true

    print_success "Gemini CLI configuration installed"
    echo "    Instructions: $TARGET_DIR/.gemini/GEMINI.md"
    echo ""
    echo -e "    ${CYAN}Usage: Ask Gemini to ${YELLOW}\"migrate to Vue 3\"${NC}"
}

install_opencode() {
    print_step "Installing for OpenCode..."

    mkdir -p "$TARGET_DIR/.opencode/agents"

    cp "$SCRIPT_DIR/platforms/opencode/agents/"*.md "$TARGET_DIR/.opencode/agents/" 2>/dev/null || true

    print_success "OpenCode configuration installed"
    echo "    Agents: $TARGET_DIR/.opencode/agents/"
    echo ""
    echo -e "    ${CYAN}Usage: Ask OpenCode to ${YELLOW}\"migrate vue\"${NC}"
}

install_all() {
    print_step "Installing for all platforms..."
    echo ""
    install_claude_code
    echo ""
    install_github_copilot
    echo ""
    install_codex
    echo ""
    install_gemini
    echo ""
    install_opencode
}

print_final_instructions() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Open your Vue 2 project in your AI assistant"
    echo "  2. Ask it to migrate your project to Vue 3"
    echo "  3. Review and approve the migration plan"
    echo "  4. Let the assistant execute the migration"
    echo ""
    echo -e "Documentation: ${CYAN}https://github.com/your-repo/vue-agent-migrator${NC}"
    echo ""
}

# Main
main() {
    print_banner

    # Check if platforms directory exists
    if [ ! -d "$SCRIPT_DIR/platforms" ]; then
        print_error "Platforms directory not found. Make sure you're running from the correct location."
        exit 1
    fi

    # Convert target to absolute path
    TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
        print_error "Target directory does not exist: $TARGET_DIR"
        exit 1
    }

    echo -e "Target directory: ${CYAN}$TARGET_DIR${NC}"

    show_menu

    case $choice in
        1)
            install_claude_code
            ;;
        2)
            install_github_copilot
            ;;
        3)
            install_codex
            ;;
        4)
            install_gemini
            ;;
        5)
            install_opencode
            ;;
        6)
            install_all
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please run the script again."
            exit 1
            ;;
    esac

    print_final_instructions
}

# Run main function
main
