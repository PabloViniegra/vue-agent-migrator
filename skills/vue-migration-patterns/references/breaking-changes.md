# Vue 2 → Vue 3 Breaking Changes

Complete catalog of removed and changed APIs. Every item listed here must be resolved during migration.

---

## Global API Changes

### Application Instance

```js
// Vue 2
import Vue from 'vue'
Vue.component('MyComp', MyComp)
Vue.directive('focus', { ... })
Vue.mixin({ ... })
Vue.use(plugin)
Vue.prototype.$http = axios
new Vue({ el: '#app', render: h => h(App) })

// Vue 3
import { createApp } from 'vue'
const app = createApp(App)
app.component('MyComp', MyComp)
app.directive('focus', { ... })
app.mixin({ ... })
app.use(plugin)
app.config.globalProperties.$http = axios
app.mount('#app')
```

### Vue.set / Vue.delete — REMOVED

```js
// Vue 2
Vue.set(obj, 'key', value)
this.$set(obj, 'key', value)
Vue.delete(obj, 'key')
this.$delete(obj, 'key')

// Vue 3 — plain assignment (Proxy-based reactivity handles it)
obj.key = value
obj['key'] = value
delete obj.key
```

### Vue.observable — REMOVED

```js
// Vue 2
const state = Vue.observable({ count: 0 })

// Vue 3
import { reactive } from 'vue'
const state = reactive({ count: 0 })
```

### Vue.nextTick / Vue.filter — CHANGED

```js
// Vue 2
Vue.nextTick(() => { ... })
Vue.filter('currency', val => `$${val}`)

// Vue 3
import { nextTick } from 'vue'
nextTick(() => { ... })
// Filters removed entirely — use computed or helper functions
```

---

## Component Instance API Changes

### Event Bus ($on / $off / $once) — REMOVED

```js
// Vue 2
const bus = new Vue()
bus.$on('event', handler)
bus.$off('event', handler)
bus.$emit('event', payload)

// Vue 3 — use mitt or tiny-emitter
import mitt from 'mitt'
const emitter = mitt()
emitter.on('event', handler)
emitter.off('event', handler)
emitter.emit('event', payload)
```

### $children — REMOVED

```js
// Vue 2
this.$children[0].doSomething()

// Vue 3 — use template refs
const childRef = useTemplateRef('child')
childRef.value.doSomething()
```

### $listeners — REMOVED (merged into $attrs)

```js
// Vue 2
<child v-bind="$props" v-on="$listeners" />

// Vue 3 — $attrs includes both attrs and listeners
<child v-bind="$attrs" />
```

Note: disable `inheritAttrs: false` if manually binding `$attrs`.

### $scopedSlots — REMOVED (merged into $slots)

```js
// Vue 2
this.$scopedSlots.default({ item })
this.$slots.default  // static VNodes array

// Vue 3 — all slots are functions via $slots
this.$slots.default?.({ item })
```

---

## Template Changes

### Filters — REMOVED

```html
<!-- Vue 2 -->
{{ price | currency }}
<div :class="status | formatClass">

<!-- Vue 3 — use method or computed -->
{{ formatCurrency(price) }}
<div :class="formatClass(status)">
```

### v-model Changes

```html
<!-- Vue 2: value prop + input event -->
<MyInput v-model="text" />
<!-- compiles to: :value="text" @input="text = $event" -->

<!-- Vue 3: modelValue prop + update:modelValue event -->
<MyInput v-model="text" />
<!-- compiles to: :modelValue="text" @update:modelValue="text = $event" -->

<!-- Vue 3: multiple v-models -->
<MyForm v-model:name="name" v-model:email="email" />
```

Component implementation:
```vue
<!-- Vue 2 -->
<script>
export default {
  model: { prop: 'value', event: 'input' },
  props: ['value'],
}
</script>

<!-- Vue 3 -->
<script setup>
const props = defineProps(['modelValue'])
const emit = defineEmits(['update:modelValue'])
</script>
```

