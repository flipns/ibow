---
version: 1
name: Midnight Glass Mobile
colors:
  primary: "#38BDF8"
  on-primary: "#0F172A"
  surface: "#0F172A"
  surface-alt: "#222A3A"
  surface-glass: "rgba(255,255,255,0.10)"
  surface-glass-strong: "rgba(56,189,248,0.20)"
  on-surface: "#FFFFFF"
  on-surface-variant: "rgba(255,255,255,0.60)"
  on-surface-muted: "rgba(255,255,255,0.40)"
  border-glass: "rgba(255,255,255,0.20)"
  border-glass-faint: "rgba(255,255,255,0.10)"
  border-accent: "rgba(56,189,248,0.30)"
  accent-soft: "#BAE6FD"
  atmos-blue: "#2563EB"
  atmos-cyan: "#06B6D4"
  atmos-indigo: "#6366F1"
  illus-cyan: "#67E8F9"
  illus-yellow: "#FACC15"
  illus-orange: "#FB923C"
  illus-green: "#4ADE80"
  illus-violet: "#C084FC"
  error: "#EF4444"
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: 300
    lineHeight: 1.0
    letterSpacing: -0.04em
  headline-lg:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: -0.005em
  headline-sm:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: 0.02em
  body-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1.4
    letterSpacing: 0em
  body-sm:
    fontFamily: Manrope
    fontSize: 13px
    fontWeight: 500
    lineHeight: 1.4
    letterSpacing: 0em
  label-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 0em
  label-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 0em
  caption:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: 500
    lineHeight: 1.3
    letterSpacing: 0.01em
  micro-uppercase:
    fontFamily: Manrope
    fontSize: 10px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 0.02em
  numeral-xl:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: 700
    lineHeight: 1.0
    letterSpacing: -0.02em
rounded:
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 24px
  card-padding: 20px
  card-padding-lg: 24px
  section-gap: 24px
icons:
  set: solar
  default_variant: linear
  active_variant: bold
  stroke_weight: 1.5px
  default_size: 24px
