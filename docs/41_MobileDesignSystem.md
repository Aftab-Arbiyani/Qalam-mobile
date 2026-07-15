# 41 — Mobile Design System (Flutter · Material 3)

> **Qalam** (قلم / क़लم — "the pen") — the mobile visual & interaction system.
> This document is the **permanent source of truth** for how the Flutter app looks, moves, and
> feels. Every mobile epic (**M1–M10**) MUST comply with it.
>
> **Companion:** `docs/40_MobileArchitecture.md` (structure/code architecture).
> **Upstream truth:** `docs/07_DesignSystem.md`, `docs/06_UIUXSpecification.md`,
> `docs/08_ComponentLibrary.md`, ADR §6–§7 (`docs/00`). The web design system is complete; the
> mobile system **translates it faithfully to Material 3 + native gestures**, it does not reinvent it.
>
> **Status:** Approved as the baseline for M1. No Flutter/UI code has been written yet.

---

## 0. How to read this document

Qalam already has a mature web design system — "warm paper and ink," a premium writing sanctuary. The
mobile app inherits it exactly: **same tokens, same voice, same two-scripts-one-dignity commitment.**
What changes is the *substrate*: Material 3 instead of AntD + Tailwind, native gestures instead of
hover, bottom navigation instead of a top bar, bottom sheets instead of desktop modals.

Three rules govern the translation:

1. **Tokens are law.** Every color, size, spacing, radius, and duration comes from a token whose value
   is identical to the web `--q-*` token. No raw hex, no magic numbers, no ad-hoc durations.
2. **Material 3 is the substrate, not the master.** We adopt M3's structure (ColorScheme, typography
   roles, components) but **override** where M3 conflicts with the Qalam system (warm shadows, static
   labels, 44px targets, Lucide icons, per-content directionality).
3. **RTL / Nastaliq is day one.** Urdu (RTL) and Hindi (Devanagari) are first-class from the first
   widget — never a retrofit. Direction is derived *per content language*, independent of UI chrome.

Every value below is quoted from the canonical Qalam tokens; keep them byte-identical to the web
`packages/ui` tokens and ADR §7.

---

## Table of contents

1. Design Philosophy
2. Mobile UX Principles
3. Material 3 Adaptation
4. Typography Scale
5. Color Tokens
6. Dynamic Color Support
7. Spacing System
8. Elevation Scale
9. Border Radius Scale
10. Iconography
11. Component Catalog
12. Animation Guidelines
13. Motion Principles
14. Page Transitions
15. Gesture Guidelines
16. Pull To Refresh
17. Infinite Scrolling
18. Swipe Actions
19. Haptic Feedback
20. Accessibility Guidelines
21. Dark Theme
22. Light Theme
23. Adaptive Layout Rules
24. Phone Layouts
25. Tablet Layouts
26. Landscape Rules
27. Safe Area Rules
28. Keyboard Handling
29. Form UX
30. Offline UX
31. Connectivity UX
32. Error UX
33. Empty State UX
34. Search UX
35. Reading Experience UX
36. Writing Experience UX
37. Notification UX
38. Analytics UX
39. Admin-only Components
40. Mobile QA Checklist

---

## 1. Design Philosophy

Qalam is **"a premium writing sanctuary — warm paper and ink, not a content feed with a text box
bolted on."** Every design decision is judged by one question: *does this make the writing feel more
important, or less?*

Two postures live in the app and never bleed into each other:

- **Reading** — the interface disappears; typography carries everything; chrome recedes.
- **Everything else** — calm utility; quiet; generous whitespace; nothing shouts.

The eight product principles (inherited verbatim from `docs/06`, applied to mobile):

1. **Writing is the hero.** Body text gets the largest, most refined type. No chrome element on a
   reading screen out-weighs the prose.
2. **Whitespace is a feature.** Generous margins are the sanctuary; density is a last resort (only
   analytics). Minimum 32px between major sections on mobile.
3. **Chrome recedes while reading.** The top bar and reading rail fade after a short downward scroll;
   restored quickly on upward scroll or an edge tap.
4. **Never make the writer wait.** Continuous ambient autosave; skeletons within 100ms; spinners are
   banned on content surfaces (they live only inside buttons).
5. **Undo over confirm.** Reversible actions execute immediately with a 5s undo; dialogs are reserved
   for the irreversible.
6. **Two scripts, one dignity.** Urdu (RTL, Nastaliq) is first-class, not a mirrored afterthought;
   logical directionality from the first widget.
7. **Quiet numbers.** Stats are secondary-weight and small; metrics inform, never gamify. No red
   badges; notification indicators use the accent, not alarm-red.
8. **Literary voice everywhere.** Empty states, errors, confirmations read like an editor wrote them —
   short, warm, never exclamatory.

**Aesthetic anchors:** warm paper canvas, ink text, a single terracotta accent, serif reading faces
with per-script care, soft warm shadows in light, border-and-surface elevation in dark. Calm motion
that clarifies, never entertains.

---

## 2. Mobile UX Principles

Translating the philosophy to a touch device:

- **Thumb-first.** Primary actions sit within thumb reach (bottom bar, bottom sheets, bottom action
  rails on reading). The compose CTA is the accented **Write** tab, centrally placed.
- **Gestures augment, never replace.** Every swipe action has a visible tap equivalent; the app is
  fully usable without learning a single gesture. (Swipe to archive a notification also has an
  overflow menu.)
- **Bottom sheets over center dialogs.** On phones, choices and forms rise from the bottom edge where
  the thumb is, not from screen center.
- **One primary action per screen.** Matching "one accent" — a screen has at most one filled accent
  button; everything else is secondary/ghost.
