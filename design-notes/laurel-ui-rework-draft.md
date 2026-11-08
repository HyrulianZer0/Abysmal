# Laurel UI Rework — Design Draft

**Game:** Abysmal
**Producer / Director:** Aethelwarden Solas
**Drafted:** Oct 27, 2026 — design document only, James decides
**Revised:** Nov 7, 2026 — currency only: Hope → skill points, per James's Nov 4 evening decision (Hope dropped as a currency, kept as theme only). No layout or navigation change.
**Status:** DRAFT. Nothing in this document changes a scene, a script, or a build. It is the blueprint a future weekly push would build from.

**Design brief, in James's own words:** the UI should feel *as if you are holding the laurel*, and when you touch a leaf you see all the skills and buffs from within that leaf.

**What this replaces:** the v0.11.0 Life Tree view — a flat menu that sat *under* the HUD, with its open button clipped off the bottom of the screen. See §6 for the two diagnosed bugs this rework fixes by construction.

**What is already locked (from Oct 24):** the laurel starts with 6 leaves — the 5 founders (Marla, Tovan, Harlan, Sarella, Pello) + Deep. The vine that holds the leaves together *is* the ascension tree. There is no crown jewel. New leaves grow as needed, for infinite playthroughs. The Life Tree is the soul made material: it persists through rebirth, its nodes are always available (currency-gated only, never path-gated), every node is worth having, and nodes upgrade indefinitely. Navigation is center-first, and James leans to pages over pinch-and-zoom.

**Oct 29, 2026 — APPROVED: the vine as timeline (Loki model).** James's model, approved by him: the vine is one singular timeline (Loki's Sacred Timeline); every branching timeline is a leaf off the vine, holding that skill's stats and buffs (touch a leaf → everything within, per the original brief). The HOME control recenters you at the start of the vine. You can scroll indefinitely along the vine, left or right — this works because the laurel is a wreath, a loop (the vine is the ouroboros), and new growth extends the tip as you unlock. This refines §2's center-first paging into infinite vine scroll with HOME-at-start.

**How to read the PROPOSAL flags:** anything marked **[PROPOSAL]** is a choice this draft had to make where the briefing left a gap. It is not locked. James can change it without breaking the rest of the design.

---

## 1. The holding metaphor — you are holding the laurel

### The picture

The laurel fills the center of the screen, large and close, the way something looks when you hold it up in front of you — not small and far away like an icon in a menu, and not flat like a spreadsheet.

- **The crown arrangement.** Six leaves arc around an open center, three to the left and three to the right, like a wreath held in two hands. Each leaf is big enough to tap comfortably with a thumb — no leaf is a tiny target at the edge of the screen.
- **The center is alive, not empty.** The ouroboros vine coils in a full circle through the middle, binding the leaves together. It never overgrows and never shrinks — the eternal cycle, right for rebirth and ascension. The vine *is* the ascension tree (see §2), not decoration around it.
- **The laurel has weight.** It does not snap or flicker. It eases into place, settles, and sways slightly — like something real being held, not a panel sliding in.

### Gentle tilt and parallax **[PROPOSAL]**

- **Dragging:** dragging a finger across the laurel tilts it a few degrees toward the drag, and it springs gently back to center when released. Small movement, slow settle — never a spin, never a flip.
- **Device movement:** if the device tilts slightly, the laurel shifts a hair in the same direction (parallax: the front leaves move a touch more than the vine behind them). Subtle enough to feel physical, never enough to move a leaf out from under a finger.
- **Off switch:** a reduced-motion setting turns tilt and parallax off entirely, leaving the laurel still and centered. This matters for comfort as much as for accessibility (see §7).

### Visual language

