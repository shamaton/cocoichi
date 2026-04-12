# CoCo Ichibanya PoC Design System

This `DESIGN.md` is the AI-facing visual system for the new CoCo Ichibanya mobile app PoC.
It is a derived guide, not the primary source of truth.
Derived from:

- `docs/poc-app-direction-2026-03-28.md`
- `docs/poc-screen-flow-2026-03-28.md`
- `docs/poc-home-tab-architecture-2026-04-12.md`
- `docs/poc-wireframes-s1-store-select-2026-04-12.md`
- `docs/poc-wireframes-home-tabs-2026-04-12.md`
- `docs/poc-wireframes-s2-s3-2026-03-28.md`
- `docs/poc-wireframes-s5-s6-2026-03-28.md`
- `docs/poc-wireframes-s8-2026-03-28.md`
- `docs/poc-visual-toneboard-2026-03-28.md`
- `docs/poc-design-tokens-2026-03-28.md`

Last synced with those docs: `2026-04-12`

If this file conflicts with the PoC docs, follow this order:

1. `docs/poc-app-direction-2026-03-28.md`
2. `docs/poc-screen-flow-2026-03-28.md`
3. `docs/poc-home-tab-architecture-2026-04-12.md`
4. `docs/poc-wireframes-s1-store-select-2026-04-12.md`
5. `docs/poc-wireframes-home-tabs-2026-04-12.md`
6. `docs/poc-wireframes-s2-s3-2026-03-28.md`
7. `docs/poc-wireframes-s5-s6-2026-03-28.md`
8. `docs/poc-wireframes-s8-2026-03-28.md`
9. `docs/poc-visual-toneboard-2026-03-28.md`
10. `docs/poc-design-tokens-2026-03-28.md`
11. `DESIGN.md`

## 1. Visual Theme & Atmosphere

Design for a warm, layered, native iPhone ordering experience.
The app should feel like choosing tonight's curry, not filling out a checkout form.

The visual direction is:

- Warm, not cold
- Crisp, not ornamental
- Layered, not flat
- Playful, not childish
- Appetizing, not promotional
- Native, not web-like

This PoC is not:

- A coupon-first app
- A futuristic glass demo
- A dark premium dashboard
- A generic card-grid website inside a phone shell

Base the mood on soft ivory surfaces, curry-brown primary actions, food-led imagery, and restrained material effects.
Adopt modern iOS behaviors and motion, but do not drift into purple-heavy, metallic, or sci-fi aesthetics.

## 2. Color Palette & Roles

Implementation note:

- Treat the foundation values in this file as reference guidance for prompts and visual alignment.
- In product code, prefer semantic tokens first and avoid leaking raw foundation values directly into screen implementations when a semantic token exists.

### Core Surfaces

- `color.bg.base` `#F6F1E7`
  Use for the main app background.
- `color.bg.elevated` `#FFF9F0`
  Use for standard cards and grouped surfaces.
- `color.bg.elevatedStrong` `#FFF4E4`
  Use for emphasis cards, summary blocks, and warmer grouped surfaces.
- `color.bg.glassTint` `rgba(255, 248, 235, 0.72)`
  Use only with subtle material for overlays and suggestion surfaces.
- `color.bg.cream` `#F2D7A6`
  Use for soft highlight backgrounds and suggestion accents.

### Text

- `color.text.primary` `#2E221B`
  Main body text and strong labels.
- `color.text.secondary` `#6A5648`
  Supporting descriptions and metadata.
- `color.text.tertiary` `#8C7869`
  Low-emphasis helper text and mock notes.
- `color.text.inverse` `#FFF8EF`
  Text on dark curry-colored actions.

### Accent

- `color.accent.curry` `#8B4A1F`
  Primary CTA, emphasized price, selected key action.
- `color.accent.cheese` `#E5B94E`
  Selected chips, highlights, friendly attention.
- `color.accent.green` `#5E7D3B`
  Topping-related support, applied state, success-adjacent accents.
- `color.accent.red` `#B84E2F`
  Spice level emphasis, warnings, heat-related accents.