- **Motion is short and purposeful.** 150/250/400ms; entrances decelerate ("settling on paper"),
  exits accelerate; pages fade, never slide (a book doesn't slide).
- **Respect the platform, keep the brand.** Native scroll physics, native keyboard behavior, native
  back gesture — but Qalam's type, color, spacing, and voice throughout. Android and iOS are equal;
  differences are limited to platform-idiomatic affordances (back gesture, share sheet, haptics).
- **Immediate, honest feedback.** Optimistic for reversible taps (like/clap/bookmark/follow) with
  rollback; pending state for irreversible ones (publish); never a fake success.
- **Density stays low.** Even on small screens, prefer scrolling to cramming. Reading and writing
  surfaces are especially uncrowded.

---

## 3. Material 3 Adaptation

Qalam Mobile uses **Material 3** as its widget substrate and themes it entirely from Qalam tokens.
Material 3 gives structure (ColorScheme, text theme, component anatomy, state layers); Qalam overrides
the parts where M3 defaults conflict with the sanctuary aesthetic.

### 3.1 What we adopt from M3

- `ThemeData(useMaterial3: true)` with a `ColorScheme` derived from Qalam color tokens.
- M3 component *anatomy and behavior* (ripples/state layers, focus, semantics, touch feedback).
- M3 text-theme *roles* as a mapping target for the Qalam type scale.
- M3 `NavigationBar`, `NavigationRail`, `BottomSheet`, `SnackBar`, `Dialog`, `Chip`, `Badge`,
  `SearchBar` as bases — restyled to Qalam.

### 3.2 What we override (the deliberate divergences)

| M3 default | Qalam override | Why |
| --- | --- | --- |
| Tonal (surface-tint) elevation | **Warm drop shadows in light; border + one surface step in dark** | ADR §7: warmth, and "borders over shadows in dark." Suppress surface-tint elevation. |
| Floating input labels | **Static labels above the field** | Floating labels misbehave in RTL + Nastaliq (`docs/06` §7.2). |
| 48px min touch target | **≥44px floor** (grow small controls to 44) | Qalam's documented minimum; still comfortable. |
| Material Icons | **Lucide icons, 1.5px stroke, outline** | The Qalam icon set (`docs/07` §6). |
| Purple/dynamic default accent | **Single terracotta accent** (`--q-accent`) | One brand hue; no ad-hoc colors. |
| Material motion (shared-axis slides) | **Fade / fade-rise; no page slides** | "A book doesn't slide." |
| Pill/large default radii | **6 controls / 10 cards / 16 sheets** | Qalam radius scale. |
| Device dynamic color (Material You) | **Off** — brand palette is fixed | See §6. |

### 3.3 Theme construction

Two `ThemeData` objects (light, dark), each built from the Qalam token maps, plus a **`ThemeExtension`
(`QTokens`)** carrying the tokens Material's `ColorScheme`/`TextTheme` cannot express: the semantic
`-text`/`-bg` triplets, `accent-subtle`, `accent-contrast`, `border-strong`, warm shadow definitions,
reading fonts, reading line-heights, and motion tokens. Widgets read tokens from `Theme.of(context)`
(Material roles) and `Theme.of(context).extension<QTokens>()` (Qalam-specific tokens). **No widget
hardcodes a value.**

### 3.4 ColorScheme mapping (roles → tokens)

| M3 ColorScheme role | Qalam token |
| --- | --- |
| `primary` | `--q-accent` |
| `onPrimary` | `--q-accent-contrast` |
| `surface` / `surfaceContainerLowest` | `--q-bg-surface` |
| `surfaceContainer` / `surfaceContainerHigh` | `--q-bg-raised` |
| `background` (scaffold) | `--q-bg-canvas` |
| `onSurface` | `--q-text-primary` |
| `onSurfaceVariant` | `--q-text-secondary` |
| `outline` | `--q-border-strong` |
| `outlineVariant` | `--q-border` |
| `error` | `--q-danger` |
| `tertiary`/others | mapped from semantic tokens as needed (success/warning/info live in `QTokens`) |

`ThemeData.scaffoldBackgroundColor = --q-bg-canvas`; `cardTheme`/`dialogTheme`/`bottomSheetTheme`
restyled to Qalam radii + elevation model; `elevation` set to 0 with explicit Qalam shadows applied by
component wrappers.

---

## 4. Typography Scale

Type is the product. The scale is the web scale exactly (1.25 ratio), with mobile-specific reading
sizes.

### 4.1 Font families (self-hosted assets, bundled — no CDN)

| Token | Stack (fallthrough per glyph) | Used for |
| --- | --- | --- |
| `--q-font-ui` | Inter → Noto Sans Devanagari → Noto Naskh Arabic → system | All chrome: nav, buttons, forms, meta, stats |
| `--q-font-reading` | Lora → Noto Serif Devanagari → Georgia (serif) | Reading body + titles, editor surface (Latin & Hindi) |
| `--q-font-reading-ur` | Noto Nastaliq Urdu → Noto Naskh Arabic (serif) | **Urdu reading body + titles only** (never chrome) |
| `--q-font-mono` | JetBrains Mono → monospace | IDs, request-id, code |

**Per-script strategy:** the UI stack falls through per glyph (Latin→Inter, Devanagari→Noto Sans
Devanagari, Arabic-script→Naskh) — chrome uses ONE family, no per-locale switch. **Reading** switches
family by the piece's language: Latin/Hindi → `--q-font-reading` (Lora / Noto Serif Devanagari), Urdu
→ `--q-font-reading-ur` (Noto Nastaliq Urdu). Nastaliq is heavy and **loaded on demand** by the Urdu
reading surface (bundled asset, lazily registered), never on the UI critical path.

### 4.2 Type scale (12 / 14 / 16 / 20 / 25 / 31 / 39 / 49 — 1.25 ratio)

| Token | Size | Role | Weight | Line-height | Usage | M3 role (approx) |
| --- | --- | --- | --- | --- | --- | --- |
| `--q-text-xs` | 12 | caption | 400 | 1.5 | timestamps, badge counts, chart axes | labelSmall |
| `--q-text-sm` | 14 | body-sm | 400/500 | 1.5 | default UI text, buttons, inputs, meta | bodyMedium / labelLarge |
| `--q-text-base` | 16 | body | 400 | 1.5 | card excerpts, settings copy, dialogs | bodyLarge |
| `--q-text-lg` | 20 | title-sm | 500 | 1.4 | section headers, sheet titles, compact-card titles | titleMedium |
| `--q-text-xl` | 25 | title | 500 | 1.35 | feed card titles, pen name, page titles | titleLarge |
| `--q-text-2xl` | 31 | heading | 600 | 1.3 | analytics header, auth headline | headlineSmall |
| `--q-text-3xl` | 39 | display | 600 (serif 500) | 1.25 | piece title (reading serif), editor title | headlineMedium |
| `--q-text-4xl` | 49 | hero | 600 | 1.15 | onboarding/landing only | displaySmall |

### 4.3 Reading sizes (independent of UI scale; user-adjustable S / M / L)

| Script | S / **M (default)** / L | Line-height token | Value |
| --- | --- | --- | --- |
| Latin (Lora) | 18 / **20** / 22 | `--q-leading-reading` | **1.7** |
| Devanagari (Noto Serif Dev) | 18 / **20** / 22 | `--q-leading-devanagari` | 1.8 |
| Nastaliq (Urdu) | 20 / **22** / 24 | `--q-leading-nastaliq` | **2.1** (never < 2.0) |
| UI (all scripts) | — | `--q-leading-ui` | **1.5** |

Reading measure targets **~65–72ch** (the web caps at 68ch) *measured in the active reading font*; on
a phone the column is the full width minus 16px gutters, which naturally lands in-band — but on tablet/
landscape the column is capped so it never exceeds the measure (§25–§26).

### 4.4 Text rendering rules

- Respect the OS **text-scale** (`MediaQuery.textScaler`) — the type scale multiplies up; layouts must
  not clip at large scales (test to 1.3×+).
- Nastaliq: **letter-spacing 0 always** (tracking breaks cursive joining); **no italic** (emphasis via
  color/quote styling); avoid faux-bold; clamped Urdu text gets +4px block padding.
- Numerals in chrome/stats/dates use **Latin (ASCII) digits** (Phase 1), even inside Urdu-labeled
  badges; the author's own body text renders digits exactly as typed (Eastern Arabic-Indic / Devanagari
  preserved).
- Use `tabular figures` for aligned numeric columns (stats, analytics tables).

---

## 5. Color Tokens

The full palette, light and dark, byte-identical to the canonical Qalam tokens (ADR §7). All values
are exact hex. Widgets reference these via the ColorScheme mapping (§3.4) or the `QTokens` extension.

### 5.1 Neutral & accent

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--q-bg-canvas` | `#FAF7F1` | `#131110` | Page/scaffold background — the paper. |
| `--q-bg-surface` | `#FFFFFF` | `#1C1917` | Cards, sheets, popovers, inputs-on-canvas. |
| `--q-bg-raised` | `#F3EEE5` | `#26221E` | Hover/pressed fills, selected rows, filled inputs. |
| `--q-text-primary` | `#24211B` | `#ECE6DA` | Body & headings — the ink (dark = warm ivory, not pure white). |
| `--q-text-secondary` | `#6B655A` | `#A69F90` | Meta, subtitles, small stats. |
| `--q-text-muted` | `#8F887A` | `#7A7367` | **Large-size-only** tertiary, placeholders, disabled labels. |
| `--q-border` | `#E7E1D6` | `#2E2A24` | Hairlines, dividers, decorative card borders. |
| `--q-border-strong` | `#8F887A` | `#7A7367` | Control boundaries (≥3:1 non-text contrast). |
| `--q-accent` | `#9E4B28` | `#D07349` | Terracotta ink — primary actions, links, active, focus ring. |
| `--q-accent-hover` | `#B45A32` | `#DD8A63` | Hover / pressed-hover on accent. |
| `--q-accent-active` | `#833E21` | `#C2653C` | Pressed accent. |
| `--q-accent-subtle` | `#F5E7DE` | `#3A2A20` | Tinted fills: selected tab wash, quote-card tint, accent chip bg. |
| `--q-accent-contrast` | `#FFFFFF` | `#131110` | Text/icon on accent fills (dark = ink-on-terracotta). |

### 5.2 Semantic (each family: base / `-text` / `-bg`)

