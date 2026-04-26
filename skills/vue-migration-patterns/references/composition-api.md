# Options API → Composition API (`<script setup>`)

Complete transformation guide for converting Vue 2 Options API components to Vue 3 `<script setup>`.

---

## Full Component Example

```vue
<!-- Vue 2 Options API -->
<script>
import { mapState, mapActions } from 'vuex'

export default {
  name: 'UserProfile',
  components: { Avatar },
  props: {
    userId: { type: Number, required: true }
  },
  data() {
    return {
      isEditing: false,
      localName: ''
    }
  },
  computed: {
    ...mapState('user', ['currentUser']),
    displayName() {
      return this.localName || this.currentUser.name
    }
  },
  watch: {
    userId: {
      immediate: true,
      handler(newId) { this.fetchUser(newId) }
    }
  },
  created() {
    this.localName = this.currentUser.name
  },
  mounted() {
    this.$refs.input.focus()
  },
  beforeDestroy() {
    this.cleanup()
  },
  methods: {
    ...mapActions('user', ['fetchUser', 'updateUser']),
    toggleEdit() { this.isEditing = !this.isEditing },
    async save() {
      await this.updateUser({ id: this.userId, name: this.localName })
      this.isEditing = false
      this.$emit('saved', this.localName)
    },
    cleanup() { /* remove event listeners etc */ }
  }
}
</script>
```

```vue
<!-- Vue 3 <script setup> -->
<script setup lang="ts">
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue'
import { useUserStore } from '@/stores/user'

const props = defineProps<{ userId: number }>()
const emit = defineEmits<{ saved: [name: string] }>()

const userStore = useUserStore()
const inputRef = useTemplateRef<HTMLInputElement>('input')

const isEditing = ref(false)
const localName = ref(userStore.currentUser.name)

const displayName = computed(() => localName.value || userStore.currentUser.name)

watch(() => props.userId, (newId) => {
  userStore.fetchUser(newId)
}, { immediate: true })

onMounted(() => {
  inputRef.value?.focus()
})

onBeforeUnmount(() => {
  cleanup()
})

function toggleEdit() { isEditing.value = !isEditing.value }

async function save() {
  await userStore.updateUser({ id: props.userId, name: localName.value })
  isEditing.value = false
  emit('saved', localName.value)
}

function cleanup() { /* remove event listeners etc */ }
</script>
```

---

## Transformation Rules

### data() → ref() / reactive()

```js
// Vue 2
data() {
  return {
    count: 0,
    user: { name: '', email: '' },
    items: []
  }
}

// Vue 3 — prefer ref() for primitives, reactive() for objects
const count = ref(0)
const user = reactive({ name: '', email: '' })
const items = ref([])

// Access: count.value, user.name (no .value for reactive)
```

**Rule**: Use `ref()` by default. Use `reactive()` only for objects where `.value` would be awkward. Never use `reactive()` for primitives.

### computed → computed()

```js
// Vue 2
computed: {
  fullName() { return `${this.first} ${this.last}` },
  fullNameWritable: {
    get() { return `${this.first} ${this.last}` },
    set(val) {
      const [first, last] = val.split(' ')
      this.first = first
      this.last = last
    }
  }
}

// Vue 3
const fullName = computed(() => `${first.value} ${last.value}`)
const fullNameWritable = computed({
  get: () => `${first.value} ${last.value}`,
  set: (val) => {
    const [f, l] = val.split(' ')
    first.value = f
    last.value = l
  }
})
```

### watch → watch() / watchEffect()

```js
// Vue 2
watch: {
  count(newVal, oldVal) { console.log(newVal) },
  'user.name': { handler(val) { ... }, immediate: true, deep: true },
  items: { handler(val) { ... }, deep: true }
}

// Vue 3
watch(count, (newVal, oldVal) => { console.log(newVal) })
watch(() => user.name, (val) => { ... }, { immediate: true })
watch(items, (val) => { ... }, { deep: true })

// watchEffect — runs immediately, tracks dependencies automatically
watchEffect(() => {
  console.log(count.value) // re-runs whenever count changes
})
```

### props → defineProps()

