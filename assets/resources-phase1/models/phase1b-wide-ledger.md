# Phase 1b Wide Ledger — creature models hunted beyond OpenGameArt (Oct 29, 2026)

**STAGED ONLY. No game code changed, no build, no APK, no release, no spawn
picker touched.** This ledger covers ONLY the files staged by this hunt
(Phase 1b-wide). It does not catalog Phase 1's Kenney packs (see
`CATALOG.md` / `LICENSES.md` in this folder) and it does not catalog 18
`.glb` files that appeared under `models/` during this session from a
sibling export workstream (PS1 enemies, Cerberus, Vampire Bat, Giant Rat,
Kappa, Goblin conversions) — those belong to that workstream's ledger,
not this one. Total `.glb` files under `models/` at ledger time: 86 =
68 (this hunt) + 18 (sibling workstream).

**Credits rule:** game credits use the pseudonym **Aethelwarden Solas**
only — never the developer's real name. Attribution strings below name
the *asset creators*, not the developer, and are recorded even where the
license does not require credit (per this hunt's rules: credit ALL
creators including CC0).

## Haul summary

| Source | Files staged | Format | License | Total size |
|---|---|---|---|---|
| Gobkit curated packs (gobkit.com/freebies, via api/free manifest) | 48 | GLB (glTF 2.0, animated, skinned) | CC0 1.0 | — |
| Gobkit community library (gobkit.com/api/community, published items only) | 12 | GLB (glTF 2.0, animated, skinned) | CC0 1.0 | — |
| 3DAssets.dev (item API + item pages) | 8 | GLB (glTF 2.0; 3 animated-ish, 5 static) | CC0 1.0 | — |
| **Total, this hunt** | **68** | **GLB only** | **All CC0** | **21,754,748 bytes (~20.7 MiB)** |

Every staged file was verified on disk: `glTF` magic bytes present and
the GLB JSON chunk parsed for animation-clip names (clip names in the
tables below come from that parse, not from marketing copy). No file in
this hunt is `.blend`-only, so no Blender export step is needed for any
of them — but see the "Static / thin-animation" notes: several
3DAssets.dev files have no animation clips at all.

**Style note (honest):** Gobkit models are stylized low-poly with baked
flat colours — the closest match in this hunt to the game's
Quaternius-style look, and mutually consistent. The 3DAssets.dev models
are a second style family (hand-painted fantasy for the Goblin /
Skeleton / Wolf; more realistic for the Corn Snake; plain static meshes
for the dragons/golem/spider). A Gobkit orc next to a 3DAssets.dev goblin
will not look like one art family. Within Gobkit, curated and community
models are consistent enough to mix.

**No copyleft in this hunt.** Nothing staged is CC-BY-SA or GPL, so no
copyleft decision is pending on staged files. (One Phase 1 lead, the
Animated Cerberus, carries a multi-license including CC-BY-SA/GPL — it
is NOT staged here; see the sibling-workstream note above.)

## 1. Gobkit curated packs — 48 files, CC0

Source pages verified Oct 29, 2026: https://gobkit.com/freebies states
"CC0 1.0 Universal — public domain… No watermark, no attribution
required" and suggests the credit `Characters by Gobkit —
https://gobkit.com`. The pack zips ship a `LICENSE.txt` with the same
CC0 text; a copy is stored at `gobkit-LICENSE-CC0.txt` in this folder.
Downloads used the manifest at https://gobkit.com/api/free (no account,
no key, direct `.glb` URLs, verbatim from the manifest). Attribution
string for every curated file (credit welcome, not required):

> **Characters by Gobkit — https://gobkit.com**

Clip-name conventions (verified by parsing each GLB): animal packs use
lowercase `idle / attack / dead / walk`; insect packs add many extra
clips (`groom, alert, run, crawl, jump, fly, sting, eat, threat, hit,
perch, buzz, sing, carry, dart, sway, curl, pounce, flip` and, for the
Vol.2 beetles, `turnL, turnR, back, sense, sleep, tripod, push, dig`);
character packs (orcs, undead, witch, scarecrow) use capitalized
`Idle / Walk / Run / Attack / Hit / Death / Special`; minions use
`idle / attack / dead` (no walk clip).

