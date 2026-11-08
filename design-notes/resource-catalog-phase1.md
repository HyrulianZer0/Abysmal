# Resource Catalog — Phase 1 (Oct 29, 2026)

**Status: HUNT ONLY.** No game code, scene, test, or existing asset was
modified. No build, no APK, no release. Everything below is staged
files + catalog docs, waiting for Phase 2 (gated on James verifying
tokens left).

**Credits:** game credits use the pseudonym **Aethelwarden Solas** only.

## What was downloaded (verified on disk)

| Type | Count | Size | Location |
|---|---|---|---|
| Audio files | 670 | ~36 MB | `assets/resources-phase1/audio/` |
| Model packs (Kenney CC0) | 3 packs, 1 shared rig, 12 skins | ~6.7 MB | `assets/resources-phase1/models/` |
| Behavior catalog (doc) | 18 archetypes + 7 composites + 16 apex patterns | — | `design-notes/behavior-catalog-phase1.md` |

Per-type license records and mappings live in the hunters' own docs —
this file is the master index, not a second copy:
- Audio licenses + family mapping:
  `assets/resources-phase1/audio/LICENSES.md`,
  `assets/resources-phase1/audio/CATALOG.md`
- Model licenses + mapping + leads:
  `assets/resources-phase1/models/LICENSES.md`,
  `assets/resources-phase1/models/CATALOG.md`
- Behavior catalog: `design-notes/behavior-catalog-phase1.md`

## Audio — per-family coverage (honest)

Dedicated vocal pools: undead 78, humans 92, orcs 51 (pitch down for
trolls/giants), demons 33, fey 65, abyssal/cosmic 101, constructs 48,
beasts 28, goblin-kin 5, oozes 8, vermin 9, spirits/breaths 19.
Dragons thin: 2 dedicated growls + beast roars as backup.
Attacks 42, movement 19 (dirt/water footsteps + 1 stomp only).
License split: 126 CC0 / 544 CC-BY 3.0 (Little Robot Sound Factory —
attribution required; jalastram — "Jesús Lastra").
Sources: Ogrebane Monster SFX 2 (CC0), rubberduck 80 CC0 creature
SFX #2 (CC0), Little Robot Sound Factory Voices/Fantasy/Horror
(CC-BY 3.0), jalastram Pack 001 (CC-BY 3.0), Kenney Voiceover war
shouts (CC0). Existing in-project Kenney packs were NOT re-downloaded.
Apex bosses: no named audio exists in any free pack found — the audio
CATALOG.md suggests a layering pool per boss (e.g., Fenrir → beast,
Koschei → undead + spirit).

## Models — per-family coverage (honest)

Covered, partially: Undead (Zombie only, 4 skins) and Humans
(Brigand-plausible stand-ins only, 8 skins, some modern-dress and a
poor thematic fit). One shared rig; animations thin (idle, run, jump
pose — no walk, attack, or death clips). Format: FBX (Godot 4 imports
FBX; no conversion needed). Kenney CC0, credit appreciated not
required.
NOT covered (no Godot-usable model found under the rules): beasts,
vermin, goblin-kin, orcs/trolls/giants, demons, dragons/serpents,
spirits/fey, golems/constructs, elementals, aquatic, Greek, Norse,
Egyptian, yōkai, Celtic, Slavic, Mesopotamian, South Asian, Chinese,
Mesoamerican, African, celestials, plants/fungi, sky/storm,
abyssal/cosmic — and none of the 16 apex bosses. Empty subfolders
under models/ are deliberate placeholders, not oversights.

## Phase 1b — expanded model hunt (Oct 29, 2026, STAGED ONLY)

James's brief: no more blocky human stand-ins for kobolds and
bugbears — find creature-true models in a Quaternius-like
stylized low-poly look, beyond Kenney, crediting ALL creators.
Three hunters, no code touched, no build. Full detail in
`assets/resources-phase1/models/CATALOG.md` (Phase 1b section),
`assets/resources-phase1/models/LICENSES.md` (Phase 1b section),
and the three ledgers (`phase1b-ps1-ledger.md`,
`phase1b-oga-ledger.md`, `phase1b-wide-ledger.md`).

What landed (models/ now ~181 MB on disk):
- **Gobkit, CC0, 60 GLB animated+skinned** (48 curated + 12
  community) — the closest Quaternius-style match: 10 orcs, real
  wolf, spider, scorpion, centipede, minotaur, gryphon, bear,
  boar, imp, wyverns ×2, ghost, mummy, vampire, werewolf, goblin
  minions (generic stand-ins, NOT goblin reads), and more.
