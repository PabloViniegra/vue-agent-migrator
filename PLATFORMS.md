# Platform-Specific Agent Systems

This document explains how the Vue migration agents work on different AI coding platforms.

## Multi-Agent Systems

These platforms support multiple specialized agents working together:

### Claude Code
- **Configuration**: `.claude/agents/` (agent files) and `.claude/commands/` (slash commands)
- **Agent Type**: YAML frontmatter with `name`, `description`, `color`
- **Workflow**:
  - Primary agent: `vue-migrator` (orchestrator)
  - Subagents: `vue-migration-planner`, `vue-migration-executor`, `vue-migration-reviewer`
  - Invokes via Task tool or slash command `/vue-migrate`
  - Enforces phased workflow with approval gates
- **Trigger**: `/vue-migrate` or mention `@vue-migrator`

### OpenCode
- **Configuration**: `.opencode/agent/` (all agent files together)
- **Agent Type**: Markdown frontmatter with `mode: primary|subagent`
- **Workflow**:
  - Primary agent: `vue-migrator.md` (`mode: primary`)
  - Subagents: `vue-migration-planner.md`, `vue-migration-executor.md`, `vue-migration-reviewer.md` (`mode: subagent`)
  - Subagents copied to same directory as primary agent
  - Invokes via Task tool or `@mention`
  - Enforces phased workflow with approval gates
- **Permissions**: Fine-grained control per agent (tools, bash, edit)
- **Trigger**: "migrate vue", `@vue-migrator`, or `@vue-migration-*`

### Cursor
- **Configuration**: `.cursor/rules/vue-migration.mdc`
- **Agent Type**: Cursor rules (`.mdc` format with YAML frontmatter)
- **Workflow**:
  - Single rule file contains complete migration workflow
  - No agent hierarchy — one AI handles all phases
  - Two approval gates: Macro Analysis approval, then Execution Plan approval
  - Phase-by-phase execution with checkpoint prompts between phases
  - Creates and maintains `migration-plan.json` in project root
- **Rule activation**: `description` field enables automatic activation when Vue migration is requested
- **Trigger**: Ask "migrate to Vue 3" in Cursor

### Antigravity
- **Configuration**: `.agents/rules/vue-migration.md`
- **Agent Type**: Antigravity workspace rule (Markdown with YAML frontmatter: `name`, `description`)
- **Workflow**:
  - Single rule file contains complete migration workflow
  - No agent hierarchy — one AI handles all phases
  - Two approval gates: Macro Analysis approval, then Execution Plan approval
  - Phase-by-phase execution with checkpoint prompts between phases
  - Creates and maintains `migration-plan.json` in project root
- **Rule loading**: Antigravity loads all `.md` files in `.agents/rules/` as context rules
- **Trigger**: Ask "migrate to Vue 3" in Antigravity

## Single-Agent Systems

These platforms use a single instruction file instead of multiple agents:

### GitHub Copilot
- **Configuration**: `.github/copilot-instructions.md`
- **System**: Instructions file that provides context for all Copilot suggestions
- **Workflow**:
  - Single file contains complete migration workflow
  - No agent hierarchy - one AI handles all phases
  - Two approval gates: Macro Analysis approval, then Execution Plan approval
  - Phase-by-phase execution with checkpoint prompts between phases
  - Creates and maintains `migration-plan.json` in project root
- **Trigger**: Ask "migrate to Vue 3" in any Copilot interface

### OpenAI Codex CLI
- **Configuration**: `.codex/AGENTS.md` (IMPORTANT: File must be named `AGENTS.md`, not `instructions.md`)
- **System**: Codex reads `AGENTS.md` files from multiple locations:
  1. Global: `~/.codex/AGENTS.md`
  2. Project root: `.codex/AGENTS.md`
  3. Current directory: `.codex/AGENTS.md`
  4. Subdirectories (optional)
