# Vue 2 → Vue 3 Migration Agent System

A multi-agent system for migrating Vue 2 applications to Vue 3. Supports multiple AI coding assistants.

## Supported Platforms

| Platform | Config Location | Command/Trigger |
|----------|-----------------|-----------------|
| **Claude Code** | `.claude/agents/`, `.claude/commands/` | `/vue-migrate` |
| **GitHub Copilot** | `.github/agents/*.md` | "migrate to Vue 3" |
| **Gemini CLI** | `.gemini/agents/*.md` | "migrate to Vue 3" |
| **Codex CLI** | `.codex/skills/*/SKILL.md` | "migrate to Vue 3" |
| **OpenCode** | `.opencode/agents/*.md` | "migrate vue" or `@vue-migrator` |

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

### 5. Two-Step Planning Approval

The migration uses a two-approval planning flow:

1. **Macro Analysis approval** — Review the full project analysis and approve before any execution begins
2. **Execution Plan approval** — Review and optionally reorder/remove the proposed phases, then approve

### 6. Phase-by-Phase Execution

After both approvals, the migration runs one phase at a time. After each phase completes you will see a checkpoint prompt listing modified files and asking you to `continue` or `pause`. A `migration-plan.json` file is written to your project root to track progress — if the session is interrupted, relaunching the tool will detect this file and offer to resume from the last incomplete phase.

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

### Option B: Direct Installation (Manual)

#### Claude Code

```bash
# Navigate to your Vue 2 project
cd /path/to/your/vue2-project

# Create directories
mkdir -p .claude/agents .claude/commands

# Copy files (adjust source path as needed)
cp /path/to/vue-agent-migrator/platforms/claude-code/agents/*.md .claude/agents/
cp /path/to/vue-agent-migrator/platforms/claude-code/commands/*.md .claude/commands/
```

#### GitHub Copilot

```bash
# Navigate to your Vue 2 project
cd /path/to/your/vue2-project

# Create directory
mkdir -p .github/agents

# Copy files
cp /path/to/vue-agent-migrator/platforms/github-copilot/agents/*.md .github/agents/
```

#### Gemini CLI

```bash
# Navigate to your Vue 2 project
cd /path/to/your/vue2-project

# Create directory
mkdir -p .gemini/agents

# Copy files
cp /path/to/vue-agent-migrator/platforms/gemini/agents/*.md .gemini/agents/
```

#### Codex CLI

**Note:** Codex uses a skill-based model and doesn't support subagents yet. Each subagent is mapped to a skill.

```bash
# Navigate to your Vue 2 project
cd /path/to/your/vue2-project

# Create directories for each skill
mkdir -p .codex/skills/vue-migrator
mkdir -p .codex/skills/vue-migration-planner
mkdir -p .codex/skills/vue-migration-executor
mkdir -p .codex/skills/vue-migration-reviewer

# Copy files (each subagent becomes a skill)
cp /path/to/vue-agent-migrator/platforms/codex/skills/vue-migrator/SKILL.md .codex/skills/vue-migrator/
cp /path/to/vue-agent-migrator/platforms/codex/skills/vue-migration-planner/SKILL.md .codex/skills/vue-migration-planner/
cp /path/to/vue-agent-migrator/platforms/codex/skills/vue-migration-executor/SKILL.md .codex/skills/vue-migration-executor/
cp /path/to/vue-agent-migrator/platforms/codex/skills/vue-migration-reviewer/SKILL.md .codex/skills/vue-migration-reviewer/
```

#### OpenCode