### 1a. Beasts — `beasts/gobkit/` (15)

| File | Roster creature / family | Notes |
|---|---|---|
| `Bat.glb` (96,720 B) | Cave Bat (Family 2, T) / Vampire Bat (Family 2, D) as a variant use | Generic bat; reads as a bat. Clips: idle/attack/dead/walk |
| `Rat.glb` (155,092 B) | Cave Rat / Giant Rat (Family 2, T) | Scale up for Giant Rat |
| `Boar.glb` (164,240 B) | Wild Boar (Family 3, T, staged) | |
| `Bull.glb` (100,552 B) | Grotto Bull (Family 3, D) | |
| `Dingo.glb` (93,868 B) | Warhound STAND-IN (Family 3, D) | A dingo reads as a canine, not specifically a wolf — do not label it Wolf/Dire Wolf without the stand-in caveat |
| `Eagle.glb` (90,572 B) | Non-roster bird flyer (Family 3, generic) | NOT a Harpy — a bird, filed as filler only |
| `Fox.glb` (95,328 B) | Non-roster beast filler (Family 3, generic) | No fox in the roster; usable as generic beast |
| `Lion.glb` (99,328 B) | Lion (Family 3, D) | |
| `MerinoRam.glb` (103,060 B) | Crag Ram (Family 3, D) | Ram; either ram file works — two coat variants staged |
| `Mouflon.glb` (96,376 B) | Crag Ram (Family 3, D) | Second ram variant |
| `Mole.glb` (99,776 B) | Blind Mole (Family 3, D) | |
| `Owl.glb` (156,676 B) | Non-roster bird flyer (Family 3, generic) | Filler only, as with Eagle |
| `SkullDeer.glb` (98,396 B) | Deep Stag (Family 3, D) | Antlered deer with a skull head — spooky variant read; acceptable for Deep Stag, not for an ordinary deer |
| `TasmanianDevil.glb` (100,388 B) | Non-roster beast filler (Family 3, generic) | |
| `Tiger.glb` (106,812 B) | Tiger (Family 3, Dp) | |

### 1b. Vermin — `vermin/gobkit/` (9)

| File | Roster creature / family | Notes |
|---|---|---|
| `Scorpion.glb` (104,708 B) | Cave Scorpion (Family 2, T, staged) | |
| `Bee.glb` (156,888 B) | Cave Wasp STAND-IN (Family 2, T) | A bee reads as a stinging flyer, not a wasp — stand-in caveat applies |
| `HerculesBeetle.glb` (357,672 B) | Stag Beetle (Family 2, D) | Large beetle; any of the three beetles works |
| `GiraffeStagBeetle.glb` (406,980 B) | Stag Beetle (Family 2, D) | Literally a stag beetle (Vol.2 clip set) |
| `GoldenStagBeetle.glb` (407,632 B) | Stag Beetle (Family 2, D) | Literally a stag beetle (Vol.2 clip set) |
| `LeafcutterAnt.glb` (360,436 B) | Ant swarm vermin filler (Family 2, generic) | Swarm presentation, not a named roster entry |
| `SoldierTermite.glb` (352,160 B) | Termite swarm vermin filler (Family 2, generic) | As above |
| `Cockroach.glb` (358,796 B) | Vermin filler (Family 2, generic) | |
| `AntlionLarva.glb` (359,360 B) | Burrow Worm STAND-IN (Family 2, D) | A burrowing ambusher larva — reads as a burrower, not a worm; stand-in caveat applies |

### 1c. Orcs & Trolls — `orcs-trolls/gobkit/` (10, new folder)

All 10 use the capitalized character clip set (Idle/Walk/Run/Attack/Hit/
Death/Special). All are orcs — no troll model was found in Gobkit's
curated set, so Troll (staged placeholder) is still unmodelled.

