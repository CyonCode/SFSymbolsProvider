# Resource Format Decision

## Decision Date
2026-01-22

## Decision
**Use SVG directly in xcassets** with template rendering mode.

---

## Context

We need to determine how to package Phosphor Icons and Ionicons for use in SwiftUI via `Image()` API. The options considered were:

1. **SVG in xcassets** (chosen)
2. PDF conversion
3. SF Symbols template format
4. Runtime SVG rendering library

---

## Evidence

### phosphor-swift Reference Implementation

The official phosphor-icons/swift library (commit 3289615c) successfully uses SVG directly in xcassets:

**Asset structure**:
```
Assets.xcassets/
└── SVG/
    └── {icon-name}.imageset/
        ├── {icon-name}.svg
        └── Contents.json
```

**Contents.json format**:
```json
{
  "info": {"version": 1, "author": "xcode"},
  "images": [{"idiom": "universal", "filename": "house.svg"}],
  "properties": {"template-rendering-intent": "template"}
}
```

### SVG Format Analysis

| Source | Color Mode | Template Compatible |
|--------|------------|---------------------|
| Phosphor regular | `stroke="currentColor"` | ✅ Yes |
| Phosphor fill | No explicit color (black default) | ✅ Yes |
| Ionicons default | No explicit color (black default) | ✅ Yes |
| Ionicons outline | `stroke="#000"` (hardcoded) | ⚠️ Needs fix |

### Ionicons Outline Fix Required

Ionicons outline variants use hardcoded `stroke="#000"` instead of `currentColor`. 

**Solution**: During asset generation, replace `stroke="#000"` with `stroke="currentColor"` to enable template rendering.

Example transformation:
```svg
<!-- Before -->
<path style="fill:none;stroke:#000;stroke-width:32px"/>

<!-- After -->
<path style="fill:none;stroke:currentColor;stroke-width:32px"/>
```

---

## Implementation Strategy

### Asset Generation Flow

1. **Read icon manifest** (list of icons to include)
2. **For each icon**:
   - Copy SVG from source directory
   - If Ionicons outline: replace `#000` with `currentColor`
   - Create `.imageset` folder
   - Write `Contents.json` with template-rendering-intent
3. **Output**: Complete `.xcassets` directory

### Contents.json Template

```json
{
  "info": {"version": 1, "author": "xcode"},
  "images": [{"idiom": "universal", "filename": "{ICON_NAME}.svg"}],
  "properties": {"template-rendering-intent": "template"}
}
```

### Path Mapping

**Phosphor Icons**:
```
ph.house       → SVGs/regular/house.svg
ph.house.thin  → SVGs/thin/house.svg
ph.house.light → SVGs/light/house.svg
ph.house.bold  → SVGs/bold/house.svg
ph.house.fill  → SVGs/fill/house.svg
```

**Ionicons**:
```
ion.home         → home.svg
ion.home.outline → home-outline.svg
ion.home.sharp   → home-sharp.svg
```

---

## Advantages of This Approach

1. **Native Xcode support** - No third-party dependencies
2. **Vector scaling** - SVGs scale perfectly at any size
3. **Template rendering** - SwiftUI `.foregroundStyle()` works correctly
4. **Minimal build time** - Just file copy, no conversion needed
5. **Proven pattern** - Used successfully by phosphor-swift

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Xcode version compatibility | Target Xcode 14+ (iOS 15+) which has stable SVG support |
| Some SVGs may have complex fills | Exclude duotone variants in v1.0 |
| Hardcoded colors in Ionicons | Replace during generation |

---

## Alternatives Rejected

### PDF Conversion
- **Pro**: Maximum compatibility
- **Con**: Requires external tool (rsvg-convert), larger file size
- **Rejected**: Unnecessary complexity

### SF Symbols Template Format
- **Pro**: Apple-native format
- **Con**: Complex format, requires SF Symbols app
- **Rejected**: Too complex for third-party icons

### Runtime SVG Library (SVGKit)
- **Pro**: Maximum flexibility
- **Con**: Third-party dependency, runtime overhead
- **Rejected**: Against guardrail of no complex dependencies

---

## Conclusion

**SVG in xcassets with template rendering is the optimal solution** for this project. It provides native iOS support, perfect scaling, and color customization via standard SwiftUI modifiers, without requiring any third-party dependencies.

The only processing needed is replacing hardcoded `#000` colors in Ionicons outline variants with `currentColor`.