### .native Modifier — REMOVED

```html
<!-- Vue 2 -->
<MyButton @click.native="onClick" />

<!-- Vue 3 — native events fall through automatically -->
<MyButton @click="onClick" />
```

### v-if vs v-for Priority — CHANGED

```html
<!-- Vue 2: v-for has higher priority than v-if -->
<!-- Vue 3: v-if has higher priority than v-for -->

<!-- Safe pattern in both versions — wrap with template -->
<template v-for="item in list" :key="item.id">
  <div v-if="item.visible">{{ item.name }}</div>
</template>
```

### key on <template v-for> — CHANGED

```html
<!-- Vue 2: key on children -->
<template v-for="item in list">
  <div :key="item.id">...</div>
</template>

<!-- Vue 3: key on <template> itself -->
<template v-for="item in list" :key="item.id">
  <div>...</div>
</template>
```

### v-bind Merge Order — CHANGED

```html
<!-- Vue 2: individual binding wins regardless of order -->
<div v-bind="{ id: 'blue' }" id="red">  <!-- id="red" always -->

<!-- Vue 3: order determines winner (last wins) -->
<div v-bind="{ id: 'blue' }" id="red">  <!-- id="red" (individual last) -->
<div id="red" v-bind="{ id: 'blue' }">  <!-- id="blue" (v-bind last) -->
```

---

## Lifecycle Hook Renames

| Vue 2 | Vue 3 |
|-------|-------|
| `beforeCreate` | `setup()` runs before both |
| `created` | `setup()` runs before both |
| `beforeMount` | `onBeforeMount` |
| `mounted` | `onMounted` |
| `beforeUpdate` | `onBeforeUpdate` |
| `updated` | `onUpdated` |
| `beforeDestroy` | `onBeforeUnmount` |
| `destroyed` | `onUnmounted` |
| `errorCaptured` | `onErrorCaptured` |
| `activated` | `onActivated` |
| `deactivated` | `onDeactivated` |

---

## Async Components — CHANGED

```js
// Vue 2
const AsyncComp = () => import('./MyComp.vue')
const AsyncWithOptions = () => ({
  component: import('./MyComp.vue'),
  loading: LoadingComp,
  error: ErrorComp,
  delay: 200,
  timeout: 3000
})

// Vue 3
import { defineAsyncComponent } from 'vue'
const AsyncComp = defineAsyncComponent(() => import('./MyComp.vue'))
const AsyncWithOptions = defineAsyncComponent({
  loader: () => import('./MyComp.vue'),
  loadingComponent: LoadingComp,
  errorComponent: ErrorComp,
  delay: 200,
  timeout: 3000
})
```

---

## Transition Changes

```html
<!-- Vue 2 class names -->
.v-enter        → .v-enter-from   (Vue 3)
.v-leave        → .v-leave-from   (Vue 3)
.v-enter-active   (unchanged)
.v-leave-active   (unchanged)
.v-enter-to       (unchanged)
.v-leave-to       (unchanged)
```

`<transition-group>` no longer renders a wrapper element by default in Vue 3.

---

## Removed Features Checklist

Run these greps to find remaining Vue 2 code:

```bash
grep -r "this\.\$set"        src/
grep -r "this\.\$delete"     src/
grep -r "this\.\$on\b"       src/
grep -r "this\.\$off\b"      src/
grep -r "this\.\$once\b"     src/
grep -r "this\.\$children"   src/
grep -r "this\.\$listeners"  src/
grep -r "this\.\$scopedSlots" src/
grep -r "Vue\.set"           src/
grep -r "Vue\.delete"        src/
grep -r "Vue\.observable"    src/
grep -r "Vue\.filter"        src/
grep -r "beforeDestroy"      src/
grep -r "destroyed\b"        src/
grep -r "\.native"           src/
grep -r "|\ "                src/  # pipe filters in templates
```
