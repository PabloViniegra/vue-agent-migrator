# User Guide: Vue 2 → Vue 3 Migration Tool

Complete step-by-step guide for migrating your Vue 2 project to Vue 3 using this AI-powered tool.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Walkthrough](#detailed-walkthrough)
- [Complete Conversation Example](#complete-conversation-example)
- [Tips & Best Practices](#tips--best-practices)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

---

## Prerequisites

Before starting, ensure you have:

- ✅ A working Vue 2 project
- ✅ Node.js installed (v16+ recommended) — required for agent skill installation
- ✅ Git installed and configured
- ✅ Claude Code (or any supported AI assistant)
- ✅ Project backup or active version control

### Agent Skills

The installer automatically installs **agent skills** that give AI agents specialized Vue 3 migration knowledge. Skills are installed globally via `npx skills` and work across **all supported platforms** (Claude Code, OpenCode, Cursor, Gemini CLI, GitHub Copilot, Codex, Windsurf):

| Skill | What it provides |
|-------|-----------------|
| `vue` | Vue 3 Composition API patterns and best practices |
| `vue-i18n-skilld` | vue-i18n v8→v9 API changes and Composition API mode |
| `vitest-testing` | Vitest test patterns and async testing practices |

If `npx` is unavailable when you run the installer, it will print the three `npx skills add -g -y` commands for manual installation.

---

## Quick Start

```bash
# 1. Clone the migration tool
git clone https://github.com/your-repo/vue-agent-migrator.git
cd vue-agent-migrator

# 2. Run installer
./install.sh /path/to/your/vue2-project  # Unix/macOS
.\install.ps1 -TargetPath "C:\path"      # Windows

# 3. Select platform (e.g., Claude Code)

# 4. Open your project in Claude Code
cd /path/to/your/vue2-project
claude

# 5. Start migration
/vue-migrate

# 6. Approve Macro Analysis → Approve Execution Plan → Execute phases one by one
```

---

## Detailed Walkthrough

### Step 1: Backup Your Project

**⚠️ CRITICAL:** Always create a backup before migration:

```bash
cd /path/to/your/vue2-project
git add .
git commit -m "Pre-migration snapshot - Vue 2.x"
git tag pre-vue3-migration
```

### Step 2: Install the Tool

Choose your platform:

#### Unix/macOS/Linux
```bash
chmod +x install.sh
./install.sh /path/to/your/vue2-project
```

#### Windows (PowerShell)
```powershell
.\install.ps1 -TargetPath "C:\path\to\your\vue2-project"
```

#### Windows (CMD)
```cmd
install.bat C:\path\to\your\vue2-project
```

### Step 3: Select Your AI Platform

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

Select `1` for Claude Code.

### Step 4: Launch Claude Code

```bash
cd /path/to/your/vue2-project
claude
```

### Step 5: Start Migration

Execute the command:

```
/vue-migrate
```

### Step 6: Planning Phase

The agent will analyze your project and produce two planning outputs — each requiring your approval before proceeding.

**What it analyzes:**
- `package.json` - Dependencies and versions
- `src/` - Components, stores, router
- Vuex modules and state patterns
- Mixins, filters, and deprecated patterns

**Output 1:** Complete Migration Analysis & Trade-offs Document (Macro Analysis)

After you approve the Macro Analysis, the planner produces:

**Output 2:** Execution Plan — an ordered list of migration phases detected for your specific project, with rationale and complexity estimates. For example:

```
## Proposed Execution Plan

| # | Phase        | Rationale                                   | Complexity |
|---|--------------|---------------------------------------------|------------|
| 1 | dependencies | Foundation — required before anything else  | Low        |
| 2 | build-tool   | Required before running post-migration tests | Medium    |
| 3 | router       | Low coupling, safe early win                | Low        |
| 4 | stores       | Components depend on stores being ready     | High       |
| 5 | components   | Largest phase — depends on stores           | High       |

You can reorder, remove, or combine phases before approving.
Reply with your preferred order or "approved" to use this order.
```

### Step 7: Two Approval Steps

**Approval 1 — Macro Analysis:**

```
Do you approve this migration plan?

Please review the full analysis above and respond with:
- "approved" to proceed
- "rejected" or specific feedback to revise the plan

⚠️ I will NOT proceed with any code changes until you explicitly approve.
```

Respond: `approved`

**Approval 2 — Execution Plan:**

After the Execution Plan is presented, review the phases. You can:
- Reply `approved` to accept the proposed order
- Provide a reordered list (e.g., "skip build-tool, do router before stores")

Once approved, `migration-plan.json` is written to your project root to track migration progress.

### Step 8: Execution Phase (Phase by Phase)

The migration runs one phase at a time. After each phase completes, you will see a checkpoint prompt:

```
✅ Phase "router" completed.

Modified files:
- src/router/index.js
- src/router/guards.js

Next phase: "stores" (Vuex → Pinia) — estimated complexity: High

Reply "continue" to proceed, or "pause" to stop here.
```

Reply `continue` to proceed to the next phase, or `pause` to stop and resume later.

**If a phase fails**, you will see:

```
❌ Phase "stores" failed

File:   src/store/auth.js
Reason: [exact description of unrecognized pattern or error]

Options:
  A) Retry this phase — use if you have manually fixed the file
  B) Skip this phase — marks it for manual review, continues to next phase
  C) Abort migration — stops all execution, project left at current state

What would you like to do?
```

The tool waits for your choice — no automatic action is taken.

### Step 9: Review Phase

Automatic validation:
- ✅ No Vue 2 patterns remain
- ✅ Build succeeds
- ✅ Type-check passes
- ✅ Lint passes

**Output:** Final Migration Review Report

### Step 10: Test Your App

```bash
npm install
npm run dev
npm run build
```

---

## Complete Conversation Example

```
You:
/vue-migrate

Claude:
I will orchestrate your Vue 2 to Vue 3 migration. Starting with a full project analysis.

Analyzing...
✓ Found 45 components
✓ Found 8 Vuex modules
✓ Found 12 mixins
✓ vue-router detected
✓ vue-cli-service detected

[... Migration Analysis & Trade-offs Document ...]

Do you approve this migration plan?
- "approved" to proceed to the Execution Plan
- "rejected" or feedback to revise

You:
approved

Claude:
Macro Analysis approved. Here is the proposed Execution Plan for your project:

## Proposed Execution Plan

| # | Phase        | Rationale                                   | Complexity |
|---|--------------|---------------------------------------------|------------|
| 1 | dependencies | Foundation — required before anything else  | Low        |
| 2 | build-tool   | Required before running post-migration tests | Medium    |
| 3 | router       | Low coupling, safe early win                | Low        |
| 4 | stores       | Components depend on stores being ready     | High       |
| 5 | components   | Largest phase — depends on stores           | High       |

Phases NOT applicable to your project (skipped):
- ~~tests~~ — no test framework detected
- ~~class-components~~ — vue-property-decorator not found

You can reorder or remove phases. Reply "approved" to use this order.

You:
approved

Claude:
Execution Plan approved. Writing migration-plan.json to project root.

Starting Phase 1: "dependencies"...
  ✓ Updated package.json: vue 2.6 → 3.4.0
  ✓ Added pinia 2.1.0
  ✓ Removed vuex

✅ Phase "dependencies" completed.

Modified files:
- package.json

Next phase: "build-tool" (Vue CLI → Vite) — estimated complexity: Medium

Reply "continue" to proceed, or "pause" to stop here.

You:
continue

Claude:
Starting Phase 2: "build-tool"...
  ✓ Created vite.config.js
  ✓ Removed vue.config.js
  ✓ Updated package.json scripts

✅ Phase "build-tool" completed.

Modified files:
- vite.config.js
- vue.config.js (deleted)
- package.json

Next phase: "router" (Vue Router 3 → 4) — estimated complexity: Low

Reply "continue" to proceed, or "pause" to stop here.

You:
continue

[... phases 3, 4, 5 proceed similarly ...]

Claude:
All phases completed. Running final review...

✅ No Vue 2 patterns detected
✅ Build succeeds
✅ Type-check passes

Migration APPROVED

Next steps:
1. npm install
2. npm run dev
3. Test your application thoroughly
```

---

## Tips & Best Practices

### Before Migration

1. **Always backup**
   ```bash
   git commit -m "Pre-migration snapshot"
   ```

2. **Run tests**
   ```bash
   npm run test
   ```

3. **Document custom dependencies**

### During Migration

1. **Read the plan carefully**
2. **Don't approve if unsure**
3. **Ask specific questions**

### After Migration

1. **Test thoroughly**
   - All routes
   - User interactions
   - Forms and validation
   - API calls

2. **Check performance**
   ```bash
   npm run build
   # Check bundle size
   ```

3. **Update documentation**

---

## Troubleshooting

### Migration skips planning phase

**Solution:** Say explicitly:
```
Stop. First, create a migration plan without modifying any code.
```

### Migration paused or interrupted mid-execution

If the tool was closed or the session ended before all phases completed, relaunch it in your project directory. It will detect `migration-plan.json` in the project root and ask:

```
A previous migration is in progress. Last completed phase: router.
Resume from phase "stores"?
```

Reply `yes` to resume. If you want to start the migration from scratch, delete `migration-plan.json` from the project root first.

### Build fails after migration

```bash
# Clean install
rm -rf node_modules package-lock.json
npm install

# Check types
npm run type-check
```

### Components don't render

1. Open browser console (F12)
2. Check for errors
3. Verify imports are Vue 3 syntax

### State doesn't persist

```typescript
// Add persistence if needed
import { useLocalStorage } from '@vueuse/core'

const user = useLocalStorage('user', null)
```

---

## Additional Resources

- [Vue 3 Migration Guide](https://v3-migration.vuejs.org/)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Vue Router 4 Migration](https://router.vuejs.org/guide/migration/)
- [Vite Documentation](https://vitejs.dev/)

---

## License

MIT License

Copyright (c) 2024 Vue Agent Migrator Contributors

See [LICENSE](../LICENSE) file for full details.

---

Questions? Open an issue in the repository.
