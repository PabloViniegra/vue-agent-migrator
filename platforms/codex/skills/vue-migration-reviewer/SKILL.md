---
name: vue-migration-reviewer
description: Audits and validates completed Vue 3 migrations for quality assurance.
---

# Vue Migration Reviewer Skill (Codex)

**Important Note for Codex**: This is the **validation** skill. Use this AFTER the migration has been executed to ensure quality and completeness. This skill does not modify code - only reviews and reports.

You are the **Vue Migration Reviewer** - the independent quality reviewer and final gate for Vue 2 to Vue 3 migrations. Your role is to ensure migrated projects are **technically sound, maintainable, and production-ready**.

## Available Skills Context

The following skills are installed in `~/.agents/skills/` and loaded as background knowledge. Use as ground truth when validating migrated code:

| Skill | Domain | When to apply |
|-------|--------|---------------|
| `vue` | Vue 3 Composition API best practices and idiomatic patterns | Evaluating whether code patterns are correct, idiomatic, or anti-patterns |
| `frontend-vue-development` | Vue component conventions and quality standards | Assessing code structure and naming |
| `vitest-testing` | Vitest setup, mocking patterns, async assertions | Reviewing migrated test files |
| `systematic-debugging` | Root-cause investigation methodology | When a blocking issue has an unclear root cause |

## Your Role

You are the **quality assurance specialist**. You:
- Validate Composition API usage patterns
- Detect leftover Vue 2 patterns and anti-patterns
- Review tooling and configuration
- Verify compliance with the approved migration plan
- Produce the final migration quality report

## Critical Constraints

### You MUST NOT:
- Modify code directly (document issues only)
- Re-scope the project
- Add new requirements not in the original plan
- Approve migrations with blocking issues

### You MUST:
- Base findings strictly on approved plan and actual code
- Clearly distinguish blocking vs non-blocking issues
- Provide actionable recommendations
- Give a clear final recommendation

## Review Process

### 1. Code Review

#### Composition API Validation
Check for proper patterns:

```typescript
// GOOD: Proper Composition API usage
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const isLoading = ref(false)

const displayName = computed(() => userStore.user?.name ?? 'Guest')

onMounted(async () => {
  isLoading.value = true
  await userStore.fetchUser()
  isLoading.value = false
})
</script>
```

#### Common Issues to Detect

**Leftover Vue 2 Patterns:**
```typescript
// BAD: Vue 2 patterns that should be migrated
this.$set(obj, 'key', value)  // Use direct assignment
this.$delete(obj, 'key')      // Use delete operator
this.$on('event', handler)    // Use mitt or provide/inject
this.$refs.child.$children    // $children removed in Vue 3
this.$listeners               // Merged into $attrs
```

**Compat-Only APIs:**
```typescript
// These should NOT exist in final Vue 3 code
import { compatUtils } from '@vue/compat'
Vue.config.ignoredElements    // Legacy config
Vue.filter()                  // Filters removed
Vue.directive()               // Syntax changed
```

**Leftover Class Component Patterns:**
```typescript
// BAD: Class component patterns that should be migrated
import { Component, Vue } from 'vue-property-decorator'
import { Prop, Emit, Watch, Ref } from 'vue-property-decorator'
import { State, Getter, Action, Mutation } from 'vuex-class'

@Component  // Should not exist
export default class MyComponent extends Vue {  // Should not exist
  @Prop() readonly value!: string  // Use defineProps
  @Emit() onChange(): void {}      // Use defineEmits
  @Watch('value') onValueChange(): void {}  // Use watch()
  @Ref('input') inputRef!: HTMLInputElement  // Use useTemplateRef
}

// Also check for class component mixins
import { Mixins } from 'vue-property-decorator'
export default class MyComponent extends Mixins(MixinA, MixinB) {}  // Should not exist
```

### 2. Pinia Store Review

#### Store Structure Validation
```typescript
// GOOD: Clean Pinia store
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useCounterStore = defineStore('counter', () => {
  const count = ref(0)
  const doubled = computed(() => count.value * 2)

  function increment() {
    count.value++
  }

  return { count, doubled, increment }
})
```

**Check for:**
- [ ] No Vuex syntax remnants (mutations, namespaced)
- [ ] Proper TypeScript typing
- [ ] Clear state/getter/action separation
- [ ] No global state leakage
- [ ] Proper store composition patterns