- **Workflow**:
  - Single file contains complete migration workflow
  - Codex concatenates multiple AGENTS.md files if found
  - No agent hierarchy - one AI handles all phases
  - Two approval gates: Macro Analysis approval, then Execution Plan approval
  - Phase-by-phase execution with checkpoint prompts between phases
  - Creates and maintains `migration-plan.json` in project root
- **Trigger**: Ask "migrate to Vue 3" in Codex CLI

### Google Gemini CLI
- **Configuration**: `.gemini/GEMINI.md`
- **System**: Gemini reads `GEMINI.md` files from multiple locations:
  1. Global: `~/.gemini/GEMINI.md`
  2. Project root: `.gemini/GEMINI.md`
  3. Current directory: `.gemini/GEMINI.md`
  4. Subdirectories (respects `.gitignore`)
- **Workflow**:
  - Single file contains complete migration workflow
  - Gemini concatenates multiple GEMINI.md files if found
  - No agent hierarchy - one AI handles all phases
  - Two approval gates: Macro Analysis approval, then Execution Plan approval
  - Phase-by-phase execution with checkpoint prompts between phases
  - Creates and maintains `migration-plan.json` in project root
- **Trigger**: Ask "migrate to Vue 3" in Gemini CLI

## Key Differences

| Feature | Claude Code | OpenCode | GitHub Copilot | Codex | Gemini | Cursor | Antigravity |
|----------|-------------|----------|----------------|--------|--------|--------|-------------|
| **Agent Files** | Multiple (agents/ + commands/) | Multiple (agent/) | Single | Single | Single | Single | Single |
| **Frontmatter** | YAML | Markdown (mode) | None | None | None | YAML (`.mdc`) | YAML (`.md`) |
| **Agent Hierarchy** | Yes (primary + subagents) | Yes (primary + subagents) | No | No | No | No | No |
| **Auto Workflow** | Phased, enforced by agents (2 approvals + phase checkpoints) | Phased, enforced by agents (2 approvals + phase checkpoints) | Manual, in instructions (2 approvals + phase checkpoints) | Manual, in instructions (2 approvals + phase checkpoints) | Manual, in instructions (2 approvals + phase checkpoints) | Manual, in instructions (2 approvals + phase checkpoints) | Manual, in instructions (2 approvals + phase checkpoints) |
| **Permissions** | Via agent definition | Per-agent, per-tool | None | None | None | None | None |
| **Trigger Method** | `/vue-migrate`, `@mention` | `@mention`, text | Text | Text | Text | Text (auto-attach via description) | Text |
| **File Naming** | Flexible | Flexible | `copilot-instructions.md` | `AGENTS.md` | `GEMINI.md` | `*.mdc` in `.cursor/rules/` | `*.md` in `.agents/rules/` |

## File Installation Summary

### Multi-Agent Platforms

```
Claude Code:
  .claude/
    agents/
      vue-migrator.md
      vue-migration-planner.md
      vue-migration-executor.md
      vue-migration-reviewer.md
    commands/
      vue-migrate.md

OpenCode:
  .opencode/
    agent/
      vue-migrator.md              (mode: primary)
      vue-migration-planner.md        (mode: subagent)
      vue-migration-executor.md        (mode: subagent)
      vue-migration-reviewer.md        (mode: subagent)
```

### Single-Agent Platforms

```
GitHub Copilot:
  .github/
    copilot-instructions.md

OpenAI Codex CLI:
  .codex/
    AGENTS.md                    (IMPORTANT: Not instructions.md)

Google Gemini CLI:
  .gemini/
    GEMINI.md

Cursor:
  .cursor/
    rules/
      vue-migration.mdc

Antigravity:
  .agents/
    rules/
      vue-migration.md
```

## Migration Workflow Comparison

### Multi-Agent Systems (Claude Code, OpenCode)