```bash
# Navigate to your Vue 2 project
cd /path/to/your/vue2-project

# Create directory
mkdir -p .opencode/agents

# Copy all agents (both primary and subagents go in the same folder)
cp /path/to/vue-agent-migrator/platforms/opencode/agents/*.md .opencode/agents/

# Note: The distinction between primary and subagents is made via the 'mode' property in frontmatter
# - mode: primary  (vue-migrator.md)
# - mode: subagent (vue-migration-planner.md, vue-migration-executor.md, vue-migration-reviewer.md)
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

### Phase 1: Planning — Macro Analysis
1. AI analyzes the project structure
2. Identifies Vue 2 patterns (Vuex, mixins, filters, Options API)
3. Audits dependencies for Vue 3 compatibility
4. Produces a **Migration Analysis & Trade-offs Document**
5. **Waits for your approval (Approval #1)**

### Phase 2: Planning — Execution Plan
1. After Macro Analysis approval, the planner proposes an ordered set of migration phases
2. Phases are detected dynamically based on your project's dependencies
3. You can reorder, remove, or combine phases before approving
4. **Waits for your approval (Approval #2)**
5. Once approved, `migration-plan.json` is written to your project root to track progress

### Phase 3: Execution (Phase by Phase)
For each approved phase (e.g., dependencies → build-tool → router → stores → components):
1. Executes that phase in isolation
2. After each phase: lists modified files and waits for you to `continue` or `pause`
3. On failure: stops immediately, reports the file and reason, offers retry / skip / abort

### Phase 4: Review
1. Validates no Vue 2 patterns remain
2. Checks build and type-check pass
3. Reads `migration-plan.json` to flag any skipped or failed phases as blocking issues
4. Produces Final Review Report
5. Issues recommendation (Approve / Approve with fixes / Reject)

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
├── install.sh                      # Unix/macOS/Linux installer
├── install.ps1                     # Windows PowerShell installer
├── install.bat                     # Windows CMD installer
├── platforms/
│   ├── claude-code/
│   │   ├── agents/                 # Claude Code agents
│   │   │   ├── vue-migrator.md
│   │   │   ├── vue-migration-planner.md
│   │   │   ├── vue-migration-executor.md
│   │   │   └── vue-migration-reviewer.md
│   │   └── commands/
│   │       └── vue-migrate.md      # /vue-migrate command
│   ├── github-copilot/
│   │   └── agents/                 # GitHub Copilot agents
│   │       ├── vue-migrator.md
│   │       ├── vue-migration-planner.md
│   │       ├── vue-migration-executor.md
│   │       └── vue-migration-reviewer.md
│   ├── gemini/
│   │   └── agents/                 # Gemini CLI agents
│   │       ├── vue-migrator.md
│   │       ├── vue-migration-planner.md
│   │       ├── vue-migration-executor.md
│   │       └── vue-migration-reviewer.md
│   ├── codex/
│   │   └── skills/                 # Codex skills (subagent → skill)
│   │       ├── vue-migrator/
│   │       │   └── SKILL.md
│   │       ├── vue-migration-planner/
│   │       │   └── SKILL.md
│   │       ├── vue-migration-executor/
│   │       │   └── SKILL.md
│   │       └── vue-migration-reviewer/
│   │           └── SKILL.md
│   └── opencode/
│       └── agents/                 # All agents (mode property distinguishes primary/subagent)
│           ├── vue-migrator.md                 # mode: primary
│           ├── vue-migration-planner.md        # mode: subagent
│           ├── vue-migration-executor.md       # mode: subagent
│           └── vue-migration-reviewer.md       # mode: subagent
├── agents/                         # Standalone/source agent files
│   ├── vue-migrator.md
│   ├── vue-migration-planner.md
│   ├── vue-migration-executor.md
│   └── vue-migration-reviewer.md
├── commands/                       # Standalone command files
│   └── vue-migrate.md
└── README.md
```

## Platform-Specific Notes

### Claude Code
- **Location**: `.claude/agents/*.md` and `.claude/commands/*.md`
- Uses multi-agent system with specialized roles
- Supports `/vue-migrate` command
- **Agents**:
  - `vue-migrator.md` (orchestrator)
  - `vue-migration-planner.md` (analysis)
  - `vue-migration-executor.md` (implementation)
  - `vue-migration-reviewer.md` (validation)
- **Command**: `/vue-migrate` triggers the orchestrator
- Native support for subagents with full context sharing

### GitHub Copilot
- **Location**: `.github/agents/*.md`
- Each agent is a separate markdown file
- **Agents**:
  - `vue-migrator.md`
  - `vue-migration-planner.md`
  - `vue-migration-executor.md`
  - `vue-migration-reviewer.md`
- **Trigger**: Ask "migrate to Vue 3" or reference specific agent
- Follows same phased workflow
- GitHub Copilot will read all agent files and use appropriate context

### Gemini CLI
- **Location**: `.gemini/agents/*.md`
- Each agent is a separate markdown file in the agents directory
- **Agents**:
  - `vue-migrator.md`
  - `vue-migration-planner.md`
  - `vue-migration-executor.md`
  - `vue-migration-reviewer.md`
- **Trigger**: Ask "migrate to Vue 3"
- Gemini reads agent context from the `.gemini/agents/` directory

### Codex CLI (OpenAI)
- **Location**: `.codex/skills/[skill-name]/SKILL.md`
- **Important**: Codex uses a **skill-based model** and doesn't support subagents
- Each subagent must be mapped to a separate skill
- **Skills** (subagent → skill mapping):
  - `.codex/skills/vue-migrator/SKILL.md` (orchestrator)
  - `.codex/skills/vue-migration-planner/SKILL.md` (analysis)
  - `.codex/skills/vue-migration-executor/SKILL.md` (implementation)
  - `.codex/skills/vue-migration-reviewer/SKILL.md` (validation)
- **Trigger**: Ask "migrate to Vue 3" or invoke specific skill
- The orchestrator skill coordinates calling other skills sequentially

### OpenCode
- **Location**: `.opencode/agents/*.md` (all agents in same directory)
- Agent-based system with native subagent support
- **Distinction by `mode` property**:
  - `mode: primary` → Primary agent (`vue-migrator.md`)
  - `mode: subagent` → Subagents (planner, executor, reviewer)
- **All agents** in `.opencode/agents/`:
  - `vue-migrator.md` (`mode: primary`)
  - `vue-migration-planner.md` (`mode: subagent`)
  - `vue-migration-executor.md` (`mode: subagent`)
  - `vue-migration-reviewer.md` (`mode: subagent`)
- **Trigger**: Ask "migrate vue" or use `@vue-migrator`
- Subagents can be invoked directly: `@vue-migration-planner`, `@vue-migration-executor`, `@vue-migration-reviewer`
- Switch between primary agents using Tab
- Reference: https://opencode.ai/docs/agents/

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

**Migration paused or interrupted mid-execution:**
Relaunch the tool in your project directory. It will detect `migration-plan.json` in the project root and offer to resume from the last incomplete phase. If you want to start fresh, delete `migration-plan.json` first.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add/improve platform support
4. Submit a pull request

## License

MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2024 Vue Agent Migrator Contributors
