#!/usr/bin/env python3
"""
Vue 2 Project Scanner — cross-platform (Windows / macOS / Linux)

Usage:
    python scripts/scan_vue2.py /path/to/vue-project

Output:
    Structured report covering all data needed for the Macro Analysis Document.
"""

import os
import re
import sys
import json
from pathlib import Path
from collections import defaultdict

# ── Pattern definitions ───────────────────────────────────────────────────────

DEPRECATED_API_PATTERNS = {
    "this.$set":        r"this\.\$set\s*\(",
    "this.$delete":     r"this\.\$delete\s*\(",
    "this.$on":         r"this\.\$on\s*\(",
    "this.$off":        r"this\.\$off\s*\(",
    "this.$once":       r"this\.\$once\s*\(",
    "this.$children":   r"this\.\$children",
    "this.$listeners":  r"this\.\$listeners",
    "this.$scopedSlots":r"this\.\$scopedSlots",
    "Vue.set":          r"\bVue\.set\s*\(",
    "Vue.delete":       r"\bVue\.delete\s*\(",
    "Vue.observable":   r"\bVue\.observable\s*\(",
    "Vue.filter":       r"\bVue\.filter\s*\(",
    "Vue.extend":       r"\bVue\.extend\s*\(",
    "$store.commit":    r"\$store\.commit\s*\(",
    "$store.dispatch":  r"\$store\.dispatch\s*\(",
    "beforeDestroy":    r"\bbeforeDestroy\b",
    "destroyed hook":   r"\bdestroyed\s*\(",
    ".native modifier": r"@\w+\.native\b",
    "pipe filter":      r"\|\s+\w+\s*}}",
    "require() assets": r"\brequire\s*\(['\"][@./]",
    "process.env.VUE_APP": r"process\.env\.VUE_APP_",
    "::v-deep":         r"::v-deep\b",
    "/deep/":           r"/deep/",
    ">>>":              r">>>\s*\.",
}

CLASS_COMPONENT_PATTERNS = {
    "@Component":               r"@Component\b",
    "@Prop":                    r"@Prop\b",
    "@PropSync":                r"@PropSync\b",
    "@Emit":                    r"@Emit\b",
    "@Watch":                   r"@Watch\b",
    "@Ref":                     r"@Ref\b",
    "vue-property-decorator":   r"from ['\"]vue-property-decorator['\"]",
    "vue-class-component":      r"from ['\"]vue-class-component['\"]",
    "vuex-class":               r"from ['\"]vuex-class['\"]",
    "@State (vuex-class)":      r"@State\b",
    "@Getter (vuex-class)":     r"@Getter\b",
    "@Action (vuex-class)":     r"@Action\b",
    "@Mutation (vuex-class)":   r"@Mutation\b",
    "extends Vue":              r"\bextends\s+Vue\b",
}

VUEX_PATTERNS = {
    "Vuex import":        r"from ['\"]vuex['\"]",
    "new Vuex.Store":     r"new\s+Vuex\.Store\s*\(",
    "namespaced: true":   r"namespaced\s*:\s*true",
    "mutations object":   r"\bmutations\s*:\s*\{",
    "mapState":           r"\bmapState\s*\(",
    "mapGetters":         r"\bmapGetters\s*\(",
    "mapActions":         r"\bmapActions\s*\(",
    "mapMutations":       r"\bmapMutations\s*\(",
}

ROUTER_PATTERNS = {
    "new VueRouter":      r"new\s+VueRouter\s*\(",
    "Vue.use(VueRouter)": r"Vue\.use\s*\(\s*VueRouter\s*\)",
    "mode: history":      r"mode\s*:\s*['\"]history['\"]",
    "mode: hash":         r"mode\s*:\s*['\"]hash['\"]",
    "addRoutes":          r"\baddRoutes\s*\(",
    "catch-all *":        r"path\s*:\s*['\"]?\*['\"]?",
    "$route access":      r"\$route\b",
    "$router access":     r"\$router\b",
}

TEST_FRAMEWORK_PATTERNS = {
    "jest":               r"from ['\"]@vue/test-utils['\"]|jest\.config",
    "vitest":             r"from ['\"]vitest['\"]|vitest\.config",
    "@vue/test-utils v1": r"createLocalVue|shallowMount|mount.*localVue",
}

# ── File collection ───────────────────────────────────────────────────────────

IGNORE_DIRS = {
    "node_modules", ".git", "dist", "build", ".nuxt", ".output",
    "coverage", ".nyc_output", "__pycache__", ".cache"
}

def collect_files(root: Path) -> dict:
    files = defaultdict(list)
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS]
        for fname in filenames:
            fpath = Path(dirpath) / fname
            ext = fpath.suffix.lower()
            if ext in (".vue", ".js", ".ts", ".jsx", ".tsx", ".css", ".scss", ".less"):
                files[ext].append(fpath)
    return files