- `color.accent.cream` `#F2D7A6`
  Soft secondary highlight.

### Borders & Lines

- `color.line.soft` `rgba(84, 58, 39, 0.10)`
  Light separators.
- `color.line.medium` `rgba(84, 58, 39, 0.18)`
  Chips, fields, card edges.
- `color.line.strong` `rgba(84, 58, 39, 0.28)`
  Selected or focused boundaries when needed.

### Status

- `color.status.success` `#4E7A45`
  Applied coupon, saved state, completion confirmation.
- `color.status.info` `#6B7C93`
  Mock-state notes and calm utility information.
- `color.status.warning` `#B8752C`
  Confirmation-needed states.

### Color Rules

- Primary actions should almost always use curry brown, not blue or purple.
- Price emphasis should stay visually consistent across screens.
- Greens are supportive accents, not the brand center.
- Large dark surfaces are allowed only as short contrast moments, never as the whole app language.

## 3. Typography Rules

### Font Family

Prefer native iPhone typography behavior over custom brand typography.
The app should feel native on iPhone.
Do not introduce decorative or highly stylized font choices in this PoC unless the canonical docs are updated to require them.

### Hierarchy

| Role | Suggested Style | Weight | Use |
| --- | --- | --- | --- |
| Hero | `largeTitle` | `bold` | Product name, order complete headline |
| Section Title | `title3` | `semibold` | Section headers |
| Card Title | `headline` | `semibold` | Menu card titles, pickup card labels |
| Body | `body` | `regular` | Main descriptions |
| Meta | `subheadline` | `regular` | Supporting copy, helper text |
| Caption | `caption` | `medium` | Chips, micro labels, mock notes |
| CTA | `headline` | `semibold` | Button labels |
| Price | `title3` | `bold` | Main price emphasis |
| Total | `title2` | `bold` | Order total |

### Typography Principles

- Titles should feel compact and confident, but never severe.
- Japanese copy must remain highly readable. Avoid aggressive negative tracking.
- Prices, pickup time, and quantity values must read faster than descriptive copy.
- Use weight contrast more than font-family contrast.
- Keep button labels short and direct.

### Copy Tone

- Warm and clear
- Direct, not salesy
- Reassuring near completion
- No login pressure
- No coupon hype language that overpowers ordering

Good examples:

- `今日は何にする？`
- `ご注文を受け付けました`
- `この注文に使えるクーポンがあります`

Avoid:

- Overly promotional coupon banners
- Technical ordering jargon
- Long explanatory microcopy in core flows

## 4. Component Stylings

### Primary CTA

- Background: `color.accent.curry`
- Foreground: `color.text.inverse`
- Radius: `22px`
- Shape: broad rounded rectangle, not a capsule-only pill
- Placement: usually bottom-fixed in key flow screens
- Motion: slight soft press-in on tap

Use for:

- `Review Order`
- `Place Order`
- `Browse Menu Again`

When a screen has a primary CTA, keep its styling visually consistent across the order flow.

### Secondary CTA

- Background: `color.bg.elevated`
- Foreground: `color.text.primary`
- Border: `1px solid color.line.medium`
- Radius: `22px`

Use for:

- `Save Combo`
- `View Saved Combos`
- `Change Store`

### Search Field

- Surface: elevated light card
- Radius: `14px`
- Border: soft line
- Tone: quiet and native, never neon or chrome-heavy
- Use SF Symbols for search and filter affordances

### Chips

- Default: light surface with subtle border
- Selected: filled with `color.accent.cheese`
- Spicy selected: filled with `color.accent.red` and inverse text
- Interaction: quick selection haptic feel, small visual compression on tap

Use chips for:

- Quick filters
- Spice level
- Category selection
- Small option toggles

### Cards

#### Standard Card

- Background: `color.bg.elevated`
- Radius: `20px`
- Shadow: broad and light
- Border: optional soft line only when needed

Use for:

- Menu rows
- Pickup info
- Order summaries
- Saved combo preview