components:
  card:
    backgroundColor: "{colors.surface-glass}"
    borderColor: "{colors.border-glass-faint}"
    borderWidth: 1px
    boxShadow: "0 4px 16px 0 rgba(0,0,0,0.20)"
    rounded: "{rounded.lg}"
    padding: "{spacing.card-padding}"
    textColor: "{colors.on-surface}"
  card-accent:
    backgroundColor: "{colors.surface-glass-strong}"
    borderColor: "{colors.border-accent}"
    borderWidth: 1px
    boxShadow: "0 8px 32px 0 rgba(6,182,212,0.15)"
    rounded: "{rounded.lg}"
    padding: "{spacing.card-padding-lg}"
    textColor: "{colors.on-surface}"
  button-primary:
    backgroundColor: "linear-gradient(135deg, #22D3EE 0%, #2563EB 100%)"
    textColor: "{colors.on-surface}"
    typography: "{typography.label-md}"
    rounded: "{rounded.full}"
    height: 56px
    paddingX: 24px
    border: none
    boxShadow: "0 4px 15px rgba(6,182,212,0.40)"
  button-secondary:
    backgroundColor: "{colors.surface-glass}"
    textColor: "{colors.on-surface-variant}"
    typography: "{typography.label-md}"
    borderColor: "{colors.border-glass}"
    borderWidth: 1px
    rounded: "{rounded.md}"
    height: 56px
    paddingX: 16px
    boxShadow: none
  button-text:
    backgroundColor: "transparent"
    textColor: "{colors.primary}"
    typography: "{typography.label-sm}"
    border: none
    boxShadow: none
    rounded: "{rounded.sm}"
    paddingX: 4px
    paddingY: 4px
  button-icon-glass:
    backgroundColor: "{colors.surface-glass}"
    textColor: "{colors.on-surface}"
    borderColor: "{colors.border-glass}"
    borderWidth: 1px
    boxShadow: none
    rounded: "{rounded.full}"
    size: 40px
    iconSize: 24px
  input-text:
    backgroundColor: "{colors.surface-glass}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-md}"
    borderColor: "{colors.border-glass}"
    borderWidth: 1px
    boxShadow: none
    rounded: "{rounded.md}"
    paddingX: 16px
    paddingY: 16px
    focusRingColor: "rgba(56,189,248,0.50)"
  chip:
    backgroundColor: "transparent"
    textColor: "{colors.on-surface-muted}"
    typography: "{typography.label-md}"
    border: none
    boxShadow: none
    rounded: "{rounded.md}"
    paddingX: 16px
    paddingY: 8px
  chip-active:
    backgroundColor: "rgba(56,189,248,0.20)"
    textColor: "{colors.primary}"
    typography: "{typography.label-md}"
    borderColor: "{colors.border-accent}"
    borderWidth: 1px
    boxShadow: none
    rounded: "{rounded.md}"
    paddingX: 16px
    paddingY: 8px
  badge-pill:
    backgroundColor: "rgba(56,189,248,0.20)"
    textColor: "{colors.accent-soft}"
    typography: "{typography.label-sm}"
    border: none
    boxShadow: none
    rounded: "{rounded.sm}"
    paddingX: 8px
    paddingY: 4px
  badge-circle:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-sm}"
    border: none
    boxShadow: none
    rounded: "{rounded.full}"
    size: 4px
  list-row:
    backgroundColor: "{colors.surface-glass}"
    borderColor: "{colors.border-glass-faint}"
    borderWidth: 1px
    boxShadow: none
    rounded: "{rounded.lg}"
    padding: "{spacing.card-padding}"
    textColor: "{colors.on-surface}"
  progress-bar:
    backgroundColor: "rgba(255,255,255,0.10)"
    rounded: "{rounded.full}"
    height: 12px
    border: none
    boxShadow: none
  progress-ring:
    backgroundColor: "transparent"
    border: none
    boxShadow: none
    size: 96px
  top-app-bar:
    backgroundColor: "transparent"
    textColor: "{colors.on-surface}"
    typography: "{typography.headline-md}"
    border: none
    boxShadow: none
    height: 48px
    paddingX: "{spacing.gutter}"
  tab-bar:
    backgroundColor: "{colors.surface-glass}"
    borderColor: "{colors.border-glass}"
    borderWidth: 1px
    boxShadow: "0 8px 32px 0 rgba(0,0,0,0.30)"
    rounded: "{rounded.lg}"
    height: 64px
    paddingX: 8px
  tab-item-active:
    backgroundColor: "transparent"
    textColor: "{colors.primary}"
    typography: "{typography.micro-uppercase}"
    border: none
    boxShadow: none
    iconSize: 24px
  tab-item-inactive:
    backgroundColor: "transparent"
    textColor: "rgba(255,255,255,0.50)"
    typography: "{typography.micro-uppercase}"
    border: none
    boxShadow: none
    iconSize: 24px
  fab-center:
    backgroundColor: "linear-gradient(135deg, #22D3EE 0%, #2563EB 100%)"
    textColor: "{colors.on-surface}"
    borderColor: "rgba(15,23,42,0.80)"
    borderWidth: 4px
    boxShadow: "0 4px 15px rgba(6,182,212,0.40)"
    rounded: "{rounded.full}"
    size: 56px
    iconSize: 24px
---

# Midnight Glass Mobile

## Overview

**Deep-night frosted glass over a glowing aurora.** This aesthetic stacks translucent white-tinted surfaces on a near-black slate background, then floods the negative space behind them with soft, oversized color blooms — saturated cyans, electric blues, atmospheric indigos. Every chrome surface is a pane of frosted glass: backdrop-blurred, hairline-bordered, slightly luminous.

The mood is **cool, technical, and atmospheric** — adjacent to a high-end dashboard or a futuristic operations console. Type is geometric sans (Manrope) with confident bold weights and one signature ultra-light display moment for hero numerals. Color is restrained on chrome (white-on-slate) and saturated only at moments that demand attention — the active tab dot, a primary CTA, the accented hero card.

The signature move: **layered translucency**. A single screen has 3–4 distinct glass tiers (faint white wash, mid-strength glass, accent-tinted glass, gradient FAB). Each tier reads as a different "depth" of the same material.

## Colors

This is a **dark-mode-only** aesthetic. Light mode does not exist here — the depth model assumes a dark base.

**Atmospheric base layer** (always behind everything): the page surface is `{colors.surface}` (a near-black slate `#0F172A`), but it is never seen flat. It's overlaid with a top-down vignette (slate-800 → transparent) and 2–3 oversized blurred color blobs (`{colors.atmos-blue}`, `{colors.atmos-cyan}`, `{colors.atmos-indigo}` at 10–30% opacity, blur radius 80–100px). These blobs are NOT decoration — they are the depth field that the glass surfaces refract.

