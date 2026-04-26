# Vue Router 3 → Vue Router 4 Migration

---

## Installation and Setup

```js
// Vue 2 + Vue Router 3
import Vue from 'vue'
import VueRouter from 'vue-router'
Vue.use(VueRouter)

export default new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [...]
})

// main.js
new Vue({ router }).$mount('#app')
```

```js
// Vue 3 + Vue Router 4
import { createRouter, createWebHistory } from 'vue-router'

export default createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [...]
})

// main.ts
const app = createApp(App)
app.use(router)
app.mount('#app')
```

---

## History Mode Mapping

| Vue Router 3 (`mode`) | Vue Router 4 (history factory) |
|-----------------------|-------------------------------|
| `mode: 'history'` | `createWebHistory(base?)` |
| `mode: 'hash'` | `createWebHashHistory(base?)` |
| `mode: 'abstract'` | `createMemoryHistory(base?)` |

---

## Route Configuration Changes

### RouteConfig → RouteRecordRaw

```js
// Vue Router 3
import { RouteConfig } from 'vue-router'
const routes: RouteConfig[] = [...]

// Vue Router 4
import { RouteRecordRaw } from 'vue-router'
const routes: RouteRecordRaw[] = [...]
```

### Redirect Changes

```js
// Vue Router 3 — redirect to named route
{ path: '/old', redirect: { name: 'home' } }

// Vue Router 4 — unchanged, but redirect functions receive normalized location
{ path: '/old', redirect: to => ({ name: 'home', query: to.query }) }
```

### Catch-All Route

```js
// Vue Router 3
{ path: '*', component: NotFound }

// Vue Router 4 — must use named parameter with custom regex
{ path: '/:pathMatch(.*)*', name: 'not-found', component: NotFound }
// or without params:
{ path: '/:pathMatch(.*)', name: 'not-found', component: NotFound }
```

---

## Dynamic Route Methods

```js
// Vue Router 3
router.addRoutes([{ path: '/new', component: NewPage }])

// Vue Router 4
router.addRoute({ path: '/new', component: NewPage })
// Add to specific parent:
router.addRoute('parentName', { path: 'child', component: Child })
```

---

## Navigation Guards

```js
// Vue Router 3 — next() required
router.beforeEach((to, from, next) => {
  if (!isAuthenticated) next('/login')
  else next()
})

// Vue Router 4 — next() optional, return value used instead
router.beforeEach((to, from) => {
  if (!isAuthenticated) return '/login'
  // return true or undefined to allow navigation
})

// Both styles still work in Vue Router 4, but returning is preferred
```

### In-component Guards

```js
// Vue Router 3 — Options API
export default {
  beforeRouteEnter(to, from, next) {
    next(vm => { vm.data = loadData() })
  },
  beforeRouteUpdate(to, from, next) { next() },
  beforeRouteLeave(to, from, next) { next() }
}

// Vue Router 4 — Composition API
import { onBeforeRouteUpdate, onBeforeRouteLeave } from 'vue-router'

onBeforeRouteUpdate((to, from) => {
  // runs when params change but component reuses
})

onBeforeRouteLeave((to, from) => {
  if (hasUnsavedChanges) return false
})
// Note: beforeRouteEnter has no Composition API equivalent —
// use onMounted or fetch data via the route object instead
```

---

## Accessing Route in Components

```js
// Vue 2 — Options API
this.$route.params.id
this.$route.query.search
this.$router.push('/home')
this.$router.replace({ name: 'profile' })
this.$router.go(-1)

// Vue 3 — Composition API
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()

route.params.id
route.query.search
router.push('/home')
router.replace({ name: 'profile' })
router.go(-1)
```

---

## Route Meta Types

```ts
// Vue Router 4 — type-safe meta
import 'vue-router'

declare module 'vue-router' {
  interface RouteMeta {
    requiresAuth?: boolean
    title?: string
    layout?: string
  }
}

// Usage in route
{
  path: '/dashboard',
  component: Dashboard,
  meta: { requiresAuth: true, title: 'Dashboard' }
}
```

---

## scroll Behavior

```js
// Vue Router 3
scrollBehavior(to, from, savedPosition) {
  if (savedPosition) return savedPosition
  return { x: 0, y: 0 }
}

// Vue Router 4 — x/y renamed to left/top, supports Promise
scrollBehavior(to, from, savedPosition) {
  if (savedPosition) return savedPosition
  return { top: 0, left: 0 }
  // or async:
  return new Promise(resolve => {
    setTimeout(() => resolve({ top: 0 }), 300)
  })
}
```

---

## Lazy Loading (unchanged but improved)

```js
// Works in both versions
{ path: '/about', component: () => import('./views/About.vue') }

// Vue Router 4: named chunks
{ path: '/about', component: () => import(/* webpackChunkName: "about" */ './views/About.vue') }
```

---

## Search Patterns for Router Issues

```bash
grep -r "new VueRouter"          src/
grep -r "Vue\.use(VueRouter)"    src/
grep -r "mode: 'history'"        src/
grep -r "mode: 'hash'"           src/
grep -r "\$route\b"              src/
grep -r "\$router\b"             src/
grep -r "addRoutes"              src/
grep -r "RouteConfig"            src/
grep -r "path: '\*'"             src/
grep -r "next(vm"                src/  # beforeRouteEnter callback form
```
