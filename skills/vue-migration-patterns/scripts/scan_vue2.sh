#!/usr/bin/env bash
# Vue 2 Project Scanner — bash version (macOS / Linux / Git Bash)
#
# Usage:
#   bash scripts/scan_vue2.sh /path/to/vue-project
#
# Output:
#   Structured report covering all data needed for the Macro Analysis Document.

set -euo pipefail

SEP="────────────────────────────────────────────────────────────"
ROOT="${1:?Usage: $0 <project-path>}"

if [ ! -d "$ROOT" ]; then
  echo "Error: directory not found: $ROOT" >&2
  exit 1
fi

cd "$ROOT"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  VUE 2 PROJECT SCAN REPORT"
echo "  Project: $ROOT"
echo "════════════════════════════════════════════════════════════"
echo ""

# ── Helper: count pattern in files ───────────────────────────────────────────

count_pattern() {
  local pattern="$1"
  shift
  # Suppress errors for binary files / missing dirs
  grep -r --include="*.vue" --include="*.ts" --include="*.js" \
       --include="*.tsx" --include="*.jsx" \
       --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=.git \
       -l "$pattern" "$ROOT" 2>/dev/null | wc -l | tr -d ' '
}

count_occurrences() {
  local pattern="$1"
  grep -r --include="*.vue" --include="*.ts" --include="*.js" \
       --include="*.tsx" --include="*.jsx" \
       --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=.git \
       -oh "$pattern" "$ROOT" 2>/dev/null | wc -l | tr -d ' '
}

count_css_pattern() {
  local pattern="$1"
  grep -r --include="*.vue" --include="*.css" --include="*.scss" --include="*.less" \
       --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=.git \
       -oh "$pattern" "$ROOT" 2>/dev/null | wc -l | tr -d ' '
}

# ── Vue version & build tool ──────────────────────────────────────────────────

VUE_VERSION="unknown"
BUILD_TOOL="unknown"