**Chrome glass tiers** (translucent white over the atmospheric layer):
- `{colors.surface-glass}` (white at 10%) — the default card / list-row / nav fill
- `{colors.surface-glass-strong}` (cyan at 20%) — the featured / hero card variant
- `{colors.border-glass}` (white at 20%) and `{colors.border-glass-faint}` (white at 10%) — the hairline that defines every glass edge

**Foreground type tiers** on glass:
- `{colors.on-surface}` (full white) — primary content, numerals, headings
- `{colors.on-surface-variant}` (white at 60%) — body, secondary labels
- `{colors.on-surface-muted}` (white at 40%) — metadata, tertiary, inactive nav

**Brand accent**: `{colors.primary}` (electric cyan `#38BDF8`) reserved exclusively for active state, primary CTA gradient stop, focus rings, and active-tab indicator. Never used as a card background — when cyan is the fill, it's at 20% alpha (`{colors.surface-glass-strong}`), never solid.

**Semantic / categorical accents** (used inside icons and small inline marks): `{colors.illus-yellow}` (sunshine), `{colors.illus-orange}` (heat / UV warm side), `{colors.illus-green}` (positive / safe), `{colors.illus-violet}` (specialty). These are categorical signal colors only — they never bleed into chrome (no green cards, no orange buttons).

**Hard palette boundary**: the atmospheric blob colors (`atmos-*`) live exclusively behind the glass; they are never used as a foreground or fill on a component. The `illus-*` colors live exclusively as icon tints and never as backgrounds. The brand `primary` is the only saturated color allowed on a foreground role.

## Typography

The system runs on **Manrope** (Google Fonts) at three weight tiers: 300 (one signature display moment), 500/600 (body and labels), 700 (headings, bold numerals). Playfair Display and JetBrains Mono are loaded but unused in chrome — treat them as available for one-off editorial moments only.

Typography is **tight, geometric, and confident**. Most type sits at slightly negative tracking (`-0.005em` to `-0.04em`) to feel modern and dense. The exception is `{typography.micro-uppercase}` (tab labels, tiny meta-kickers) which uses positive tracking (`+0.02em`) to compensate for small size.

Role guide:
- `{typography.display-lg}` (48px / 300 / -0.04em) — hero numeric display. Used for the large featured number on a primary screen. Its **light weight is non-negotiable** — it's the aesthetic's signature contrast against everything else being bold.
- `{typography.headline-lg}` (24px / 700) — primary screen titles
- `{typography.headline-md}` (20px / 700) — featured card titles, prominent inline headings
- `{typography.headline-sm}` (18px / 700 / +0.02em) — section anchor (top-bar centered title with optional subtitle below)
- `{typography.numeral-xl}` (24px / 700) — bold compact numerals on metric tiles and list rows
- `{typography.body-md}` / `{typography.body-sm}` — paragraph and inline body
- `{typography.label-md}` / `{typography.label-sm}` — buttons, chips, list-row meta
- `{typography.caption}` — supporting captions under metrics
- `{typography.micro-uppercase}` (10px / 600 / +0.02em / uppercase) — tab labels, tiny status kickers like "GOOD" / "MODERATE"

Weight rule of thumb: **bold (700) is the workhorse for any anchoring text; light (300) is reserved for the single hero numeric on a screen; everything in between is 500–600**.

## Spacing & Layout

**Density: balanced-airy.** Cards have generous internal padding (`{spacing.card-padding}` = 20px, or 24px on featured cards). Between sections, expect `{spacing.section-gap}` (24px). Side gutter is `{spacing.gutter}` (24px) — content never touches the screen edge.

The layout breathes around its glass panels. Stacked cards sit ~12–16px apart vertically (`{spacing.md}`). Inside a card, icon-to-text gap is typically `{spacing.sm}` (8px). Horizontally scrolled rails use `{spacing.sm}`–`{spacing.md}` between tiles and bleed past the gutter (`-mx-6 px-6`) so the last visible tile teases off the edge.

The bottom tab bar floats with `{spacing.md}` (16px) inset from all three bottom edges — it is never flush to the screen.

## Elevation & Depth

Depth here is conveyed by **translucency tiers and atmospheric blur**, not traditional shadow ramps. The hierarchy:

1. **Tier 0 — atmospheric**: blurred color blobs behind everything. No surface, just light.
2. **Tier 1 — faint glass** (`bg-white/5` + `border-white/10`): default cards, list rows, secondary surfaces.
3. **Tier 2 — mid glass** (`bg-white/10` + `border-white/20`): nav chrome, icon buttons, inputs, the bottom tab bar.
4. **Tier 3 — accent glass** (cyan tint at 20% + cyan border at 30%): the one featured / "primary" card on a screen, plus active chips and active-state pills.
5. **Tier 4 — solid gradient**: the floating FAB. The only fully opaque surface on the screen, intentionally pushing forward.

Box-shadows exist but are subtle and used to accent specific tiers:
- Default card: `0 4px 16px rgba(0,0,0,0.20)` — barely there, settles the glass on the field
- Featured/accent card: `0 8px 32px rgba(6,182,212,0.15)` — cyan-tinted glow consistent with the tier
- Tab bar: `0 8px 32px rgba(0,0,0,0.30)` — pronounced under-shadow because it floats
- FAB: `0 4px 15px rgba(6,182,212,0.40)` — saturated cyan glow

Backdrop-blur is mandatory on every glass surface (`backdrop-blur-md` for default, `backdrop-blur-xl` for hero/nav). Without it, the aesthetic collapses.

## Shapes

The shape vocabulary is **softly geometric** — generous rounding everywhere, no sharp corners.

- `{rounded.sm}` (8px) — small inline marks: badge-pills, tiny progress bars, micro chips
- `{rounded.md}` (16px) — inputs, segmented controls, secondary buttons
- `{rounded.lg}` (24px) — the dominant card / list-row radius. Most surfaces sit here.
- `{rounded.xl}` (32px) — extra-large hero cards (rare; used when a card is screen-dominant)
- `{rounded.full}` — every pill: primary CTA, icon buttons, FAB, active-tab dot, progress bars

Rule: **interactive elements with text are pills (`rounded-full`); container surfaces are `rounded-lg` (24px)**. There is no use of square or low-radius (`rounded-sm` 8px and below) on a primary surface — only on inline accents.

## Components

### card

The default surface. Faint white glass on the atmospheric field.

```html
<div class="rounded-3xl bg-white/10 backdrop-blur-lg border border-white/15 p-5 shadow-lg">
  <div class="flex items-center space-x-2 mb-3">
    <iconify-icon icon="solar:[icon-name]-bold" class="size-5 text-[#4ADE80]"></iconify-icon>
    <span class="text-sm font-medium text-white/80">[Card title]</span>
  </div>
  <div class="text-white">[Card body]</div>
</div>
```

### card-accent

The "this is the most important card on this screen" variant. Cyan-tinted glass + cyan border + cyan glow.

```html
<div class="relative overflow-hidden rounded-3xl bg-gradient-to-br from-cyan-500/20 to-blue-600/20 backdrop-blur-xl border border-cyan-400/30 p-6 shadow-[0_8px_32px_0_rgba(6,182,212,0.15)]">
  <div class="flex justify-between items-start">
    <div>
      <div class="flex items-center space-x-2 mb-1">
        <iconify-icon icon="solar:[icon-name]-bold" class="size-5 text-cyan-400"></iconify-icon>
        <span class="text-xl font-bold">[Title]</span>
      </div>
      <p class="text-cyan-100/70 text-sm">[Subtitle]</p>
    </div>
    <iconify-icon icon="solar:[icon-name]-bold" class="size-10 text-cyan-300 drop-shadow-[0_0_10px_rgba(103,232,249,0.5)]"></iconify-icon>
  </div>
  <div class="mt-6 flex items-end justify-between">
    <div>
      <div class="text-5xl font-light tracking-tighter text-white">[Value]</div>
      <div class="text-sm text-cyan-100 mt-1 font-medium">[Caption]</div>
    </div>
  </div>
</div>
```

Note the **drop-shadow on the featured icon** — `drop-shadow-[0_0_10px_rgba(103,232,249,0.5)]` is a recurring signature for "important" inline icons. Use sparingly, only on hero-card icons.

### button-primary

The cyan→blue gradient pill. Reserved for one-per-screen primary CTAs.

```html
<button class="h-14 px-6 rounded-full bg-gradient-to-br from-cyan-400 to-blue-600 text-white font-semibold text-sm shadow-[0_4px_15px_rgba(6,182,212,0.40)] active:scale-95 transition-transform flex items-center justify-center gap-2">
  [Action label]
</button>
```

### button-secondary

Glass pill / rounded button.