| Token | Light | Dark |
| --- | --- | --- |
| `--q-success` | `#3E7C4F` | `#6FA97E` |
| `--q-success-text` | `#2F6B40` | `#6FA97E` |
| `--q-success-bg` | `#EAF0E7` | `#1E2A20` |
| `--q-warning` | `#A97A1F` | `#C9974A` |
| `--q-warning-text` | `#7E5B12` | `#C9974A` |
| `--q-warning-bg` | `#F7EEDC` | `#2E2718` |
| `--q-danger` | `#B3382E` | `#D0655B` |
| `--q-danger-text` | `#B3382E` | `#DA7E74` |
| `--q-danger-bg` | `#F8E7E4` | `#2F1D1A` |
| `--q-info` | `#3B6EA8` | `#7396C2` |
| `--q-info-text` | `#3B6EA8` | `#7396C2` |
| `--q-info-bg` | `#EBF2F9` | `#1D2530` |

Scrim (dialogs/sheets backdrop): `rgba(19,17,16,0.55)` (the ink `#131110` at 55%) in both themes.

### 5.3 Color usage rules (load-bearing)

1. **Muted is large-only.** `--q-text-muted` fails AA at normal size (3.29:1 on canvas); legal only at
   ≥19px (≥24px Nastaliq), placeholders, or disabled controls. Small meta uses `--q-text-secondary`.
2. **Use `-text` for words, base for icons/borders, `-bg` for washes.** e.g. warning *text* is
   `--q-warning-text`, the warning *icon* is `--q-warning`.
3. **One accent.** Terracotta is the only brand hue. No ad-hoc blues/purples/greens outside the
   semantic set.
4. **Borders:** `--q-border` is decorative; anything that must *identify a control boundary* uses
   `--q-border-strong` (≥3:1) or a filled `--q-bg-raised`.
5. **Never color alone.** Pair semantic color with an icon and/or text (WCAG 1.4.1).
6. **Dark accent buttons take ink-on-terracotta** (`--q-accent-contrast` = `#131110`) — white-on-
   accent fails contrast in dark's lighter accent.

---

## 6. Dynamic Color Support

**Decision: Material You device dynamic color is OFF.** Qalam has a single, deliberate brand hue
(terracotta) and a warm-paper palette that is core to the "sanctuary" identity. Adopting the device
wallpaper palette would break brand consistency, RTL/dark carefully-tuned contrast ratios, and the
"one accent" rule.

- The `ColorScheme` is **always** built from Qalam tokens (§5), never from
  `ColorScheme.fromSeed(dynamic)`.
- The only "dynamic" axis Qalam honors is **light/dark theme** (§21–§22) and the user's **reading-size**
  preference — both Qalam-controlled, not OS-palette-derived.
- If a future product decision ever wants an optional dynamic-color mode, it would be an explicit,
  opt-in setting layered on top — never the default, and never on reading surfaces. Not in scope for
  M1–M10.

---

## 7. Spacing System

4px base scale; `--q-space-N = N × 4px`. Off-scale values are banned — "if a design needs 20px, the
design is wrong."

| Token | px | Typical mobile use |
| --- | --- | --- |
| `--q-space-1` | 4 | icon-to-count gap, chip inner gap |
| `--q-space-2` | 8 | inside compact controls, chip gaps |
| `--q-space-3` | 12 | input padding, card meta rows |
| `--q-space-4` | 16 | **mobile page gutter**, compact card padding |
| `--q-space-5` | 24 | default card padding, sheet padding |
| `--q-space-6` | 32 | **section gaps (mobile)**, form-group spacing |
| `--q-space-7` | 48 | large section gaps |
| `--q-space-8` | 64 | reading top margin, breathing room |
| `--q-space-9` | 96 | onboarding/hero rhythm only |

Rules: **mobile gutter = 16px** (`--q-space-4`); **minimum 32px between major sections** on phone
(48px on tablet). Use `EdgeInsetsDirectional` (start/end), never left/right, so spacing mirrors in RTL.
The allowlist of steps is the table above; a value not on the scale does not exist.

---

## 8. Elevation Scale

Elevation is expressed with **warm drop shadows in light** and **border + surface-step in dark** —
never M3 tonal surface-tint. Three levels; shadow color is the ink `rgba(36,33,27,…)`, never gray.

| Token | Light (shadow) | Dark | Use |
| --- | --- | --- | --- |
| `--q-shadow-1` | `0 1px 2px rgba(36,33,27,.06), 0 1px 3px rgba(36,33,27,.08)` | none + 1px `--q-border` | cards at rest, inputs |
| `--q-shadow-2` | `0 2px 4px rgba(36,33,27,.05/.06), 0 4px 10–12px rgba(36,33,27,.08)` | 1px `--q-border` + surface `--q-bg-raised` | pressed/raised cards, popovers, dropdowns, snackbars |
| `--q-shadow-3` | `0 4px 8px rgba(36,33,27,.06/.08), 0 12–16px 28–32px rgba(36,33,27,.12)` | 1px `--q-border-strong` + `--q-bg-raised` | dialogs, bottom sheets, command surfaces |

**Implementation:** set Material component `elevation: 0` and apply the Qalam shadow via a
`BoxShadow`/`DecoratedBox` wrapper in light; in dark, drop the shadow entirely and express elevation as
a border + one surface step lighter. Never rely on M3's automatic tonal overlay. A dark-mode "elevated"
surface is `--q-bg-surface` on `--q-bg-canvas` with a `--q-border` outline; a higher level steps to
`--q-bg-raised` with `--q-border-strong`.

---

## 9. Border Radius Scale

| Token | px | Applies to |
| --- | --- | --- |
| `--q-radius-control` | 6 | buttons, inputs, chips, tabs, tooltips |
| `--q-radius-card` | 10 | cards, popovers, covers, snackbars, skeleton rects |
| `--q-radius-modal` | 16 | dialogs, bottom sheets (top corners), drawers |
| `--q-radius-full` | 9999 | avatars, dots, pill badges, clap button |

Bottom sheets round only the **top** corners (16px); cards round all four (10px). Use these four
values only — no intermediate radii.

---

## 10. Iconography

- **Icon set: Lucide** (outline, **1.5px stroke**, round joins). Use a Lucide Flutter package; do
  **not** use Material Icons for product iconography. Filled variants only for active toggles (liked
  heart, filled bookmark).
- **Sizes:** 16 (inline with 12–14px text, chip icons), **20 (default** — buttons, inputs, rails), 24
  (bottom tab bar, empty-state icon at 2× inside a 48px circle).
- Icons **inherit `currentColor`** — never carry their own palette; color comes from the text/role
  token around them.
- Icon-beside-text gap = 8px (`--q-space-2`), using directional spacing.
- **RTL flip:** directional icons (`arrow-*`, `chevron-*`, `corner-*`, list-indent, back) mirror in
  RTL. **Never flip:** play/media controls, clocks, checkmarks, undo/redo, the Qalam wordmark, code.
- Icon buttons meet the 44px hit target even when the glyph is 20px (padded).

---

## 11. Component Catalog

The full catalog. On the web, some primitives wrap AntD; on mobile **everything is custom-themed
Material 3** — so the variant / size / state matrices below are what matter, not the base widget. Two
tiers exist: **Q-primitives** (generic) and **product components** (one of each concept). All values
are tokens.

### 11.1 Buttons (`QButton`)

- Anatomy: `[icon?] label [icon?]`, radius 6 (`--q-radius-control`), font `--q-text-sm` (lg:
  `--q-text-base`), weight 500, icon 20.
- **Sizes:** `sm` = 32 tall / 12 inline pad (hit area padded to 44 on touch); `md` = 40 / 16 (default);
  `lg` = 48 / 24 (auth CTAs, publish primary, mobile primary CTAs).
- **Variants:**
  - **primary** — bg `--q-accent`, text `--q-accent-contrast`; pressed `--q-accent-active`. One per
    screen.
  - **secondary** (default) — transparent bg, 1px `--q-border-strong`, text `--q-text-primary`; pressed
    fill `--q-bg-raised`.
  - **ghost** — text `--q-text-secondary`, no border; pressed fill `--q-bg-raised`, text primary.
  - **danger** — bg `--q-danger`, text `#FFFFFF` (light) / outline-until-confirm in dark.