| File | Roster creature / family | Notes |
|---|---|---|
| `OrcLegionary.glb` (481,520 B) | Orc (Family 5, D, staged) | The baseline orc |
| `OrcIronGuard.glb` (658,804 B) | Orc guard variant (Family 5) | |
| `OrcShieldBearer.glb` (477,492 B) | Orc guard variant (Family 5) | |
| `OrcLegionArcher.glb` (514,468 B) | Orc archer variant (Family 5) | Ranged orc; no named roster archer, but an orc-family variant |
| `OrcLegionCommander.glb` (570,372 B) | Orc Champion / leader variant (Family 5) | |
| `OrcWarbandChampion.glb` (542,276 B) | Orc Champion (Family 5) | |
| `OrcWarShaman.glb` (594,324 B) | Orc Shaman variant (Family 5) | Caster orc |
| `OrcWarDrummer.glb` (580,912 B) | Orc support variant (Family 5) | Drummer = support/bard read |
| `OrcChainBrute.glb` (382,564 B) | Orc Berserker (Family 5, D) | Brute read |
| `OrcPyromancer.glb` (419,368 B) | Orc caster variant (Family 5) | Fire-caster orc |

### 1d. Undead — `undead/gobkit/` (5)

| File | Roster creature / family | Notes |
|---|---|---|
| `SheetGhost.glb` (245,452 B) | Ghost / Wraith (Family 6; Wraith staged) | Sheet-ghost read — cartoonish, but unmistakably a ghost |
| `TombMummy.glb` (559,852 B) | Mummy (Family 6) | |
| `VampireCountess.glb` (421,868 B) | Vampire (Family 6) | |
| `WerewolfCaptain.glb` (531,104 B) | Werewolf (Family 6) | |
| `StitchedBrute.glb` (400,120 B) | Zombie brute / Flesh Golem (Family 6; golem-adjacent) | Filed under undead; a stitched-together brute also works as a flesh construct — decide at wire-up time |

### 1e. Goblin-kin, constructs, humanoids, aquatic — curated (10)

| File | Roster creature / family | Notes |
|---|---|---|
| `goblin-kin/gobkit/minion-a01.glb` (188,700 B) | Generic small-creature STAND-IN for Goblin / Imp | Minions are blobby little creatures, NOT goblins — they do not read as "goblin" specifically. Use only where a generic small creature is acceptable. Clips: idle/attack/dead (no walk) |
| `goblin-kin/gobkit/minion-b01.glb` (192,392 B) | Same stand-in note as a01 | Body type B |
| `goblin-kin/gobkit/minion-c01.glb` (169,072 B) | Same stand-in note as a01 | Body type C |
| `goblin-kin/gobkit/minion-d01.glb` (207,680 B) | Same stand-in note as a01 | Body type D |
| `golems/gobkit/PumpkinScarecrow.glb` (647,348 B) | Scarecrow construct (Golems & Constructs) | Pumpkin-head scarecrow; seasonal look — construct read is clear |
| `humanoids/gobkit/NightWitch.glb` (335,388 B) | Witch (Humans & the Damned Living) | Living humanoid, not undead — filed under humanoids deliberately |
| `aquatic/gobkit/Anglerfish.glb` (91,052 B) | Deep aquatic creature (Aquatic family) | |
| `aquatic/gobkit/Shark.glb` (95,028 B) | Shark (Aquatic family) | |
| `aquatic/gobkit/Jellyfish.glb` (100,384 B) | Jellyfish (Aquatic family) | |

Not staged from Gobkit curated (deliberate): all modern-human packs
(office, medical, police, army, firefighter, etc.), farm animals
(cows/pigs/sheep), dinosaurs (no dinosaurs in the roster), birds beyond
Eagle/Owl, and the Nature Kit props (not creatures). Minion variants
a02–d02 (second colourway of each body type) were also left out — the
four body types staged already cover the stand-in use.

## 2. Gobkit community library — 12 files, CC0

Source verified Oct 29, 2026: https://gobkit.com/api/community returns
`published` items only by default, each with `license: "cc0"`,
`download_available: true`, and a per-item page. The freebies page
states the community library is "also CC0, and also downloadable as
`.glb`", human-reviewed. Clips on community models are
`idle / move / attack` (note `move`, not `walk`, and no `dead` clip —
except Treant, which also has `roar`). Attribution string per file
(credit welcome, not required by CC0):

> **"[Title]" by [creator] — Gobkit community library (CC0) — [page URL]**

