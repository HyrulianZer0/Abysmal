# Phase 1b OpenGameArt Ledger — hunted Oct 29, 2026 (STAGED ONLY, no code touched)

Scope: fresh OpenGameArt searches by creature family, staged under
`assets/resources-phase1/models/`. No `scripts/` file was modified, no
spawn picker was touched, no build was made, no Blender export was
attempted (another hunter owns exports). Game credits use the pseudonym
**Aethelwarden Solas** only — never the developer's real name.
**Every creator below is credited, including CC0 authors** (project rule).

Prior Phase 1 work was NOT re-downloaded: the Kenney blocky humanoid
packs (zombies, brigand stand-ins) already in `undead/` and `humanoids/`
are untouched. Phase 1 leads that were `.blend`-only are now staged,
because this hunt's rule is "stage + note the export step", unlike
Phase 1's Godot-format-only rule.

## Staged assets

| # | Folder / file(s) staged | Source (OGA item page) | License (as stated on item page / OGA credits file — see notes) | Attribution string for credits | Format on disk | Roster creature / family it covers | Export / use note |
|---|---|---|---|---|---|---|---|
| 1 | `vermin/ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/` — 13 `.blend` + PNG textures (1,628,268-byte zip, verified) | https://opengameart.org/content/ps1-style-rpg-enemies | CC0 1.0 (item page, verified Oct 29, 2026) | PS1 Style RPG Enemies by CptDrunkBear (CC0) | .blend + PNG | **Bandit → Brigand; Revenant → Revenant; Scorpion → Cave Scorpion; cobracon + rattler → Serpents;** plus cannae, cereptera, clod, helichard, janga, myocene, tardigrade, ungulate (fungus/beast/plant-adjacent dungeon creatures) | .blend only — needs Blender → glTF/FBX export. Retro-style rig (limbs as separate parented models). Single most valuable haul: one consistent PS1 style across many families. |
| 2 | `beasts/vampire-bat/` — `bat_v5.blend` + textures + frost variant textures + HDRI (16,497,090-byte zip, verified) | https://opengameart.org/content/vampire-bat-animated | CC0 1.0 (item page, verified) | Vampire Bat (Animated) by rubberduck (CC0) | .blend + JPG | **Vampire Bat** (also frost-bat variant) | .blend only — needs export. Rigged + animated; 7,732 tris (decimate-able). |
| 3 | `vermin/evil-giant-rat/rat.blend` (1,028,612 bytes, Blender 2.66 — see caveat) | https://opengameart.org/content/evil-giant-rat | CC0 1.0 (item page, verified) | Evil Giant Rat by CDmir, with TinyWorlds (CC0) | .blend | **Giant Rat / Cave Rat** — a real rat, not a human stand-in | .blend only — needs export. Rigged + animated; textures packed in file per page. |
| 4 | `demons/flare-daemon/daemon4.blend` (2,267,468 bytes, Blender 2.68) | https://lpc.opengameart.org/content/demon-flare-sprite-sheets | CC0 1.0 (item page, verified) | Demon — Flare sprite sheets by ryan.dansie, based on umask007's animated demon model (CC0) | .blend (+ sprite sheet on the same page, not staged — this hunt stages models) | **Demon / Daemon / Imp-adjacent** (horned demon) | .blend only — needs export. Animations per page: idle, walk, attack ×2, cast, flinch, die. |
| 5 | `goblin-kin/goblin-br-n518/goblin.blend` (790,276 bytes, Blender 2.76) | https://opengameart.org/content/goblin-2 | CC0 1.0 (item page, verified) | Goblin by br-n518 (CC0) | .blend | **Goblin** — a real goblin, not a human skin | .blend only — needs export. Simple armature rig, weight-painted per page. |
| 6 | `beasts/troll-flare/Troll.blend` (2,251,484 bytes, Blender 2.62) | https://lpc.opengameart.org/content/flare-model-troll | CC-BY 3.0 (item page, verified) | FLARE Model - Troll by VWolfdog (CC-BY 3.0) | .blend | **Troll** — big, fat, club-wielding monster per page | .blend only — needs export. Built on Clint Bellanger's Base Human Mesh (noted on page); the shipped file is a troll mesh, not a human. |
| 7 | `undead/pirate-crewman-ghost/piratezombiemodel.blend` (1,301,348 bytes, Blender 2.62) | https://opengameart.org/content/flare-zombie-mod-pirate-crewman-ghost | CC-BY 3.0 (item page, verified) | FLARE Zombie Mod - Pirate Crewman Ghost by VWolfdog, with Clint Bellanger (CC-BY 3.0) | .blend | **Ghost** (pirate ghost; alpha setting gives the "ghosty" appearance per page) | .blend only — needs export. Re-skinned/edited zombie mesh; read as ghost via its alpha, not as a zombie. |
| 8 | `golems/fire-ice-stone-golem/golem.blend` (31,244,692 bytes, Blender 2.68) | https://opengameart.org/content/fire-ice-stone-golem (title "Fire/Ice/Stone Golem") | **CC-BY 3.0 / CC-BY-SA 3.0 (dual, item page)** — see FLAG below | Fire/Ice/Stone Golem by umask007 (CC-BY 3.0 elected; also offered under CC-BY-SA 3.0 — FLAG) | .blend | **Fire / Ice / Stone Golem + Elemental area** (three material variants in one file) | .blend only — needs export. Animated: walk, attack, flinch, attack2, die, idle. Textures baked from yughues textures (noted on page); original model from BlendSwap (noted on page). |
| 9 | `golems/bone-golem/BoneGolem/Bone_Golem.obj` + `Bone_Golem_Diffuse.png` (from `Bone_Golem_OBJ.zip`, 503,602 bytes, verified) | https://opengameart.org/content/bone-golem | **CC-BY 3.0 / GPL 3.0 (dual, item page + OGA credits file)** — see FLAG below | Bone Golem by Mophs, concept art by Nubux (CC-BY 3.0 elected; also offered under GPL 3.0 — FLAG) | **.obj + PNG — Godot-usable, no export needed** | **Bone Golem** (undead/construct crossover; ~4k tris, 512×512 handpainted texture) | OBJ staged, not the .blend: the .blend's own rig is "not production ready" (spine/finger issues, per page). Needs rigging for animation. `__MACOSX` metadata from the zip was deleted. |
| 10 | `undead/skeleton-outlaw/SkeletonOutlaw/` — `Source Model/SkeletonOutlaw.fbx` + 14 `Animations/*.fbx` + `Textures/` (from `SkeletonOutlaw_0.zip`, 4,875,182 bytes, verified) | https://opengameart.org/content/skeleton-outlaw-3d-character | CC0 1.0 (OGA-generated credits file — see caveat) | Skeleton Outlaw 3D Character by KevDev (CC0) | **.fbx — Godot-usable, no export needed** | **Skeleton variant (outlaw/warrior skeleton)** | Best animation set in this haul: Attack ×3, Damage ×2, Dead ×2, Idle ×3, Jump (×2, one no-root-motion), Run, Walk. Included `Thank You.txt` points at a Unity Asset Store version — the OGA zip itself is the CC0 copy staged here; do not buy/substitute the store version. |
| 11 | `undead/crossbowman-skeleton/obj/skull_monster.obj` + `.mtl` + `Skull_Monster_512.png` (from `skull.zip`, 620,476 bytes, verified) | https://opengameart.org/content/animated-crossbowman-skeleton | CC-BY 4.0 (OGA-generated credits file — see caveat) | [Animated] Crossbowman Skeleton by CoinCoin (CC-BY 4.0) | **.obj + .mtl + PNG — Godot-usable, no export needed** | **Skeleton Archer** (the roster's skeleton-archer slot; page title says "Animated" but the OGA zip ships a static OBJ — see note) | Static mesh: needs rigging + animation in Blender/Godot. The "animated" claim refers to the author's Sketchfab preview, not the OGA file contents. |
| 12 | `undead/skeleton-with-rig/fgc_skeleton.blend` (1,748,720 bytes, Blender 2.49) | https://opengameart.org/content/skeleton-with-rig | CC0 1.0 (OGA-generated credits file — see caveat) | Skeleton with rig by Gord Goodwin (CC0) | .blend | **Skeleton (base/rig variant)** | .blend only — needs export. Very old Blender version (2.49) — the export hunter should confirm it opens cleanly in modern Blender. |
| 13 | `dragons/dragon-drakanfyr/dragon.3ds` (33,845 bytes, verified 3D Studio model) | https://opengameart.org/content/dragon-3 | CC0 1.0 (item page, verified) | Dragon by DrakanFyr (CC0) | .3ds | **Generic dragon / wyrm** | .3ds is NOT directly Godot-usable and the model is unrigged + unskinned per page — needs conversion AND rigging. Staged as a dragon silhouette base only. |
| 14 | `fey/snappakappa/snappa-kappa.blend` (724,712 bytes, Blender 2.78) | https://opengameart.org/content/snappakappa-3d | CC-BY 4.0 (item page, verified) | snappaKappa 3d by MNDV.ecb, after crisisworks' snappaKappa (CC-BY 4.0) | .blend | **Kappa** (yōkai / turtle-like water creature, ~1,200 tris) | .blend only — needs export. Rigged per page. Page notes it inherits license from the original snappa-kappa strip, used as texture. |
| 15 | `bosses/cerberus/cerberus_v002.blend` (1,254,592 bytes, Blender 2.56) + `cerberus_texture_0.png` (81,295 bytes, 512×512 PNG, verified) | https://opengameart.org/content/animated-cerberus | **CC-BY 3.0 / CC-BY-SA 3.0 / GPL 3.0 / GPL 2.0 (multi-license, user picks one — item page)** — see FLAG below | Animated Cerberus by Clement Wu, Nikolaus & Botanic (CC-BY 3.0 elected; also offered under CC-BY-SA 3.0, GPL 3.0, GPL 2.0 — FLAG) | .blend + PNG | **Cerberus (apex boss)** — three-headed hound, not a human stand-in | .blend only — needs export. Fully animated per page: Attack, Idle, Hit, Pose, Walk. Texture filename on disk is `cerberus_texture_0.png` (OGA renamed the upload; the plain name 404s — do not "fix" it back). |

