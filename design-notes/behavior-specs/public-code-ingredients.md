# Abysmal — Public Code Ingredients (vetted)

Status: VETTING ONLY, Nov 4, 2026. No code from any source below has been copied, pasted, or applied to the game. Code application belongs to the systems step. No code is pasted in this file or in any behavior-spec part file — references and adaptation notes only.

Rules (James, Nov 4): a source is usable only if its license is a common, standard one (CC0 / CC-BY / MIT or similar) verified ON the source page; use must stay up to date and compliant (credit + terms honored, recorded); what ships stays Abysmal-original — public sources are ingredients, never wholesale copies of someone else's behavior code passed off as ours. Adapt + credit, do not clone.

Central verification, Nov 4, 2026: every license below was re-checked on its own source page by the coordinator (not just taken from a part writer's claim). One conflict was resolved this way: part-3 listed Beehave (MIT, verified on its repo page) while part-4 did not list it because that writer had not checked its page. The repo page shows "License: MIT License (MIT)" plus a LICENSE file, so Beehave IS included here.

## Vetted ingredients

### 1. LimboAI — Behavior Trees & State Machines for Godot 4

- **Source:** https://github.com/limbonaut/limboai
- **License:** MIT-style, verified on the repo page ("License: MIT License (MIT)"; README License section points to the LICENSE file and opensource.org/licenses/MIT). Logo and demo-project art are separately CC-BY 4.0 — not needed, not used.
- **What it is:** C++ plugin for Godot 4 combining behavior trees and hierarchical state machines, with a blackboard system, visual debugger, and GDScript support for custom tasks/states. Supported versions per its README: 1.8.x releases = Godot 4.6+ (GDExtension) / Godot 4.7 (module).
- **What we'd adapt:** only the BT/HSM skeleton + blackboard pattern, for the most layered creatures (Wight Lord, Watcher, Lich, multi-phase patterns, pack coordination, form-change logic). All behaviors, telegraphs, and timings come from Abysmal's own specs.
- **Caveats:** heaviest option — optional, not default. GDExtension export-target check is a systems-step decision (the module path needs export-template builds). Demo project and art are NOT copied.
- **Abysmal-original note:** generic framework machinery only; no demo enemies, scenes, or artwork copied.
- **Appears in:** parts 1, 2, 3, 4, 5, 7.

### 2. Beehave — behavior tree AI for Godot Engine

- **Source:** https://github.com/bitbrain/beehave
- **License:** MIT, verified on the repo page ("License: MIT License (MIT)" plus a LICENSE file).
- **What it is:** pure-GDScript behavior-tree addon — node-based trees built in the scene tree, with a runtime debug view and performance monitors. Godot 4.x branch is 2.x (Godot 4.5+ → 2.10+).
- **What we'd adapt:** the tree/blackboard skeleton for pack coordination, Púca form decisions, and shaman cast-vs-rally choices. All behaviors and telegraphs come from Abysmal's own specs.
- **Caveats:** pure GDScript means no native-extension export burden, but editor-plugin weight versus hand-rolled states is still a systems-step call. Examples are NOT copied.
- **Abysmal-original note:** generic framework machinery only; no example enemies or scenes copied.
- **Appears in:** part 3 (centrally verified here; see the note at the top of this file).

### 3. CodingQuests — Godot Enemy AI

- **Source:** https://github.com/CodingQuests/godot-enemy-ai (also listed at https://store.godotengine.org/asset/codingquests/enemy-ai/)
- **License:** MIT for the code, verified on the repo page ("License: MIT License (MIT)"; README: "MIT for the code. See LICENSE").
- **What it is:** GDScript, Godot 4.7+ (tested on 4.7.2 stable, Windows). One shared state machine — IDLE / CHASE / TELEGRAPH / ATTACK / RECOVERY / DEAD — with readable telegraphs (pulsing ring, line) and four demo shapes: Grunt (chase, ring, swing), Skitterling (weaving, short telegraph), Charger (line lock, dash), Boss (slam, projectile ring, line charge).
- **What we'd adapt:** the telegraph-first state discipline and the charger line-then-dash pattern, mapped to brutes, chargers, skirmishers, ambushers, oozes, and plants. All attacks, telegraphs, and timings come from Abysmal's own specs.
- **Caveats:** 2D demo — movement, facing, and telegraphs must be reworked for first-person readability. No pathfinding and no line-of-sight/hearing in the demo, so Abysmal's Awareness rules must be built, not copied. Demo arena, sprites, and boss are NOT copied (demo sprites are Kenney Tiny Dungeon, CC0 — not needed). Young repo (created Oct 3, 2026, few commits) — license is clear and the code is small and readable, but the systems step should re-check it at adoption time.
- **Abysmal-original note:** shared state shape only; no demo enemies, scenes, or art copied.
- **Appears in:** parts 1, 2, 3, 4, 5, 7.

### 4. CodingQuests — State Machine

- **Source:** https://store.godotengine.org/asset/codingquests/state-machine/ (source code: https://github.com/CodingQuests/godot-state-machine)
- **License:** MIT for the code, verified on the asset page ("MIT for the code. See LICENSE").
- **What it is:** two small GDScript files (StateMachine ~70 lines, State ~30 lines): one node per state, transitions by signal, four hooks per state (enter / exit / update / physics_update), plus a demo slime that idles, roams, chases, telegraphs a leap, staggers, and dies. Godot 4.7+ (tested on 4.7.2 stable, Windows).
- **What we'd adapt:** the node-per-state pattern and signal transitions for simpler creatures; the demo slime's idle-roam-chase-leap flow as a SHAPE for oozes and plants; the telegraphed-leap vulnerable window for ambushers and dives. All states and timings come from Abysmal's own specs.
- **Caveats:** 2D demo (sprites are Kenney Tiny Dungeon, CC0 — not needed). No nested or parallel states. Transitions are by node name, and a typo is silently ignored. No line of sight. The demo room is open, so walled floors need a real navigation bake.
- **Abysmal-original note:** machine scaffolding only; no demo enemy, scene, or art copied.
- **Appears in:** parts 1, 2, 5, 7.

### 5. godot-behavior-tree-plugin

- **Source:** http://godotassetlibrary.com/asset/W8b2oo/godot-behavior-tree-plugin (repo chain: Kriet108 ← brandonlamb ← olsonjeffery ← quabug)
- **License:** MIT, verified on the asset page ("released under the terms of the MIT License").
- **What it is:** pure-GDScript behavior-tree addon — BehaviorTree + BehaviorBlackboard nodes, sequence/selector composites, decorator nodes, action/condition leaves.
- **What we'd adapt:** the sequence/selector/blackboard pattern for branching creatures (multi-head sequences, pack bursts, lure-then-grab). All tree contents come from Abysmal's own specs.
- **Caveats:** the asset-page snapshot consulted is from May 2026 — the systems step should confirm the current repo state before adoption. Lighter-weight alternative to LimboAI/Beehave if only basic trees are needed; no demo content copied.
- **Abysmal-original note:** tree pattern only; no demo enemies or scenes copied.
- **Appears in:** part 5.

### 6. OpenSteer — steering concepts ONLY (not a Godot drop-in)

- **Source:** https://opensteer.sourceforge.net/doc.html
- **License:** MIT, verified on the doc page ("distributed as open source software in accordance with the MIT License").
- **What it is:** a C++ library of steering behaviors (seek, pursuit, evasion, flocking, obstacle avoidance, path following) for autonomous agents.
- **What we'd adapt:** CONCEPTS ONLY, re-implemented in GDScript — seek/pursuit/evasion/flocking for pack and flock movement (Hellhound, Great Wolf, Stymphalian Bird flock, Satyr harrying). No OpenSteer code ships in Abysmal.
- **Caveats:** not a Godot integration; the docs describe version 0.8.2 as not mature or stable and ask to be contacted before large-project integration — another reason to take concepts only, never the library.
- **Abysmal-original note:** steering math re-implemented from documented concepts; no library code copied.
- **Appears in:** part 5.

## Deliberately excluded (not ingredients)

- **Paid itch.io horror-creature pack advertising a CreatureAI script** (found during part-2 research): no license verifiable on its page, so it is excluded, not assumed usable. It is also outside the free scope — never buy without James's word.
- **General rule:** anything whose license could not be verified on its own source page is excluded, not assumed. The writers applied this consistently (e.g., part-4 left out Beehave only because that writer hadn't checked its page — resolved above by central verification).

## Credit recording

MIT notices for anything actually adapted go into `design-notes/credits-and-attribution.md` at systems-step adoption time. This list records the obligation now; no code has been adapted yet, so no credit entries are added yet.

## Part-6 coverage note

Part-6 (Egyptian, Mesopotamian, South Asian, Chinese, Yōkai) carries no appendix of its own — the Nov 4 scope update never reached that writer (tool-layer delivery failure, twice). Its families are covered centrally by this list: the ingredients above are pattern-based (state machines, behavior trees, telegraph discipline, steering concepts), not per-family, and the part-6 specs need no family-specific code candidate beyond these patterns. The part-6 specs themselves are unaffected.