# ── Scanning helpers ──────────────────────────────────────────────────────────

def scan_patterns(fpath: Path, patterns: dict) -> dict:
    try:
        text = fpath.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return {}
    hits = {}
    for name, pat in patterns.items():
        matches = re.findall(pat, text)
        if matches:
            hits[name] = len(matches)
    return hits

def count_options_api(fpath: Path) -> bool:
    try:
        text = fpath.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return False
    return bool(re.search(r"export default\s*\{", text)) and not bool(
        re.search(r"<script\s+setup", text)
    )

def count_script_setup(fpath: Path) -> bool:
    try:
        text = fpath.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return False
    return bool(re.search(r"<script\s+setup", text))

def has_typescript(fpath: Path) -> bool:
    try:
        text = fpath.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return False
    return bool(re.search(r"lang=['\"]ts['\"]|lang=ts", text))

# ── Main scan ─────────────────────────────────────────────────────────────────

def scan_project(root: Path) -> dict:
    files = collect_files(root)

    vue_files   = files.get(".vue", [])
    ts_files    = files.get(".ts", []) + files.get(".tsx", [])
    js_files    = files.get(".js", []) + files.get(".jsx", [])
    css_files   = files.get(".css", []) + files.get(".scss", []) + files.get(".less", [])
    all_source  = vue_files + ts_files + js_files
    all_files   = all_source + css_files

    # Component breakdown
    options_api  = sum(1 for f in vue_files if count_options_api(f))
    script_setup = sum(1 for f in vue_files if count_script_setup(f))
    uses_ts      = sum(1 for f in vue_files if has_typescript(f))

    # Check package.json
    pkg = {}
    pkg_path = root / "package.json"
    if pkg_path.exists():
        try:
            pkg = json.loads(pkg_path.read_text(encoding="utf-8"))
        except Exception:
            pass

    deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}

    # Detect Vue version
    vue_version = deps.get("vue", "unknown")

    # Aggregate pattern hits across all source files
    deprecated_hits: dict[str, int] = defaultdict(int)
    class_hits:      dict[str, int] = defaultdict(int)
    vuex_hits:       dict[str, int] = defaultdict(int)
    router_hits:     dict[str, int] = defaultdict(int)
    test_hits:       dict[str, int] = defaultdict(int)

    for fpath in all_source:
        for k, v in scan_patterns(fpath, DEPRECATED_API_PATTERNS).items():
            deprecated_hits[k] += v
        for k, v in scan_patterns(fpath, CLASS_COMPONENT_PATTERNS).items():
            class_hits[k] += v
        for k, v in scan_patterns(fpath, VUEX_PATTERNS).items():
            vuex_hits[k] += v
        for k, v in scan_patterns(fpath, ROUTER_PATTERNS).items():
            router_hits[k] += v

    for fpath in all_source + [root / "package.json"]:
        for k, v in scan_patterns(fpath, TEST_FRAMEWORK_PATTERNS).items():
            test_hits[k] += v

    # CSS deep selectors
    css_hits: dict[str, int] = defaultdict(int)
    for fpath in all_files:
        for k, v in scan_patterns(fpath, {
            "::v-deep": r"::v-deep\b",
            "/deep/":   r"/deep/",
            ">>>":      r">>>\s*\.",
        }).items():
            css_hits[k] += v

    # Count Vuex modules (namespaced stores)
    vuex_module_count = vuex_hits.get("namespaced: true", 0)

    # Build tool detection
    build_tool = "unknown"
    if "vite" in deps or (root / "vite.config.js").exists() or (root / "vite.config.ts").exists():
        build_tool = "vite"
    elif "@vue/cli-service" in deps or (root / "vue.config.js").exists():
        build_tool = "vue-cli (webpack)"
    elif "webpack" in deps:
        build_tool = "webpack"

    return {
        "vue_version": vue_version,
        "build_tool": build_tool,
        "has_typescript": any(f for f in ts_files),
        "components": {
            "total_vue_files": len(vue_files),
            "options_api": options_api,
            "script_setup": script_setup,
            "uses_typescript": uses_ts,
        },
        "source_files": {
            "vue": len(vue_files),
            "ts": len(ts_files),
            "js": len(js_files),
            "css_scss_less": len(css_files),
        },
        "deprecated_apis": dict(deprecated_hits),
        "class_components": dict(class_hits),
        "vuex": {
            "used": "vuex" in deps,
            "module_count": vuex_module_count,
            "patterns": dict(vuex_hits),
        },
        "router": {
            "used": "vue-router" in deps,
            "patterns": dict(router_hits),
        },
        "tests": {
            "framework": next(iter(test_hits), None),
            "patterns": dict(test_hits),
        },
        "css_issues": dict(css_hits),
        "dependencies": {
            "vue_i18n": "vue-i18n" in deps,
            "vue_class_component": "vue-class-component" in deps,
            "vue_property_decorator": "vue-property-decorator" in deps,
            "vuex_class": "vuex-class" in deps,
            "portal_vue": "portal-vue" in deps,
            "vue_router": "vue-router" in deps,
            "vuex": "vuex" in deps,
        }
    }