Counts: **15 staged items, 14 source packs/files** (items 8–15 are one file each
except Cerberus's texture). Formats: 3 Godot-usable as-is (Bone Golem OBJ,
Skeleton Outlaw FBX, Crossbowman OBJ), 11 `.blend`-only (export step
needed), 1 `.3ds` (conversion + rigging needed). Families newly covered
vs Phase 1: vermin (rat, scorpion), serpents, brigand (real bandit),
revenant, bat, demon, goblin, troll, ghost, golems (fire/ice/stone,
bone), skeleton variants (outlaw, crossbowman/archer, rigged base),
dragon, kappa, Cerberus boss.

## ⚠️ FLAG — copyleft / multi-license items (decision needed, NOT silently adopted)

These three are staged but must NOT be treated as cleared until James
(or the parent) picks the license election:

- **Fire/Ice/Stone Golem (item 8):** offered under CC-BY 3.0 **and**
  CC-BY-SA 3.0. This ledger's working election is **CC-BY 3.0**
  (no share-alike), but if the project instead takes the SA option,
  derivatives of the golem art would carry share-alike. Confirm the
  CC-BY 3.0 election before use.
- **Bone Golem (item 9):** offered under CC-BY 3.0 **and GPL 3.0**.
  Working election is **CC-BY 3.0**; a GPL election would be a
  copyleft decision for the art. Confirm the CC-BY 3.0 election.