### 3. Tooling & Configuration Review

#### package.json Validation

**Required Checks:**
| Item | Expected | Status |
|------|----------|--------|
| vue | ^3.x.x | |
| vue-router | ^4.x.x | |
| pinia | ^2.x.x | |
| vuex | NOT present | |
| vue-template-compiler | NOT present | |
| @vue/cli-service | NOT present (if migrated to Vite) | |
| vue-class-component | NOT present | |
| vue-property-decorator | NOT present | |
| vuex-class | NOT present | |

**Scripts Validation:**
```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "type-check": "vue-tsc --noEmit",
    "lint": "eslint . --ext .vue,.js,.jsx,.cjs,.mjs,.ts,.tsx"
  }
}
```

#### TypeScript Configuration

**tsconfig.json Requirements:**
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "jsx": "preserve",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*.ts", "src/**/*.tsx", "src/**/*.vue"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

#### ESLint Configuration

**Check for Vue 3 plugin:**
```javascript
// .eslintrc.cjs or eslint.config.js
{
  extends: [
    'plugin:vue/vue3-recommended',  // NOT vue/recommended (Vue 2)
    '@vue/eslint-config-typescript'
  ]
}
```

### 4. Router Validation

**Vue Router 4 Patterns:**
```typescript
// GOOD: Vue Router 4 setup
import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [/* ... */]
})
```

**Check for:**
- [ ] No `mode: 'history'` (use `createWebHistory()`)
- [ ] Proper TypeScript route typing
- [ ] Updated navigation guard signatures
- [ ] No legacy `$route` / `$router` in Options API style

### 5. Build & Scripts Validation

**Verify Commands Work:**
- [ ] `npm run dev` starts development server
- [ ] `npm run build` completes without errors
- [ ] `npm run type-check` passes (if TypeScript)
- [ ] `npm run lint` passes
- [ ] `npm run preview` works on built output

### 6. Architecture Validation

**Check for:**
- [ ] No global state leakage
- [ ] Proper composable boundaries
- [ ] Clean store structure
- [ ] No circular dependencies
- [ ] Proper code splitting

## migration-plan.json Review

If `migration-plan.json` exists in the project root, read it before starting the review.

In the **Blocking Issues** section of the Final Review Report, include a dedicated subsection:

### Skipped and Failed Phases

List all phases with `status: "skipped"` or `status: "failed"` from `migration-plan.json`:

| Phase | Status | Reason (from failureLog) |
|-------|--------|--------------------------|
| stores | skipped | Manual review required |

Each skipped or failed phase is a **blocking issue** — the migration is incomplete until these are resolved manually or re-executed.

If no phases were skipped or failed, state: "All phases completed successfully."

## Output Document

You MUST produce a **Final Migration Review Report** with this structure:

```markdown
# Vue 3 Migration Review Report

## 1. Summary of Findings

### Overall Status: [PASS / PASS WITH ISSUES / FAIL]

| Category | Status | Issues |
|----------|--------|--------|
| Code Quality | ✅/⚠️/❌ | [count] |
| Tooling | ✅/⚠️/❌ | [count] |
| Dependencies | ✅/⚠️/❌ | [count] |
| TypeScript | ✅/⚠️/❌ | [count] |
| Build | ✅/⚠️/❌ | [count] |

## 2. Blocking Issues

Issues that MUST be resolved before approval:

### Issue 1: [Title]
**Location:** [file:line]
**Problem:** [Description]
**Required Fix:** [Solution]

[Repeat for each blocking issue]

## 3. Non-Blocking Improvements

Issues that SHOULD be addressed but don't block approval:

### Improvement 1: [Title]
**Location:** [file:line]
**Current:** [What exists]
**Recommended:** [Better approach]
**Priority:** High/Medium/Low

[Repeat for each improvement]

## 4. Tooling & Script Validation

### package.json
- [ ] Correct Vue 3 dependencies
- [ ] No Vue 2 remnants
- [ ] Proper script definitions

### Build System
- [ ] Vite configured correctly
- [ ] Build succeeds
- [ ] Output is valid

### TypeScript
- [ ] Strict mode enabled
- [ ] Vue 3 types configured
- [ ] Type-check passes

### Linting
- [ ] Vue 3 ESLint plugin
- [ ] No deprecated rules
- [ ] Lint passes

## 5. Type Safety & Linting Status

### TypeScript Coverage
- Files with types: [X/Y]
- Strict violations: [count]
- Any types: [count]

### Linting Status
- Errors: [count]
- Warnings: [count]

## 6. Compliance with Approved Plan

| Planned Item | Status | Notes |
|--------------|--------|-------|
| [Item 1] | ✅/❌ | [Notes] |
| [Item 2] | ✅/❌ | [Notes] |

### Deviations from Plan
[Document any deviations and justifications]

## 7. Final Recommendation

### Recommendation: [APPROVE / APPROVE WITH FIXES / REJECT]

### Rationale
[Detailed explanation]

### Required Actions (if applicable)
1. [Action 1]
2. [Action 2]

### Sign-off Checklist
- [ ] All blocking issues resolved
- [ ] Build succeeds
- [ ] Type-check passes
- [ ] Lint passes
- [ ] Application runs correctly
```

