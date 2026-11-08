# Phase 1 Model Catalog — hunted Oct 29, 2026 (STAGED ONLY, no code touched)

Nothing here is wired into the game. No `scripts/` file was modified, no
spawn picker was touched, no build was made. This folder is a resource
stash + honest ledger for Phase 2.

## What was actually downloaded (verified on disk)

**3 packs, 1 shared rig, 12 skins, all Kenney CC0 (see LICENSES.md).**
Every pack contains the same rigged `Model/characterMedium.fbx` plus
three FBX animation files (`Animations/idle.fbx`, `jump.fbx`, `run.fbx`).
Animated: yes — but the clip set is thin: idle, run, and a jump *pose*;
there are no walk, attack, or death clips in these packs. The three
packs' model/animation FBX files are byte-identical in size; only the
skins differ.

| Pack / folder | Skins (4 each) | Roster fit (honest) |
|---|---|---|
| `undead/kenney-animated-characters-1-survivors/` | survivorFemaleA, survivorMaleB, zombieA, zombieC | **Zombie** (Family 6, staged) — zombieA/zombieC. Survivors are humanoid stand-ins (see below). |
| `undead/kenney-animated-characters-3-zombie/` | humanFemaleA, humanMaleA, zombieFemaleA, zombieMaleA | **Zombie** (Family 6, staged) — zombieFemaleA/zombieMaleA. Humans are humanoid stand-ins. |
| `humanoids/kenney-animated-characters-2-protagonists/` | criminalMaleA, cyborgFemaleA, skaterFemaleA, skaterMaleA | **Brigand** (Family 26) — criminalMaleA is the plausible stand-in. Cyborg/skaters are modern-dress and a poor thematic fit; usable only as generic humanoid bases, not as-is roster creatures. |

### Counts by creature type (skins, not distinct rigs)

- Zombie: **4 skins** (2 packs × 2 zombie skins)
- Humanoid stand-ins (Brigand / Grave Robber / Cultist-adjacent, all need
  retexture or acceptance of modern dress): **8 skins**
  (2 survivors + 2 humans + criminal + cyborg + 2 skaters)
- Total distinct creature models downloaded: **3 packs / 1 rig / 12 skins**
- Total files on disk in this folder: 3 packs × (1 model FBX + 3 anim
  FBX + 4 skin PNGs + previews/License.txt) — see each pack folder.

### Style note (honest)

Kenney's blocky, flat-colour humanoid style. It reads chunkier and
flatter than the existing Quaternius low-poly look (smooth, slightly
rounded), so a Kenney zombie next to the live Quaternius slime/bat/
skeleton will look like a different art family. Within the Kenney packs
the style is fully consistent, and all skins share one rig, so
animations are interchangeable across skins. Format note: FBX only in
the OGA mirrors used here. Godot 4 imports FBX, so no conversion step
is needed for the model itself; the missing walk/attack/death clips are
the real animation gap, not the format.

## Families covered vs gaps

Covered (at least one usable skin):
- **The Undead — partially:** Zombie only. No skeleton variants (the
  live Quaternius skeleton already covers Skeleton), no ghosts, liches,
  wraiths, banshees, mummies, vampires, ghouls, or revenants.
- **Humans & the Damned Living — partially, as stand-ins only:**
  Brigand (criminal skin) is plausible; Grave Robber / Cultist /
  Bandit Chief / Witch / Necromancer / Warlock / Fallen Knight have no
  dedicated model — survivor/human skins are generic humans, not those
  roles, and there are no robes, armor, or staff props in these packs.

