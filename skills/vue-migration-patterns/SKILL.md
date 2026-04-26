---
name: vue-migration-patterns
description: Comprehensive Vue 2→3 migration pattern reference for migration agents. Use during any phase of a Vue 2 to Vue 3 migration — planning, execution, or review. Contains complete breaking changes catalog, Options API to Composition API transformations, Vuex to Pinia conversion patterns, Vue Router 3 to 4 migration, edge cases, and a cross-platform project scanner script.
---

# Vue Migration Patterns

Authoritative reference for all Vue 2→3 migration tasks. Load the relevant reference file for the active phase.

## Reference Files

| File | Phase | Use when |
|------|-------|----------|
| `references/breaking-changes.md` | All | Identifying any removed or deprecated Vue 2 API |
| `references/composition-api.md` | Execution | Converting Options API components to `<script setup>` |
| `references/vuex-to-pinia.md` | Execution | Converting Vuex stores to Pinia |
| `references/router-migration.md` | Execution | Upgrading Vue Router 3 to Vue Router 4 |
| `references/edge-cases.md` | All | Complex patterns — mixins, render functions, custom directives, slots |

## Scanner Script

Run before the planning phase to get a structured analysis report:

```bash
# Bash (macOS / Linux / Git Bash on Windows)
bash scripts/scan_vue2.sh /path/to/project

# Python (cross-platform — use on Windows when bash unavailable)
python scripts/scan_vue2.py /path/to/project
```

Output covers: component count, deprecated API usages, class component detection, Vuex module count, router mode, test framework, build tool — all data needed for the Macro Analysis Document.

## Phase → Reference Mapping

**Planner**: run scanner + load `breaking-changes.md` to scope complexity and risk.

**Executor (components)**: load `composition-api.md` + `breaking-changes.md`.

**Executor (stores)**: load `vuex-to-pinia.md`.

**Executor (router)**: load `router-migration.md`.

**Executor (complex cases)**: load `edge-cases.md` for mixins, render functions, scoped slots.

**Reviewer**: load `breaking-changes.md` + `edge-cases.md` to verify no Vue 2 patterns remain.