| File | Creator / page | Roster creature / family | Notes |
|---|---|---|---|
| `demons/gobkit-community/FattyImp.glb` (132,540 B) | RADQnico — https://gobkit.com/s/hsw2pt996rvv | Imp (Demons, T, staged) | A real imp — the demon family's only model in this hunt |
| `dragons/gobkit-community/Wyvern.glb` (912,048 B) | ak — https://gobkit.com/s/9tx8dw8ekt6a | Drake / Wyvern (Dragons, D, staged Drake) | Winged draconic creature; 7,122 tris |
| `dragons/gobkit-community/BelfryWyvern.glb` (385,128 B) | TUTU — https://gobkit.com/s/26vqs7uuaahq | Drake / Wyvern variant (Dragons) | Second wyvern read |
| `vermin/gobkit-community/GeodeCentipede.glb` (344,624 B) | ak — https://gobkit.com/s/3brigvwdxqc3 | Centipede (Family 2, T, staged) | A real centipede |
| `vermin/gobkit-community/Mantis.glb` (358,512 B) | Linus — https://gobkit.com/s/w637mbvvd3ah | Non-roster insect predator filler (Family 2, generic) | Mantis, not a named roster entry |
| `beasts/gobkit-community/TrapBear.glb` (217,228 B) | TUTU — https://gobkit.com/s/nfc4njn6w5zq | Grizzly / Cave Bear (Family 3) | A real bear |
| `beasts/gobkit-community/IroncladBoar.glb` (788,596 B) | Ariescar — https://gobkit.com/s/tiyqrn5net27 | Razorback (Family 3, D) | Armoured boar — the "scarred boar whose charges dent stone" read |
| `beasts/gobkit-community/GeodeSilverback.glb` (467,484 B) | Alice Liu — https://gobkit.com/s/yxea3wajq9f6 | Cave Ape (Family 3, D) | Ape read |
| `beasts/gobkit-community/ThunderBeakGryphon.glb` (336,584 B) | Alice Liu — https://gobkit.com/s/znzn64bqypck | Gryphon (Greek & Mediterranean Myth) | Eagle/lion gryphon read |
| `beasts/gobkit-community/BrazenMinotaur.glb` (654,372 B) | Alice Liu — https://gobkit.com/s/gyn4rhpenihc | Minotaur (Greek, D, staged) | A real minotaur |
| `fey/gobkit-community/AmberElderwood.glb` (412,732 B) | Linus — https://gobkit.com/s/nrtrmd66v835 | Tree spirit / Elder Tree (Fey & Nature Spirits) | Walking-tree read |
| `fey/gobkit-community/Treant.glb` (1,228,240 B) | Ariescar — https://gobkit.com/s/nwskt6hjiqi5 | Walking Oak (Fey & Nature Spirits) — RENAME REQUIRED | The file is titled "Treant", but the roster deliberately avoids the name "Treant" (D&D coinage dodge; see monster-roster-2026-10.md). Use only under the roster name Walking Oak / Elder Tree. Has a `roar` clip plus idle/move/attack; the only community file with an embedded texture (1024×1024) |

Community items checked but NOT staged (24 published at check time):
Scholar Swordsman (human — out of scope), Sanctum-Glass Ossuary Snail,
Tortoise, Vent Crab, Scarlet Crab, Tectonic Pangolin, Obsidian Manta,
Hearth (ambiguous title, not examined as a creature), Razor Avian,
Ballista Ceratopsian (dinosaur-adjacent), Drakebearer (ambiguous —
humanoid carrying something, not examined as a creature), Armored Frost
Mammoth, Geode Silverback's companions — see staged list above. The
community wall keeps growing; re-check it for demon/dragon/golem gaps
before commissioning anything.

## 3. 3DAssets.dev — 8 files, CC0 (AI-generated — read the provenance note)

Source verified Oct 29, 2026 via the site's public item API
(`https://3dassets.dev/api/v1/assets?q=…`) and each item's record: every
item below carries `license: CC0 1.0 Universal, attributionRequired:
false`, `contributor: 3D Assets`, and `aiGenerated: true`. The site's
FAQ states every model is CC0, no account, direct `.glb` download.
**Provenance flag (not a license flag):** these models are
AI-generated by the site itself and carry no human author name — the
attribution string is therefore the site, not a person. James may want
to weigh AI-generated assets separately from human-authored CC0; the
license itself is clean CC0 either way. Downloads used the item
`cdnUrl` values verbatim from the API records. Attribution string for
every 3DAssets.dev file:

> **3D Assets (3dassets.dev) — CC0 1.0, AI-generated model, no human author named on the item page — [item page URL]**

| File | Item page | Roster creature / family | Animation state (parsed from GLB) |
|---|---|---|---|
| `dragons/3dassets/WesternDragon.glb` (198,252 B) | https://3dassets.dev/assets/dragons-and-wyverns-western-dragon-wings-spread-8d633362 | Dragon, generic (Dragons, Dp) | STATIC — no clips. Pose model; needs animation or static use |
| `dragons/3dassets/EasternDragon.glb` (166,884 B) | https://3dassets.dev/assets/dragons-and-wyverns-eastern-dragon-flying-bc200fcb | Serpentine dragon / Great Serpent variant (Dragons) | STATIC — no clips |
| `dragons/3dassets/CornSnake.glb` (103,764 B) | https://3dassets.dev/assets/pets-and-companions-hd-corn-snake-8a83dce6 | Giant Serpent / Cave Python (Family 3, staged Giant Serpent) | STATIC — no clips. Realistic corn-snake pattern; scaled up it reads as a serpent, but it is not a stylized cave python |
| `goblin-kin/3dassets/GoblinScavenger.glb` (352,628 B) | https://3dassets.dev/assets/fantasy-mmo-city-and-townsfolk-goblin-scavenger-35af904a | Goblin (Family 4, T, staged) | THIN — `idle, head-turn, arm-swing, weapon-raise` only; no walk/attack/death. A real goblin (green, hooded, club) — the best true-goblin model in this hunt |
| `undead/3dassets/SkeletonWarrior.glb` (424,280 B) | https://3dassets.dev/assets/fantasy-mmo-city-and-townsfolk-skeleton-warrior-599467cf | Skeleton Warrior variant (Family 6; live Quaternius Skeleton already covers base Skeleton) | THIN — `idle, head-turn, arm-swing, weapon-raise` only |
| `golems/3dassets/StoneGardenGolem.glb` (89,436 B) | https://3dassets.dev/assets/runestone-conservatory-stone-garden-golem | Stone Golem / Clay Golem variant (Golems, D, staged Clay Golem) | STATIC — no clips. Only 896 tris; simple garden-golem read |
| `beasts/3dassets/CityWolf.glb` (101,180 B) | https://3dassets.dev/assets/fantasy-mmo-city-and-townsfolk-city-wolf-571ed42b | Wolf (Family 3, T, staged Cave Wolf) | THIN — `idle, head-turn, tail-wag` only; no walk/attack/death. A real wolf — the only true wolf in this hunt (Gobkit's Dingo is a stand-in) |
| `vermin/3dassets/CellarSpider.glb` (150,880 B) | https://3dassets.dev/assets/hollowwick-halloween-long-legged-spider-47c29be1 | Cave Spider (Family 2, T, staged) | STATIC — no clips. A real spider; long-legged cellar-spider read |

3DAssets.dev searches that returned nothing usable: `demon` (results
were lemons, sharks, and jelly characters — the search matches loosely),
`golem` beyond the one above, and a second spider (orb weaver) that was
left out to keep the haul to one spider. The site's "Fantasy MMO City
And Townsfolk" set is the one worth re-checking first for future
humanoid monsters.

## 4. Families covered vs still missing (after this hunt + Phase 1)

Covered with a creature-true model by this hunt (first model for the
creature, not a stand-in): Wolf, Lion, Tiger, Blind Mole, Crag Ram,
Grotto Bull, Deep Stag, Grizzly/Cave Bear, Razorback, Cave Ape,
Gryphon, Minotaur, Cave Spider, Cave Scorpion, Stag Beetle, Centipede,
Orc (+ 9 orc variants), Goblin (true goblin, thin animation), Imp,
Drake/Wyvern (×2), Dragon (×2, static), Giant Serpent (static snake),
Ghost/Wraith, Mummy, Vampire, Werewolf, Skeleton Warrior variant,
Stone Golem (static), Scarecrow construct, Witch, Walking Oak
(renamed Treant), Elderwood, Shark, Anglerfish, Jellyfish.