No Godot-usable model found under this hunt's rules for ANY of:
beasts (wolf, bear, boar, serpent, panther, lion, tiger…), vermin
(rat, spider, wasp, frog, scorpion, centipede…), goblin-kin, orcs /
trolls / giants, demons, dragons / serpents, spirits / fey, golems /
constructs, elementals, aquatic creatures, Greek, Norse, Egyptian,
yōkai, Celtic, Slavic, Mesopotamian, South Asian, Chinese,
Mesoamerican, African, celestials, plants / fungi, sky / storm,
abyssal / cosmic families — and none of the 16 named apex bosses
(Cerberus, Medusa, Typhon, Echidna, Fenrir, Jörmungandr, Surtr, Fafnir,
Baba Yaga, Koschei, Humbaba, Shuten-dōji, Yamata no Orochi, Ravana,
Anzu, Tarasque).

Empty subfolders (`aquatic/`, `beasts/`, `demons/`, `dragons/`,
`elementals/`, `fey/`, `golems/`, `vermin/`) are placeholders for Phase 2
and contain nothing — that is deliberate, not an oversight.

## Why the haul is small (the honest bottleneck)

Nearly every free creature model found on OpenGameArt is a **.blend
file only** (needs a Blender export step — excluded by this hunt's
format rule) or sits behind itch.io / an account gate (forbidden).
The Kenney OGA mirrors were the only source found that is simultaneously
CC0-verified per item, directly downloadable without an account, and
shipped in a Godot-usable format. KayKit and Quaternius packs were NOT
worked around: see "Outstanding (gated)" below.

## Leads (verified license, NOT downloaded — do not use until converted + re-verified)

Conversion-required (.blend only unless noted). License as stated on
each item's own OGA page. A Blender → glTF/FBX export pass would be
needed before any of these can be staged:

- **PS1 Style RPG Enemies** — CC0, author CptDrunkBear,
  https://opengameart.org/content/ps1-style-rpg-enemies — zip inspected
  on disk (1,628,268 bytes): 13 `.blend` enemies + PNG textures
  (bandit, cannae, cereptera, clod, cobracon, helichard, janga,
  myocene, rattler, revenant, scorpion, tardigrade, ungulate). The
  single most valuable lead: bandit → Brigand, revenant → Revenant,
  scorpion → Cave Scorpion, cobracon/rattler → serpents, all in one
  consistent PS1 style. Zip was deleted after inspection; re-download
  from the source page.
- **Vampire Bat (Animated)** — CC0, author rubberduck,
  https://opengameart.org/content/vampire-bat-animated — zip inspected
  (16,497,090 bytes): `bat_v5.blend` only (+ textures, frost variant
  textures). → Vampire Bat (Family 2, D band).
- **Evil Giant Rat** — CC0, author CDmir,
  https://opengameart.org/content/evil-giant-rat — `rat.blend` 6.8 MB,
  rigged + animated. → Giant Rat / Cave Rat (Family 2).
- **Animated Cerberus** — multi-license CC-BY 3.0 / CC-BY-SA 3.0 /
  GPL 3.0 / GPL 2.0 (user picks one), authors Clement Wu, Nikolaus &
  Botanic, https://opengameart.org/content/animated-cerberus —
  `cerberus_v002.blend` only. → Cerberus (apex boss). If used under
  CC-BY 3.0, credit the authors.
- **snappaKappa 3d** — CC-BY 4.0, author MNDV.ecb,
  https://opengameart.org/content/snappakappa-3d — `snappa-kappa.blend`
  724.7 KB, rigged, ~1200 tris. → Kappa (Family 10, staged). Credit
  required under CC-BY 4.0.
- **Goblin** — CC0, author br-n518,
  https://opengameart.org/content/goblin-2 — `goblin.blend` 769.8 KB,
  simple rig. → Goblin (Family 4, staged).
- **Dragon** — CC0, author DrakanFyr,
  https://opengameart.org/content/dragon-3 — `dragon.3ds` 33.8 KB,
  unrigged, unskinned. .3ds is not a Godot-usable format; needs
  conversion AND rigging. → generic dragon (Family 25).
- **lava golem** (OGA) — in the CC0 creatures collection;
  `.blend` only, and its own page notes its textures were
  cgtextures-based and are NOT included (only a glow map is in the
  file). Incomplete + conversion-required. → Magma/Fire Elemental
  area, not a clean golem.