```html
<button class="h-14 px-4 rounded-2xl bg-white/10 backdrop-blur-md border border-white/20 text-white/80 font-semibold text-sm active:scale-95 transition-transform">
  [Action label]
</button>
```

### button-text

Subtle inline cyan link.

```html
<button class="text-cyan-300 text-sm font-semibold">[See all]</button>
```

### button-icon-glass

Round glass pill for icon-only chrome buttons (top-bar back/menu, overflow). Universal in this aesthetic.

```html
<button class="p-2 rounded-full bg-white/10 backdrop-blur-md border border-white/20 active:scale-95 transition-transform">
  <iconify-icon icon="solar:[icon-name]-linear" class="size-6 text-white"></iconify-icon>
</button>
```

### input-text

Glass input with leading icon convention and cyan focus ring.

```html
<div class="relative">
  <div class="absolute inset-y-0 left-4 flex items-center pointer-events-none z-20">
    <iconify-icon icon="solar:magnifer-linear" class="size-5 text-white/60"></iconify-icon>
  </div>
  <input
    type="text"
    class="w-full bg-white/10 border border-white/20 rounded-2xl py-4 pl-12 pr-4 text-white placeholder:text-white/40 focus:outline-none focus:ring-2 focus:ring-cyan-500/50 backdrop-blur-md transition-all relative z-10"
    placeholder="[Placeholder text]"
  />
</div>
```

### chip / chip-active (segmented control)

Chips here appear as a segmented control inside a glass tray — not as standalone tags. Active = cyan-tinted glass + cyan text + cyan-30 border.

```html
<div class="flex p-1 bg-white/5 backdrop-blur-md border border-white/10 rounded-2xl">
  <button class="flex-1 py-2 text-sm font-semibold rounded-xl bg-cyan-500/20 text-cyan-400 border border-cyan-400/20">[Active]</button>
  <button class="flex-1 py-2 text-sm font-semibold rounded-xl text-white/40 hover:text-white/60 transition-colors">[Inactive]</button>
</div>
```

### badge-pill

A tiny tinted-glass pill used to label scope ("Next Nh", "New", a category).

```html
<span class="text-xs font-bold bg-blue-500/20 text-blue-200 px-2 py-1 rounded-lg">[Scope]</span>
```

### badge-circle

A 4px solid cyan dot — the active-tab marker. That's its primary role; don't use it for counts in this aesthetic.

```html
<div class="size-1 bg-cyan-400 rounded-full"></div>
```

### list-row

A glass row, often as a stack of "items" on a list screen. Identical surface to `card` but typically wider with a horizontal layout inside.

```html
<div class="relative overflow-hidden rounded-3xl bg-white/5 backdrop-blur-lg border border-white/10 p-5">
  <div class="flex justify-between items-center">
    <div>
      <h2 class="text-xl font-bold">[Title]</h2>
      <p class="text-white/40 text-xs mt-1">[Subtitle]</p>
    </div>
    <div class="text-right">
      <iconify-icon icon="solar:[icon-name]-bold" class="size-8 text-white/60"></iconify-icon>
      <div class="text-2xl font-bold mt-1">[Value]</div>
    </div>
  </div>
</div>
```

**Tonal recipe for "featured" list row**: render a `list-row` with the `card-accent` surface treatment (cyan-tinted gradient + cyan border) when one row in a list deserves emphasis. The implementer composes — no separate component.

### progress-bar

A thin pill rail with a gradient fill. Use cyan for accent, multi-stop (green→yellow→orange) for graded scales.

```html
<div class="w-full h-3 bg-white/10 rounded-full overflow-hidden">
  <div class="h-full w-1/3 bg-gradient-to-r from-green-400 via-yellow-400 to-orange-500 rounded-full"></div>
</div>
```

### progress-ring

A circular SVG ring inside a 96px frame, with centered numeral + uppercase status caption inside.

```html
<div class="size-24 rounded-full border-[6px] border-white/10 relative flex items-center justify-center">
  <svg viewBox="0 0 100 100" class="absolute inset-0 -rotate-90">
    <circle r="42" cx="50" cy="50" fill="none" stroke="currentColor" stroke-width="6" stroke-linecap="round" class="text-green-400" stroke-dasharray="264" stroke-dashoffset="100" />
  </svg>
  <div class="flex flex-col items-center z-10">
    <span class="text-2xl font-bold text-white">[Value]</span>
    <span class="text-[10px] text-green-300 font-semibold uppercase tracking-wide">[Status]</span>
  </div>
</div>
```