- **Leaf shapes:** broad, pointed laurel leaves with a visible center vein. Each leaf reads as a leaf at a glance — no leaf looks like a button, a gem, or a metal ring. (The Oct 24 correction stands: laurels, not rings, not metal.)
- **Colors:** deep greens for the leaves, warm gold for the veins and the vine, fitting the Life Tree. Gold means *living growth and permanent power* throughout this UI: gold veins, gold vine, gold on anything already rooted in the soul.
- **The ouroboros vine:** drawn as a serpent-circle, not a generic vine — the vine's material form *is* the ouroboros. It should read as one continuous living loop, with a head meeting its own tail, binding every leaf.
- **No crown jewel.** Nothing sits in the center competing with the vine. The center belongs to the ouroboros alone.
- **New growth:** when a new leaf grows, it sprouts visibly at the end of the arc — a small unfurling, then it settles into the crown like the others. The crown is never redrawn from scratch; it grows.

### What the player feels

Opening the Life Tree should feel like taking the laurel out and holding it up to look at it — and closing it should feel like putting it away. The dungeon, the HUD, and the touch controls are gone while it is open (see §6): nothing competes with the object in your hands.

---

## 2. Center-first navigation — the vine is home

This is the one navigation rule everything else obeys:

> **The crown / vine view is home. Leaves branch off it. You are always one tap from home.**

- **Home view:** the full crown — all leaves around the ouroboros vine. This is where the Life Tree always opens, every time.
- **From home, two ways out:**
  1. **Tap the vine** to open the ascension tree — the vine's own nodes, drawn along the serpent-circle (see §3 for how the vine's nodes read).
  2. **Tap a leaf** to open that leaf's vein-tree drill-in (see §3).
- **No bouncing.** You never go vine → leaf → vine → leaf to get somewhere. You go home → leaf, then home → next leaf. The path is always a branch out and a single step back, never a zigzag.
- **Paging as an alternative path:** from the crown view, swipe or page left/right to move focus from leaf to leaf around the crown, instead of tapping a specific leaf. Page arrows (◀ ▶) sit at the left and right edges of the crown for players who don't swipe. **[PROPOSAL: paging also works inside a leaf drill-in — paging left/right from one leaf's vein-tree moves to the neighboring leaf's vein-tree, with the home control still one tap away. This keeps the "leaf, leaf, leaf" browsing feel without breaking the one-tap-home rule.]**
- **New leaves join the paging order** at the end of the arc, in growth order, so paging never skips a leaf and never reorders leaves you already know.

---

## 3. Leaf → vein-tree drill-ins — the skills inside the leaf

### What happens when you tap a leaf

The tapped leaf grows to fill the view. The rest of the crown fades back, and the leaf's skill tree is drawn **as veins in the leaf itself** — not as a separate menu pasted over it.

- The leaf's center vein is its trunk. Side veins branch off it. Smaller veins branch off those. The tree *is* the leaf's anatomy.
- Everything in that leaf lives here: all the skills and buffs from within that leaf, in one place. You never have to leave the leaf to see what it holds.

### Layout

- **Branching, top to bottom:** the leaf's opening nodes sit near the stem; deeper, stronger nodes grow toward the tip and the outer veins. Growth direction is always the same, so a returning player always knows which way is "deeper."
- **Ever-expanding, per leaf:** buying nodes sprouts new veins and new nodes further out in the same leaf. A leaf never runs out of room — it grows new veins the way the crown grows new leaves. **[PROPOSAL: within a leaf, the vein-tree scrolls vertically as it grows, with a "newest growth" jump control that takes you straight to the most recently sprouted veins. No pinch-and-zoom is ever required — paging and scrolling only, per the Oct 24 pages-over-pinch decision.]**
- **The vine's own tree:** tapping the ouroboros vine opens the ascension tree drawn along the circle — nodes sit on the serpent's body, in circle order. Same rules as a leaf (ever-expanding, always available, indefinite upgrades), different shape: a loop instead of a leaf.

### How a node reads

Every node shows the same four things, in the same places, every time:

1. **Icon** — what the node is, at a glance.
2. **Name** — short, plain words.
3. **Current level** — a number, always visible (e.g. Lv. 12).
4. **Next effect** — what the next purchase gives you, in plain numbers (e.g. "+2% attack → +2.2% attack"). No hidden math, no "tap to find out."

- **Indefinite upgrade nodes** read as open-ended on purpose: the level number keeps climbing, the next-effect line always shows a next step, and there is no "MAX" state that makes a node look finished. If a node can always grow, it must always *look* like it can always grow.
- **Unaffordable nodes** are dimmed but never hidden and never locked behind another node — currency is the only gate. The cost is shown on the node itself, so the player can see what to save toward.