if [ -f "package.json" ]; then
  VUE_VERSION=$(node -e "try{const p=require('./package.json');console.log(p.dependencies?.vue||p.devDependencies?.vue||'unknown')}catch(e){console.log('unknown')}" 2>/dev/null || echo "unknown")

  if [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
    BUILD_TOOL="vite"
  elif [ -f "vue.config.js" ]; then
    BUILD_TOOL="vue-cli (webpack)"
  elif grep -q '"vite"' package.json 2>/dev/null; then
    BUILD_TOOL="vite"
  elif grep -q '"@vue/cli-service"' package.json 2>/dev/null; then
    BUILD_TOOL="vue-cli (webpack)"
  fi
fi

printf "  %-20s %s\n" "Vue version:"  "$VUE_VERSION"
printf "  %-20s %s\n" "Build tool:"   "$BUILD_TOOL"
echo ""

# ── Components ───────────────────────────────────────────────────────────────

echo "$SEP"
echo "  COMPONENTS"
echo "$SEP"

TOTAL_VUE=$(find "$ROOT" -name "*.vue" \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" \
  2>/dev/null | wc -l | tr -d ' ')

OPTIONS_API=$(find "$ROOT" -name "*.vue" \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" \
  2>/dev/null -exec grep -l "export default {" {} \; | \
  xargs grep -L "<script setup" 2>/dev/null | wc -l | tr -d ' ')

SCRIPT_SETUP=$(find "$ROOT" -name "*.vue" \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" \
  2>/dev/null -exec grep -l "<script.*setup" {} \; 2>/dev/null | wc -l | tr -d ' ')

printf "  %-30s %s\n" "Total .vue files:"  "$TOTAL_VUE"
printf "  %-30s %s\n" "Options API:"       "$OPTIONS_API"
printf "  %-30s %s\n" "<script setup>:"    "$SCRIPT_SETUP"
echo ""

# ── Deprecated APIs ───────────────────────────────────────────────────────────

echo "$SEP"
echo "  DEPRECATED APIS (must be removed)"
echo "$SEP"

declare -A DEPRECATED_PATTERNS=(
  ["this.\$set"]='this\.\$set\s*\('
  ["this.\$delete"]='this\.\$delete\s*\('
  ["this.\$on"]='this\.\$on\s*\('
  ["this.\$off"]='this\.\$off\s*\('
  ["this.\$once"]='this\.\$once\s*\('
  ["this.\$children"]='this\.\$children'
  ["this.\$listeners"]='this\.\$listeners'
  ["this.\$scopedSlots"]='this\.\$scopedSlots'
  ["Vue.set"]='Vue\.set\s*\('
  ["Vue.delete"]='Vue\.delete\s*\('
  ["Vue.observable"]='Vue\.observable\s*\('
  ["Vue.filter"]='Vue\.filter\s*\('
  ["Vue.extend"]='Vue\.extend\s*\('
  ["\$store.commit"]='\$store\.commit\s*\('
  ["\$store.dispatch"]='\$store\.dispatch\s*\('
  ["beforeDestroy"]='beforeDestroy'
  ["destroyed hook"]='destroyed\s*\('
  [".native modifier"]='@\w+\.native\b'
  ["process.env.VUE_APP"]='process\.env\.VUE_APP_'
)

FOUND_DEPRECATED=0
for name in "${!DEPRECATED_PATTERNS[@]}"; do
  pat="${DEPRECATED_PATTERNS[$name]}"
  n=$(count_occurrences "$pat")
  if [ "$n" -gt 0 ]; then
    printf "  %-35s %s occurrences\n" "$name" "$n"
    FOUND_DEPRECATED=1
  fi
done

[ "$FOUND_DEPRECATED" -eq 0 ] && echo "  None found"
echo ""

# ── Class Components ──────────────────────────────────────────────────────────

echo "$SEP"
echo "  CLASS COMPONENTS"
echo "$SEP"

CC_DECORATOR=$(count_occurrences '@Component\b')
CC_PROP=$(count_occurrences '@Prop\b')
CC_EMIT=$(count_occurrences '@Emit\b')
CC_WATCH=$(count_occurrences '@Watch\b')
CC_IMPORT=$(count_occurrences "from 'vue-property-decorator'")
CC_VUEXCLASS=$(count_occurrences "from 'vuex-class'")
CC_EXTENDS=$(count_occurrences 'extends Vue\b')

FOUND_CC=0
print_cc() {
  local label="$1" val="$2"
  [ "$val" -gt 0 ] && printf "  %-35s %s occurrences\n" "$label" "$val" && FOUND_CC=1
}

print_cc "@Component"                   "$CC_DECORATOR"
print_cc "@Prop"                        "$CC_PROP"
print_cc "@Emit"                        "$CC_EMIT"
print_cc "@Watch"                       "$CC_WATCH"
print_cc "vue-property-decorator import" "$CC_IMPORT"
print_cc "vuex-class import"            "$CC_VUEXCLASS"
print_cc "extends Vue"                  "$CC_EXTENDS"

[ "$FOUND_CC" -eq 0 ] && echo "  None found"
echo ""

# ── Vuex ─────────────────────────────────────────────────────────────────────

echo "$SEP"
echo "  VUEX / STATE MANAGEMENT"
echo "$SEP"

VUEX_USED=$(count_occurrences "from 'vuex'")
VUEX_MODULES=$(count_occurrences "namespaced:\s*true")
MAP_STATE=$(count_occurrences 'mapState\s*\(')
MAP_GETTERS=$(count_occurrences 'mapGetters\s*\(')
MAP_ACTIONS=$(count_occurrences 'mapActions\s*\(')
MAP_MUTATIONS=$(count_occurrences 'mapMutations\s*\(')

[ "$VUEX_USED" -gt 0 ] && echo "  Vuex: YES — requires Pinia migration" || echo "  Vuex: not detected"
printf "  %-35s %s\n"  "Namespaced modules:"  "$VUEX_MODULES"
printf "  %-35s %s\n"  "mapState:"            "$MAP_STATE"
printf "  %-35s %s\n"  "mapGetters:"          "$MAP_GETTERS"
printf "  %-35s %s\n"  "mapActions:"          "$MAP_ACTIONS"
printf "  %-35s %s\n"  "mapMutations:"        "$MAP_MUTATIONS"
echo ""

# ── Router ────────────────────────────────────────────────────────────────────

echo "$SEP"
echo "  ROUTER"
echo "$SEP"

ROUTER_INIT=$(count_occurrences 'new VueRouter\s*\(')
ROUTER_MODE_HIST=$(count_occurrences "mode:\s*'history'")
ROUTER_MODE_HASH=$(count_occurrences "mode:\s*'hash'")
ROUTER_ADD=$(count_occurrences 'addRoutes\s*\(')
ROUTER_CATCH=$(count_occurrences "path:\s*'\*'")

[ "$ROUTER_INIT" -gt 0 ] && echo "  Vue Router 3: YES — requires migration" || echo "  Vue Router: not detected"
printf "  %-35s %s\n" "mode: history"            "$ROUTER_MODE_HIST"
printf "  %-35s %s\n" "mode: hash"               "$ROUTER_MODE_HASH"
printf "  %-35s %s\n" "addRoutes() (deprecated)" "$ROUTER_ADD"
printf "  %-35s %s\n" "catch-all * route"        "$ROUTER_CATCH"
echo ""

# ── CSS issues ────────────────────────────────────────────────────────────────

echo "$SEP"
echo "  CSS DEEP SELECTORS"
echo "$SEP"

CSS_DEEP=$(count_css_pattern '::v-deep\b')
CSS_SLASH=$(count_css_pattern '/deep/')
CSS_ARROW=$(count_css_pattern '>>>')

printf "  %-35s %s occurrences\n" "::v-deep (→ :deep())"  "$CSS_DEEP"
printf "  %-35s %s occurrences\n" "/deep/ (→ :deep())"    "$CSS_SLASH"
printf "  %-35s %s occurrences\n" ">>> (→ :deep())"       "$CSS_ARROW"
echo ""

# ── Package.json summary ─────────────────────────────────────────────────────

echo "$SEP"
echo "  KEY DEPENDENCIES"
echo "$SEP"

check_dep() {
  local pkg="$1"
  if [ -f "package.json" ] && grep -q "\"$pkg\"" package.json 2>/dev/null; then
    echo "  YES — requires migration"
  else
    echo "  no"
  fi
}

printf "  %-30s %s\n" "vue-i18n:"               "$(check_dep vue-i18n)"
printf "  %-30s %s\n" "vue-class-component:"    "$(check_dep vue-class-component)"
printf "  %-30s %s\n" "vue-property-decorator:" "$(check_dep vue-property-decorator)"
printf "  %-30s %s\n" "vuex-class:"             "$(check_dep vuex-class)"
printf "  %-30s %s\n" "portal-vue:"             "$(check_dep portal-vue)"
echo ""

echo "════════════════════════════════════════════════════════════"
echo "  Scan complete. Use this data for the Macro Analysis."
echo "════════════════════════════════════════════════════════════"
echo ""