Still missing a creature-true model (stand-in only, or nothing):
- **Troll** (orc family staged, troll still placeholder — no troll found)
- **Demons beyond Imp** (no big demon, devil, or demon lord — the demon family is one small imp)
- **Spirits beyond Ghost** (no banshee, wisp, or shade variant — SheetGhost is the only spirit)
- **Serpents beyond one static snake** (no animated serpent/dragon with walk/attack/death; the wyverns are the only animated draconics)
- **Golems beyond two** (no clay/iron/fire golem with animation; StoneGardenGolem is static, PumpkinScarecrow is seasonal)
- **Skeleton Archer, Zombie (true zombie model beyond Kenney skins), Banshee, Lich, Ghoul, Revenant** — undead variants still thin
- **Goblin variants** (Shaman, Sneak, Hobgoblin, Bugbear, Kobold) — one true goblin only; the minions are generic stand-ins, not goblin-kin reads
- **Vermin**: no true wasp (Bee is a stand-in), no frog, no rat swarm presentation beyond single Rat
- **Yōkai**: no Kappa/Oni model staged here (Phase 1's Kappa lead is a `.blend` in the sibling workstream's set)
- **Elementals, celestials, plants/fungi beyond tree creatures, sky/storm, abyssal/cosmic** — untouched by this hunt

## 5. Leads verified but NOT downloaded (with reason)

### 5a. itch.io-gated — NOT downloaded, per this hunt's rules

- **Kenney — Cube Pets** (kenney.nl/assets/cube-pets): CC0 verified on
  Kenney's own page (License: Creative Commons CC0, 3D, animation,
  24 files, v2.0 remake with animals & animations). The page's Download
  control routes to `kenney.itch.io` (All-in-1 bundle). **Gated — not
  downloaded.** Creature value if a human completes the clickthrough:
  cube pets (dog/cat etc.) — pet animals, not fantasy monsters.
- **Kenney — Mini Dungeon** (kenney.nl/assets/mini-dungeon): Download
  control also routes to `kenney.itch.io`. License/tags did not render
  in the page fetch, and creature content is unverified — **gated and
  unverified, not downloaded.**
- **Kenney generally:** every kenney.nl pack page checked routes its
  Download control to the itch.io All-in-1 bundle. That includes the
  Voxel Pack (190 voxel models: characters, vehicles, buildings, props
  — voxel animals not individually verified). No kenney.nl pack was
  downloaded in this phase for that reason. (Phase 1 used OpenGameArt
  mirrors for the Animated Characters packs instead; this phase did not
  re-mirror Kenney packs.)
