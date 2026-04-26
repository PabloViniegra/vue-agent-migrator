# Edge Cases and Complex Migration Scenarios

Patterns that require extra care. These are the areas where migrations most commonly break.

---

## Render Functions

```js
// Vue 2
export default {
  render(h) {
    return h('div', { class: 'wrapper', on: { click: this.onClick } }, [
      h('span', { attrs: { id: 'title' } }, this.title),
      this.$slots.default
    ])
  }
}

// Vue 3 — h is globally imported, flat props object
import { h } from 'vue'
export default {
  render() {
    return h('div', { class: 'wrapper', onClick: this.onClick }, [
      h('span', { id: 'title' }, this.title),
      this.$slots.default?.()  // slots are now functions
    ])
  }
}
```

Key render function changes:
- `h` is imported from `vue`, not injected as argument
- Prop structure is flat — no `attrs`, `on`, `domProps`, `class` nesting
- Event listeners: `on: { click }` → `onClick`
- Native DOM attrs merge directly with component props
- `this.$slots.default` is now a function: `this.$slots.default?.()`

---

## Scoped Slots / Slot Syntax

```html
<!-- Vue 2 -->
<template v-slot:default="{ item }">{{ item.name }}</template>
<template slot="header" slot-scope="{ title }">{{ title }}</template>

<!-- Vue 3 — v-slot syntax only (slot + slot-scope removed) -->
<template v-slot:default="{ item }">{{ item.name }}</template>
<template #header="{ title }">{{ title }}</template>
```

Defining scoped slots in the child:

```vue
<!-- Vue 2 -->
<slot name="item" :item="currentItem" />

<!-- Vue 3 — unchanged, but $scopedSlots removed; use $slots -->
<slot name="item" :item="currentItem" />

<!-- Programmatic slot access in child -->
<!-- Vue 2: this.$scopedSlots.item({ item }) -->
<!-- Vue 3: this.$slots.item?.({ item }) -->
```

---

## Custom Directives — Lifecycle Hook Renames

| Vue 2 hook | Vue 3 hook |
|------------|------------|
| `bind` | `beforeMount` |
| `inserted` | `mounted` |
| `update` | `beforeUpdate` |
| `componentUpdated` | `updated` |
| `unbind` | `unmounted` |

```js
// Vue 2
Vue.directive('focus', {
  inserted(el, binding) { el.focus() },
  unbind(el) { el.removeEventListener(...) }
})

// Vue 3
app.directive('focus', {
  mounted(el, binding) { el.focus() },
  unmounted(el) { el.removeEventListener(...) }
})
```

---

## Functional Components

```vue
<!-- Vue 2 functional component -->
<template functional>
  <div>{{ props.message }}</div>
</template>

<!-- Or JS functional -->
export default {
  functional: true,
  render(h, ctx) {
    return h('div', ctx.data, ctx.props.message)
  }
}
```

```vue
<!-- Vue 3 — all components are effectively functional; just use <script setup> -->
<script setup>
defineProps<{ message: string }>()
</script>
<template>
  <div>{{ message }}</div>
</template>
```

Vue 3 has no `functional` option — plain stateless components have the same performance. Remove the `functional: true` flag entirely.

---

## Mixins with Naming Conflicts

Mixins with conflicting property names silently overwrite each other in Vue 2. In Vue 3, they still work but migration is the opportunity to convert to composables and eliminate conflicts explicitly.

```js
// Multiple mixins with same property — conflict hidden in Vue 2
const authMixin = { data() { return { user: null } } }
const profileMixin = { data() { return { user: {} } } }  // silently wins

// Vue 3 composables — explicit, no conflicts
function useAuth() { const authUser = ref(null); return { authUser } }
function useProfile() { const profileUser = ref({}); return { profileUser } }
const { authUser } = useAuth()
const { profileUser } = useProfile()
```

---

## Global Mixins

```js
// Vue 2 — global mixin applied to ALL components
Vue.mixin({
  mounted() { this.trackPageView() },
  methods: { trackPageView() { analytics.track(this.$route.path) } }
})

// Vue 3 options:
// 1. Keep as app-level mixin (still supported but discouraged)
app.mixin({ ... })

// 2. Better: use a plugin that injects via provide/inject
const trackingPlugin = {
  install(app) {
    app.provide('trackPageView', (path) => analytics.track(path))
  }
}
app.use(trackingPlugin)

// 3. Best for route tracking: use router.afterEach
router.afterEach((to) => analytics.track(to.path))
```

