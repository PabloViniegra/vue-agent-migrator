# Vue 2 → Vue 3 Migration Agent System

A multi-agent system for migrating Vue 2 applications to Vue 3. Supports multiple AI coding assistants.

## Supported Platforms

| Platform | Config Location | Command/Trigger |
|----------|-----------------|-----------------|
| **Claude Code** | `.claude/agents/`, `.claude/commands/` | `/vue-migrate` |
| **GitHub Copilot** | `.github/copilot-instructions.md` | "migrate to Vue 3" |
| **Codex CLI** | `.codex/AGENTS.md` | "migrate to Vue 3" |
| **Gemini CLI** | `.gemini/GEMINI.md` | "migrate to Vue 3" |
| **OpenCode** | `.opencode/agent/` | "migrate vue" or `@vue-migrator` |

## Quick Start

### 1. Clone or Download

```bash
git clone https://github.com/your-repo/vue-agent-migrator.git
cd vue-agent-migrator
```

### 2. Run Installer

You must provide the path to your Vue 2 project as a parameter.

#### Unix/macOS/Linux
```bash
chmod +x install.sh
./install.sh /path/to/your/vue2-project
```

#### Windows (PowerShell)
```powershell
.\install.ps1 C:\path\to\your\vue2-project
```

#### Windows (CMD)
```cmd
install.bat C:\path\to\your\vue2-project
```

### 3. Select Your Platform

The installer will prompt you to choose your AI assistant:

```
Select your AI coding assistant:

  1) Claude Code      - Anthropic's CLI tool
  2) GitHub Copilot   - GitHub's AI assistant
  3) Codex            - OpenAI's Codex CLI
  4) Gemini           - Google's Gemini CLI
  5) OpenCode         - Open source AI CLI
  6) All              - Install for all platforms

Enter your choice [1-6]:
```

### 4. Start Migration

In your Vue 2 project, use your AI assistant:

- **Claude Code**: `/vue-migrate`
- **Other platforms**: Ask "migrate to Vue 3"

## Installation Options

### Option A: Interactive Installer (Recommended)

```bash
# Unix/macOS/Linux
./install.sh /path/to/your/vue2-project

# Windows PowerShell
.\install.ps1 -TargetPath "C:\path\to\your\vue2-project"

# Windows CMD
install.bat C:\path\to\your\vue2-project
```

### Option B: Direct Installation (Claude Code)

```bash
# Navigate to your Vue 2 project
cd /path/to/your/vue2-project

# Create directories
mkdir -p .claude/agents .claude/commands

# Copy files (adjust source path as needed)
cp /path/to/vue-agent-migrator/platforms/claude-code/agents/*.md .claude/agents/
cp /path/to/vue-agent-migrator/platforms/claude-code/commands/*.md .claude/commands/

# For OpenCode
mkdir -p .opencode/agent
cp /path/to/vue-agent-migrator/platforms/opencode/agent/*.md .opencode/agent/
cp /path/to/vue-agent-migrator/platforms/opencode/agent/subagent/*.md .opencode/agent/
```

### Option C: Non-Interactive (CLI flags)

```bash
# Unix - Install specific platform
./install.sh /path/to/project
# Then enter: 1 (for Claude Code)

# Windows PowerShell - Direct platform selection
.\install.ps1 -TargetPath "C:\project" -Platform claude
.\install.ps1 -TargetPath "C:\project" -Platform copilot
.\install.ps1 -TargetPath "C:\project" -Platform all
```

## Overview

This system implements a phased migration workflow with strict approval gates:

```
┌─────────────────────────────────────────────────────────────────┐
│                        vue-migrator                              │
│                    (Primary Orchestrator)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │   planner    │───▶│   executor   │───▶│   reviewer   │       │
│  │              │    │              │    │              │       │
│  │  Analysis &  │    │Implementation│    │  Validation  │       │
│  │   Proposal   │    │              │    │   & QA       │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
│         │                   │                   │                │
│         ▼                   ▼                   ▼                │
│   Migration Plan      Code Changes       Review Report          │
│                                                                  │
│  ═══════════════════════════════════════════════════════════    │
│           ▲                                                      │
│           │                                                      │
│    USER APPROVAL                                                 │
│       REQUIRED                                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Workflow

### Phase 1: Planning
1. AI analyzes the project structure
2. Identifies Vue 2 patterns (Vuex, mixins, filters, Options API)
3. Audits dependencies for Vue 3 compatibility
4. Produces a Migration Plan document
5. **Waits for your approval**

### Phase 2: Execution (After Approval)
1. Updates dependencies (Vue 3, Router 4, Pinia)
2. Migrates Vuex stores to Pinia
3. Converts components to Composition API
4. Updates build tooling
5. Reports progress throughout

### Phase 3: Review
1. Validates no Vue 2 patterns remain
2. Checks build and type-check pass
3. Produces Final Review Report
4. Issues recommendation (Approve/Fix/Reject)

## What Gets Migrated

| From | To |
|------|-----|
| Vue 2 | Vue 3 |
| Vue Router 3 | Vue Router 4 |
| Vuex | Pinia |
| Options API | Composition API (`<script setup>`) |
| Mixins | Composables |
| Filters | Methods/Computed |
| Vue CLI | Vite (optional) |

### Breaking Changes Handled

- Event Bus (`$on`, `$off`, `$emit`)
- Filters (removed in Vue 3)
- `$children`, `$listeners`, `$scopedSlots`
- v-model changes
- `.native` modifier
- Custom directives API
- Async components syntax
- And more...

## Project Structure

```
vue-agent-migrator/
├── install.sh              # Unix/macOS/Linux installer
├── install.ps1             # Windows PowerShell installer
├── install.bat             # Windows CMD installer
├── platforms/
│   ├── claude-code/
│   │   ├── agents/         # Claude Code agents
│   │   └── commands/       # Claude Code commands
│   ├── github-copilot/
│   │   └── copilot-instructions.md
│   ├── codex/
│   │   └── instructions.md
│   ├── gemini/
│   │   └── GEMINI.md
│   └── opencode/
│       └── agents/
├── agents/                 # Standalone agent files
├── commands/               # Standalone command files
└── README.md
```

## Platform-Specific Notes

### Claude Code
- Uses multi-agent system with specialized roles
- Supports `/vue-migrate` command
- Agents: vue-migrator, vue-migration-planner, vue-migration-executor, vue-migration-reviewer

### GitHub Copilot
- Single instruction file in `.github/`
- Trigger: Ask "migrate to Vue 3"
- Follows same phased workflow

### Codex CLI (OpenAI)
- Instructions in `.codex/` directory
- Trigger: Ask "migrate to Vue 3"

### Gemini CLI
- Instructions in `.gemini/` directory
- Trigger: Ask "migrate to Vue 3"

### OpenCode
- Agent-based system in `.opencode/agent/` (primary agent + subagents)
- Primary agent: `vue-migrator.md`
- Subagents: `vue-migration-planner.md`, `vue-migration-executor.md`, `vue-migration-reviewer.md`
- Trigger: Ask "migrate vue" or use `@vue-migrator`
- Subagents can be invoked via `@vue-migration-planner`, `@vue-migration-executor`, `@vue-migration-reviewer`

## Success Criteria

A migration is successful when:

- [ ] Application builds and runs on Vue 3
- [ ] No deprecated APIs or tooling remain
- [ ] Pinia fully replaces Vuex (if applicable)
- [ ] Tooling is modern and consistent
- [ ] Review phase approves the migration

## Non-Goals

This system does NOT:

- Redesign UI/UX
- Add new features
- Modify backend/API
- Change business logic

## Troubleshooting

### Installer Issues

**Unix permission denied:**
```bash
chmod +x install.sh
```

**Windows execution policy:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\install.ps1
```

### Migration Issues

**AI skips planning phase:**
Explicitly ask: "Analyze this project and create a migration plan first"

**AI proceeds without approval:**
Add to instructions: "Wait for my explicit approval before making any changes"

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add/improve platform support
4. Submit a pull request

## License

MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2024 Vue Agent Migrator Contributors
