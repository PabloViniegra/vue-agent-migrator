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
- ✅ Node.js installed (v16+ recommended)
- ✅ Git installed and configured
- ✅ Claude Code (or any supported AI assistant)
- ✅ Project backup or active version control

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

# 6. Review plan → Approve → Done!
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

The agent will analyze your project:

**What it analyzes:**
- `package.json` - Dependencies and versions
- `src/` - Components, stores, router
- Vuex modules and state patterns
- Mixins, filters, and deprecated patterns

**Output:** Complete Migration Analysis Document

### Step 7: Review & Approve

The agent will ask:

```
Do you approve this migration plan?

Please review the full analysis above and respond with:
- "approved" to proceed with execution
- "rejected" or specific feedback to revise the plan

⚠️ I will NOT proceed with any code changes until you explicitly approve.
```

Respond: `approved`

### Step 8: Execution Phase

The agent will migrate:

1. **Dependencies** - Vue 3, Router 4, Pinia
2. **Entry Point** - `main.js` → `main.ts`
3. **Router** - Vue Router 3 → 4
4. **Stores** - Vuex → Pinia
5. **Components** - Options API → Composition API
6. **Mixins** - → Composables
7. **Filters** - → Methods/Utils
8. **Build** - Vue CLI → Vite

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
I will orchestrate your Vue 2 to Vue 3 migration through three phases:
1. Planning Phase
2. Execution Phase (requires approval)
3. Review Phase

Starting analysis...

✓ Found 45 components
✓ Found 8 Vuex modules
✓ Found 12 mixins

[... Migration Plan Document ...]

Do you approve this plan?

You:
approved

Claude:
✅ Plan approved. Proceeding...

[Phase 1] Updating dependencies...
  ✓ Vue 2.6 → 3.4.0
  ✓ Added Pinia 2.1.0

[Phase 2] Migrating stores...
  ✓ user store → Pinia
  ✓ auth store → Pinia

[Phase 3] Migrating components...
  ✓ 45 components → Composition API

Migration complete!

Running validation...
✅ All checks passed

Migration APPROVED 🎉

Next steps:
1. npm install
2. npm run dev
3. Test your app
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

Questions? Open an issue in the repository.