**Automatic Phase Enforcement:**
1. User triggers migration
2. Orchestrator agent (vue-migrator) invokes planner agent
3. Planner analyzes and produces **Macro Analysis Document**
4. Orchestrator presents Macro Analysis and **automatically waits for Approval #1**
5. After Macro Analysis approval, planner produces **Execution Plan** — an ordered list of phases with rationale and complexity, based on the project's dependencies
6. Orchestrator presents Execution Plan; user can reorder or remove phases, then gives **Approval #2**
7. Orchestrator writes `migration-plan.json` to project root; begins phase loop
8. For each approved phase: orchestrator invokes executor, executor runs phase in isolation, orchestrator presents checkpoint prompt and **waits for "continue"**
9. On failure: orchestrator presents failure report (file + reason) and waits for retry/skip/abort choice
10. After all phases complete (or are skipped), orchestrator invokes reviewer agent
11. Reviewer reads `migration-plan.json`, validates result, produces Review Report
12. Final recommendation provided

**Benefits:**
- Clear separation of concerns
- Automatic workflow enforcement
- Each agent has specialized permissions
- User can switch between agents during session
- Phase-level granularity: pause, resume, or skip individual phases

### Single-Agent Systems (Copilot, Codex, Gemini)

**Manual Phase Enforcement:**
1. User triggers migration
2. AI analyzes project and produces **Macro Analysis (Migration Plan)**
3. AI **asks** for user approval (Approval #1)
4. User must explicitly approve
5. AI presents **Execution Plan** — an ordered list of phases; user can reorder or remove phases
6. User approves Execution Plan (Approval #2); AI writes `migration-plan.json` to project root
7. AI executes Phase 1, presents checkpoint prompt, **waits for "continue"**
8. Repeat for each phase; on failure: report file + reason, wait for retry/skip/abort choice
9. After all phases: AI validates result, reads `migration-plan.json`, produces Review Report
10. Final recommendation provided

**Benefits:**
- Simpler setup (single file)
- Consistent behavior (one AI instance)
- Easier to modify workflow
- Less context switching

## Important Notes

### For Codex Users
- ⚠️ **CRITICAL**: File must be named `AGENTS.md`, NOT `instructions.md`
- Codex reads files in this order: `AGENTS.override.md` → `AGENTS.md`
- You can use `AGENTS.override.md` for project-specific overrides
- Codex concatenates files from project root down to current directory

### For Gemini Users
- File is named `GEMINI.md`
- Gemini loads from: global (`.gemini/GEMINI.md`) → project root → current directory
- Use `/memory show` command to see loaded context
- Use `/memory refresh` to reload context files
- Can modularize with `@file.md` imports in GEMINI.md

### For GitHub Copilot Users
- File is named `copilot-instructions.md`
- Instructions are automatically loaded by Copilot for this repository
- Works in VS Code, GitHub web, JetBrains, Xcode, etc.
- Instructions are invisible to user, only affect AI suggestions

## Best Practices

1. **Always test after installation**: Verify the file is in the correct location with correct name
2. **Review instructions**: Read the installed file to ensure content is correct
3. **Check platform docs**: Each platform has specific behaviors and features
4. **Use version control**: Commit the instruction file so it persists
5. **Platform-specific**: Customize instructions for each platform's capabilities

## Troubleshooting

### Codex not loading instructions
- Verify file is named `AGENTS.md` (not `instructions.md`)
- Check file is in `.codex/` directory at project root
- Run `codex /memory show` to see loaded context
- Run `codex /memory refresh` to reload context files

### Gemini not loading instructions
- Verify file is named `GEMINI.md`
- Check file is in `.gemini/` directory
- Check `.gitignore` isn't excluding `.gemini/`
- Run `gemini /memory` to view context hierarchy

### Copilot not using instructions
- Verify file is at `.github/copilot-instructions.md`
- Check Copilot extension is active in your IDE
- Try restarting your IDE
- Check Copilot settings are not blocking custom instructions

## References

- [Claude Code Documentation](https://docs.anthropic.com/)
- [OpenCode Documentation](https://opencode.ai/docs/agents/)
- [GitHub Copilot Custom Instructions](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
- [OpenAI Codex Documentation](https://developers.openai.com/codex/guides/agents-md/)
- [Google Gemini CLI Documentation](https://google-gemini.github.io/gemini-cli/docs/cli/gemini-md.html)