- **States:** loading (spinner replaces the leading icon; width locked; disabled; `Semantics(busy)`);
  disabled (50% opacity, no hue shift); pressed (state layer + Qalam pressed color); focus (2px accent
  ring, offset 2). Spinners appear **only** inside buttons — never on content.
- Props: `iconPosition` start/end (logical), `block` (full-width), `size`, `variant`.

### 11.2 Cards (`QCard`, `PieceCard`, `QuoteCard`)

- **QCard** — bg `--q-bg-surface`, 1px `--q-border`, radius 10, `--q-shadow-1`; interactive card raises
  to `--q-shadow-2` on press + `--q-border-strong`. Padding `none | 16 | 24`.
- **PieceCard** — the feed/list unit. Variants: **feed | compact | featured**.
  - *feed:* byline (avatar 32 · pen name · `@username` · relative time) → title `--q-text-xl` reading
    serif, 2-line clamp, **direction per piece** → excerpt `--q-text-base` secondary, 2-line clamp →
    footer: genre chip + language badge · read-time · actions (clap/like/save). Padding 24; the whole
    card is one tap target (opens the reader); action buttons are separate tap targets layered above.
  - *compact:* no excerpt, title `--q-text-lg` — search/profile/response lists.
  - *featured:* adds a 2:1 cover (radius 10 top) — Discover shelves only.
- **QuoteCard** — `--q-accent-subtle` bg, oversized opening-quote glyph in reading serif, quote
  `--q-text-lg` (italic for Latin/Hindi, regular for Urdu), attribution byline.

### 11.3 Inputs (`QInput`, `QTextArea`, `QSelect`, `QSearchField`)

- Anatomy: **static label** (14px/500) above → field → hint | error (12px). Field: bg
  `--q-bg-surface`, 1px `--q-border-strong`, radius 6, inline pad 12, height 40 (`md`) / 48 (`lg`);
  placeholder `--q-text-muted`.
- **No floating labels** (M3 override) — labels are static above the field (RTL + Nastaliq safety).
- **States:** focus → border `--q-accent` + 2px ring; error → border `--q-danger`, `--q-danger-text`
  message + 16px alert icon, `Semantics` invalid + describedby; disabled → bg `--q-bg-raised`, muted
  text.
- User-content fields default to **auto directionality** (`TextDirection` from the text / piece
  language); the caret and alignment follow the content.
- `QTextArea` auto-grows; `showCount` renders "218 / 280" (12px secondary, end-aligned). `QSelect`
  opens a bottom sheet on phones. `QSearchField` has a leading search icon + trailing clear.

### 11.4 Dialogs (`QDialog`)

- Reserved for the **irreversible** (undo covers the rest). Anatomy: scrim `rgba(19,17,16,.55)` →
  panel radius 16, `--q-shadow-3`, padding 24; title `--q-text-lg`/600; actions end-aligned (logical),
  primary last.
- Sizes: `sm` (confirms), `md` (short forms). On phones, a dialog that is more than a short confirm
  renders as a **bottom sheet** instead (§11.5).
- Behavior: focus trap, back/scrim dismiss (disabled for destructive-typed confirms), `scaleIn` motion,
  focus restored to invoker.

### 11.5 Bottom Sheets (`QSheet`)

- The **default** mobile surface for choices, filters, and short forms (replaces desktop center
  dialogs and side sheets). Radius 16 top corners, drag handle, `--q-shadow-3`, padding 24, scrim
  behind.
- **Modal** (blocks, needs a choice) vs **standard/expanding** (drag to expand — e.g. the publish
  sheet, comment composer). Respects safe-area bottom inset and rises above the keyboard.
- `slideUp` motion (opacity + 24px rise, 400ms decelerate). Dismiss via drag-down, back, or scrim tap.

### 11.6 Snackbars / Toasts (`useToast` equivalent)

- Anatomy: surface bg, radius 10, `--q-shadow-2`, 16px semantic icon, 14px message, optional action
  (Undo). Positioned **above the bottom tab bar**, respecting safe area.

| Variant | Icon color | Duration |
| --- | --- | --- |
| neutral ("Saved") | `--q-text-secondary` | 3s |
| success | `--q-success` | 3s |
| danger (rollback) | `--q-danger` | 5s |
| undo | (action carries) | 5s (10s for unpublish); pauses on interaction |

Max ~3 stacked; oldest collapses. Announced via a polite live region. Toasts never carry critical-path
information — they are transient.

### 11.7 Navigation Bar (bottom)

- **Bottom `NavigationBar`**, 56px + safe-area inset, bg `--q-bg-canvas`, 1px `--q-border` top. **Five
  destinations: Feed · Search · Write · Notifications · Profile.**
- The **Write** destination is **visually accented** (`--q-accent` icon) — it is the primary compose
  CTA (Qalam has no separate FAB on phones; see §11.10).
- Active destination: accent icon + label; inactive: `--q-text-secondary`. Notification destination
  shows a count badge capped "9+".