- **3DAssets.dev, CC0, 8 GLB** — true goblin, true wolf, true
  spider, dragon ×2 (static), serpent (static), skeleton warrior,
  stone golem (static). PROVENANCE FLAG: AI-generated, no human
  author named — license clean CC0, but James may weigh them
  separately.
- **Blender exports, 18 GLB** — all 13 PS1 enemies clean; bat,
  rat, cerberus, kappa, goblin with non-fatal warnings (check in
  Godot). Blender 4.5.3 LTS portable installed at
  `~/workspace/tools/blender-4.5.3-linux-x64/` (1.2 GB) for Phase 2.
- **OGA Godot-usable:** Bone Golem (OBJ), Skeleton Outlaw (FBX +
  14 anims), Crossbowman Skeleton (OBJ, static — needs rigging).
- **.blend staged (export pending):** PS1 sources, FLARE Daemon,
  Troll, Fire/Ice/Stone Golem, Pirate Crewman Ghost, Skeleton
  with rig. Dragon stays .3ds-only (Blender 4.5.3 has no 3DS
  importer; needs Blender ≤3.6 or Assimp + rigging).
- **Copyleft flags (confirm the CC-BY 3.0 election before use):**
  Cerberus (multi-license), Fire/Ice/Stone Golem (dual), Bone
  Golem (dual). No staged file requires copyleft.
- **Deduplication note:** PS1, bat, rat, goblin, cerberus, kappa,
  dragon were staged twice under different paths — same source
  assets; canonical copies are the PS1-ledger paths (with .glb).
- **Still missing creature-true models:** Troll, demons beyond
  Imp, spirits beyond Ghost, animated serpents/dragons with full
  clips, animated golems, Skeleton Archer (rigging pending), true
  Zombie beyond Kenney skins, Banshee, Lich, Ghoul, goblin
  variants (Shaman, Sneak, Hobgoblin, Bugbear, Kobold), true Wasp,
  Frog, Oni, elementals, celestials, sky/storm, abyssal/cosmic,
  and 15 of 16 apex bosses (Cerberus only).
- **Still gated (not worked around):** itch.io (Quaternius,
  KayKit, LOWPO goblins, Kenney bundles), Sketchfab (account gate;
  CC dragons are leads only), FLARE Knight/Occultist (license
  conflict), Gobkit "coming soon" (Skeleton Warrior, Imp Fiend,
  Orc Bruiser, Human Knight, Sprite).

## Behavior catalog (doc only)

All 18 archetypes + 7 staged composites, each with movement, attack,
telegraph, special mechanic, tuning hooks against the locked curves
(HP × depth^1.2, ATK × depth^1.05, flat defense), and roster users.
Plus a high-level signature-pattern table for all 16 apex bosses.
No stats invented beyond locked curves + staged depth-1 values. No
drop mappings invented (locked only: wolf→fur, boar→leather,
spider→silk, light/heavy leather by size, teeth/fangs as
Undercrucible reagents). Boss→slot mapping noted as PROPOSAL ONLY,
not reproduced as a mapping.

## GAPS — the honest list

Audio:
1. No per-monster vocals anywhere — family-level or generic only.
2. No dedicated banshee wail, siren song, or mandrake scream
   (nearest: Horror screams + scared breaths, to layer).
3. No clean real-animal vocal set (Wikimedia hits were mostly human
   imitations — nothing staged rather than poor fits).
4. Movement thin: no wing flaps, slither, swim, or hop sounds.
5. Attacks lack bow, fire-breath, poison-spit, bite-specific sounds.
6. Files selected by pack description + filename, NOT auditioned
   individually — Phase 2 must listen before wiring.
7. Culture families (Greek, Norse, Egyptian, yōkai, Celtic, Slavic,
   Mesopotamian, South Asian, Chinese, Mesoamerican, African),
   celestials, plants, aquatic, sky/storm, elementals: fallback pools
   only, no dedicated vocals.

Models:
8. Nearly every free creature model on OpenGameArt is .blend-only
   (needs a Blender export) or behind itch.io/an account gate.
   Kenney FBX mirrors were the only source meeting all rules.
