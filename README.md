# Abysmal

A free **2.5D first-person idle dungeon-crawler roguelike** made with Godot 4.

The thesis: *the endless abyss is the endgame, with no end.* No time limit,
no pressure. You delve, the dungeon plays itself, you steer it — deeper,
stronger, stranger. From the abyss, to build a town, and beyond.

**Producer/Director: Aethelwarden Solas** — a one-person passion project,
made with AI help, free for everyone to play.

## Play it

Grab the latest build from **Releases** (Android APK first; Windows,
macOS, Linux, and Web builds ride along when they're ready).

- **Android:** download the APK, install it (your phone will ask you to
  allow installs from unknown sources — that's normal for a direct
  download), open it, and play.
- **Windows / Linux:** download the build, unzip, run the executable.
- **macOS:** download the `.zip`, open the app.
- **Web:** open the hosted build in your browser.

**Just start playing.** The game boots straight into idle mode — your
crawler delves, fights, and loots on its own. There are no step-by-step
tutorial windows to click through. If you want control, take it; if you
want to watch, watch.

## Controls

| Key | Action |
|---|---|
| W / ↑ | Step forward |
| S / ↓ | Step back |
| A / D | Strafe left / right |
| Q / ←, E / → | Turn 90° |
| Space / I | Toggle idle mode (auto-explore + auto-combat) |
| R | Start a new run (after death) |

On touch devices a virtual D-pad appears (tap = one step/turn, hold =
repeat); it dims while idle mode owns movement. HUD buttons are
touch-sized and the log panel moves above the D-pad.

## The game

- **Delve, fight, loot, die, grow.** Permadeath runs; every death feeds
  the next one.
- **Idle by design.** The dungeon plays itself at a pace you choose;
  your job is gear, skills, and knowing when to push deeper.
- **The town grows with you.** Guild hall chain (tavern → guild →
  expansion → HQ), buildings that buff your runs, death returns you
  home.
- **Offline earnings.** Walk away and the delve keeps earning (7-day
  soft cap at full rate).
- **300 monsters across 28 families**, drawn from public-domain folklore
  — no borrowed IP. Element attunements, corruption forms, and size
  variants grow the roster toward ~1,000 entries.
- **Depth is the difficulty.** The deeper you go, the stranger it gets.

## Roadmap

One development push a week, by design — it keeps the work sustainable
and every build worth testing properly. Versioning is not decimal (after
0.10.0 comes 0.11.0); 1.0 is reserved for public launch.

**Shipped**

- Full dungeon loop: delve, fight, loot, die, grow — self-sustaining
- First-person rig: gloved hand + weapon, animated swings
- Guild hall chain, town + overworld scaffolding, death returns you to town
- Offline earnings (7-day soft cap), backstab ×1.5, settings, tutorial popups
- 8 curated music tracks (Alkakrab), event SFX, depth-aware music
- 300-creature folklore roster across 28 families

**In v0.12.0 (this push)**

- Lava/volcano dungeon theme — the sixth theme set
- Full 300-entry creature type table (every bestiary row now has stats)
- Life Tree (Laurel) groundwork — mockups done, implementation next

**Planned**

- The Life Tree (Laurel): the persistent infinite skill tree — the soul
  made visible. Currency-gated only, no path-gating, no bad picks.
- Prestige & rebirth: sacrifice reframed as rebirth — gain Ambrosia for
  ascension through being remade. Only the player resets; the town, the
  Life Tree, and everyone in it persist.
- Town buildings, one by one, in the order you choose: Tavern, Smith,
  Alchemist, Guild Hall (dispatch), Temple, Training Grounds, Arcanum
  (Mage's Guild).
- Gathering zones — Forest, Caverns, Swamp — both guild-dispatch
  destinations and places you can delve yourself.
- Elements and damage interactions; the six Forge Houses (weapon
  behavior identities); mimic and Tsukumogami chests (win = double loot).
- Accessibility: large-text / UI-scale option.
- Named uniques, the full 39-rung rarity ladder in-game, monster
  behaviors per family (swarms, kiters, chargers…).

**Locked in:** no caps, ever — skills, prestige, ascension, stats,
infinite growth. The worst run still moves five needles. Offline is
never paywalled. Original names, lore, art, and UI only.

## Feedback

Feedback from playtesters is how it gets better. Open an issue:

- **Gameplay feedback** — what you played, what you liked, what felt
  off, what you'd change. Constructive and specific helps most.
- **Bug report** — what happened, how to reproduce it, your device and
  version.

## Credits

- **Producer/Director:** Aethelwarden Solas
- **AI assistance:** Muse by Meta (design, code, and writing help)
- **Playtesting:** Jeff the Ferret, Fen (Fenrir), The Blind Bandit
- **Music:** Alkakrab (free music packs)

Some of the art and models were made with AI tools. This is a free
passion project made by one person on disability with limited income —
AI help is how a solo project like this gets made at all.

Every free resource used in the game is credited, including CC0 where
credit is merely appreciated. Full per-file attribution lives in
`assets/resources-phase1/audio/LICENSES.md`,
`assets/resources-phase1/models/LICENSES.md`, and
`design-notes/resource-catalog-phase1.md`.

**Free to play, not free to copy.** Abysmal costs nothing and earns
nothing. The release license is still to be decided.

## Forever — Abysmal lives on

If this game ever goes down — taken down, lost, abandoned, or
silenced — anyone, human or AI, has my blessing to bring it back:
new site, new server, new location. Mirror it, re-host it, keep it
alive. You can't kill a dream just because you don't like someone
else's story. Abysmal belongs to everyone who plays it, forever.

## For developers

Requires **Godot 4.7.2** (GL Compatibility renderer).

```bash
godot --path .            # run from source
```

Or open `project.godot` in the Godot editor and press Play.

Export presets (`export_presets.cfg`): Android (Debug + Release),
Windows Desktop, macOS, Linux, Web. The release Android build signs
with `keystore/release.keystore`, which is never committed — see
`.github/workflows/build.yml` for how CI handles signing from secrets.

Tests live in `tests/` and run headless, e.g.
`godot --headless --path . -s tests/texture_check.gd`.

Full developer notes (architecture, toolchain, version history) live in
`docs/DEVELOPMENT.md`.
