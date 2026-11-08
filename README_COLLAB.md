# Idle Dungeon Roguelike — collaborator notes

Godot 4.7 project. Open `project.godot` with Godot 4.7 and it imports clean.
Export presets: **Android (Debug)**, **Android (Release)**, **Windows Desktop**.
(For Windows export, install the export templates first: Editor → Manage Export Templates.)

## What's NOT in this zip

- `assets/audio/alkakrab/` — 2 GB of staged (not yet wired-in) music WAVs. Too big to share; the game doesn't use them yet.
- `.godot/` — editor import cache. Regenerates on first open.
- `keystore/` — James's Android release signing key. Deliberately excluded; builds you make will be debug-signed.
- `test_logs/` — old test output.

## What we've built so far

- **Core loop:** idle auto-delving dungeon crawler. The little guy explores, fights, loots,
  and descends on his own; you manage the build. Death sends you to the death shop —
  spend gold on 14 skills and 8 charms, then delve again.
- **Death shop:** skills level with gold (price ×1.10/level, effects +0.5%/level;
  Luck is the generous one: +2% gold, +1% rarity per level). Charms are one-run
  consumables with rebuy growth ×1.2.
- **Save system (v0.6.0):** autosaves every 30s and on app background; restores the live
  run exactly — floor, RNG, enemies, loot, fog, open shop. Meta progression always persists.
- **Idle brain:** explores room by room (monsters → chests/loot → unexplored cells),
  mentally marks the exit but finishes clearing first, retreats to the depth shop for a
  50%-HP patch-up at critical HP (≤25%). Smooth interpolated movement with walk bob.
- **Dungeon gen:** connectivity guaranteed; chests can never seal off enemies/stairs;
  fog of war with radius-4 light; locked doors, seals, sleepers, patrols, horde floors.
- **Depth scaling (working tree, unreleased):** maps grow 40×40 → 120×120 with depth,
  walk speed scales 1.0× → 3.0×, minimap follows the player (whole-map only when it fits).
- **Manual mode:** turn-based play with keyboard support; potion drinking is a free action.
- **Economy:** tuned for the long climb — depth 10 is the tutorial; curves must survive
  100s, 1,000s, 10,000s of depths. Easy, but not too easy.
- **Staged, not yet wired in:** Quaternius animated monsters (bat/slime/skeleton),
  Kenney SFX (372 files), FlakDeau pixel dungeon textures, Alkakrab music.
  Rule: no AI-generated assets, ever — everything is hand-made/CC0.

## Roadmap

1. **Wire in the staged assets** — models, SFX, textures, music. Nothing AI-made.
2. **NPC breadcrumb trail** — depth 2 farmer (Well Fed: +max HP), depth 4 woodcutter
   (Well Rested: +regen), depth 6 blacksmith (Well Armed: +attack), depth 8 trader
   (Inspired: +luck). Buffs are soul-bound: they persist through death.
3. **Town + guild pivot** — depth 10 is a soft nudge, not a gate: found a guild, shift
   from personal adventuring toward managing adventurers and a growing town.
4. **Offline earnings** — "while you were away" gold on load, so income keeps pace
   with skill costs at any depth, even when the player is away.
5. **Player speed as a real stat**, more validation (longer soaks, door/patrol/sleeper
   edge cases), Barony-style monster horde floor.

## Ground rules from James

- Credits use the pseudonym **Aethelwarden Solas** — his real name stays off the project entirely.
- Nothing gets published, uploaded, or monetized without his explicit go-ahead.
- One step at a time: small, reviewable changes.