```js
// Vue 2
props: {
  title: String,
  count: { type: Number, default: 0 },
  items: { type: Array, required: true },
  config: { type: Object, default: () => ({}) }
}

// Vue 3 — TypeScript (preferred)
const props = defineProps<{
  title?: string
  count?: number
  items: string[]
  config?: Record<string, unknown>
}>()
// withDefaults for defaults in TS mode:
const props = withDefaults(defineProps<{
  count?: number
  config?: Record<string, unknown>
}>(), {
  count: 0,
  config: () => ({})
})

// Vue 3 — runtime (JS or when defaults needed without withDefaults)
const props = defineProps({
  title: String,
  count: { type: Number, default: 0 },
  items: { type: Array, required: true }
})
```

### emits → defineEmits()

```js
// Vue 2
this.$emit('update', payload)
this.$emit('change', value)

// Vue 3
const emit = defineEmits<{
  update: [payload: UpdatePayload]
  change: [value: string]
}>()
emit('update', payload)
emit('change', value)
```

### methods → plain functions

```js
// Vue 2
methods: {
  increment() { this.count++ },
  async fetchData() { this.data = await api.get() }
}

// Vue 3 — just declare functions in script setup scope
function increment() { count.value++ }
async function fetchData() { data.value = await api.get() }
```

### Lifecycle Hooks

```js
// Vue 2 Options API → Vue 3 Composition API
// created / beforeCreate → top-level setup code (no hook needed)
// mounted         → onMounted(() => { ... })
// beforeMount     → onBeforeMount(() => { ... })
// updated         → onUpdated(() => { ... })
// beforeUpdate    → onBeforeUpdate(() => { ... })
// beforeDestroy   → onBeforeUnmount(() => { ... })
// destroyed       → onUnmounted(() => { ... })
// activated       → onActivated(() => { ... })
// deactivated     → onDeactivated(() => { ... })
// errorCaptured   → onErrorCaptured((err, instance, info) => { ... })
```

### Template Refs → useTemplateRef()

```js
// Vue 2
// <input ref="myInput">
mounted() { this.$refs.myInput.focus() }

// Vue 3
// <input ref="myInput">
const myInput = useTemplateRef<HTMLInputElement>('myInput')
onMounted(() => myInput.value?.focus())
```

### provide / inject

```js
// Vue 2
provide() {
  return { theme: this.theme }
}
inject: ['theme']

// Vue 3
import { provide, inject, InjectionKey, Ref } from 'vue'
const ThemeKey: InjectionKey<Ref<string>> = Symbol('theme')

// Parent
provide(ThemeKey, theme)

// Child
const theme = inject(ThemeKey, ref('light')) // with default
```

### $attrs / inheritAttrs

```vue
<!-- Vue 2 — $attrs excludes class/style, $listeners separate -->
<script>
export default { inheritAttrs: false }
</script>
<template>
  <div>
    <input v-bind="$attrs" v-on="$listeners" />
  </div>
</template>

<!-- Vue 3 — $attrs includes class, style, and event listeners -->
<script setup>
defineOptions({ inheritAttrs: false })
</script>
<template>
  <div>
    <input v-bind="$attrs" />
  </div>
</template>
```

---

## Mixin → Composable Conversion

```js
// Vue 2 mixin
export const counterMixin = {
  data() { return { count: 0 } },
  methods: {
    increment() { this.count++ },
    decrement() { this.count-- }
  }
}

// Vue 3 composable
export function useCounter(initial = 0) {
  const count = ref(initial)
  function increment() { count.value++ }
  function decrement() { count.value-- }
  return { count, increment, decrement }
}

// Usage
const { count, increment, decrement } = useCounter(10)
```

**Mixin → Composable rules:**
- `data()` properties → `ref()` / `reactive()` inside the composable
- `methods` → plain functions inside the composable
- `computed` → `computed()` inside the composable
- `watch` → `watch()` / `watchEffect()` inside the composable
- Lifecycle hooks → `onMounted()` etc. inside the composable
- Multiple mixins → multiple composables (no name collision risk)

---

## defineModel() for v-model Components

```vue
<!-- Vue 2 -->
<script>
export default {
  model: { prop: 'value', event: 'input' },
  props: ['value'],
  methods: {
    update(val) { this.$emit('input', val) }
  }
}
</script>

<!-- Vue 3 with defineModel (Vue 3.4+) -->
<script setup>
const model = defineModel<string>()
// model.value is reactive two-way binding
</script>

<!-- Vue 3 multiple models -->
<script setup>
const name = defineModel<string>('name')
const age = defineModel<number>('age')
</script>
```
