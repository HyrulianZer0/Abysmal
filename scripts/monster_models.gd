class_name MonsterModels
extends RefCounted
## Wave 2 model registry (Oct 29, 2026): which real model each enemy type
## uses, and how it is normalised against the player capsule.
##
## Every entry was measured in Godot 4.7.2 headless (scratch-project
## import walk, editor-imported scenes) before wiring — the "target"
## numbers below are the in-game size AFTER the existing
## `_build_model()` height normalisation, not raw import sizes. Raw
## sizes are wild (SheetGhost ~1.4 mm, OrcLegionary 2.3 m tall,
## Troll body floating at y=1.61, rat Hair mesh spanning 17 m), so no
## wired model ships at raw import scale.
##
## Entry fields:
## - "model": res:// path of the model file (GLB, FBX, or OBJ).
## - "norm_axis": "x", "y" (default), or "z" — the axis normalised to
##   "target". Long creatures (centipede, rattler) normalise by length
##   (z); the Vampire Bat normalises by wingspan (x).
## - "target": in-game size on norm_axis, in metres.
## - "y_offset": extra metres added after grounding (flyers hover).
## - "remove": node names deleted before measuring (ground/shadow
##   planes, the rat's exploded Hair mesh — never body parts).
## - "texture": PNG re-linked onto every surface (PS1 pack only: the
##   Blender 2.79 exports dropped their texture links; the meshes DO
##   carry UVs, so a Godot material re-link restores them — no
##   Blender re-export was needed).
## - "anim": preferred AnimationPlayer clip (substring match, same as
##   the live types). Empty/absent = static model, procedural motion.
## - "clips": role -> clip name, where the source names roles honestly.
##   Troll / pirate-ghost clips are unnamed ("Action...") and the
##   mapping is deliberately NOT invented.
## - "proc_motion"/"proc_profile": procedural idle motion for static
##   models (see enemy.gd `_process`); animated models don't need it.
##
## HELD files NEVER appear here: no Bone Golem. Cerberus hold LIFTED
## Nov 1, 2026 (director-authorized build, memo
## design-notes/cerberus-director-memo.md; CC-BY 3.0 election
## confirmed Oct 29, 2026) — the _full GLB is rostered below as
## "cerberus". The old Walk-only cerberus_v002.glb stays
## reference-only and is never wired. `is_held_path()` + the test
## suite enforce the remaining hold.
## Wave 2b (Oct 29, 2026) lifts two former holds, and this registry
## records exactly that: (1) James APPROVED the 3DAssets.dev
## AI-generated models in principle, so spider/wolf below use them —
## but he has NOT visually reviewed them, so every AI-wired entry is
## flagged VISUAL REVIEW in its note and must get his in-editor
## eyeball pass before shipping; (2) James CONFIRMED the CC-BY 3.0
## elections "to its fullest extent" for Fire/Ice/Stone Golem and Bone
## Golem, so the golem entry below uses the election model (REQUIRED
## attribution in its note). Bone Golem stays unwired: no staged type
## matches it, its .mtl is missing (texture unlinked on import), and
## it is static with a 6.61 m splayed rest width — a future/variant
## item, not a forced fit.
## Credits use "Aethelwarden Solas" only, never the developer's name.
## Wave 5 (Nov 2, 2026): 272 guide-built bestiary rows rostered above
## (ROSTER_MODELS — no TYPES entry, no stats invented, no spawn), the 7
## former procedural code types wired into MODELS, and the bestiary Wolf
## row rostered as "wolf_bestiary" so it cannot collide with the staged
## wolf type (CityWolf wire stands). Banshee translucency per its guide
## (BLEND alpha 0.7 on body materials in the wired copy); 15 Hair nodes
## renamed HairStrands in wired copies (test reserves "Hair" for the
## rat's exploded mesh).

## Substrings that mark a HELD path. Any registry path containing one
## of these is rejected by the test suite.
## RECONCILED Nov 2, 2026 (Wave 5): the marker used to be the bare
## substring "bone-golem", which blocked every Bone Golem path. It now
## covers ONLY the election-model directory
## (resources-phase1/models/golems/bone-golem: Bone_Golem.obj + PNG,
## .mtl missing, CC-BY 3.0 election UNCONFIRMED per its LICENSE.md).
## The Nov 2 guide-built Bone Golem row (bestiary/golem-construct/)
## is an original build, not the election file, and is rostered.
const HELD_MARKERS := [
	"resources-phase1/models/golems/bone-golem",
]

static func is_held_path(path: String) -> bool:
	for marker in HELD_MARKERS:
		if path.contains(marker):
			return true
	return false

const _PS1 := "res://assets/resources-phase1/models/ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/"
const _PHASE1 := "res://assets/resources-phase1/models/"
const _BESTIARY := "res://assets/models/bestiary/"