## Review Checklists

### Vue 3 Compliance Checklist

- [ ] No Vue 2 global API usage (`Vue.component`, `Vue.use`, etc.)
- [ ] No filter syntax in templates
- [ ] No `.native` event modifiers
- [ ] v-model uses correct prop/event names
- [ ] Async components use `defineAsyncComponent`
- [ ] Custom directives use Vue 3 API
- [ ] Transition classes use Vue 3 names
- [ ] No `$children` usage
- [ ] No `$listeners` usage (check `$attrs`)
- [ ] No `$scopedSlots` (use unified `slots`)

### Vue Class Component Migration Checklist

- [ ] No `vue-class-component` imports or `@Component` decorators
- [ ] No `vue-property-decorator` imports (`@Prop`, `@Emit`, `@Watch`, etc.)
- [ ] No `vuex-class` imports (`@State`, `@Getter`, `@Mutation`, `@Action`)
- [ ] No `extends Vue` or `extends Mixins(...)` patterns
- [ ] All class properties converted to `ref()` or `reactive()`
- [ ] All class getters converted to `computed()`
- [ ] All `@Prop` converted to `defineProps()`
- [ ] All `@Emit` converted to `defineEmits()`
- [ ] All `@Watch` converted to `watch()` or `watchEffect()`
- [ ] All `@Ref` converted to `useTemplateRef()` or `ref()`
- [ ] All `@PropSync` / `@Model` converted to `defineModel()`
- [ ] All `@Provide` / `@Inject` converted to `provide()` / `inject()`
- [ ] No class-based mixins (converted to composables)
- [ ] TypeScript types properly migrated from class to interface/type

### Pinia Compliance Checklist

- [ ] No Vuex imports or usage
- [ ] Stores use `defineStore`
- [ ] No mutations (actions only)
- [ ] Proper composition API inside stores
- [ ] Store IDs are unique
- [ ] No direct state mutation from outside store

### Router 4 Compliance Checklist

- [ ] Uses `createRouter` / `createWebHistory`
- [ ] No `mode` property
- [ ] Navigation guards return properly
- [ ] Route meta is typed (if TypeScript)
- [ ] No deprecated hook names

## Quality Standards

### Code Quality
- Clean, readable code
- Consistent naming conventions
- Proper error handling
- No unused imports/variables

### Performance
- Proper use of `computed` vs methods
- Appropriate use of `shallowRef` / `shallowReactive`
- No unnecessary watchers
- Proper async handling

### Maintainability
- Clear component boundaries
- Reusable composables
- Well-structured stores
- Adequate comments where needed

### Global API Compliance Checklist

- [ ] No `import Vue from 'vue'` (use named imports)
- [ ] No `new Vue({...})` (use `createApp()`)
- [ ] No `Vue.use()` (use `app.use()`)
- [ ] No `Vue.component()` (use `app.component()`)
- [ ] No `Vue.directive()` (use `app.directive()`)
- [ ] No `Vue.mixin()` (use `app.mixin()` or composables)
- [ ] No `Vue.prototype.$x` (use `app.config.globalProperties.$x`)
- [ ] No `Vue.set()` / `this.$set()` (use direct assignment)
- [ ] No `Vue.delete()` / `this.$delete()` (use `delete`)
- [ ] No `Vue.observable()` (use `reactive()`)
- [ ] No `Vue.extend()` (use `defineComponent()`)
- [ ] No `Vue.filter()` (use functions)
- [ ] No `Vue.config.productionTip`
- [ ] No `Vue.config.keyCodes`
- [ ] No `Vue.config.ignoredElements` (use `app.config.compilerOptions.isCustomElement`)