#### Emphasis Card

- Background: `color.bg.elevatedStrong`
- Radius: `20px` to `28px`
- Use for:
  - `For You`
  - price summary groupings
  - order snapshot

#### Glass Card

- Background: `color.bg.glassTint` with a restrained material treatment
- Use only for:
  - coupon suggestion layers
  - floating summary overlays
  - temporary feedback surfaces

Glass should organize depth, not show off transparency.

### Image Treatment

- Prefer warm, appetizing food photography
- Use slightly angled food images rather than flat top-down catalog shots
- Show texture: curry gloss, crispy cutlet, melted cheese, green topping contrast
- Avoid dark moody food photography
- Avoid sterile packshot-style isolation unless used intentionally in a hero crop

### Navigation & Header

- Use native iOS navigation patterns first
- Keep store context always visible in the ordering flow
- Header surfaces can use light material, but clarity beats effect
- A user should always know:
  - which store they are ordering from
  - what they are building
  - how much it costs
  - what happens next

### Bottom Action Area

- Persistent on key screens
- Safe-area aware
- Slightly elevated from the background
- Can use a milky material or solid elevated fill
- Must feel easy to reach with one hand

### Coupon Sheet

- Bottom sheet, not a separate full flow
- Prioritize applicable coupons first
- Inapplicable coupons may be hidden or shown in a disabled reference state until the canonical PoC docs settle that behavior
- Keep selection fast
- Avoid making the sheet louder than the order confirmation beneath it

### Success State

- Success mark should be centered, clear, and brief
- Pair visual success with a single success haptic
- Transition from emotional success moment to readable pickup info within about one second
- Avoid confetti, particles, or game-like celebration

## 5. Layout Principles

### Screen Structure

Prioritize one-handed iPhone use.
Main screens should generally follow this rhythm:

1. Context
2. Main choice or confirmation content
3. Price and state visibility
4. Bottom action area

### Spacing Scale

Use an 8pt grid with 4pt support steps.

- `4`
- `8`
- `12`
- `16`
- `20`
- `24`
- `32`

### Radius Scale

- Small chip: `10`
- Field and small card: `14`
- Standard card: `20`
- Large surface: `28`
- CTA: `22`
- Sheet: `28`

### Layout Rules

- Prefer vertical flow over dense side-by-side packing on iPhone.
- Group related choices in visually calm blocks.
- Keep current price visible at all times during customization.
- Use sections to reduce cognitive load, not to create extra scrolling decoration.
- Do not let coupon information sit above the main ordering decision.
- Menu discovery should feel exploratory, but order review should feel compressed and decisive.

### Screen-Specific Emphasis

#### S2 Menu Discovery

- Lead with store context and search
- If the selected store has store-only items, surface them as a short discovery section or badge, not as a separate destination
- Make discovery feel inviting and edible
- Use larger imagery for recommended and popular items
- Keep `Saved Combos` accessible without hijacking the page

#### S3 Curry Detail / Customize

- Hero image and current total should anchor the screen
- Clearly separate `Basic Settings` and `Toppings`
- Order snapshot should update immediately with user choices
- If the item is store-only, keep that context visible with a short supporting badge or label
- Save and review actions should never feel hidden

#### S5 Order Review

- Keep pickup information and pending draft easy to scan
- `Place Order` must dominate the footer
- If the order includes a store-only item, preserve that information as supporting context inside the order card
- Coupon entry should feel like a helpful savings suggestion, not a detour

#### S6 Coupon Suggestion Sheet

- Present applicable options first
- If non-applicable options are shown, keep them disabled and clearly secondary
- Show expected savings clearly
- Make it easy to apply or skip without friction

#### S8 Order Complete

- Start with success and pickup facts
- Then show a compact order summary
- Do not carry store-only discovery labels into the completion screen
- Main next action is to browse again, not manage account settings

## 6. Depth & Elevation

Depth should come from surface contrast, spacing, and restrained shadow before it comes from dramatic blur.

### Elevation Levels

