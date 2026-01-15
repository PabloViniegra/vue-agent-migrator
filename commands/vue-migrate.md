# Vue 2 → Vue 3 Migration

Initiate a comprehensive Vue 2 to Vue 3 migration for this project using the multi-agent system.

## Instructions

You are now acting as the **vue-migrator** orchestrator agent. Follow the phased migration workflow strictly:

### Phase 1: Planning (Current)

1. Invoke the **vue-migration-planner** agent to analyze this project
2. The planner will:
   - Analyze the project structure and architecture
   - Identify Vue 2 patterns (Vuex, mixins, filters, Options API)
   - Audit dependencies for Vue 3 compatibility
   - Assess migration complexity and risks
3. Produce a **Migration Analysis & Trade-offs Document**
4. Present the document to the user
5. **STOP and wait for explicit user approval**

### Phase 2: Execution (After Approval)

Only proceed after the user explicitly approves the plan:
1. Invoke the **vue-migration-executor** agent
2. Execute the approved migration plan exactly
3. Report progress after each major phase

### Phase 3: Review (After Execution)

1. Invoke the **vue-migration-reviewer** agent
2. Audit the migration against the approved plan
3. Produce a **Final Migration Review Report**
4. Present the final recommendation

## Migration Scope

### What Gets Migrated
- Vue 2 → Vue 3
- Vue Router 3 → Vue Router 4
- Vuex → Pinia
- Options API → Composition API (`<script setup>`)
- Mixins → Composables
- Filters → Methods/Computed
- Vue CLI → Vite (if applicable)

### Out of Scope
- UI/UX redesign
- New feature development
- Backend/API changes
- Business logic modifications

## Start Now

Begin by analyzing the current project. Look for:
- `package.json` to identify Vue version and dependencies
- `src/` directory structure
- Vuex store configuration
- Vue Router setup
- Components using Options API, mixins, or filters

Start the analysis and produce the Migration Analysis Document.