- **KayKit — Character Pack: Skeletons** (Godot Asset Library asset
  2566, https://godotengine.org/asset-library/asset/2566): library page
  states 4 stylised low-poly skeleton characters, fully rigged and
  animated, 90+ animations, 10+ accessories, "Free for personal and
  commercial use, no attribution required. (CC0 Licensed)". The
  library page text does not expose the download destination, and
  KayKit downloads are outstanding on a human clickthrough per this
  hunt's brief — **not downloaded, not worked around.** Same standing
  applies to all other KayKit packs (Adventurers, Character Animations).
- **Quaternius packs** (Animated Easy Enemies, Low Poly Animated
  Animals, Animated Knight, dragon siblings): CC0, but download
  requires an itch.io clickthrough — **outstanding, not worked around,
  per the brief.** No Quaternius file was downloaded in this hunt, and
  no Quaternius mirror (OpenGameArt, aggregator, or otherwise) was used
  to bypass the gate.
- **LOWPO: Goblin Assets** (Standout 7, itch.io): 7 stylised low-poly
  goblins, rigged, game-ready, listed free — **itch.io-gated, not
  downloaded.** Would be the single best goblin-kin fill if a human
  completes the clickthrough.
- **LOWPO: Low Poly Elf Characters Pack — free version** (Standout 7,
  itch.io): 3 rigged elves, FBX — **itch.io-gated, not downloaded**
  (elves are humanoids, not roster creatures in any case).
- **Free Animated Cartoon Low-Poly Skeleton** (Overaction Game Studio,
  itch.io) and **Free Stylized Dark Fantasy Skeleton / Zombie**
  (Hotstrike Studio, itch.io): free, rigged — **itch.io-gated, not
  downloaded.**
- **Gobkit itch.io mirrors** (gobkit.itch.io): Gobkit's own page notes
  the same five packs are mirrored on itch.io with identical files and
  identical CC0 terms — irrelevant here, because the gobkit.com direct
  route was used instead. Listed only so nobody re-downloads them via
  itch.io by mistake.

### 5b. Godot Asset Library — checked, nothing staged

- The Godot Asset Library's creature-model pickings are thin: most
  "3D" addons are tools, controllers, shaders, or templates, not
  monster packs. The two relevant findings are the **Icosa Gallery
  addon** (a Godot 4.5+ plugin that browses the Icosa Gallery catalog
  and downloads glTF/OBJ in-editor; login is described as fetching a
  personal/liked library, not as a requirement to browse) and the
  **KayKit Skeletons listing** above. No addon was installed and no
  model was staged through the Asset Library in this hunt — installing
  an addon would be a project change, outside this hunt's
  hunt+stage-only scope. Icosa Gallery (icosa.gallery) itself was
  searched for dragon/goblin/skeleton/demon/golem models, but no
  per-model direct-download URL surfaced in this hunt's searches, so no
  Icosa model is claimed or staged here; the Icosa Gallery addon is
  the documented route for a future in-editor pass.
- Poly Pizza (poly.pizza, 10,600+ models, mostly CC-BY per its
  coverage): searched for wolf/dragon/goblin/skeleton models — no
  per-model page with a verified license and direct download surfaced
  in this hunt's searches, so **nothing staged from Poly Pizza**.
  It remains a credible next source for a human pass (CC-BY credit
  would be required per model), not a verified haul.

### 5c. Sketchfab — CC verified, account-gated: leads only, NOT downloaded

Per the brief, Sketchfab items count only where the license is CC AND
a direct download is possible without an account. Sketchfab downloads
require a signed-in account, so these are leads only:

- **Low Poly Ice Dragon** by Ethan McGuirk — CC Attribution, 12.6k
  tris, animated breathing, made as a game boss:
  https://sketchfab.com/3d-models/low-poly-ice-dragon-a7d5dc0fb7d846299cad4c3cf4acbe4d
- **Low Poly Dragon** by louieoliva — CC Attribution, 2.3k tris,
  Blender-made, game-ready:
  https://sketchfab.com/3d-models/low-poly-dragon-91836e765d764e098a98a8069d64efc9

**Rejected, not a lead:** "Red dragon" by M.FARHAN (CC Attribution
shown) carries a comment stating its models are from the Microsoft 3D
library — a possible unauthorized re-upload. **Do not use** until that
provenance is resolved; it is excluded on the unauthorized-mirror rule.

### 5d. Other leads and watch items

- **Gobkit "coming soon"** (shown on gobkit.com/freebies, not yet
  downloadable): Skeleton Warrior, Imp Fiend, Orc Bruiser, Human
  Knight, Sprite — all labelled "Rigged Animated Low-Poly". Worth
  re-checking: a curated Gobkit Skeleton Warrior and Imp Fiend would
  upgrade two thin spots in this haul. Nothing was downloaded for
  these; they do not exist as free files yet.
- **Gobkit community wall**: only the first 24 published items were
  reviewed (see §2). The wall grows; later items may cover demons,
  golems, or serpents.
- **3DAssets.dev "Fantasy MMO City And Townsfolk" set**: the source of
  the Goblin, Skeleton, and Wolf staged here — re-check this set first
  for future humanoid monsters (same CC0 terms, same thin-animation
  caveat).
- **Phase 1 `.blend` leads** (PS1 Style RPG Enemies, Vampire Bat,
  Evil Giant Rat, Goblin, snappaKappa, Cerberus): NOT re-downloaded
  here — a sibling export workstream has since staged converted
  `.glb` versions of these under `models/` (18 files, see header).
  The Cerberus item's multi-license (CC-BY 3.0 / CC-BY-SA 3.0 / GPL
  3.0 / GPL 2.0, user picks one) still needs a copyleft decision if
  it is ever used under a share-alike option; under CC-BY 3.0 it
  would need credit to Clement Wu, Nikolaus & Botanic. That decision
  belongs to the sibling workstream / James, not this ledger.