### top-app-bar

Transparent (sits over the atmospheric layer); a centered title-with-subtitle stack flanked by two glass icon buttons.

```html
<div class="flex items-center justify-between">
  <button class="p-2 rounded-full bg-white/10 backdrop-blur-md border border-white/20 active:scale-95 transition-transform">
    <iconify-icon icon="solar:arrow-left-linear" class="size-6 text-white"></iconify-icon>
  </button>
  <div class="flex flex-col items-center">
    <span class="text-lg font-bold tracking-wide">[Screen title]</span>
    <span class="text-xs text-white/50 tracking-wider">[Subtitle / meta]</span>
  </div>
  <button class="p-2 rounded-full bg-white/10 backdrop-blur-md border border-white/20 active:scale-95 transition-transform">
    <iconify-icon icon="solar:menu-dots-bold" class="size-6 text-white"></iconify-icon>
  </button>
</div>
```

When a screen has no back action (top-level), the left button is omitted and the title left-aligns as `{typography.headline-lg}`.

### tab-bar (floating glass with center FAB)

The bottom navigation is a **signature element**: a floating glass pill housing 4 tab items + a raised gradient FAB protruding above its center. The FAB's bottom-edge ring is 4px of `surface` color, which makes it appear notched into the bar.

```html
<div class="fixed bottom-0 left-0 right-0 p-4 z-50">
  <div class="bg-white/10 backdrop-blur-xl border border-white/20 rounded-3xl h-16 flex items-center justify-around px-2 shadow-[0_8px_32px_0_rgba(0,0,0,0.30)]">
    <!-- inactive tab -->
    <button class="flex flex-col items-center justify-center w-14 h-full space-y-1 text-white/50 hover:text-white transition-colors">
      <iconify-icon icon="solar:[icon-name]-linear" class="size-6"></iconify-icon>
    </button>
    <!-- inactive tab -->
    <button class="flex flex-col items-center justify-center w-14 h-full space-y-1 text-white/50 hover:text-white transition-colors">
      <iconify-icon icon="solar:[icon-name]-linear" class="size-6"></iconify-icon>
    </button>
    <!-- center FAB -->
    <button class="flex flex-col items-center justify-center -mt-8">
      <div class="size-14 bg-gradient-to-br from-cyan-400 to-blue-600 rounded-full flex items-center justify-center shadow-[0_4px_15px_rgba(6,182,212,0.40)] border-4 border-indigo-950/80">
        <iconify-icon icon="solar:add-circle-bold" class="size-6 text-white"></iconify-icon>
      </div>
    </button>
    <!-- active tab -->
    <button class="flex flex-col items-center justify-center w-14 h-full space-y-1 text-cyan-400">
      <iconify-icon icon="solar:[icon-name]-bold" class="size-6"></iconify-icon>
      <div class="size-1 bg-cyan-400 rounded-full"></div>
    </button>
    <!-- inactive tab -->
    <button class="flex flex-col items-center justify-center w-14 h-full space-y-1 text-white/50 hover:text-white transition-colors">
      <iconify-icon icon="solar:[icon-name]-linear" class="size-6"></iconify-icon>
    </button>
  </div>
</div>
```

Active tab convention: switch icon variant from `linear` → `bold`, switch color to `text-cyan-400`, and add a 4px solid cyan dot below the icon.

### Composition recipes (not components)

- **Metric tile** (small square card with icon + ring or bar + numeric value + caption): compose from `card` + a `progress-ring` or `progress-bar` + a centered numeral block. Don't add a `metric-tile` component — the interesting decisions are already in the primitives.
- **Hourly / horizontal scroll rail of mini-tiles**: compose by repeating a vertical `flex-col` 80px-wide pill (`rounded-2xl bg-white/5 border border-white/10` for inactive, `bg-cyan-500/30 border-cyan-400/30` for the active "now" one) inside an `overflow-x-auto` row that bleeds beyond the gutter (`-mx-6 px-6`).
- **Bar chart row** (paired vertical bars with labels below): each bar is a `bg-{color}/N rounded-t-lg` div whose height encodes the value; the label sits below in `body-sm text-white/50`. Heights step down in a clear visual rhythm.
- **Day-row in a vertical list**: a `list-row` whose internal layout is `[day-label, weather-icon] · [condition-word] · [high °, low °]`, with high in full white and low in white/30. Featured ("today") row gets the `card-accent` treatment plus a 3-column metric strip below a `border-t border-white/10` divider.