## Wired models: one entry per staged type that has a real model.
## The other 8 staged types stay procedural (see enemy.gd).
const MODELS := {
	"rat": {
		"model": _PHASE1 + "vermin/evil-giant-rat/rat_full.glb",
		"norm_axis": "y", "target": 0.42,
		"remove": ["Plane", "Plane.001", "Hair"],
		"anim": "Idle_001",
		"clips": {"idle": "Idle_001", "attack": "Attack_000", "death": "Die", "walk": "Walk"},
		"note": "Fresh Oct 29 re-download (6,833,728 bytes, full rat); the staged rat.glb is still the broken cylinder and is NOT used. Planes are 2x2 m ground planes; Hair exports as a 15x17x25 m exploded mesh and is removed, not repaired. Idle_000 is a 64.7 s timeline, so Idle_001 (3.75 s) is the idle clip.",
	},
	"spider": {
		"model": _PHASE1 + "vermin/3dassets/CellarSpider_godot.glb",
		"norm_axis": "y", "target": 0.5,
		"proc_motion": true, "proc_profile": "skitter",
		"note": "Wave 2b: 3DAssets.dev CellarSpider (CC0, AI-generated, site-generated, no human author). Original GLB failed Godot import (required KHR_mesh_quantization unsupported); Blender 4.5.3 re-export (CellarSpider_godot.glb, quantization stripped) imports clean: 2 meshes, 0 clips, 0 textures, flat colours (dark iron + teal magic accent), Godot AABB 0.60 x 0.21 x 0.44 m — height-normalised to 0.50 m, leg span ~1.42 m. Static, procedural skitter. VISUAL REVIEW REQUIRED before shipping: James has not eyeballed this model; the leg/body read is judged from mesh name, vertex counts (6672 + 2640) and materials only, never from a render.",
	},
	"snake": {
		"model": _PS1 + "enemy_cobracon.glb",
		"norm_axis": "y", "target": 0.85,
		"texture": _PS1 + "enemy_cobracon.png",
		"proc_motion": true, "proc_profile": "slither",
		"note": "PS1 cobracon (raised cobra). Static, no skeleton/clips; texture re-linked in Godot materials.",
	},
	"wolf": {
		"model": _PHASE1 + "beasts/3dassets/CityWolf_godot.glb",
		"norm_axis": "y", "target": 0.85,
		"anim": "idle",
		"clips": {"idle": "idle"},
		"note": "Wave 2b: 3DAssets.dev CityWolf (CC0, AI-generated, site-generated, no human author). Original GLB failed Godot import (required KHR_mesh_quantization unsupported); Blender 4.5.3 re-export (CityWolf_godot.glb, quantization stripped) imports clean: 7 meshes, 0 skeletons, node animations only (idle / head-turn / tail-wag, 1 channel each), 1 flat-colour material, 0 textures, Godot AABB 0.52 x 0.99 x 2.09 m — height-normalised to 0.85 m (boar parity), body length ~1.79 m. Only the idle clip is claimed (no attack/walk/death clips exist; attack timing lives in behaviors.gd). VISUAL REVIEW REQUIRED before shipping: James has not eyeballed this model.",
	},
	"goblin": {
		"model": _PHASE1 + "goblin-kin/goblin/goblin.glb",
		"norm_axis": "y", "target": 1.0,
		"proc_motion": true, "proc_profile": "breathe",
		"note": "True goblin (OGA, br-n518, CC0). Skinned, 39 bones, 0 clips — posed + procedural motion, never claimed animated.",
	},
	"kobold": {
		"model": _PHASE1 + "goblin-kin/goblin/goblin.glb",
		"norm_axis": "y", "target": 1.0,
		"proc_motion": true, "proc_profile": "breathe",
		"note": "James-APPROVED fallback Nov 1, 2026: goblin.glb stands in for the kobold unless a true kobold is found (same file as the goblin wire, goblin-sized — matches the spec: short, goblin-sized dragonkin). NOT a true kobold model: the hunt target is a gadget-tinker (color open — red was just one example, green/blue seen in games; dragonkin NOT required, per James Nov 1; Jeff's AI-made picture is one design reference, Jeff's description pending). Same import as goblin: skinned, 39 bones, 0 clips — posed + procedural motion, never claimed animated.",
	},
	"ghost": {
		"model": _PHASE1 + "undead/gobkit/SheetGhost.glb",
		"norm_axis": "y", "target": 1.5, "y_offset": 0.35,
		"anim": "Idle",
		"clips": {"idle": "Idle", "attack": "Attack", "death": "Death", "walk": "Walk"},
		"note": "Gobkit SheetGhost (CC0), animated. The Wraith's model. NOTE: opaque white sheet with embedded texture — NOT translucent; the old placeholder translucency check moves to the banshee only.",
	},
	"golem": {
		"model": _PHASE1 + "golems/fire-ice-stone-golem/golem_mirrored.glb",
		"norm_axis": "y", "target": 1.9,
		"anim": "idle",
		"clips": {"idle": "idle", "attack": "attack", "death": "die", "walk": "walk"},
		"note": "Wave 2b: Fire/Ice/Stone Golem (CC-BY 3.0 election CONFIRMED by James Oct 29, 2026, attribution-only terms). REQUIRED attribution if it ships: 'Fire/Ice/Stone Golem by umask007'. Imports clean (no re-export needed): 1 mesh, 3 surfaces, 44-bone skeleton, 7 honestly named clips (idle / attack / attack2 / die / flinch / walk + full-timeline ArmatureAction_001, unused); single flat 'iceBaked' grey material, 0 textures. The original wire was HALF a mesh (stone mesh weighted 100% to .L + center groups, bounds X 0 to +5.542); Nov 1, 2026 the mesh was completed by a Blender Mirror across X=0 with mirrored vertex groups (3,356 to 6,632 verts, bounds symmetric X -5.542 to +5.542, skeleton + clips intact) and THIS mirrored file was wired in place of the original — original golem.glb untouched on disk. James eyeballed the mirrored file Nov 1 ('nice'). Height-normalised to 1.90 m. VISUAL REVIEW REQUIRED before shipping: the in-game normalised golem has not been eyeballed yet, and its ice-baked pale-stone read vs the staged 'Clay Golem' name is an open eyeball question.",
	},
	"boar": {
		"model": _PHASE1 + "beasts/gobkit/Boar.glb",
		"norm_axis": "y", "target": 0.85,
		"anim": "idle",
		"clips": {"idle": "idle", "attack": "attack", "death": "dead", "walk": "walk"},
		"note": "Gobkit Boar (CC0), animated. Raw mesh is only 0.046 m tall — normalisation does the work.",
	},
	"scorpion": {
		"model": _PS1 + "enemy_scorpion.glb",
		"norm_axis": "y", "target": 0.5,
		"texture": _PS1 + "enemy_scorpion.png",
		"proc_motion": true, "proc_profile": "skitter",
		"note": "PS1 scorpion (per the Wave 2 map). Static, no skeleton/clips; texture re-linked. The animated Gobkit Scorpion is a recorded alternate, not wired, to keep one mapping per type.",
	},
	"centipede": {
		"model": _PHASE1 + "vermin/gobkit-community/GeodeCentipede.glb",
		"norm_axis": "z", "target": 1.7,
		"anim": "idle",
		"clips": {"idle": "idle", "attack": "attack", "walk": "move"},
		"note": "Gobkit community GeodeCentipede (CC0), animated. Normalised by length (z): the rest pose is 1.82 m tall (rearing), so height normalisation would shrink it to a stub. No death clip exists (idle/move/attack only).",
	},
	"skeleton_archer": {
		"model": _PHASE1 + "undead/crossbowman-skeleton/obj/skull_monster.obj",
		"norm_axis": "y", "target": 1.4,
		"proc_motion": true, "proc_profile": "breathe",
		"note": "OGA Crossbowman Skeleton (CC-BY 4.0, CoinCoin). Static OBJ; its .mtl texture (Skull_Monster_512.png) links on import, so no texture override is set. OBJ loads as an ArrayMesh, not a PackedScene — enemy.gd wraps it in a MeshInstance3D.",
	},
	"imp": {
		"model": _PHASE1 + "demons/gobkit-community/FattyImp.glb",
		"norm_axis": "y", "target": 1.0, "y_offset": 0.9,
		"anim": "idle",
		"clips": {"idle": "idle", "attack": "attack", "walk": "move"},
		"note": "Gobkit community FattyImp (CC0), animated — a real imp. Hovers (y_offset 0.9). No death clip (idle/move/attack only).",
	},
	"orc": {
		"model": _PHASE1 + "orcs-trolls/gobkit/OrcLegionary.glb",
		"norm_axis": "y", "target": 1.55,
		"anim": "Idle",
		"clips": {"idle": "Idle", "attack": "Attack", "death": "Death", "walk": "Walk"},
		"note": "Gobkit OrcLegionary (CC0), animated. Rest pose is 4.2 m wide (arms out); the Idle clip brings the arms in — rest-pose width overstates in-game width.",
	},
	"troll": {
		"model": _PHASE1 + "beasts/troll-flare/Troll.glb",
		"norm_axis": "y", "target": 2.2,
		"remove": ["ShadowPlane"],
		"anim": "Action",
		"clips": {},
		"note": "FLARE Troll (CC-BY 3.0, VWolfdog), skinned, 25 bones. ShadowPlane (20x20 m) is removed BEFORE measuring, or the body (floating at y=1.61, 0.985 m tall) normalises wrong. Clips are 8 unnamed Actions — the first is played and no idle/walk/attack mapping is claimed.",
	},
	"minotaur": {
		"model": _PHASE1 + "beasts/gobkit-community/BrazenMinotaur.glb",
		"norm_axis": "y", "target": 1.75,
		"anim": "idle",
		"clips": {"idle": "idle", "attack": "attack", "walk": "move"},
		"note": "Gobkit community BrazenMinotaur (CC0), animated — a real minotaur. No death clip (idle/move/attack only).",
	},
	"kappa": {
		"model": _PHASE1 + "yokai/snappakappa-3d/snappa-kappa.glb",
		"norm_axis": "y", "target": 1.15,
		"proc_motion": true, "proc_profile": "breathe",
		"note": "snappaKappa (CC-BY 4.0, MNDV.ecb — REQUIRED credit if it ships). Skinned, 21 bones, 0 clips — posed + procedural motion. Flat colours, no texture to link.",
	},
	"drake": {
		"model": _PHASE1 + "dragons/gobkit-community/Wyvern.glb",
		"norm_axis": "y", "target": 1.4,
		"anim": "idle",
		"clips": {"idle": "idle", "attack": "attack", "walk": "move"},
		"note": "Gobkit community Wyvern (CC0), animated — the Drake's model (winged draconic). No death clip. The static 3DAssets dragons are NOT used (static, generic, unreviewed — see wave2b-ai-models.md) and the unrigged DrakanFyr dragon is static-only.",
	},
	# --- Wave 5 (Nov 2, 2026): the 7 former procedural types get their guide-built models. ---
	"wasp": {
		"model": "res://assets/models/bestiary/winged/cave-wasp.glb",
		"norm_axis": "y", "target": 0.4, "y_offset": 0.9,
		"proc_motion": true, "proc_profile": "hover",
		"note": "Wave 5 (Nov 2, 2026): guide-built staging model (Cave Wasp), approved under the Nov 2 all-means-all directive; static, procedural hover; flat colors, texture paint pending over this same path.",
	},
	"frog": {
		"model": "res://assets/models/bestiary/aquatic/cave-frog.glb",
		"norm_axis": "y", "target": 0.4,
		"proc_motion": true, "proc_profile": "breathe",
		"note": "Wave 5 (Nov 2, 2026): guide-built staging model (Cave Frog), approved under the Nov 2 all-means-all directive; static, procedural breathe; flat colors, texture paint pending over this same path.",
	},
	"zombie": {
		"model": "res://assets/models/bestiary/biped-humanoid/zombie.glb",
		"norm_axis": "y", "target": 1.7,
		"proc_motion": true, "proc_profile": "breathe",
		"note": "Wave 5 (Nov 2, 2026): guide-built staging model (Zombie), approved under the Nov 2 all-means-all directive; static, procedural breathe; flat colors, texture paint pending over this same path.",
	},
	"pixie": {
		"model": "res://assets/models/bestiary/winged/pixie.glb",
		"norm_axis": "y", "target": 0.5, "y_offset": 1.1,
		"proc_motion": true, "proc_profile": "hover",
		"note": "Wave 5 (Nov 2, 2026): guide-built staging model (Pixie), approved under the Nov 2 all-means-all directive; static, procedural hover; flat colors, texture paint pending over this same path. Node 'Hair' renamed 'HairStrands' in the wired copy (the test suite reserves the name Hair for the rat's exploded mesh; the hair itself is untouched).",
	},
	"harpy": {
		"model": "res://assets/models/bestiary/winged/harpy.glb",
		"norm_axis": "y", "target": 1.5, "y_offset": 0.9,
		"proc_motion": true, "proc_profile": "hover",
		"note": "Wave 5 (Nov 2, 2026): guide-built staging model (Harpy), approved under the Nov 2 all-means-all directive; static, procedural hover; flat colors, texture paint pending over this same path. Node 'Hair' renamed 'HairStrands' in the wired copy (the test suite reserves the name Hair for the rat's exploded mesh; the hair itself is untouched).",
	},
	"oni": {
		"model": "res://assets/models/bestiary/biped-humanoid/oni.glb",
		"norm_axis": "y", "target": 2.0,
		"proc_motion": true, "proc_profile": "breathe",
		"note": "Wave 5 (Nov 2, 2026): guide-built staging model (Oni), approved under the Nov 2 all-means-all directive; static, procedural breathe; flat colors, texture paint pending over this same path.",
	},
	"banshee": {
		"model": "res://assets/models/bestiary/ghost-wisp/banshee.glb",
		"norm_axis": "y", "target": 1.6, "y_offset": 0.35,
		"proc_motion": true, "proc_profile": "sway",
		"note": "Wave 5 (Nov 2, 2026): guide-built staging model (Banshee), approved under the Nov 2 all-means-all directive; static, procedural sway; flat colors, texture paint pending over this same path. Translucency per its guide: body materials set BLEND alpha 0.7 in the wired copy (staging file opaque); eyes stay opaque.",
	},
}

