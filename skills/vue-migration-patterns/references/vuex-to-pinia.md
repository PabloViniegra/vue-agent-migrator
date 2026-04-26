# Vuex → Pinia Migration

Complete conversion guide from Vuex 4 (or Vuex 3) modules to Pinia stores.

---

## Concept Mapping

| Vuex | Pinia |
|------|-------|
| `state` | `ref()` / `reactive()` inside store |
| `getters` | `computed()` inside store |
| `mutations` | **removed** — mutate state directly |
| `actions` | plain `async function` inside store |
| module namespace | separate `defineStore` per module |
| `store.commit('mutation', payload)` | `store.action(payload)` or direct assignment |
| `store.dispatch('action', payload)` | `store.action(payload)` |
| `mapState`, `mapGetters` | `storeToRefs(store)` |
| `mapActions`, `mapMutations` | destructure directly from store |

---

## Full Module Conversion

```js
// Vuex module (src/store/modules/user.js)
export default {
  namespaced: true,
  state: () => ({
    currentUser: null,
    isLoading: false,
    error: null
  }),
  getters: {
    isLoggedIn: (state) => !!state.currentUser,
    userName: (state) => state.currentUser?.name ?? 'Guest'
  },
  mutations: {
    SET_USER(state, user) { state.currentUser = user },
    SET_LOADING(state, val) { state.isLoading = val },
    SET_ERROR(state, err) { state.error = err }
  },
  actions: {
    async login({ commit }, credentials) {
      commit('SET_LOADING', true)
      try {
        const user = await api.login(credentials)
        commit('SET_USER', user)
      } catch (err) {
        commit('SET_ERROR', err.message)
      } finally {
        commit('SET_LOADING', false)
      }
    },
    logout({ commit }) {
      commit('SET_USER', null)
    }
  }
}
```

```js
// Pinia store (src/stores/user.ts)
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  const currentUser = ref<User | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  const isLoggedIn = computed(() => !!currentUser.value)
  const userName = computed(() => currentUser.value?.name ?? 'Guest')

  async function login(credentials: Credentials) {
    isLoading.value = true
    error.value = null
    try {
      currentUser.value = await api.login(credentials)
    } catch (err) {
      error.value = (err as Error).message
    } finally {
      isLoading.value = false
    }
  }

  function logout() {
    currentUser.value = null
  }

  return { currentUser, isLoading, error, isLoggedIn, userName, login, logout }
})
```

---

## Vuex Root Store → Pinia Setup

```js
// Vue 2 + Vuex (src/store/index.js)
import Vue from 'vue'
import Vuex from 'vuex'
import user from './modules/user'
import cart from './modules/cart'

Vue.use(Vuex)
export default new Vuex.Store({
  modules: { user, cart },
  state: { appVersion: '1.0.0' },
  getters: { version: state => state.appVersion }
})

// main.js
import store from './store'
new Vue({ store, render: h => h(App) }).$mount('#app')
```

```js
// Vue 3 + Pinia (src/main.ts)
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

const app = createApp(App)
app.use(createPinia())
app.mount('#app')

// No central index — each module becomes its own store file
// src/stores/user.ts  → useUserStore
// src/stores/cart.ts  → useCartStore
// src/stores/app.ts   → useAppStore (for root-level state)
```

---

## Component Usage Conversion

```vue
<!-- Vue 2 with Vuex helpers -->
<script>
import { mapState, mapGetters, mapActions, mapMutations } from 'vuex'

export default {
  computed: {
    ...mapState('user', ['currentUser', 'isLoading']),
    ...mapGetters('user', ['isLoggedIn', 'userName'])
  },
  methods: {
    ...mapActions('user', ['login', 'logout']),
    ...mapMutations('user', ['SET_ERROR']),
    async handleLogin(credentials) {
      await this.login(credentials)
    }
  }
}
</script>
```

```vue
<!-- Vue 3 with Pinia -->
<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// storeToRefs preserves reactivity for state and getters
const { currentUser, isLoading, isLoggedIn, userName } = storeToRefs(userStore)

// Actions destructure directly (they're plain functions, no need for storeToRefs)
const { login, logout } = userStore

async function handleLogin(credentials: Credentials) {
  await login(credentials)
}
</script>
```

---

## Direct Store Access in Non-Setup Contexts

```js
// In router guards, axios interceptors, non-component JS
import { useUserStore } from '@/stores/user'

// Must be called AFTER pinia is installed (after createPinia())
const userStore = useUserStore()
if (!userStore.isLoggedIn) { ... }
```

---

## Store Cross-References

```js
// Vuex: access other modules via rootState / rootGetters
actions: {
  checkout({ state, rootGetters, dispatch }) {
    const userId = rootGetters['user/currentUser']?.id
    dispatch('cart/clear', null, { root: true })
  }
}

// Pinia: import and use other stores directly
import { useCartStore } from './cart'

export const useOrderStore = defineStore('order', () => {
  async function checkout() {
    const cartStore = useCartStore()
    const userStore = useUserStore()
    const userId = userStore.currentUser?.id
    await api.placeOrder(userId, cartStore.items)
    cartStore.clear()
  }
  return { checkout }
})
```

---

## Pinia Plugins (replacing Vuex plugins)

```js
// Vuex plugin
const myPlugin = (store) => {
  store.subscribe((mutation, state) => {
    localStorage.setItem('state', JSON.stringify(state))
  })
}

// Pinia plugin
import { PiniaPluginContext } from 'pinia'

function localStoragePlugin({ store }: PiniaPluginContext) {
  store.$subscribe((mutation, state) => {
    localStorage.setItem(store.$id, JSON.stringify(state))
  })
}

const pinia = createPinia()
pinia.use(localStoragePlugin)
```

---

## Mutation Patterns to Remove

All these Vuex patterns become direct assignment in Pinia:

```js
// Find and eliminate all patterns like:
store.commit('user/SET_USER', user)       → userStore.currentUser = user
store.commit('cart/ADD_ITEM', item)       → cartStore.items.push(item)
store.dispatch('user/login', credentials) → userStore.login(credentials)
this.$store.state.user.currentUser        → userStore.currentUser
this.$store.getters['user/isLoggedIn']    → userStore.isLoggedIn
```

Search patterns:
```bash
grep -r "store\.commit"    src/
grep -r "store\.dispatch"  src/
grep -r "\$store"          src/
grep -r "mapState\|mapGetters\|mapActions\|mapMutations" src/
```