9. Kenney blocky flat-colour humanoids read chunkier/flatter than
   the live Quaternius look — a style mismatch to manage in Phase 2.
10. No skeleton variants, ghosts, liches, wraiths, banshees, mummies,
    vampires, ghouls, revenants, robed cultists/witches, or armoured
    knights as usable models.

Behavior:
11. Trapper: thinnest archetype — one staged monster (Kobold), zero
    wired mechanics, no trap/disarm rules anywhere.
12. Grappler: hold duration, break-out, damage-while-held, player
    agency while held all unwired.
13. Pure flyer: no staged example — open decision whether bare
    "flyer" survives or flight always pairs with a combat role.
14. Roster-only flavors with no staged reference: controller
    (gaze/petrify/lure/fear/root/sleep), support/summoner, lifedrain,
    splitter, def-shredder, shapeshifter, saboteur, guardian,
    stationary, aquatic movement-medium rules.
15. All behavior-knob values left [OPEN] for Phase 2 tuning.

## Deliberately NOT downloaded (no workarounds attempted)

- itch.io in all forms, including Quaternius packs (Animated Easy
  Enemies, Low Poly Animated Animals, Animated Knight, any LowPoly
  Animated Monsters dragon sibling) and Quaternius-authored items
  mirrored on OpenGameArt — still outstanding, human clickthrough.
- KayKit packs (Adventurers, Skeletons, Character Animations): CC0
  confirmed, but download links route to itch.io — outstanding.
- Kenney glTF variants: kenney.nl download points at the itch.io
  All-in-1 bundle — only FBX OpenGameArt mirrors used.
- Freesound (account required), BBC RemArc (verified
  personal/educational/research only; commercial use needs a separate
  licence — recorded exactly, not relabelled), Sonniss 2026 bundle
  (royalty-free but 7.47 GB with no per-file targets — needs a future
  size-budgeted pass), any paid/paywalled source, any ripped
  game/anime/movie content, anything without a stated licence.

## Best leads for Phase 2 (verified license, NOT downloaded)

- **PS1 Style RPG Enemies** (CC0, CptDrunkBear): 13 .blend enemies +
  textures on disk-inspected zip (bandit, revenant, scorpion,
  cobracon, rattler…). Needs a Blender → glTF/FBX pass. Single
  biggest coverage jump available without a human clickthrough.
- Vampire Bat (CC0, rubberduck), Evil Giant Rat (CC0, CDmir),
  Animated Cerberus (CC-BY 3.0 / CC-BY-SA 3.0 / GPL, pick one),
  snappaKappa (CC-BY 4.0, credit required), Goblin (CC0), Dragon
  (CC0, .3ds, unrigged) — all .blend except the dragon; need export.
- rubberduck pack #1 ("spit" advertised) could not be resolved to a
  direct download URL (page hides the file link; guessed URLs 404'd).

## What Phase 2 still needs

1. James's token verification (the gate for Phase 2 starting).
2. A Blender export pass over the PS1 enemies pack (+ the .blend
   leads) to unlock Brigand, Revenant, Cave Scorpion, serpent
   stand-ins, and more in one consistent style. **Phase 1b update:**
   18 exports done (all 13 PS1 enemies clean; bat/rat/cerberus/
   kappa/goblin with warnings to check in Godot); remaining .blend
   exports (FLARE Daemon, Troll, golems, ghost, skeleton-with-rig)
   + Dragon (.3ds, needs Blender ≤3.6 or Assimp + rigging) still
   pending, with Blender 4.5.3 LTS installed for reuse.
3. The human itch.io clickthrough for Quaternius (and optionally
   KayKit) — the single biggest art unlock; nothing here substitutes
   for it.
4. Auditioning all 670 audio files before wiring (none were
   individually auditioned).
5. Behavior mechanics implementation per the catalog, with all [OPEN]
   knobs tuned against the locked depth curves + a balance soak.
6. Spawn wiring (depth bands, weights, horde weak-only rules) —
   `_pick_type()` still returns slime/bat/skeleton only.
7. James's materials list (still unfilled beyond the three locked
   examples) — drops cannot be finalized until he fills it.
8. A style decision for mixed art families (Kenney blocky vs
   Quaternius vs PS1-style) before shipping models together.

## Declines

No part of this Phase 1 task was declined by any hunter. (The Oct 29
build-session refusals were a separate, earlier attempt and were not
retried here — this hunt was new, narrower work: download + catalog
only.)