# ── Report output ─────────────────────────────────────────────────────────────

def print_report(report: dict, root: Path):
    sep = "─" * 60

    print(f"\n{'═' * 60}")
    print(f"  VUE 2 PROJECT SCAN REPORT")
    print(f"  Project: {root}")
    print(f"{'═' * 60}\n")

    print(f"  Vue version   : {report['vue_version']}")
    print(f"  Build tool    : {report['build_tool']}")
    print(f"  TypeScript    : {'yes' if report['has_typescript'] else 'no'}")
    print()

    c = report["components"]
    print(f"{sep}")
    print(f"  COMPONENTS")
    print(f"{sep}")
    print(f"  Total .vue files  : {c['total_vue_files']}")
    print(f"  Options API       : {c['options_api']}")
    print(f"  <script setup>    : {c['script_setup']}")
    print(f"  With TypeScript   : {c['uses_typescript']}")
    print()

    vuex = report["vuex"]
    print(f"{sep}")
    print(f"  VUEX / STATE MANAGEMENT")
    print(f"{sep}")
    print(f"  Vuex used         : {'yes' if vuex['used'] else 'no'}")
    if vuex["used"]:
        print(f"  Namespaced modules: {vuex['module_count']}")
        for k, v in vuex["patterns"].items():
            print(f"    {k:<30} {v} occurrences")
    print()

    router = report["router"]
    print(f"{sep}")
    print(f"  ROUTER")
    print(f"{sep}")
    print(f"  Vue Router used   : {'yes' if router['used'] else 'no'}")
    if router["used"]:
        for k, v in router["patterns"].items():
            print(f"    {k:<30} {v} occurrences")
    print()

    print(f"{sep}")
    print(f"  DEPRECATED APIs")
    print(f"{sep}")
    if report["deprecated_apis"]:
        for k, v in sorted(report["deprecated_apis"].items(), key=lambda x: -x[1]):
            print(f"    {k:<30} {v} occurrences")
    else:
        print("    None found")
    print()

    print(f"{sep}")
    print(f"  CLASS COMPONENTS (vue-property-decorator / vuex-class)")
    print(f"{sep}")
    if report["class_components"]:
        for k, v in sorted(report["class_components"].items(), key=lambda x: -x[1]):
            print(f"    {k:<30} {v} occurrences")
    else:
        print("    None found")
    print()

    print(f"{sep}")
    print(f"  CSS DEEP SELECTORS (to replace with :deep())")
    print(f"{sep}")
    if report["css_issues"]:
        for k, v in report["css_issues"].items():
            print(f"    {k:<30} {v} occurrences")
    else:
        print("    None found")
    print()

    deps = report["dependencies"]
    print(f"{sep}")
    print(f"  KEY DEPENDENCIES")
    print(f"{sep}")
    for k, v in deps.items():
        status = "YES — requires migration" if v else "no"
        print(f"    {k:<30} {status}")
    print()

    tests = report["tests"]
    print(f"{sep}")
    print(f"  TESTS")
    print(f"{sep}")
    print(f"  Framework detected: {tests['framework'] or 'none detected'}")
    print()

    print(f"{'═' * 60}")
    print(f"  COMPLEXITY ESTIMATE")
    print(f"{'═' * 60}")

    score = 0
    score += c["options_api"] * 2
    score += len(report["class_components"]) * 5
    score += vuex["module_count"] * 3
    score += len(report["deprecated_apis"]) * 2
    score += len(report["css_issues"]) * 1

    if score < 20:
        complexity = "LOW"
    elif score < 60:
        complexity = "MEDIUM"
    elif score < 120:
        complexity = "HIGH"
    else:
        complexity = "VERY HIGH"

    print(f"  Score: {score}  →  {complexity}")
    print(f"{'═' * 60}\n")

# ── Entry point ───────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print("Usage: python scan_vue2.py <project-path>")
        sys.exit(1)

    root = Path(sys.argv[1]).resolve()
    if not root.exists():
        print(f"Error: path not found: {root}")
        sys.exit(1)

    report = scan_project(root)
    print_report(report, root)

if __name__ == "__main__":
    main()