### Tonal recipes

- For a low-attention secondary action, render `button-secondary` with `bg-white/5` instead of `bg-white/10` and a `border-dashed border-white/20` — this becomes the "add new" CTA pattern.
- For a destructive action, swap the gradient on `button-primary` for solid `{colors.error}` with no glow.
- For a success/info badge, swap `badge-pill`'s `bg-blue-500/20 text-blue-200` for `bg-green-500/20 text-green-200` etc., keeping the same shape, padding, and weight.

## Iconography

**Set: Solar (Iconify `solar:*`).** Solar's rounded geometric construction matches Manrope's geometric feel and the soft 24px corner radii of the surfaces. Don't substitute another set — proportions and terminals will clash.

**Variant convention**:
- **Inactive / chrome / passive icons** → `linear` variant (`solar:home-2-linear`, `solar:settings-linear`)
- **Active state, hero / featured icons, semantically-colored small accents** → `bold` variant (`solar:home-2-bold`, `solar:cloud-rain-bold`)
- The active-state switch is **always** `linear → bold` paired with a color shift to `text-cyan-400`

**Sizes**:
- 12–14px (`size-3` / `size-3.5`) — inline-with-meta-text accent icons
- 16–20px (`size-4` / `size-5`) — small icons inside inputs, list-row corners, status icons
- 24px (`size-6`) — the default chrome size: tab-bar items, top-bar buttons, list-row leading icons
- 32px (`size-8`) — featured icons inside cards (weather hero, day-row condition)
- 40px (`size-10`) — the single largest icon on a hero card

**Categorical color tints** for inline icons: cyan (`text-cyan-300/400`) for primary/highlight, yellow/orange (`text-yellow-400`, `text-orange-400`) for warm/sun, green (`text-green-400`) for positive/safe, white at varying opacities for chrome-default. Tint is applied via Tailwind text-color classes; the icon set always renders as the current `text-color`.

**Glow technique**: any "hero" icon inside an accent card may receive `drop-shadow-[0_0_10px_rgba(103,232,249,0.5)]` to bloom against the glass. Use only for the largest icon on a featured surface, never on chrome.

## Illustration & Imagery

**Note**: no source images present in HTML. This section is *inferred* from the aesthetic's type, color, and shape language — treat as a starting point, not ground truth. If a future round of extraction includes images, this section should be replaced with extracted values.

- **Style / Technique**: soft 3D glass-volumetric icons or low-poly soft-render shapes — semi-transparent, gently lit, with subtle inner glow consistent with the chrome glass tiers. Alternatively (when a single illustration is needed), a flat-vector silhouette in saturated cyan/violet gradient over a blurred-blob background. NOT photographic, NOT hand-drawn, NOT cartoon-character-driven.
- **Palette**: limited to 2–4 colors per illustration drawn from `{colors.illus-cyan}`, `{colors.illus-yellow}`, `{colors.illus-orange}`, `{colors.illus-violet}`, plus the atmospheric blues. Saturation is medium-high; everything reads as "lit from within." No earth tones, no muted pastels, no warm beige.
- **Edge treatment**: no hard outlines. Forms are defined by the gradient or the inner highlight, not a stroke. If an outline is necessary, use a 1px hairline at `{colors.border-glass}`.
- **Shading & light**: soft gradient shading with a clear single light direction (top-right). Highlights are bloomy / glowy rather than hard specular. Suggested treatment: emulate the `drop-shadow-[0_0_10px_...]` glow already used on icons.
- **Composition & framing**: subject centered or slightly off-center, sitting inside abundant negative space. Subject occupies ~40–60% of the frame. Bleed to edges only in hero contexts.
- **Background within the illustration**: transparent — the illustration sits on the page's atmospheric layer (the glass card surface or the blurred-blob field). Never a solid color background under the subject.
- **Container styling**: place inside a standard `card` (`rounded-3xl bg-white/10 backdrop-blur-lg border border-white/15`, `p-5`) — no special illustration frame. For full-width hero illustrations, drop the border and let the illustration bleed within `p-6`.
- **CSS treatment on `<img>`**: `object-fit: contain` (preserve subject); no `mix-blend-mode`; opacity 100%; no filter. The illustration must look the same as it would on a transparent canvas.
- **Box-shadow on the image / frame**: none on the image itself (the surrounding card carries the shadow). If standalone-floated, an optional `drop-shadow-[0_0_20px_rgba(56,189,248,0.30)]` echoes the cyan glow language.
- **Aspect ratio rule**: prefer square (1:1) for inline tile illustrations; 4:3 or 16:9 for hero band illustrations. Preserve source ratio — do not crop.
- **Anti-references**: NOT photographic, NOT hand-drawn, NOT watercolor, NOT claymation, NOT pastel, NOT warm/earthy, NOT cartoon mascot, NOT line-art-only.
- **Style recipe prompt**:

  > *Soft 3D volumetric icon of [SUBJECT], rendered in translucent glass-like material with gentle internal glow, lit from upper-right with bloomy soft highlights. Palette limited to electric cyan, deep blue, and one warm accent (yellow or orange) at most; saturation medium-high; no hard outlines, edges defined by gradient and highlight. Centered with generous negative space, transparent background. Cool, technical, atmospheric mood — like a futuristic dashboard icon. Not photographic, not pastel, not cartoon, not hand-drawn.*