- **Cerberus (item 15):** offered under CC-BY 3.0, CC-BY-SA 3.0,
  GPL 3.0, GPL 2.0 — user picks one (OGA's own rule for multi-license
  items). Working election is **CC-BY 3.0**; any SA/GPL election is a
  copyleft decision. Confirm the CC-BY 3.0 election.

## Caveats (honest, check before shipping)

- **Rat size mismatch:** the OGA page lists `rat.blend` as 6.8 MB, but
  the file served Oct 29, 2026 is 1,028,612 bytes and `file` confirms a
  valid Blender 2.66 file. The export hunter should confirm the model
  opens complete in Blender; if it is truncated, re-download from the
  item page.
- **Credits-file licenses (items 10–12):** for Skeleton Outlaw,
  Crossbowman Skeleton, and Skeleton with rig, the item-page fetches
  dropped the license/file metadata fields (pages rendered comments
  only), so their licenses rest on OGA's own generated credits files
  for those items (CC0 / CC-BY 4.0 / CC0 respectively, with matching
  filenames that all downloaded and verified). Re-confirm on the item
  pages before these ship in a release.
- **Parallel hunter's files:** while this hunt ran, another hunter
  staged sibling exports in this same folder (e.g. `gobkit/` .glb
  packs, `demons/animated-cerberus/*.glb`, `ps1-style-rpg-enemies/*.glb`,
  `vermin/evil-giant-rat/rat.glb` + `LICENSE.md`). Those are NOT this
  ledger's work, were not verified by this hunt, and are not claimed
  here. This ledger covers only the files listed in the table above.
  The sibling `ps1-style-rpg-enemies/` (top level) and
  `vermin/ps1-style-rpg-enemies/` (this hunt) are different folders
  holding the same source pack; neither overwrote the other.