## Roster coverage: models mapped to roster creatures that have NO
## staged TYPES entry yet (no stats invented, no spawn). They are
## recorded here so the mapping, scale, and texture work is not lost,
## and so the test suite can prove they exist and are not HELD.
## Nothing in ROSTER_MODELS is referenced by any TYPES entry.
const ROSTER_MODELS := {
	"vampire_bat": {
		"model": _PHASE1 + "vermin/vampire-bat-animated/bat_v5.glb",
		"norm_axis": "x", "target": 1.7, "y_offset": 1.1,
		"remove": ["Plane", "Frost_Bat_LP", "Frost_Bat_LP_Anim", "Armature_Frost_Bat", "Bat_LP"],
		"anim": "Bat_Flying",
		"clips": {"flying": "Bat_Flying", "attack": "Bat_Attack", "death": "Bat_Die"},
		"note": "Vampire Bat (OGA, rubberduck, CC0). Variant picked: NORMAL (Bat_LP_Anim); the frost variant, the two static copies, and the black 2x2 m ground Plane are removed. The live Cave Bat keeps its Quaternius model — this is a separate roster creature, not a replacement.",
	},
	"brigand": {
		"model": _PS1 + "enemy_bandit.glb",
		"norm_axis": "y", "target": 1.7,
		"remove": ["Plane"],
		"texture": _PS1 + "enemy_bandit.png",
		"note": "PS1 bandit (CC0, CptDrunkBear). Static. Weapon surfaces share the body texture: enemy_bandit_weapon.png is NOT per-surface mapped (meshes are not named by part) — recorded gap, roster-only so it blocks nothing.",
	},
	"revenant": {
		"model": _PS1 + "enemy_revenant.glb",
		"norm_axis": "y", "target": 1.7,
		"texture": _PS1 + "enemy_revenant.png",
		"note": "PS1 revenant (CC0). Static. Splayed pose: 6.20 m wide at rest — height normalisation keeps it standing-height but the rest width is a pose warning for any future wire-up.",
	},
	"daemon": {
		"model": _PHASE1 + "demons/flare-daemon/daemon4.glb",
		"norm_axis": "y", "target": 1.85,
		"anim": "idleAnim",
		"clips": {"idle": "idleAnim", "attack": "attack", "death": "die", "walk": "walk"},
		"note": "FLARE Daemon (CC0, ryan.dansie). Skinned, 49 bones. idle1/idle2 are 0.00 s empty clips, so idleAnim (1.29 s) is the idle clip. Roster Daemon — NOT wired to Imp (the Imp has its own FattyImp model).",
	},
	"pirate_ghost": {
		"model": _PHASE1 + "undead/pirate-crewman-ghost/piratezombiemodel.glb",
		"norm_axis": "y", "target": 1.7,
		"remove": ["ShadowPlane"],
		"anim": "Action_001",
		"clips": {},
		"note": "CALL: NOT wired to Wraith. It imports as a zombie mesh + Gibs with a 20x20 m ShadowPlane, flat materials, and 2 unnamed clips — its 'ghost' read depends on an alpha setting that does not survive in the GLB. The Wraith uses Gobkit SheetGhost instead. Kept here as its own roster creature (Pirate Ghost).",
	},
	"skeleton_outlaw": {
		"model": _PHASE1 + "undead/skeleton-outlaw/SkeletonOutlaw/Source Model/SkeletonOutlaw.fbx",
		"norm_axis": "y", "target": 1.7,
		"anim": "Default Take",
		"clips": {},
		"note": "OGA Skeleton Outlaw (CC0, KevDev). Skinned, 67 bones, one 4.97 s 'Default Take' clip; the 14 separate animation FBX files are NOT merged. Textures (SkeletonOutlaw00.png, Axe00.png) sit beside the source and link on import. Roster skeleton variant — the live Skeleton keeps Quaternius, the Archer uses the Crossbowman.",
	},
	"cannae": {
		"model": _PS1 + "enemy_cannae.glb",
		"norm_axis": "y", "target": 1.1,
		"texture": _PS1 + "enemy_cannae.png",
		"note": "PS1 pack, static, texture re-linked.",
	},
	"cereptera": {
		"model": _PS1 + "enemy_cereptera.glb",
		"norm_axis": "y", "target": 0.8,
		"texture": _PS1 + "enemy_cereptera.png",
		"note": "PS1 pack, static, texture re-linked. Floats at y=+0.94 in source; grounding (box-min to 0) fixes it on wire-up.",
	},
	"clod": {
		"model": _PS1 + "enemy_clod.glb",
		"norm_axis": "y", "target": 1.0,
		"texture": _PS1 + "enemy_clod.png",
		"note": "PS1 pack, static, texture re-linked.",
	},
	"helichard": {
		"model": _PS1 + "enemy_helichard.glb",
		"norm_axis": "y", "target": 0.7,
		"texture": _PS1 + "enemy_helichard.png",
		"note": "PS1 pack, static, texture re-linked. Floats at y=+0.99 in source; grounding fixes it on wire-up.",
	},
	"janga": {
		"model": _PS1 + "enemy_janga.glb",
		"norm_axis": "y", "target": 1.4,
		"texture": _PS1 + "enemy_janga.png",
		"note": "PS1 pack, static, texture re-linked.",
	},
	"myocene": {
		"model": _PS1 + "enemy_myocene.glb",
		"norm_axis": "y", "target": 1.0,
		"texture": _PS1 + "enemy_myocene.png",
		"note": "PS1 pack, static, texture re-linked.",
	},
	"rattler": {
		"model": _PS1 + "enemy_rattler.glb",
		"norm_axis": "z", "target": 1.7,
		"texture": _PS1 + "enemy_rattler.png",
		"note": "PS1 pack, static, texture re-linked. Serpent alternate to the cobracon (the snake's model). Node scale ~0.25 is preserved — never 'fixed' by rescaling meshes. Dips to y=-0.25 in source; grounding fixes it.",
	},
	"tardigrade": {
		"model": _PS1 + "enemy_tardigrade.glb",
		"norm_axis": "y", "target": 0.9,
		"texture": _PS1 + "enemy_tardigrade.png",
		"note": "PS1 pack, static, texture re-linked.",
	},
	"ungulate": {
		"model": _PS1 + "enemy_ungulate.glb",
		"norm_axis": "y", "target": 1.3,
		"texture": _PS1 + "enemy_ungulate.png",
		"note": "PS1 pack, static, texture re-linked.",
	},
	"cerberus": {
		"model": "res://assets/models/apex/cerberus_v003_fixed.glb",
		"norm_axis": "y", "target": 3.0,
		"anim": "Idle",
		"clips": {"idle": "Idle", "attack": "Attack", "death": "die", "walk": "Walk", "hit": "hit"},
		"note": "Cerberus (apex boss, head slot) — v003 wire Nov 4, 2026 (director-authorized; v002 shelved as fallback). Animated Cerberus (CC-BY 3.0, Clement Wu, Nikolaus & Botanic — REQUIRED attribution if it ships: 'Animated Cerberus by Clement Wu, Nikolaus & Botanic (CC-BY 3.0)'). v003 rework (Nov 2, 2026): stockier build + 6 bone horns moving with the heads, verified Godot 4.7.2 headless Nov 2: 57 nodes, 5 clips, 7 meshes, grounded, 3.0155 m, texture embedded; height-normalised to 3.0 m. The old cerberus_v002.glb (Walk only, flat grey) is reference only, never wired. James eyeballed the fixed preview Nov 4, 2026 and authorized the v003 wire; the v002 file (cerberus_v002_full.glb) stays on disk as the shelved fallback, no longer wired. Roster-only: Cerberus is an apex boss, not a staged type — no TYPES entry, no spawn.",
	},
	# --- Wave 5 (Nov 2, 2026): all 272 remaining guide-built bestiary rows (5 rows ride as MODELS code types above; wolf row disambiguated). ---
	"afanc": {
		"model": "res://assets/models/bestiary/aquatic/afanc.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Afanc (Celtic & British Isles), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ahuizotl": {
		"model": "res://assets/models/bestiary/aquatic/ahuizotl.glb",
		"norm_axis": "y", "target": 0.56,
		"note": "Ahuizotl (Mesoamerican & Andean), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cave-frog": {
		"model": "res://assets/models/bestiary/aquatic/cave-frog.glb",
		"norm_axis": "y", "target": 0.41,
		"note": "Cave Frog (Vermin & Cave Crawlers), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cipactli-brood": {
		"model": "res://assets/models/bestiary/aquatic/cipactli-brood.glb",
		"norm_axis": "y", "target": 0.52,
		"note": "Cipactli Brood (Mesoamerican & Andean), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"giant-octopus": {
		"model": "res://assets/models/bestiary/aquatic/giant-octopus.glb",
		"norm_axis": "y", "target": 0.61,
		"note": "Giant Octopus (Aquatic & the Drowned Deep), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"kelpie": {
		"model": "res://assets/models/bestiary/aquatic/kelpie.glb",
		"norm_axis": "y", "target": 1.13,
		"note": "Kelpie (Celtic & British Isles), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"kraken": {
		"model": "res://assets/models/bestiary/aquatic/kraken.glb",
		"norm_axis": "y", "target": 1.23,
		"note": "Kraken (Norse & Germanic), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"makara": {
		"model": "res://assets/models/bestiary/aquatic/makara.glb",
		"norm_axis": "y", "target": 0.48,
		"note": "Makara (also Aquatic & the Drowned Deep) (South Asian), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mami-wata": {
		"model": "res://assets/models/bestiary/aquatic/mami-wata.glb",
		"norm_axis": "y", "target": 1.03,
		"note": "Mami Wata (African Traditions), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"merrow": {
		"model": "res://assets/models/bestiary/aquatic/merrow.glb",
		"norm_axis": "y", "target": 1.06,
		"note": "Merrow (Celtic & British Isles), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"naiad": {
		"model": "res://assets/models/bestiary/aquatic/naiad.glb",
		"norm_axis": "y", "target": 1.03,
		"note": "Naiad (Fey & Nature Spirits), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"nixie": {
		"model": "res://assets/models/bestiary/aquatic/nixie.glb",
		"norm_axis": "y", "target": 1.03,
		"note": "Nixie (Norse & Germanic), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"selkie": {
		"model": "res://assets/models/bestiary/aquatic/selkie.glb",
		"norm_axis": "y", "target": 0.48,
		"note": "Selkie (Celtic & British Isles), aquatic guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"air-elemental": {
		"model": "res://assets/models/bestiary/biped-humanoid/air-elemental.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Air Elemental (Elementals & Primal Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"alfar-raider": {
		"model": "res://assets/models/bestiary/biped-humanoid/alfar-raider.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Alfar Raider (Norse & Germanic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"asag": {
		"model": "res://assets/models/bestiary/biped-humanoid/asag.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Asag (Mesopotamian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ashen-titan": {
		"model": "res://assets/models/bestiary/biped-humanoid/ashen-titan.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Ashen Titan (The Abyssal & Cosmic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"asura": {
		"model": "res://assets/models/bestiary/biped-humanoid/asura.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Asura (South Asian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"bandit-chief": {
		"model": "res://assets/models/bestiary/biped-humanoid/bandit-chief.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Bandit Chief (Humans & the Damned Living), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"barrow-wight": {
		"model": "res://assets/models/bestiary/biped-humanoid/barrow-wight.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Barrow Wight (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"bauchan": {
		"model": "res://assets/models/bestiary/biped-humanoid/bauchan.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Bauchan (Celtic & British Isles), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"berserker": {
		"model": "res://assets/models/bestiary/biped-humanoid/berserker.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Berserker (Humans & the Damned Living), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"bhuta": {
		"model": "res://assets/models/bestiary/biped-humanoid/bhuta.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Bhūta (South Asian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"boggart": {
		"model": "res://assets/models/bestiary/biped-humanoid/boggart.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Boggart (Goblin-Kin & Cave Folk), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"brownie": {
		"model": "res://assets/models/bestiary/biped-humanoid/brownie.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Brownie (Fey & Nature Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cave-troll": {
		"model": "res://assets/models/bestiary/biped-humanoid/cave-troll.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Cave Troll (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"changeling": {
		"model": "res://assets/models/bestiary/biped-humanoid/changeling.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Changeling (Fey & Nature Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"contract-devil": {
		"model": "res://assets/models/bestiary/biped-humanoid/contract-devil.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Contract Devil (Demons, Devils & the Damned), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cultist": {
		"model": "res://assets/models/bestiary/biped-humanoid/cultist.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Cultist (Humans & the Damned Living), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cyclops": {
		"model": "res://assets/models/bestiary/biped-humanoid/cyclops.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Cyclops (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"dark-elf": {
		"model": "res://assets/models/bestiary/biped-humanoid/dark-elf.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Dark Elf (Dökkálfar) (Norse & Germanic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"deva": {
		"model": "res://assets/models/bestiary/biped-humanoid/deva.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Deva (Celestials & the Fallen), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"djinn": {
		"model": "res://assets/models/bestiary/biped-humanoid/djinn.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Djinn (Demons, Devils & the Damned), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"domovoi": {
		"model": "res://assets/models/bestiary/biped-humanoid/domovoi.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Domovoi (Slavic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"draugr": {
		"model": "res://assets/models/bestiary/biped-humanoid/draugr.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Draugr (also Norse & Germanic) (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"drowned-sailor": {
		"model": "res://assets/models/bestiary/biped-humanoid/drowned-sailor.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Drowned Sailor (Aquatic & the Drowned Deep), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"dullahan": {
		"model": "res://assets/models/bestiary/biped-humanoid/dullahan.glb",
		"norm_axis": "y", "target": 0.87,
		"note": "Dullahan (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"earth-elemental": {
		"model": "res://assets/models/bestiary/biped-humanoid/earth-elemental.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Earth Elemental (Elementals & Primal Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"empusa": {
		"model": "res://assets/models/bestiary/biped-humanoid/empusa.glb",
		"norm_axis": "y", "target": 1.02,
		"note": "Empusa (Greek & Mediterranean Myth), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ettin": {
		"model": "res://assets/models/bestiary/biped-humanoid/ettin.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Ettin (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"fachan": {
		"model": "res://assets/models/bestiary/biped-humanoid/fachan.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Fachan (Celtic & British Isles), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"fallen-angel": {
		"model": "res://assets/models/bestiary/biped-humanoid/fallen-angel.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Fallen Angel (Celestials & the Fallen), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"fallen-knight": {
		"model": "res://assets/models/bestiary/biped-humanoid/fallen-knight.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Fallen Knight (Humans & the Damned Living), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"faun": {
		"model": "res://assets/models/bestiary/biped-humanoid/faun.glb",
		"norm_axis": "y", "target": 0.87,
		"note": "Faun (Fey & Nature Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"fire-elemental": {
		"model": "res://assets/models/bestiary/biped-humanoid/fire-elemental.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Fire Elemental (Elementals & Primal Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"fire-giant": {
		"model": "res://assets/models/bestiary/biped-humanoid/fire-giant.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Fire Giant (also Norse & Germanic) (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"frost-elemental": {
		"model": "res://assets/models/bestiary/biped-humanoid/frost-elemental.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Frost Elemental (Elementals & Primal Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"frost-giant": {
		"model": "res://assets/models/bestiary/biped-humanoid/frost-giant.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Frost Giant (also Norse & Germanic) (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"galla": {
		"model": "res://assets/models/bestiary/biped-humanoid/galla.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Galla (Mesopotamian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"gashadokuro": {
		"model": "res://assets/models/bestiary/biped-humanoid/gashadokuro.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Gashadokuro (also Japanese Yōkai) (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ghoul": {
		"model": "res://assets/models/bestiary/biped-humanoid/ghoul.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Ghoul (also Demons, Devils & the Damned) (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"gnome": {
		"model": "res://assets/models/bestiary/biped-humanoid/gnome.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Gnome (Elementals & Primal Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"goblin-champion": {
		"model": "res://assets/models/bestiary/biped-humanoid/goblin-champion.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Goblin Champion (Goblin-Kin & Cave Folk), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"goblin-shaman": {
		"model": "res://assets/models/bestiary/biped-humanoid/goblin-shaman.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Goblin Shaman (Goblin-Kin & Cave Folk), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"goblin-sneak": {
		"model": "res://assets/models/bestiary/biped-humanoid/goblin-sneak.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Goblin Sneak (Goblin-Kin & Cave Folk), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"gorgon": {
		"model": "res://assets/models/bestiary/biped-humanoid/gorgon.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Gorgon (Greek & Mediterranean Myth), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"grave-robber": {
		"model": "res://assets/models/bestiary/biped-humanoid/grave-robber.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Grave Robber (Humans & the Damned Living), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"gremlin": {
		"model": "res://assets/models/bestiary/biped-humanoid/gremlin.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Gremlin (Goblin-Kin & Cave Folk), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"half-ogre": {
		"model": "res://assets/models/bestiary/biped-humanoid/half-ogre.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Half-Ogre (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"hill-giant": {
		"model": "res://assets/models/bestiary/biped-humanoid/hill-giant.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Hill Giant (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"hobgoblin": {
		"model": "res://assets/models/bestiary/biped-humanoid/hobgoblin.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Hobgoblin (Goblin-Kin & Cave Folk), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"hulder": {
		"model": "res://assets/models/bestiary/biped-humanoid/hulder.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Hulder (Norse & Germanic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ifrit": {
		"model": "res://assets/models/bestiary/biped-humanoid/ifrit.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Ifrit (Demons, Devils & the Damned), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"incubus": {
		"model": "res://assets/models/bestiary/biped-humanoid/incubus.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Incubus (Demons, Devils & the Damned), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"jiangshi": {
		"model": "res://assets/models/bestiary/biped-humanoid/jiangshi.glb",
		"norm_axis": "y", "target": 1.05,
		"note": "Jiangshi (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"kikimora": {
		"model": "res://assets/models/bestiary/biped-humanoid/kikimora.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Kikimora (Slavic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"lanternjaw": {
		"model": "res://assets/models/bestiary/biped-humanoid/lanternjaw.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Lanternjaw (Aquatic & the Drowned Deep), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"lich": {
		"model": "res://assets/models/bestiary/biped-humanoid/lich.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Lich (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mad-alchemist": {
		"model": "res://assets/models/bestiary/biped-humanoid/mad-alchemist.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Mad Alchemist (Humans & the Damned Living), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"magma-elemental": {
		"model": "res://assets/models/bestiary/biped-humanoid/magma-elemental.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Magma Elemental (Elementals & Primal Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"marid": {
		"model": "res://assets/models/bestiary/biped-humanoid/marid.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Marid (Demons, Devils & the Damned), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"marsh-troll": {
		"model": "res://assets/models/bestiary/biped-humanoid/marsh-troll.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Marsh Troll (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mogwai": {
		"model": "res://assets/models/bestiary/biped-humanoid/mogwai.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Mogwai (Chinese & East Asian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mora": {
		"model": "res://assets/models/bestiary/biped-humanoid/mora.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Mora (Slavic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mountain-yaoguai": {
		"model": "res://assets/models/bestiary/biped-humanoid/mountain-yaoguai.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Mountain Yaoguai (Chinese & East Asian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mummy": {
		"model": "res://assets/models/bestiary/biped-humanoid/mummy.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Mummy (also Egyptian & Near East) (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mushussu": {
		"model": "res://assets/models/bestiary/biped-humanoid/mushussu.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Mušḫuššu (Mesopotamian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"necromancer": {
		"model": "res://assets/models/bestiary/biped-humanoid/necromancer.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Necromancer (Humans & the Damned Living), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"nue": {
		"model": "res://assets/models/bestiary/biped-humanoid/nue.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Nue (Japanese Yōkai), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ogre": {
		"model": "res://assets/models/bestiary/biped-humanoid/ogre.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Ogre (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ogre-mage": {
		"model": "res://assets/models/bestiary/biped-humanoid/ogre-mage.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Ogre Mage (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"orc-berserker": {
		"model": "res://assets/models/bestiary/biped-humanoid/orc-berserker.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Orc Berserker (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"orc-shaman": {
		"model": "res://assets/models/bestiary/biped-humanoid/orc-shaman.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Orc Shaman (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"pisaca": {
		"model": "res://assets/models/bestiary/biped-humanoid/pisaca.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Piśāca (South Asian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"pit-brute": {
		"model": "res://assets/models/bestiary/biped-humanoid/pit-brute.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Pit Brute (Demons, Devils & the Damned), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"possessed-cultist": {
		"model": "res://assets/models/bestiary/biped-humanoid/possessed-cultist.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Possessed Cultist (Demons, Devils & the Damned), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"puca": {
		"model": "res://assets/models/bestiary/biped-humanoid/puca.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Púca (also Celtic & British Isles) (Goblin-Kin & Cave Folk), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"rakshasa": {
		"model": "res://assets/models/bestiary/biped-humanoid/rakshasa.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Rakshasa (South Asian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"redcap": {
		"model": "res://assets/models/bestiary/biped-humanoid/redcap.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Redcap (also Celtic & British Isles) (Goblin-Kin & Cave Folk), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"rusalka": {
		"model": "res://assets/models/bestiary/biped-humanoid/rusalka.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Rusalka (also Aquatic & the Drowned Deep) (Slavic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"satyr": {
		"model": "res://assets/models/bestiary/biped-humanoid/satyr.glb",
		"norm_axis": "y", "target": 1.04,
		"note": "Satyr (Greek & Mediterranean Myth), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"shaitan": {
		"model": "res://assets/models/bestiary/biped-humanoid/shaitan.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Shaitan (Demons, Devils & the Damned), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"skeleton-knight": {
		"model": "res://assets/models/bestiary/biped-humanoid/skeleton-knight.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Skeleton Knight (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"spriggan": {
		"model": "res://assets/models/bestiary/biped-humanoid/spriggan.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Spriggan (also Celtic & British Isles) (Goblin-Kin & Cave Folk), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"star-horror": {
		"model": "res://assets/models/bestiary/biped-humanoid/star-horror.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Star Horror (The Abyssal & Cosmic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"stone-giant": {
		"model": "res://assets/models/bestiary/biped-humanoid/stone-giant.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Stone Giant (Orcs, Trolls & Giant-Kin), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"storm-elemental": {
		"model": "res://assets/models/bestiary/biped-humanoid/storm-elemental.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Storm Elemental (Elementals & Primal Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"striga": {
		"model": "res://assets/models/bestiary/biped-humanoid/striga.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Striga (Slavic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"strigoi": {
		"model": "res://assets/models/bestiary/biped-humanoid/strigoi.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Strigoi (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"succubus": {
		"model": "res://assets/models/bestiary/biped-humanoid/succubus.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Succubus (Demons, Devils & the Damned), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"taotie": {
		"model": "res://assets/models/bestiary/biped-humanoid/taotie.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Taotie (Chinese & East Asian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"titan": {
		"model": "res://assets/models/bestiary/biped-humanoid/titan.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Titan (The Abyssal & Cosmic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"tokoloshe": {
		"model": "res://assets/models/bestiary/biped-humanoid/tokoloshe.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Tokoloshe (African Traditions), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"tzitzimitl": {
		"model": "res://assets/models/bestiary/biped-humanoid/tzitzimitl.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Tzitzimitl (Mesoamerican & Andean), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ugallu": {
		"model": "res://assets/models/bestiary/biped-humanoid/ugallu.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Ugallu (Mesopotamian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"undine": {
		"model": "res://assets/models/bestiary/biped-humanoid/undine.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Undine (Elementals & Primal Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"vampire": {
		"model": "res://assets/models/bestiary/biped-humanoid/vampire.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Vampire (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"vetala": {
		"model": "res://assets/models/bestiary/biped-humanoid/vetala.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Vetala (also South Asian) (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"vodyanoy": {
		"model": "res://assets/models/bestiary/biped-humanoid/vodyanoy.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Vodyanoy (Slavic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"void-horror": {
		"model": "res://assets/models/bestiary/biped-humanoid/void-horror.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Void Horror (The Abyssal & Cosmic), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"warlock": {
		"model": "res://assets/models/bestiary/biped-humanoid/warlock.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Warlock (Humans & the Damned Living), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"watcher": {
		"model": "res://assets/models/bestiary/biped-humanoid/watcher.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Watcher (Grigori) (Celestials & the Fallen), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"water-elemental": {
		"model": "res://assets/models/bestiary/biped-humanoid/water-elemental.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Water Elemental (Elementals & Primal Spirits), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"wight-lord": {
		"model": "res://assets/models/bestiary/biped-humanoid/wight-lord.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Wight Lord (The Undead), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"witch": {
		"model": "res://assets/models/bestiary/biped-humanoid/witch.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Witch (Humans & the Damned Living), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"yaksha": {
		"model": "res://assets/models/bestiary/biped-humanoid/yaksha.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Yaksha (South Asian), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"yuki-onna": {
		"model": "res://assets/models/bestiary/biped-humanoid/yuki-onna.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Yuki-onna (Japanese Yōkai), biped-humanoid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"acid-blob": {
		"model": "res://assets/models/bestiary/blob-ooze/acid-blob.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Acid Blob (Oozes & Slimes), blob-ooze guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"amber-ooze": {
		"model": "res://assets/models/bestiary/blob-ooze/amber-ooze.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Amber Ooze (Oozes & Slimes), blob-ooze guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cave-jelly": {
		"model": "res://assets/models/bestiary/blob-ooze/cave-jelly.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Cave Jelly (Oozes & Slimes), blob-ooze guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"gloom-ooze": {
		"model": "res://assets/models/bestiary/blob-ooze/gloom-ooze.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Gloom Ooze (Oozes & Slimes), blob-ooze guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"hundun": {
		"model": "res://assets/models/bestiary/blob-ooze/hundun.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Hundun (Chinese & East Asian), blob-ooze guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mercury-slime": {
		"model": "res://assets/models/bestiary/blob-ooze/mercury-slime.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Mercury Slime (Oozes & Slimes), blob-ooze guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mire-pudding": {
		"model": "res://assets/models/bestiary/blob-ooze/mire-pudding.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Mire Pudding (Oozes & Slimes), blob-ooze guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"primordial-ooze": {
		"model": "res://assets/models/bestiary/blob-ooze/primordial-ooze.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Primordial Ooze (Oozes & Slimes), blob-ooze guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"adze": {
		"model": "res://assets/models/bestiary/ghost-wisp/adze.glb",
		"norm_axis": "y", "target": 1.0, "y_offset": 0.3,
		"note": "Adze (African Traditions), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"bean-nighe": {
		"model": "res://assets/models/bestiary/ghost-wisp/bean-nighe.glb",
		"norm_axis": "y", "target": 1.0, "y_offset": 0.3,
		"note": "Bean-nighe (Celtic & British Isles), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"chochin-obake": {
		"model": "res://assets/models/bestiary/ghost-wisp/chochin-obake.glb",
		"norm_axis": "y", "target": 0.8, "y_offset": 0.3,
		"note": "Chōchin-obake (Japanese Yōkai), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"entropy-wraith": {
		"model": "res://assets/models/bestiary/ghost-wisp/entropy-wraith.glb",
		"norm_axis": "y", "target": 0.98, "y_offset": 0.3,
		"note": "Entropy Wraith (The Abyssal & Cosmic), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"living-shadow": {
		"model": "res://assets/models/bestiary/ghost-wisp/living-shadow.glb",
		"norm_axis": "y", "target": 1.0, "y_offset": 0.3,
		"note": "Living Shadow (The Abyssal & Cosmic), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mare": {
		"model": "res://assets/models/bestiary/ghost-wisp/mare.glb",
		"norm_axis": "y", "target": 0.8, "y_offset": 0.3,
		"note": "Mare (Norse & Germanic), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"penanggalan": {
		"model": "res://assets/models/bestiary/ghost-wisp/penanggalan.glb",
		"norm_axis": "y", "target": 1.0, "y_offset": 0.3,
		"note": "Penanggalan (The Undead), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"phantom": {
		"model": "res://assets/models/bestiary/ghost-wisp/phantom.glb",
		"norm_axis": "y", "target": 1.0, "y_offset": 0.3,
		"note": "Phantom (The Undead), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"poltergeist": {
		"model": "res://assets/models/bestiary/ghost-wisp/poltergeist.glb",
		"norm_axis": "y", "target": 1.0, "y_offset": 0.3,
		"note": "Poltergeist (The Undead), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"sluagh": {
		"model": "res://assets/models/bestiary/ghost-wisp/sluagh.glb",
		"norm_axis": "y", "target": 0.98, "y_offset": 0.3,
		"note": "Sluagh (also Celtic & British Isles) (The Undead), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"specter": {
		"model": "res://assets/models/bestiary/ghost-wisp/specter.glb",
		"norm_axis": "y", "target": 1.0, "y_offset": 0.3,
		"note": "Specter (The Undead), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"storm-wraith": {
		"model": "res://assets/models/bestiary/ghost-wisp/storm-wraith.glb",
		"norm_axis": "y", "target": 0.98, "y_offset": 0.3,
		"note": "Storm Wraith (Mesoamerican & Andean), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"the-hollow-choir": {
		"model": "res://assets/models/bestiary/ghost-wisp/the-hollow-choir.glb",
		"norm_axis": "y", "target": 1.0, "y_offset": 0.3,
		"note": "The Hollow Choir (The Abyssal & Cosmic), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"will-o-wisp": {
		"model": "res://assets/models/bestiary/ghost-wisp/will-o-wisp.glb",
		"norm_axis": "y", "target": 0.35, "y_offset": 0.3,
		"note": "Will-o'-wisp (Fey & Nature Spirits), ghost-wisp guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"bone-golem": {
		"model": "res://assets/models/bestiary/golem-construct/bone-golem.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Bone Golem (Golems & Constructs), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"brass-automaton": {
		"model": "res://assets/models/bestiary/golem-construct/brass-automaton.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Brass Automaton (Golems & Constructs), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"crystal-golem": {
		"model": "res://assets/models/bestiary/golem-construct/crystal-golem.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Crystal Golem (Golems & Constructs), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"gargoyle": {
		"model": "res://assets/models/bestiary/golem-construct/gargoyle.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Gargoyle (Golems & Constructs), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"golem-fire": {
		"model": "res://assets/models/bestiary/golem-construct/golem-fire.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Golem Fire (Golems & Constructs), golem variant wire Nov 4, 2026: geometrically-differentiated variant of the golem proof mesh (3 back spikes + 5 lava drips), painted with the Nov 2 golem_fire 512 texture (per-material LINEAR). Emissive lava-drip and rune materials left untextured by rule. Behavior: see design-notes/golem-variant-behaviors.md. Roster-only: no TYPES entry, no spawn.",
	},
	"golem-ice": {
		"model": "res://assets/models/bestiary/golem-construct/golem-ice.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Golem Ice (Golems & Constructs), golem variant wire Nov 4, 2026: geometrically-differentiated variant of the golem proof mesh (6 icicles + 2 crystal shards), painted with the Nov 2 golem_ice 512 texture (per-material LINEAR). Emissive rune materials left untextured by rule. Behavior: see design-notes/golem-variant-behaviors.md. Roster-only: no TYPES entry, no spawn.",
	},
	"golem-stone": {
		"model": "res://assets/models/bestiary/golem-construct/golem-stone.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Golem Stone (Golems & Constructs), golem variant wire Nov 4, 2026: geometrically-differentiated variant of the golem proof mesh (6 moss clumps + 4 vine strands), painted with the Nov 2 golem_stone 512 texture (per-material LINEAR). Emissive rune materials left untextured by rule. Behavior: see design-notes/golem-variant-behaviors.md. Roster-only: no TYPES entry, no spawn.",
	},
	"golem-storm": {
		"model": "res://assets/models/bestiary/golem-construct/golem-storm.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Golem Storm (Golems & Constructs), golem variant wire Nov 4, 2026: geometrically-differentiated variant of the golem proof mesh (2 shoulder lightning rods + 3 zigzag bolts), painted with the Nov 2 golem_storm 512 texture (per-material LINEAR). Emissive bolt and rune materials left untextured by rule. Behavior: see design-notes/golem-variant-behaviors.md. Roster-only: no TYPES entry, no spawn.",
	},
	"golem-water": {
		"model": "res://assets/models/bestiary/golem-construct/golem-water.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Golem Water (Golems & Constructs), golem variant wire Nov 4, 2026: geometrically-differentiated variant of the golem proof mesh (2 coral blobs + 3 seaweed strands per foot), painted with the Nov 2 golem_water 512 texture (per-material LINEAR). Emissive rune materials left untextured by rule. Behavior: see design-notes/golem-variant-behaviors.md. Roster-only: no TYPES entry, no spawn.",
	},
	"haunted-armor": {
		"model": "res://assets/models/bestiary/golem-construct/haunted-armor.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Haunted Armor (Golems & Constructs), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"iron-golem": {
		"model": "res://assets/models/bestiary/golem-construct/iron-golem.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Iron Golem (Golems & Constructs), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"karakasa": {
		"model": "res://assets/models/bestiary/golem-construct/karakasa.glb",
		"norm_axis": "y", "target": 0.97,
		"note": "Karakasa (Japanese Yōkai), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"living-statue": {
		"model": "res://assets/models/bestiary/golem-construct/living-statue.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Living Statue (Golems & Constructs), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ophanim": {
		"model": "res://assets/models/bestiary/golem-construct/ophanim.glb",
		"norm_axis": "y", "target": 0.94,
		"note": "Ophanim (Celestials & the Fallen), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"stone-golem": {
		"model": "res://assets/models/bestiary/golem-construct/stone-golem.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Stone Golem (Golems & Constructs), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"terracotta-soldier": {
		"model": "res://assets/models/bestiary/golem-construct/terracotta-soldier.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Terracotta Soldier (also Golems & Constructs) (Chinese & East Asian), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ushabti": {
		"model": "res://assets/models/bestiary/golem-construct/ushabti.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Ushabti (also Golems & Constructs) (Egyptian & Near East), golem-construct guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cedar-guardian": {
		"model": "res://assets/models/bestiary/plant-fungal/cedar-guardian.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Cedar Guardian (Mesopotamian), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"corpse-flower": {
		"model": "res://assets/models/bestiary/plant-fungal/corpse-flower.glb",
		"norm_axis": "y", "target": 1.15,
		"note": "Corpse Flower (Plants & Fungi), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"dryad": {
		"model": "res://assets/models/bestiary/plant-fungal/dryad.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Dryad (also Plants & Fungi) (Fey & Nature Spirits), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"elder-dryad": {
		"model": "res://assets/models/bestiary/plant-fungal/elder-dryad.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Elder Dryad (also Plants & Fungi) (Fey & Nature Spirits), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"fungal-shambler": {
		"model": "res://assets/models/bestiary/plant-fungal/fungal-shambler.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Fungal Shambler (Plants & Fungi), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"grotto-snapper": {
		"model": "res://assets/models/bestiary/plant-fungal/grotto-snapper.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Grotto Snapper (Plants & Fungi), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"leshy": {
		"model": "res://assets/models/bestiary/plant-fungal/leshy.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Leshy (also Plants & Fungi) (Slavic), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"mandrake": {
		"model": "res://assets/models/bestiary/plant-fungal/mandrake.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Mandrake (Plants & Fungi), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"spore-servant": {
		"model": "res://assets/models/bestiary/plant-fungal/spore-servant.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Spore Servant (Plants & Fungi), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"vampire-vine": {
		"model": "res://assets/models/bestiary/plant-fungal/vampire-vine.glb",
		"norm_axis": "y", "target": 0.2,
		"note": "Vampire Vine (Plants & Fungi), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"walking-oak": {
		"model": "res://assets/models/bestiary/plant-fungal/walking-oak.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Walking Oak (Plants & Fungi), plant-fungal guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"baboon-troop": {
		"model": "res://assets/models/bestiary/quadruped-beast/baboon-troop.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Baboon Troop (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"bake-danuki": {
		"model": "res://assets/models/bestiary/quadruped-beast/bake-danuki.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Bake-danuki (Japanese Yōkai), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"blind-mole": {
		"model": "res://assets/models/bestiary/quadruped-beast/blind-mole.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Blind Mole (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"bramble-imp": {
		"model": "res://assets/models/bestiary/quadruped-beast/bramble-imp.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Bramble Imp (Fey & Nature Spirits), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"bronze-bull": {
		"model": "res://assets/models/bestiary/quadruped-beast/bronze-bull.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Bronze Bull (Greek & Mediterranean Myth), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"bugbear": {
		"model": "res://assets/models/bestiary/quadruped-beast/bugbear.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Bugbear (Goblin-Kin & Cave Folk), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cat-sith": {
		"model": "res://assets/models/bestiary/quadruped-beast/cat-sith.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Cat Sìth (Celtic & British Isles), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cave-ape": {
		"model": "res://assets/models/bestiary/quadruped-beast/cave-ape.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Cave Ape (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cave-bear": {
		"model": "res://assets/models/bestiary/quadruped-beast/cave-bear.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Cave Bear (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cave-hyena": {
		"model": "res://assets/models/bestiary/quadruped-beast/cave-hyena.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Cave Hyena (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"centaur": {
		"model": "res://assets/models/bestiary/quadruped-beast/centaur.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Centaur (Greek & Mediterranean Myth), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"chimera": {
		"model": "res://assets/models/bestiary/quadruped-beast/chimera.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Chimera (Greek & Mediterranean Myth), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"crag-ram": {
		"model": "res://assets/models/bestiary/quadruped-beast/crag-ram.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Crag Ram (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"crocodile": {
		"model": "res://assets/models/bestiary/quadruped-beast/crocodile.glb",
		"norm_axis": "y", "target": 0.6,
		"note": "Crocodile (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"deep-stag": {
		"model": "res://assets/models/bestiary/quadruped-beast/deep-stag.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Deep Stag (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"devourer-beast": {
		"model": "res://assets/models/bestiary/quadruped-beast/devourer-beast.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Devourer Beast (Egyptian & Near East), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"dire-wolf": {
		"model": "res://assets/models/bestiary/quadruped-beast/dire-wolf.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Dire Wolf (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"falcon-sphinx": {
		"model": "res://assets/models/bestiary/quadruped-beast/falcon-sphinx.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Falcon Sphinx (Egyptian & Near East), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"giant-rat": {
		"model": "res://assets/models/bestiary/quadruped-beast/giant-rat.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Giant Rat (Vermin & Cave Crawlers), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"great-wolf": {
		"model": "res://assets/models/bestiary/quadruped-beast/great-wolf.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Great Wolf (Norse & Germanic), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"grizzly": {
		"model": "res://assets/models/bestiary/quadruped-beast/grizzly.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Grizzly (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"grotto-bull": {
		"model": "res://assets/models/bestiary/quadruped-beast/grotto-bull.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Grotto Bull (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"hulijing": {
		"model": "res://assets/models/bestiary/quadruped-beast/hulijing.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Hulijing (Chinese & East Asian), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"hyena": {
		"model": "res://assets/models/bestiary/quadruped-beast/hyena.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Hyena (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"jackal-guardian": {
		"model": "res://assets/models/bestiary/quadruped-beast/jackal-guardian.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Jackal Guardian (Egyptian & Near East), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"kasha": {
		"model": "res://assets/models/bestiary/quadruped-beast/kasha.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Kasha (Japanese Yōkai), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"kitsune": {
		"model": "res://assets/models/bestiary/quadruped-beast/kitsune.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Kitsune (Japanese Yōkai), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"lamassu": {
		"model": "res://assets/models/bestiary/quadruped-beast/lamassu.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Lamassu (Mesopotamian), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"lion": {
		"model": "res://assets/models/bestiary/quadruped-beast/lion.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Lion (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"manticore": {
		"model": "res://assets/models/bestiary/quadruped-beast/manticore.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Manticore (Greek & Mediterranean Myth), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"nagual": {
		"model": "res://assets/models/bestiary/quadruped-beast/nagual.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Nagual (Mesoamerican & Andean), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"nemean-lion": {
		"model": "res://assets/models/bestiary/quadruped-beast/nemean-lion.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Nemean Lion (Greek & Mediterranean Myth), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"pale-horse": {
		"model": "res://assets/models/bestiary/quadruped-beast/pale-horse.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Pale Horse (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"panther": {
		"model": "res://assets/models/bestiary/quadruped-beast/panther.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Panther (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"peluda": {
		"model": "res://assets/models/bestiary/quadruped-beast/peluda.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Peluda (Dragons & Great Serpents), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"plague-bearer": {
		"model": "res://assets/models/bestiary/quadruped-beast/plague-bearer.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Plague Bearer (Humans & the Damned Living), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"qilin-corrupted": {
		"model": "res://assets/models/bestiary/quadruped-beast/qilin-corrupted.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Qilin, Corrupted (Chinese & East Asian), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"razorback": {
		"model": "res://assets/models/bestiary/quadruped-beast/razorback.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Razorback (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"sabertooth": {
		"model": "res://assets/models/bestiary/quadruped-beast/sabertooth.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Sabertooth (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"salamander": {
		"model": "res://assets/models/bestiary/quadruped-beast/salamander.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Salamander (Elementals & Primal Spirits), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"sha-beast": {
		"model": "res://assets/models/bestiary/quadruped-beast/sha-beast.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Sha Beast (Egyptian & Near East), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"sphinx": {
		"model": "res://assets/models/bestiary/quadruped-beast/sphinx.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Sphinx (Greek & Mediterranean Myth), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"tarasque": {
		"model": "res://assets/models/bestiary/quadruped-beast/tarasque.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Tarasque (Dragons & Great Serpents), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"thornhound": {
		"model": "res://assets/models/bestiary/quadruped-beast/thornhound.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Thornhound (Plants & Fungi), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"tiger": {
		"model": "res://assets/models/bestiary/quadruped-beast/tiger.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Tiger (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"warhound": {
		"model": "res://assets/models/bestiary/quadruped-beast/warhound.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Warhound (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"wolf_bestiary": {
		"model": "res://assets/models/bestiary/quadruped-beast/wolf.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Wolf (Beasts), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path. NOT the staged code type wolf (CityWolf wire stands).",
	},
	"xiezhi": {
		"model": "res://assets/models/bestiary/quadruped-beast/xiezhi.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Xiezhi (Chinese & East Asian), quadruped-beast guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"deep-crab": {
		"model": "res://assets/models/bestiary/spider-arachnid/deep-crab.glb",
		"norm_axis": "y", "target": 0.45,
		"note": "Deep Crab (Aquatic & the Drowned Deep), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"emperor-scorpion": {
		"model": "res://assets/models/bestiary/spider-arachnid/emperor-scorpion.glb",
		"norm_axis": "y", "target": 0.73,
		"note": "Emperor Scorpion (Vermin & Cave Crawlers), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"guardian-scorpion": {
		"model": "res://assets/models/bestiary/spider-arachnid/guardian-scorpion.glb",
		"norm_axis": "y", "target": 0.73,
		"note": "Guardian Scorpion (Egyptian & Near East), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"jorogumo": {
		"model": "res://assets/models/bestiary/spider-arachnid/jorogumo.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Jorōgumo (Japanese Yōkai), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"omukade": {
		"model": "res://assets/models/bestiary/spider-arachnid/omukade.glb",
		"norm_axis": "z", "target": 1.0,
		"note": "Ōmukade (also Japanese Yōkai) (Vermin & Cave Crawlers), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"rat-swarm": {
		"model": "res://assets/models/bestiary/spider-arachnid/rat-swarm.glb",
		"norm_axis": "y", "target": 0.35,
		"note": "Rat Swarm (Vermin & Cave Crawlers), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"scarab-swarm": {
		"model": "res://assets/models/bestiary/spider-arachnid/scarab-swarm.glb",
		"norm_axis": "y", "target": 0.5,
		"note": "Scarab Swarm (Egyptian & Near East), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"scorpion-man": {
		"model": "res://assets/models/bestiary/spider-arachnid/scorpion-man.glb",
		"norm_axis": "y", "target": 0.99,
		"note": "Scorpion Man (Mesopotamian), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"stag-beetle": {
		"model": "res://assets/models/bestiary/spider-arachnid/stag-beetle.glb",
		"norm_axis": "y", "target": 0.51,
		"note": "Stag Beetle (Vermin & Cave Crawlers), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"tsuchigumo": {
		"model": "res://assets/models/bestiary/spider-arachnid/tsuchigumo.glb",
		"norm_axis": "y", "target": 0.4,
		"note": "Tsuchigumo (Japanese Yōkai), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"widow-spider": {
		"model": "res://assets/models/bestiary/spider-arachnid/widow-spider.glb",
		"norm_axis": "y", "target": 0.45,
		"note": "Widow Spider (Vermin & Cave Crawlers), spider-arachnid guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"alkonost": {
		"model": "res://assets/models/bestiary/winged/alkonost.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Alkonost (Slavic), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"anzu": {
		"model": "res://assets/models/bestiary/winged/anzu.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Anzu (also Sky & Storm) (Mesopotamian), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ashen-seraph": {
		"model": "res://assets/models/bestiary/winged/ashen-seraph.glb",
		"norm_axis": "y", "target": 1.13,
		"note": "Ashen Seraph (Celestials & the Fallen), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cave-wasp": {
		"model": "res://assets/models/bestiary/winged/cave-wasp.glb",
		"norm_axis": "y", "target": 0.5,
		"note": "Cave Wasp (Vermin & Cave Crawlers), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cockatrice": {
		"model": "res://assets/models/bestiary/winged/cockatrice.glb",
		"norm_axis": "y", "target": 0.83,
		"note": "Cockatrice (Dragons & Great Serpents), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"death-bat": {
		"model": "res://assets/models/bestiary/winged/death-bat.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Death Bat (Mesoamerican & Andean), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"fallen-valkyrie": {
		"model": "res://assets/models/bestiary/winged/fallen-valkyrie.glb",
		"norm_axis": "y", "target": 1.11,
		"note": "Fallen Valkyrie (Norse & Germanic), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"firebird": {
		"model": "res://assets/models/bestiary/winged/firebird.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Firebird (also Sky & Storm) (Slavic), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"gamayun": {
		"model": "res://assets/models/bestiary/winged/gamayun.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Gamayun (Slavic), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"garuda": {
		"model": "res://assets/models/bestiary/winged/garuda.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Garuda (also Sky & Storm) (South Asian), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"griffin": {
		"model": "res://assets/models/bestiary/winged/griffin.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Griffin (also Sky & Storm) (Greek & Mediterranean Myth), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"hornet-matriarch": {
		"model": "res://assets/models/bestiary/winged/hornet-matriarch.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Hornet Matriarch (Vermin & Cave Crawlers), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"impundulu": {
		"model": "res://assets/models/bestiary/winged/impundulu.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Impundulu (also Sky & Storm) (African Traditions), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"null-seraph": {
		"model": "res://assets/models/bestiary/winged/null-seraph.glb",
		"norm_axis": "y", "target": 1.13,
		"note": "Null Seraph (The Abyssal & Cosmic), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"phoenix": {
		"model": "res://assets/models/bestiary/winged/phoenix.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Phoenix (Sky & Storm), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"roc": {
		"model": "res://assets/models/bestiary/winged/roc.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Roc (Sky & Storm), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"sasabonsam": {
		"model": "res://assets/models/bestiary/winged/sasabonsam.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Sasabonsam (African Traditions), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"seraph": {
		"model": "res://assets/models/bestiary/winged/seraph.glb",
		"norm_axis": "y", "target": 1.13,
		"note": "Seraph (Celestials & the Fallen), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"simurgh": {
		"model": "res://assets/models/bestiary/winged/simurgh.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Simurgh (Sky & Storm), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"siren": {
		"model": "res://assets/models/bestiary/winged/siren.glb",
		"norm_axis": "y", "target": 1.09,
		"note": "Siren (Greek & Mediterranean Myth), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"sprite": {
		"model": "res://assets/models/bestiary/winged/sprite.glb",
		"norm_axis": "y", "target": 0.31,
		"note": "Sprite (Fey & Nature Spirits), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"storm-crow": {
		"model": "res://assets/models/bestiary/winged/storm-crow.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Storm Crow (Sky & Storm), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"stymphalian-bird": {
		"model": "res://assets/models/bestiary/winged/stymphalian-bird.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Stymphalian Bird (also Sky & Storm) (Greek & Mediterranean Myth), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"sylph": {
		"model": "res://assets/models/bestiary/winged/sylph.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Sylph (also Elementals & Primal Spirits) (Fey & Nature Spirits), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"tengu": {
		"model": "res://assets/models/bestiary/winged/tengu.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Tengu (Japanese Yōkai), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"thunderbird": {
		"model": "res://assets/models/bestiary/winged/thunderbird.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Thunderbird (Sky & Storm), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ur-dragon": {
		"model": "res://assets/models/bestiary/winged/ur-dragon.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Ur-Dragon (The Abyssal & Cosmic), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"wyvern": {
		"model": "res://assets/models/bestiary/winged/wyvern.glb",
		"norm_axis": "y", "target": 0.98,
		"note": "Wyvern (Dragons & Great Serpents), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"ziz": {
		"model": "res://assets/models/bestiary/winged/ziz.glb",
		"norm_axis": "y", "target": 1.0,
		"note": "Ziz (Sky & Storm), winged guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"amphiptere": {
		"model": "res://assets/models/bestiary/worm-serpent/amphiptere.glb",
		"norm_axis": "z", "target": 2.38,
		"note": "Amphiptere (Dragons & Great Serpents), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"asp": {
		"model": "res://assets/models/bestiary/worm-serpent/asp.glb",
		"norm_axis": "z", "target": 1.18,
		"note": "Asp (Egyptian & Near East), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"basilisk": {
		"model": "res://assets/models/bestiary/worm-serpent/basilisk.glb",
		"norm_axis": "z", "target": 2.16,
		"note": "Basilisk (Dragons & Great Serpents), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"burrow-worm": {
		"model": "res://assets/models/bestiary/worm-serpent/burrow-worm.glb",
		"norm_axis": "z", "target": 2.25,
		"note": "Burrow Worm (Vermin & Cave Crawlers), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"carrion-worm": {
		"model": "res://assets/models/bestiary/worm-serpent/carrion-worm.glb",
		"norm_axis": "z", "target": 2.25,
		"note": "Carrion Worm (Vermin & Cave Crawlers), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cave-moray": {
		"model": "res://assets/models/bestiary/worm-serpent/cave-moray.glb",
		"norm_axis": "z", "target": 2.16,
		"note": "Cave Moray (Aquatic & the Drowned Deep), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"cave-python": {
		"model": "res://assets/models/bestiary/worm-serpent/cave-python.glb",
		"norm_axis": "z", "target": 2.16,
		"note": "Cave Python (Beasts), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"elder-wyrm": {
		"model": "res://assets/models/bestiary/worm-serpent/elder-wyrm.glb",
		"norm_axis": "z", "target": 2.55,
		"note": "Elder Wyrm (Dragons & Great Serpents), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"hydra": {
		"model": "res://assets/models/bestiary/worm-serpent/hydra.glb",
		"norm_axis": "z", "target": 1.41,
		"note": "Hydra (Greek & Mediterranean Myth), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"inkanyamba": {
		"model": "res://assets/models/bestiary/worm-serpent/inkanyamba.glb",
		"norm_axis": "z", "target": 2.16,
		"note": "Inkanyamba (African Traditions), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"jaculus": {
		"model": "res://assets/models/bestiary/worm-serpent/jaculus.glb",
		"norm_axis": "z", "target": 0.48,
		"note": "Jaculus (Dragons & Great Serpents), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"lamia": {
		"model": "res://assets/models/bestiary/worm-serpent/lamia.glb",
		"norm_axis": "z", "target": 1.78,
		"note": "Lamia (Greek & Mediterranean Myth), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"larva-of-the-damned": {
		"model": "res://assets/models/bestiary/worm-serpent/larva-of-the-damned.glb",
		"norm_axis": "z", "target": 1.18,
		"note": "Larva of the Damned (Demons, Devils & the Damned), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"lindworm": {
		"model": "res://assets/models/bestiary/worm-serpent/lindworm.glb",
		"norm_axis": "z", "target": 2.16,
		"note": "Lindworm (also Dragons & Great Serpents) (Norse & Germanic), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"naga": {
		"model": "res://assets/models/bestiary/worm-serpent/naga.glb",
		"norm_axis": "z", "target": 2.16,
		"note": "Naga (also Aquatic & the Drowned Deep) (South Asian), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"nure-onna": {
		"model": "res://assets/models/bestiary/worm-serpent/nure-onna.glb",
		"norm_axis": "z", "target": 2.16,
		"note": "Nure-onna (Japanese Yōkai), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"river-long": {
		"model": "res://assets/models/bestiary/worm-serpent/river-long.glb",
		"norm_axis": "z", "target": 2.55,
		"note": "River Long (also Dragons & Great Serpents) (Chinese & East Asian), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"sea-serpent": {
		"model": "res://assets/models/bestiary/worm-serpent/sea-serpent.glb",
		"norm_axis": "z", "target": 2.55,
		"note": "Sea Serpent (Norse & Germanic), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"serpopard": {
		"model": "res://assets/models/bestiary/worm-serpent/serpopard.glb",
		"norm_axis": "z", "target": 2.16,
		"note": "Serpopard (Egyptian & Near East), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"world-wurm": {
		"model": "res://assets/models/bestiary/worm-serpent/world-wurm.glb",
		"norm_axis": "z", "target": 2.55,
		"note": "World Wurm (Aquatic & the Drowned Deep), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"wyrm": {
		"model": "res://assets/models/bestiary/worm-serpent/wyrm.glb",
		"norm_axis": "z", "target": 2.16,
		"note": "Wyrm (Dragons & Great Serpents), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
	"zmey": {
		"model": "res://assets/models/bestiary/worm-serpent/zmey.glb",
		"norm_axis": "z", "target": 2.16,
		"note": "Zmey (also Dragons & Great Serpents) (Slavic), worm-serpent guide build Nov 2, 2026; flat colors, texture paint pending over this same path.",
	},
}


static func for_type(type_id: String) -> Dictionary:
	return MODELS.get(type_id, {})


static func roster(creature_id: String) -> Dictionary:
	return ROSTER_MODELS.get(creature_id, {})