## 6. What was declined / not done (plainly)

- No itch.io download was attempted in any form (Kenney, KayKit,
  Quaternius, LOWPO, or any other itch.io page). No itch.io gate was
  worked around via mirrors, aggregators, or alternate hosts.
- No Freesound, paid, or paywalled source was used. No ripped
  game/anime/movie content was used. No unauthorized mirror was used
  (the one suspect Sketchfab item found was rejected, §5c).
- No Sketchfab file was downloaded (account gate).
- No Quaternius or KayKit file was downloaded, including via the
  Godot Asset Library listing.
- No Blender export was attempted (another hunter owns that).
- No game code, spawn picker, test, build, APK, or release was
  touched. No file outside `assets/resources-phase1/models/` was
  created or modified by this hunt, except this ledger itself and the
  `gobkit-LICENSE-CC0.txt` copy noted in §1.
- No license was inferred from a collection listing alone: every
  staged file's license was read from its own source (Gobkit pack
  license text / manifest license field / community item license
  field / 3DAssets.dev item license field).

## 7. Method note

Sources checked in this hunt: Godot Asset Library (search + KayKit
Skeletons + Icosa Gallery addon pages), kenney.nl (Cube Pets, Mini
Dungeon pages + general download-route check), Gobkit curated
manifest (305 models enumerated; roster-relevant subset staged),
Gobkit community API (24 published items enumerated; 12 staged),
3DAssets.dev item API (first batch verified and claimed here: dragon,
goblin, skeleton, demon, golem, spider, snake, wolf — the `demon`
query returned only loosely-matched non-demons such as lemons and
jelly characters). A second batch of 3DAssets.dev queries (imp,
wraith, ghost, zombie, vampire, werewolf, troll, ogre, wyvern,
kraken, mummy, lich, hellhound, bat, bear, boar) completed after
this ledger's first write; its outcome is recorded in the Addendum
(§8) and nothing from it was staged.
Sketchfab (CC dragon search; account gate confirmed as lead-only),
Poly Pizza / Icosa (search only; no verified per-model download
surfaced), and general web search for the brief's terms (low poly
skeleton/goblin/orc/demon/dragon/wolf/spider/golem, stylized fantasy
creatures CC0). Every staged GLB was verified by parsing its binary
header and JSON chunk; sizes and clip names above are from those
parses.

## 8. Addendum — second 3DAssets.dev batch (completed after first write)

Queries run: imp, wraith, ghost, zombie, vampire, werewolf, troll,
ogre, wyvern, kraken, mummy, lich, hellhound, bat, bear, boar.
Result: **no usable demon, wraith, zombie character, vampire
character, werewolf, troll, ogre, mummy, lich, or hellhound.**
The `imp`, `wraith`, `werewolf`, and `hellhound` queries returned
nothing at all; `zombie`/`vampire`/`mummy`/`lich`/`troll`/`ogre`
returned only scenery, props, and loosely-matched non-creatures
(zombie street scenes, crypt architecture, training dummies, salt
licks, ore piles, tape rolls).

Marginal hits found but deliberately NOT staged (all static, all
duplicates of better animated models already in this haul):
- `Wyvern With Wings Spread` and five sibling wyvern poses
  (standing alert, juvenile, slain, crouched, flying) — static pose
  variants of one 3,138-tri wyvern; the two animated Gobkit
  community wyverns already cover Drake/Wyvern.
- `Wandering draped ghost` (4,440 tris, static) and `Little sheet
  ghost` (592 tris, static) — the animated Gobkit SheetGhost already
  covers Ghost/Wraith.
- `Spread-wing bat` (312 tris, static) — Gobkit's animated Bat
  already covers Cave Bat.
- `Forest Boar, Jointed` (idle/head-turn only) and `Grizzly bear`
  (realistic, static, 19,780 tris) — Gobkit's animated Boar,
  Ironclad Boar, and Trap Bear already cover boar and bear.
- `Kraken Tentacle` — a scenery prop (1,472 tris), not a creature.

Counts in this ledger are unchanged by this addendum: still 68
files staged, all from §§1–3. Nothing in this addendum was
downloaded.