## NOT staged (checked, deliberately left out — do not treat as available)

- **Wolf:** `Wolf` by Micket (https://opengameart.org/content/wolf-1) —
  comments discuss a multi-license including CC0, but the item-page
  fetch rendered comments only, so license + file format are
  UNVERIFIED. Not downloaded. `winter wolf+ normal wolf` by umask007
  is CC-BY-SA 3.0-only per a third-party credits listing and its page
  fetch also lost metadata — not downloaded (SA-only + weak evidence).
  **Wolf remains an open gap.**
- **Spider (standalone):** `Spider - Animated` by Panther-One —
  attribution instruction ("credit Panther-One") is on the page, but
  the license field did not render on either the main or LPC mirror,
  and no file list rendered. License UNVERIFIED → not downloaded.
  Spider coverage currently comes only from the PS1 pack's scorpion
  (arachnid-adjacent, not a spider) — **true spider remains a gap.**
- **Animated daemon (standalone):** https://opengameart.org/content/animated-daemon
  — license field did not render and the page says the model is based
  on a BlendSwap model. Not downloaded standalone; the FLARE CC0
  derivative (`daemon4.blend`, item 4) is staged instead.
- **Brigand (Animated Defender):**
  https://opengameart.org/content/animated-defender-aka-brigand —
  description says the original is CC-BY-3 (Anthony Myers), retopologized
  + animated, but the file list did not render, so no file could be
  verified or downloaded. Brigand coverage comes from the PS1 bandit
  (item 1) instead.
- **FLARE Skeleton Knight / Occultist:** OGA pages say CC-BY 3.0, but
  a third-party credits review reports the shipped `.blend` files embed
  Clint Bellanger's base-model notice (GPL 2+ / CC-BY-SA 3.0+), i.e. the
  pages and the files disagree. Not staged — license conflict must be
  resolved first. Skeleton coverage comes from items 10–12 instead.
- **Snake (standalone):** `Snake low poly animated 3d model` by
  methodical pixel — CC0 is stated only in a third-party project's
  credits page, not verified on the OGA item page this hunt. Not
  downloaded. Serpent coverage comes from the PS1 pack (cobracon,
  rattler) instead.
- **Orc, kobold, imp (standalone), wraith, elemental (standalone):**
  no OGA 3D model found this hunt with a license verified on its own
  item page. Orc/kobold/wraith/imp remain open gaps. (FLARE orc/goblin
  sprite sheets exist on OGA but are 2D sprites, not 3D models, and
  were out of this hunt's scope.)
- **Low Poly Animated Character** by Anunciatta (CC0, item page
  verified): a generic humanoid base with Mixamo clips, not a creature
  — intentionally not staged; it would be a human stand-in, which
  James's rule forbids for non-human monsters.

## Forbidden sources — none used

No itch.io (in any form), no Freesound, no paid/paywalled source, no
ripped game/anime/movie content, no unauthorized mirror. Quaternius
packs were not touched (still outstanding on a human clickthrough).
Every staged file came from opengameart.org or its lpc subdomain, with
its license checked on its own item page (or, for items 10–12, on OGA's
own generated credits file for that item — flagged above).

## Addendum — Wave 1 Worker B: remaining Blender exports + HELD golems + duplicate pruning (Oct 29, 2026)

Scope of this addendum only: Blender `.blend` → `.glb` exports for the
items below, HELD-flagged golem exports, and deletion of non-canonical
duplicate copies. No game script, scene, or test was modified. Nothing
was imported into the Godot project. Nothing was wired into the game.
No APK, release, publish, or upload. Credits use **Aethelwarden Solas**
only. Export method (same as the PS1 ledger): one headless Blender
4.5.3 LTS run per source file,
`bpy.ops.export_scene.gltf(export_format='GLB', export_yup=True)`,
saving a `.glb` next to its source. Every `.glb` below was verified as
a real glTF binary (`glTF` magic, declared length = actual length) and
its JSON chunk was parsed for mesh/node/skin/animation counts. Honest
limit (same as the PS1 ledger): files were NOT imported into Godot, so
mesh, texture, rig, and animation-clip behavior in-engine is still a
Phase 2 / Wave 2 check. Warnings are recorded verbatim, not waved away.
Full export logs: `.wave1b-logs/exp_*.log` in this folder (working
logs, not game assets).

### Exports completed

| Model (source → export) | .glb bytes | GLB contents (parsed) | Warnings verbatim |
|---|---|---|---|
| FLARE Daemon `demons/flare-daemon/daemon4.blend` (2.68, CC0) → `daemon4.glb` | 528,592 | 1 mesh, 51 nodes, 1 skin, 9 anims: attack, die, hit, idle1, idle2, idleAnim, mightyAttack, spell, walk | "Animation target pose.bones[\"root.008\"] not found" (×112), same for root.009 (×112) and root.010 (×112); "Mesh Circle.001 is not valid, and may be exported wrongly"; "There are more than 4 joint vertex influences. The 4 with highest weight will be used (and normalized)."; "Warning: region type 4 missing in space type \"Info\" (id: 7) - removing region" |
| Troll `beasts/troll-flare/Troll.blend` (2.62, CC-BY 3.0) → `Troll.glb` | 256,588 | 2 meshes, 29 nodes, 1 skin, 8 anims: Action, Action.001–Action.007 | "Animation target pose.bones[\"Cloak\"] not found" (×20); "Mesh 'Plane' has no primitives and will be omitted."; "Armature must be the parent of skinned mesh. Armature is selected by its name, but may be false in case of instances." |
| Pirate Crewman Ghost `undead/pirate-crewman-ghost/piratezombiemodel.blend` (2.62, CC-BY 3.0) → `piratezombiemodel.glb` | 141,644 | 3 meshes, 40 nodes, 2 skins, 2 anims: Action.001, Action.002 | "Armature must be the parent of skinned mesh. Armature is selected by its name, but may be false in case of instances." (×2); "Mesh 'Plane.002' has no primitives and will be omitted." |
| Skeleton with rig `undead/skeleton-with-rig/fgc_skeleton.blend` (2.49, CC0) → `fgc_skeleton.glb` | 1,352,132 | 8 meshes, 246 nodes, 1 skin, **0 animations** | "Armature must be the parent of skinned mesh. Armature is selected by its name, but may be false in case of instances." (×8) |

**Skeleton-with-rig note (good news, recorded plainly):** the 2.49 file
DID open in Blender 4.5.3 and exported on the first attempt — no
conversion step, no forcing, no data loss observed at export time
(8 `SkeletonMesh` primitives extracted). The caution in the main ledger
("confirm it opens cleanly") is therefore answered: it opens and
exports. Two caveats remain for Wave 2: (a) the exported GLB contains
**zero animation clips**, so if the source had animations they did not
survive as clips — Wave 2 must check whether the rig is animation-ready
or pose-only; (b) the CC0 license for this item still rests on OGA's
generated credits file (see main-ledger caveat), so re-confirm on the
item page before it ships.

Per-folder license notes were also added for the five exported models
(`LICENSE.md` beside each source), matching the convention used by the
other staged folders.

### ⚠️ HELD — Fire/Ice/Stone Golem: EXPORT ONLY, DO NOT WIRE

- `golems/fire-ice-stone-golem/golem.blend` (2.68, 31,244,692 bytes)
  → `golem.glb` (459,620 bytes), valid glTF binary: 1 mesh, 46 nodes,
  1 skin, 7 anims (ArmatureAction.001, attack, attack2, die, flinch,
  idle, walk — matching the page's animation list).
- Warnings verbatim: "Baking animation because of unsupported
  constraints acting on the bone" (×56); "Warning: region type 4
  missing in space type \"Info\" (id: 7) - removing region".
- **HELD:** the file exists so Wave 2 does not need to re-export, but
  this golem is **NOT cleared for in-game use**. Its license is dual
  CC-BY 3.0 / CC-BY-SA 3.0 and the CC-BY 3.0 election is UNCONFIRMED
  (see main-ledger FLAG). Nothing in this addendum authorizes its use
  in-game. The per-folder `LICENSE.md` carries the same HELD flag.

### ⚠️ HELD — Bone Golem and Cerberus: not re-exported, not wired

- **Bone Golem** (`golems/bone-golem/BoneGolem/Bone_Golem.obj` + PNG):
  NOT touched. It is already Godot-usable as OBJ, so no Blender export
  was needed, and none was made. It is **HELD** on the same basis: dual
  CC-BY 3.0 / GPL 3.0, CC-BY 3.0 election UNCONFIRMED — do not wire
  until the election is confirmed.
- **Cerberus** (`demons/animated-cerberus/cerberus_v002.glb`): NOT
  re-exported — the PS1 workstream's verified GLB (95,096 bytes) was
  already present and was left untouched, and nothing was wired. The
  PS1 ledger's CC-BY 3.0 election record for Cerberus is unchanged by
  this addendum; Wave 2 should still confirm the election before use,
  per the Wave 1B brief's HELD instruction for election-flagged models.

### Duplicate pruning (non-canonical copies deleted)

Canonical copies are the PS1-ledger paths (the ones carrying the `.glb`
exports). Only the non-canonical duplicates below were deleted. No
canonical path, unique file, or uncertain file was deleted.

| Deleted path | Reason / verification |
|---|---|
| `vermin/ps1-style-rpg-enemies/` (entire folder: 13 `.blend` + 15 PNG) | Byte-identical (md5) to `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/` for every `.blend` and PNG; canonical folder alone holds the 13 `.glb` exports, the zip, and `LICENSE.md`. |
| `beasts/vampire-bat/` (entire folder incl. `raw/`, `HDRI/`) | `bat_v5.blend` md5-identical to `vermin/vampire-bat-animated/bat_v5.blend`; all textures, `raw/` and `HDRI/` contents identical by `diff -rq`; canonical folder alone holds `bat_v5.glb`, the zip, and `LICENSE.md`. |
| `bosses/cerberus/` (entire folder: `.blend` + texture) | `cerberus_v002.blend` md5-identical to `demons/animated-cerberus/cerberus_v002.blend`; texture md5-identical (despite the filename difference: `cerberus_texture_0.png` vs `cerberus_texture.png`); canonical folder alone holds `cerberus_v002.glb` and `LICENSE.md`. `bosses/` is now an empty folder; left in place. |
| `fey/snappakappa/snappa-kappa.blend` (file + now-empty folder) | md5-identical to `yokai/snappakappa-3d/snappa-kappa.blend`; canonical folder alone holds `snappa-kappa.glb` and `LICENSE.md`. |
| `goblin-kin/goblin-br-n518/goblin.blend` (file + now-empty folder) | Same OGA source item (goblin_1.blend) as `goblin-kin/goblin/goblin.blend`, BUT the two downloads are NOT byte-identical: deleted copy 790,276 bytes (md5 `38d11ca841061529f155cb336d2d46a4`) vs canonical 769,844 bytes (md5 `61b79c07345bd0245e321b12184f06ab`). Deleted per the Wave 1B brief (non-canonical duplicate of the same source asset); the canonical copy is the proven one — it already produced the verified `goblin.glb` (94,608 bytes). The size difference is recorded here so Wave 2 can see it was noticed, not hidden. |
| `dragons/dragon-drakanfyr/dragon.3ds` (file + now-empty folder) | md5-identical to `dragons/dragon/dragon.3ds`; canonical folder alone holds `LICENSE.md`. Dragon conversion status is covered in the Dragon section below. |

**NOT deleted (checked, deliberately left):**

- **Evil Giant Rat:** no second copy exists. Both ledgers point at the
  same path, `vermin/evil-giant-rat/rat.blend`, which already carries
  `rat.glb` — there was nothing non-canonical to delete.
- **Rat size discrepancy noticed:** the on-disk `rat.blend` is
  1,028,612 bytes (matching this ledger), but the PS1 ledger claims
  6,833,728 bytes for the same path. Either the PS1 ledger's size claim
  is wrong or the file was replaced by this hunt's smaller download
  after the PS1 export. The exported `rat.glb` (38,436 bytes) matches
  the PS1 ledger's export size. Wave 2 should confirm the rat mesh is
  complete in Godot (already flagged in the PS1 ledger as a mesh check).
- **Gobkit / 3DAssets.dev / Kenney files:** untouched; not part of this
  pruning scope.

### Dragon .3ds → GLB conversion — SUCCEEDED as a static mesh (Oct 29, 2026)

- **Route tried and failed (recorded honestly):** Assimp was NOT used.
  `assimp` CLI is not installed on the VM; `apt-get install
  assimp-utils` failed with "Unable to locate package" (stale package
  lists), and the follow-up `apt-get update` hung for 15+ minutes with
  no output and was killed. The PyPI `assimp` wheel (4.1.4) was also
  tried and failed: it is only a ctypes wrapper and raises "assimp
  library not found" because no system libassimp exists. No Assimp
  conversion was performed or claimed.
- **Route that worked:** Blender 3.6.23 LTS (the last 3.6 patch, June
  17, 2025), installed portable at
  `~/workspace/tools/blender-3.6.23-linux-x64/` (kept outside the game
  tree for reuse; tarball `blender-3.6.23-linux-x64.tar.xz`,
  272,819,000 bytes, from the official Blender download page). Blender
  3.6 still ships the `io_scene_3ds` importer; in `--background` mode
  the addon must be enabled explicitly in the script
  (`addon_utils.enable("io_scene_3ds")`) or the import operator
  reports "could not be found". Import script:
  `.wave1b-logs/import_3ds_export_glb.py`.
- **Result:** `dragons/dragon/dragon.glb` (165,252 bytes), valid glTF
  binary (declared length = actual length), converted cleanly with
  **no warnings**. Parsed contents: 1 mesh (`Body`, 2 primitives,
  2 materials — the file's two "Default" materials), 5,942 + 288
  vertices, 1 node, **0 skins**, 2 materials, **no UV coordinates**
  (primitives carry POSITION + NORMAL only). The single "animation"
  (`BodyAction`, one keyframe of translation/rotation/scale) is the
  .3ds keyframer block's static pose, not a gameplay animation.
- **Rigging feasibility — honest assessment:** the conversion itself
  is solved, but the model is **still unrigged and unskinned**, exactly
  as the source page states. The .3ds format carries no skin weights
  and no armature, so there is nothing to recover: making this dragon
  a usable animated enemy requires Wave 2 work from scratch —
  armature + weight painting + animation authoring, plus a UV unwrap
  if it is ever to be textured, plus a rescale (vertex extents span
  roughly ±315 units, and the node carries a ~47.5 / 88.0 translation
  offset). As it stands, `dragon.glb` is usable only as a **static
  mesh / silhouette**, not as an animated enemy. It is NOT a Drake
  replacement (the animated Gobkit wyverns already cover Drake).
- The source `.3ds` was not modified, and the duplicate
  `dragons/dragon-drakanfyr/dragon.3ds` copy was pruned above.

### Wave 1 follow-up — Rat re-export: NOT DONE, source itself is broken (Oct 29, 2026)

Worker A's import verification (see
`design-notes/wave1-import-verification.md`) found `rat.glb`
UNUSABLE AS-IS: Godot imported exactly one mesh, `Cylinder_002`
(AABB 1.24 × 1.64 × 7.16 m), no skeleton, no animations, no texture.
Re-opening `vermin/evil-giant-rat/rat.blend` in Blender 4.5.3 proves
the export was faithful and the **source is the problem**:

- The file contains exactly **2 objects total**: a CAMERA and one
  MESH, `Cylinder.002` (722 verts, 1,336 polys, dims 1.244 × 1.637 ×
  7.163 — the same dimensions Worker A measured). The same object is
  linked into 19 collections, which is why the file lists 20
  collections but no additional geometry.
- **0 armatures, 0 actions, 1 mesh datablock in the entire file.**
  There is no rat body, head, tail, or limbs to export, and no rig to
  preserve. (Diagnostic logs: `.wave1b-logs/diag_rat.log`,
  `.wave1b-logs/diag_rat2.py`.)
- This is consistent with the size discrepancy already flagged in the
  main ledger: the served file is 1,028,612 bytes, but the OGA page
  lists `rat.blend` as 6.8 MB. Whatever the full 6.8 MB file contains,
  the file on disk is a fragment, not a truncated download (it opens
  cleanly; it is simply missing content).

**Therefore no new rat GLB was produced, deliberately:** re-exporting
this file can only reproduce the same cylinder. No file was forced,
faked, or "repaired" by inventing rat geometry. The old `rat.glb`
(38,436 bytes) was left untouched and remains UNUSABLE AS-IS.
**Wave 2 step:** re-download `rat.blend` from the OGA item page
(https://opengameart.org/content/evil-giant-rat) and check whether the
fresh download is the full 6.8 MB rat; if the served file is still
this fragment, the Evil Giant Rat needs a different source model.
Do NOT attempt to fix the existing GLB.

### Wave 1 follow-up — Cerberus re-export: ALL RECOVERABLE ACTIONS + TEXTURE (HELD, Oct 29, 2026)

Worker A's verification found `cerberus_v002.glb` kept only Walk and
lost its texture (flat grey). Diagnosis of
`demons/animated-cerberus/cerberus_v002.blend` (`.wave1b-logs/diag_cerberus.log`):

- All promised actions EXCEPT Pose exist in the file: `Attack`
  (frames 1–41, 220 fcurves), `Idle` (1–21, 220), `hit` (1–21, 220),
  `Walk` (1–31, 230), plus `die` (1–35, 220) — which the page did not
  list but is present. The old export kept only Walk because the
  armature's active action was `Walk` and there were **no NLA
  tracks**; the glTF exporter exports the active action + NLA strips,
  so the other four actions were silently dropped.
- The texture was lost because the material (`Material.001`) is an
  old Blender Internal material (`use_nodes=False`) with no node
  tree, so the exporter could not see it. The image datablock
  `cerberus_texture.png` (512×512, filepath `//cerberus_texture.png`)
  was present in the file and the PNG sits next to the `.blend`.
  The mesh has a UV layer (`UVTex`), so the texture CAN map.
- **Fix applied (export only, no content authored):** in-memory only
  — one NLA track + strip per action (names kept verbatim from the
  source, including the mixed case: `Attack`, `Idle`, `hit`, `Walk`,
  `die`), active action cleared so clips come from strips only, and a
  Principled node tree wiring the existing `cerberus_texture.png`
  image to Base Color. The source `.blend` was **NOT saved** (its
  mtime is unchanged); the fix lives only in the exported GLB and in
  the reproducible script `.wave1b-logs/fix_cerberus_export.py`.
- **Result:** `demons/animated-cerberus/cerberus_v002_full.glb`
  (333,540 bytes), valid glTF binary, **new file — the old
  `cerberus_v002.glb` (95,096 bytes) was left untouched for reference.**
  Parsed contents: 1 mesh, 51 nodes, 1 skin with **49 joints**
  (matching Worker A's 49-bone skeleton), **5 clips** (`Attack`,
  `die`, `hit`, `Idle`, `Walk`, 144 channels each), material
  `Material.001` with `baseColorTexture`, and the texture **embedded**
  as PNG (`cerberus_texture`, bufferView — not an external reference).
  Only warning (verbatim, harmless per Worker A): "Armature must be
  the parent of skinned mesh. Armature is selected by its name, but
  may be false in case of instances."
- **Pose: MISSING, not recoverable, not authored.** No action named
  `Pose` (or similar) exists anywhere in the source file, so the
  page-promised Pose clip cannot be re-exported. Per the brief, no
  replacement was authored. If Wave 2 wants a Pose clip, it must be
  authored in Godot or Blender as new work, not presented as a
  recovered source clip.
- **⚠️ HELD:** `cerberus_v002_full.glb` is **EXPORT ONLY — DO NOT
  WIRE**. Its CC-BY 3.0 election is unconfirmed (multi-license offer:
  CC-BY 3.0 / CC-BY-SA 3.0 / GPL 3.0 / GPL 2.0), per the Wave 1B brief.
  The per-folder `LICENSE.md` carries the same HELD flag. Nothing in
  this addendum authorizes its use in-game.
