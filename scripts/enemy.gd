class_name Enemy
extends Node3D
## A dungeon enemy: body mesh, billboarded HP bar + name, stats, death signal.
## Stats are scaled by depth via the `stat_mult` passed to setup() — except
## defense, which is intentionally FLAT (depth-scaled defense once made the
## skeleton an unkillable math wall at depth 3).

signal died(enemy: Enemy)

const TYPES := {
	"slime": {
		"name": "Slime", "color": Color(0.35, 0.9, 0.4),
		"hp": 18.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.65, 1.0),
		"model": "res://assets/models/quaternius/Slime.fbx",
		"anim": "Idle", "body_h": 0.715,
		"family": "Oozes & Slimes", "band": "T", "archetype": "brawler",
		"behavior": "Wobbles forward and body-slams; no split mechanic staged.",
		"sound_vocal": "PROCEDURAL: wet glorp, low sine blip 180→90 Hz.",
		"sound_steps": "PROCEDURAL: soft squelch (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactSoft_medium_000.ogg",
	},
	"bat": {
		"name": "Cave Bat", "color": Color(0.55, 0.4, 0.85),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(1.2, 0.5, 0.7),
		"model": "res://assets/models/quaternius/Bat.fbx",
		"anim": "Flying", "body_h": 0.45,
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "flyer/skirmisher",
		"behavior": "Darts in, bites, retreats; never lands.",
		"sound_vocal": "PROCEDURAL: rapid high chirps, 3–5 kHz bursts.",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"skeleton": {
		"name": "Skeleton", "color": Color(0.92, 0.9, 0.82),
		"hp": 28.0, "atk": 7.0, "def": 2.0, "xp": 18.0, "gold": 20.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7),
		"model": "res://assets/models/quaternius/Skeleton.fbx",
		"anim": "Idle", "body_h": 1.17,
		"family": "The Undead", "band": "T", "archetype": "brawler",
		"behavior": "Shambles forward and chops; flat defense, honest bruiser.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	# --- Wave 1 placeholder types (monster-roster-2026-10.md) -------------
	# Wave 3 wired dungeon_gen's _pick_type() to depth bands, so these
	# DO spawn now — stats below are live depth-1 values (balanced by
	# the Wave 3 soak), not provisional stand-ins. Bodies are primitive
	# composites built by _build_placeholder()
	# (keyed by "build"); "mesh"/"squash" remain as the legacy fallback.
	# When a CC0 model is staged for a type, add its "model" path and the
	# model path takes over automatically, same as the original three.
	"rat": {
		"name": "Cave Rat", "color": Color(0.45, 0.37, 0.29),
		"hp": 10.0, "atk": 3.0, "def": 0.0, "xp": 6.0, "gold": 5.0,
		"mesh": "sphere", "squash": Vector3(0.8, 0.5, 1.2), "build": "rat", "model": "res://assets/resources-phase1/models/vermin/evil-giant-rat/rat_full.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "swarmer",
		"behavior": "Darts in numbers; quick nips, then breaks off.",
		"sound_vocal": "PROCEDURAL: squeaks, 2–4 kHz chirp bursts.",
		"sound_steps": "res://assets/audio/kenney/rpg-audio/footstep00.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_000.ogg",
	},
	"spider": {
		"name": "Cave Spider", "color": Color(0.28, 0.2, 0.34),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "spider", "model": "res://assets/resources-phase1/models/vermin/3dassets/CellarSpider_godot.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "ambusher",
		"behavior": "Wall-clings above the path, drops on prey, venom bite (venom rider is future wiring, not a staged mechanic).",
		"sound_vocal": "PROCEDURAL: dry chitter (fast filtered-noise ticks).",
		"sound_steps": "none (wall-clinging; drop thump on landing, procedural).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_001.ogg",
	},
	"snake": {
		"name": "Giant Serpent", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "snake", "model": "res://assets/resources-phase1/models/ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_cobracon.glb",
		"family": "Beasts", "band": "T", "archetype": "ambusher",
		"behavior": "Lies coiled in cover, lunges, then re-coils; constrict flavor only.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"wasp": {
		"name": "Cave Wasp", "color": Color(0.87, 0.66, 0.16),
		"hp": 9.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 7.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.7, 1.1), "build": "wasp",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "flyer/swarm",
		"behavior": "Hovers, dive-stings, repositions; never stays in reach.",
		"sound_vocal": "PROCEDURAL: buzz (sawtooth ~200 Hz + harmonics).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_002.ogg",
		"model": "res://assets/models/bestiary/winged/cave-wasp.glb"
	},
	"frog": {
		"name": "Cave Frog", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "frog",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "skirmisher",
		"behavior": "Hops into range, tongue-lashes, hops back out.",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "PROCEDURAL: single wet hop-thump on landing (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_003.ogg",
		"model": "res://assets/models/bestiary/aquatic/cave-frog.glb"
	},
	"wolf": {
		"name": "Cave Wolf", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "wolf", "model": "res://assets/resources-phase1/models/beasts/3dassets/CityWolf_godot.glb",
		"family": "Beasts", "band": "T", "archetype": "pack skirmisher",
		"behavior": "Circles and harries; pack bursts when numbers join it.",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"goblin": {
		"name": "Goblin", "color": Color(0.46, 0.66, 0.3),
		"hp": 16.0, "atk": 5.0, "def": 0.0, "xp": 10.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.65, 1.0, 0.65), "build": "goblin", "model": "res://assets/resources-phase1/models/goblin-kin/goblin/goblin.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "skirmisher/swarm",
		"behavior": "Cowardly alone, brave in numbers; hit-and-run stabs.",
		"sound_vocal": "PROCEDURAL: cackle (pitched noise bursts, fast).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice2.ogg",
	},
	"zombie": {
		"name": "Zombie", "color": Color(0.56, 0.62, 0.46),
		"hp": 30.0, "atk": 5.0, "def": 1.0, "xp": 13.0, "gold": 9.0,
		"mesh": "box", "squash": Vector3(0.7, 1.25, 0.7), "build": "zombie",
		"family": "The Undead", "band": "T", "archetype": "tank/swarm",
		"behavior": "Slow, tireless advance; grabs and bites; numbers over speed.",
		"sound_vocal": "PROCEDURAL: low moan (sine ~80 Hz, slow vibrato).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_004.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPunch_heavy_000.ogg",
		"model": "res://assets/models/bestiary/biped-humanoid/zombie.glb"
	},
	"ghost": {
		"name": "Wraith", "color": Color(0.78, 0.92, 0.97),
		"hp": 15.0, "atk": 8.0, "def": 0.0, "xp": 16.0, "gold": 13.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "ghost", "model": "res://assets/resources-phase1/models/undead/gobkit/SheetGhost.glb",
		"family": "The Undead", "band": "D", "archetype": "phase skirmisher",
		"behavior": "Drifts through positioning and phase-strikes; no footsteps, no cover respect.",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_000.ogg",
	},
	"golem": {
		"name": "Clay Golem", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "golem", "model": "res://assets/resources-phase1/models/golems/fire-ice-stone-golem/golem_mirrored.glb",
		"family": "Golems & Constructs", "band": "D", "archetype": "tank",
		"behavior": "Plods, absorbs hits, answers with a heavy slam.",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	# --- Wave 2 placeholder types (Oct 27, 2026 staged expansion) --------
	# Same staging contract as Wave 1: primitive composites ONLY, no model
	# keys. Wave 3 wired dungeon_gen._pick_type() to depth bands, so
	# these DO spawn now. Base hp/atk are depth-1
	# values; live scaling is hp_mult = depth^1.2, atk_mult = depth^1.05
	# (main.gd _new_depth), defense stays flat. Sound specs: res:// paths
	# are real CC0 Kenney files already staged in assets/audio/kenney/;
	# PROCEDURAL lines are specs for a future synth pass, not files.
	"boar": {
		"name": "Wild Boar", "color": Color(0.42, 0.32, 0.24),
		"hp": 24.0, "atk": 8.0, "def": 0.0, "xp": 15.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.8, 0.7, 1.1), "build": "boar", "model": "res://assets/resources-phase1/models/beasts/gobkit/Boar.glb",
		"family": "Beasts", "band": "T", "archetype": "charger",
		"behavior": "Paws the ground and snorts as a telegraph, then charges in a straight line; slow to turn after a miss.",
		"sound_vocal": "PROCEDURAL: snort and grunt (low noise bursts ~150 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPunch_heavy_001.ogg",
	},
	"scorpion": {
		"name": "Cave Scorpion", "color": Color(0.35, 0.28, 0.18),
		"hp": 16.0, "atk": 5.0, "def": 1.0, "xp": 11.0, "gold": 9.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.4, 1.1), "build": "scorpion", "model": "res://assets/resources-phase1/models/ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_scorpion.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "venom skirmisher",
		"behavior": "Sidesteps to flank, snaps with claws, then tail-stings; venom rider is future wiring, not a staged mechanic.",
		"sound_vocal": "PROCEDURAL: dry click-clack (short filtered ticks).",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"centipede": {
		"name": "Centipede", "color": Color(0.55, 0.35, 0.15),
		"hp": 11.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 7.0,
		"mesh": "sphere", "squash": Vector3(0.5, 0.3, 1.8), "build": "centipede", "model": "res://assets/resources-phase1/models/vermin/gobkit-community/GeodeCentipede.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "skirmisher",
		"behavior": "Very fast and very low; weaves side to side so it is hard to lead, but folds to a single solid hit.",
		"sound_vocal": "PROCEDURAL: rapid leg-rustle (dense soft ticks).",
		"sound_steps": "PROCEDURAL: leg-rustle skitter (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"skeleton_archer": {
		"name": "Skeleton Archer", "color": Color(0.88, 0.86, 0.78),
		"hp": 20.0, "atk": 5.0, "def": 0.0, "xp": 15.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(0.6, 1.25, 0.6), "build": "skeleton_archer", "model": "res://assets/resources-phase1/models/undead/crossbowman-skeleton/obj/skull_monster.obj",
		"family": "The Undead", "band": "T", "archetype": "ranged",
		"behavior": "Holds distance and looses arrows; steps back when closed on, never charges.",
		"sound_vocal": "PROCEDURAL: bone rattle plus a bowstring pluck (no file staged).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"kobold": {
		"name": "Kobold", "color": Color(0.55, 0.45, 0.25),
		"hp": 12.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 13.0,
		"mesh": "box", "squash": Vector3(0.55, 0.9, 0.55), "build": "kobold", "model": "res://assets/resources-phase1/models/goblin-kin/goblin/goblin.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "trapper/swarm",
		"behavior": "Darts between cover, jabs with a spear, and flees toward its pack; trap-setting is future wiring, not staged.",
		"sound_vocal": "PROCEDURAL: yip-chatter (short high barks).",
		"sound_steps": "res://assets/audio/kenney/rpg-audio/footstep01.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice2.ogg",
	},
	"imp": {
		"name": "Imp", "color": Color(0.75, 0.25, 0.2),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.7, 0.7), "build": "imp", "model": "res://assets/resources-phase1/models/demons/gobkit-community/FattyImp.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "flyer/caster",
		"behavior": "Erratic hovering flight; lobs small fire bolts from odd angles, then flits to a new perch.",
		"sound_vocal": "PROCEDURAL: giggling cackle (high pitched bursts).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_light_001.ogg",
	},
	"pixie": {
		"name": "Pixie", "color": Color(0.95, 0.75, 0.9),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(0.4, 0.4, 0.4), "build": "pixie",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "flyer/caster",
		"behavior": "Tiny, fast, and annoying by design: dazzles, darts, and nicks; folds to any clean hit. Dazzle is future wiring.",
		"sound_vocal": "PROCEDURAL: bell-like tinkle (sine pings ~2 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: dazzle chime (bright sine ping, no file staged).",
		"model": "res://assets/models/bestiary/winged/pixie.glb"
	},
	"orc": {
		"name": "Orc", "color": Color(0.35, 0.5, 0.25),
		"hp": 32.0, "atk": 8.0, "def": 1.0, "xp": 18.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.8, 1.3, 0.7), "build": "orc", "model": "res://assets/resources-phase1/models/orcs-trolls/gobkit/OrcLegionary.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "brute",
		"behavior": "Advances steadily and swings heavy overhead chops; slow windup, punishing if it connects.",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_001.ogg",
	},
	"troll": {
		"name": "Troll", "color": Color(0.45, 0.55, 0.4),
		"hp": 48.0, "atk": 7.0, "def": 2.0, "xp": 24.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(1.0, 1.5, 0.9), "build": "troll", "model": "res://assets/resources-phase1/models/beasts/troll-flare/Troll.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "tank/regen",
		"behavior": "Hunched wall that lumbers in and swats; slow regeneration flavor (regen rate is future tuning, not staged).",
		"sound_vocal": "PROCEDURAL: deep bellow (sine/saw ~60 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_004.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPunch_heavy_002.ogg",
	},
	"minotaur": {
		"name": "Minotaur", "color": Color(0.5, 0.35, 0.22),
		"hp": 40.0, "atk": 9.0, "def": 1.0, "xp": 26.0, "gold": 18.0,
		"mesh": "box", "squash": Vector3(0.9, 1.5, 0.8), "build": "minotaur", "model": "res://assets/resources-phase1/models/beasts/gobkit-community/BrazenMinotaur.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "charger/brute",
		"behavior": "Paws and bellows as a telegraph, gore-charges down corridors, then follows with horn swipes in the open.",
		"sound_vocal": "PROCEDURAL: bellow plus snort (low saw + noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_002.ogg",
	},
	"harpy": {
		"name": "Harpy", "color": Color(0.6, 0.5, 0.35),
		"hp": 18.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 13.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "harpy",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "flyer/skirmisher",
		"behavior": "Circles overhead shrieking, then dive-rakes with talons and climbs away; the dive line is the tell.",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
		"model": "res://assets/models/bestiary/winged/harpy.glb"
	},
	"oni": {
		"name": "Oni", "color": Color(0.65, 0.2, 0.25),
		"hp": 38.0, "atk": 9.0, "def": 2.0, "xp": 25.0, "gold": 17.0,
		"mesh": "box", "squash": Vector3(0.85, 1.6, 0.75), "build": "oni",
		"family": "Japanese Yōkai", "band": "D", "archetype": "brute",
		"behavior": "Slow, deliberate club work: raises the iron club high (the tell), then slams a wide arc; no rush, no retreat.",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactWood_heavy_001.ogg",
		"model": "res://assets/models/bestiary/biped-humanoid/oni.glb"
	},
	"kappa": {
		"name": "Kappa", "color": Color(0.3, 0.6, 0.35),
		"hp": 30.0, "atk": 6.0, "def": 2.0, "xp": 20.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.7, 1.0, 0.7), "build": "kappa", "model": "res://assets/resources-phase1/models/yokai/snappakappa-3d/snappa-kappa.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "grappler/tank",
		"behavior": "Waddles in behind its shell, grabs and drags, then wrestles at close range; grapple is future wiring, posture is staged.",
		"sound_vocal": "PROCEDURAL: wet croak-gurgle (low sine + noise).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPunch_medium_001.ogg",
	},
	"drake": {
		"name": "Drake", "color": Color(0.55, 0.3, 0.15),
		"hp": 34.0, "atk": 8.0, "def": 1.0, "xp": 24.0, "gold": 20.0,
		"mesh": "box", "squash": Vector3(1.2, 0.8, 1.2), "build": "drake", "model": "res://assets/resources-phase1/models/dragons/gobkit-community/Wyvern.glb",
		"family": "Dragons & Great Serpents", "band": "D", "archetype": "flyer/brute",
		"behavior": "Swoops low, breathes a short cone of fire, then climbs to reposition; the inhale before the breath is the tell.",
		"sound_vocal": "PROCEDURAL: reptilian roar (sawtooth ~140 Hz + noise).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: fire-breath roar (filtered noise burst, no file staged).",
	},
	"banshee": {
		"name": "Banshee", "color": Color(0.85, 0.9, 0.95),
		"hp": 22.0, "atk": 9.0, "def": 0.0, "xp": 22.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.4, 0.8), "build": "banshee",
		"family": "The Undead", "band": "Dp", "archetype": "caster",
		"behavior": "Floats at range and wails: an area scream with a long windup, then drifts to a new vantage; AoE is future wiring.",
		"sound_vocal": "PROCEDURAL: wail (sine sweep 600→1400 Hz, long).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
		"model": "res://assets/models/bestiary/ghost-wisp/banshee.glb"
	},

	# --- Nov 8, 2026 TYPES expansion: 272 bestiary entries (one per bestiary
	# row with a ROSTER model). Stats are family medians (rounded half-up);
	# archetype from behavior-specs Attack lines; sounds reuse staged Kenney
	# files / procedural specs. Derivation log: design-notes/types-expansion-20261108.md ---
	"cave-jelly": {
		"name": "Cave Jelly", "color": Color(0.35, 0.9, 0.4),
		"hp": 18.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.65, 1.0), "build": "cave-jelly", "model": "res://assets/models/bestiary/blob-ooze/cave-jelly.glb",
		"family": "Oozes & Slimes", "band": "T", "archetype": "ambusher",
		"behavior": "Drop-and-envelop — a faint glisten overhead is the tell, then it falls and tries to smother its target in",
		"sound_vocal": "PROCEDURAL: wet glorp, low sine blip 180→90 Hz.",
		"sound_steps": "PROCEDURAL: soft squelch (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactSoft_medium_000.ogg",
	},
	"amber-ooze": {
		"name": "Amber Ooze", "color": Color(0.35, 0.9, 0.4),
		"hp": 18.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.65, 1.0), "build": "amber-ooze", "model": "res://assets/models/bestiary/blob-ooze/amber-ooze.glb",
		"family": "Oozes & Slimes", "band": "T", "archetype": "brute",
		"behavior": "Adhesive lunge — it stretches, brightens, and snaps forward, trying to glue its target in place for follow-up",
		"sound_vocal": "PROCEDURAL: wet glorp, low sine blip 180→90 Hz.",
		"sound_steps": "PROCEDURAL: soft squelch (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactSoft_medium_000.ogg",
	},
	"mire-pudding": {
		"name": "Mire Pudding", "color": Color(0.35, 0.9, 0.4),
		"hp": 18.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.65, 1.0), "build": "mire-pudding", "model": "res://assets/models/bestiary/blob-ooze/mire-pudding.glb",
		"family": "Oozes & Slimes", "band": "T", "archetype": "ambusher",
		"behavior": "Surge-and-grab — the surface ripples, then a tendril of muck lashes out to drag the target toward its bulk.",
		"sound_vocal": "PROCEDURAL: wet glorp, low sine blip 180→90 Hz.",
		"sound_steps": "PROCEDURAL: soft squelch (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactSoft_medium_000.ogg",
	},
	"acid-blob": {
		"name": "Acid Blob", "color": Color(0.35, 0.9, 0.4),
		"hp": 18.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.65, 1.0), "build": "acid-blob", "model": "res://assets/models/bestiary/blob-ooze/acid-blob.glb",
		"family": "Oozes & Slimes", "band": "T", "archetype": "caster",
		"behavior": "Corrosive spit — it rears back, its surface bubbles and brightens, then looses a splashing glob that eats at",
		"sound_vocal": "PROCEDURAL: wet glorp, low sine blip 180→90 Hz.",
		"sound_steps": "PROCEDURAL: soft squelch (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"gloom-ooze": {
		"name": "Gloom Ooze", "color": Color(0.35, 0.9, 0.4),
		"hp": 18.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.65, 1.0), "build": "gloom-ooze", "model": "res://assets/models/bestiary/blob-ooze/gloom-ooze.glb",
		"family": "Oozes & Slimes", "band": "T", "archetype": "grappler/tank",
		"behavior": "Smothering gloom — it swells and darkens, then folds over its target, blinding and pressing at once.",
		"sound_vocal": "PROCEDURAL: wet glorp, low sine blip 180→90 Hz.",
		"sound_steps": "PROCEDURAL: soft squelch (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactSoft_medium_000.ogg",
	},
	"mercury-slime": {
		"name": "Mercury Slime", "color": Color(0.35, 0.9, 0.4),
		"hp": 18.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.65, 1.0), "build": "mercury-slime", "model": "res://assets/models/bestiary/blob-ooze/mercury-slime.glb",
		"family": "Oozes & Slimes", "band": "T", "archetype": "ambusher",
		"behavior": "Shard spray — it shivers, throws off bright droplets in a scatter, then reforms and lunges while the target",
		"sound_vocal": "PROCEDURAL: wet glorp, low sine blip 180→90 Hz.",
		"sound_steps": "PROCEDURAL: soft squelch (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactSoft_medium_000.ogg",
	},
	"primordial-ooze": {
		"name": "Primordial Ooze", "color": Color(0.35, 0.9, 0.4),
		"hp": 18.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.65, 1.0), "build": "primordial-ooze", "model": "res://assets/models/bestiary/blob-ooze/primordial-ooze.glb",
		"family": "Oozes & Slimes", "band": "T", "archetype": "grappler/tank",
		"behavior": "Engulfing wave — it draws itself up like a rising tide, pauses at full height, then crashes forward over",
		"sound_vocal": "PROCEDURAL: wet glorp, low sine blip 180→90 Hz.",
		"sound_steps": "PROCEDURAL: soft squelch (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactSoft_medium_000.ogg",
	},
	"rat-swarm": {
		"name": "Rat Swarm", "color": Color(0.28, 0.2, 0.34),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "rat-swarm", "model": "res://assets/models/bestiary/spider-arachnid/rat-swarm.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "swarmer",
		"behavior": "Overwhelming gnaw — the mass surges forward in a wave, teeth everywhere at once, with a rising chitter as its",
		"sound_vocal": "PROCEDURAL: dry chitter (fast filtered-noise ticks).",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"cave-wasp": {
		"name": "Cave Wasp", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "cave-wasp", "model": "res://assets/models/bestiary/winged/cave-wasp.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "pack skirmisher",
		"behavior": "Stinging dive — it hovers, dips low, and buzzes louder for a beat before driving in with its sting.",
		"sound_vocal": "PROCEDURAL: buzz (sawtooth ~200 Hz + harmonics).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"cave-frog": {
		"name": "Cave Frog", "color": Color(0.42, 0.62, 0.3),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "cave-frog", "model": "res://assets/models/bestiary/aquatic/cave-frog.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "grappler/tank",
		"behavior": "Tongue snatch and leap-slam — it inflates its throat as a tell, then either flicks its tongue out to drag",
		"sound_vocal": "PROCEDURAL: rapid high chirps, 3–5 kHz bursts.",
		"sound_steps": "PROCEDURAL: single wet hop-thump on landing (no file staged).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"giant-rat": {
		"name": "Giant Rat", "color": Color(0.52, 0.54, 0.58),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "giant-rat", "model": "res://assets/models/bestiary/quadruped-beast/giant-rat.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "ranged",
		"behavior": "Lunging maul — it rears onto its hind legs, bares its teeth, then throws itself forward in a mauling rush.",
		"sound_vocal": "PROCEDURAL: rapid high chirps, 3–5 kHz bursts.",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"widow-spider": {
		"name": "Widow Spider", "color": Color(0.28, 0.2, 0.34),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "widow-spider", "model": "res://assets/models/bestiary/spider-arachnid/widow-spider.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "ambusher",
		"behavior": "Venom bite from the web — it drops on a thread, bites, and climbs back up, leaving its target slowed and",
		"sound_vocal": "PROCEDURAL: rapid high chirps, 3–5 kHz bursts.",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"emperor-scorpion": {
		"name": "Emperor Scorpion", "color": Color(0.28, 0.2, 0.34),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "emperor-scorpion", "model": "res://assets/models/bestiary/spider-arachnid/emperor-scorpion.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "venom skirmisher",
		"behavior": "Crushing pincer and overhead sting — it spreads both claws as a tell, snaps one shut, then brings the tail",
		"sound_vocal": "PROCEDURAL: rapid high chirps, 3–5 kHz bursts.",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"stag-beetle": {
		"name": "Stag Beetle", "color": Color(0.28, 0.2, 0.34),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "stag-beetle", "model": "res://assets/models/bestiary/spider-arachnid/stag-beetle.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "ranged",
		"behavior": "Mandible toss — it lowers its great jaws, paws the ground, then charges a short distance and tries to lift",
		"sound_vocal": "PROCEDURAL: rapid high chirps, 3–5 kHz bursts.",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"burrow-worm": {
		"name": "Burrow Worm", "color": Color(0.32, 0.56, 0.26),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "burrow-worm", "model": "res://assets/models/bestiary/worm-serpent/burrow-worm.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "venom skirmisher",
		"behavior": "Eruption bite — the ridge stops, the ground bulges, then the worm bursts upward with jaws open.",
		"sound_vocal": "PROCEDURAL: rapid high chirps, 3–5 kHz bursts.",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"carrion-worm": {
		"name": "Carrion Worm", "color": Color(0.32, 0.56, 0.26),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "carrion-worm", "model": "res://assets/models/bestiary/worm-serpent/carrion-worm.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "caster",
		"behavior": "Rotting spray — it rears its head, its body pulses, then it sprays a foul, sickening mist that clings and",
		"sound_vocal": "PROCEDURAL: rapid high chirps, 3–5 kHz bursts.",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"hornet-matriarch": {
		"name": "Hornet Matriarch", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "hornet-matriarch", "model": "res://assets/models/bestiary/winged/hornet-matriarch.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "caster",
		"behavior": "Royal sting and brood call — she dips and shrieks, her brood dives in a wave, then she follows with a heavy",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: dazzle chime (bright sine ping, no file staged).",
	},
	"omukade": {
		"name": "Ōmukade", "color": Color(0.28, 0.2, 0.34),
		"hp": 12.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "omukade", "model": "res://assets/models/bestiary/spider-arachnid/omukade.glb",
		"family": "Vermin & Cave Crawlers", "band": "T", "archetype": "venom skirmisher",
		"behavior": "Coiling crush and venomous bite — it rears its head high, mandibles spread wide, then strikes and tries to",
		"sound_vocal": "PROCEDURAL: rapid high chirps, 3–5 kHz bursts.",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"wolf_bestiary": {
		"name": "Wolf", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "wolf_bestiary", "model": "res://assets/models/bestiary/quadruped-beast/wolf.glb",
		"family": "Beasts", "band": "T", "archetype": "pack skirmisher",
		"behavior": "Quick nips from the flank; when packmates close in, the pack converges for a coordinated burst, telegraphed",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"hyena": {
		"name": "Hyena", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "hyena", "model": "res://assets/models/bestiary/quadruped-beast/hyena.glb",
		"family": "Beasts", "band": "T", "archetype": "pack skirmisher",
		"behavior": "Snapping bites from the side and rear, with packmates striking in the same window once numbers join.",
		"sound_vocal": "PROCEDURAL: cackle (pitched noise bursts, fast).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"grizzly": {
		"name": "Grizzly", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "grizzly", "model": "res://assets/models/bestiary/quadruped-beast/grizzly.glb",
		"family": "Beasts", "band": "T", "archetype": "charger/brute",
		"behavior": "Heavy overhead swipes with a long, readable wind-up — the raised paw is the dodge window — and a punishing",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"dire-wolf": {
		"name": "Dire Wolf", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "dire-wolf", "model": "res://assets/models/bestiary/quadruped-beast/dire-wolf.glb",
		"family": "Beasts", "band": "T", "archetype": "pack skirmisher",
		"behavior": "Lunging bites that carry it forward, telegraphed by a lowered head and a short crouch before the spring.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"warhound": {
		"name": "Warhound", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "warhound", "model": "res://assets/models/bestiary/quadruped-beast/warhound.glb",
		"family": "Beasts", "band": "T", "archetype": "charger",
		"behavior": "A driving charge ending in a bite; the baying and pawing are the tell, and the wheel after a miss is the",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"cave-bear": {
		"name": "Cave Bear", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "cave-bear", "model": "res://assets/models/bestiary/quadruped-beast/cave-bear.glb",
		"family": "Beasts", "band": "T", "archetype": "charger/brute",
		"behavior": "Infrequent heavy slams, telegraphed by a rearing lift of both forepaws; the slam punishes standing still, not",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"razorback": {
		"name": "Razorback", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "razorback", "model": "res://assets/models/bestiary/quadruped-beast/razorback.glb",
		"family": "Beasts", "band": "T", "archetype": "charger",
		"behavior": "The charge is the entry; once the charge ends, it turns to close-range tusk swipes with a head-toss wind-up.",
		"sound_vocal": "PROCEDURAL: snort and grunt (low noise bursts ~150 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"panther": {
		"name": "Panther", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "panther", "model": "res://assets/models/bestiary/quadruped-beast/panther.glb",
		"family": "Beasts", "band": "T", "archetype": "ambusher",
		"behavior": "A leaping pounce from concealment, telegraphed only by a faint shadow shift and a crouch in the last moment",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"cave-python": {
		"name": "Cave Python", "color": Color(0.32, 0.56, 0.26),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "cave-python", "model": "res://assets/models/bestiary/worm-serpent/cave-python.glb",
		"family": "Beasts", "band": "T", "archetype": "ambusher",
		"behavior": "A constricting lunge that wraps and squeezes if it connects, telegraphed by a slow coil-tightening before the",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"cave-ape": {
		"name": "Cave Ape", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "cave-ape", "model": "res://assets/models/bestiary/quadruped-beast/cave-ape.glb",
		"family": "Beasts", "band": "T", "archetype": "charger/brute",
		"behavior": "Heavy overhead arm swings with a long wind-up, plus a chest-beating roar that signals the next swing.",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"baboon-troop": {
		"name": "Baboon Troop", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "baboon-troop", "model": "res://assets/models/bestiary/quadruped-beast/baboon-troop.glb",
		"family": "Beasts", "band": "T", "archetype": "pack skirmisher",
		"behavior": "Quick nips and thrown debris from many angles, then a break-off; the troop's massing and chatter are the tell.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"crag-ram": {
		"name": "Crag Ram", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "crag-ram", "model": "res://assets/models/bestiary/quadruped-beast/crag-ram.glb",
		"family": "Beasts", "band": "T", "archetype": "charger",
		"behavior": "A head-lowered charge ending in a horn impact; pawing and a lowered head are the tell.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"deep-stag": {
		"name": "Deep Stag", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "deep-stag", "model": "res://assets/models/bestiary/quadruped-beast/deep-stag.glb",
		"family": "Beasts", "band": "T", "archetype": "charger",
		"behavior": "An antler charge followed by sweeping antler tosses if the player stays close after the rush.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"grotto-bull": {
		"name": "Grotto Bull", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "grotto-bull", "model": "res://assets/models/bestiary/quadruped-beast/grotto-bull.glb",
		"family": "Beasts", "band": "T", "archetype": "charger",
		"behavior": "The charge is the entry; horn swipes with a head-swing wind-up are the follow-up once the charge ends.",
		"sound_vocal": "PROCEDURAL: deep bellow (sine/saw ~60 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"blind-mole": {
		"name": "Blind Mole", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "blind-mole", "model": "res://assets/models/bestiary/quadruped-beast/blind-mole.glb",
		"family": "Beasts", "band": "T", "archetype": "ambusher",
		"behavior": "A sudden surfacing lunge from below, telegraphed by a faint ripple or mound shifting in the floor before it",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"crocodile": {
		"name": "Crocodile", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "crocodile", "model": "res://assets/models/bestiary/quadruped-beast/crocodile.glb",
		"family": "Beasts", "band": "T", "archetype": "ambusher",
		"behavior": "A sideways lunging bite with a death-roll follow-up if it connects, telegraphed by a slight jaw gape and tail",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"lion": {
		"name": "Lion", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "lion", "model": "res://assets/models/bestiary/quadruped-beast/lion.glb",
		"family": "Beasts", "band": "T", "archetype": "pack skirmisher",
		"behavior": "Heavy paw swipes with a readable wind-up, plus coordinated bites when pride-mates close in.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"sabertooth": {
		"name": "Sabertooth", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "sabertooth", "model": "res://assets/models/bestiary/quadruped-beast/sabertooth.glb",
		"family": "Beasts", "band": "T", "archetype": "ambusher",
		"behavior": "A leaping pounce ending in a fang bite, telegraphed by a low crouch and bared fangs; a missed pounce flows",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"tiger": {
		"name": "Tiger", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "tiger", "model": "res://assets/models/bestiary/quadruped-beast/tiger.glb",
		"family": "Beasts", "band": "T", "archetype": "ambusher",
		"behavior": "A bounding pounce with raking claws, telegraphed by a flattening crouch and a tail lash in the final moment.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"cave-hyena": {
		"name": "Cave Hyena", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "cave-hyena", "model": "res://assets/models/bestiary/quadruped-beast/cave-hyena.glb",
		"family": "Beasts", "band": "T", "archetype": "pack skirmisher",
		"behavior": "Snapping bites from the dark side, with packmates striking together once the circle closes.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"pale-horse": {
		"name": "Pale Horse", "color": Color(0.52, 0.54, 0.58),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 14.0, "gold": 11.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "pale-horse", "model": "res://assets/models/bestiary/quadruped-beast/pale-horse.glb",
		"family": "Beasts", "band": "T", "archetype": "charger",
		"behavior": "A sudden rearing strike and trampling rush, telegraphed by a stillness that breaks all at once into motion.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"goblin-sneak": {
		"name": "Goblin Sneak", "color": Color(0.92, 0.9, 0.82),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "goblin-sneak", "model": "res://assets/models/bestiary/biped-humanoid/goblin-sneak.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "ambusher",
		"behavior": "a single backstab-style lunge from concealment, telegraphed by a faint shimmer/hint just before it springs,",
		"sound_vocal": "PROCEDURAL: cackle (pitched noise bursts, fast).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice2.ogg",
	},
	"goblin-shaman": {
		"name": "Goblin Shaman", "color": Color(0.92, 0.9, 0.82),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "goblin-shaman", "model": "res://assets/models/bestiary/biped-humanoid/goblin-shaman.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "caster",
		"behavior": "spits crackling bolts and raises a warding gesture (a raised staff and a visible glow) that rallies nearby",
		"sound_vocal": "PROCEDURAL: cackle (pitched noise bursts, fast).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"hobgoblin": {
		"name": "Hobgoblin", "color": Color(0.92, 0.9, 0.82),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "hobgoblin", "model": "res://assets/models/bestiary/biped-humanoid/hobgoblin.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "brawler",
		"behavior": "drilled spear thrusts and shield bashes in sequence; the spear is leveled visibly before each thrust, giving",
		"sound_vocal": "PROCEDURAL: cackle (pitched noise bursts, fast).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice2.ogg",
	},
	"bugbear": {
		"name": "Bugbear", "color": Color(0.52, 0.54, 0.58),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "bugbear", "model": "res://assets/models/bestiary/quadruped-beast/bugbear.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "ambusher",
		"behavior": "a heavy grab-and-maul rush; the tell is a sudden stillness, then a roar and charge with no further warning.",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice2.ogg",
	},
	"boggart": {
		"name": "Boggart", "color": Color(0.92, 0.9, 0.82),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "boggart", "model": "res://assets/models/bestiary/biped-humanoid/boggart.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "ranged",
		"behavior": "escalating mischief turned violent: first it harries with thrown clutter and sudden noises, then it lunges",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"redcap": {
		"name": "Redcap", "color": Color(0.92, 0.9, 0.82),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "redcap", "model": "res://assets/models/bestiary/biped-humanoid/redcap.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "brawler",
		"behavior": "savage pikestaff thrusts and talon rakes; the tell is the staff being drawn back and the cap's glow flaring",
		"sound_vocal": "PROCEDURAL: cackle (pitched noise bursts, fast).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice2.ogg",
	},
	"spriggan": {
		"name": "Spriggan", "color": Color(0.92, 0.9, 0.82),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "spriggan", "model": "res://assets/models/bestiary/biped-humanoid/spriggan.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "caster",
		"behavior": "spiteful swipes plus a signature swell — it visibly inflates, limbs lengthening, before delivering a",
		"sound_vocal": "PROCEDURAL: cackle (pitched noise bursts, fast).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"gremlin": {
		"name": "Gremlin", "color": Color(0.92, 0.9, 0.82),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "gremlin", "model": "res://assets/models/bestiary/biped-humanoid/gremlin.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "pack skirmisher",
		"behavior": "sabotage first, claws second — it tampers with the player's gear and surroundings (jamming, snagging,",
		"sound_vocal": "PROCEDURAL: cackle (pitched noise bursts, fast).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice2.ogg",
	},
	"puca": {
		"name": "Púca", "color": Color(0.92, 0.9, 0.82),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "puca", "model": "res://assets/models/bestiary/biped-humanoid/puca.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "caster",
		"behavior": "a wild-ride lure — it invites approach, then bursts into a bucking charge that carries the player",
		"sound_vocal": "PROCEDURAL: cackle (pitched noise bursts, fast).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"goblin-champion": {
		"name": "Goblin Champion", "color": Color(0.92, 0.9, 0.82),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "goblin-champion", "model": "res://assets/models/bestiary/biped-humanoid/goblin-champion.glb",
		"family": "Goblin-Kin & Cave Folk", "band": "T", "archetype": "pack skirmisher",
		"behavior": "heavy overhead chops with a long wind-up (weapon raised high, the defining brute tell), plus a rallying",
		"sound_vocal": "PROCEDURAL: deep bellow (sine/saw ~60 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice2.ogg",
	},
	"orc-berserker": {
		"name": "Orc Berserker", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "orc-berserker", "model": "res://assets/models/bestiary/biped-humanoid/orc-berserker.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "caster",
		"behavior": "a frenzied flurry of wild swings; the tell is a chest-beating pause and a scream before the rush, then swings",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"half-ogre": {
		"name": "Half-Ogre", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "half-ogre", "model": "res://assets/models/bestiary/biped-humanoid/half-ogre.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "brawler",
		"behavior": "club swings with a long wind-up, plus the occasional shoulder-barge; the club raise is the tell for the",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_001.ogg",
	},
	"ogre": {
		"name": "Ogre", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "ogre", "model": "res://assets/models/bestiary/biped-humanoid/ogre.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "brute",
		"behavior": "massive club slams in a wide arc; the tell is the club raised high overhead and held a beat before falling.",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_001.ogg",
	},
	"marsh-troll": {
		"name": "Marsh Troll", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "marsh-troll", "model": "res://assets/models/bestiary/biped-humanoid/marsh-troll.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "ambusher",
		"behavior": "long-armed swipes and a grappling grab that drags the player closer; the tell is water or muck stirring",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_001.ogg",
	},
	"orc-shaman": {
		"name": "Orc Shaman", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "orc-shaman", "model": "res://assets/models/bestiary/biped-humanoid/orc-shaman.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "caster",
		"behavior": "searing bolts and a war-drum rhythm that visibly emboldens nearby orcs; the drum-beat and raised fetish are",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"cave-troll": {
		"name": "Cave Troll", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "cave-troll", "model": "res://assets/models/bestiary/biped-humanoid/cave-troll.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "ambusher",
		"behavior": "boulder-hurling from range (the lifted stone is the tell) followed by crushing club work up close.",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_001.ogg",
	},
	"ettin": {
		"name": "Ettin", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "ettin", "model": "res://assets/models/bestiary/biped-humanoid/ettin.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "brawler",
		"behavior": "twin club swings, one from each side, landing in sequence rather than together; the tells are the two",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_001.ogg",
	},
	"cyclops": {
		"name": "Cyclops", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "cyclops", "model": "res://assets/models/bestiary/biped-humanoid/cyclops.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "ranged",
		"behavior": "a massive club sweep and a grabbed boulder throw; the tell is the eye fixing on the player and the arm",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"hill-giant": {
		"name": "Hill Giant", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "hill-giant", "model": "res://assets/models/bestiary/biped-humanoid/hill-giant.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "brute",
		"behavior": "a tree-limb club brought down in a huge overhead arc; the tell is the limb raised high and the giant planting",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_001.ogg",
	},
	"stone-giant": {
		"name": "Stone Giant", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "stone-giant", "model": "res://assets/models/bestiary/biped-humanoid/stone-giant.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "brute",
		"behavior": "hurled rocks from range (the raised arm and braced stance are the tell) and crushing fists up close.",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_001.ogg",
	},
	"frost-giant": {
		"name": "Frost Giant", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "frost-giant", "model": "res://assets/models/bestiary/biped-humanoid/frost-giant.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "caster",
		"behavior": "a great axe sweep plus a freezing breath that visibly mists before it blows; the inhale and the mist are the",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"ogre-mage": {
		"name": "Ogre Mage", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "ogre-mage", "model": "res://assets/models/bestiary/biped-humanoid/ogre-mage.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "caster",
		"behavior": "bolts of conjured force plus a sudden blinking reposition (a shimmer and a vanishing puff mark the departure,",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"fire-giant": {
		"name": "Fire Giant", "color": Color(0.92, 0.9, 0.82),
		"hp": 40.0, "atk": 8.0, "def": 2.0, "xp": 21.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "fire-giant", "model": "res://assets/models/bestiary/biped-humanoid/fire-giant.glb",
		"family": "Orcs, Trolls & Giant-Kin", "band": "D", "archetype": "caster",
		"behavior": "a blazing sword sweep plus a wave of flame breathed or hurled forward; the tell is the sword or maw glowing",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_003.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"skeleton-knight": {
		"name": "Skeleton Knight", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "skeleton-knight", "model": "res://assets/models/bestiary/biped-humanoid/skeleton-knight.glb",
		"family": "The Undead", "band": "T", "archetype": "brawler",
		"behavior": "Heavy sword swings with a long, readable raise, followed by a slow recovery.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"ghoul": {
		"name": "Ghoul", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "ghoul", "model": "res://assets/models/bestiary/biped-humanoid/ghoul.glb",
		"family": "The Undead", "band": "T", "archetype": "ranged",
		"behavior": "Quick lunging bites and claw swipes with only a short crouch as warning.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"barrow-wight": {
		"name": "Barrow Wight", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "barrow-wight", "model": "res://assets/models/bestiary/biped-humanoid/barrow-wight.glb",
		"family": "The Undead", "band": "T", "archetype": "venom skirmisher",
		"behavior": "Wide, punishing weapon arcs with a long raise; the arc's sweep line is the tell.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"specter": {
		"name": "Specter", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "specter", "model": "res://assets/models/bestiary/ghost-wisp/specter.glb",
		"family": "The Undead", "band": "T", "archetype": "phase skirmisher",
		"behavior": "A phase-strike delivered from the drift: it shimmers into solidity, strikes, and drifts away. It stays",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"poltergeist": {
		"name": "Poltergeist", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "poltergeist", "model": "res://assets/models/bestiary/ghost-wisp/poltergeist.glb",
		"family": "The Undead", "band": "T", "archetype": "ambusher",
		"behavior": "Hurls loose debris across the room, with objects rattling and lifting just before they fly — the rattle is",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"draugr": {
		"name": "Draugr", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "draugr", "model": "res://assets/models/bestiary/biped-humanoid/draugr.glb",
		"family": "The Undead", "band": "T", "archetype": "brute",
		"behavior": "Crushing weapon blows with a long raise, sometimes followed by a shoulder-barge when the player stands too",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"mummy": {
		"name": "Mummy", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "mummy", "model": "res://assets/models/bestiary/biped-humanoid/mummy.glb",
		"family": "The Undead", "band": "T", "archetype": "caster",
		"behavior": "Heavy, wrapping-laden strikes at close range, plus a spoken curse at range — the curse is announced by a",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"phantom": {
		"name": "Phantom", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "phantom", "model": "res://assets/models/bestiary/ghost-wisp/phantom.glb",
		"family": "The Undead", "band": "T", "archetype": "pack skirmisher",
		"behavior": "A sudden gliding lunge from the circle, telegraphed by the phantom turning to face the player and brightening",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"vampire": {
		"name": "Vampire", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "vampire", "model": "res://assets/models/bestiary/biped-humanoid/vampire.glb",
		"family": "The Undead", "band": "T", "archetype": "brawler",
		"behavior": "A lunge-and-bite that restores the vampire as it harms the player, telegraphed by a pause, a bared-teeth",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"strigoi": {
		"name": "Strigoi", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "strigoi", "model": "res://assets/models/bestiary/biped-humanoid/strigoi.glb",
		"family": "The Undead", "band": "T", "archetype": "brawler",
		"behavior": "Clawing rushes and a draining bite, telegraphed by a crouch and a hiss before each burst.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"jiangshi": {
		"name": "Jiangshi", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "jiangshi", "model": "res://assets/models/bestiary/biped-humanoid/jiangshi.glb",
		"family": "The Undead", "band": "T", "archetype": "brute",
		"behavior": "Slamming arm strikes and a draining grasp delivered at the end of a hop, with the hop's arc itself as the",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"vetala": {
		"name": "Vetala", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "vetala", "model": "res://assets/models/bestiary/biped-humanoid/vetala.glb",
		"family": "The Undead", "band": "T", "archetype": "brawler",
		"behavior": "Cunning close strikes mixed with a whispered riddle-chant at range; the chant is announced by the corpse",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"sluagh": {
		"name": "Sluagh", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "sluagh", "model": "res://assets/models/bestiary/ghost-wisp/sluagh.glb",
		"family": "The Undead", "band": "T", "archetype": "brute",
		"behavior": "Diving nips from many angles at once, telegraphed by the flock wheeling and tightening overhead before the",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"wight-lord": {
		"name": "Wight Lord", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "wight-lord", "model": "res://assets/models/bestiary/biped-humanoid/wight-lord.glb",
		"family": "The Undead", "band": "T", "archetype": "brawler",
		"behavior": "Heavy weapon blows with a long raise, plus shouted commands that send nearby lesser undead surging at the",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"lich": {
		"name": "Lich", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "lich", "model": "res://assets/models/bestiary/biped-humanoid/lich.glb",
		"family": "The Undead", "band": "T", "archetype": "caster",
		"behavior": "Ranged death-magic bolts and a raised-staff area blast, each announced by staff glow and a chanting wind-up",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"dullahan": {
		"name": "Dullahan", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "dullahan", "model": "res://assets/models/bestiary/biped-humanoid/dullahan.glb",
		"family": "The Undead", "band": "T", "archetype": "ranged",
		"behavior": "A spine-whip sweep as it passes, plus a thrown-head strike: the rider raises the carried head high and hurls",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"gashadokuro": {
		"name": "Gashadokuro", "color": Color(0.92, 0.9, 0.82),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "gashadokuro", "model": "res://assets/models/bestiary/biped-humanoid/gashadokuro.glb",
		"family": "The Undead", "band": "T", "archetype": "grappler/tank",
		"behavior": "Enormous sweeping grabs and a biting lunge, telegraphed by the skeleton rearing back and its eye-glow",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"penanggalan": {
		"name": "Penanggalan", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 7.0, "def": 0.0, "xp": 16.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "penanggalan", "model": "res://assets/models/bestiary/ghost-wisp/penanggalan.glb",
		"family": "The Undead", "band": "T", "archetype": "grappler/tank",
		"behavior": "Trailing-organ lashes followed by a draining bite, telegraphed by the head rearing back and the organs",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"satyr": {
		"name": "Satyr", "color": Color(0.92, 0.9, 0.82),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "satyr", "model": "res://assets/models/bestiary/biped-humanoid/satyr.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "brawler",
		"behavior": "A leaping butt or club swing, telegraphed by a crouch and a stamp; in a group, satyrs harry from different",
		"sound_vocal": "PROCEDURAL: bellow plus snort (low saw + noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_002.ogg",
	},
	"centaur": {
		"name": "Centaur", "color": Color(0.52, 0.54, 0.58),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "centaur", "model": "res://assets/models/bestiary/quadruped-beast/centaur.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "ranged",
		"behavior": "Loosed arrows or thrown javelins from range, telegraphed by a draw and a pause to aim; a close-range charge",
		"sound_vocal": "PROCEDURAL: bellow plus snort (low saw + noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"siren": {
		"name": "Siren", "color": Color(0.6, 0.5, 0.35),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "siren", "model": "res://assets/models/bestiary/winged/siren.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "caster",
		"behavior": "A lure song that pulls the player toward her, followed by close talon strikes once the player is drawn in;",
		"sound_vocal": "PROCEDURAL: bellow plus snort (low saw + noise bursts).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: dazzle chime (bright sine ping, no file staged).",
	},
	"stymphalian-bird": {
		"name": "Stymphalian Bird", "color": Color(0.6, 0.5, 0.35),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "stymphalian-bird", "model": "res://assets/models/bestiary/winged/stymphalian-bird.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "flyer/brute",
		"behavior": "A volley of bronze feathers loosed in a fan, telegraphed by a wing flare and a metallic glint before release;",
		"sound_vocal": "PROCEDURAL: bellow plus snort (low saw + noise bursts).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_002.ogg",
	},
	"bronze-bull": {
		"name": "Bronze Bull", "color": Color(0.52, 0.54, 0.58),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "bronze-bull", "model": "res://assets/models/bestiary/quadruped-beast/bronze-bull.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "caster",
		"behavior": "A gore charge, telegraphed by pawing and a snort of steam, and a breath of fire at close range, telegraphed",
		"sound_vocal": "PROCEDURAL: snort and grunt (low noise bursts ~150 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"gorgon": {
		"name": "Gorgon", "color": Color(0.92, 0.9, 0.82),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "gorgon", "model": "res://assets/models/bestiary/biped-humanoid/gorgon.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "grappler/tank",
		"behavior": "A petrifying gaze, telegraphed by glowing eyes and a held stare, that slows and then holds a player who keeps",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_002.ogg",
	},
	"chimera": {
		"name": "Chimera", "color": Color(0.52, 0.54, 0.58),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "chimera", "model": "res://assets/models/bestiary/quadruped-beast/chimera.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "caster",
		"behavior": "A rotating set of close attacks — lion bite, goat butt, and serpent snap — each telegraphed by the head that",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"sphinx": {
		"name": "Sphinx", "color": Color(0.52, 0.54, 0.58),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "sphinx", "model": "res://assets/models/bestiary/quadruped-beast/sphinx.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "charger",
		"behavior": "A riddle challenge that roots or staggers a player who answers wrong or hesitates, telegraphed by a spoken",
		"sound_vocal": "PROCEDURAL: bellow plus snort (low saw + noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_002.ogg",
	},
	"griffin": {
		"name": "Griffin", "color": Color(0.6, 0.5, 0.35),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "griffin", "model": "res://assets/models/bestiary/winged/griffin.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "flyer/brute",
		"behavior": "A swooping talon rake, telegraphed by a folded-wing dive line, and a close beak snap if the player closes",
		"sound_vocal": "PROCEDURAL: bellow plus snort (low saw + noise bursts).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_002.ogg",
	},
	"manticore": {
		"name": "Manticore", "color": Color(0.52, 0.54, 0.58),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "manticore", "model": "res://assets/models/bestiary/quadruped-beast/manticore.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "ranged",
		"behavior": "A volley of tail spines, telegraphed by a raised, bristling tail and a shudder before release; a lunging bite",
		"sound_vocal": "PROCEDURAL: bellow plus snort (low saw + noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"lamia": {
		"name": "Lamia", "color": Color(0.32, 0.56, 0.26),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "lamia", "model": "res://assets/models/bestiary/worm-serpent/lamia.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "grappler/tank",
		"behavior": "A lunging bite, telegraphed by a raised coil and a hiss, followed by a draining grasp that saps the player",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_002.ogg",
	},
	"empusa": {
		"name": "Empusa", "color": Color(0.92, 0.9, 0.82),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "empusa", "model": "res://assets/models/bestiary/biped-humanoid/empusa.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "caster",
		"behavior": "A seductive lure that draws the player close, followed by a sudden bite and claw rake, telegraphed by a",
		"sound_vocal": "PROCEDURAL: bellow plus snort (low saw + noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"nemean-lion": {
		"name": "Nemean Lion", "color": Color(0.52, 0.54, 0.58),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "nemean-lion", "model": "res://assets/models/bestiary/quadruped-beast/nemean-lion.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "charger",
		"behavior": "A heavy paw swipe and a lunging bite, telegraphed by a crouch, a tail lash, and a roar before the lunge.",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_001.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_002.ogg",
	},
	"hydra": {
		"name": "Hydra", "color": Color(0.32, 0.56, 0.26),
		"hp": 29.0, "atk": 8.0, "def": 1.0, "xp": 21.0, "gold": 16.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "hydra", "model": "res://assets/models/bestiary/worm-serpent/hydra.glb",
		"family": "Greek & Mediterranean Myth", "band": "D", "archetype": "caster",
		"behavior": "Multiple heads strike in sequence — bite, snap, bite — each telegraphed by the striking head rearing back;",
		"sound_vocal": "PROCEDURAL: bellow plus snort (low saw + noise bursts).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"sea-serpent": {
		"name": "Sea Serpent", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "sea-serpent", "model": "res://assets/models/bestiary/worm-serpent/sea-serpent.glb",
		"family": "Norse & Germanic", "band": "D", "archetype": "grappler/tank",
		"behavior": "A lunging bite, telegraphed by a raised head and a hiss, and a sweeping tail lash at close range, telegraphed",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"nixie": {
		"name": "Nixie", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "nixie", "model": "res://assets/models/bestiary/aquatic/nixie.glb",
		"family": "Norse & Germanic", "band": "D", "archetype": "caster",
		"behavior": "A lure song or shimmering display that draws the player toward the water, followed by a dragging grasp once",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "none (swims — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"hulder": {
		"name": "Hulder", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "hulder", "model": "res://assets/models/bestiary/biped-humanoid/hulder.glb",
		"family": "Norse & Germanic", "band": "D", "archetype": "caster",
		"behavior": "A charming call that slows and draws the player toward her, telegraphed by a soft song cue and a beckoning",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"mare": {
		"name": "Mare", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 9.0, "def": 0.0, "xp": 22.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "mare", "model": "res://assets/models/bestiary/ghost-wisp/mare.glb",
		"family": "Norse & Germanic", "band": "D", "archetype": "grappler/tank",
		"behavior": "A sleep pressure that weighs the player down, telegraphed by a dimming, heavy haze around her, followed by",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_000.ogg",
	},
	"dark-elf": {
		"name": "Dark Elf", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "dark-elf", "model": "res://assets/models/bestiary/biped-humanoid/dark-elf.glb",
		"family": "Norse & Germanic", "band": "D", "archetype": "ranged",
		"behavior": "A quick dagger stab from cover, telegraphed by a brief glint and a crouch before the dart, then an immediate",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"alfar-raider": {
		"name": "Alfar Raider", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "alfar-raider", "model": "res://assets/models/bestiary/biped-humanoid/alfar-raider.glb",
		"family": "Norse & Germanic", "band": "D", "archetype": "ranged",
		"behavior": "Loosed arrows and thrown spears, telegraphed by a draw and aim pause, with a quick sword cut if the player",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"fallen-valkyrie": {
		"name": "Fallen Valkyrie", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "fallen-valkyrie", "model": "res://assets/models/bestiary/winged/fallen-valkyrie.glb",
		"family": "Norse & Germanic", "band": "D", "archetype": "flyer/skirmisher",
		"behavior": "A diving spear thrust, telegraphed by a raised spear and a dive line, followed by sweeping sword cuts on the",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"great-wolf": {
		"name": "Great Wolf", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "great-wolf", "model": "res://assets/models/bestiary/quadruped-beast/great-wolf.glb",
		"family": "Norse & Germanic", "band": "D", "archetype": "pack skirmisher",
		"behavior": "A harrying nip, telegraphed by a lowered head and a circling tighten, and a lunging pounce, telegraphed by a",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"lindworm": {
		"name": "Lindworm", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "lindworm", "model": "res://assets/models/bestiary/worm-serpent/lindworm.glb",
		"family": "Norse & Germanic", "band": "D", "archetype": "ambusher",
		"behavior": "A lunging bite, telegraphed by a raised head and a hiss, and a tail sweep at close range, telegraphed by a",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"kraken": {
		"name": "Kraken", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "kraken", "model": "res://assets/models/bestiary/aquatic/kraken.glb",
		"family": "Norse & Germanic", "band": "D", "archetype": "grappler/tank",
		"behavior": "Tentacle grabs and slams, telegraphed by a limb rising and coiling before it falls, and a dragging pull",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "none (swims — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_003.ogg",
	},
	"scarab-swarm": {
		"name": "Scarab Swarm", "color": Color(0.28, 0.2, 0.34),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "scarab-swarm", "model": "res://assets/models/bestiary/spider-arachnid/scarab-swarm.glb",
		"family": "Egyptian & Near East", "band": "D", "archetype": "swarmer",
		"behavior": "Many small nips from all sides at once; the danger is being surrounded, not any single bite. A rising rustle",
		"sound_vocal": "PROCEDURAL: rapid leg-rustle (dense soft ticks).",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_001.ogg",
	},
	"asp": {
		"name": "Asp", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "asp", "model": "res://assets/models/bestiary/worm-serpent/asp.glb",
		"family": "Egyptian & Near East", "band": "D", "archetype": "venom skirmisher",
		"behavior": "A fast rearing strike with a raised head and flared hood as the tell, followed by a venom bite; it slips back",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"jackal-guardian": {
		"name": "Jackal Guardian", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "jackal-guardian", "model": "res://assets/models/bestiary/quadruped-beast/jackal-guardian.glb",
		"family": "Egyptian & Near East", "band": "D", "archetype": "ranged",
		"behavior": "Snap-and-retreat bites aimed at the flanks; when more than one is present they time their darts so the player",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"guardian-scorpion": {
		"name": "Guardian Scorpion", "color": Color(0.28, 0.2, 0.34),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "guardian-scorpion", "model": "res://assets/models/bestiary/spider-arachnid/guardian-scorpion.glb",
		"family": "Egyptian & Near East", "band": "D", "archetype": "venom skirmisher",
		"behavior": "Claw snaps to pin and distract, then a raised-tail sting as the real payload; the tail lift is the clear",
		"sound_vocal": "PROCEDURAL: dry chitter (fast filtered-noise ticks).",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_001.ogg",
	},
	"serpopard": {
		"name": "Serpopard", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "serpopard", "model": "res://assets/models/bestiary/worm-serpent/serpopard.glb",
		"family": "Egyptian & Near East", "band": "D", "archetype": "venom skirmisher",
		"behavior": "A neck-lunge bite that arrives before the body does, telegraphed by the neck drawing back and coiling;",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"sha-beast": {
		"name": "Sha Beast", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "sha-beast", "model": "res://assets/models/bestiary/quadruped-beast/sha-beast.glb",
		"family": "Egyptian & Near East", "band": "D", "archetype": "charger",
		"behavior": "Snapping bites and head-butts delivered mid-sprint, with a stiff-legged rear and a braying call as its",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"falcon-sphinx": {
		"name": "Falcon Sphinx", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "falcon-sphinx", "model": "res://assets/models/bestiary/quadruped-beast/falcon-sphinx.glb",
		"family": "Egyptian & Near East", "band": "D", "archetype": "charger",
		"behavior": "A wing-spread, head-high display before a leaping claw rake; the spread wings and fixed stare are the tell,",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"devourer-beast": {
		"name": "Devourer Beast", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "devourer-beast", "model": "res://assets/models/bestiary/quadruped-beast/devourer-beast.glb",
		"family": "Egyptian & Near East", "band": "D", "archetype": "charger",
		"behavior": "A triple-threat sequence — crocodile-jaw snap, lion-claw rake, and a hippo-bulk shoulder charge — with the",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"ushabti": {
		"name": "Ushabti", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "ushabti", "model": "res://assets/models/bestiary/golem-construct/ushabti.glb",
		"family": "Egyptian & Near East", "band": "D", "archetype": "tank",
		"behavior": "Repeated blunt tool-strikes — hoe-like chops and thrusts — with a slow arm raise as the tell; several figures",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	"karakasa": {
		"name": "Karakasa", "color": Color(0.62, 0.43, 0.3),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "karakasa", "model": "res://assets/models/bestiary/golem-construct/karakasa.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "ambusher",
		"behavior": "Tongue-lash flicks and hopping body-slams, telegraphed by a high hop and a tongue flick before the drop; it",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactWood_heavy_001.ogg",
	},
	"chochin-obake": {
		"name": "Chōchin-obake", "color": Color(0.78, 0.92, 0.97),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "chochin-obake", "model": "res://assets/models/bestiary/ghost-wisp/chochin-obake.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "phase skirmisher",
		"behavior": "A split-mouth snap and a burst of lantern flame, telegraphed by the lantern flaring bright and the mouth",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactWood_heavy_001.ogg",
	},
	"bake-danuki": {
		"name": "Bake-danuki", "color": Color(0.52, 0.54, 0.58),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "bake-danuki", "model": "res://assets/models/bestiary/quadruped-beast/bake-danuki.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "charger",
		"behavior": "Drumming-belly feints and sudden transformation strikes, where a harmless seeming snaps into a clawed or",
		"sound_vocal": "PROCEDURAL: buzz (sawtooth ~200 Hz + harmonics).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactWood_heavy_001.ogg",
	},
	"kasha": {
		"name": "Kasha", "color": Color(0.52, 0.54, 0.58),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "kasha", "model": "res://assets/models/bestiary/quadruped-beast/kasha.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "grappler/tank",
		"behavior": "A flaming pounce with claws extended, telegraphed by a crouch and a flare of corpse-fire around its wheels;",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactWood_heavy_001.ogg",
	},
	"kitsune": {
		"name": "Kitsune", "color": Color(0.52, 0.54, 0.58),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "kitsune", "model": "res://assets/models/bestiary/quadruped-beast/kitsune.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "pack skirmisher",
		"behavior": "Fox-fire bolts flicked from range, plus a sudden close claw strike from an afterimage's position; the fire",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactWood_heavy_001.ogg",
	},
	"tengu": {
		"name": "Tengu", "color": Color(0.6, 0.5, 0.35),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "tengu", "model": "res://assets/models/bestiary/winged/tengu.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "ranged",
		"behavior": "A fan-driven gust that pushes the player off balance, followed by a swooping sword or claw strike along a",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"yuki-onna": {
		"name": "Yuki-onna", "color": Color(0.92, 0.9, 0.82),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "yuki-onna", "model": "res://assets/models/bestiary/biped-humanoid/yuki-onna.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "caster",
		"behavior": "A freezing breath and a chilling touch, telegraphed by the air frosting visibly around her and her sleeves",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"jorogumo": {
		"name": "Jorōgumo", "color": Color(0.28, 0.2, 0.34),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "jorogumo", "model": "res://assets/models/bestiary/spider-arachnid/jorogumo.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "ambusher",
		"behavior": "A web-cast that snares and slows, telegraphed by silk threads shimmering faintly in the air before the cast,",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactWood_heavy_001.ogg",
	},
	"nure-onna": {
		"name": "Nure-onna", "color": Color(0.32, 0.56, 0.26),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "nure-onna", "model": "res://assets/models/bestiary/worm-serpent/nure-onna.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "grappler/tank",
		"behavior": "A serpent's lunge and a constricting coil, plus a handed burden — a seeming child pressed on the player —",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactWood_heavy_001.ogg",
	},
	"nue": {
		"name": "Nue", "color": Color(0.92, 0.9, 0.82),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "nue", "model": "res://assets/models/bestiary/biped-humanoid/nue.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "phase skirmisher",
		"behavior": "A mixed assault — a monkey's snapping bite, tiger claw rakes, and a serpent-tail lash — delivered in an",
		"sound_vocal": "PROCEDURAL: bell-like tinkle (sine pings ~2 kHz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactWood_heavy_001.ogg",
	},
	"tsuchigumo": {
		"name": "Tsuchigumo", "color": Color(0.28, 0.2, 0.34),
		"hp": 34.0, "atk": 8.0, "def": 2.0, "xp": 23.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "tsuchigumo", "model": "res://assets/models/bestiary/spider-arachnid/tsuchigumo.glb",
		"family": "Japanese Yōkai", "band": "D", "archetype": "venom skirmisher",
		"behavior": "A wide web-cast that snares, followed by crushing leg strikes and a venom bite; the legs rearing and silk",
		"sound_vocal": "PROCEDURAL: roar with a drum-like thump (low saw + burst).",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactWood_heavy_001.ogg",
	},
	"kelpie": {
		"name": "Kelpie", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "kelpie", "model": "res://assets/models/bestiary/aquatic/kelpie.glb",
		"family": "Celtic & British Isles", "band": "D", "archetype": "caster",
		"behavior": "An adhesive lure — the player who touches or mounts the horse form is held — followed by a drag toward the",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "none (swims — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"merrow": {
		"name": "Merrow", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "merrow", "model": "res://assets/models/bestiary/aquatic/merrow.glb",
		"family": "Celtic & British Isles", "band": "D", "archetype": "caster",
		"behavior": "A lure call and a dragging grasp at the water's edge, telegraphed by a rising song cue, followed by close",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "none (swims — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"selkie": {
		"name": "Selkie", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "selkie", "model": "res://assets/models/bestiary/aquatic/selkie.glb",
		"family": "Celtic & British Isles", "band": "D", "archetype": "skirmisher",
		"behavior": "A swift water rush and bite, telegraphed by a surfacing ripple and a turn toward the player, and a close claw",
		"sound_vocal": "PROCEDURAL: buzz (sawtooth ~200 Hz + harmonics).",
		"sound_steps": "none (swims — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_003.ogg",
	},
	"cat-sith": {
		"name": "Cat Sìth", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "cat-sith", "model": "res://assets/models/bestiary/quadruped-beast/cat-sith.glb",
		"family": "Celtic & British Isles", "band": "D", "archetype": "ambusher",
		"behavior": "A dropping pounce with claws, telegraphed by a faint silhouette above the path and a tail lash before the",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"bauchan": {
		"name": "Bauchan", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "bauchan", "model": "res://assets/models/bestiary/biped-humanoid/bauchan.glb",
		"family": "Celtic & British Isles", "band": "D", "archetype": "ranged",
		"behavior": "A spear or club jab, telegraphed by a crouch and a raised arm, then an immediate retreat; sometimes a thrown",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"fachan": {
		"name": "Fachan", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "fachan", "model": "res://assets/models/bestiary/biped-humanoid/fachan.glb",
		"family": "Celtic & British Isles", "band": "D", "archetype": "brute",
		"behavior": "A heavy single-hand slam, telegraphed by a raised arm and a long wind-up, and a hopping body slam if the",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"afanc": {
		"name": "Afanc", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "afanc", "model": "res://assets/models/bestiary/aquatic/afanc.glb",
		"family": "Celtic & British Isles", "band": "D", "archetype": "ambusher",
		"behavior": "A surging bite, telegraphed by a ripple and a rising back before the surge, and a tail thrash at close range.",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "none (swims — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_003.ogg",
	},
	"bean-nighe": {
		"name": "Bean-nighe", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 9.0, "def": 0.0, "xp": 22.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "bean-nighe", "model": "res://assets/models/bestiary/ghost-wisp/bean-nighe.glb",
		"family": "Celtic & British Isles", "band": "D", "archetype": "caster",
		"behavior": "An omen wail that weighs the player down with dread, telegraphed by a rising keen and a visible shroud cue,",
		"sound_vocal": "PROCEDURAL: wail (sine sweep 600→1400 Hz, long).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"domovoi": {
		"name": "Domovoi", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "domovoi", "model": "res://assets/models/bestiary/biped-humanoid/domovoi.glb",
		"family": "Slavic", "band": "D", "archetype": "ranged",
		"behavior": "A quick, unseen shove or trip from cover, telegraphed by a faint scuffle and a moving shadow, followed by a",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"kikimora": {
		"name": "Kikimora", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "kikimora", "model": "res://assets/models/bestiary/biped-humanoid/kikimora.glb",
		"family": "Slavic", "band": "D", "archetype": "trapper/swarm",
		"behavior": "A tangling snare that slows and trips the player, telegraphed by a whirring spin cue and a thread glint,",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"rusalka": {
		"name": "Rusalka", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "rusalka", "model": "res://assets/models/bestiary/biped-humanoid/rusalka.glb",
		"family": "Slavic", "band": "D", "archetype": "caster",
		"behavior": "A lure song that draws the player toward the water, telegraphed by a rising melody cue, followed by a",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"vodyanoy": {
		"name": "Vodyanoy", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "vodyanoy", "model": "res://assets/models/bestiary/biped-humanoid/vodyanoy.glb",
		"family": "Slavic", "band": "D", "archetype": "grappler/tank",
		"behavior": "A heavy club-like slam, telegraphed by a raised arm and a long wind-up, and a dragging grasp at the water's",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"striga": {
		"name": "Striga", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "striga", "model": "res://assets/models/bestiary/biped-humanoid/striga.glb",
		"family": "Slavic", "band": "D", "archetype": "ambusher",
		"behavior": "A dropping talon strike, telegraphed by a wing flare and a screech, and a draining bite in humanoid form,",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"leshy": {
		"name": "Leshy", "color": Color(0.4, 0.55, 0.3),
		"hp": 19.0, "atk": 6.0, "def": 0.0, "xp": 14.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "leshy", "model": "res://assets/models/bestiary/plant-fungal/leshy.glb",
		"family": "Slavic", "band": "D", "archetype": "charger",
		"behavior": "A path-scrambling call that turns the player's route, telegraphed by a whispering wind cue and shifting",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_000.ogg",
	},
	"alkonost": {
		"name": "Alkonost", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "alkonost", "model": "res://assets/models/bestiary/winged/alkonost.glb",
		"family": "Slavic", "band": "D", "archetype": "caster",
		"behavior": "A joyous, forgetful song that slows and stills the player, telegraphed by a rising melody cue and a bright",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: dazzle chime (bright sine ping, no file staged).",
	},
	"gamayun": {
		"name": "Gamayun", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "gamayun", "model": "res://assets/models/bestiary/winged/gamayun.glb",
		"family": "Slavic", "band": "D", "archetype": "caster",
		"behavior": "A prophetic song that steadies her allies and unsettles the player, telegraphed by a spoken verse cue before",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: dazzle chime (bright sine ping, no file staged).",
	},
	"mora": {
		"name": "Mora", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "mora", "model": "res://assets/models/bestiary/biped-humanoid/mora.glb",
		"family": "Slavic", "band": "D", "archetype": "venom skirmisher",
		"behavior": "A nightmare pressure that weighs the player down, telegraphed by a dimming haze, followed by close,",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"zmey": {
		"name": "Zmey", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "zmey", "model": "res://assets/models/bestiary/worm-serpent/zmey.glb",
		"family": "Slavic", "band": "D", "archetype": "caster",
		"behavior": "Multiple heads strike in sequence — bite, snap, bite — each telegraphed by the striking head rearing back,",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"firebird": {
		"name": "Firebird", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "firebird", "model": "res://assets/models/bestiary/winged/firebird.glb",
		"family": "Slavic", "band": "D", "archetype": "ranged",
		"behavior": "A blinding feather flash, telegraphed by a brightening glow before it fires, followed by a diving feather",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"cedar-guardian": {
		"name": "Cedar Guardian", "color": Color(0.4, 0.55, 0.3),
		"hp": 19.0, "atk": 6.0, "def": 0.0, "xp": 14.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "cedar-guardian", "model": "res://assets/models/bestiary/plant-fungal/cedar-guardian.glb",
		"family": "Mesopotamian", "band": "D", "archetype": "trapper/swarm",
		"behavior": "Wide, sweeping arm blows and a bellowing roar that staggers the unwary; the arms drawing back and the chest",
		"sound_vocal": "PROCEDURAL: buzz (sawtooth ~200 Hz + harmonics).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_000.ogg",
	},
	"galla": {
		"name": "Galla", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "galla", "model": "res://assets/models/bestiary/biped-humanoid/galla.glb",
		"family": "Mesopotamian", "band": "D", "archetype": "grappler/tank",
		"behavior": "Clutching grabs and dragging pulls, telegraphed by both arms reaching wide; if a grab lands, it tries to haul",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"scorpion-man": {
		"name": "Scorpion Man", "color": Color(0.28, 0.2, 0.34),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "scorpion-man", "model": "res://assets/models/bestiary/spider-arachnid/scorpion-man.glb",
		"family": "Mesopotamian", "band": "D", "archetype": "venom skirmisher",
		"behavior": "Ranged bow shots from a held position, stepping back to keep distance when closed on; if cornered, a tail",
		"sound_vocal": "PROCEDURAL: dry chitter (fast filtered-noise ticks).",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_001.ogg",
	},
	"ugallu": {
		"name": "Ugallu", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "ugallu", "model": "res://assets/models/bestiary/biped-humanoid/ugallu.glb",
		"family": "Mesopotamian", "band": "D", "archetype": "ranged",
		"behavior": "A dagger-and-mace flurry at close range after the charge, telegraphed by the weapon arm drawing high and the",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"lamassu": {
		"name": "Lamassu", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "lamassu", "model": "res://assets/models/bestiary/quadruped-beast/lamassu.glb",
		"family": "Mesopotamian", "band": "D", "archetype": "charger",
		"behavior": "Heavy paw swipes and a forward horned-head butt, with the head lowering and wings flaring as the tell; a",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"mushussu": {
		"name": "Mušḫuššu", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "mushussu", "model": "res://assets/models/bestiary/biped-humanoid/mushussu.glb",
		"family": "Mesopotamian", "band": "D", "archetype": "venom skirmisher",
		"behavior": "A coiling lunge with a snapping bite, telegraphed by the body drawing into a tight coil and the head pulling",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"anzu": {
		"name": "Anzu", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "anzu", "model": "res://assets/models/bestiary/winged/anzu.glb",
		"family": "Mesopotamian", "band": "D", "archetype": "caster",
		"behavior": "A talon dive-rake along a visible dive line, plus a gusting wing-beat on the climb that pushes the player",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: dazzle chime (bright sine ping, no file staged).",
	},
	"asag": {
		"name": "Asag", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "asag", "model": "res://assets/models/bestiary/biped-humanoid/asag.glb",
		"family": "Mesopotamian", "band": "D", "archetype": "brawler",
		"behavior": "Rocky, flailing limb strikes plus a spreading plague ground — cracked, foul earth that punishes standing",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"naga": {
		"name": "Naga", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "naga", "model": "res://assets/models/bestiary/worm-serpent/naga.glb",
		"family": "South Asian", "band": "D", "archetype": "caster",
		"behavior": "A hood-flare display before a spitting strike and a coiling lunge; the flare is the tell, and the spit",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"yaksha": {
		"name": "Yaksha", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "yaksha", "model": "res://assets/models/bestiary/biped-humanoid/yaksha.glb",
		"family": "South Asian", "band": "D", "archetype": "brute",
		"behavior": "Overhead club and fist blows with a long arm raise as the tell, plus a sudden ground-stomp that shakes the",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"bhuta": {
		"name": "Bhūta", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "bhuta", "model": "res://assets/models/bestiary/biped-humanoid/bhuta.glb",
		"family": "South Asian", "band": "D", "archetype": "phase skirmisher",
		"behavior": "A sudden materializing strike from the drift, telegraphed by a brief shimmer where it will appear; it fades",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"pisaca": {
		"name": "Piśāca", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "pisaca", "model": "res://assets/models/bestiary/biped-humanoid/pisaca.glb",
		"family": "South Asian", "band": "D", "archetype": "brawler",
		"behavior": "Raking claw swipes and snapping bites delivered in a flurry, then an immediate break-off; a hunched,",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"rakshasa": {
		"name": "Rakshasa", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "rakshasa", "model": "res://assets/models/bestiary/biped-humanoid/rakshasa.glb",
		"family": "South Asian", "band": "D", "archetype": "brawler",
		"behavior": "Brutal claw and weapon blows with a slow, taunting wind-up, plus illusionary doubles that mirror its",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"makara": {
		"name": "Makara", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "makara", "model": "res://assets/models/bestiary/aquatic/makara.glb",
		"family": "South Asian", "band": "D", "archetype": "skirmisher",
		"behavior": "A gaping jaw snap with the mouth opening wide as the tell, followed by a tail sweep that covers its rear; it",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "none (swims — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_003.ogg",
	},
	"asura": {
		"name": "Asura", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "asura", "model": "res://assets/models/bestiary/biped-humanoid/asura.glb",
		"family": "South Asian", "band": "D", "archetype": "brawler",
		"behavior": "Powerful weapon combos with a raised-weapon wind-up as the tell, plus a shouted challenge that precedes a",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"garuda": {
		"name": "Garuda", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "garuda", "model": "res://assets/models/bestiary/winged/garuda.glb",
		"family": "South Asian", "band": "D", "archetype": "caster",
		"behavior": "A screaming stoop into a talon rake along a visible dive line, followed by a wing buffet on the climb; the",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: dazzle chime (bright sine ping, no file staged).",
	},
	"terracotta-soldier": {
		"name": "Terracotta Soldier", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "terracotta-soldier", "model": "res://assets/models/bestiary/golem-construct/terracotta-soldier.glb",
		"family": "Chinese & East Asian", "band": "D", "archetype": "tank",
		"behavior": "Synchronized spear thrusts and halberd chops with a shared arm raise as the tell; the threat is the rank's",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	"mountain-yaoguai": {
		"name": "Mountain Yaoguai", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "mountain-yaoguai", "model": "res://assets/models/bestiary/biped-humanoid/mountain-yaoguai.glb",
		"family": "Chinese & East Asian", "band": "D", "archetype": "charger",
		"behavior": "Claw rakes and shoulder charges delivered from a scramble, telegraphed by a crouch and a scramble-start",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"xiezhi": {
		"name": "Xiezhi", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "xiezhi", "model": "res://assets/models/bestiary/quadruped-beast/xiezhi.glb",
		"family": "Chinese & East Asian", "band": "D", "archetype": "charger",
		"behavior": "A single-horn gore delivered after a long, fixed stare; the stare and the horn lowering are the tell, and the",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"hulijing": {
		"name": "Hulijing", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "hulijing", "model": "res://assets/models/bestiary/quadruped-beast/hulijing.glb",
		"family": "Chinese & East Asian", "band": "D", "archetype": "charger",
		"behavior": "Beguiling feints and sudden fox-fire flickers that dazzle and misdirect, followed by a real claw strike from",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"mogwai": {
		"name": "Mogwai", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "mogwai", "model": "res://assets/models/bestiary/biped-humanoid/mogwai.glb",
		"family": "Chinese & East Asian", "band": "D", "archetype": "ranged",
		"behavior": "Nipping bites and snatching grabs at gear and hands, telegraphed by a brief massing chatter before a dart;",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"river-long": {
		"name": "River Long", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "river-long", "model": "res://assets/models/bestiary/worm-serpent/river-long.glb",
		"family": "Chinese & East Asian", "band": "D", "archetype": "grappler/tank",
		"behavior": "A coiling lunge with a snapping bite, plus a sweeping tail lash as it uncoils; the coil tightening is the",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"taotie": {
		"name": "Taotie", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "taotie", "model": "res://assets/models/bestiary/biped-humanoid/taotie.glb",
		"family": "Chinese & East Asian", "band": "D", "archetype": "ambusher",
		"behavior": "A gaping, devouring bite with the mouth opening wider as the tell, followed by a swallowing lunge that pulls",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"hundun": {
		"name": "Hundun", "color": Color(0.35, 0.9, 0.4),
		"hp": 18.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.65, 1.0), "build": "hundun", "model": "res://assets/models/bestiary/blob-ooze/hundun.glb",
		"family": "Chinese & East Asian", "band": "D", "archetype": "charger",
		"behavior": "Confusing, directionless flails and a disorienting presence that scrambles the player's sense of where the",
		"sound_vocal": "PROCEDURAL: wet glorp, low sine blip 180→90 Hz.",
		"sound_steps": "PROCEDURAL: soft squelch (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactSoft_medium_000.ogg",
	},
	"qilin-corrupted": {
		"name": "Qilin  Corrupted", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "qilin-corrupted", "model": "res://assets/models/bestiary/quadruped-beast/qilin-corrupted.glb",
		"family": "Chinese & East Asian", "band": "D", "archetype": "charger",
		"behavior": "A horn gore delivered after a pawing, head-lowering charge telegraph, plus a corrupted aura-flare that",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"ahuizotl": {
		"name": "Ahuizotl", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "ahuizotl", "model": "res://assets/models/bestiary/aquatic/ahuizotl.glb",
		"family": "Mesoamerican & Andean", "band": "D", "archetype": "ambusher",
		"behavior": "A grabbing tail-hand snatch that drags the player toward the water, telegraphed by ripples and a faint cry",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "none (swims — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_003.ogg",
	},
	"death-bat": {
		"name": "Death Bat", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "death-bat", "model": "res://assets/models/bestiary/winged/death-bat.glb",
		"family": "Mesoamerican & Andean", "band": "D", "archetype": "pack skirmisher",
		"behavior": "A diving bite that drains as it clings briefly, telegraphed by a circling shriek and a dive line that",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"nagual": {
		"name": "Nagual", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "nagual", "model": "res://assets/models/bestiary/quadruped-beast/nagual.glb",
		"family": "Mesoamerican & Andean", "band": "D", "archetype": "ranged",
		"behavior": "The attack changes with the form: bites, claws, or a darting strike, each telegraphed by a shimmer and a",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"storm-wraith": {
		"name": "Storm Wraith", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 9.0, "def": 0.0, "xp": 22.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "storm-wraith", "model": "res://assets/models/bestiary/ghost-wisp/storm-wraith.glb",
		"family": "Mesoamerican & Andean", "band": "D", "archetype": "phase skirmisher",
		"behavior": "Wind and lightning bursts from range, telegraphed by a long, visible gathering of storm light before each",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_000.ogg",
	},
	"tzitzimitl": {
		"name": "Tzitzimitl", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "tzitzimitl", "model": "res://assets/models/bestiary/biped-humanoid/tzitzimitl.glb",
		"family": "Mesoamerican & Andean", "band": "D", "archetype": "phase skirmisher",
		"behavior": "Starlight volleys and a dread gaze that slows the player, telegraphed by a brightening of its skeletal eyes",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"cipactli-brood": {
		"name": "Cipactli Brood", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "cipactli-brood", "model": "res://assets/models/bestiary/aquatic/cipactli-brood.glb",
		"family": "Mesoamerican & Andean", "band": "D", "archetype": "swarmer",
		"behavior": "Many small bites from all sides at once, telegraphed by the massing surge and a churning ripple of bodies",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "PROCEDURAL: single wet hop-thump on landing (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_003.ogg",
	},
	"tokoloshe": {
		"name": "Tokoloshe", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "tokoloshe", "model": "res://assets/models/bestiary/biped-humanoid/tokoloshe.glb",
		"family": "African Traditions", "band": "D", "archetype": "ambusher",
		"behavior": "Quick low strikes and tripping grabs from unexpected cover, telegraphed by a faint rustle and a glimpse of",
		"sound_vocal": "PROCEDURAL: rapid leg-rustle (dense soft ticks).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"adze": {
		"name": "Adze", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 9.0, "def": 0.0, "xp": 22.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "adze", "model": "res://assets/models/bestiary/ghost-wisp/adze.glb",
		"family": "African Traditions", "band": "D", "archetype": "phase skirmisher",
		"behavior": "A draining bite delivered after drifting close under the guise of a harmless light, telegraphed by the light",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_000.ogg",
	},
	"impundulu": {
		"name": "Impundulu", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "impundulu", "model": "res://assets/models/bestiary/winged/impundulu.glb",
		"family": "African Traditions", "band": "D", "archetype": "pack skirmisher",
		"behavior": "Lightning strikes called from its circling flight and a diving talon rake, telegraphed by a brightening storm",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"sasabonsam": {
		"name": "Sasabonsam", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "sasabonsam", "model": "res://assets/models/bestiary/winged/sasabonsam.glb",
		"family": "African Traditions", "band": "D", "archetype": "ambusher",
		"behavior": "A dropping ambush with hooked feet and iron teeth, telegraphed by a faint silhouette above the path and a",
		"sound_vocal": "PROCEDURAL: rapid leg-rustle (dense soft ticks).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"mami-wata": {
		"name": "Mami Wata", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "mami-wata", "model": "res://assets/models/bestiary/aquatic/mami-wata.glb",
		"family": "African Traditions", "band": "D", "archetype": "caster",
		"behavior": "Luring calls and water magic from range, telegraphed by a shimmering, beautiful display and a stillness",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "none (swims — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"inkanyamba": {
		"name": "Inkanyamba", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "inkanyamba", "model": "res://assets/models/bestiary/worm-serpent/inkanyamba.glb",
		"family": "African Traditions", "band": "D", "archetype": "ranged",
		"behavior": "Storm-lashed coils and sweeping tail strikes, telegraphed by water churning and a rising serpent silhouette",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"sprite": {
		"name": "Sprite", "color": Color(0.6, 0.5, 0.35),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "sprite", "model": "res://assets/models/bestiary/winged/sprite.glb",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "ranged",
		"behavior": "Quick darting sting or nip, then a climbing retreat out of melee reach.",
		"sound_vocal": "PROCEDURAL: bell-like tinkle (sine pings ~2 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"bramble-imp": {
		"name": "Bramble Imp", "color": Color(0.52, 0.54, 0.58),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "bramble-imp", "model": "res://assets/models/bestiary/quadruped-beast/bramble-imp.glb",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "charger",
		"behavior": "Thorned jab from cover, then a scramble to a new hiding spot.",
		"sound_vocal": "PROCEDURAL: bell-like tinkle (sine pings ~2 kHz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"brownie": {
		"name": "Brownie", "color": Color(0.92, 0.9, 0.82),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "brownie", "model": "res://assets/models/bestiary/biped-humanoid/brownie.glb",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "brawler",
		"behavior": "Hit-and-run prod or trip-style swipe, always followed by a retreat to cover.",
		"sound_vocal": "PROCEDURAL: bell-like tinkle (sine pings ~2 kHz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"dryad": {
		"name": "Dryad", "color": Color(0.4, 0.55, 0.3),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "dryad", "model": "res://assets/models/bestiary/plant-fungal/dryad.glb",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "trapper/swarm",
		"behavior": "Lashing branch sweeps at close range and a slow, arcing seed or thorn volley at range.",
		"sound_vocal": "PROCEDURAL: low creak and leaf-rustle (no file staged).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_000.ogg",
	},
	"naiad": {
		"name": "Naiad", "color": Color(0.42, 0.62, 0.3),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "naiad", "model": "res://assets/models/bestiary/aquatic/naiad.glb",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "grappler/tank",
		"behavior": "Splashing wave lash at range and a dragging pull when the player stands in wet ground.",
		"sound_vocal": "PROCEDURAL: wet croak-gurgle (low sine + noise).",
		"sound_steps": "none (swims — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_003.ogg",
	},
	"sylph": {
		"name": "Sylph", "color": Color(0.6, 0.5, 0.35),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "sylph", "model": "res://assets/models/bestiary/winged/sylph.glb",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "pack skirmisher",
		"behavior": "Gust bolts and swirling wind slashes thrown from above, then a drift to a new angle.",
		"sound_vocal": "PROCEDURAL: bell-like tinkle (sine pings ~2 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"faun": {
		"name": "Faun", "color": Color(0.92, 0.9, 0.82),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "faun", "model": "res://assets/models/bestiary/biped-humanoid/faun.glb",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "brawler",
		"behavior": "Bounding kick or horn jab, then an immediate leap back out of range.",
		"sound_vocal": "PROCEDURAL: bell-like tinkle (sine pings ~2 kHz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"will-o-wisp": {
		"name": "Will-o'-wisp", "color": Color(0.78, 0.92, 0.97),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "will-o-wisp", "model": "res://assets/models/bestiary/ghost-wisp/will-o-wisp.glb",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "caster",
		"behavior": "No direct strike — it lures the player onward, then flares in a burst when the player follows too far or",
		"sound_vocal": "PROCEDURAL: bell-like tinkle (sine pings ~2 kHz).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"changeling": {
		"name": "Changeling", "color": Color(0.92, 0.9, 0.82),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "changeling", "model": "res://assets/models/bestiary/biped-humanoid/changeling.glb",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "ambusher",
		"behavior": "Ambush strike at the moment its disguise drops, followed by a scrambling retreat to re-disguise.",
		"sound_vocal": "PROCEDURAL: bell-like tinkle (sine pings ~2 kHz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"elder-dryad": {
		"name": "Elder Dryad", "color": Color(0.4, 0.55, 0.3),
		"hp": 7.0, "atk": 4.0, "def": 0.0, "xp": 10.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "elder-dryad", "model": "res://assets/models/bestiary/plant-fungal/elder-dryad.glb",
		"family": "Fey & Nature Spirits", "band": "T", "archetype": "trapper/swarm",
		"behavior": "Wide root sweeps, falling branch strikes, and a slow thorn volley that fills its grove.",
		"sound_vocal": "PROCEDURAL: low creak and leaf-rustle (no file staged).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_000.ogg",
	},
	"possessed-cultist": {
		"name": "Possessed Cultist", "color": Color(0.92, 0.9, 0.82),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "possessed-cultist", "model": "res://assets/models/bestiary/biped-humanoid/possessed-cultist.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "caster",
		"behavior": "Wild melee swipes plus a chanted bolt at range, telegraphed by a head-tilt and a rising chant before the bolt",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"succubus": {
		"name": "Succubus", "color": Color(0.92, 0.9, 0.82),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "succubus", "model": "res://assets/models/bestiary/biped-humanoid/succubus.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "caster",
		"behavior": "A beguiling lure — a raised hand and a fixing gaze as the tell — followed by a draining embrace at close",
		"sound_vocal": "PROCEDURAL: giggling cackle (high pitched bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"incubus": {
		"name": "Incubus", "color": Color(0.92, 0.9, 0.82),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "incubus", "model": "res://assets/models/bestiary/biped-humanoid/incubus.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "ranged",
		"behavior": "A grappling embrace that drains as it holds, telegraphed by a crouch and arms spreading before the lunge.",
		"sound_vocal": "PROCEDURAL: giggling cackle (high pitched bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"pit-brute": {
		"name": "Pit Brute", "color": Color(0.92, 0.9, 0.82),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "pit-brute", "model": "res://assets/models/bestiary/biped-humanoid/pit-brute.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "brute",
		"behavior": "Heavy overhead slams with a long weapon raise, followed by a wide ground-shaking stomp announced by a foot",
		"sound_vocal": "PROCEDURAL: giggling cackle (high pitched bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_light_001.ogg",
	},
	"djinn": {
		"name": "Djinn", "color": Color(0.92, 0.9, 0.82),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "djinn", "model": "res://assets/models/bestiary/biped-humanoid/djinn.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "caster",
		"behavior": "Conjured fire bolts and a smoke-blink strike — it vanishes in smoke and re-forms beside the player to strike,",
		"sound_vocal": "PROCEDURAL: giggling cackle (high pitched bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"larva-of-the-damned": {
		"name": "Larva of the Damned", "color": Color(0.32, 0.56, 0.26),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "larva-of-the-damned", "model": "res://assets/models/bestiary/worm-serpent/larva-of-the-damned.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "venom skirmisher",
		"behavior": "Gnawing bites from many mouths at once at close range, telegraphed by the mass rearing and surging forward",
		"sound_vocal": "PROCEDURAL: giggling cackle (high pitched bursts).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_light_001.ogg",
	},
	"ifrit": {
		"name": "Ifrit", "color": Color(0.92, 0.9, 0.82),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "ifrit", "model": "res://assets/models/bestiary/biped-humanoid/ifrit.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "brute",
		"behavior": "Sweeping fire blasts and a ground-slam that sends flame outward, each announced by the ifrit inhaling and its",
		"sound_vocal": "PROCEDURAL: giggling cackle (high pitched bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_light_001.ogg",
	},
	"marid": {
		"name": "Marid", "color": Color(0.92, 0.9, 0.82),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "marid", "model": "res://assets/models/bestiary/biped-humanoid/marid.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "caster",
		"behavior": "Conjured water bolts and a surging tide-push that drives the player back, telegraphed by the marid gathering",
		"sound_vocal": "PROCEDURAL: giggling cackle (high pitched bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"contract-devil": {
		"name": "Contract Devil", "color": Color(0.92, 0.9, 0.82),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "contract-devil", "model": "res://assets/models/bestiary/biped-humanoid/contract-devil.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "caster",
		"behavior": "Binding bolts and a spoken bargain-offer at range — the offer is announced by a raised hand and a formal",
		"sound_vocal": "PROCEDURAL: giggling cackle (high pitched bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"shaitan": {
		"name": "Shaitan", "color": Color(0.92, 0.9, 0.82),
		"hp": 10.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "shaitan", "model": "res://assets/models/bestiary/biped-humanoid/shaitan.glb",
		"family": "Demons, Devils & the Damned", "band": "T", "archetype": "caster",
		"behavior": "Crushing weapon blows with a long raise, plus storm bolts from range announced by a gathering crackle before",
		"sound_vocal": "PROCEDURAL: giggling cackle (high pitched bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"deva": {
		"name": "Deva", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "deva", "model": "res://assets/models/bestiary/biped-humanoid/deva.glb",
		"family": "Celestials & the Fallen", "band": "D", "archetype": "caster",
		"behavior": "Radiant bolts from range, each announced by a hand raised and a gathering glow before the bolt flies.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"seraph": {
		"name": "Seraph", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "seraph", "model": "res://assets/models/bestiary/winged/seraph.glb",
		"family": "Celestials & the Fallen", "band": "D", "archetype": "caster",
		"behavior": "A diving radiant strike plus ranged light bolts from the air, telegraphed by wings folding before a dive and",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: dazzle chime (bright sine ping, no file staged).",
	},
	"ophanim": {
		"name": "Ophanim", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "ophanim", "model": "res://assets/models/bestiary/golem-construct/ophanim.glb",
		"family": "Celestials & the Fallen", "band": "D", "archetype": "tank",
		"behavior": "Sweeping eye-beams that track across the ground, telegraphed by the wheel slowing and its many eyes",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	"watcher": {
		"name": "Watcher", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "watcher", "model": "res://assets/models/bestiary/biped-humanoid/watcher.glb",
		"family": "Celestials & the Fallen", "band": "D", "archetype": "phase skirmisher",
		"behavior": "After a long, silent stare — the only warning is the watcher's gaze fixing and brightening — it calls down a",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"fallen-angel": {
		"name": "Fallen Angel", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "fallen-angel", "model": "res://assets/models/bestiary/biped-humanoid/fallen-angel.glb",
		"family": "Celestials & the Fallen", "band": "D", "archetype": "caster",
		"behavior": "Heavy wing-assisted sword blows with a long raise, plus a dark bolt from range announced by a gathering",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"ashen-seraph": {
		"name": "Ashen Seraph", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "ashen-seraph", "model": "res://assets/models/bestiary/winged/ashen-seraph.glb",
		"family": "Celestials & the Fallen", "band": "D", "archetype": "ambusher",
		"behavior": "A diving strike that leaves a trail of ash, plus scattered ember bolts, telegraphed by a shuddering wing-fold",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"gnome": {
		"name": "Gnome", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "gnome", "model": "res://assets/models/bestiary/biped-humanoid/gnome.glb",
		"family": "Elementals & Primal Spirits", "band": "D", "archetype": "brawler",
		"behavior": "Quick earth jab or tossed stone, then a duck back into cover or soil.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"salamander": {
		"name": "Salamander", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "salamander", "model": "res://assets/models/bestiary/quadruped-beast/salamander.glb",
		"family": "Elementals & Primal Spirits", "band": "D", "archetype": "caster",
		"behavior": "Flame lick at close range and a short fire-spit at mid-range, both telegraphed by a brightening glow.",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"fire-elemental": {
		"name": "Fire Elemental", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "fire-elemental", "model": "res://assets/models/bestiary/biped-humanoid/fire-elemental.glb",
		"family": "Elementals & Primal Spirits", "band": "D", "archetype": "brawler",
		"behavior": "Sweeping flame lash at close range and a lobbed fireball at range, telegraphed by a swelling flare.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"water-elemental": {
		"name": "Water Elemental", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "water-elemental", "model": "res://assets/models/bestiary/biped-humanoid/water-elemental.glb",
		"family": "Elementals & Primal Spirits", "band": "D", "archetype": "tank/regen",
		"behavior": "Crashing wave slam at close range and a surging water jet at range.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"earth-elemental": {
		"name": "Earth Elemental", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "earth-elemental", "model": "res://assets/models/bestiary/biped-humanoid/earth-elemental.glb",
		"family": "Elementals & Primal Spirits", "band": "D", "archetype": "brute",
		"behavior": "Massive ground slam with a long raised-arm wind-up, plus a shock ripple along the ground.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"air-elemental": {
		"name": "Air Elemental", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "air-elemental", "model": "res://assets/models/bestiary/biped-humanoid/air-elemental.glb",
		"family": "Elementals & Primal Spirits", "band": "D", "archetype": "pack skirmisher",
		"behavior": "Cutting gust slash from a dive and a buffeting wind burst that pushes the player off balance.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"undine": {
		"name": "Undine", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "undine", "model": "res://assets/models/bestiary/biped-humanoid/undine.glb",
		"family": "Elementals & Primal Spirits", "band": "D", "archetype": "phase skirmisher",
		"behavior": "Lashing water whip at range and a chilling mist burst at close range.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"storm-elemental": {
		"name": "Storm Elemental", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "storm-elemental", "model": "res://assets/models/bestiary/biped-humanoid/storm-elemental.glb",
		"family": "Elementals & Primal Spirits", "band": "D", "archetype": "caster",
		"behavior": "Lightning bolt strikes telegraphed by a gathering charge glow, plus a gusting shockwave burst.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"magma-elemental": {
		"name": "Magma Elemental", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "magma-elemental", "model": "res://assets/models/bestiary/biped-humanoid/magma-elemental.glb",
		"family": "Elementals & Primal Spirits", "band": "D", "archetype": "caster",
		"behavior": "Molten slam at close range and a lobbed magma glob that bursts into a burning patch.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"frost-elemental": {
		"name": "Frost Elemental", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "frost-elemental", "model": "res://assets/models/bestiary/biped-humanoid/frost-elemental.glb",
		"family": "Elementals & Primal Spirits", "band": "D", "archetype": "brute",
		"behavior": "Freezing shard volley at range and a chilling slam at close range, telegraphed by a brightening ice sheen.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"gargoyle": {
		"name": "Gargoyle", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "gargoyle", "model": "res://assets/models/bestiary/golem-construct/gargoyle.glb",
		"family": "Golems & Constructs", "band": "D", "archetype": "flyer/skirmisher",
		"behavior": "Dive rake with talons, telegraphed by the dive line, plus a close-range claw swipe when grounded.",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	"living-statue": {
		"name": "Living Statue", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "living-statue", "model": "res://assets/models/bestiary/golem-construct/living-statue.glb",
		"family": "Golems & Constructs", "band": "D", "archetype": "brute",
		"behavior": "Sweeping stone arm strike and a crushing two-handed blow, both with long wind-ups.",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	"haunted-armor": {
		"name": "Haunted Armor", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "haunted-armor", "model": "res://assets/models/bestiary/golem-construct/haunted-armor.glb",
		"family": "Golems & Constructs", "band": "D", "archetype": "tank",
		"behavior": "Sword chop with a formal raised-blade wind-up, plus a shield shove at close range.",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	"stone-golem": {
		"name": "Stone Golem", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "stone-golem", "model": "res://assets/models/bestiary/golem-construct/stone-golem.glb",
		"family": "Golems & Constructs", "band": "D", "archetype": "charger",
		"behavior": "Wide ground slam and a shoulder charge down straight lines, telegraphed by a grinding crouch.",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	"bone-golem": {
		"name": "Bone Golem", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "bone-golem", "model": "res://assets/models/bestiary/golem-construct/bone-golem.glb",
		"family": "Golems & Constructs", "band": "D", "archetype": "ranged",
		"behavior": "Raking bone-claw sweeps and a throwing-bone volley at range.",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"brass-automaton": {
		"name": "Brass Automaton", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "brass-automaton", "model": "res://assets/models/bestiary/golem-construct/brass-automaton.glb",
		"family": "Golems & Constructs", "band": "D", "archetype": "tank",
		"behavior": "Piston punch with a winding wind-up and a steam burst at close range, telegraphed by a rising hiss.",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	"iron-golem": {
		"name": "Iron Golem", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "iron-golem", "model": "res://assets/models/bestiary/golem-construct/iron-golem.glb",
		"family": "Golems & Constructs", "band": "D", "archetype": "brute",
		"behavior": "Crushing fist slam with a very long wind-up and a ground-shaking stomp that ripples outward.",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	"crystal-golem": {
		"name": "Crystal Golem", "color": Color(0.62, 0.43, 0.3),
		"hp": 45.0, "atk": 8.0, "def": 3.0, "xp": 22.0, "gold": 16.0,
		"mesh": "box", "squash": Vector3(1.0, 1.4, 0.9), "build": "crystal-golem", "model": "res://assets/models/bestiary/golem-construct/crystal-golem.glb",
		"family": "Golems & Constructs", "band": "D", "archetype": "tank",
		"behavior": "Shard volley at range, telegraphed by a brightening facet glow, plus a slicing crystal-edge strike at close",
		"sound_vocal": "PROCEDURAL: stone grind (low noise rumble).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",
	},
	"grotto-snapper": {
		"name": "Grotto Snapper", "color": Color(0.4, 0.55, 0.3),
		"hp": 19.0, "atk": 6.0, "def": 0.0, "xp": 14.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "grotto-snapper", "model": "res://assets/models/bestiary/plant-fungal/grotto-snapper.glb",
		"family": "Plants & Fungi", "band": "D", "archetype": "ambusher",
		"behavior": "Jaw snap — its maw opens slowly as the tell, then slams shut on anything inside its reach.",
		"sound_vocal": "PROCEDURAL: low creak and leaf-rustle (no file staged).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_000.ogg",
	},
	"mandrake": {
		"name": "Mandrake", "color": Color(0.4, 0.55, 0.3),
		"hp": 19.0, "atk": 6.0, "def": 0.0, "xp": 14.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "mandrake", "model": "res://assets/models/bestiary/plant-fungal/mandrake.glb",
		"family": "Plants & Fungi", "band": "D", "archetype": "caster",
		"behavior": "Piercing shriek — in folklore the root screams when pulled from the ground, and here it throws its head back,",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"vampire-vine": {
		"name": "Vampire Vine", "color": Color(0.4, 0.55, 0.3),
		"hp": 19.0, "atk": 6.0, "def": 0.0, "xp": 14.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "vampire-vine", "model": "res://assets/models/bestiary/plant-fungal/vampire-vine.glb",
		"family": "Plants & Fungi", "band": "D", "archetype": "venom skirmisher",
		"behavior": "Coiling drain — a tendril rises and sways as its tell, then whips out to coil around its target and drain",
		"sound_vocal": "PROCEDURAL: low creak and leaf-rustle (no file staged).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_000.ogg",
	},
	"fungal-shambler": {
		"name": "Fungal Shambler", "color": Color(0.4, 0.55, 0.3),
		"hp": 19.0, "atk": 6.0, "def": 0.0, "xp": 14.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "fungal-shambler", "model": "res://assets/models/bestiary/plant-fungal/fungal-shambler.glb",
		"family": "Plants & Fungi", "band": "D", "archetype": "phase skirmisher",
		"behavior": "Spore burst and bludgeoning swipe — it raises both arms as a tell, then either swings heavily or bursts a",
		"sound_vocal": "PROCEDURAL: low creak and leaf-rustle (no file staged).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_000.ogg",
	},
	"walking-oak": {
		"name": "Walking Oak", "color": Color(0.4, 0.55, 0.3),
		"hp": 19.0, "atk": 6.0, "def": 0.0, "xp": 14.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "walking-oak", "model": "res://assets/models/bestiary/plant-fungal/walking-oak.glb",
		"family": "Plants & Fungi", "band": "D", "archetype": "brute",
		"behavior": "Branch sweep and root slam — it draws a great limb back, then sweeps it across a wide arc, or drives a root",
		"sound_vocal": "PROCEDURAL: low creak and leaf-rustle (no file staged).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_000.ogg",
	},
	"thornhound": {
		"name": "Thornhound", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "thornhound", "model": "res://assets/models/bestiary/quadruped-beast/thornhound.glb",
		"family": "Plants & Fungi", "band": "D", "archetype": "pack skirmisher",
		"behavior": "Thorn rake and entangling pounce — it crouches low, brambles bristling, then pounces to rake with thorns and",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"spore-servant": {
		"name": "Spore Servant", "color": Color(0.4, 0.55, 0.3),
		"hp": 19.0, "atk": 6.0, "def": 0.0, "xp": 14.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "spore-servant", "model": "res://assets/models/bestiary/plant-fungal/spore-servant.glb",
		"family": "Plants & Fungi", "band": "D", "archetype": "trapper/swarm",
		"behavior": "Spore-laden grasp — it reaches out with both arms spread, then clutches and presses its spore-covered body",
		"sound_vocal": "PROCEDURAL: low creak and leaf-rustle (no file staged).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_000.ogg",
	},
	"corpse-flower": {
		"name": "Corpse Flower", "color": Color(0.4, 0.55, 0.3),
		"hp": 19.0, "atk": 6.0, "def": 0.0, "xp": 14.0, "gold": 12.0,
		"mesh": "box", "squash": Vector3(0.8, 1.1, 0.8), "build": "corpse-flower", "model": "res://assets/models/bestiary/plant-fungal/corpse-flower.glb",
		"family": "Plants & Fungi", "band": "D", "archetype": "caster",
		"behavior": "Carrion lure and engulfing bloom — it opens wide, releasing a heavy, sweet-rot scent, and when prey steps",
		"sound_vocal": "PROCEDURAL: low creak and leaf-rustle (no file staged).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"cave-moray": {
		"name": "Cave Moray", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "cave-moray", "model": "res://assets/models/bestiary/worm-serpent/cave-moray.glb",
		"family": "Aquatic & the Drowned Deep", "band": "D", "archetype": "ambusher",
		"behavior": "Lunging bite — its head draws back into the crevice as a tell, then it shoots out to snap at anything passing",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"drowned-sailor": {
		"name": "Drowned Sailor", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "drowned-sailor", "model": "res://assets/models/bestiary/biped-humanoid/drowned-sailor.glb",
		"family": "Aquatic & the Drowned Deep", "band": "D", "archetype": "grappler/tank",
		"behavior": "Dragging grasp — it reaches out with both arms, moaning as it closes, and tries to seize its target and pull",
		"sound_vocal": "PROCEDURAL: low moan (sine ~80 Hz, slow vibrato).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"giant-octopus": {
		"name": "Giant Octopus", "color": Color(0.42, 0.62, 0.3),
		"hp": 13.0, "atk": 4.0, "def": 0.0, "xp": 8.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.55, 1.0), "build": "giant-octopus", "model": "res://assets/models/bestiary/aquatic/giant-octopus.glb",
		"family": "Aquatic & the Drowned Deep", "band": "D", "archetype": "skirmisher",
		"behavior": "Tentacle wrap and beak bite — a tentacle rises and hovers as its tell, then whips out to wrap its target and",
		"sound_vocal": "PROCEDURAL: deep croak (sine ~90 Hz with vibrato).",
		"sound_steps": "PROCEDURAL: single wet hop-thump on landing (no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_003.ogg",
	},
	"deep-crab": {
		"name": "Deep Crab", "color": Color(0.28, 0.2, 0.34),
		"hp": 14.0, "atk": 5.0, "def": 0.0, "xp": 9.0, "gold": 8.0,
		"mesh": "sphere", "squash": Vector3(1.0, 0.5, 1.0), "build": "deep-crab", "model": "res://assets/models/bestiary/spider-arachnid/deep-crab.glb",
		"family": "Aquatic & the Drowned Deep", "band": "D", "archetype": "brute",
		"behavior": "Crushing claw snap — it raises one great claw high as a tell, then snaps it shut on whatever is in front of",
		"sound_vocal": "PROCEDURAL: dry chitter (fast filtered-noise ticks).",
		"sound_steps": "PROCEDURAL: chitin skitter (fast ticks, no file staged).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_001.ogg",
	},
	"lanternjaw": {
		"name": "Lanternjaw", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "lanternjaw", "model": "res://assets/models/bestiary/biped-humanoid/lanternjaw.glb",
		"family": "Aquatic & the Drowned Deep", "band": "D", "archetype": "ambusher",
		"behavior": "Lure-and-lunge — the glow brightens and bobs as its tell, then the great jawed head surges upward and snaps",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"world-wurm": {
		"name": "World Wurm", "color": Color(0.32, 0.56, 0.26),
		"hp": 20.0, "atk": 6.0, "def": 0.0, "xp": 12.0, "gold": 10.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "world-wurm", "model": "res://assets/models/bestiary/worm-serpent/world-wurm.glb",
		"family": "Aquatic & the Drowned Deep", "band": "D", "archetype": "pack skirmisher",
		"behavior": "Coiling crush and sweeping bite — it rears a length of its body high as a tell, then either sweeps its head",
		"sound_vocal": "PROCEDURAL: hiss (white noise, 4–8 kHz band).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"wyvern": {
		"name": "Wyvern", "color": Color(0.6, 0.5, 0.35),
		"hp": 34.0, "atk": 8.0, "def": 1.0, "xp": 24.0, "gold": 20.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "wyvern", "model": "res://assets/models/bestiary/winged/wyvern.glb",
		"family": "Dragons & Great Serpents", "band": "D", "archetype": "venom skirmisher",
		"behavior": "Dive sting with its tail barb, telegraphed by the dive line and a raised tail, plus a biting pass at close",
		"sound_vocal": "PROCEDURAL: reptilian roar (sawtooth ~140 Hz + noise).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"cockatrice": {
		"name": "Cockatrice", "color": Color(0.6, 0.5, 0.35),
		"hp": 34.0, "atk": 8.0, "def": 1.0, "xp": 24.0, "gold": 20.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "cockatrice", "model": "res://assets/models/bestiary/winged/cockatrice.glb",
		"family": "Dragons & Great Serpents", "band": "D", "archetype": "flyer/skirmisher",
		"behavior": "Pecking strikes and a slowing statue-gaze, telegraphed by a brightening eye glow.",
		"sound_vocal": "PROCEDURAL: reptilian roar (sawtooth ~140 Hz + noise).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"jaculus": {
		"name": "Jaculus", "color": Color(0.32, 0.56, 0.26),
		"hp": 34.0, "atk": 8.0, "def": 1.0, "xp": 24.0, "gold": 20.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "jaculus", "model": "res://assets/models/bestiary/worm-serpent/jaculus.glb",
		"family": "Dragons & Great Serpents", "band": "D", "archetype": "ranged",
		"behavior": "The launch itself is the attack — a high-speed piercing strike — followed by a coiling retreat to cover.",
		"sound_vocal": "PROCEDURAL: reptilian roar (sawtooth ~140 Hz + noise).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"wyrm": {
		"name": "Wyrm", "color": Color(0.32, 0.56, 0.26),
		"hp": 34.0, "atk": 8.0, "def": 1.0, "xp": 24.0, "gold": 20.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "wyrm", "model": "res://assets/models/bestiary/worm-serpent/wyrm.glb",
		"family": "Dragons & Great Serpents", "band": "D", "archetype": "flyer/skirmisher",
		"behavior": "Surfacing lunge and bite, telegraphed by churning ground, plus a tail sweep when fully surfaced.",
		"sound_vocal": "PROCEDURAL: reptilian roar (sawtooth ~140 Hz + noise).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"basilisk": {
		"name": "Basilisk", "color": Color(0.32, 0.56, 0.26),
		"hp": 34.0, "atk": 8.0, "def": 1.0, "xp": 24.0, "gold": 20.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "basilisk", "model": "res://assets/models/bestiary/worm-serpent/basilisk.glb",
		"family": "Dragons & Great Serpents", "band": "D", "archetype": "venom skirmisher",
		"behavior": "Petrifying gaze telegraphed by eye glow, plus a venomous bite at close range.",
		"sound_vocal": "PROCEDURAL: reptilian roar (sawtooth ~140 Hz + noise).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"amphiptere": {
		"name": "Amphiptere", "color": Color(0.32, 0.56, 0.26),
		"hp": 34.0, "atk": 8.0, "def": 1.0, "xp": 24.0, "gold": 20.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "amphiptere", "model": "res://assets/models/bestiary/worm-serpent/amphiptere.glb",
		"family": "Dragons & Great Serpents", "band": "D", "archetype": "grappler/tank",
		"behavior": "Coiling constriction dive from above, telegraphed by the coil tightening, plus a snapping bite.",
		"sound_vocal": "PROCEDURAL: reptilian roar (sawtooth ~140 Hz + noise).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"peluda": {
		"name": "Peluda", "color": Color(0.52, 0.54, 0.58),
		"hp": 34.0, "atk": 8.0, "def": 1.0, "xp": 24.0, "gold": 20.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "peluda", "model": "res://assets/models/bestiary/quadruped-beast/peluda.glb",
		"family": "Dragons & Great Serpents", "band": "D", "archetype": "charger",
		"behavior": "Quill volley at range, telegraphed by a bristling shake, plus a trampling charge down straight lines.",
		"sound_vocal": "PROCEDURAL: reptilian roar (sawtooth ~140 Hz + noise).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"elder-wyrm": {
		"name": "Elder Wyrm", "color": Color(0.32, 0.56, 0.26),
		"hp": 34.0, "atk": 8.0, "def": 1.0, "xp": 24.0, "gold": 20.0,
		"mesh": "sphere", "squash": Vector3(0.7, 0.4, 1.6), "build": "elder-wyrm", "model": "res://assets/models/bestiary/worm-serpent/elder-wyrm.glb",
		"family": "Dragons & Great Serpents", "band": "D", "archetype": "caster",
		"behavior": "Multi-point surfacing bites, ground-churning tail sweeps, and a long breath wash along the ground.",
		"sound_vocal": "PROCEDURAL: reptilian roar (sawtooth ~140 Hz + noise).",
		"sound_steps": "none (slithers; soft drag, procedural).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"tarasque": {
		"name": "Tarasque", "color": Color(0.52, 0.54, 0.58),
		"hp": 34.0, "atk": 8.0, "def": 1.0, "xp": 24.0, "gold": 20.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "tarasque", "model": "res://assets/models/bestiary/quadruped-beast/tarasque.glb",
		"family": "Dragons & Great Serpents", "band": "D", "archetype": "caster",
		"behavior": "Shell-shoulder charge down straight lines, a poisonous breath wash telegraphed by a swelling throat, and a",
		"sound_vocal": "PROCEDURAL: reptilian roar (sawtooth ~140 Hz + noise).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"grave-robber": {
		"name": "Grave Robber", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "grave-robber", "model": "res://assets/models/bestiary/biped-humanoid/grave-robber.glb",
		"family": "Humans & the Damned Living", "band": "D", "archetype": "brawler",
		"behavior": "a desperate shovel or knife swipe when cornered, plus scattering debris to blind and distract; the tell is",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"cultist": {
		"name": "Cultist", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "cultist", "model": "res://assets/models/bestiary/biped-humanoid/cultist.glb",
		"family": "Humans & the Damned Living", "band": "D", "archetype": "pack skirmisher",
		"behavior": "ritual dagger lunges plus a channeled rite (raised arms, glowing circle, rising chant) that calls something",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"witch": {
		"name": "Witch", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "witch", "model": "res://assets/models/bestiary/biped-humanoid/witch.glb",
		"family": "Humans & the Damned Living", "band": "D", "archetype": "caster",
		"behavior": "hexes and thrown phials — a curse gesture (pointed finger, muttered words, a visible dark wisp) that withers",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"berserker": {
		"name": "Berserker", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "berserker", "model": "res://assets/models/bestiary/biped-humanoid/berserker.glb",
		"family": "Humans & the Damned Living", "band": "D", "archetype": "charger",
		"behavior": "a whirlwind of axe swings once it arrives; the tell is a roaring pause and a stamped foot before the rush,",
		"sound_vocal": "PROCEDURAL: guttural roar (sawtooth ~90 Hz).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"bandit-chief": {
		"name": "Bandit Chief", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "bandit-chief", "model": "res://assets/models/bestiary/biped-humanoid/bandit-chief.glb",
		"family": "Humans & the Damned Living", "band": "D", "archetype": "brawler",
		"behavior": "skilled bladework with feints — a raised blade that may become a cut or a thrust — plus a shouted order that",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"mad-alchemist": {
		"name": "Mad Alchemist", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "mad-alchemist", "model": "res://assets/models/bestiary/biped-humanoid/mad-alchemist.glb",
		"family": "Humans & the Damned Living", "band": "D", "archetype": "ranged",
		"behavior": "a barrage of thrown phials with mixed effects — bursting, clinging, choking — each telegraphed by the phial's",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "PROCEDURAL: bow twang + arrow whistle (no file staged).",
	},
	"necromancer": {
		"name": "Necromancer", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "necromancer", "model": "res://assets/models/bestiary/biped-humanoid/necromancer.glb",
		"family": "Humans & the Damned Living", "band": "D", "archetype": "caster",
		"behavior": "bolts of grave-cold force plus a raising gesture (raised staff, green glow, corpses stirring) that brings",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"warlock": {
		"name": "Warlock", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "warlock", "model": "res://assets/models/bestiary/biped-humanoid/warlock.glb",
		"family": "Humans & the Damned Living", "band": "D", "archetype": "caster",
		"behavior": "eldritch bolts and a channeled blast (gathering dark glow, a raised hand, a beat of stillness) that hits hard",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_001.ogg",
	},
	"plague-bearer": {
		"name": "Plague Bearer", "color": Color(0.52, 0.54, 0.58),
		"hp": 17.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 8.0,
		"mesh": "box", "squash": Vector3(0.7, 0.8, 1.2), "build": "plague-bearer", "model": "res://assets/models/bestiary/quadruped-beast/plague-bearer.glb",
		"family": "Humans & the Damned Living", "band": "D", "archetype": "charger",
		"behavior": "a coughing miasma that spreads around it and clinging, diseased swipes; the tell is a deep, rattling inhale",
		"sound_vocal": "PROCEDURAL: growl rising to a howl (sawtooth ~120 Hz, pitch envelope).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_002.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGeneric_light_004.ogg",
	},
	"fallen-knight": {
		"name": "Fallen Knight", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "fallen-knight", "model": "res://assets/models/bestiary/biped-humanoid/fallen-knight.glb",
		"family": "Humans & the Damned Living", "band": "D", "archetype": "brawler",
		"behavior": "a shield bash followed by a heavy sword cut, in sequence; the tells are the shield drawing back for the bash",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"storm-crow": {
		"name": "Storm Crow", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "storm-crow", "model": "res://assets/models/bestiary/winged/storm-crow.glb",
		"family": "Sky & Storm", "band": "D", "archetype": "swarmer",
		"behavior": "Dive-pecks from above, telegraphed by a circling bird breaking formation and dropping along a visible line.",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"roc": {
		"name": "Roc", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "roc", "model": "res://assets/models/bestiary/winged/roc.glb",
		"family": "Sky & Storm", "band": "D", "archetype": "pack skirmisher",
		"behavior": "A talon stoop that rakes along its dive path, telegraphed by the widening wing shadow and a folding of the",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"phoenix": {
		"name": "Phoenix", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "phoenix", "model": "res://assets/models/bestiary/winged/phoenix.glb",
		"family": "Sky & Storm", "band": "D", "archetype": "pack skirmisher",
		"behavior": "Sweeping fire from above and a diving ember rake, telegraphed by a brightening glow and an inhale-like flare",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"thunderbird": {
		"name": "Thunderbird", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "thunderbird", "model": "res://assets/models/bestiary/winged/thunderbird.glb",
		"family": "Sky & Storm", "band": "D", "archetype": "flyer/skirmisher",
		"behavior": "Storm strikes called down from above — thunderclaps and lightning — telegraphed by wing beats quickening and",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"simurgh": {
		"name": "Simurgh", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "simurgh", "model": "res://assets/models/bestiary/winged/simurgh.glb",
		"family": "Sky & Storm", "band": "D", "archetype": "pack skirmisher",
		"behavior": "Sweeping wing gusts and radiant feather volleys from above, telegraphed by a slow wing raise and a shimmer",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"ziz": {
		"name": "Ziz", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "ziz", "model": "res://assets/models/bestiary/winged/ziz.glb",
		"family": "Sky & Storm", "band": "D", "archetype": "pack skirmisher",
		"behavior": "A vast stooping rake along a long dive line, telegraphed by the sun dimming under its wings and a long shadow",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"living-shadow": {
		"name": "Living Shadow", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 9.0, "def": 0.0, "xp": 22.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "living-shadow", "model": "res://assets/models/bestiary/ghost-wisp/living-shadow.glb",
		"family": "The Abyssal & Cosmic", "band": "D", "archetype": "phase skirmisher",
		"behavior": "Phase strike delivered from the drift, then a drift-away, telegraphed by a materializing shimmer.",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_000.ogg",
	},
	"titan": {
		"name": "Titan", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "titan", "model": "res://assets/models/bestiary/biped-humanoid/titan.glb",
		"family": "The Abyssal & Cosmic", "band": "D", "archetype": "brute",
		"behavior": "Colossal overhead slam and a ground-shaking stomp ripple, both with very long wind-ups.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"void-horror": {
		"name": "Void Horror", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "void-horror", "model": "res://assets/models/bestiary/biped-humanoid/void-horror.glb",
		"family": "The Abyssal & Cosmic", "band": "D", "archetype": "phase skirmisher",
		"behavior": "Grasping tendril lash at range and a draining close-range grip, telegraphed by a darkening ripple.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"null-seraph": {
		"name": "Null Seraph", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "null-seraph", "model": "res://assets/models/bestiary/winged/null-seraph.glb",
		"family": "The Abyssal & Cosmic", "band": "D", "archetype": "flyer/skirmisher",
		"behavior": "Radiant beam volleys from above, telegraphed by a gathering halo glow, plus a silencing aura pulse at close",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",
	},
	"entropy-wraith": {
		"name": "Entropy Wraith", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 9.0, "def": 0.0, "xp": 22.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "entropy-wraith", "model": "res://assets/models/bestiary/ghost-wisp/entropy-wraith.glb",
		"family": "The Abyssal & Cosmic", "band": "D", "archetype": "phase skirmisher",
		"behavior": "Withering touch at close range and a decay wave at mid-range, telegraphed by a paling shimmer.",
		"sound_vocal": "PROCEDURAL: hollow whisper (breathy filtered noise).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_000.ogg",
	},
	"star-horror": {
		"name": "Star Horror", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "star-horror", "model": "res://assets/models/bestiary/biped-humanoid/star-horror.glb",
		"family": "The Abyssal & Cosmic", "band": "D", "archetype": "grappler/tank",
		"behavior": "Starlight burst volleys telegraphed by a brightening core, plus a gravitational pull that drags the player",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"the-hollow-choir": {
		"name": "The Hollow Choir", "color": Color(0.78, 0.92, 0.97),
		"hp": 22.0, "atk": 9.0, "def": 0.0, "xp": 22.0, "gold": 15.0,
		"mesh": "sphere", "squash": Vector3(0.8, 1.2, 0.8), "build": "the-hollow-choir", "model": "res://assets/models/bestiary/ghost-wisp/the-hollow-choir.glb",
		"family": "The Abyssal & Cosmic", "band": "D", "archetype": "swarmer",
		"behavior": "Layered scream volleys from several voices at once, telegraphed by a rising harmonic swell, plus a",
		"sound_vocal": "PROCEDURAL: wail (sine sweep 600→1400 Hz, long).",
		"sound_steps": "none (floats — no footsteps).",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_000.ogg",
	},
	"ashen-titan": {
		"name": "Ashen Titan", "color": Color(0.92, 0.9, 0.82),
		"hp": 30.0, "atk": 6.0, "def": 1.0, "xp": 18.0, "gold": 14.0,
		"mesh": "box", "squash": Vector3(0.7, 1.3, 0.7), "build": "ashen-titan", "model": "res://assets/models/bestiary/biped-humanoid/ashen-titan.glb",
		"family": "The Abyssal & Cosmic", "band": "D", "archetype": "brute",
		"behavior": "Ash-cloud slam at close range, telegraphed by a rising ash plume, plus an ember volley at range.",
		"sound_vocal": "PROCEDURAL: dry bone rattle (filtered noise bursts).",
		"sound_steps": "res://assets/audio/kenney/impact-sounds/footstep_concrete_000.ogg",
		"sound_attack": "res://assets/audio/kenney/impact-sounds/impactPlate_medium_000.ogg",
	},
	"ur-dragon": {
		"name": "Ur-Dragon", "color": Color(0.6, 0.5, 0.35),
		"hp": 12.0, "atk": 6.0, "def": 0.0, "xp": 11.0, "gold": 12.0,
		"mesh": "sphere", "squash": Vector3(1.2, 0.7, 0.8), "build": "ur-dragon", "model": "res://assets/models/bestiary/winged/ur-dragon.glb",
		"family": "The Abyssal & Cosmic", "band": "D", "archetype": "flyer/brute",
		"behavior": "Sweeping breath wash telegraphed by a deep inhale, tail sweeps around its coils, and a crushing bite on a",
		"sound_vocal": "PROCEDURAL: tearing shriek (sawtooth sweep 1.5→3 kHz).",
		"sound_steps": "none (flies — no footsteps).",
		"sound_attack": "PROCEDURAL: fire-breath roar (filtered noise burst, no file staged).",
	},
}

## Loaded model scenes, shared across all enemies of a type.
static var _model_cache: Dictionary = {}

var type_id: String = "slime"
var display_name: String = "Slime"
var grid_pos: Vector2i = Vector2i.ZERO
var max_hp: float = 10.0
var hp: float = 10.0
var atk: float = 1.0
var def: float = 0.0
var xp_reward: float = 1.0
var gold_reward: float = 1.0
var dead: bool = false
var attack_cooldown: float = 0.0
var wander_cooldown: float = 0.0
## Travel direction on the grid (unit Vector2i). Enemies face where they're
## going — never the camera (James). Used for backstab detection.
var facing := Vector2i(0, 1)
## Asleep monsters don't aggro, wander, or strike until woken (disturbed by
## proximity, damaged, or startled by a bashed door). The Stealth skill plays
## against the wake-up check.
var asleep: bool = false

var _body: MeshInstance3D
var _model_root: Node3D
var _anim: AnimationPlayer
## Wave 2 procedural idle motion: true for static wired models and for
## all placeholders (the upgraded procedural form); false when a real
## animation clip is playing. `_proc_profile` picks the motion shape.
var _proc_motion: bool = false
var _proc_profile: String = "breathe"
var _proc_time: float = 0.0
## Every tintable material on the visible body (primitive's single material,
## or per-instance duplicates of the FBX model's materials). Flash + sleep
## effects walk this list so the HP bar/label code never cares which path
## was used.
var _body_mats: Array[StandardMaterial3D] = []
var _awake_colors: Array[Color] = []
var _bar_pivot: Node3D
var _bar_fg: MeshInstance3D
var _flash_tween: Tween
var _sleep_label: Label3D

## Wave 2 integration — behavior + voice (NOT model building, stats,
## combat math, or scaling; those are untouched above and below).
## One BehaviorState per enemy, created in setup() from the ALREADY
## SCALED max_hp/atk and the flat def, so behaviors compose with the
## locked curves (hp x depth^1.2, atk x depth^1.05, def flat) without
## rescaling anything. update_behavior() is the per-tick entry point:
## main.gd (Wave 3 spawn+soak wiring) calls it with the player context
## — it is deliberately NOT auto-run from _process(), because manual
## mode is turn-based and the world freezes until the player acts, so
## a _process tick would advance venom/regen/charge timers in real
## time while the game is supposed to be frozen. The fields below are
## the outputs main.gd reads: move/attack intent, telegraph, grapple
## restrictions on the PLAYER, and this tick's venom/heal/grapple
## damage (venom and grapple damage are dealt to the player by the
## caller — this layer only reports them, it never touches the
## player's HP itself). Player dodge/block during telegraph windows:
## NO dedicated dodge/block action exists in the codebase (only the
## generic Agility dodge_chance at damage time), so none is invented
## here — Wave 3 gates a flat sidestep bonus on in_telegraph_window()
## in main.gd instead (a passive tell-reward, not a windowed action).
## Banshee layering
## (scream+breath simultaneously) is future work: idle plays breath,
## attack/death play scream, per voice_map.gd.
var behavior_state: Behaviors.BehaviorState = null
var behavior_intent: Dictionary = {}
var behavior_action: String = "idle"
var behavior_telegraph: String = ""
var last_telegraph: String = ""
var behavior_move_dir := Vector2.ZERO
var behavior_move_speed_mult: float = 1.0
var behavior_attack_kind: String = ""
var behavior_damage_mult: float = 1.0
var behavior_dazzle_miss_chance: float = 0.0
var behavior_altitude: float = 0.0
var behavior_flight_phase: String = "ground"
var behavior_charge_phase: String = "idle"
var behavior_grapple_phase: String = "none"
var behavior_venom_damage: float = 0.0
var behavior_healed: float = 0.0
var behavior_grapple_damage: float = 0.0
## Grapple restrictions on the PLAYER while this enemy holds them
## (Behaviors.grapple_player_restrictions). Enemy-side enforcement
## surface: main.gd must consult player_grappled / player_can_move /
## player_attack_mult in _try_step() and _player_attack() (Wave 3) —
## an enemy node cannot block player movement on its own.
var player_grappled: bool = false
var player_can_move: bool = true
var player_attack_mult: float = 1.0
var _idle_voice_timer: float = 0.0
var _prev_behavior_action: String = ""
## Wave 3 vocal dedupe: update_behavior() auto-plays an attack vocal on
## a fresh strike action AND main.gd's _enemy_strike() calls
## play_attack_vocal() (the retaliation path has no preceding tick).
## Both paths are wanted; a double within one beat is not. Any attack
## vocal within ATTACK_VOCAL_DEDUPE_MS of the last one is suppressed.
const ATTACK_VOCAL_DEDUPE_MS := 500
var _last_attack_vocal_msec := -1000000
var _behavior_want_charge: bool = false
var _behavior_wall_hit: bool = false
var _behavior_want_dive: bool = false
var _behavior_can_step_back: bool = true
var _telegraph_label: Label3D
var _hint_label: Label3D
const IDLE_VOICE_INTERVAL := 5.0
const TELEGRAPH_TEXT := {
	"pawing": "Pawing the ground…",
	"club_raised": "Club raised!",
	"inhale": "Inhaling…",
	"wail_windup": "Wailing…",
	"tail_raised": "Tail raised!",
	"reach_out": "Reaching out!",
	"dive_line": "Diving!",
	"shimmer": "Shimmering…",
	"crouch": "Crouching…",
	"charge_line": "Charging!",
}


func setup(p_type_id: String, hp_mult: float, atk_mult: float, p_grid_pos: Vector2i) -> void:
	type_id = p_type_id
	grid_pos = p_grid_pos
	var t: Dictionary = TYPES[type_id]
	display_name = str(t["name"])
	max_hp = float(t["hp"]) * hp_mult
	hp = max_hp
	atk = float(t["atk"]) * atk_mult
	# NOTE: defense never scales with depth. Scaling it turned the skeleton
	# into a 1-damage-per-hit wall at depth 3; it stays at its base value.
	def = float(t["def"])
	xp_reward = float(t["xp"]) * (0.5 + 0.5 * hp_mult)
	gold_reward = float(t["gold"]) * (0.5 + 0.5 * hp_mult)
	# Wave 2 integration: one BehaviorState per enemy, from the SCALED
	# stats above (never re-scaled). The archetype string is passed
	# verbatim from TYPES — Behaviors.profile_for() falls back to the
	# brawler profile for unknown strings instead of crashing (see the
	# integration report: space-form archetypes such as "pack
	# skirmisher" currently take that fallback; the behaviors module
	# owns that mapping, so it is reported, not patched here).
	behavior_state = Behaviors.new_state(str(t.get("archetype", "brawler")), max_hp, atk, def)
	behavior_state.position = Vector2(float(grid_pos.x), float(grid_pos.y))
	behavior_state.facing = Vector2(float(facing.x), float(facing.y))
	_refresh_behavior_hints()


func _ready() -> void:
	var t: Dictionary = TYPES[type_id]
	var color: Color = t["color"]

	# Body: animated FBX model when one is staged for this type, otherwise
	# the type's primitive composite placeholder (Wave 1), otherwise the
	# classic squashed primitive (also the fallback if anything above fails).
	if not _build_model(t):
		if not _build_placeholder(type_id, t, color):
			_build_primitive(t, color)

	# Procedural idle motion: animated models already move (their clip
	# plays); static wired models and all placeholders get a procedural
	# idle profile instead (see _process). Live animated types are
	# unaffected. Attack timing lives in behaviors.gd and death is
	# main.gd's squash-and-vanish tween — this layer does not fight them.
	var _animated := _anim != null and _anim.is_playing()
	if not _animated:
		_proc_motion = true
		var reg: Dictionary = MonsterModels.for_type(type_id)
		if str(reg.get("proc_profile", "")) != "":
			_proc_profile = str(reg["proc_profile"])
		else:
			_proc_profile = _proc_profile_for(str(t.get("archetype", "")))

	# HP bar: billboarded pivot with bg + fg quads (double-sided material).
	_bar_pivot = Node3D.new()
	_bar_pivot.position = Vector3(0, 1.55, 0)
	add_child(_bar_pivot)
	var bar_mat_bg := StandardMaterial3D.new()
	bar_mat_bg.albedo_color = Color(0.25, 0.05, 0.05)
	bar_mat_bg.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	bar_mat_bg.cull_mode = BaseMaterial3D.CULL_DISABLED
	var bar_mat_fg := StandardMaterial3D.new()
	bar_mat_fg.albedo_color = Color(0.3, 0.85, 0.3)
	bar_mat_fg.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	bar_mat_fg.cull_mode = BaseMaterial3D.CULL_DISABLED
	var bg := MeshInstance3D.new()
	var bg_quad := QuadMesh.new()
	bg_quad.size = Vector2(1.0, 0.14)
	bg.mesh = bg_quad
	bg.material_override = bar_mat_bg
	_bar_pivot.add_child(bg)
	_bar_fg = MeshInstance3D.new()
	var fg_quad := QuadMesh.new()
	fg_quad.size = Vector2(0.96, 0.1)
	_bar_fg.mesh = fg_quad
	_bar_fg.material_override = bar_mat_fg
	_bar_fg.position.z = 0.001
	_bar_pivot.add_child(_bar_fg)

	# Floating name label.
	var label := Label3D.new()
	label.text = display_name
	label.font_size = 48
	label.pixel_size = 0.004
	label.position = Vector3(0, 1.85, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(1, 1, 1, 0.9)
	add_child(label)

	if asleep:
		# Dozing look: darkened body + a floating "z z".
		_awake_colors.clear()
		for mat in _body_mats:
			_awake_colors.append(mat.albedo_color)
			mat.albedo_color = mat.albedo_color.darkened(0.45)
		_sleep_label = Label3D.new()
		_sleep_label.text = "z  z"
		_sleep_label.font_size = 40
		_sleep_label.pixel_size = 0.004
		_sleep_label.position = Vector3(0.35, 2.15, 0)
		_sleep_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_sleep_label.modulate = Color(0.65, 0.75, 1.0, 0.85)
		add_child(_sleep_label)

	_refresh_bar()
	_create_integration_labels()
	_refresh_behavior_hints()


## Wake up: restore the awake look. The AI state itself (aggro/wander) is
## driven by main.gd, which simply starts including this enemy again.
func wake_up() -> void:
	if not asleep:
		return
	asleep = false
	for i in _body_mats.size():
		if i < _awake_colors.size():
			_body_mats[i].albedo_color = _awake_colors[i]
	_awake_colors.clear()
	if is_instance_valid(_sleep_label):
		_sleep_label.queue_free()
	_sleep_label = null


func _process(delta: float) -> void:
	# Billboard the HP bar toward the camera.
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var target := cam.global_transform.origin
	if is_instance_valid(_bar_pivot):
		var bar_target := target
		bar_target.y = _bar_pivot.global_transform.origin.y
		if _bar_pivot.global_transform.origin.distance_squared_to(bar_target) > 0.001:
			_bar_pivot.look_at(bar_target, Vector3.UP)
	# Face travel direction (James: never the camera). _model_root's -Z is
	# the model's front (baked PI yaw), so yaw = atan2(-dx, -dz).
	if is_instance_valid(_model_root) and facing != Vector2i.ZERO:
		_model_root.rotation.y = atan2(-float(facing.x), -float(facing.y))
	# Procedural idle motion (Wave 2): static models + placeholders only.
	# Gentle bob/sway so an unanimated body never reads as frozen; the
	# facing yaw above is untouched (motion uses y position and z roll).
	if _proc_motion and is_instance_valid(_model_root):
		_proc_time += delta
		var tt := _proc_time
		match _proc_profile:
			"hover":
				_model_root.position.y = sin(tt * 2.4) * 0.08
				_model_root.rotation.z = sin(tt * 1.9) * 0.04
			"scurry":
				_model_root.position.y = absf(sin(tt * 9.0)) * 0.03
				_model_root.rotation.z = sin(tt * 9.0) * 0.02
			"skitter":
				_model_root.position.y = absf(sin(tt * 12.0)) * 0.02
				_model_root.rotation.z = sin(tt * 5.0) * 0.03
			"slither":
				_model_root.position.y = sin(tt * 6.0) * 0.02
				_model_root.rotation.z = sin(tt * 3.0) * 0.08
			"sway":
				_model_root.position.y = sin(tt * 1.2) * 0.03
				_model_root.rotation.z = sin(tt * 1.2) * 0.06
			_:
				_model_root.position.y = sin(tt * 1.6) * 0.02
				_model_root.scale = Vector3(1.0, 1.0 + sin(tt * 1.6) * 0.02, 1.0)


## Instantiate the staged model for this enemy type (FBX for the live
## three, GLB/FBX/OBJ for the Wave 2 wires via scripts/monster_models.gd).
## Returns false when no model is staged or the import failed, so the
## caller falls back to the primitive body. Never fakes a model.
## Wave 2 normalisation (monster_models.gd): junk nodes (ground/shadow
## planes, the rat's exploded Hair mesh) are deleted BEFORE measuring,
## the model is scaled so its norm_axis size equals the registry
## target (never raw import scale), its AABB minimum is grounded to
## the floor, and a y_offset hovers flyers. PS1 textures are re-linked
## onto the duplicated materials (the exports carry UVs but no texture
## links). Vertex-colour surfaces are forced to use their colours
## (the Gobkit community imports leave one surface per model flagged
## off, which would otherwise render white).
func _build_model(t: Dictionary) -> bool:
	var reg: Dictionary = MonsterModels.for_type(type_id)
	var path := str(reg.get("model", t.get("model", "")))
	if path.is_empty():
		return false
	var model: Node3D = null
	var ps := _model_cache.get(path) as PackedScene
	if ps == null:
		var res := load(path)
		if res is PackedScene:
			ps = res as PackedScene
			_model_cache[path] = ps
		elif res is Mesh:
			# OBJ files load as a Mesh, not a scene: wrap in a node.
			model = Node3D.new()
			var mi := MeshInstance3D.new()
			mi.mesh = res as Mesh
			model.add_child(mi)
		else:
			push_warning("Enemy: model failed to load, using primitive: " + path)
			return false
	if model == null:
		if ps == null:
			push_warning("Enemy: model failed to load, using primitive: " + path)
			return false
		model = ps.instantiate() as Node3D
		if model == null:
			push_warning("Enemy: model did not instantiate as Node3D: " + path)
			return false

	# Delete junk nodes BEFORE measuring (see monster_models.gd).
	for junk in reg.get("remove", []):
		var node := _find_node_named(model, str(junk))
		if node != null:
			var parent := node.get_parent()
			if parent != null:
				parent.remove_child(node)
			node.free()

	# Normalize: scale so the model's rest-pose norm_axis size matches
	# the registry target (or the legacy body_h for the live three),
	# and sit its base on the floor.
	var box := _measure_aabb(model)
	var axis := str(reg.get("norm_axis", "y"))
	var raw_size: float = box.size.y
	if axis == "x":
		raw_size = box.size.x
	elif axis == "z":
		raw_size = box.size.z
	if raw_size < 0.001:
		push_warning("Enemy: model has no measurable meshes: " + path)
		model.free()
		return false
	var target: float = float(reg.get("target", t.get("body_h", 1.0)))
	var s: float = target / raw_size
	_model_root = Node3D.new()
	_model_root.name = "ModelRoot"
	add_child(_model_root)
	# Quaternius models are authored facing +Z (the bat's separate "Eyes"
	# mesh sits forward at +Z); Godot forward is -Z, so bake a 180-degree
	# yaw on the model itself, so _model_root's -Z is the model's front.
	# _process yaws _model_root toward the enemy's travel direction.
	# NOTE (Wave 2): the same baked yaw is kept for GLB wires; per-model
	# facing still needs an editor eyeball pass (headless import cannot
	# prove which way a model faces).
	model.scale = Vector3(s, s, s)
	model.position.y = -box.position.y * s + float(reg.get("y_offset", 0.0))
	model.rotation.y = PI
	_model_root.add_child(model)

	# Per-instance material duplicates: the imported materials are shared
	# subresources, so tint/flash would otherwise hit every enemy of this
	# type at once.
	for mi in _find_meshes(_model_root):
		var mesh := mi.mesh
		if mesh == null:
			continue
		for si in mesh.get_surface_count():
			var src := mi.get_active_material(si)
			if src is StandardMaterial3D:
				var dup := (src as StandardMaterial3D).duplicate() as StandardMaterial3D
				# Honour vertex colours where the mesh carries them.
				var arrs := mesh.surface_get_arrays(si)
				if arrs.size() > Mesh.ARRAY_COLOR and arrs[Mesh.ARRAY_COLOR] != null:
					dup.vertex_color_use_as_albedo = true
				mi.set_surface_override_material(si, dup)
			else:
				push_warning("Enemy: non-StandardMaterial3D on %s surface %d — tint skipped" % [mi.name, si])
	for mi in _find_meshes(_model_root):
		var mesh2 := mi.mesh
		if mesh2 == null:
			continue
		for si in mesh2.get_surface_count():
			var m := mi.get_active_material(si)
			if m is StandardMaterial3D and not _body_mats.has(m):
				_body_mats.append(m)

	# PS1 texture re-link: one PNG per model, onto every surface.
	var tex_path := str(reg.get("texture", ""))
	if not tex_path.is_empty():
		var tex := load(tex_path)
		if tex is Texture2D:
			for m in _body_mats:
				m.albedo_texture = tex as Texture2D
		else:
			push_warning("Enemy: texture failed to load, model stays flat: " + tex_path)

	# Play the type's preferred animation (idle / flying loop).
	_anim = _find_anim_player(_model_root)
	if _anim != null:
		var want := str(reg.get("anim", t.get("anim", "Idle")))
		var names := _anim.get_animation_list()
		var chosen := ""
		for a in names:
			if a.containsn(want):
				chosen = a
				break
		if chosen.is_empty() and names.size() > 0:
			chosen = names[0]
		if not chosen.is_empty():
			_anim.play(chosen)
		else:
			push_warning("Enemy: model has no animations: " + path)
	return true


## Fallback body: simple primitive, squashed per type. Flat-shaded idle-game look.
func _build_primitive(t: Dictionary, color: Color) -> void:
	_body = MeshInstance3D.new()
	if str(t["mesh"]) == "sphere":
		var sphere := SphereMesh.new()
		sphere.radius = 0.55
		sphere.height = 1.1
		_body.mesh = sphere
	else:
		var box := BoxMesh.new()
		box.size = Vector3(0.9, 0.9, 0.9)
		_body.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	_body.material_override = mat
	var squash: Vector3 = t["squash"]
	_body.scale = squash
	_body.position.y = 0.55 * squash.y
	add_child(_body)
	_body_mats = [mat]


## Placeholder body: a composite of primitives with a distinct silhouette
## per type (Wave 1, monster roster paper). NOT final art — each build is a
## stopgap until a CC0 model is staged, at which point the "model" key in
## TYPES takes over and this never runs for that type. Parts face -Z, the
## same front convention as the FBX models, and the root is assigned to
## _model_root so _process yaws it toward the travel direction exactly
## like a model. All part materials register in _body_mats, so damage
## flash, sleep darkening, and wake-up restore work unchanged.
func _build_placeholder(p_type_id: String, t: Dictionary, color: Color) -> bool:
	if str(t.get("build", "")) != p_type_id:
		return false
	var root := Node3D.new()
	root.name = "PlaceholderBody"
	match p_type_id:
		"rat": _ph_rat(root, color)
		"spider": _ph_spider(root, color)
		"snake": _ph_snake(root, color)
		"wasp": _ph_wasp(root, color)
		"frog": _ph_frog(root, color)
		"wolf": _ph_wolf(root, color)
		"goblin": _ph_goblin(root, color)
		"zombie": _ph_zombie(root, color)
		"ghost": _ph_ghost(root, color)
		"golem": _ph_golem(root, color)
		"boar": _ph_boar(root, color)
		"scorpion": _ph_scorpion(root, color)
		"centipede": _ph_centipede(root, color)
		"skeleton_archer": _ph_skeleton_archer(root, color)
		"kobold": _ph_kobold(root, color)
		"imp": _ph_imp(root, color)
		"pixie": _ph_pixie(root, color)
		"orc": _ph_orc(root, color)
		"troll": _ph_troll(root, color)
		"minotaur": _ph_minotaur(root, color)
		"harpy": _ph_harpy(root, color)
		"oni": _ph_oni(root, color)
		"kappa": _ph_kappa(root, color)
		"drake": _ph_drake(root, color)
		"banshee": _ph_banshee(root, color)
		_:
			root.free()
			return false
	add_child(root)
	_model_root = root
	return true


## One placeholder material, registered for flash/sleep tinting.
func _ph_mat(c: Color, alpha: float = 1.0, glow: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(c.r, c.g, c.b, alpha)
	m.roughness = 0.95
	if alpha < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glow > 0.0:
		m.emission_enabled = true
		m.emission = Color(c.r, c.g, c.b)
		m.emission_energy_multiplier = glow
	_body_mats.append(m)
	return m


func _ph_part(root: Node3D, mesh: Mesh, mat: Material, pos: Vector3,
		scl: Vector3 = Vector3.ONE, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.scale = scl
	mi.rotation = rot
	root.add_child(mi)
	return mi


func _ph_box(s: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = s
	return b


func _ph_sphere(r: float) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 12
	s.rings = 8
	return s


func _ph_cyl(r_top: float, r_bottom: float, h: float) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = r_top
	c.bottom_radius = r_bottom
	c.height = h
	c.radial_segments = 10
	return c


func _ph_rat(root: Node3D, color: Color) -> void:
	var body := _ph_mat(color)
	var dark := _ph_mat(color.darkened(0.35))
	var tail_mat := _ph_mat(Color(0.72, 0.55, 0.5))
	# Low, long body + head + cone snout.
	_ph_part(root, _ph_sphere(0.26), body, Vector3(0, 0.27, 0.02), Vector3(0.85, 0.68, 1.35))
	_ph_part(root, _ph_sphere(0.17), body, Vector3(0, 0.29, -0.33), Vector3(0.9, 0.85, 1.1))
	_ph_part(root, _ph_cyl(0.01, 0.085, 0.17), dark, Vector3(0, 0.26, -0.5), Vector3.ONE, Vector3(-PI / 2.0, 0, 0))
	# Ears.
	_ph_part(root, _ph_sphere(0.062), dark, Vector3(0.1, 0.43, -0.3), Vector3(1, 1, 0.45))
	_ph_part(root, _ph_sphere(0.062), dark, Vector3(-0.1, 0.43, -0.3), Vector3(1, 1, 0.45))
	# Tail trailing behind (+Z), angled up.
	_ph_part(root, _ph_cyl(0.012, 0.026, 0.55), tail_mat, Vector3(0, 0.2, 0.48), Vector3.ONE, Vector3(1.15, 0, 0))
	# Stubby legs.
	for sx in [0.13, -0.13]:
		for zz in [0.18, -0.16]:
			_ph_part(root, _ph_cyl(0.03, 0.03, 0.15), dark, Vector3(sx, 0.07, zz))


func _ph_spider(root: Node3D, color: Color) -> void:
	var body := _ph_mat(color)
	var dark := _ph_mat(Color(0.08, 0.06, 0.1))
	# Bulbous abdomen behind, thorax in front, eyes on the front face.
	_ph_part(root, _ph_sphere(0.3), body, Vector3(0, 0.42, 0.15), Vector3(1, 0.85, 1.15))
	_ph_part(root, _ph_sphere(0.2), body, Vector3(0, 0.38, -0.24))
	_ph_part(root, _ph_sphere(0.035), dark, Vector3(0.07, 0.45, -0.41))
	_ph_part(root, _ph_sphere(0.035), dark, Vector3(-0.07, 0.45, -0.41))
	# Eight legs: cylinders fanning out and down to the floor.
	for side in [1.0, -1.0]:
		for i in 4:
			var z := -0.27 + 0.18 * float(i)
			_ph_part(root, _ph_cyl(0.02, 0.028, 0.62), body,
					Vector3(0.36 * side, 0.26, z), Vector3.ONE,
					Vector3(0, -z * 0.7, side * 1.02))


func _ph_snake(root: Node3D, color: Color) -> void:
	var body := _ph_mat(color)
	var belly := _ph_mat(color.lightened(0.2))
	var dark := _ph_mat(Color(0.05, 0.08, 0.04))
	var tongue := _ph_mat(Color(0.8, 0.15, 0.2))
	# Coiled S of shrinking spheres trailing to +Z.
	var segs := [
		[0.0, 0.14, -0.12, 0.185], [0.09, 0.13, 0.06, 0.175],
		[-0.08, 0.12, 0.23, 0.155], [0.05, 0.11, 0.39, 0.13],
		[-0.02, 0.09, 0.53, 0.1], [0.0, 0.08, 0.64, 0.07],
	]
	for s in segs:
		_ph_part(root, _ph_sphere(s[3]), body, Vector3(s[0], s[1], s[2]))
	# Raised neck + flattened head at the front.
	_ph_part(root, _ph_sphere(0.17), belly, Vector3(0, 0.25, -0.3))
	_ph_part(root, _ph_sphere(0.18), body, Vector3(0, 0.36, -0.48), Vector3(0.95, 0.68, 1.25))
	_ph_part(root, _ph_sphere(0.032), dark, Vector3(0.08, 0.42, -0.6))
	_ph_part(root, _ph_sphere(0.032), dark, Vector3(-0.08, 0.42, -0.6))
	_ph_part(root, _ph_box(Vector3(0.025, 0.012, 0.13)), tongue, Vector3(0, 0.31, -0.72))


func _ph_wasp(root: Node3D, color: Color) -> void:
	var body := _ph_mat(color)
	var dark := _ph_mat(Color(0.12, 0.1, 0.08))
	var wing := _ph_mat(Color(0.9, 0.95, 1.0), 0.35)
	# Hovering body: thorax front, striped abdomen behind, stinger last.
	_ph_part(root, _ph_sphere(0.17), body, Vector3(0, 0.85, 0.0))
	_ph_part(root, _ph_sphere(0.12), dark, Vector3(0, 0.88, -0.21))
	_ph_part(root, _ph_sphere(0.21), body, Vector3(0, 0.82, 0.3), Vector3(0.9, 0.9, 1.3))
	_ph_part(root, _ph_cyl(0.2, 0.2, 0.05), dark, Vector3(0, 0.82, 0.22), Vector3.ONE, Vector3(PI / 2.0, 0, 0))
	_ph_part(root, _ph_cyl(0.17, 0.17, 0.05), dark, Vector3(0, 0.82, 0.4), Vector3.ONE, Vector3(PI / 2.0, 0, 0))
	_ph_part(root, _ph_cyl(0.0, 0.05, 0.16), dark, Vector3(0, 0.8, 0.58), Vector3.ONE, Vector3(PI / 2.0, 0, 0))
	# Translucent wings angled up off the thorax.
	_ph_part(root, _ph_box(Vector3(0.36, 0.015, 0.17)), wing, Vector3(0.18, 1.03, 0.02), Vector3.ONE, Vector3(0, 0.3, -0.5))
	_ph_part(root, _ph_box(Vector3(0.36, 0.015, 0.17)), wing, Vector3(-0.18, 1.03, 0.02), Vector3.ONE, Vector3(0, -0.3, 0.5))


func _ph_frog(root: Node3D, color: Color) -> void:
	var body := _ph_mat(color)
	var dark := _ph_mat(Color(0.06, 0.08, 0.05))
	# Wide squashed body, eye bumps on top, folded haunches at the sides.
	_ph_part(root, _ph_sphere(0.3), body, Vector3(0, 0.23, 0.02), Vector3(1.25, 0.62, 1.05))
	_ph_part(root, _ph_sphere(0.075), body, Vector3(0.14, 0.43, -0.15))
	_ph_part(root, _ph_sphere(0.075), body, Vector3(-0.14, 0.43, -0.15))
	_ph_part(root, _ph_sphere(0.04), dark, Vector3(0.14, 0.46, -0.21))
	_ph_part(root, _ph_sphere(0.04), dark, Vector3(-0.14, 0.46, -0.21))
	_ph_part(root, _ph_sphere(0.16), body, Vector3(0.31, 0.14, 0.13), Vector3(0.6, 0.5, 1.3))
	_ph_part(root, _ph_sphere(0.16), body, Vector3(-0.31, 0.14, 0.13), Vector3(0.6, 0.5, 1.3))
	_ph_part(root, _ph_cyl(0.03, 0.035, 0.16), body, Vector3(0.18, 0.08, -0.22))
	_ph_part(root, _ph_cyl(0.03, 0.035, 0.16), body, Vector3(-0.18, 0.08, -0.22))


func _ph_wolf(root: Node3D, color: Color) -> void:
	var body := _ph_mat(color)
	var dark := _ph_mat(color.darkened(0.3))
	var black := _ph_mat(Color(0.05, 0.05, 0.06))
	# Quadruped: blocky torso, head + snout at the front, tail up at back.
	_ph_part(root, _ph_box(Vector3(0.44, 0.48, 0.9)), body, Vector3(0, 0.62, 0.02))
	_ph_part(root, _ph_box(Vector3(0.3, 0.3, 0.34)), body, Vector3(0, 0.84, -0.56))
	_ph_part(root, _ph_box(Vector3(0.16, 0.16, 0.27)), dark, Vector3(0, 0.77, -0.83))
	_ph_part(root, _ph_box(Vector3(0.09, 0.07, 0.05)), black, Vector3(0, 0.79, -0.97))
	# Pointed ears.
	_ph_part(root, _ph_cyl(0.0, 0.07, 0.17), body, Vector3(0.1, 1.05, -0.52))
	_ph_part(root, _ph_cyl(0.0, 0.07, 0.17), body, Vector3(-0.1, 1.05, -0.52))
	# Legs + raised tail.
	for sx in [0.15, -0.15]:
		for zz in [0.3, -0.3]:
			_ph_part(root, _ph_cyl(0.05, 0.045, 0.5), dark, Vector3(sx, 0.25, zz))
	_ph_part(root, _ph_cyl(0.02, 0.05, 0.46), body, Vector3(0, 0.74, 0.55), Vector3.ONE, Vector3(0.7, 0, 0))


func _ph_goblin(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var rags := _ph_mat(Color(0.4, 0.3, 0.18))
	var dark := _ph_mat(Color(0.06, 0.08, 0.04))
	# Small humanoid: rag torso, big head, long ears out to the sides.
	for sx in [0.09, -0.09]:
		_ph_part(root, _ph_cyl(0.045, 0.05, 0.3), skin, Vector3(sx, 0.15, 0))
	_ph_part(root, _ph_box(Vector3(0.36, 0.34, 0.22)), rags, Vector3(0, 0.47, 0))
	for sx in [0.24, -0.24]:
		_ph_part(root, _ph_cyl(0.038, 0.042, 0.37), skin, Vector3(sx, 0.47, 0), Vector3.ONE, Vector3(0, 0, sx * 1.0))
	_ph_part(root, _ph_sphere(0.16), skin, Vector3(0, 0.83, 0))
	for sx in [0.25, -0.25]:
		_ph_part(root, _ph_box(Vector3(0.23, 0.05, 0.09)), skin, Vector3(sx, 0.87, 0), Vector3.ONE, Vector3(0, 0, sx * 1.4))
	_ph_part(root, _ph_cyl(0.01, 0.045, 0.13), skin, Vector3(0, 0.8, -0.17), Vector3.ONE, Vector3(-PI / 2.0, 0, 0))
	_ph_part(root, _ph_sphere(0.026), dark, Vector3(0.06, 0.86, -0.14))
	_ph_part(root, _ph_sphere(0.026), dark, Vector3(-0.06, 0.86, -0.14))


func _ph_zombie(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var cloth := _ph_mat(Color(0.3, 0.28, 0.34))
	# Hunched humanoid, arms reaching forward, head lolled.
	for sx in [0.1, -0.1]:
		_ph_part(root, _ph_box(Vector3(0.13, 0.45, 0.15)), cloth, Vector3(sx, 0.225, 0))
	_ph_part(root, _ph_box(Vector3(0.46, 0.55, 0.26)), cloth, Vector3(0, 0.74, 0.0), Vector3.ONE, Vector3(-0.16, 0, 0))
	_ph_part(root, _ph_sphere(0.17), skin, Vector3(0, 1.14, -0.09), Vector3(0.9, 1.0, 0.9), Vector3(-0.25, 0, 0.12))
	for sx in [0.29, -0.29]:
		_ph_part(root, _ph_cyl(0.045, 0.05, 0.52), skin, Vector3(sx, 0.8, -0.22), Vector3.ONE, Vector3(-1.25, 0, 0))


func _ph_ghost(root: Node3D, color: Color) -> void:
	var shroud := _ph_mat(color, 0.55, 0.3)
	var face := _ph_mat(Color(0.1, 0.14, 0.2), 0.85)
	var eyes := _ph_mat(Color(0.65, 0.95, 1.0), 1.0, 1.6)
	# Floating shroud: tapered cylinder, hooded head, hollow face, lit eyes.
	_ph_part(root, _ph_cyl(0.15, 0.45, 0.95), shroud, Vector3(0, 0.78, 0))
	_ph_part(root, _ph_sphere(0.24), shroud, Vector3(0, 1.32, 0), Vector3(1, 1.12, 1))
	_ph_part(root, _ph_sphere(0.155), face, Vector3(0, 1.29, -0.09))
	_ph_part(root, _ph_sphere(0.03), eyes, Vector3(0.06, 1.33, -0.22))
	_ph_part(root, _ph_sphere(0.03), eyes, Vector3(-0.06, 1.33, -0.22))
	# Wispy arms hanging at the sides.
	for sx in [0.31, -0.31]:
		_ph_part(root, _ph_cyl(0.03, 0.075, 0.5), shroud, Vector3(sx, 0.88, -0.04), Vector3.ONE, Vector3(0, 0, sx * 0.9))


func _ph_golem(root: Node3D, color: Color) -> void:
	var stone := _ph_mat(color)
	var dark := _ph_mat(color.darkened(0.28))
	var eyes := _ph_mat(Color(1.0, 0.62, 0.2), 1.0, 1.4)
	# Stacked slabs: thick legs, broad torso, low head, glowing eye slit.
	for sx in [0.16, -0.16]:
		_ph_part(root, _ph_box(Vector3(0.25, 0.4, 0.29)), dark, Vector3(sx, 0.2, 0))
	_ph_part(root, _ph_box(Vector3(0.62, 0.2, 0.4)), stone, Vector3(0, 0.5, 0))
	_ph_part(root, _ph_box(Vector3(0.78, 0.55, 0.48)), stone, Vector3(0, 0.88, 0))
	_ph_part(root, _ph_box(Vector3(0.5, 0.4, 0.07)), dark, Vector3(0, 0.88, -0.26))
	for sx in [0.53, -0.53]:
		_ph_part(root, _ph_box(Vector3(0.3, 0.22, 0.35)), stone, Vector3(sx, 1.1, 0))
		_ph_part(root, _ph_box(Vector3(0.22, 0.6, 0.26)), stone, Vector3(sx + 0.02, 0.7, 0))
		_ph_part(root, _ph_box(Vector3(0.27, 0.2, 0.31)), dark, Vector3(sx + 0.02, 0.32, 0))
	_ph_part(root, _ph_box(Vector3(0.3, 0.26, 0.3)), stone, Vector3(0, 1.3, 0))
	_ph_part(root, _ph_box(Vector3(0.19, 0.045, 0.03)), eyes, Vector3(0, 1.32, -0.16))


## Wave 2 placeholder bodies (same contract as Wave 1: distinct primitive
## silhouettes, parts facing -Z, materials registered for flash/sleep).
func _ph_boar(root: Node3D, color: Color) -> void:
	var body := _ph_mat(color)
	var dark := _ph_mat(color.darkened(0.3))
	var tusk := _ph_mat(Color(0.95, 0.93, 0.85))
	# Low, wide quadruped; bristled back, snout down, tusks forward.
	_ph_part(root, _ph_box(Vector3(0.56, 0.5, 0.82)), body, Vector3(0, 0.55, 0.02))
	_ph_part(root, _ph_box(Vector3(0.36, 0.3, 0.3)), body, Vector3(0, 0.52, -0.52))
	_ph_part(root, _ph_box(Vector3(0.2, 0.16, 0.18)), dark, Vector3(0, 0.44, -0.72))
	for sx in [0.16, -0.16]:
		_ph_part(root, _ph_cyl(0.0, 0.05, 0.16), tusk, Vector3(sx, 0.42, -0.8), Vector3.ONE, Vector3(-1.9, 0, sx * 1.2))
		for zz in [0.3, -0.28]:
			_ph_part(root, _ph_cyl(0.055, 0.05, 0.32), dark, Vector3(sx, 0.16, zz))
	for i in 4:
		_ph_part(root, _ph_box(Vector3(0.05, 0.14, 0.05)), dark, Vector3(-0.15 + 0.1 * float(i), 0.86, 0.1))


func _ph_scorpion(root: Node3D, color: Color) -> void:
	var body := _ph_mat(color)
	var dark := _ph_mat(color.darkened(0.3))
	var sting := _ph_mat(Color(0.1, 0.08, 0.06))
	# Flat body, claws forward, tail arcing up over the back.
	_ph_part(root, _ph_sphere(0.26), body, Vector3(0, 0.2, 0.02), Vector3(1.15, 0.5, 1.35))
	for side in [1.0, -1.0]:
		_ph_part(root, _ph_sphere(0.14), dark, Vector3(0.42 * side, 0.2, -0.38))
		_ph_part(root, _ph_box(Vector3(0.1, 0.06, 0.2)), dark, Vector3(0.42 * side, 0.2, -0.55))
		for i in 3:
			_ph_part(root, _ph_cyl(0.015, 0.02, 0.34), body,
					Vector3(0.3 * side, 0.12, -0.05 + 0.16 * float(i)), Vector3.ONE,
					Vector3(0, 0, side * 1.1))
	# Tail: rising chain of shrinking spheres to a stinger cone.
	var tz := 0.3
	var ty := 0.22
	for r in [0.11, 0.095, 0.08, 0.065]:
		_ph_part(root, _ph_sphere(r), body, Vector3(0, ty, tz))
		tz += 0.1
		ty += 0.13
	_ph_part(root, _ph_cyl(0.0, 0.05, 0.18), sting, Vector3(0, 0.78, 0.62), Vector3.ONE, Vector3(0.9, 0, 0))


func _ph_centipede(root: Node3D, color: Color) -> void:
	var body := _ph_mat(color)
	var dark := _ph_mat(color.darkened(0.25))
	var leg := _ph_mat(Color(0.2, 0.12, 0.06))
	# Long, low chain of segments; head raised slightly at the front.
	for i in 9:
		var z := -0.72 + 0.18 * float(i)
		var r := 0.15 if i < 8 else 0.17
		_ph_part(root, _ph_sphere(r), body, Vector3(0, 0.16, z), Vector3(1.0, 0.75, 1.0))
		if i < 8:
			for side in [1.0, -1.0]:
				_ph_part(root, _ph_cyl(0.012, 0.015, 0.2), leg,
						Vector3(0.16 * side, 0.1, z), Vector3.ONE, Vector3(0, 0, side * 1.2))
	_ph_part(root, _ph_sphere(0.05), dark, Vector3(0.06, 0.22, -0.92))
	_ph_part(root, _ph_sphere(0.05), dark, Vector3(-0.06, 0.22, -0.92))
	for side in [1.0, -1.0]:
		_ph_part(root, _ph_cyl(0.008, 0.012, 0.22), leg,
				Vector3(0.07 * side, 0.24, -0.98), Vector3.ONE, Vector3(-0.9, 0, side * 0.5))


func _ph_skeleton_archer(root: Node3D, color: Color) -> void:
	var bone := _ph_mat(color)
	var dark := _ph_mat(Color(0.25, 0.22, 0.18))
	var bow := _ph_mat(Color(0.4, 0.28, 0.14))
	# Thin humanoid (taller and narrower than the zombie) + bow held forward.
	for sx in [0.1, -0.1]:
		_ph_part(root, _ph_box(Vector3(0.11, 0.5, 0.13)), bone, Vector3(sx, 0.25, 0))
	_ph_part(root, _ph_box(Vector3(0.4, 0.5, 0.24)), bone, Vector3(0, 0.78, 0))
	_ph_part(root, _ph_sphere(0.15), bone, Vector3(0, 1.2, 0))
	_ph_part(root, _ph_sphere(0.025), dark, Vector3(0.055, 1.22, -0.13))
	_ph_part(root, _ph_sphere(0.025), dark, Vector3(-0.055, 1.22, -0.13))
	for sx in [0.27, -0.27]:
		_ph_part(root, _ph_cyl(0.035, 0.04, 0.5), bone, Vector3(sx, 0.78, -0.05), Vector3.ONE, Vector3(-0.5, 0, 0))
	# Bow: vertical limbs + string, held out front-left; quiver on the back.
	_ph_part(root, _ph_box(Vector3(0.04, 0.7, 0.04)), bow, Vector3(-0.3, 0.85, -0.45))
	_ph_part(root, _ph_box(Vector3(0.015, 0.66, 0.015)), dark, Vector3(-0.3, 0.85, -0.39))
	_ph_part(root, _ph_box(Vector3(0.015, 0.015, 0.3)), bone, Vector3(-0.3, 0.85, -0.45), Vector3.ONE, Vector3(0, 0, 0))
	_ph_part(root, _ph_cyl(0.06, 0.06, 0.5), bow, Vector3(0.14, 0.95, 0.2), Vector3.ONE, Vector3(0.25, 0, 0))


func _ph_kobold(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var rags := _ph_mat(Color(0.35, 0.28, 0.2))
	var wood := _ph_mat(Color(0.45, 0.32, 0.18))
	# Small humanoid with a tall spear (the silhouette tell vs the goblin).
	for sx in [0.08, -0.08]:
		_ph_part(root, _ph_cyl(0.04, 0.045, 0.3), skin, Vector3(sx, 0.15, 0))
	_ph_part(root, _ph_box(Vector3(0.3, 0.32, 0.2)), rags, Vector3(0, 0.46, 0))
	for sx in [0.2, -0.2]:
		_ph_part(root, _ph_cyl(0.032, 0.036, 0.34), skin, Vector3(sx, 0.46, 0), Vector3.ONE, Vector3(0, 0, sx * 1.0))
	_ph_part(root, _ph_sphere(0.14), skin, Vector3(0, 0.78, 0))
	for sx in [0.09, -0.09]:
		_ph_part(root, _ph_cyl(0.0, 0.05, 0.15), skin, Vector3(sx, 0.92, 0), Vector3.ONE, Vector3(0, 0, sx * 2.2))
	_ph_part(root, _ph_cyl(0.018, 0.018, 1.25), wood, Vector3(0.3, 0.68, -0.05))
	_ph_part(root, _ph_cyl(0.0, 0.04, 0.14), skin, Vector3(0.3, 1.36, -0.05))
	_ph_part(root, _ph_cyl(0.012, 0.022, 0.4), skin, Vector3(0, 0.16, 0.3), Vector3.ONE, Vector3(1.2, 0, 0))


func _ph_imp(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var wing := _ph_mat(Color(0.3, 0.12, 0.15))
	var dark := _ph_mat(Color(0.1, 0.06, 0.06))
	# Small hovering demon: body at ~1.05, bat wings, horns, barbed tail.
	_ph_part(root, _ph_sphere(0.17), skin, Vector3(0, 1.05, 0))
	_ph_part(root, _ph_sphere(0.13), skin, Vector3(0, 1.28, 0))
	for sx in [0.08, -0.08]:
		_ph_part(root, _ph_cyl(0.0, 0.045, 0.14), skin, Vector3(sx, 1.42, 0), Vector3.ONE, Vector3(0, 0, sx * 1.5))
	_ph_part(root, _ph_box(Vector3(0.4, 0.015, 0.24)), wing, Vector3(0.28, 1.22, 0.05), Vector3.ONE, Vector3(0, -0.3, -0.55))
	_ph_part(root, _ph_box(Vector3(0.4, 0.015, 0.24)), wing, Vector3(-0.28, 1.22, 0.05), Vector3.ONE, Vector3(0, 0.3, 0.55))
	for sx in [0.1, -0.1]:
		_ph_part(root, _ph_cyl(0.03, 0.035, 0.22), skin, Vector3(sx, 0.82, 0.02), Vector3.ONE, Vector3(0.4, 0, 0))
	_ph_part(root, _ph_cyl(0.012, 0.02, 0.4), skin, Vector3(0, 0.95, 0.28), Vector3.ONE, Vector3(1.1, 0, 0))
	_ph_part(root, _ph_cyl(0.0, 0.045, 0.09), dark, Vector3(0, 0.82, 0.48), Vector3.ONE, Vector3(PI / 2.0, 0, 0))


func _ph_pixie(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var wing := _ph_mat(Color(0.95, 0.85, 1.0), 0.4, 0.5)
	var glow := _ph_mat(Color(1.0, 0.9, 0.4), 1.0, 1.2)
	# Tiny hovering fey: the smallest silhouette in the staged set.
	_ph_part(root, _ph_sphere(0.09), skin, Vector3(0, 1.35, 0))
	_ph_part(root, _ph_sphere(0.07), skin, Vector3(0, 1.47, 0))
	_ph_part(root, _ph_sphere(0.02), glow, Vector3(0, 1.35, -0.09))
	_ph_part(root, _ph_box(Vector3(0.22, 0.012, 0.14)), wing, Vector3(0.13, 1.44, 0.03), Vector3.ONE, Vector3(0, 0.3, -0.5))
	_ph_part(root, _ph_box(Vector3(0.22, 0.012, 0.14)), wing, Vector3(-0.13, 1.44, 0.03), Vector3.ONE, Vector3(0, -0.3, 0.5))


func _ph_orc(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var dark := _ph_mat(color.darkened(0.3))
	var cloth := _ph_mat(Color(0.3, 0.25, 0.2))
	# Bulky humanoid, broader than the goblin, jaw forward.
	for sx in [0.13, -0.13]:
		_ph_part(root, _ph_box(Vector3(0.17, 0.5, 0.19)), dark, Vector3(sx, 0.25, 0))
	_ph_part(root, _ph_box(Vector3(0.58, 0.6, 0.34)), skin, Vector3(0, 0.82, 0))
	_ph_part(root, _ph_box(Vector3(0.3, 0.16, 0.3)), cloth, Vector3(0, 0.52, 0))
	for sx in [0.36, -0.36]:
		_ph_part(root, _ph_box(Vector3(0.2, 0.18, 0.24)), skin, Vector3(sx, 1.1, 0))
		_ph_part(root, _ph_cyl(0.05, 0.055, 0.5), skin, Vector3(sx, 0.78, -0.02), Vector3.ONE, Vector3(0, 0, sx * 0.6))
	_ph_part(root, _ph_sphere(0.19), skin, Vector3(0, 1.3, 0))
	_ph_part(root, _ph_box(Vector3(0.2, 0.09, 0.12)), dark, Vector3(0, 1.22, -0.18))
	for sx in [0.05, -0.05]:
		_ph_part(root, _ph_cyl(0.0, 0.035, 0.12), skin, Vector3(sx, 1.44, 0), Vector3.ONE, Vector3(0, 0, sx * 2.0))


func _ph_troll(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var dark := _ph_mat(color.darkened(0.3))
	# Hunched giant: long arms to the knees, head sunk low between shoulders.
	for sx in [0.2, -0.2]:
		_ph_part(root, _ph_box(Vector3(0.3, 0.55, 0.34)), dark, Vector3(sx, 0.27, 0))
	_ph_part(root, _ph_box(Vector3(0.86, 0.7, 0.52)), skin, Vector3(0, 0.95, 0), Vector3.ONE, Vector3(0.15, 0, 0))
	for sx in [0.55, -0.55]:
		_ph_part(root, _ph_cyl(0.09, 0.1, 0.85), skin, Vector3(sx, 0.62, -0.05), Vector3.ONE, Vector3(0, 0, sx * 0.35))
		_ph_part(root, _ph_sphere(0.14), skin, Vector3(sx, 0.16, -0.05))
	_ph_part(root, _ph_sphere(0.22), skin, Vector3(0, 1.5, -0.1))
	_ph_part(root, _ph_box(Vector3(0.24, 0.1, 0.14)), dark, Vector3(0, 1.42, -0.3))


func _ph_minotaur(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var dark := _ph_mat(color.darkened(0.25))
	var horn := _ph_mat(Color(0.9, 0.86, 0.75))
	# Tall bull-headed brute: horns are the width tell vs the troll and oni.
	for sx in [0.16, -0.16]:
		_ph_part(root, _ph_box(Vector3(0.2, 0.6, 0.22)), dark, Vector3(sx, 0.3, 0))
	_ph_part(root, _ph_box(Vector3(0.64, 0.65, 0.4)), skin, Vector3(0, 0.95, 0))
	for sx in [0.4, -0.4]:
		_ph_part(root, _ph_cyl(0.06, 0.065, 0.55), skin, Vector3(sx, 0.9, 0), Vector3.ONE, Vector3(0, 0, sx * 0.7))
	_ph_part(root, _ph_box(Vector3(0.4, 0.36, 0.34)), skin, Vector3(0, 1.42, 0))
	_ph_part(root, _ph_box(Vector3(0.24, 0.16, 0.2)), dark, Vector3(0, 1.32, -0.22))
	for sx in [0.32, -0.32]:
		_ph_part(root, _ph_cyl(0.0, 0.055, 0.42), horn, Vector3(sx, 1.54, 0), Vector3.ONE, Vector3(0, 0, sx * 1.9))
	_ph_part(root, _ph_sphere(0.035), dark, Vector3(0.1, 1.46, -0.18))
	_ph_part(root, _ph_sphere(0.035), dark, Vector3(-0.1, 1.46, -0.18))


func _ph_harpy(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var feather := _ph_mat(Color(0.45, 0.38, 0.26))
	var talon := _ph_mat(Color(0.85, 0.8, 0.6))
	# Circling bird-woman: wide wings, humanoid torso, talons below.
	_ph_part(root, _ph_sphere(0.16), skin, Vector3(0, 1.3, 0))
	_ph_part(root, _ph_box(Vector3(0.3, 0.34, 0.2)), skin, Vector3(0, 1.05, 0))
	_ph_part(root, _ph_box(Vector3(0.62, 0.015, 0.4)), feather, Vector3(0.55, 1.28, 0.05), Vector3.ONE, Vector3(0, -0.25, -0.5))
	_ph_part(root, _ph_box(Vector3(0.62, 0.015, 0.4)), feather, Vector3(-0.55, 1.28, 0.05), Vector3.ONE, Vector3(0, 0.25, 0.5))
	for sx in [0.1, -0.1]:
		_ph_part(root, _ph_cyl(0.035, 0.04, 0.28), skin, Vector3(sx, 0.78, 0), Vector3.ONE, Vector3(0.3, 0, 0))
		_ph_part(root, _ph_cyl(0.0, 0.04, 0.12), talon, Vector3(sx, 0.64, -0.06), Vector3.ONE, Vector3(-1.2, 0, 0))
	_ph_part(root, _ph_box(Vector3(0.06, 0.02, 0.3)), feather, Vector3(0, 1.02, 0.28))


func _ph_oni(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var dark := _ph_mat(color.darkened(0.3))
	var club := _ph_mat(Color(0.25, 0.2, 0.16))
	# Tallest staged silhouette: massive torso, horns, iron club held high.
	for sx in [0.17, -0.17]:
		_ph_part(root, _ph_box(Vector3(0.22, 0.62, 0.24)), dark, Vector3(sx, 0.31, 0))
	_ph_part(root, _ph_box(Vector3(0.7, 0.75, 0.44)), skin, Vector3(0, 1.05, 0))
	_ph_part(root, _ph_sphere(0.23), skin, Vector3(0, 1.52, 0))
	for sx in [0.16, -0.16]:
		_ph_part(root, _ph_cyl(0.0, 0.06, 0.22), skin, Vector3(sx, 1.66, 0), Vector3.ONE, Vector3(0, 0, sx * 1.8))
	_ph_part(root, _ph_cyl(0.06, 0.07, 0.6), skin, Vector3(0.45, 1.05, -0.05), Vector3.ONE, Vector3(0, 0, 0.5))
	_ph_part(root, _ph_cyl(0.09, 0.11, 0.7), club, Vector3(0.52, 1.42, -0.05), Vector3.ONE, Vector3(0, 0, 0.5))
	for sx in [0.05, -0.05]:
		_ph_part(root, _ph_sphere(0.04), dark, Vector3(sx, 1.56, -0.21))


func _ph_kappa(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var shell := _ph_mat(Color(0.25, 0.4, 0.2))
	var dish := _ph_mat(Color(0.35, 0.55, 0.6))
	# Squat turtle-folk: shell disc on the back, water dish on the head.
	for sx in [0.11, -0.11]:
		_ph_part(root, _ph_cyl(0.05, 0.05, 0.34), skin, Vector3(sx, 0.17, 0))
	_ph_part(root, _ph_box(Vector3(0.4, 0.44, 0.26)), skin, Vector3(0, 0.56, 0))
	_ph_part(root, _ph_sphere(0.3), shell, Vector3(0, 0.6, 0.28), Vector3(1.0, 1.1, 0.4))
	for sx in [0.24, -0.24]:
		_ph_part(root, _ph_cyl(0.04, 0.045, 0.4), skin, Vector3(sx, 0.56, 0), Vector3.ONE, Vector3(0, 0, sx * 0.8))
	_ph_part(root, _ph_sphere(0.17), skin, Vector3(0, 0.94, 0))
	_ph_part(root, _ph_cyl(0.13, 0.13, 0.04), dish, Vector3(0, 1.1, 0))
	_ph_part(root, _ph_cyl(0.0, 0.05, 0.12), skin, Vector3(0, 0.9, -0.19), Vector3.ONE, Vector3(-PI / 2.0, 0, 0))


func _ph_drake(root: Node3D, color: Color) -> void:
	var skin := _ph_mat(color)
	var wing := _ph_mat(Color(0.45, 0.25, 0.12))
	var dark := _ph_mat(Color(0.15, 0.1, 0.08))
	# Winged quadruped: long tail, raised neck, wings wider than the harpy's.
	_ph_part(root, _ph_box(Vector3(0.46, 0.44, 0.85)), skin, Vector3(0, 0.6, 0.05))
	_ph_part(root, _ph_cyl(0.09, 0.12, 0.5), skin, Vector3(0, 0.95, -0.42), Vector3.ONE, Vector3(-0.5, 0, 0))
	_ph_part(root, _ph_box(Vector3(0.2, 0.18, 0.3)), skin, Vector3(0, 1.18, -0.6))
	_ph_part(root, _ph_box(Vector3(0.12, 0.08, 0.16)), dark, Vector3(0, 1.14, -0.78))
	for sx in [0.14, -0.14]:
		_ph_part(root, _ph_cyl(0.045, 0.04, 0.42), dark, Vector3(sx, 0.21, 0.28))
		_ph_part(root, _ph_cyl(0.045, 0.04, 0.42), dark, Vector3(sx, 0.21, -0.22))
	_ph_part(root, _ph_box(Vector3(0.72, 0.015, 0.45)), wing, Vector3(0.62, 0.95, 0.05), Vector3.ONE, Vector3(0, -0.2, -0.45))
	_ph_part(root, _ph_box(Vector3(0.72, 0.015, 0.45)), wing, Vector3(-0.62, 0.95, 0.05), Vector3.ONE, Vector3(0, 0.2, 0.45))
	_ph_part(root, _ph_cyl(0.02, 0.06, 0.7), skin, Vector3(0, 0.5, 0.72), Vector3.ONE, Vector3(1.35, 0, 0))


func _ph_banshee(root: Node3D, color: Color) -> void:
	var shroud := _ph_mat(color, 0.6, 0.35)
	var face := _ph_mat(Color(0.12, 0.16, 0.22), 0.9)
	var eyes := _ph_mat(Color(0.8, 0.95, 1.0), 1.0, 1.8)
	# Taller, wider, arms-raised wailing cousin of the ghost shroud.
	_ph_part(root, _ph_cyl(0.18, 0.5, 1.2), shroud, Vector3(0, 0.95, 0))
	_ph_part(root, _ph_sphere(0.26), shroud, Vector3(0, 1.68, 0), Vector3(1, 1.15, 1))
	_ph_part(root, _ph_sphere(0.17), face, Vector3(0, 1.65, -0.1))
	_ph_part(root, _ph_sphere(0.035), eyes, Vector3(0.07, 1.7, -0.24))
	_ph_part(root, _ph_sphere(0.035), eyes, Vector3(-0.07, 1.7, -0.24))
	for sx in [0.36, -0.36]:
		_ph_part(root, _ph_cyl(0.035, 0.08, 0.7), shroud, Vector3(sx, 1.45, -0.05), Vector3.ONE, Vector3(0, 0, sx * -1.6))


## Measure the combined local-space AABB of every mesh under a node,
## without needing the node to be inside the scene tree.
func _measure_aabb(root: Node) -> AABB:
	var box := AABB()
	var first := true
	var stack: Array = [[root, Transform3D.IDENTITY]]
	while not stack.is_empty():
		var item: Array = stack.pop_back()
		var node: Node = item[0]
		var parent_xf: Transform3D = item[1]
		var xf := parent_xf
		if node is Node3D:
			xf = parent_xf * (node as Node3D).transform
		if node is MeshInstance3D:
			var mi := node as MeshInstance3D
			if mi.mesh != null:
				var b := xf * mi.get_aabb()
				box = b if first else box.merge(b)
				first = false
		for c in node.get_children():
			stack.push_back([c, xf])
	return box


func _find_meshes(root: Node) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	var stack: Array = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is MeshInstance3D:
			out.append(node as MeshInstance3D)
		for c in node.get_children():
			stack.push_back(c)
	return out


func _find_anim_player(root: Node) -> AnimationPlayer:
	var stack: Array = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is AnimationPlayer:
			return node as AnimationPlayer
		for c in node.get_children():
			stack.push_back(c)
	return null


## First node under root with the given name (junk-node removal).
func _find_node_named(root: Node, wanted: String) -> Node:
	var stack: Array = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if str(node.name) == wanted:
			return node
		for c in node.get_children():
			stack.push_back(c)
	return null


## Idle-motion profile for an unanimated body, by behavior archetype.
## Registry proc_profile entries (static wired models) win over this.
func _proc_profile_for(archetype: String) -> String:
	if archetype.begins_with("flyer") or archetype == "phase skirmisher":
		return "hover"
	if archetype == "caster":
		return "sway"
	if archetype == "swarmer" or archetype == "trapper/swarm":
		return "scurry"
	if archetype == "venom skirmisher" or archetype == "ambusher":
		return "skitter"
	return "breathe"


## --- Wave 2 integration: behavior tick + voice hooks -----------------
## Telegraph + faint-hint labels. The telegraph label is the visible
## tell the behavior catalog requires (phone-first: it reads at a
## glance, above the name label). The hint label is the idle-AI
## faint-hint rule: an ambusher still hidden, or a trapper with live
## traps, always shows SOMETHING faint (never zero-signal), even
## before perception reveals it fully.
func _create_integration_labels() -> void:
	if not is_instance_valid(_telegraph_label):
		_telegraph_label = Label3D.new()
		_telegraph_label.font_size = 44
		_telegraph_label.pixel_size = 0.004
		_telegraph_label.position = Vector3(0, 2.2, 0)
		_telegraph_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_telegraph_label.modulate = Color(1.0, 0.85, 0.3, 0.95)
		_telegraph_label.visible = false
		add_child(_telegraph_label)
	if not is_instance_valid(_hint_label):
		_hint_label = Label3D.new()
		_hint_label.font_size = 40
		_hint_label.pixel_size = 0.004
		_hint_label.position = Vector3(0, 2.5, 0)
		_hint_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_hint_label.modulate = Color(1, 1, 1, 0.35)
		_hint_label.visible = false
		add_child(_hint_label)


func _refresh_behavior_hints() -> void:
	if not is_instance_valid(_telegraph_label) or not is_instance_valid(_hint_label):
		return
	if behavior_telegraph != "":
		_telegraph_label.text = str(TELEGRAPH_TEXT.get(behavior_telegraph, behavior_telegraph))
		_telegraph_label.visible = true
	else:
		_telegraph_label.visible = false
	var hint := ""
	if behavior_state != null and behavior_state.hidden:
		hint = "?"
	elif behavior_state != null:
		for trap in behavior_state.traps:
			if not trap.triggered and not trap.disarmed:
				hint = "trap?"
				break
	_hint_label.text = hint
	_hint_label.visible = hint != ""


## Lazy state for enemies constructed without setup() (defensive only;
## normal spawn always goes through setup() first).
func _ensure_behavior_state() -> void:
	if behavior_state != null:
		return
	var arch := "brawler"
	if TYPES.has(type_id):
		arch = str(TYPES[type_id].get("archetype", "brawler"))
	behavior_state = Behaviors.new_state(arch, max_hp, atk, def)
	behavior_state.position = Vector2(float(grid_pos.x), float(grid_pos.y))


## Caller-set behavior flags, merged into the next update_behavior()
## tick unless the caller's ctx overrides them. want_charge / wall_hit
## / want_dive are one-shot events and are consumed by the tick;
## can_step_back persists (it describes the room, not an event).
func set_behavior_flags(want_charge: bool = false, wall_hit: bool = false,
		want_dive: bool = false, can_step_back: bool = true) -> void:
	_behavior_want_charge = want_charge
	_behavior_wall_hit = wall_hit
	_behavior_want_dive = want_dive
	_behavior_can_step_back = can_step_back


func request_charge() -> void:
	_behavior_want_charge = true


func report_wall_hit() -> void:
	_behavior_wall_hit = true


func request_dive() -> void:
	_behavior_want_dive = true


## The per-tick behavior call. ctx may carry: player_pos (Vector2),
## allies (int), in_combat (bool), want_charge / wall_hit / want_dive /
## can_step_back. Returns the Behaviors.update() intent Dictionary and
## stores every output field on this enemy for main.gd to read.
## Applied here: healed (clamped to max_hp, bar refreshed), telegraph
## rendering, grapple restrictions, idle voice (periodic, never every
## tick), attack voice on a fresh strike action. NOT applied here:
## venom_damage and grapple_damage (the caller deals them to the
## player), move_dir / move_speed_mult (the caller moves the enemy
## — this node never moves itself), attack_kind / damage_mult (the
## caller resolves the strike), dazzle_miss_chance (read by the
## caller when this enemy is the attack target).
func update_behavior(delta: float, ctx: Dictionary = {}) -> Dictionary:
	_ensure_behavior_state()
	behavior_state.hp = hp
	behavior_state.position = Vector2(float(grid_pos.x), float(grid_pos.y))
	if facing != Vector2i.ZERO:
		behavior_state.facing = Vector2(float(facing.x), float(facing.y))
	var full := ctx.duplicate()
	if not full.has("want_charge"):
		full["want_charge"] = _behavior_want_charge
	if not full.has("wall_hit"):
		full["wall_hit"] = _behavior_wall_hit
	if not full.has("want_dive"):
		full["want_dive"] = _behavior_want_dive
	if not full.has("can_step_back"):
		full["can_step_back"] = _behavior_can_step_back
	_behavior_want_charge = false
	_behavior_wall_hit = false
	_behavior_want_dive = false
	var intent: Dictionary = Behaviors.update(behavior_state, delta, full)
	behavior_intent = intent
	behavior_action = str(intent.get("action", "idle"))
	behavior_telegraph = str(intent.get("telegraph", ""))
	if behavior_telegraph != "":
		last_telegraph = behavior_telegraph
		_log_telegraph()
	behavior_move_dir = intent.get("move_dir", Vector2.ZERO)
	behavior_move_speed_mult = float(intent.get("move_speed_mult", 1.0))
	behavior_attack_kind = str(intent.get("attack_kind", ""))
	behavior_damage_mult = float(intent.get("damage_mult", 1.0))
	behavior_dazzle_miss_chance = float(intent.get("dazzle_miss_chance", 0.0))
	behavior_altitude = float(intent.get("altitude", 0.0))
	behavior_flight_phase = str(intent.get("flight_phase", "ground"))
	behavior_charge_phase = str(intent.get("charge_phase", "idle"))
	behavior_grapple_phase = str(intent.get("grapple_phase", "none"))
	behavior_venom_damage = float(intent.get("venom_damage", 0.0))
	behavior_grapple_damage = float(intent.get("grapple_damage", 0.0))
	var healed := float(intent.get("healed", 0.0))
	behavior_healed = healed
	if healed > 0.0:
		hp = minf(max_hp, hp + healed)
		behavior_state.hp = hp
		_refresh_bar()
	player_can_move = bool(intent.get("can_player_move", true))
	player_attack_mult = float(intent.get("player_attack_mult", 1.0))
	player_grappled = behavior_grapple_phase == "held"
	_refresh_behavior_hints()
	if not dead and not asleep:
		_idle_voice_timer += delta
		if _idle_voice_timer >= IDLE_VOICE_INTERVAL:
			_idle_voice_timer = 0.0
			play_idle_vocal()
		if behavior_action == "strike" and _prev_behavior_action != "strike":
			play_attack_vocal()
	_prev_behavior_action = behavior_action
	return intent


## Log a NEW telegraph once (not every tick) via GameState when the
## autoload is reachable; silent when it is not (headless unit runs).
## Dynamic lookup on purpose: this script must not hard-depend on an
## autoload identifier to compile in -s test runs.
func _log_telegraph() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree == null:
		return
	var gs := tree.root.get_node_or_null("GameState")
	if gs != null and gs.has_method("add_log"):
		gs.call("add_log", "%s %s" % [display_name,
			str(TELEGRAPH_TEXT.get(behavior_telegraph, behavior_telegraph))])


## True while any telegraph/windup tell is showing: the window a
## future dodge/block mechanic would gate on. No such mechanic exists
## in the codebase today, so this is exposure, not enforcement.
func in_telegraph_window() -> bool:
	return behavior_telegraph != "" or behavior_charge_phase == "telegraph" \
		or behavior_grapple_phase == "telegraph"


## Ground melee reaches this enemy only while its flight altitude is
## below 0.5 (Behaviors flying rule).
func is_melee_reachable() -> bool:
	_ensure_behavior_state()
	return Behaviors.melee_reachable(behavior_state)


## Player-side grapple restrictions, straight from behaviors.gd.
func grapple_player_restrictions() -> Dictionary:
	_ensure_behavior_state()
	return Behaviors.grapple_player_restrictions(behavior_state)


## One struggle input from the held player. True if it broke the hold.
## Wave 3 wiring: movement keys ARE the struggle while held (main.gd
## _try_step routes them here) — no new input, no new action.
func struggle_grapple() -> bool:
	_ensure_behavior_state()
	return Behaviors.grapple_struggle(behavior_state)


## Reveal a hidden ambusher (first strike spent). Returns nothing;
## the faint "?" hint clears on the next label refresh.
func reveal_ambush() -> void:
	_ensure_behavior_state()
	Behaviors.ambush_reveal(behavior_state)
	_refresh_behavior_hints()


## A sting/bite landing applies venom to this enemy's own state, whose
## ticks then report venom_damage for the caller to deal. Returns the
## new stack count.
func apply_venom() -> int:
	_ensure_behavior_state()
	return Behaviors.apply_venom(behavior_state)


## This enemy as a dazzle TARGET: its own state holds the timer, and
## update_behavior() reports dazzle_miss_chance from it. (A pixie
## dazzling the PLAYER is a separate, player-side store — Wave 3.)
func apply_dazzle() -> void:
	_ensure_behavior_state()
	Behaviors.apply_dazzle(behavior_state)


## Place one trap at a grid cell (trapper archetypes). Traps persist
## after the trapper dies; only trigger/disarm removes them.
func place_behavior_trap(cell: Vector2) -> bool:
	_ensure_behavior_state()
	behavior_state.position = Vector2(float(grid_pos.x), float(grid_pos.y))
	var placed := Behaviors.place_trap(behavior_state, cell) != null
	_refresh_behavior_hints()
	return placed


## Advance all live traps one tick against the victim's grid cell.
## Returns an Array of trigger result Dictionaries (empty when
## nothing triggered). The caller deals the damage / root.
func update_behavior_traps(delta: float, victim_cell: Vector2) -> Array:
	_ensure_behavior_state()
	var out: Array = []
	for trap in behavior_state.traps:
		var res: Dictionary = Behaviors.update_trap(behavior_state, trap, delta, victim_cell)
		if bool(res.get("triggered", false)):
			out.append(res)
	_refresh_behavior_hints()
	return out


## --- voice hooks ------------------------------------------------------
## Defensive by construction: unknown type or context fails silent
## (returns false, never crashes), and a missing AudioManager autoload
## (e.g. a bare unit run) also fails silent. Banshee: idle = breath
## pool, attack/death = scream pool (voice_map.gd); simultaneous
## scream+breath layering is future work, noted, not faked here.
func _audio_manager() -> Node:
	if not is_inside_tree():
		return null
	var tree := get_tree()
	if tree == null:
		return null
	return tree.root.get_node_or_null("AudioManager")


func _play_vocal(context: String) -> bool:
	if context != "death" and dead:
		return false
	var am := _audio_manager()
	if am == null or not am.has_method("has_monster_voice") \
			or not am.has_method("resolve_monster_vocal") \
			or not am.has_method("play_monster_vocal"):
		return false
	if not bool(am.call("has_monster_voice", type_id)):
		return false
	if str(am.call("resolve_monster_vocal", type_id, context)) == "":
		return false
	var pool = am.get("_pool")
	if pool is Array and pool.is_empty():
		am.call("_ready")
		pool = am.get("_pool")
		if pool is Array and pool.is_empty():
			return false
	return bool(am.call("play_monster_vocal", type_id, context))


func play_idle_vocal() -> bool:
	return _play_vocal("idle")


## Attack voice: called by main.gd when this enemy strikes (manual
## mode, and the idle retaliation path) and automatically on a fresh
## strike action in update_behavior() (idle mode). Wave 3 dedupe: a
## second attack vocal within ATTACK_VOCAL_DEDUPE_MS of the first is
## suppressed, so the two paths never double up on one strike.
func play_attack_vocal() -> bool:
	var now := Time.get_ticks_msec()
	if now - _last_attack_vocal_msec < ATTACK_VOCAL_DEDUPE_MS:
		return false
	if _play_vocal("attack"):
		_last_attack_vocal_msec = now
		return true
	return false


func play_death_vocal() -> bool:
	return _play_vocal("death")


## Apply damage. Returns true if this killed the enemy.
func take_damage(amount: float) -> bool:
	if dead:
		return true
	hp = maxf(0.0, hp - amount)
	if behavior_state != null:
		Behaviors.notify_damaged(behavior_state, amount)
		behavior_state.hp = hp
	_flash()
	_refresh_bar()
	if hp <= 0.0:
		dead = true
		if behavior_state != null:
			behavior_state.dead = true
		play_death_vocal()
		died.emit(self)
		return true
	return false


func _refresh_bar() -> void:
	if not is_instance_valid(_bar_fg):
		return
	var frac := clampf(hp / max_hp, 0.0, 1.0)
	_bar_fg.scale.x = maxf(frac, 0.001)
	# Left-align the shrinking bar.
	_bar_fg.position.x = -0.48 * (1.0 - frac)


func _flash() -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	if _body_mats.is_empty():
		return
	_flash_tween = create_tween()
	for mat in _body_mats:
		mat.emission_enabled = true
		mat.emission = Color(1, 1, 1)
	_flash_tween.tween_interval(0.08)
	_flash_tween.tween_callback(func() -> void:
		for m in _body_mats:
			if is_instance_valid(m):
				m.emission_enabled = false
	)