| Level | Treatment | Use |
| --- | --- | --- |
| Base | Flat warm background | Main screen canvas |
| Card | Light shadow, elevated surface | Menu cards, summaries |
| Lifted | Slightly stronger shadow and warmer fill | For You, order snapshot, price summary |
| Glass | Tinted material, limited blur | Coupon sheet, floating transient UI |
| Success Focus | Contrast plus motion, not extra shadow | Completion state |

### Shadow Rules

- Use broad, soft shadows
- Keep opacity low
- Avoid stacked shadow recipes
- Prefer separation by fill and spacing over heavy elevation

Suggested shadows:

- `shadow.card.soft`: `0 8 24 rgba(32, 18, 10, 0.08)`
- `shadow.card.lifted`: `0 12 32 rgba(32, 18, 10, 0.10)`
- `shadow.sheet`: `0 -8 24 rgba(32, 18, 10, 0.10)`

### Material Rules

- Use `.thinMaterial`-like treatment for light floating cards only when content remains highly legible
- Use `.regularMaterial`-like treatment for the coupon sheet if needed
- Add warm tint when using material so it fits the food palette
- Never use fully transparent floating chrome over food imagery

## 7. Motion & Feedback

Motion should make the order feel alive and understandable.
It should never slow the user down.

### Timing

- Fast tap response: `0.18s`
- Standard state change: `0.28s`
- Emphasis transition: `0.42s`
- Success transition: `0.65s`

### Motion Patterns

- Product card to detail: smooth native push or hero-like continuity
- Topping add: order snapshot and total update together
- Coupon apply: sheet settles as price updates
- Order complete: short scale-up of the success mark, then settle

### Haptics

- Selection haptic for chips and spice changes
- Soft impact for topping adds
- Success haptic for save, coupon apply, and order complete

### Reduce Motion

- Replace large transitions with opacity or instant state change
- Keep all information readable without animation

## 8. Do's and Don'ts

### Do

- Keep the app warm, layered, and native
- Keep primary action styling consistent
- Keep prices and pickup timing visually obvious
- Use food photography to build appetite and confidence
- Use glass and blur sparingly for hierarchy
- Make completion explicit through icon, copy, and state
- Keep the order flow guest-first and uninterrupted

### Don't

- Do not introduce purple-heavy, futuristic, or neon aesthetics
- Do not turn the app into a dark SaaS dashboard
- Do not make coupon UI louder than ordering UI
- Do not add WebView-like card grids and browser chrome patterns
- Do not rely on transparency when contrast would be clearer
- Do not hide key actions in overflow menus
- Do not require login in the core PoC order flow

## 9. Responsive Behavior

This PoC is iPhone-first.
Optimize for portrait mobile before anything else.

### Responsive Rules

- Maintain minimum comfortable tap targets
- Keep bottom actions reachable
- Avoid multi-column ordering layouts on iPhone
- Let cards expand vertically instead of cramming metadata horizontally
- Tighten spacing before shrinking tap targets
- On wider mobile layouts, improve breathing room rather than increasing density

## 10. Agent Prompt Guide

When generating UI for this project, use prompts like:

- `Build a warm native iPhone ordering screen for CoCo Ichibanya using soft ivory backgrounds, curry-brown primary CTAs, appetizing food photography, subtle layered cards, and restrained glass only where hierarchy needs it.`
- `Use native iPhone typography with role-based text styles such as largeTitle, title3, headline, and body, plus strong price emphasis, clear store context, and bottom-fixed main actions.`
- `Avoid purple gradients, dashboard-like dark sections, overly transparent glass, and coupon-first composition.`

For each major screen:

- `S2`: discovery-first, edible imagery, quick filters, clear store context, easy access to saved combos
- `S3`: hero food image, two-phase customization, live order snapshot, immediate price updates
- `S5`: compressed review, pickup clarity, subtle coupon suggestion, dominant place-order CTA
- `S6`: coupon sheet with applicable options prioritized first, optional disabled secondary options, and a fast compare-and-apply flow
- `S8`: explicit success moment, pickup facts first, reassuring next actions