- Selecting a destination switches the shell branch (keeps that tab's stack + scroll); re-tapping the
  active destination scrolls-to-top / pops to root.

### 11.8 Navigation Rail (tablet / landscape)

- On tablet and wide landscape (`≥ lg`, §25), the bottom bar becomes a **`NavigationRail`** on the
  leading edge (start side — mirrors to the right in RTL). Same five destinations, same accent-Write
  treatment. Optionally a two-pane layout (rail + list + detail) on the widest sizes (§25).

### 11.9 Chips / Tags / Badges

- **QTag (chip):** heights 20 (`sm`) / 24 (`md`), radius 6, inline pad 8, 12px text. Colors: neutral
  (`--q-bg-raised` / secondary text), accent (`--q-accent-subtle` / accent text), or a semantic family
  (`-bg` + `-text`). Interactive tags are tappable (link semantics); removable tags add a 16px ✕ with
  its own 44px hit area + label.
- **Language badge:** a neutral QTag showing the native name (`اردو`, `हिन्दी`) bidi-isolated, in the
  UI font.
- **QBadge:** a notification **dot** (8px `--q-accent`) or a **count pill** (16px tall, 10px text,
  radius-full, "9+" cap), positioned logical top-end. A screen-reader label is **required** ("4 unread
  notifications"). No alarm-red badges — indicators use the accent.

### 11.10 FAB

- **Phones: no FAB.** The accented **Write** tab in the bottom bar is the compose CTA — a FAB would
  duplicate it and fight the "one accent / quiet" aesthetic.
- **Tablet / landscape (rail layout):** a single accented compose action may appear as a rail-top
  action or an extended FAB (`--q-accent`, `--q-accent-contrast` label/icon, radius per control/full)
  where the rail doesn't already surface Write prominently. At most one FAB, ever, and only when the
  bottom Write tab isn't present.

### 11.11 Avatars

- Circular (radius-full), sizes **24 / 32 / 48 / 80** (byline sm/md, profile header, large). Fallback:
  initials on `--q-bg-raised` with `--q-text-secondary` when no avatar key. Cover images 2:1. Built via
  `cached_network_image` from a resolved key (§35 of doc 40).

### 11.12 Lists

- Feed/timeline lists: lazy builder lists of `PieceCard`s, 1 column on phone, edge-to-edge cards with
  16px gutters, section spacing 32px. Dividers use `--q-border` hairlines where needed; prefer
  whitespace over rules. Row min-height comfortable for touch; leading avatar 32–48.
- Settings lists: grouped sections with static labels and 48px rows.

### 11.13 Search

- `QSearchField` (11.3) anchored at the top of the Search screen; results grouped by type on the
  landing (grouped preview) and switchable to a per-type infinite list. Recent + trending shown when
  the query is empty. (Full behavior: §34.)

### 11.14 Empty States (`QEmptyState`)

- 48px circle (`--q-bg-raised`) with a 24px Lucide icon in `--q-text-muted` → title `--q-text-lg`/500
  → body `--q-text-base` secondary (≤40ch) → one optional action. Min-height 320, centered. Copy comes
  from a catalog, literary voice (§33).

### 11.15 Loading States & Skeletons (`QSkeleton`)

- Base `--q-bg-raised`; shimmer sweep transparent→`--q-bg-surface`@60%→transparent, ~1.8s, running
  **inline-start → inline-end** (mirrors in RTL); **static under reduced motion**.
- Variants: text (14px lines, last line 60% width), title (25px), avatar (circle 32/48/80), rect (any,
  radius 10). Composites match real min-heights so there is **no reflow** when content arrives
  (`PieceCardSkeleton`, `BylineSkeleton`, `StatTileSkeleton`).
- Skeletons appear within **100ms**. Buttons show an inline spinner, never a skeleton. Spinners exist
  **only** inside buttons.

### 11.16 Error States

- Inline error region (forms), full-screen error (a failed read/list), and the dedicated `/401`,
  `/403`, `/404`, `/offline` screens. Full-screen error = icon + literary title + body + a **Try
  again** action (re-fetch), never a stack trace. (Full behavior: §32.)

### 11.17 Charts (mobile)

- StatTile (metric value + delta ▲/▼), line chart (1px `--q-accent`, 8% area tint), donut (devices),
  bars (top countries). Charts **re-map to the dark ramp** in dark mode (never a color invert). All
  chart colors derive from the neutral + semantic ramps — no ad-hoc palette. Every chart has an
  accessible data table alternative (§38, §20).

### 11.18 Tables (mobile)

- Tables are an **analytics-only** surface and are rare on mobile. Where a table is unavoidable, it
  scrolls horizontally inside its own container (never the page); header 12px/600/secondary on
  `--q-bg-raised`; rows 48px; numeric columns tabular + end-aligned. Prefer **stacked cards** over
  tables on phones wherever possible.

### 11.19 Product components

- **ClapButton** — batched 1–50 (`MAX_CLAPS_PER_USER_PER_PIECE = 50`); one server call **600ms after
  the last tap**; `Semantics(toggled: mine > 0)`; total announced politely after settle; the burst pop
  (scale 1→1.12→1) is the one spring, **disabled under reduced motion**; sizes 40/48 circle, radius-
  full. Haptic light-impact per tap (§19).
- **AuthorByline** — avatar (24/32) + pen name + `@username` (bidi-isolated, always LTR) + relative
  time + read-time; optional trailing slot (Follow / overflow).
- **ReadingProgress** — 2px bar, `--q-accent`, `Semantics` progressbar with value in ~10% steps; fills
  in the piece's reading direction (Urdu fills right→left).
- **EditorToolbar** — docked above the keyboard on mobile; marks bold/italic/underline, align,
  blockquote, lists, footnotes, mentions (@), hashtags (#). Italic disabled in Urdu.

---

## 12. Animation Guidelines

Motion tokens are the web tokens exactly. Implement with Flutter implicit/explicit animations and
route transitions; **no inline duration/curve literals** — read from `QTokens`.

### 12.1 Durations

| Token | Value | Use |
| --- | --- | --- |
| `--q-motion-fast` | 150ms | pressed/selected states, focus, chrome fade-out |
| `--q-motion-base` | 250ms | fade-rise, popovers, tab indicator, snackbar in |
| `--q-motion-slow` | 400ms | dialogs/sheets, page transitions, clap burst |

### 12.2 Easings (cubic-bezier → Flutter `Cubic`)

| Token | Curve | Character |
| --- | --- | --- |
| `--q-ease-standard` | `cubic-bezier(0.2, 0, 0, 1)` | default — quick start, soft landing |
| `--q-ease-out` | `cubic-bezier(0.16, 1, 0.3, 1)` | entrances — decelerating, "settling on paper" |
| `--q-ease-in` | `cubic-bezier(0.3, 0, 1, 1)` | exits only — leave faster than they arrive |

### 12.3 Standard motions (the vocabulary)

| Motion | Spec |
| --- | --- |
| `fadeRise` | opacity 0→1 + 8px rise, 250ms out-ease. Cards mounting, snackbars, save bar, "new pieces" pill. |
| `fade` | opacity only, 150ms. Chrome show/hide, image reveals. |
| `scaleIn` | opacity + scale 0.98→1, 250ms, origin at anchor. Dialogs, popovers. |
| `slideUp` | opacity + 24px rise, 400ms out-ease. Bottom sheets. |
| `clapBurst` | scale 1→1.12→1, 400ms spring. The single spring; off under reduced motion. |

Animate **only opacity and transform** on hot paths — never width/height/layout (jank). Stagger on
first paint only, ≤20–30ms/item. Skeleton shimmer 1.8s. Toast auto-dismiss 3/5/10s.

---

## 13. Motion Principles

- **Motion clarifies, never entertains.** If an animation does not communicate a spatial/state
  relationship, remove it.
- **Entrances decelerate; exits accelerate.** Things settle onto the paper and leave briskly.
- **Pages fade, they don't slide.** A book doesn't slide (see §14).
- **One spring in the whole system:** the clap burst. Everything else is eased tweens.
- **Reduced motion is honored globally** (§20): transform motions degrade to ≤150ms opacity or
  instant; shimmer becomes static; the clap burst becomes a static increment; page transitions become
  an instant/≤150ms fade. Implemented once (a single motion configuration reading
  `MediaQuery.disableAnimations` + the in-app reduced-motion preference), so one switch degrades every
  motion.
- **Never block interaction on animation.** Content is tappable before its entrance finishes.

---

## 14. Page Transitions

- Route transitions are **fade / fade-rise**, not Material shared-axis slides. Configure GoRouter
  routes with a custom transition: exit fade (150ms, in-ease) → enter fade-rise (250ms, out-ease).
- **The reading view** in particular never slides — it fades in, reinforcing "opening a page," not
  "swiping a card."
- The **native back gesture** is preserved (iOS edge-swipe, Android predictive back); the *visual*
  transition on back is a fade, but the gesture itself behaves natively.
- Bottom sheets and dialogs use `slideUp` / `scaleIn` respectively (not page transitions).
- Under reduced motion, transitions collapse to an instant or ≤150ms cross-fade.

---

## 15. Gesture Guidelines

Gestures are additive affordances; every one has a visible tap equivalent (nothing is gesture-only).

- **Tap** — primary action (open, toggle).
- **Long-press** — contextual actions (e.g. copy a quote, open an overflow menu) — always also
  reachable via a visible overflow (`⋯`) control.
- **Vertical drag** — scroll; drag-down dismisses bottom sheets; drag-to-expand on expanding sheets.
- **Horizontal swipe** — swipe actions on list rows (§18) and native back-navigation edge swipe. In
  RTL, swipe directions mirror.
- **Pull-down at top** — refresh (§16).
- **Pinch** — **not** used for reading text size (that is an explicit S/M/L setting, so it is
  predictable and accessible); pinch is reserved for any future image zoom only.
- Gesture targets meet the 44px minimum; swipe thresholds are forgiving; a mis-swipe is always
  cancellable and never destructive without undo.

---

## 16. Pull To Refresh

- Available on all primary lists (feed, discover, notifications, search results, profile pieces).
- Uses a Qalam-styled refresh indicator (accent-colored, respects reduced motion → a simple accent
  progress, no bounce animation).
- Pull-to-refresh **refetches the Live/Content tier** for that surface and reconciles the cursor list
  from page one (the accumulated list is replaced, not appended).
- It never blocks reading existing (cached) content; the refresh happens above the already-rendered
  list.
- On failure, a quiet snackbar (`danger`) with retry; the existing content stays.

---

## 17. Infinite Scrolling

- All timelines use **cursor-based infinite scroll** (feed, search, comments, followers, notifications).
- Prefetch the next page **one screen-height before the end**; append seamlessly.
- The **end-of-list** shows a literary end state ("You've read it all. The rest is unwritten — perhaps
  by you.") when `hasMore == false`, not an empty spinner.
- A page-load failure shows an inline retry row at the list tail (not a full-screen error) so the
  already-loaded items remain.
- A stale cursor (`FEED_INVALID_CURSOR`) silently restarts the list from page one.
- Scroll position is preserved per tab (the shell branch keeps its stack), so returning to a tab lands
  where the user left it.

---

## 18. Swipe Actions

- List rows may expose swipe actions with a visible icon + color, always mirrored by a tap-reachable
  control (overflow menu):
  - **Notifications:** swipe to **archive** (leading, `--q-info`/neutral) and **mark read/delete**
    (trailing, `--q-danger` for delete). Delete is undo-able (5s snackbar).
  - **Drafts:** swipe to **delete** (trailing, `--q-danger`) — with confirm or undo since it is
    destructive.
  - **Bookmarks / reading list:** swipe to **remove** (undo-able).
- Swipe direction is **logical** (mirrors in RTL): "trailing" is right in LTR, left in RTL.
- Threshold and reveal use the standard motion; a partial swipe springs back.
- **Reversible swipes prefer undo; irreversible swipes require confirm** (per the undo-over-confirm
  principle).

---

## 19. Haptic Feedback

Subtle, meaningful haptics — never noisy. Use `HapticFeedback`:

| Event | Haptic |
| --- | --- |
| Clap tap (each tap in a burst) | light impact |
| Toggle like / bookmark / follow | selection click |
| Pull-to-refresh trigger | light impact |
| Bottom sheet snap / swipe-action commit | selection / medium impact |
| Destructive confirm (delete) | medium impact |
| Error (failed action) | (no heavy buzz) — rely on visual + light impact at most |

Rules: haptics accompany a **state change the user caused**, never a passive event; they respect the
OS haptic setting; they are never the *only* feedback (always paired with visual). Keep intensity low —
this is a sanctuary, not a game.

---

## 20. Accessibility Guidelines

Accessibility is non-negotiable (WCAG 2.1 AA), inherited from the web and extended for touch/native.

- **Contrast AA minimum.** The token contrast ratios are pre-verified (text-primary/canvas ~15:1;
  text-secondary ~5.4:1; accent link ~5.6:1; `text-muted` is large-only). Never place small text on a
  failing pairing.
- **Touch targets ≥ 44×44** (Qalam floor; grow small controls with padding).
- **Focus / selection** visible for switch-access and external keyboards: 2px accent ring, offset 2.
- **Semantics** on everything: buttons labeled; toggles report state (`Semantics(toggled/…)`); tabs are
  a tab list; the feed exposes list/busy semantics; progress bars report value; live regions
  (`Semantics(liveRegion)`) announce toasts, autosave status, and clap totals politely.
- **Text scaling:** honor `textScaler` up to large sizes without clipping; test at 1.3×+.
- **Reduced motion:** honor `MediaQuery.disableAnimations` and the in-app override (§13).
- **Per-content language & direction:** every content node carries its `lang` + `dir` (WCAG 3.1.2);
  usernames/URLs/numbers are bidi-isolated so they don't corrupt surrounding RTL text.
- **Never color alone** (WCAG 1.4.1) — always pair with icon/text.
- **Charts** always have an accessible data-table alternative and are not conveyed by color alone.
- **Screen-reader flows** tested (TalkBack / VoiceOver) for the core journeys: auth, feed, reading,
  writing, notifications.

---

## 21. Dark Theme

- **Warm near-black, never pure black.** Canvas `#131110`; surfaces step `#1C1917` → `#26221E`.
- Reading text is **warm ivory `#ECE6DA`** (~15:1) — deliberately not pure white, to reduce halation on
  serif text.
- **Elevation = border + surface step**, not shadow (M3 tonal overlay suppressed). A "raised" surface
  is a lighter surface + a border, never a heavier shadow.
- **Accent shifts lighter** to `#D07349`; buttons use **ink-on-accent** (`--q-accent-contrast` =
  `#131110`), because white-on-accent fails contrast in dark.
- Cover/hero images render at ~0.92 brightness (removed on focus). User content is never inverted;
  charts re-map to the dark ramp, never CSS/color invert.
- Switching is instant via the theme mode (§22); there is no flash because the token maps swap
  wholesale.

---

## 22. Light Theme

- **Warm paper.** Canvas `#FAF7F1`; surface `#FFFFFF`; raised `#F3EEE5`; ink `#24211B`.
- **Elevation = warm drop shadows** (§8), tinted with the ink color, never gray-black.
- Accent terracotta `#9E4B28`; accent buttons take white text (`--q-accent-contrast` = `#FFFFFF`).
- Light is the default posture: calm, warm, high-contrast, generous whitespace.

**Theme mode:** a persisted `ThemeMode` (System / Light / Dark) drives `MaterialApp.themeMode`; the
default is **System**. The choice is stored in `prefs` (device pref) and, when the user is signed in,
synced to the server `theme_preference` for cross-device consistency — but the **client drives
rendering** (the server value is a synced preference, not the render authority). The Appearance
settings screen (§29) presents System/Light/Dark as radio cards with mini previews, plus reading-size
S/M/L and a reduced-motion override ("Follow system" default).

---

## 23. Adaptive Layout Rules

Breakpoints reuse the standard scale (matching the web — "no custom breakpoints, ever"):

| Name | Min-width | Behavior |
| --- | --- | --- |
| base | 0 | phone: bottom tab bar, single column, 16px gutters, ≥44px targets |
| `sm` | 640 | wider gutters (24px); bottom sheets still used for choices |
| `md` | 768 | tablet portrait: reading rail / two-column lists begin |
| `lg` | 1024 | tablet landscape / large: NavigationRail replaces bottom bar; master-detail two-pane |
| `xl` | 1280 | content max-width reached; whitespace grows, columns do not |

Rules: **max two columns, ever.** Content max width ~1280 — beyond it, whitespace grows, columns don't.
Layout responds to width (`LayoutBuilder` / `MediaQuery`), and to orientation (§26). The reading column
is always capped to the ~68ch measure regardless of available width.

---

## 24. Phone Layouts

- **Navigation:** bottom `NavigationBar`, 5 destinations (§11.7), 56px + safe-area inset. Full-screen
  flows (editor, reader, auth, settings sub-pages) hide the bottom bar.
- **Gutters:** 16px; cards edge-to-edge; **32px** between major sections.
- **Feed:** single column, swipeable/scrollable tab strip, pull-to-refresh, infinite scroll.
- **Reading:** full-bleed column with 16px inline padding, per-script font/size/direction, chrome
  recede, a bottom action bar (clap/save/share) within thumb reach.
- **Editor:** minimal top chrome (back · save status · Preview · Publish); toolbar docked above the
  keyboard; a single forward action.
- **Sheets over dialogs:** choices/forms/filters rise as bottom sheets.
- **Targets ≥44px**, one primary action per screen.

---

## 25. Tablet Layouts

- At **`≥ lg`** (and `md` where it helps), the bottom bar becomes a **`NavigationRail`** on the leading
  edge (mirrors to trailing in RTL), same 5 destinations, accent-Write.
- **Master-detail two-pane** where it fits: e.g. feed/search list on the start side, reading view on
  the end side; notifications list + detail; drafts list + editor. Never more than two panes.
- The **reading column stays capped at the ~68ch measure** and is centered in its pane with generous
  side whitespace — a tablet does not stretch prose to full width.
- Dialogs may render as centered dialogs (not bottom sheets) at `≥ sm`, matching the web's "dialogs
  stop being bottom sheets" rule — but bottom sheets remain acceptable and often preferable on tablets
  held in portrait.
- Larger paddings (24–48px), larger avatars/covers, but the same tokens and the same two-posture
  design.

---

## 26. Landscape Rules

- Landscape is treated as a **wider viewport**, not a different design: the breakpoint/width logic
  applies, so a phone in landscape that crosses `md`/`lg` may adopt the rail / two-pane layout.
- **Reading in landscape:** the column stays capped to the measure and centered; extra width becomes
  margin, not longer lines. Chrome-recede still applies.
- **Editor in landscape:** the toolbar remains docked above the keyboard; the composing area uses the
  available width but the text column respects the measure.
- Media/covers keep their aspect ratios; no letterboxing of user content beyond the intended crop.
- Avoid layouts that only work in one orientation; every screen is usable in both. Respect safe areas
  in both (notch/cutout on the side in landscape — §27).

---

## 27. Safe Area Rules

- All screens respect `SafeArea` / `MediaQuery.padding` — status bar, notch/cutout, home indicator,
  and the on-screen navigation gesture area.
- The **bottom tab bar** adds the bottom safe-area inset to its 56px height; **bottom sheets** and the
  **reading action bar** sit above the home indicator.
- **Snackbars** float above the bottom tab bar *and* the safe-area inset.
- In **landscape**, side notches/cutouts are respected with directional insets (so RTL mirrors
  correctly).
- The **keyboard** inset is handled per §28 (content lifts above it; sheets rise above it).
- Full-bleed images may extend under the status bar only where intended (immersive reading cover), with
  legibility preserved (scrim/contrast).

---

## 28. Keyboard Handling

- Content **avoids the keyboard**: scrollable forms lift the focused field above the keyboard; bottom
  sheets and composers rise above it (`viewInsets`-aware); the editor keeps the toolbar docked directly
  above the keyboard.
- **No content is ever obscured** by the keyboard; the focused field is always visible with a comfort
  margin.
- **Return-key semantics** are set per field (next / done / search); tapping outside dismisses the
  keyboard where appropriate; a scroll gesture dismisses it in long forms.
- **Autocorrect / capitalization / input type** match the field (email = email keyboard, no
  autocapitalize/autocorrect; username = no autocorrect; body = sentence case).
- In the **editor**, the toolbar tracks the keyboard so formatting is always one tap away; on keyboard
  dismiss the toolbar can float on selection.
- RTL text entry uses the correct keyboard direction; mixed-script input is bidi-isolated so caret
  behavior stays sane.

---

## 29. Form UX

Mirrors the web form discipline (`docs/33`), translated to native inputs.

- **Static labels** (no floating), inline hint/error below the field.
- **Validate on blur first, then on change after the first error** (calm, not naggy) — the "onTouched"
  equivalent. Never validate on every keystroke from the start; never only on submit.
- **Validation rules come from shared limits** (`qalam_shared`): password 10–128; username
  `^[a-z0-9_]{3,30}$`; pen name 1–50; bio ≤500; title ≤200; subtitle ≤300; featured quote validated at
  280; ≤5 tags; comment 1–2000. Client validation is UX; the server is authoritative.
- **Server errors map to fields** by `error.code` + `details[].field` (dot/bracket paths →
  `profile.penName`); a code-only error becomes a form-level banner. Copy is from the error catalog,
  never the raw server message.
- **Submit** is a pending mutation: the button shows a loading state (`Semantics(busy)`), never a
  spinner on the form body; the form is disabled while submitting. **Publish/schedule/delete carry
  pending state (never optimistic)**; publish sends a per-intent idempotency key.
- **Register wizard** is one logical form across steps; the final step submits once, atomically; the
  username step has the one deliberate confirmation (it is permanent — never offer an edit path).
- **Focus the first invalid field** on failed submit; announce errors via a polite live region.
- User-content fields default to auto directionality; `showCount` on length-limited text areas.

---

## 30. Offline UX

Reflects the architecture stance (doc 40 §23): **cached reads work offline; writes require
connectivity; there is no offline authoring in Phase 1.**

- **Cached content is readable offline**, clearly marked as possibly stale (a subtle "offline —
  showing saved content" banner, §31).
- **Write actions offline** (publish, follow, clap, comment, edit) are **disabled or fail fast** with
  an honest "You're offline" message — never a fake success, never a silent queue.
- **Drafts** are server-backed; offline, the editor shows its save status as "offline — will save when
  connected" (the draft's *local edits are not persisted* in Phase 1, so the user is warned before
  leaving with unsynced changes).
- A cold start with **no cache** and no connection lands on the `/offline` screen (literary copy + a
  retry).
- The offline experience degrades **gracefully and honestly** — the sanctuary stays calm even without
  a network.

---

## 31. Connectivity UX

- A **persistent, unobtrusive offline banner** (top or bottom, `--q-warning-bg`/`-text` or neutral)
  appears while offline; it does not block content and disappears on reconnect.
- **On reconnect:** a brief neutral confirmation may appear; Live-tier surfaces (feed, notifications,
  unread count) refetch automatically; failed reads on the current screen retry.
- **Transient network errors** (a single failed request while nominally online) surface as a quiet
  retry affordance on that surface, not a global banner.
- Connectivity state is **honest** — "offline" reflects real reachability where possible (a captive
  portal / unreachable server is treated as effectively offline once a transport failure confirms it).
- Destructive/irreversible actions are **suppressed** while offline (you can't publish offline), so the
  user is never in a state where an action appears available but cannot succeed.

---

## 32. Error UX

- **Errors are honest and literary**, never a raw exception. Copy is keyed by error type/code (§21 of
  doc 40), calm and non-blaming.
- **Field errors** land inline on forms; **code-only errors** become a form banner; **read/list errors**
  become a full error state with **Try again**.
- **404 / private content:** shown as "not found" with exits (search, trending), never "forbidden" —
  existence is not leaked (private pieces return 404).
- **Rate limited (429):** a quiet "slow down" message; the action re-enables after the window; no
  aggressive auto-retry.
- **Session expired:** silent refresh where possible; if it truly fails, a calm redirect to login with
  a "your session ended" note and a returnTo back to where the user was.
- **Support affordance:** a full-screen error offers a "details" disclosure showing the `requestId`
  (for support correlation), never a stack trace.
- Errors never use alarm-red gratuitously; `--q-danger` is used with an icon and text, following the
  never-color-alone rule.

---

## 33. Empty State UX

- Every list/collection has a **`QEmptyState`** (§11.14): calm icon, literary title (≤8 words), warm
  body (≤20 words), at most one action. Copy comes from a **catalog**, never invented per screen, and
  **never blames the user** or uses exclamation marks.
- Sample catalog copy (inherited):
  - Following feed empty: *"Your feed is a blank page."* / *"Follow writers and their words will find
    you here."*
  - Drafts empty: *"Nothing here yet — that's how every book starts."*
  - End of feed: *"You've read it all. The rest is unwritten — perhaps by you."*
  - No search results: a calm "nothing matched" with a suggestion to broaden.
- **Empty ≠ misleading zeros.** Profile counters that are placeholders (not-yet-computed metrics) are
  hidden or labeled, never shown as a real "0" (mirrors the web rule). Only real counts render.
- Empty states offer an **exit or an action** (follow writers, start a draft, adjust filters) — a dead
  end always offers a door.

---

## 34. Search UX

- **Search screen** with a top `QSearchField` (leading icon, trailing clear). Query state is the source
  of truth (mirrors the web URL-state discipline): scope (`type` = all/pieces/writers/tags/genres/
  languages), filters (language, genre, tag, sort), all reflected in navigable state.
- **Empty query:** show **recent searches** (server + local) and **trending** — a starting point, not a
  blank screen. Recent items are removable.
- **As-you-type autocomplete** (debounced; min query length 2 → shorter shows a hint, not an error;
  server may return `SEARCH_QUERY_TOO_SHORT`), capped at 10 suggestions per group.
- **Submit / scope:** grouped preview (top results per type) on the landing; selecting a type opens a
  per-type **infinite** result list with filters + sort.
- **Result cards** use `PieceCard compact` / writer / tag rows; snippets carry the correct per-content
  direction and language.
- **Degraded search** (`SEARCH_UNAVAILABLE`, 503): a calm "search is catching its breath" state with
  retry/backoff, not an error dump.

---

## 35. Reading Experience UX

The reading surface is where "the interface disappears." This is the most carefully-designed screen.

- **The prose is the hero.** Reading serif at the reading size (S/M/L), reading line-heights
  (1.7 Latin / 1.8 Devanagari / **2.1 Nastaliq**), column capped to ~68ch, generous top margin. No
  chrome out-weighs the text.
- **Per-script, per-direction rendering.** The piece's language sets the font family (Lora / Noto Serif
  Devanagari / **Noto Nastaliq Urdu**) and direction (Urdu RTL); Nastaliq gets its non-negotiable
  accommodations (line-height ≥2, larger base, no italic, letter-spacing 0, +4px on clamped lines).
- **Chrome recedes.** The top bar and any rail fade after a short downward scroll; restored quickly on
  upward scroll or an edge tap.
- **Reading progress** bar (2px accent) fills in the reading direction (right→left for Urdu).
- **Footnotes** render inline-referenced with a tap-to-reveal popover/sheet; mentions and hashtags are
  tappable, bidi-isolated.
- **Bottom action bar** within thumb reach: clap (batched burst + haptic), bookmark, share; quiet
  counts.
- **Content is rendered from TipTap JSON to native widgets** (whitelisted nodes/marks) — **never a
  WebView**, never HTML. Rendering is safe by construction (mirrors the server whitelist).
- **Reading analytics** (view + read-completion) beacon quietly in the background (dwell ≥30s AND
  ≥50% scroll = a completed read), never interrupting.
- **Reading settings** (size S/M/L, theme) are reachable without leaving the flow; changes apply live.

---

## 36. Writing Experience UX

The editor honors "never make the writer wait" and "writing is the hero."

- **Minimal chrome:** back · ambient save status · Preview · Publish. No bottom tab bar. The canvas is
  the reading serif at the editor title/body sizes, in the piece's language/direction.
- **Ambient autosave:** debounced (~2s) writes to the server; the save-status indicator reads
  saved / saving / offline; a conflict (`PIECE_STALE_WRITE`) shows a calm conflict banner, never a
  silent overwrite. The user is warned before leaving with unsaved changes.
- **Toolbar docked above the keyboard:** bold / italic / underline (italic **disabled in Urdu** —
  emphasis via color/quote), alignment, blockquote, ordered/unordered lists, footnotes, mentions (@),
  hashtags (#). The toolbar tracks the keyboard; floats on selection when the keyboard is down.
- **One language per piece** — chosen at creation, drives direction + reading font; not switchable
  mid-piece.
- **Publish is a deliberate, non-optimistic flow:** a publish **bottom sheet** collects title, subtitle,
  cover, featured quote, tags (≤5), genre, language, visibility, and optional scheduled time; publish
  carries a per-intent idempotency key; the server mints slug/status. Completeness is validated before
  the call (`PIECE_INCOMPLETE` guarded client-side for UX).
- **Cover upload** shows progress; images are downscaled/validated client-side (JPEG/PNG/WebP, ≤10MB).
- **Focus mode** hides all non-essential chrome for distraction-free writing.
- **Word count / reading time** update quietly as ambient meta, not a scoreboard.

---

## 37. Notification UX

- **In-app only in Phase 1**, delivered by polling (doc 40 §32); push is a Phase-2 seam.
- **Inbox** at the Notifications tab: infinite list, filterable by status (unread/read/archived) and
  type; grouped by day; each row shows the actor avatar, a literary summary built from the notification
  `type` + denormalized `data`, and a relative time. Tapping deep-links to the target (piece/profile/
  comment).
- **Unread badge** on the tab: a count pill capped "9+" (accent, never alarm-red); a bare dot on
  denser surfaces. Screen-reader label required ("4 unread notifications").
- **Actions:** mark read / read-all / archive / delete — via swipe (§18) and an overflow, optimistic
  (badge zeroes instantly) with rollback on failure.
- **Preferences** (`/settings/notifications`): per-type toggles; when push lands (Phase 2), channel
  toggles appear here.
- **Quiet numbers:** notifications inform, they don't nag; no aggressive badges, no sounds beyond the
  OS default, calm copy.

---

## 38. Analytics UX

The writer analytics surface (`/me/stats`) — Ravi's honest-metrics need.

- **Calm, honest dashboard:** stat tiles (views, reads, reading-time, completion rate, claps, shares,
  followers gained) with a small delta (▲/▼); a line chart for growth (period selectable); a donut for
  devices; bars for top countries — all in the neutral + semantic ramps, **re-mapped for dark**, never
  color-inverted.
- **Per-piece analytics** (`/me/stats/pieces/:id`): the same metrics scoped to one piece.
- **Metrics inform, never gamify** — small, secondary-weight numbers; no leaderboards, no red urgency.
- **Accessibility:** every chart has a **screen-reader data table** alternative; values are not
  conveyed by color alone; tabular figures for alignment.
- **Honest gaps:** where the backend has no data (some geo/device breakdowns can be empty), the UI
  shows a calm "not enough data yet" state — never fabricated numbers, never misleading zeros.
- **Export** (where available) offers the data as CSV/JSON via the platform share sheet; a print/summary
  view is a nice-to-have.
- **Growth series is often sparse early** — the chart handles empty/short series gracefully.

---

## 39. Admin-only Components

**Not applicable to Qalam Mobile.** The mobile app is the **reader/writer surface only**. All
admin/moderation functionality lives on the web `admin.qalam.*` app (AntD, offset pagination, RBAC on
every `/admin/*` route). Mobile:

- Renders **no** admin dashboards, moderation queues, user-management, settings, or audit surfaces.
- Never calls `/admin/*` endpoints.
- Gates any moderator/admin *affordance* (were one ever added) purely as a role-based UX hint with the
  server authoritative (doc 40 §11.4) — but Phase 1 mobile builds none.

The only moderation-adjacent surface a normal user touches is **reporting content** (`POST /reports`,
`POST /reports/:id/appeal`) — a simple, literary report bottom sheet available from a piece/comment
overflow menu. That is a *user* action, not an admin component.

If a future phase ever brings a lightweight moderator mobile experience, it would be a **separate,
flag-gated feature module** with its own design pass — explicitly out of scope for M1–M10.

---

## 40. Mobile QA Checklist

A screen/feature is design-complete only when all boxes are checked:

**Tokens & theming**
- [ ] No raw colors / sizes / radii / durations — every value is a token (`QTokens`/ColorScheme).
- [ ] Renders correctly in **light and dark**; dark uses border+surface elevation (no tonal overlay);
      accent buttons use ink-on-accent in dark.
- [ ] Dynamic color is off; the Qalam palette is used.

**Typography & i18n**
- [ ] Correct type scale + weights; chrome uses `--q-font-ui`, reading uses the per-script reading
      font.
- [ ] **RTL verified** (Urdu): directional insets/alignment mirror; directional icons flip, non-
      directional don't; usernames/URLs/numbers bidi-isolated.
- [ ] **Nastaliq verified**: line-height ≥2.0/2.1, larger base size, no italic, letter-spacing 0,
      +4px on clamped lines; golden test passes.
- [ ] Devanagari (Hindi) renders with correct font + 1.8 leading.
- [ ] Text scales to 1.3×+ without clipping.

**Layout & adaptivity**
- [ ] Phone (base), tablet (`md`/`lg`), and **landscape** layouts all correct; ≤2 columns; reading
      column capped to the measure.
- [ ] Safe areas respected (status bar, notch, home indicator, side cutouts in landscape).
- [ ] Keyboard never obscures the focused field; sheets/toolbar rise above the keyboard.

**Components & states**
- [ ] Uses catalog components with correct variants/sizes/states.
- [ ] **Loading** = skeletons within 100ms (spinners only in buttons); **empty** = literary
      `QEmptyState` from the catalog; **error** = honest state with retry; **offline** = cached read +
      banner.
- [ ] One primary (accent) action per screen; bottom sheets used for choices on phones.

**Motion & gesture**
- [ ] Motion uses the token durations/curves; pages fade (no slide); only opacity/transform animated.
- [ ] **Reduced motion** honored (transforms → opacity/instant; shimmer static; clap static).
- [ ] Every swipe/gesture has a visible tap equivalent; swipe directions mirror in RTL; destructive
      swipes use undo/confirm.
- [ ] Haptics are subtle, paired with visuals, respect the OS setting.

**Accessibility**
- [ ] AA contrast on all text; `text-muted` only at large sizes.
- [ ] ≥44px touch targets; visible focus; full semantics (labels, toggle state, live regions,
      progressbar); charts have data-table alternatives.
- [ ] Screen-reader pass on the core flows (auth, feed, reading, writing, notifications).

**Voice & honesty**
- [ ] Copy is literary, calm, non-blaming, no exclamation marks; from the catalog where one exists.
- [ ] Quiet numbers; no alarm-red badges; no misleading zeros; no fabricated data.

---

*End of `41_MobileDesignSystem.md`. Companion: `40_MobileArchitecture.md`. Do not begin M1
implementation until both documents are approved.*