---

## Vue.extend — Removed

```js
// Vue 2 — class-like component creation
const MyComp = Vue.extend({
  props: ['message'],
  template: '<p>{{ message }}</p>'
})

// Vue 3 — just use defineComponent for type inference
import { defineComponent } from 'vue'
const MyComp = defineComponent({
  props: ['message'],
  template: '<p>{{ message }}</p>'
})
// Or simply use SFC with <script setup>
```

---

## Dynamic Components with keep-alive

```html
<!-- Vue 2 -->
<keep-alive :include="['ComponentA', 'ComponentB']">
  <component :is="currentView" />
</keep-alive>

<!-- Vue 3 — unchanged, but ActivatedHook renamed -->
<!-- onActivated / onDeactivated instead of activated / deactivated -->
```

---

## Teleport (replaces portal-vue)

```html
<!-- Vue 2 with portal-vue -->
<portal to="modals">
  <MyModal v-if="showModal" />
</portal>
<portal-target name="modals" />

<!-- Vue 3 built-in Teleport -->
<Teleport to="body">
  <MyModal v-if="showModal" />
</Teleport>
<!-- No target needed — teleports directly to selector -->
```

---

## Environment Variables

When migrating from Vue CLI to Vite:

```bash
# Vue CLI (Webpack)
VUE_APP_API_URL=https://api.example.com  → process.env.VUE_APP_API_URL

# Vite
VITE_API_URL=https://api.example.com     → import.meta.env.VITE_API_URL
```

Search and replace all occurrences:
```bash
grep -r "VUE_APP_"           src/
grep -r "process\.env\."     src/
grep -r "require('"          src/  # CJS require → ESM import
```

---

## require() → import

```js
// Vue 2 (Webpack allows require in components)
const img = require('@/assets/logo.png')
const component = require('./MyComp.vue').default

// Vue 3 / Vite — ESM only
import img from '@/assets/logo.png'
import MyComp from './MyComp.vue'

// Dynamic assets in Vite — use import.meta.url pattern
const imgUrl = new URL('./assets/logo.png', import.meta.url).href
```

---

## CSS Deep Selector

```css
/* Vue 2 */
.parent >>> .child { color: red; }
.parent /deep/ .child { color: red; }
.parent ::v-deep .child { color: red; }

/* Vue 3 */
.parent :deep(.child) { color: red; }
```

---

## $attrs Fallthrough Behavior

Vue 3 `$attrs` includes `class`, `style`, and event listeners. Components that previously set `inheritAttrs: false` and manually spread `$attrs` must now account for this.

```vue
<!-- Vue 2: $attrs had no class/style/listeners -->
<input v-bind="$attrs" v-on="$listeners" :class="customClass" :style="customStyle" />

<!-- Vue 3: $attrs has everything — be careful about double-binding -->
<input v-bind="$attrs" />
<!-- class and style from $attrs now apply automatically -->
<!-- If you need to override: explicitly set them after $attrs -->
<input v-bind="$attrs" class="always-this-class" />
```

---

## Known Gotchas

1. **Reactive array methods**: `arr.push()`, `arr.splice()` etc. still trigger reactivity in Vue 3 (Proxy handles this). `arr[index] = val` now also works — no `$set` needed.

2. **Reactive object property addition**: Direct `obj.newProp = val` now works — no `$set` needed.

3. **Non-reactive root**: In Vue 2, `data()` root object itself is reactive. In Vue 3, use `reactive()` if you need the whole object to be reactive.

4. **`setup()` has no `this`**: All component instance access goes through composables and reactive primitives.

5. **Template compiler differences**: Vue 3 template compiler is stricter — unclosed tags, invalid HTML that Vue 2 silently accepted may error.

6. **`<style>` `v-bind`**: Vue 3 supports CSS `v-bind()` in `<style>` — useful for dynamic CSS that previously required inline styles or CSS custom properties.