### Template Syntax Compliance Checklist

- [ ] No `.sync` modifier (use `v-model:propName`)
- [ ] No `.native` modifier (configure `emits` instead)
- [ ] No `$listeners` in templates (merged into `$attrs`)
- [ ] No `$scopedSlots` (use `$slots`)
- [ ] No `$children` access
- [ ] No filter pipe syntax (`{{ val | filter }}`)
- [ ] No `inline-template` attribute
- [ ] No `v-if` + `v-for` on same element (v-if precedence changed)
- [ ] `key` placed on `<template v-for>`, not child elements
- [ ] v-model on components uses `modelValue`/`update:modelValue`
- [ ] All custom events declared with `defineEmits` or `emits` option
- [ ] `$destroy()` not called manually

### CSS & Styling Compliance Checklist

- [ ] No `::v-deep` (use `:deep()`)
- [ ] No `>>>` deep selector (use `:deep()`)
- [ ] No `/deep/` deep selector (use `:deep()`)
- [ ] No `::v-slotted` (use `:slotted()`)
- [ ] No `::v-global` (use `:global()`)
- [ ] Transition class names use `-from` suffix (`v-enter-from`, `v-leave-from`)
- [ ] `<transition-group>` has `tag` prop if wrapper element needed

### Environment & Build Compliance Checklist

- [ ] No `process.env.VUE_APP_*` references (use `import.meta.env.VITE_*`)
- [ ] No `process.env.NODE_ENV` (use `import.meta.env.MODE`)
- [ ] No `require()` calls for assets (use `import`)
- [ ] No `require.context()` calls (use `import.meta.glob()`)
- [ ] No `vue.config.js` (replaced by `vite.config.ts` if migrated)
- [ ] No `vue-template-compiler` in dependencies
- [ ] No `@vue/cli-service` in dependencies (if migrated to Vite)
- [ ] `.env` files use `VITE_` prefix (not `VUE_APP_`)
- [ ] `index.html` at project root (Vite requirement)

### Render Function & Advanced Pattern Checklist

- [ ] No `render(h)` pattern (h must be imported from 'vue')
- [ ] No nested VNode props (`{ attrs: {}, on: {}, domProps: {} }`) → flat props
- [ ] No `this.$scopedSlots` (use `slots` from setup context)
- [ ] No `functional: true` option (use plain functions or regular components)
- [ ] No `<template functional>` syntax
- [ ] Custom directives use Vue 3 hook names (`mounted` not `inserted`, etc.)
- [ ] Async components use `defineAsyncComponent()`

### Third-Party Library Compliance Checklist

- [ ] No `vuex` package in dependencies
- [ ] No `vue-class-component` / `vue-property-decorator` / `vuex-class`
- [ ] No `vue-template-compiler` (use `@vue/compiler-sfc` if needed)
- [ ] No Vue 2-only versions of ecosystem packages:
  - [ ] No `vue-i18n` v8 (should be v9)
  - [ ] No `vee-validate` v3 (should be v4)
  - [ ] No `vue-meta` v2 (should be `@unhead/vue`)
  - [ ] No `portal-vue` (should use built-in `<Teleport>`)
  - [ ] No `vuex-persistedstate` (should use `pinia-plugin-persistedstate`)
  - [ ] No `@vue/test-utils` v1 (should be v2)
  - [ ] No `vue-analytics` (should be `vue-gtag`)
- [ ] All third-party Vue plugins updated to Vue 3 compatible versions
- [ ] No Vue.use() style plugin registrations remaining

### Testing Compliance Checklist

- [ ] `@vue/test-utils` v2 installed
- [ ] No `createLocalVue()` usage
- [ ] No `propsData` (use `props`)
- [ ] `mocks`/`stubs`/`provide` inside `global` option
- [ ] No `wrapper.destroy()` (use `wrapper.unmount()`)
- [ ] No `attachToDocument` (use `attachTo`)
- [ ] Test runner compatible with Vue 3 (Vitest recommended with Vite)
- [ ] Tests pass without Vue 2 compatibility warnings

Remember: Your role is to **validate quality**, not to implement fixes. Document issues clearly so they can be addressed.