## Hierarchy & Emphasis

Visual weight in this aesthetic is conveyed by:
1. **Tier upgrade** — moving a surface from faint glass → mid glass → accent glass is the loudest move on a screen. Use it once per screen at most.
2. **Saturation** — cyan is the only saturated foreground color. Anywhere it appears (CTA, active state, focus, primary numeral icon), it draws the eye first.
3. **Weight contrast** — a single `display-lg` light-300 numeral against everything else being bold creates an editorial focal point.
4. **Glow** — the cyan-tinted box-shadow and `drop-shadow` on hero icons.

Whisper-tier (metadata, helper captions) lives at `text-white/40` to `text-white/50`, often paired with `{typography.caption}` or `{typography.micro-uppercase}`. Never make metadata loud.

## Distinctive Details

1. **Atmospheric color blobs behind the chrome.** Every screen needs 2–3 oversized blurred radial gradients (cyan, blue, indigo at 10–30% opacity, blur 80–100px), positioned at screen corners and partially clipped. Without them, the glass has nothing to refract and the aesthetic reads flat.
2. **The notched FAB.** The center bottom-tab FAB has a 4px-wide ring in the page's surface color (`border-indigo-950/80` or matching), making it appear cut into the floating tab bar. This is unique to this aesthetic — don't render the FAB as a flat floating circle without the notch.
3. **Glow drop-shadow on hero icons.** A `drop-shadow-[0_0_10px_rgba(103,232,249,0.5)]` (or matching color) on the single biggest icon inside an accent card. It's the smallest distinctive detail and it's what makes the design feel "lit" rather than just "translucent."

## Do's and Don'ts

### Do

- Always render glass surfaces with `backdrop-blur-md` (default) or `backdrop-blur-xl` (nav/hero). Backdrop-blur is mandatory.
- Place 2–3 atmospheric color blobs behind the content on every screen.
- Use `rounded-3xl` (24px) as the default surface radius and `rounded-full` for every interactive pill.
- Pair cyan brand color with translucent backgrounds (20–30% alpha) — never solid cyan as a card fill.
- Switch icon variant from `linear` → `bold` for active state; pair with `text-cyan-400`.
- Use the light-300 `display-lg` for at most one numeric value per screen — it's a precious moment.
- Keep all metadata at `text-white/40`–`text-white/50` — whispers stay whispers.

### Don't

- Don't use solid saturated colors as card backgrounds. Cyan, blue, green, orange, yellow ALL stay either as icon tints or as alpha-blended glass fills — never as a solid surface.
- Don't omit `backdrop-blur` on glass — it collapses to flat translucent rectangles and looks broken.
- Don't use the atmospheric blob colors (`atmos-blue`, `atmos-cyan`, `atmos-indigo`) as foreground fills — they live exclusively behind the glass.
- Don't pile on saturated colors. One screen has one accent card, one CTA, one active tab. Restraint is the look.
- Don't render the bottom tab FAB without the 4px surface-colored ring — the notch effect is signature.
- Don't use square or sharp corners. The smallest acceptable container radius is `rounded-2xl` (16px) on inputs/segments; everything else is 24px+.
- Don't introduce a light mode. The depth model assumes a dark base; ported to light, the glass tier system stops working.
- Don't use Playfair Display or JetBrains Mono in chrome — Manrope is the chrome typeface.
- Don't add character mascots or photographic imagery — the aesthetic is geometric/atmospheric, not narrative.