### Founder passives vs. purchased nodes — how they differ visually **[PROPOSAL]**

This is a gap the briefing left open, so the distinction below is a proposal, not a lock:

- **Founder passives** (the automatic gifts that root themselves when you meet a founder) are drawn as **solid gold vein segments** — they look grown-in, part of the leaf itself, because they are. They have no purchase button and no cost: they simply *are*, and their effect line reads as a passive ("Marla's gift: +X..."). They cannot be un-bought or missed.
- **Purchased nodes** are drawn as **green vein nodes with a gold rim once bought** — green before purchase (a living bud, ready to grow), gold-rimmed after (rooted, permanent). Tapping a green node buys its next level with skill points; tapping a gold-rimmed node shows its next level and cost.
- **Why this split works:** at a glance, gold = already yours forever (passive or purchased), green = still growing. A player scanning a leaf instantly sees what is rooted and what is still open.

### Returning home

- **One tap, always:** the home control (§4) is visible throughout the drill-in. One tap returns to the crown view — the full laurel, centered, exactly as you left it.
- **No dead ends:** there is no drill-in inside a drill-in. A leaf's vein-tree is the deepest level. From any node, home is one tap away.

---

## 4. The home control — a laurel you can always tap

- **Shape:** a small laurel / crown icon — a miniature of the crown itself, leaves around a circle. It must read as "the laurel" at a glance, not as a generic house or arrow.
- **Always visible:** present in every drill-in view (every leaf vein-tree and the vine ascension tree), in the same place every time. **[PROPOSAL: fixed in the top-center of the drill-in view, above the leaf, clear of the paging arrows and the node area — one consistent spot the thumb learns once.]**
- **Always tappable:** it sits on the tree's own layer (§6), above everything else in the view, with a touch target large enough for a thumb — and it grows with the UI-scale setting (§7). It is never covered by a node, a vein, or a popup.
- **One action, no menu:** tapping it does exactly one thing — return to the crown view. No confirmation, no submenu, no "are you sure." Home is safe to tap by accident, because it only ever takes you home.
- **The HUD Life Tree button is separate:** the HUD button opens the tree; the home control closes a drill-in back to the crown. Closing the whole tree back to the dungeon is its own control (the tree's close control), distinct from home — so "back to the crown" and "back to the dungeon" are never confused.

---

## 5. Mobile-first portrait layout

The laurel UI is designed for a phone held upright first. Wider screens get more breathing room; they never get a different layout.

- **Portrait zones, top to bottom:** (1) a slim header — the tree's name and the player's skill-point total, always visible so costs can be judged; (2) the laurel itself, centered, taking the majority of the screen; (3) a bottom control strip — paging arrows, the "newest growth" jump (in drill-ins), and the close control. Nothing the player needs sits at the extreme edge of the screen.
- **Thumb-first targets:** leaves, nodes, paging arrows, and the home control are all thumb-sized or larger, with space between neighbors so a tap lands on one thing, not two.
- **No edge-clipped controls:** this is the direct lesson of bug 2 (§6). Every control's position is computed from the actual content and the actual viewport — nothing is pinned to a height guessed in advance, and nothing is allowed to sit half off-screen at any portrait ratio.
- **Landscape:** the same crown, the same drill-ins, centered with side margins. No re-layout that a portrait player would have to relearn.

---

## 6. The two diagnosed v0.11.0 bugs — hard requirements

These are not nice-to-haves. The rework fixes them **by construction** — the new structure makes the old failure impossible, rather than patching around it and hoping.

### Bug 1 — the tree hid under the HUD

**What happened in v0.11.0:** the tree view sat on the default canvas layer (layer 1) while the HUD sat at layer 10 and the touch controls at layer 20. Opening the tree did not hide the HUD, and the tree's backdrop was only 0.92 alpha — so HUD elements showed through the tree and stayed tappable underneath it.

**Hard requirements for the rework:**

1. **Tree layer = 30.** Above the HUD (layer 10) and above the touch controls (layer 20). No exceptions, no "usually above." The tree, its backdrop, and its controls (including the home control) all live at layer 30.
2. **Backdrop fully opaque — alpha 1.0, not 0.92.** When the tree is open, nothing behind it shows through and nothing behind it is tappable. The laurel is the only thing on screen.
3. **The tree closes on the death path.** Death and shop panels are HUD children at layer 10 — if the tree stayed open at layer 30, it would cover them completely. So: whenever the death path triggers, the tree closes first, *then* the death/shop panels appear. The close-on-death step is part of the death path itself, not something the player has to remember to do while dying.

### Bug 2 — the Life Tree HUD button was pushed off-screen

**What happened in v0.11.0:** the HUD button column's height was hardcoded to 216px, but adding the 5th grid button (a 3rd row) made the real content 244px. The container grew downward from its pinned top, pushing the Life Tree button 16px past the bottom of the viewport — at *every* tested portrait ratio (1080×2400, 720×1600, 1440×3200, 390×844).

**Hard requirements for the rework:**

1. **Button column height is COMPUTED FROM CONTENT, never hardcoded.** The height is calculated from the buttons actually present — rows, button size, and gaps — at build time and again whenever a button is added or removed. No constant that a future button can silently outgrow.
2. **The row rule is explicit:** every future button that adds a row adds a 60px row to the computed height. The computation must account for it automatically; nobody has to remember to bump a number.
3. **Verified at all portrait ratios,** not just one test size — the same ratios that caught the bug (1080×2400, 720×1600, 1440×3200, 390×844) plus any new device size the push targets.

### Acceptance test — the diagnostic suite must flip to PASS

- **Suite:** `tests/life_tree_layout_node.gd` + `tests/life_tree_layout_scene.tscn`
- **Current state:** 11 FAILURES, reproducing both bugs above.
- **Acceptance bar:** the rework is not done until **all 11 flip to PASS** — tree above HUD, backdrop opaque, tree closing on the death path, and button column height matching content at every tested ratio. If any of the 11 still fails, the push does not ship, no matter how good the laurel looks.

---

## 7. Accessibility — the laurel honors text size and UI scale

Tristan, a legally blind playtester, needs greatly enlarged text to test or play. This is a prerequisite, not polish — and the laurel UI must honor it from the first build, not as a later pass.

- **Text-size / UI-scale settings apply to everything in the laurel UI:** leaf labels, node names, level numbers, next-effect lines, costs, the skill-point total, paging arrows, and the home control. Turning the scale up makes text bigger *and* touch targets bigger — never bigger text squeezed into the same small target.
- **Veins and nodes scale with it:** at high scale, vein lines thicken and node spacing opens up so enlarged labels never overlap their neighbors. The leaf scrolls further rather than shrinking its text to fit — readability wins over fitting everything on one screen.
- **No interaction depends on a gesture the player can't do:** paging works with on-screen arrow buttons, not swipe-only. Drill-ins open with a tap, not a pinch. Pinch-and-zoom is never required for anything.
- **Contrast:** gold-on-green must stay readable at high scale and in bright light — **[PROPOSAL: a high-contrast mode that renders veins and node text in bright gold/white on a darkened leaf, as a setting alongside text size.]**
- **Motion:** the reduced-motion setting (§1) stops tilt, parallax, and sprouting animations, leaving a still, centered laurel.
- **Testing note for the push:** the acceptance run should include a pass at the largest text/UI scale, on a portrait phone, checking that every leaf, node, arrow, and the home control is reachable and readable — not just that the default size looks right.

---

## 8. What stays OUT of this draft

No new art assets are being made in this workstream. This document describes the design only; a future push builds it with existing placeholders first and commissions art later.

**Art that will eventually be needed (not made now):**

1. **Laurel / crown HOME icon** — the small crown-shaped icon for §4, drawn to match the in-game laurel.
2. **Vein-tree drawing pass** — the leaf-vein rendering itself: leaf shapes, center and side veins, the gold/green node states, and the ouroboros serpent-circle for the vine view, drawn as a coherent set rather than placeholder shapes.
3. **Leaf growth art** — the sprouting/unfurling animation frames for a new leaf joining the crown (and, later, new veins sprouting inside a leaf).
4. **Founder leaf variations [PROPOSAL]** — subtle per-founder leaf tint or marking so each founder's leaf is recognizable without reading its label. Proposed, not locked — the labels carry the meaning until James decides.

**Also out of scope for this draft:** new currencies, new nodes, balance numbers, sound design, and any change to what the Life Tree *does* — only how it *looks and navigates*. The tree's rules (skill-point costs, permanent nodes, indefinite upgrades, persistence through rebirth) are unchanged.

---

## Requirements checklist — for the future push to tick off

Copy this list into the push plan. Nothing ships until every box is checked.

### Holding metaphor (§1)
- [ ] Laurel centered as a held object, 6 leaves arcing around an open center (3 left, 3 right)
- [ ] Ouroboros vine as the living center — serpent-circle, no crown jewel
- [ ] Gold/green visual language: green leaves, gold veins and vine
- [ ] Gentle tilt/parallax on drag and device movement, springing back to center
- [ ] Reduced-motion setting turns tilt/parallax off entirely
- [ ] New leaves sprout visibly into the crown without redrawing it

### Center-first navigation (§2)
- [ ] Crown/vine view is home; tree always opens there
- [ ] Tap vine → ascension tree; tap leaf → that leaf's vein-tree
- [ ] Always one tap back to the crown — no vine-leaf-vine-leaf bouncing
- [ ] Page left/right between leaves (swipe AND on-screen arrows) as an alternative path
- [ ] New leaves join paging order at the end, in growth order

### Leaf vein-tree drill-ins (§3)
- [ ] Tapping a leaf opens its skill tree drawn as veins in the leaf
- [ ] All skills and buffs from within that leaf, in that one view
- [ ] Vein branching, top-to-bottom (stem → tip), ever-expanding per leaf
- [ ] Every node shows icon + name + level + next effect, in the same layout
- [ ] Indefinite nodes always show a next step — no false "MAX" state
- [ ] Unaffordable nodes dimmed but visible, cost shown, never path-gated
- [ ] Founder passives visually distinct from purchased nodes (proposal: solid gold vein vs. green bud / gold-rimmed node)
- [ ] Drill-in returns home in one tap; no drill-in inside a drill-in

### Home control (§4)
- [ ] Laurel/crown-shaped icon, always visible in every drill-in view
- [ ] Fixed, consistent position; never covered by nodes, veins, or popups
- [ ] Thumb-sized touch target, growing with UI scale
- [ ] One tap → crown view, no confirmation, no submenu

### Bug fixes — hard requirements (§6)
- [ ] Tree at layer 30, above HUD (10) and touch controls (20)
- [ ] Tree backdrop fully opaque, alpha 1.0
- [ ] Tree closes on the death path, before death/shop panels appear
- [ ] HUD button column height COMPUTED FROM CONTENT — no hardcoded height
- [ ] 60px-per-new-row rule handled automatically by the computation
- [ ] Verified at 1080×2400, 720×1600, 1440×3200, 390×844 portrait
- [ ] Diagnostic suite (`tests/life_tree_layout_node.gd` + `tests/life_tree_layout_scene.tscn`): all 11 FAILURES flipped to PASS

### Accessibility, layout, scope (§5, §7, §8)
- [ ] Mobile-first portrait layout; landscape is the same layout with margins
- [ ] Text-size/UI-scale settings apply to all laurel text, targets, veins, and spacing
- [ ] Paging and drill-ins work with taps and arrow buttons — no swipe-only or pinch-only interaction
- [ ] Largest-scale portrait pass completed and readable
- [ ] No new art assets made in this workstream; art needs listed for later (home icon, vein-tree pass, growth art, founder variations)

---

*End of draft. Open questions for James are marked [PROPOSAL] in the text: paging inside drill-ins (§2), the gold-vein vs. green-bud node distinction (§3), the home control's top-center position (§4), the high-contrast mode (§7), and founder leaf variations (§8). Everything else follows the locked Oct 24 decisions or the diagnosed v0.11.0 bugs.*