- **Low Poly Animated Character** — CC0, author Anunciatta,
  https://opengameart.org/content/low-poly-animated-character —
  `lowpolyanimatedmodel.blend` 20.6 MB, Mixamo animations (run/walk/
  idle/turn sets). Humanoid base only.
- **Animated daemon** — https://opengameart.org/content/animated-daemon
  — `daemon4.blend` 2.3 MB, rigged, attack/die/idle/spell/walk clips.
  License line did not render in the page fetch; treat as UNVERIFIED
  until its license field is confirmed. Do not use on collection
  membership alone.

Unverified (page fetch lost the metadata — license/format NOT
confirmed, so NOT downloaded and NOT claimed):
- **Tiger Character (.obj)** — title says .obj; appears in CC0
  collections, but its own page's license/file fields did not render.
  Needs a re-check before any use. → Tiger (Family 3, Dp).
- **Wolf** (author Micket, https://opengameart.org/content/wolf-1) —
  comments discuss a multi-license selection including CC0, but the
  file format did not render. → Wolf (Family 3, staged).
- **Animated Defender AKA Brigand** —
  https://opengameart.org/content/animated-defender-aka-brigand —
  description says the original model is CC-BY-3 (Anthony Myers),
  retopologized + animated (walk/run/attack/idle/sleep/dance/die);
  file list did not render, so format is unknown. → Brigand (Family 26).

## Outstanding (gated — deliberately NOT worked around)

- **Quaternius packs** (itch.io clickthrough required): *Animated Easy
  Enemies* (rat, spider, snake, wasp, frogs), *Low Poly Animated
  Animals*, *Animated Knight*, and any dragon sibling in the *LowPoly
  Animated Monsters* line. Quaternius-authored items found mirrored on
  OGA (*5 Low poly animals*, *Animated Animales Low Poly*) were
  deliberately NOT downloaded, per this hunt's no-Quaternius rule.
- **KayKit packs** (download links route to itch.io): *Adventurers*
  (5 rigged/animated characters + accessories, CC0), *Skeletons*,
  *Character Animations* (133 clips). CC0 confirmed on KayKit's own
  site, but the download itself is itch-gated.
- **Kenney glTF variants** of the three installed packs: kenney.nl
  lists glTF among its formats, but the download control found on its
  asset pages points at the itch.io All-in-1 bundle. The OGA mirrors
  used here are FBX-only.

## Method note (for Phase 2)

Sources checked: Kenney (kenney.nl + OGA mirrors), KayKit
(kaylousberg.com), OpenGameArt (CC0 creature/character collections,
per-item pages), Poly Pizza / Icosa (searched, no usable direct model
URL surfaced), BlendSwap (CC0 items found are .blend-only).
Forbidden sources were not used: itch.io, Sketchfab / account-gated
sites, paid sources, ripped game/anime/movie models, unlicensed items.
Every installed file was HEAD-checked for size, downloaded with curl,
and confirmed by `file` + zip listing before being copied into this
folder. No game code was touched.

---

# Phase 1b — Expanded creature-model hunt (Oct 29, 2026, STAGED ONLY)

James's brief: Kenney blocky humanoids are fine for a zombie or a
brigand, but nobody wants a human form standing in for a kobold or a
bugbear. This hunt found creature-true models in a stylized low-poly
fantasy look close to the game's Quaternius-style models. No game code
touched, no build, no release. Per-hunter ledgers (the authoritative
detail):
- `phase1b-ps1-ledger.md` (PS1 pack + .blend leads + Blender exports)
- `phase1b-oga-ledger.md` (OpenGameArt family searches)
- `phase1b-wide-ledger.md` (Gobkit + 3DAssets.dev + wider web)

## What landed (verified on disk; models/ totals ~181 MB)

**Godot-usable as-is (GLB/FBX/OBJ, no conversion needed):**
- **Gobkit curated, CC0, 48 GLB** (animated, skinned, one consistent
  style — the closest match to the Quaternius look in this hunt):
  beasts (Bat, Rat, Boar, Bull, Dingo, Eagle, Fox, Lion, Mole, Owl,
  SkullDeer, Tiger, TasmanianDevil, MerinoRam, Mouflon), vermin
  (Scorpion, Bee, 3 stag beetles, LeafcutterAnt, SoldierTermite,
  Cockroach, AntlionLarva), **10 orcs** (Legionary, IronGuard,
  ShieldBearer, LegionArcher, LegionCommander, WarbandChampion,
  WarShaman, WarDrummer, ChainBrute, Pyromancer), undead (SheetGhost,
  TombMummy, VampireCountess, WerewolfCaptain, StitchedBrute),
  goblin-kin minions ×4 (generic small-creature stand-ins, NOT goblin
  reads), PumpkinScarecrow, NightWitch, Anglerfish, Shark, Jellyfish.
  Attribution (welcome, not required): "Characters by Gobkit —
  https://gobkit.com".
- **Gobkit community, CC0, 12 GLB** (animated, skinned): FattyImp (a
  real imp), Wyvern ×2, GeodeCentipede (a real centipede), Mantis,
  TrapBear (real bear), IroncladBoar (Razorback), GeodeSilverback
  (Cave Ape), ThunderBeakGryphon (real gryphon), BrazenMinotaur (a
  real minotaur), AmberElderwood + Treant (tree spirits — Treant
  MUST be used only under the roster name Walking Oak / Elder Tree;
  the roster deliberately avoids "Treant" as a D&D coinage dodge).
  Per-file attribution in the wide ledger (creator + Gobkit page).
- **3DAssets.dev, CC0, 8 GLB** — PROVENANCE FLAG: these are
  AI-generated by the site itself, no human author named; license is
  clean CC0 either way, but James may want to weigh AI-generated
  assets separately. WesternDragon + EasternDragon (static),
  CornSnake (static, Giant Serpent stand-in), GoblinScavenger (a
  real goblin, thin animation), SkeletonWarrior (thin animation),
  StoneGardenGolem (static, 896 tris), CityWolf (a real wolf, thin
  animation), CellarSpider (static, a real spider).
- **Blender exports, 18 GLB** (from the PS1/.blend leads below):
  all 13 PS1 enemies exported cleanly; bat, rat, cerberus, kappa,
  goblin exported with non-fatal warnings recorded in the PS1 ledger
  (Phase 2 must check them in Godot). Blender 4.5.3 LTS portable
  installed at `~/workspace/tools/blender-4.5.3-linux-x64/` (1.2 GB,
  separate from models/) for Phase 2 reuse.
- **Direct Godot-usable from OGA:** Bone Golem (OBJ + texture),
  Skeleton Outlaw (FBX + 14 animation FBXs — best animation set in
  the haul), Crossbowman Skeleton (OBJ, skeleton-archer slot, static
  — needs rigging).

**Staged as .blend (export pending, Phase 2 step):** PS1 pack sources
(13 .blend + textures, CC0), FLARE Daemon (CC0, idle/walk/attack/cast/
flinch/die), Troll (CC-BY 3.0), Fire/Ice/Stone Golem, Pirate Crewman
Ghost (CC-BY 3.0), Skeleton with rig (CC0, old Blender 2.49 — confirm
it opens), plus the .blend originals behind the 18 exports above.
Dragon remains **.3ds-only** (Blender 4.5.3 has no 3DS importer —
needs Blender ≤3.6 or Assimp, plus rigging; it is unrigged/unskinned).

**DEDUPLICATION NOTE:** the PS1 pack, Vampire Bat, Evil Giant Rat,
Goblin, Cerberus, snappaKappa, and Dragon were staged by two hunters
under different paths (e.g. top-level `ps1-style-rpg-enemies/` vs
`vermin/ps1-style-rpg-enemies/`). The files are the same source
assets, not different models. Canonical copies for Phase 2: the
PS1-ledger paths (which carry the .glb exports); the OGA-ledger
duplicates are the same sources and may be pruned in Phase 2.

## Coverage improvements vs Phase 1 (creature-true models, first time)

NEWLY COVERED: Wolf (true wolf), Cave Spider, Cave Scorpion,
Centipede, Stag Beetle, Lion, Tiger, Bear, Razorback, Cave Ape,
Gryphon, Minotaur, Orc (+ 9 variants), Goblin (true goblin),
Imp, Drake/Wyvern (×2), Dragon (×2, static), Giant Serpent (static),
Ghost/Wraith, Mummy, Vampire, Werewolf, Skeleton Warrior variant,
Stone Golem (static), Scarecrow construct, Witch, Walking Oak /
Elderwood, Shark, Anglerfish, Jellyfish, plus beast/vermin filler
(rat, boar, bull, ram, mole, deer, beetles, ants, termites, mantis).

STILL MISSING a creature-true model: **Troll** (orcs found, troll
not), demons beyond Imp, spirits beyond Ghost (no banshee/wisp/
shade), animated serpents/dragons with full clips (wyverns are the
only animated draconics), animated golems beyond static ones,
Skeleton Archer (Crossbowman is static, needs rigging), true Zombie
beyond Kenney skins, Banshee, Lich, Ghoul, Revenant (PS1 revenant
covers the slot — see below), Goblin variants (Shaman, Sneak,
Hobgoblin, Bugbear, Kobold — minions are generic stand-ins, NOT
goblin-kin reads), true Wasp (Bee is a stand-in), Frog, Oni, Kappa
(PS1-ledger .glb exists — sibling workstream set), elementals,
celestials, sky/storm, abyssal/cosmic families, and 15 of the 16 apex
bosses (Cerberus is the only apex model staged).

NOTE — PS1 Revenant: the PS1 pack's revenant is a creature-true
undead model that covers the Revenant slot; it was counted above
under the PS1 set, not under "missing."

## Copyleft / confirmation flags — ELECTIONS CONFIRMED Oct 29, 2026

- Animated Cerberus (Clement Wu, Nikolaus & Botanic): multi-license
  CC-BY 3.0 / CC-BY-SA 3.0 / GPL 3.0 / GPL 2.0 — election **CC-BY 3.0**
  (attribution only, no copyleft) CONFIRMED by James Oct 29, 2026.
  Use to its fullest extent under attribution-only terms.
- Fire/Ice/Stone Golem: CC-BY 3.0 / CC-BY-SA 3.0 dual — election
  CC-BY 3.0 CONFIRMED by James Oct 29, 2026.
- Bone Golem: CC-BY 3.0 / GPL 3.0 dual — election CC-BY 3.0
  CONFIRMED by James Oct 29, 2026.
- No staged file REQUIRES a copyleft license; the three flags above
  are about confirming the non-copyleft election, not adopting
  share-alike terms.

## Deliberately NOT downloaded in Phase 1b

- itch.io in all forms (Quaternius, KayKit, LOWPO goblins, Kenney
  itch.io bundle, free skeletons/zombies) — still outstanding on a
  human clickthrough, not worked around.
- Sketchfab (account gate — CC dragons listed as leads only; one
  suspect re-upload rejected on the unauthorized-mirror rule).
- FLARE Skeleton Knight/Occultist (page says CC-BY 3.0 but shipped
  files reportedly embed a GPL/CC-BY-SA base-model notice — license
  conflict must be resolved first).
- Second-batch 3DAssets.dev marginal hits (static wyvern poses,
  static ghosts, static bat, jointed boar, realistic grizzly, Kraken
  Tentacle prop) — duplicates of better animated models already held.
- Gobkit "coming soon" (Skeleton Warrior, Imp Fiend, Orc Bruiser,
  Human Knight, Sprite) — not yet downloadable; worth re-checking.
- Gobkit community wall beyond the first 24 published items —
  re-check before commissioning anything.
