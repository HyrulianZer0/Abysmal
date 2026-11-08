# Abysmal — Bestiary Tracker

Dev-only progress tracker. Source of truth for creature names and materials: `design-notes/monster-material-list-filled-2026-10-29.txt` (300 base creatures, 28 families). Statuses cross-referenced against `scripts/enemy.gd` (28 TYPES), `scripts/monster_models.gd` (MODELS + ROSTER_MODELS), `scripts/apex_bosses.gd` (16 apex), `scripts/voice_map.gd` (TYPE_VOICE), and `scripts/dungeon_gen.gd` (`spawn_table`). Generated Nov 1, 2026 — DOC ONLY, no game code touched. Updated Nov 1, 2026 (phase 1: kobold wired, golem mirror wired, spawn-guard discrepancy resolved; phase 2 survey Nov 1, 2026: Appendix D — 13 FOUND / 217 STAND-IN / 51 NO MODEL FOUND across 281 non-wired rows).

Variants (~1,000 with attunements / corruption / stature) inherit their base creature's materials and are NOT separate rows here.

## Summary

| Metric | Count |
| --- | ---: |
| Total creatures (material-list rows) | 300 |
| Families | 28 |
| Creatures with a model file mapped in code | 22 |
| &nbsp;&nbsp;of which wired to a live type | 19 |
| &nbsp;&nbsp;of which roster-only model (not wired, no spawn) | 3 |
| Creatures apex-linked only (Hellhound via Cerberus) | 1 |
| Creatures pending models (live procedural types) | 7 |
| Creatures with no code presence at all | 270 |
| Code types wired (of 28 TYPES in enemy.gd) | 21 |
| Code types without a material-list row (Cave Wolf, Wraith) | 2 |
| Visually reviewed: apex full pass | 1 (Cerberus) |
| Visually reviewed: list rows eyeballed, held/partial verdict | 4 (Goblin, Kobold fallback, Clay Golem mirror, Cave Spider) |
| Visually reviewed: list rows fully passed for shipping | 0 |
| Apex bosses with treatments documented | 16 |
| Apex bosses with hooks activated | 0 |

### Notes and discrepancies (read before using the counts)

- **Spawn-guard discrepancy — RESOLVED Nov 1 (phase 1).** The old claim is pre–Wave 3: dungeon_gen documents the guard was lifted on purpose ("the full 28-type staged roster actually appears in gameplay"); the `guard` variables are loop-safety counters, not spawn filters. No spawn guard was found in `scripts/main.gd` or `scripts/dungeon_gen.gd`: `spawn_table()` includes all 28 types at depth bands (depth 1: slime, bat, rat, spider, frog; 2+: skeleton, snake, centipede, goblin, boar; 3+: zombie, wolf, scorpion, wasp, kobold; 4+: skeleton_archer, imp, pixie; 5+: ghost, golem, orc, harpy; 6+: troll, minotaur, oni, kappa; 8+: drake, banshee) and `main.gd` spawns whatever `dungeon_gen` picks. The “behavior live” column follows the code. The guard claim needs verification against the live build before it is trusted.
- **“Wired” means a live TYPES entry with a real model.** The 20 wired code types map to only 18 material-list rows: the wolf type is named “Cave Wolf” and the ghost type “Wraith” — neither name appears in the material list (see appendix). Nearest list rows (Wolf; Specter/Phantom) are NOT claimed as matches.
- **Sounds are family-level, never per-creature.** `voice_map.gd` states no per-monster vocals exist in any free pack found. “Family pool mapped” means the creature's code type has a TYPE_VOICE entry. Creatures with no code type are UNKNOWN — a family pool is not assumed for them. Banshee's dedicated wail is the known gap.
- **Registry notes are stale for four models.** `monster_models.gd` still says spider, wolf, golem, and cerberus have “not been eyeballed”; Nov 1 reviews (Cerberus passed; golem mirror “nice”; spider “not bad as fallback”, held; wolf held) supersede those notes. This tracker records the Nov 1 verdicts.
- **Apex bosses are not list rows.** The 16 apex bosses are built on list rows as base types (see appendix). Only Cerberus has a model file; the other 15 are procedural-only treatments with hooks NOT activated.

### Column legend

- **model status**: Wired = model file in the MODELS dict (live type) or Quaternius live model; Roster-only = ROSTER_MODELS entry with no TYPES entry; None = no model mapped in code.
- **wired**: Yes = live TYPES entry with a real model. (Procedural live types are “No” here — they spawn on placeholder bodies.)
- **visually reviewed**: James's eyeball verdicts only. “No” includes registry “VISUAL REVIEW REQUIRED” flags.
- **sounds**: family-pool mapping from `voice_map.gd`, or UNKNOWN where no code mapping exists.
- **behavior live**: spawns via `spawn_table()` depth bands, or No where the creature has no spawn entry.

## Oozes & Slimes (8)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Slime | viscous mucus | Wired — Quaternius model (live type) | Yes | No | Family pool mapped (ooze) | Yes — spawns (depth 1) |
| Cave Jelly | luminescent gelatin | None — not in code | No | No | UNKNOWN | No |
| Amber Ooze | hardened resinous glob | None — not in code | No | No | UNKNOWN | No |
| Mire Pudding | stagnant sediment | None — not in code | No | No | UNKNOWN | No |
| Acid Blob | corrosive enzyme | None — not in code | No | No | UNKNOWN | No |
| Gloom Ooze | umbral sludge | None — not in code | No | No | UNKNOWN | No |
| Mercury Slime | heavy metallic fluid | None — not in code | No | No | UNKNOWN | No |
| Primordial Ooze | raw protoplasm | None — not in code | No | No | UNKNOWN | No |

## Vermin & Cave Crawlers (17)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Cave Rat | rat tail | Wired — rat_full.glb | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 1) |
| Rat Swarm | matted fur scraps | None — not in code | No | No | UNKNOWN | No |
| Cave Bat | leathery wing membrane | Wired — Quaternius model (live type) | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 1) |
| Cave Spider | silk | Wired — CellarSpider_godot.glb | Yes | Eyeballed — “not bad as fallback”, HELD (not finalized) | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 1) |
| Cave Wasp | venom stinger | None — procedural placeholder (Bee.glb stand-in on disk, unwired) | No | No | Family pool mapped (TYPE_VOICE) | Yes — spawns as placeholder (depth 3+) |
| Cave Scorpion | chitinous pincer | Wired — enemy_scorpion.glb (PS1) | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 3+) |
| Centipede | segmented shell | Wired — GeodeCentipede.glb | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 2+) |
| Cave Frog | moist hide | None — procedural placeholder (must source) | No | No | Family pool mapped (TYPE_VOICE) | Yes — spawns as placeholder (depth 1) |
| Giant Rat | oversized rodent pelt | None — not in code | No | No | UNKNOWN | No |
| Vampire Bat | crimson-webbed wing | Roster-only model — bat_v5.glb, not wired to a type | No | No | UNKNOWN | No — roster model only, no spawn |
| Widow Spider | toxic spinneret | None — not in code | No | No | UNKNOWN | No |
| Emperor Scorpion | sovereign carapace | None — not in code | No | No | UNKNOWN | No |
| Stag Beetle | iridescent mandible | None — not in code | No | No | UNKNOWN | No |
| Burrow Worm | tunneling mucus gland | None — not in code | No | No | UNKNOWN | No |
| Carrion Worm | putrid ichor sack | None — not in code | No | No | UNKNOWN | No |
| Hornet Matriarch | royal thorax shell | None — not in code | No | No | UNKNOWN | No |
| Ōmukade (also Japanese Yōkai) | giant segmented plates | None — not in code | No | No | UNKNOWN | No |

## Beasts (23)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Wolf | fur | None — no code presence (code wolf type is “Cave Wolf”, no list row; match unconfirmed) | No | No | UNKNOWN | No |
| Wild Boar | leather | Wired — Boar.glb (Gobkit) | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 2+) |
| Hyena | coarse hide | None — not in code | No | No | UNKNOWN | No |
| Giant Serpent | scaled serpentine skin | Wired — enemy_cobracon.glb (PS1) | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 2+) |
| Grizzly | heavy leather | None — not in code | No | No | UNKNOWN | No |
| Dire Wolf | thick winter fur | None — not in code | No | No | UNKNOWN | No |
| Warhound | scarred tough hide | None — not in code | No | No | UNKNOWN | No |
| Cave Bear | heavy leather | None — not in code | No | No | UNKNOWN | No |
| Razorback | bristled thick hide | None — not in code | No | No | UNKNOWN | No |
| Panther | sleek dark pelt | None — not in code | No | No | UNKNOWN | No |
| Cave Python | subterranean scales | None — not in code | No | No | UNKNOWN | No |
| Cave Ape | shaggy thick pelt | None — not in code | No | No | UNKNOWN | No |
| Baboon Troop | patchy primate hide | None — not in code | No | No | UNKNOWN | No |
| Crag Ram | curled heavy horn | None — not in code | No | No | UNKNOWN | No |
| Deep Stag | branched bone antler | None — not in code | No | No | UNKNOWN | No |
| Grotto Bull | heavy leather | None — not in code | No | No | UNKNOWN | No |
| Blind Mole | velvety pelt | None — not in code | No | No | UNKNOWN | No |
| Crocodile | armored scutes | None — not in code | No | No | UNKNOWN | No |
| Lion | golden mane hide | None — not in code | No | No | UNKNOWN | No |
| Sabertooth | elongated saber fangs | None — not in code | No | No | UNKNOWN | No |
| Tiger | striped heavy pelt | None — not in code | No | No | UNKNOWN | No |
| Cave Hyena | spotted rough hide | None — not in code | No | No | UNKNOWN | No |
| Pale Horse | light leather | None — not in code | No | No | UNKNOWN | No |

## Goblin-Kin & Cave Folk (12)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Kobold | scaly scrap hide | Wired — goblin.glb fallback (James-approved Nov 1; NOT a true kobold, hunt target gadget-tinker (color open, dragonkin optional); Gobkit minions a01–d01 reviewed + REJECTED) | Yes | Fallback goblin.glb eyeballed — decent | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 3+) |
| Goblin | rough ear cartilage | Wired — goblin.glb | Yes | Eyeballed as kobold fallback — decent | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 2+) |
| Goblin Sneak | soft suede rags | None — not in code | No | No | UNKNOWN | No |
| Goblin Shaman | bone fetish beads | None — not in code | No | No | UNKNOWN | No |
| Hobgoblin | toughened hide scraps | None — not in code | No | No | UNKNOWN | No |
| Bugbear | coarse bristle fur | None — not in code | No | No | UNKNOWN | No |
| Boggart | withered knuckle bone | None — not in code | No | No | UNKNOWN | No |
| Redcap (also Celtic & British Isles) | iron-stained felt | None — not in code | No | No | UNKNOWN | No |
| Spriggan (also Celtic & British Isles) | gnarled wood-bark skin | None — not in code | No | No | UNKNOWN | No |
| Gremlin | greasy ear leather | None — not in code | No | No | UNKNOWN | No |
| Púca (also Celtic & British Isles) | shapeshifted bristle | None — not in code | No | No | UNKNOWN | No |
| Goblin Champion | veteran scarred hide | None — not in code | No | No | UNKNOWN | No |

## Orcs, Trolls & Giant-Kin (15)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Orc | green-tinged thick hide | Wired — OrcLegionary.glb | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 5+) |
| Orc Berserker | battle-scarred thick hide | None — not in code | No | No | UNKNOWN | No |
| Half-Ogre | coarse heavy hide | None — not in code | No | No | UNKNOWN | No |
| Ogre | heavy leather | None — not in code | No | No | UNKNOWN | No |
| Marsh Troll | spongy regenerative fat | None — not in code | No | No | UNKNOWN | No |
| Troll | rubbery hide | Wired — Troll.glb (FLARE) | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 6+) |
| Orc Shaman | tribal ritual bone | None — not in code | No | No | UNKNOWN | No |
| Cave Troll | stony rough hide | None — not in code | No | No | UNKNOWN | No |
| Ettin | dual-headed skull fragment | None — not in code | No | No | UNKNOWN | No |
| Cyclops | monocle optic nerve | None — not in code | No | No | UNKNOWN | No |
| Hill Giant | giant hide | None — not in code | No | No | UNKNOWN | No |
| Stone Giant | granitic outer crust | None — not in code | No | No | UNKNOWN | No |
| Frost Giant (also Norse & Germanic) | rime-encrusted giant hide | None — not in code | No | No | UNKNOWN | No |
| Ogre Mage | mystic-marked heavy hide | None — not in code | No | No | UNKNOWN | No |
| Fire Giant (also Norse & Germanic) | cinderscorched plate skin | None — apex base only (Surtr: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |

## The Undead (23)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Skeleton | brittle bone shard | Wired — Quaternius model (live type) | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 2+) |
| Skeleton Archer | notched arm bone | Wired — skull_monster.obj | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 4+) |
| Zombie | rotted flesh scrap | None — procedural placeholder (Kenney zombie on disk, unwired) | No | No | Family pool mapped (undead); jalastram gasp loop repurposed, pool moved to undead Nov 1 | Yes — spawns as placeholder (depth 3+) |
| Skeleton Knight | polished iron-bone | None — not in code | No | No | UNKNOWN | No |
| Ghoul (also Demons, Devils & the Damned) | clawed necrotic digit | None — not in code | No | No | UNKNOWN | No |
| Barrow Wight | ancient grave dust | None — not in code | No | No | UNKNOWN | No |
| Specter | ethereal ectoplasm | None — not in code | No | No | UNKNOWN | No |
| Poltergeist | volatile spirit shiver | None — not in code | No | No | UNKNOWN | No |
| Draugr (also Norse & Germanic) | bloated corpse flesh | None — not in code | No | No | UNKNOWN | No |
| Mummy (also Egyptian & Near East) | linen burial wrap | None — not in code | No | No | UNKNOWN | No |
| Phantom | translucent shroud fragment | None — not in code | No | No | UNKNOWN | No |
| Banshee (also Celtic & British Isles) | wailing vocal resonance | None — procedural placeholder (must source model + wail) | No | No | Mapped to spirit/human_scream pools; dedicated wail MISSING | Yes — spawns as placeholder (depth 8+) |
| Vampire | preserved noble blood | None — not in code | No | No | UNKNOWN | No |
| Strigoi | ash-grey cursed heart | None — not in code | No | No | UNKNOWN | No |
| Jiangshi (also Chinese & East Asian) | sealing talisman scrap | None — not in code | No | No | UNKNOWN | No |
| Vetala (also South Asian) | cemetery soil residue | None — not in code | No | No | UNKNOWN | No |
| Revenant | vengeance-bound sinew | Roster-only model — enemy_revenant.glb (PS1), not wired | No | No | UNKNOWN | No — roster model only, no spawn |
| Sluagh (also Celtic & British Isles) | restless shadow feather | None — not in code | No | No | UNKNOWN | No |
| Wight Lord | rusted crown fragment | None — not in code | No | No | UNKNOWN | No |
| Lich | phylactery glass dust | None — apex base only (Koschei the Deathless: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |
| Dullahan (also Celtic & British Isles) | headless spine segment | None — not in code | No | No | UNKNOWN | No |
| Gashadokuro (also Japanese Yōkai) | giant vengeful femur | None — not in code | No | No | UNKNOWN | No |
| Penanggalan | trailing viscera cord | None — not in code | No | No | UNKNOWN | No |

## Greek & Mediterranean Myth (17)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Satyr | cloven goat hoof | None — not in code | No | No | UNKNOWN | No |
| Harpy (also Sky & Storm) | avian talon | None — procedural placeholder (must source) | No | No | Family pool mapped (TYPE_VOICE) | Yes — spawns as placeholder (depth 5+) |
| Centaur | equine light leather | None — not in code | No | No | UNKNOWN | No |
| Siren | luring feather plumage | None — not in code | No | No | UNKNOWN | No |
| Hellhound (also Demons, Devils & the Damned) | sulfurous canine fang | None — apex base only (Cerberus model exists for the apex boss, not for Hellhound as a type) | No | No | UNKNOWN (apex Cerberus: pool names only, no clips) | No — apex hook not activated |
| Minotaur | heavy minotaur hide | Wired — BrazenMinotaur.glb | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 6+) |
| Stymphalian Bird (also Sky & Storm) | bronze-tipped quill | None — not in code | No | No | UNKNOWN | No |
| Bronze Bull | heat-conductive metal plating | None — not in code | No | No | UNKNOWN | No |
| Gorgon | petrified scale | None — apex base only (Medusa: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |
| Chimera | lion-goat-serpent composite hide | None — not in code | No | No | UNKNOWN | No |
| Sphinx | riddling golden tuft | None — not in code | No | No | UNKNOWN | No |
| Griffin (also Sky & Storm) | aquiline golden feather | None — not in code | No | No | UNKNOWN | No |
| Manticore | barbed tail spike | None — not in code | No | No | UNKNOWN | No |
| Lamia | serpentine scaled underbelly | None — apex base only (Echidna: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |
| Empusa | bronze prosthetic limb scrap | None — not in code | No | No | UNKNOWN | No |
| Nemean Lion | invulnerable golden pelt | None — not in code | No | No | UNKNOWN | No |
| Hydra (also Dragons & Great Serpents) | multi-headed regenerative blood | None — apex base only (Yamata no Orochi: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |

## Norse & Germanic (10)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Sea Serpent | abyssal scale | None — not in code | No | No | UNKNOWN | No |
| Nixie | freshwater reed skirt | None — not in code | No | No | UNKNOWN | No |
| Hulder | hollow tree-tail scrap | None — not in code | No | No | UNKNOWN | No |
| Mare | nightmare mane hair | None — not in code | No | No | UNKNOWN | No |
| Dark Elf (Dökkálfar) | obsidian mesh fabric | None — not in code | No | No | UNKNOWN | No |
| Alfar Raider | twilight leather | None — not in code | No | No | UNKNOWN | No |
| Fallen Valkyrie (also Celestials & the Fallen) | tarnished silver feather | None — not in code | No | No | UNKNOWN | No |
| Great Wolf | colossal wolf pelt | None — apex base only (Fenrir: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |
| Lindworm (also Dragons & Great Serpents) | wingless dragon scale | None — not in code | No | No | UNKNOWN | No |
| Kraken (also Aquatic & the Drowned Deep) | colossal tentacle suction ring | None — not in code | No | No | UNKNOWN | No |

## Egyptian & Near East (9)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Scarab Swarm | iridescent beetle shell | None — not in code | No | No | UNKNOWN | No |
| Asp | desert cobra hood | None — not in code | No | No | UNKNOWN | No |
| Jackal Guardian | embalmed jackal hide | None — not in code | No | No | UNKNOWN | No |
| Guardian Scorpion | temple-carved chitin | None — not in code | No | No | UNKNOWN | No |
| Serpopard | mythical spotted pelt | None — not in code | No | No | UNKNOWN | No |
| Sha Beast | anomalous beast ear | None — not in code | No | No | UNKNOWN | No |
| Falcon Sphinx | raptor-headed crest | None — not in code | No | No | UNKNOWN | No |
| Devourer Beast | abyssal-stomach lining | None — not in code | No | No | UNKNOWN | No |
| Ushabti (also Golems & Constructs) | faience ceramic shard | None — not in code | No | No | UNKNOWN | No |

## Japanese Yōkai (13)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Karakasa | oiled paper parasol rib | None — not in code | No | No | UNKNOWN | No |
| Chōchin-obake | lantern bamboo frame | None — not in code | No | No | UNKNOWN | No |
| Kappa | head-plate water basin fragment | Wired — snappa-kappa.glb | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 6+) |
| Oni | ogre brow horn | None — procedural placeholder (orc/troll stand-in option; no true model; also apex base: Shuten-dōji) | No | No | Family pool mapped (TYPE_VOICE) | Yes — spawns as placeholder (depth 6+) |
| Bake-danuki | oversized tanuki leaf | None — not in code | No | No | UNKNOWN | No |
| Kasha | corpse-fire cinder | None — not in code | No | No | UNKNOWN | No |
| Kitsune | celestial spirit tail-fur | None — not in code | No | No | UNKNOWN | No |
| Tengu | crow-tengu large wing feather | None — not in code | No | No | UNKNOWN | No |
| Yuki-onna | unmelting frost crystal | None — not in code | No | No | UNKNOWN | No |
| Jorōgumo | patterned spider abdomen shell | None — not in code | No | No | UNKNOWN | No |
| Nure-onna | damp serpentine hair-strand | None — not in code | No | No | UNKNOWN | No |
| Nue | chimeric chimera-tail snake skin | None — not in code | No | No | UNKNOWN | No |
| Tsuchigumo | earth-crusted spider leg | None — not in code | No | No | UNKNOWN | No |

## Celtic & British Isles (8)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Kelpie (also Aquatic & the Drowned Deep) | river-weed mane | None — not in code | No | No | UNKNOWN | No |
| Merrow (also Aquatic & the Drowned Deep) | webbed fin-membrane | None — not in code | No | No | UNKNOWN | No |
| Selkie | smooth seal pelt | None — not in code | No | No | UNKNOWN | No |
| Cat Sìth | spectral feline fur | None — not in code | No | No | UNKNOWN | No |
| Bauchan | mischievous goblin ear | None — not in code | No | No | UNKNOWN | No |
| Fachan | single-eye lens fragment | None — not in code | No | No | UNKNOWN | No |
| Afanc | lake-bed mineralized hide | None — not in code | No | No | UNKNOWN | No |
| Bean-nighe | blood-washed laundering rag | None — not in code | No | No | UNKNOWN | No |

## Slavic (11)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Domovoi | hearth-ash tuft | None — not in code | No | No | UNKNOWN | No |
| Kikimora | wall-cracks moss | None — not in code | No | No | UNKNOWN | No |
| Rusalka (also Aquatic & the Drowned Deep) | drowning hair-weed | None — not in code | No | No | UNKNOWN | No |
| Vodyanoy | green water-frog skin | None — not in code | No | No | UNKNOWN | No |
| Striga | vampiric night-feather | None — not in code | No | No | UNKNOWN | No |
| Leshy (also Plants & Fungi) | living birch bark | None — not in code | No | No | UNKNOWN | No |
| Alkonost | sorrow-singing bird feather | None — not in code | No | No | UNKNOWN | No |
| Gamayun | prophetic feather quill | None — not in code | No | No | UNKNOWN | No |
| Mora | suffocating night-mist | None — not in code | No | No | UNKNOWN | No |
| Zmey (also Dragons & Great Serpents) | multi-headed dragon scale | None — not in code | No | No | UNKNOWN | No |
| Firebird (also Sky & Storm) | luminescent ember feather | None — not in code | No | No | UNKNOWN | No |

## Mesopotamian (8)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Cedar Guardian | sacred cedar resin | None — apex base only (Humbaba: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |
| Galla | underworld bailiff shackle | None — not in code | No | No | UNKNOWN | No |
| Scorpion Man | hybrid chitin-skin | None — not in code | No | No | UNKNOWN | No |
| Ugallu | storm-lion pelt | None — not in code | No | No | UNKNOWN | No |
| Lamassu | winged bull feather-hide | None — not in code | No | No | UNKNOWN | No |
| Mušḫuššu | dragon-serpent scute | None — not in code | No | No | UNKNOWN | No |
| Anzu (also Sky & Storm) | storm-bird beak fragment | None — apex base only (Anzu: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |
| Asag | disease-tainted stone slag | None — not in code | No | No | UNKNOWN | No |

## South Asian (8)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Naga (also Aquatic & the Drowned Deep) | multi-headed cobra scale | None — not in code | No | No | UNKNOWN | No |
| Yaksha | guardian tree root-fiber | None — not in code | No | No | UNKNOWN | No |
| Bhūta | phantom ash | None — not in code | No | No | UNKNOWN | No |
| Piśāca | flesh-eating ghoul tooth | None — not in code | No | No | UNKNOWN | No |
| Rakshasa | illusion-woven beast pelt | None — apex base only (Ravana: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |
| Makara (also Aquatic & the Drowned Deep) | crocodile-fish composite scale | None — not in code | No | No | UNKNOWN | No |
| Asura | celestial-wrath iron hide | None — not in code | No | No | UNKNOWN | No |
| Garuda (also Sky & Storm) | sun-fire golden feather | None — not in code | No | No | UNKNOWN | No |

## Chinese & East Asian (9)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Terracotta Soldier (also Golems & Constructs) | baked clay armor shard | None — not in code | No | No | UNKNOWN | No |
| Mountain Yaoguai | rugged boulder hide | None — not in code | No | No | UNKNOWN | No |
| Xiezhi | justice-seeking single horn | None — not in code | No | No | UNKNOWN | No |
| Hulijing | nine-tailed spirit fur | None — not in code | No | No | UNKNOWN | No |
| Mogwai | mischievous damp pelt | None — not in code | No | No | UNKNOWN | No |
| River Long (also Dragons & Great Serpents) | celestial river scale | None — not in code | No | No | UNKNOWN | No |
| Taotie | gluttonous stomach leather | None — not in code | No | No | UNKNOWN | No |
| Hundun | faceless chaos blur-pelt | None — not in code | No | No | UNKNOWN | No |
| Qilin, Corrupted | tainted auspicious horn | None — not in code | No | No | UNKNOWN | No |

## Mesoamerican & Andean (6)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Ahuizotl | hand-tipped tail appendage | None — not in code | No | No | UNKNOWN | No |
| Death Bat | sacrificial wing membrane | None — not in code | No | No | UNKNOWN | No |
| Nagual | shapeshifter skin fragment | None — not in code | No | No | UNKNOWN | No |
| Storm Wraith | condensed tempest vapor | None — not in code | No | No | UNKNOWN | No |
| Tzitzimitl | stellar skeletal star-bone | None — not in code | No | No | UNKNOWN | No |
| Cipactli Brood | primordial aquatic scute | None — not in code | No | No | UNKNOWN | No |

## African Traditions (6)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Tokoloshe | river-spirit hair tuft | None — not in code | No | No | UNKNOWN | No |
| Adze | firefly-form chitin | None — not in code | No | No | UNKNOWN | No |
| Impundulu (also Sky & Storm) | lightning-striking feather | None — not in code | No | No | UNKNOWN | No |
| Sasabonsam | forest-giant leathery hide | None — not in code | No | No | UNKNOWN | No |
| Mami Wata | mermaid serpentine scale | None — not in code | No | No | UNKNOWN | No |
| Inkanyamba | torrential storm serpent scale | None — not in code | No | No | UNKNOWN | No |

## Fey & Nature Spirits (11)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Pixie | iridescent dust | None — procedural placeholder (must source) | No | No | Family pool mapped (TYPE_VOICE) | Yes — spawns as placeholder (depth 4+) |
| Sprite | translucent wing | None — not in code | No | No | UNKNOWN | No |
| Bramble Imp | thorny vine fragment | None — not in code | No | No | UNKNOWN | No |
| Brownie | homespun wool scrap | None — not in code | No | No | UNKNOWN | No |
| Dryad (also Plants & Fungi) | living heartwood | None — not in code | No | No | UNKNOWN | No |
| Naiad | crystal stream droplet | None — not in code | No | No | UNKNOWN | No |
| Sylph (also Elementals & Primal Spirits) | condensed breeze wisp | None — not in code | No | No | UNKNOWN | No |
| Faun | caprine leg-fur | None — not in code | No | No | UNKNOWN | No |
| Will-o'-wisp | trapped ghost-light core | None — not in code | No | No | UNKNOWN | No |
| Changeling | glamour-faded cloth | None — not in code | No | No | UNKNOWN | No |
| Elder Dryad (also Plants & Fungi) | ancient ironwood bark | None — not in code | No | No | UNKNOWN | No |

## Demons, Devils & the Damned (11)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Imp | smoldering horn scrap | Wired — FattyImp.glb | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 4+) |
| Possessed Cultist | tainted blood-cloth | None — not in code | No | No | UNKNOWN | No |
| Succubus | alluring leather wing | None — not in code | No | No | UNKNOWN | No |
| Incubus | shadow-touched leather wing | None — not in code | No | No | UNKNOWN | No |
| Pit Brute | brimstone-crusted hide | None — not in code | No | No | UNKNOWN | No |
| Djinn | bottled whirlwind core | None — not in code | No | No | UNKNOWN | No |
| Larva of the Damned | writhing soul slime | None — not in code | No | No | UNKNOWN | No |
| Ifrit | living charcoal core | None — not in code | No | No | UNKNOWN | No |
| Marid | pressurized water globule | None — not in code | No | No | UNKNOWN | No |
| Contract Devil | blood-signed parchment scrap | None — not in code | No | No | UNKNOWN | No |
| Shaitan | heavy earth-gem shard | None — not in code | No | No | UNKNOWN | No |

## Celestials & the Fallen (6)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Deva | radiant divine feather | None — not in code | No | No | UNKNOWN | No |
| Seraph | six-winged halo fragment | None — not in code | No | No | UNKNOWN | No |
| Ophanim | eye-set wheel bronze ring | None — not in code | No | No | UNKNOWN | No |
| Watcher (Grigori) | ancient celestial stone plate | None — not in code | No | No | UNKNOWN | No |
| Fallen Angel | scorched holy feather | None — not in code | No | No | UNKNOWN | No |
| Ashen Seraph | cinderscorched wing plume | None — not in code | No | No | UNKNOWN | No |

## Elementals & Primal Spirits (10)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Gnome | compressed earth nodule | None — not in code | No | No | UNKNOWN | No |
| Salamander | flame-slicked scale | None — not in code | No | No | UNKNOWN | No |
| Fire Elemental | unstable ember core | None — not in code | No | No | UNKNOWN | No |
| Water Elemental | fluid core droplet | None — not in code | No | No | UNKNOWN | No |
| Earth Elemental | dense granite chunk | None — not in code | No | No | UNKNOWN | No |
| Air Elemental | captured gale fragment | None — not in code | No | No | UNKNOWN | No |
| Undine | pure liquid droplet | None — not in code | No | No | UNKNOWN | No |
| Storm Elemental | static-charged thunder stone | None — not in code | No | No | UNKNOWN | No |
| Magma Elemental | cooling obsidian crust | None — not in code | No | No | UNKNOWN | No |
| Frost Elemental | eternal ice sliver | None — not in code | No | No | UNKNOWN | No |

## Golems & Constructs (9)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Clay Golem | hardened damp clay | Wired — golem_mirrored.glb (mirror wired Nov 1; original untouched) | Yes | Mirrored file eyeballed — nice; in-game normalized golem not yet eyeballed | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 5+) |
| Gargoyle | weathered stone wing fragment | None — not in code | No | No | UNKNOWN | No |
| Living Statue | chiseled marble chunk | None — not in code | No | No | UNKNOWN | No |
| Haunted Armor | rusted steel pauldrons | None — not in code | No | No | UNKNOWN | No |
| Stone Golem | monolithic core stone | None — not wired (StoneGardenGolem recorded as alternate only) | No | No | UNKNOWN | No |
| Bone Golem | stitched skeletal armature | None — HELD (no matching type, static, missing .mtl; CC-BY election confirmed) | No | No | UNKNOWN | No |
| Brass Automaton | clockwork brass gear | None — not in code | No | No | UNKNOWN | No |
| Iron Golem | slagged iron plating | None — not in code | No | No | UNKNOWN | No |
| Crystal Golem | prismatic crystal shard | None — not in code | No | No | UNKNOWN | No |

Nov 4, 2026 addendum (wiring round): the 5 geometrically-differentiated golem variants are now wired as ROSTER rows (no TYPES entry, no spawn): golem-fire, golem-ice, golem-stone, golem-storm, golem-water (bestiary/golem-construct/), each painted with its Nov 2 variant 512 texture. Behaviors in design-notes/golem-variant-behaviors.md (Stone Golem base + elemental flavor; elemental variants flagged as Abysmal takes). The animated TYPES golem (Clay Golem, golem_mirrored.glb) is unchanged.

## Plants & Fungi (8)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Grotto Snapper | snapping floral jaw | None — not in code | No | No | UNKNOWN | No |
| Mandrake | shriek-rooted tuber | None — not in code | No | No | UNKNOWN | No |
| Vampire Vine | blood-sucking tendril | None — not in code | No | No | UNKNOWN | No |
| Fungal Shambler | spongy mycelium mass | None — not in code | No | No | UNKNOWN | No |
| Walking Oak | seasoned branch wood | None — not in code | No | No | UNKNOWN | No |
| Thornhound | briar-covered pelt | None — not in code | No | No | UNKNOWN | No |
| Spore Servant | toxic spore capsule | None — not in code | No | No | UNKNOWN | No |
| Corpse Flower | rotting nectar bloom | None — not in code | No | No | UNKNOWN | No |

## Aquatic & the Drowned Deep (6)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Cave Moray | electric eel skin | None — not in code | No | No | UNKNOWN | No |
| Drowned Sailor | waterlogged canvas scrap | None — not in code | No | No | UNKNOWN | No |
| Giant Octopus | flexible tentacle skin | None — not in code | No | No | UNKNOWN | No |
| Deep Crab | abyssal heavy shell | None — not in code | No | No | UNKNOWN | No |
| Lanternjaw | bioluminescent lure gland | None — not in code | No | No | UNKNOWN | No |
| World Wurm | trench-carved colossal scale | None — apex base only (Jörmungandr: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |

## Dragons & Great Serpents (10)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Drake | reptilian scale | Wired — Wyvern.glb (Gobkit) | Yes | No | Family pool mapped (TYPE_VOICE) | Yes — spawns (depth 8+) |
| Wyvern | barbed tail membrane | None — not in code | No | No | UNKNOWN | No |
| Cockatrice | petrifying beak fragment | None — not in code | No | No | UNKNOWN | No |
| Jaculus | winged serpent scale | None — not in code | No | No | UNKNOWN | No |
| Wyrm | subterranean wyrm scale | None — not in code | No | No | UNKNOWN | No |
| Basilisk | stony eye membrane | None — not in code | No | No | UNKNOWN | No |
| Amphiptere | feathered wing scale | None — not in code | No | No | UNKNOWN | No |
| Peluda | bristled green scale | None — not in code | No | No | UNKNOWN | No |
| Elder Wyrm | ancient layered scale plate | None — apex base only (Fafnir: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |
| Tarasque | impenetrable carapace plate | None — apex base only (The Tarasque: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |

## Humans & the Damned Living (11)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Brigand | worn leather boot | Roster-only model — enemy_bandit.glb (PS1), not wired | No | No | UNKNOWN | No — roster model only, no spawn |
| Grave Robber | soiled burlap sack | None — not in code | No | No | UNKNOWN | No |
| Cultist | tattered ceremonial robe | None — not in code | No | No | UNKNOWN | No |
| Witch | brewed herb pouch | None — apex base only (Baba Yaga: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |
| Berserker | war-painted hide scrap | None — not in code | No | No | UNKNOWN | No |
| Bandit Chief | ornate belt buckle | None — not in code | No | No | UNKNOWN | No |
| Mad Alchemist | shattered glass vial | None — not in code | No | No | UNKNOWN | No |
| Necromancer | skull-engraved talisman | None — not in code | No | No | UNKNOWN | No |
| Warlock | pact-bound parchment | None — not in code | No | No | UNKNOWN | No |
| Plague Bearer | disease-ridden rag | None — not in code | No | No | UNKNOWN | No |
| Fallen Knight | dented steel gauntlet | None — not in code | No | No | UNKNOWN | No |

## Sky & Storm (6)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Storm Crow | lightning-charged feather | None — not in code | No | No | UNKNOWN | No |
| Roc | colossal quill | None — not in code | No | No | UNKNOWN | No |
| Phoenix | eternal ash plume | None — not in code | No | No | UNKNOWN | No |
| Thunderbird | thunder-resonant tail feather | None — not in code | No | No | UNKNOWN | No |
| Simurgh | wisdom-infused plumage | None — not in code | No | No | UNKNOWN | No |
| Ziz | sky-shading wing down | None — not in code | No | No | UNKNOWN | No |

## The Abyssal & Cosmic (9)

| creature | materials | model status | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| Living Shadow | solid dark silhouette | None — not in code | No | No | UNKNOWN | No |
| Titan | primordial bedrock fragment | None — not in code | No | No | UNKNOWN | No |
| Void Horror | null-space membrane | None — not in code | No | No | UNKNOWN | No |
| Null Seraph | entropy-bleached halo feather | None — not in code | No | No | UNKNOWN | No |
| Entropy Wraith | decaying reality dust | None — not in code | No | No | UNKNOWN | No |
| Star Horror | meteorite chitin shard | None — not in code | No | No | UNKNOWN | No |
| The Hollow Choir | resonance-vocal membrane | None — not in code | No | No | UNKNOWN | No |
| Ashen Titan | burnt cosmic slag | None — not in code | No | No | UNKNOWN | No |
| Ur-Dragon | genesis-scale fragment | None — apex base only (Typhon: treatment documented, hook not activated) | No | No | Apex pool names only, no clips | No — apex hook not activated |

## Appendix A — Code types with no material-list row

| code type | display name | model | wired | visually reviewed | sounds | behavior live |
| --- | --- | --- | --- | --- | --- | --- |
| wolf | Cave Wolf | Wired — CityWolf_godot.glb | Yes | Eyeballed — held, “might be a pass if we cant find anymore”; no textures (one flat “dirt” material) | Family pool mapped | Yes — spawns (depth 3+) |
| ghost | Wraith | Wired — SheetGhost.glb (Gobkit) | Yes | No | Family pool mapped | Yes — spawns (depth 5+) |

## Appendix B — Apex bosses (16, treatments documented, hooks NOT activated)

| apex boss | base list row | model | hook | sounds |
| --- | --- | --- | --- | --- |
| Medusa | Gorgon | None — procedural only | Not activated | Pool names only, no clips |
| Typhon | Ur-Dragon | None — procedural only | Not activated | Pool names only, no clips |
| Echidna | Lamia | None — procedural only | Not activated | Pool names only, no clips |
| Fenrir | Great Wolf | None — procedural only | Not activated | Pool names only, no clips |
| Jörmungandr | World Wurm | None — procedural only | Not activated | Pool names only, no clips |
| Surtr | Fire Giant | None — procedural only | Not activated | Pool names only, no clips |
| Fafnir | Elder Wyrm | None — procedural only | Not activated | Pool names only, no clips |
| Baba Yaga | Witch | None — procedural only | Not activated | Pool names only, no clips |
| Koschei the Deathless | Lich | None — procedural only | Not activated | Pool names only, no clips |
| Humbaba | Cedar Guardian | None — procedural only | Not activated | Pool names only, no clips |
| Shuten-dōji | Oni | None — procedural only | Not activated | Pool names only, no clips |
| Yamata no Orochi | Hydra | None — procedural only | Not activated | Pool names only, no clips |
| Ravana | Rakshasa | None — procedural only | Not activated | Pool names only, no clips |
| Anzu | Anzu | None — procedural only | Not activated | Pool names only, no clips |
| The Tarasque | Tarasque | None — procedural only | Not activated | Pool names only, no clips |
| Cerberus | Hellhound | cerberus_v002_full.glb — VISUAL REVIEW PASSED Nov 1 (bones “a nice touch”); refinement notes queued: heavier retriever/husky build, sharper horns, Triple Bite stabbing side effect | Not activated | Pool names only, no clips |

Apex unique items (16, incl. Cerberus's Gatekeeper's Triune Helm) and the Crown of the Deep set bonus are proposal data only. Cerberus's depth-55 encounter hook is a proposal, documented-not-activated like the other 15.

## Appendix C — What “pending” means for the 7 families (v0.12.0 monster work)

- Ready to wire after review: wasp (Bee.glb on disk), zombie (Kenney model on disk; phase 2 survey also FOUND the LOWHO Horror Pack zombie, CC0 — both await visual review).
- Wired Nov 1 (phase 1): kobold (goblin.glb fallback stands unless a true kobold is found). Pick-a-stand-in: oni (FLARE Troll.glb; no true free CC oni found in the phase 2 survey).
- Must source: pixie, harpy, banshee (model + wail for banshee). Survey result: frog FOUND (Meshy Green FROG, CC0) — awaits visual review before wiring.

## Appendix D — Phase 2 survey (Nov 1, 2026): free-model sourcing for all non-wired rows

Paper survey only: no files modified, nothing wired, nothing bought or downloaded. Six survey passes covered every non-wired row (all 28 families). Verdicts: FOUND = a specific free CC0/CC-BY model identified with source + license (a lead, not an on-disk file, unless stated); STAND-IN = an existing on-disk project model that could plausibly stand in (recolors, rescaling, and instance reuse count as stand-ins, never as true models); NO MODEL FOUND = no suitable match after a genuine search across at least 3 distinct free sources (Quaternius, Kenney, Gobkit, Godot Asset Library, OpenGameArt, Sketchfab, itch.io free CC packs, 3DAssets.dev, Meshy CC0 gallery). KayKit excluded throughout (paid). One tally correction: the Orcs/Undead/Greek/Norse pass's summary line said 31 STAND-IN / 26 NO MODEL FOUND, but its own row lists give 35 / 22; the row lists rule and all totals below use them.

### Survey counts (deduplicated; Harpy appears in both the Greek and Sky tables and is counted once)

| Scope | FOUND | STAND-IN | NO MODEL FOUND | Total |
| --- | ---: | ---: | ---: | ---: |
| All non-wired rows surveyed | 13 | 217 | 51 | 281 |
| of which: 270 rows with no code presence | 11 | 211 | 48 | 270 |
| of which: 7 pending live-procedural types | 2 | 2 | 3 | 7 |
| of which: 3 roster-only models (not wired) | 0 | 3 | 0 | 3 |
| of which: 1 apex-linked only (Hellhound) | 0 | 1 | 0 | 1 |
| Wired rows (not surveyed) | — | — | — | 19 |

### Priority gaps (the 7 pending types)

| Creature | Survey verdict | Detail |
| --- | --- | --- |
| Cave Frog | FOUND | Meshy “Green FROG”, CC0, GLB (see FOUND table; static AI mesh, needs procedural hop + visual review) |
| Zombie | FOUND | LOWHO Horror Character Pack “Zombie”, CC0, FBX (see FOUND table; also on-disk Kenney zombie skins) |
| Cave Wasp | STAND-IN | `vermin/gobkit/Bee.glb` on disk, unwired; still awaits James's visual review |
| Oni | STAND-IN | FLARE `Troll.glb` on disk (horns absent); no true free CC oni found (see Blocked) |
| Pixie | NO MODEL FOUND | Hard search, no verified CC0/CC-BY 3D pixie; Gobkit “Sprite” still COMING SOON (watch item) |
| Harpy | NO MODEL FOUND (zip-blocked) | No free CC harpy anywhere searched; only unexamined lead is a Quaternius Greek/harpy-adjacent pack whose zip is not on disk |
| Banshee | NO MODEL FOUND | No wailing female ghost model in any free source searched; dedicated wail audio remains a separate gap |

### FOUND (13) — specific free models with verified licenses

| Creature | Model + source + license | Caveats |
| --- | --- | --- |
| Cave Frog | Meshy “Green FROG”, CC0, GLB/FBX/OBJ — https://www.meshy.ai/tags/amphibian | Gallery CC0 verified; individual model page not opened; AI-generated static mesh; free Meshy account to download; visual review + procedural hop needed |
| Zombie | LOWHO “Zombie”, Horror Character Pack, CC0, FBX (rigged, no animations) — https://standout7.itch.io/horror-character-pack | License verified on the page; second source after on-disk Kenney zombie skins |
| Specter | LOWHO “Ghost”, same pack, CC0, FBX | Generic ghost; fits the specter slot |
| Vampire | LOWHO “Vampire”, same pack, CC0, FBX (rigged, no animations) | License verified on the page |
| River Long | Low Poly Dragon by louieoliva, Sketchfab, CC-BY — https://sketchfab.com/3d-models/low-poly-dragon-91836e765d764e098a98a8069d64efc9 | Format/rig/animation not stated in page text; Sketchfab download needs an account |
| Giant Octopus | Meshy Amber Octopus, CC0, GLB confirmed — https://www.meshy.ai/posts/Amber-Octopus-019fbdea-6cd7-7cfa-bd29-78a3483edff6 | Static AI mesh; free account to download; rig review needed |
| Phoenix | Meshy Emberwing Phoenix, CC0, GLB — https://www.meshy.ai/3d-models/Emberwing-Phoenix-01a11b23-f66a-7475-9c6a-797d0f2e47bc | Static AI mesh; free account to download |
| Living Shadow | Meshy “shadow stalker”, CC0 — https://www.meshy.ai/posts/01998c8f-7933-731c-8b94-fda9fd267660 | Description-exact fit (darkness, smoke robes, glowing eyes); format gallery-wide GLB, not stated on the individual page; static AI mesh |
| Titan | Meshy Titan Sentinel, CC0 — https://www.meshy.ai/3d-models/Titan-Sentinel-01a171c8-b528-72e0-a87e-b7b18e15842c | Name match only; appearance unreviewed; static AI mesh |
| Void Horror | Meshy Void Sentinel, CC0 — https://www.meshy.ai/3d-models/Void-Sentinel-01a171ce-d0b7-7144-884c-59bcdc666877 | Name/theme match only; appearance unreviewed; static AI mesh |
| Entropy Wraith | Meshy Dark Wraith, CC0, GLB confirmed — https://www.meshy.ai/posts/019d8de8-2caa-7073-837c-e1fa2937822b | Static AI mesh; free account to download |
| Star Horror | Meshy star-darkness being, CC0 — https://www.meshy.ai/posts/0194e84a-4baa-792b-86a4-7b8ea54b362a | Format gallery-wide GLB, not stated on the individual page; static AI mesh |
| Ashen Titan | Meshy Ashen Sentinel, CC0 — https://www.meshy.ai/3d-models/Ashen-Sentinel-01a185a1-d5c0-7296-83c8-c0f223ba32a2 | Name match only; appearance unreviewed; static AI mesh |

All Meshy FOUNDs are AI-generated static meshes: none is a rigged, animated game model out of the box, and every Meshy download requires a free account.

### NO MODEL FOUND (51, deduplicated)

- Oozes/Vermin/Beasts: Burrow Worm, Carrion Worm, Crocodile, Pale Horse.
- Orcs/Undead/Greek/Norse: Ettin, Cyclops, Banshee, Jiangshi, Dullahan, Penanggalan, Satyr, Harpy, Centaur, Siren, Gorgon, Chimera, Sphinx, Manticore, Lamia, Empusa, Hydra, Nixie, Hulder, Mare, Fallen Valkyrie, Kraken.
- Egyptian/Yōkai/Celtic/Slavic/Mesopotamian: Scarab Swarm, Sha Beast, Devourer Beast, Karakasa, Chōchin-obake, Kelpie, Merrow, Selkie, Cat Sìth.
- South Asian/Chinese/Mesoamerican/African/Fey: Mami Wata, Pixie, Sprite, Naiad, Faun, Will-o'-wisp.
- Demons/Celestials/Elementals/Golems/Plants: Seraph, Ophanim, Ashen Seraph, Corpse Flower.
- Aquatic/Dragons/Humans/Sky/Abyssal: Cockatrice, Jaculus, Amphiptere, Tarasque, Null Seraph, The Hollow Choir.

Pattern: the hard gaps are hybrids whose defining anatomy is exactly what is missing (two heads, one eye, many heads, horse-human, serpent-woman, winged humanoid woman, six wings, wheel-of-eyes, aquatic humanoids, object-ghosts) plus creatures with no on-disk analogue at all (worms, crocodile, horse, seal, mermaid, wisp, flower).

### STAND-IN assignments (217) — on-disk model + fit note (part 1 of 2)

Oozes & Slimes (7, all via the wired Slime.fbx recolor): Cave Jelly (translucent), Amber Ooze (amber/resin), Mire Pudding (murky sediment), Acid Blob (corrosive-green), Gloom Ooze (dark umbral), Mercury Slime (metallic-silver), Primordial Ooze (raw protoplasm).

| Creature | On-disk stand-in | Fit note |
| --- | --- | --- |
| Rat Swarm | `vermin/evil-giant-rat/rat_full.glb` | Multi-instance swarm read |
| Cave Wasp | `vermin/gobkit/Bee.glb` | Unwired; still awaits visual review |
| Giant Rat | `vermin/evil-giant-rat/rat_full.glb` | True-species reuse |
| Vampire Bat | `vermin/vampire-bat-animated/bat_v5.glb` | Roster-only, animated, OGA CC0; wiring only |
| Widow Spider | `vermin/3dassets/CellarSpider_godot.glb` | True spider, darker recolor |
| Emperor Scorpion | `vermin/gobkit/Scorpion.glb` | True scorpion, scaled up |
| Stag Beetle | `vermin/gobkit/GiraffeStagBeetle.glb` | True stag beetle, Gobkit CC0 |
| Hornet Matriarch | `vermin/gobkit/Bee.glb` | Scaled up hymenopteran |
| Ōmukade | `vermin/gobkit-community/GeodeCentipede.glb` | Giant centipede, animated, strong fit |
| Wolf | `beasts/3dassets/CityWolf_godot.glb` | True wolf; flat “dirt” material, no textures |
| Hyena | `beasts/gobkit/Dingo.glb` | Canid proxy only; weakest beast fit |
| Grizzly | `beasts/gobkit-community/TrapBear.glb` | True bear |
| Dire Wolf | `beasts/3dassets/CityWolf_godot.glb` | Scaled up, winter recolor |
| Warhound | `beasts/3dassets/CityWolf_godot.glb` | Scarred war-dog recolor/scale |
| Cave Bear | `beasts/gobkit-community/TrapBear.glb` | True bear, cave-dark recolor |
| Razorback | `beasts/gobkit-community/IroncladBoar.glb` | Armored/bristled boar, near-exact |
| Panther | `beasts/gobkit/Tiger.glb` | Black recolor; stripes must be removed |
| Cave Python | `dragons/3dassets/CornSnake_godot.glb` | True snake, static, scaled up |
| Cave Ape | `beasts/gobkit-community/GeodeSilverback.glb` | Hulking primate |
| Baboon Troop | `beasts/gobkit-community/GeodeSilverback.glb` | Multi-instance troop read |
| Crag Ram | `beasts/gobkit/MerinoRam.glb` | True ram (Mouflon alternate) |
| Deep Stag | `beasts/gobkit/SkullDeer.glb` | Antlered deer |
| Grotto Bull | `beasts/gobkit/Bull.glb` | True bull |
| Blind Mole | `beasts/gobkit/Mole.glb` | Exact species |
| Lion | `beasts/gobkit/Lion.glb` | Exact species, Gobkit CC0 |
| Sabertooth | `beasts/gobkit/Tiger.glb` | Big cat; saber fangs absent |
| Tiger | `beasts/gobkit/Tiger.glb` | Exact species, Gobkit CC0 |
| Cave Hyena | `beasts/gobkit/Dingo.glb` | Canid proxy, spotted recolor |
| Goblin Sneak | `goblin-kin/3dassets/GoblinScavenger_godot.glb` | Small goblinoid, sneak read |
| Goblin Shaman | `goblin-kin/goblin/goblin.glb` | Same species, gear variant by dressing |
| Hobgoblin | `goblin-kin/goblin/goblin.glb` | Scaled up |
| Bugbear | `beasts/gobkit-community/GeodeSilverback.glb` | Hulking hairy brute |
| Boggart | `goblin-kin/3dassets/GoblinScavenger_godot.glb` | Small withered goblinoid |
| Redcap | `goblin-kin/goblin/goblin.glb` | Red cap/tint needed |
| Spriggan | `fey/gobkit-community/Treant.glb` | Gnarled wood-bark humanoid, strong fit |
| Gremlin | `goblin-kin/goblin/goblin.glb` | Scaled down |
| Púca | `undead/gobkit/WerewolfCaptain.glb` | Beast-man read; weakest fit in family |
| Goblin Champion | `goblin-kin/goblin/goblin.glb` | Scaled up veteran read |
| Orc Berserker | `OrcWarbandChampion.glb` (Gobkit) | Orc champion frame, battle-ready |
| Half-Ogre | `OrcChainBrute.glb` (Gobkit) | Large heavy brute, ogre-sized |
| Ogre | `Troll.glb` (wired Troll, reused) | Big club-wielding brute |
| Marsh Troll | `Troll.glb` (reused) | Swamp retexture needed |
| Orc Shaman | `OrcWarShaman.glb` (Gobkit) | Literally a war shaman |
| Cave Troll | `Troll.glb` (reused) | Stony retexture needed |
| Hill Giant | `GeodeSilverback.glb` | Large ape-like giant frame, scale up |
| Stone Giant | `StoneGardenGolem.glb` (3DAssets) | Stone body, giant scale |
| Frost Giant | `golem.glb` (ice variant) | Scale up, ice tint |
| Ogre Mage | `OrcPyromancer.glb` (Gobkit) | Large orc spellcaster frame |
| Fire Giant | `golem.glb` (fire variant) | Scale up, fire tint; apex Surtr separate |
| Skeleton Knight | `SkeletonOutlaw` FBX (KevDev, CC0 via OGA, staged) | Armored skeleton warrior |
| Ghoul | `StitchedBrute.glb` (Gobkit) | Stitched undead brute |
| Barrow Wight | `fgc_skeleton.glb` (OGA-staged, rigged) | Grave skeleton, dust/shroud retexture |
| Poltergeist | `SheetGhost.glb` (Gobkit, wired as Wraith) | Sheet ghost, volatile-spirit read |
| Draugr | `piratezombiemodel.glb` (OGA-staged) | Bloated corpse/ghost undead |
| Mummy | `TombMummy.glb` (Gobkit) | Wrapped tomb undead |
| Phantom | `SheetGhost.glb` (Gobkit) | Translucent shroud ghost |
| Strigoi | `VampireCountess.glb` (Gobkit) | Vampire noble, cursed-aristocrat read |
| Vetala | `StitchedBrute.glb` (Gobkit, reused) | Reanimated corpse body for a possessing spirit |
| Revenant | `enemy_revenant.glb` (PS1, roster-only) | Literally named revenant; wiring only |
| Sluagh | `SheetGhost.glb` (Gobkit, reused) | Single restless spirit; flock aspect lost |
| Wight Lord | `SkeletonOutlaw` FBX (reused) | Armored skeleton leader read |
| Lich | `NightWitch.glb` (Gobkit) | Robed spellcaster; skeletal retexture needed, weakest undead fit |
| Gashadokuro | `SkeletonWarrior.glb` (3DAssets) | Giant scale; no distinct giant-skeleton model |
| Hellhound | `cerberus_v002_full.glb` (apex Cerberus) | Hound frame; single-head trim needed for a true hellhound |
| Stymphalian Bird | `Eagle.glb` (Gobkit) | Bird of prey; bronze-tipped retexture |
| Bronze Bull | `Bull.glb` (Gobkit) | Bull frame; metallic retexture |
| Griffin | `ThunderBeakGryphon.glb` (Gobkit community) | Gryphon, direct fit |
| Nemean Lion | `Lion.glb` (Gobkit) | Lion frame; golden/invulnerable retexture |
| Sea Serpent | `EasternDragon.glb` (3DAssets) | Long serpentine body, sea retexture |
| Dark Elf (Dökkálfar) | `NightWitch.glb` (Gobkit) | Dark robed humanoid; pointed ears absent |
| Alfar Raider | Kenney `criminalMaleA` FBX (on disk) | Humanoid raider frame; modern-dress caveat |
| Great Wolf | `CityWolf.glb` (3DAssets, on disk) | Wolf frame, scale up; flat “dirt” material |
| Lindworm | `CornSnake.glb` (3DAssets) | Scaled up wingless serpent; legs absent |
| Asp | `enemy_cobracon.glb` (PS1) | Raised cobra, direct serpent fit |
| Jackal Guardian | `Dingo.glb` (Gobkit) | Wild jackal-like canid; embalmed aspect absent |
| Guardian Scorpion | `enemy_scorpion.glb` (PS1) | True scorpion; temple-carved aspect absent |
| Serpopard | `Tiger.glb` (Gobkit) | Spotted big-cat body; serpent neck absent |
| Falcon Sphinx | `ThunderBeakGryphon.glb` (Gobkit community) | Raptor head + quadruped body, closest sphinx read |
| Ushabti | `StoneGardenGolem.glb` (3DAssets) | Small statue-like stone humanoid, funerary figurine |
| Oni | FLARE `Troll.glb` (on disk, wired to Troll) | Large brute humanoid; horns absent |
| Bake-danuki | `Fox.glb` (Gobkit) | Canid body, tanuki-scale; raccoon markings absent |
| Kasha | `Tiger.glb` (Gobkit) | Large cat body; corpse-fire aspect absent |
| Kitsune | `Fox.glb` (Gobkit) | True fox body; multi-tail aspect absent (strongest in family) |
| Tengu | `daemon4.glb` (FLARE, roster-only) | Winged humanoid, crow-tengu frame |
| Yuki-onna | `NightWitch.glb` (Gobkit) | Female humanoid; kimono/pale-snow aspect absent |
| Jorōgumo | `CellarSpider_godot.glb` (3DAssets) | True spider body; woman aspect absent |
| Nure-onna | `enemy_cobracon.glb` (PS1) | Serpent body; woman aspect absent |
| Nue | `GeodeSilverback.glb` | Primate aspect of the monkey-headed chimera; tiger legs/snake tail absent |
| Tsuchigumo | `CellarSpider_godot.glb` (3DAssets) | True spider, earth-toned; strong fit |
| Bauchan | `goblin.glb` (OGA CC0) | Small goblinoid humanoid, direct type fit |
| Fachan | `goblin.glb` | Small humanoid; single eye/arm/leg absent |
| Afanc | `Shark.glb` (Gobkit) | Large aquatic predator, lake-beast read |
| Bean-nighe | `NightWitch.glb` (Gobkit) | Female spirit figure; stream-washing aspect absent |
| Domovoi | `goblin.glb` | Small hairy household humanoid |
| Kikimora | `NightWitch.glb` (Gobkit) | Female household-spirit figure |
| Rusalka | `NightWitch.glb` (Gobkit) | Female spirit figure; aquatic aspect absent |
| Vodyanoy | `snappa-kappa.glb` (CC-BY 4.0, wired to Kappa) | Frog/turtle-like water spirit, closest read |
| Striga | `VampireCountess.glb` (Gobkit) | Vampiric female figure, direct striga read |
| Leshy | `Treant.glb` (Gobkit community) | Tree humanoid, direct leshy read |
| Alkonost | `Eagle.glb` (Gobkit) | Large bird; woman aspect absent |
| Gamayun | `Owl.glb` (Gobkit) | Bird with wisdom/prophecy association; woman aspect absent |
| Mora | `SheetGhost.glb` (Gobkit) | Incorporeal spectral figure, night-mist spirit |
| Zmey | `Wyvern.glb` (Gobkit community, animated) | Winged dragon; multi-head aspect absent |
| Firebird | `Eagle.glb` (Gobkit) | Large bird; glow/ember aspect absent |
| Cedar Guardian | FLARE `Troll.glb` | Giant brute guardian, Humbaba's bulk |
| Galla | `daemon4.glb` (FLARE) | Underworld demon humanoid |
| Scorpion Man | `enemy_scorpion.glb` (PS1) | Scorpion aspect; human half absent |
| Ugallu | `Lion.glb` (Gobkit) | Lion body; storm/demon aspect absent |
| Lamassu | `Bull.glb` (Gobkit) | Bull body; wings and human head absent |
| Mušḫuššu | `EasternDragon_godot.glb` (3DAssets) | Serpentine dragon body |
| Anzu | `ThunderBeakGryphon.glb` (Gobkit community) | Large raptor-beast, storm-bird read |
| Asag | `StoneGardenGolem.glb` (3DAssets) | Stone humanoid, stone demon |

### STAND-IN assignments (part 2 of 2)

| Creature | On-disk stand-in | Fit note |
| --- | --- | --- |
| Naga | `enemy_cobracon.glb` (PS1) | Raised cobra; single head, not multi-headed |
| Yaksha | `Treant.glb` | Tree-guardian humanoid |
| Bhūta | `SheetGhost.glb` | Floating phantom spirit |
| Piśāca | `StitchedBrute.glb` | Ghoulish undead brute, flesh-eater read |
| Rakshasa | `daemon4.glb` | Horned demon humanoid (apex Ravana base only) |
| Makara | `Shark.glb` | Large aquatic predator; weakest fit here, no crocodilian on disk |
| Asura | `OrcWarbandChampion.glb` | Armored powerful humanoid warrior |
| Garuda | `ThunderBeakGryphon.glb` | Large winged raptor, sun-fire bird read (gryphon, not true Garuda) |
| Terracotta Soldier | `StoneGardenGolem.glb` | Stone statue humanoid, clay-soldier read |
| Mountain Yaoguai | `GeodeSilverback.glb` | Rocky large ape-beast, boulder-hide read |
| Xiezhi | `Bull.glb` | Horned quadruped (not single-horned specifically) |
| Hulijing | `Fox.glb` (Gobkit) | True fox form; nine-tailed/humanoid form absent |
| Mogwai | `minion-a01.glb` | Small mischievous blobby creature |
| Taotie | `Boar.glb` | Large gluttonous beast read |
| Hundun | `Slime.fbx` (Quaternius) | Amorphous faceless blob, chaos read; FBX import untested |
| Qilin, Corrupted | `SkullDeer.glb` | Antlered hooved quadruped; no scales/single horn, taint via tint only |
| Ahuizotl | `Dingo.glb` | Canine-sized beast; hand-tipped tail absent |
| Death Bat | `bat_v5.glb` (roster-only, animated) | Animated bat |
| Nagual | `WerewolfCaptain.glb` | Humanoid shapeshifter, beast-man read |
| Storm Wraith | `SheetGhost.glb` | Floating spirit |
| Tzitzimitl | `SkeletonWarrior_godot.glb` | Skeletal humanoid, stellar-skeletal read |
| Cipactli Brood | `Anglerfish.glb` | Primordial deep aquatic predator |
| Tokoloshe | `GoblinScavenger.glb` | Small humanoid trickster read |
| Adze | `Bee.glb` | Flying insect; firefly glow absent |
| Impundulu | `Eagle.glb` | Large raptor, lightning-bird read |
| Sasabonsam | `Troll.glb` | Large forest-giant humanoid |
| Inkanyamba | `CornSnake_godot.glb` | Large serpent, storm-serpent read |
| Bramble Imp | `FattyImp.glb` | Real small imp; bramble/thorns absent |
| Brownie | `minion-d01.glb` | Small household-sized creature |
| Dryad | `Treant.glb` | Tree humanoid |
| Sylph | `SheetGhost.glb` | Floating airy spirit |
| Changeling | `enemy_bandit.glb` (PS1) | Generic humanoid, glamour-faded cloth read |
| Elder Dryad | `AmberElderwood.glb` | Elder tree spirit, ancient-ironwood read |
| Possessed Cultist | Kenney `characterMedium.fbx` + humanMaleA skin (CC0) | Generic human male base; robe retexture needed, weak fit |
| Succubus | `VampireCountess.glb` (Gobkit) | Only female gothic humanoid on disk; wings unverified |
| Incubus | `daemon4.glb` (FLARE, animated) | True horned demon, male-presenting read |
| Pit Brute | `BrazenMinotaur.glb` (Gobkit community) | Big horned brute silhouette; scale up, brimstone recolor |
| Djinn | `SheetGhost.glb` (Gobkit) | Floating spirit; smoky-grey tint, opaque not translucent |
| Larva of the Damned | `AntlionLarva.glb` (Gobkit) | Small larval/grub read |
| Ifrit | `daemon4.glb` (shared with Incubus) | Horned demon + ember recolor |
| Marid | `Jellyfish.glb` (Gobkit) | Fluid water-spirit form; humanoid shape missing |
| Contract Devil | Kenney `characterMedium.fbx` + criminalMaleA skin (CC0) | Well-dressed deal-maker humanoid; horns missing, weak fit |
| Shaitan | `golem.glb`, stone variant | Heavy rocky humanoid, earth-djinn fit |
| Deva | Kenney `characterMedium.fbx` + human skin (CC0) | Radiant humanoid base; wings missing, weak fit |
| Watcher (Grigori) | Kenney `characterMedium.fbx` + human skin (CC0) | Human-form watcher read; wings missing, weak fit |
| Fallen Angel | `VampireCountess.glb` (shared with Succubus) | Dark gothic humanoid; wings/scorch unverified |
| Gnome | `goblin.glb` | Small humanoid, correct scale class; earthy recolor |
| Salamander | `CornSnake_godot.glb` | Reptilian fire-lizard proxy; legless (snake vs lizard) |
| Fire Elemental | `golem.glb`, fire variant | Animated humanoid flame construct; ember material needed |
| Water Elemental | `Jellyfish.glb` (shared with Marid) | Fluid water form; humanoid shape missing |
| Earth Elemental | `golem.glb`, stone variant | Rocky humanoid, animated |
| Air Elemental | `SheetGhost.glb` (shared with Djinn) | Wispy floating spirit; pale tint needed |
| Undine | `Jellyfish.glb` (shared) | Water-spirit form; humanoid shape missing |
| Storm Elemental | `SheetGhost.glb` (shared) | Storm-grey floating wisp; lightning VFX/tint required, weak fit |
| Magma Elemental | `golem.glb`, fire variant (shared) | Molten-rock humanoid; lava-crack material needed |
| Frost Elemental | `golem.glb`, ice variant | Crystalline ice humanoid |
| Gargoyle | `BelfryWyvern.glb` (Gobkit community) | Winged, belfry-associated; stone-grey recolor, dragon-head difference |
| Living Statue | `StoneGardenGolem.glb` (3DAssets, static, 896 tris) | Stone humanoid statue read |
| Haunted Armor | `OrcIronGuard.glb` (Gobkit) | Armored humanoid, helm hides face → empty-armor read; orc bulk |
| Stone Golem | `StoneGardenGolem.glb` (shared) | True stone-golem read; already the tracker's alternate for this row; static |
| Bone Golem | `Bone_Golem.obj` + PNG on disk (election file, still HELD) | ROSTERED Nov 2, 2026 via guide-built original (`bestiary/golem-construct/bone-golem.glb`); election file stays HELD (`.mtl` missing, license unconfirmed) |
| Brass Automaton | `OrcIronGuard.glb` (shared) | Metallic armored humanoid; brass recolor, gears missing |
| Iron Golem | `golem.glb` | Heavy construct bulk, animated; iron-grey recolor, no plating detail |
| Crystal Golem | `golem.glb`, ice variant | Crystalline look; ice ≠ prismatic crystal, material work needed |
| Grotto Snapper | `AntlionLarva.glb` (shared) | Jawed ambush predator; floral recolor needed, weak fit |
| Mandrake | `minion-a01.glb` (Gobkit) | Small blobby humanoid, right scale; root recolor needed, weak fit |
| Vampire Vine | `CornSnake_godot.glb` (shared) | Serpentine tendril mass; green/blood recolor, snake-vs-vine flag |
| Fungal Shambler | `enemy_myocene.glb` (PS1, CC0) | Fungus-adjacent per ledger; identity not visually verified by the surveyor |
| Walking Oak | `Treant.glb` (Gobkit community, animated + roar) | True-type walking tree; use only under the name Walking Oak, not “Treant” |
| Thornhound | `Dingo.glb` (Gobkit, animated) | Unwired canine (avoids duplicating wired CityWolf); briar/thorn overlay needed |
| Spore Servant | `minion-b01.glb` (Gobkit) | Small fungal servant proxy; spore recolor needed, weak fit |
| Cave Moray | `CornSnake_godot.glb` | Long serpentine body; snake, not eel |
| Drowned Sailor | `pirateverbiemodel.glb` (roster-only) | Undead sailor mesh, waterlogged read; flat materials |
| Deep Crab | `Scorpion.glb` | Pincered arthropod; it is a scorpion, not a crab |
| Lanternjaw | `Anglerfish.glb` (Gobkit) | Anglerfish with lure, near-true fit |
| World Wurm | `EasternDragon_godot.glb` | Long serpentine dragon, colossal sea-serpent read; apex Jörmungandr treatment only |
| Wyvern | `Wyvern.glb` (Gobkit community) | True wyvern on disk but already wired to Drake — duplicates Drake's model |
| Wyrm | `CornSnake_godot.glb` | True serpent, subterranean-wyrm read by scaling |
| Basilisk | `enemy_cobracon.glb` (PS1, CC0) | Raised cobra serpent, basilisk read |
| Peluda | `WesternDragon_godot.glb` | Generic dragon, green recolor in principle; bristles absent |
| Elder Wyrm | `EasternDragon_godot.glb` | Ancient serpentine dragon read; apex Fafnir treatment only |
| Brigand | `enemy_bandit.glb` (PS1, roster-only) | True bandit; static, texture re-link noted in registry |
| Grave Robber | Kenney `characterMedium.fbx` (CC0) | Generic human silhouette only, modern dress, no sack/props |
| Cultist | Kenney `characterMedium.fbx` (CC0) | Generic human only, no ceremonial robe |
| Witch | `NightWitch.glb` (Gobkit) | True witch on disk, not wired; closest dedicated match in family |
| Berserker | Kenney `characterMedium.fbx` (CC0) | Generic human warrior base only |
| Bandit Chief | `enemy_bandit.glb` (PS1, reused) | Bandit model reused at chief scale; no distinct chief model |
| Mad Alchemist | Kenney `characterMedium.fbx` (CC0) | Generic human only, no vials/lab gear |
| Necromancer | Kenney `characterMedium.fbx` (CC0) | Generic living human only, no robe, staff, or skull talisman |
| Warlock | `NightWitch.glb` (Gobkit) | Robed spellcaster silhouette; gender/role mismatch noted |
| Plague Bearer | Kenney zombie `characterMedium.fbx` (CC0) | Diseased, tattered humanoid read |
| Fallen Knight | `OrcIronGuard.glb` (Gobkit) | Armored living melee warrior; species mismatch (orc, not human); Gobkit Human Knight COMING SOON |
| Storm Crow | `Eagle.glb` (Gobkit) | Large dark bird flyer; crow size/species not matched |
| Roc | `Eagle.glb` (Gobkit) | Giant-bird read by colossal scaling only |
| Thunderbird | `ThunderBeakGryphon.glb` (Gobkit community) | Thunder-named avian; gryphon body mismatch, no lightning element |
| Simurgh | `Eagle.glb` (Gobkit) | Large mythic-bird read only |
| Ziz | `Eagle.glb` (Gobkit) | Sky-shading bird read by colossal scaling only |
| Ur-Dragon | `WesternDragon_godot.glb` | Generic dragon, genesis-dragon read by scale; apex Typhon treatment only |

### Blocked / could not determine

- **Quaternius/LOWPO zips not on disk (workspace search confirmed; on-disk Quaternius = only Slime/Bat/Skeleton FBX).** Harpy is the one explicitly zip-blocked row (only unexamined lead: a Quaternius Greek/harpy-adjacent pack). No other row's only lead is a zip, but a Quaternius clickthrough check by an eligible agent remains the one unclosed avenue for celestials especially. LOWPO's zip holds 3 goblins only (irrelevant beyond goblin variants).
- **Wasp/zombie visual reviews still outstanding** (Bee.glb, Kenney zombie on disk). Zombie now also has a LOWHO FOUND lead; both routes await James's eyeball before wiring.
- **Meshy/Sketchfab downloads need free accounts** (parent/browser step) for format, rig, and appearance verification — including the 8 Meshy FOUNDs (static AI meshes, rig review required) and the Sketchfab River Long dragon (format/rig unstated).
- **Bone Golem record conflict — RECONCILED Nov 2, 2026 (Wave 5):** the HELD marker now covers only the election-model directory (`resources-phase1/models/golems/bone-golem`, `.mtl` missing, license unconfirmed); the guide-built Bone Golem row is an original build and is rostered. The already-wired Clay Golem is unaffected.
- **Gobkit COMING SOON (re-check as they release):** Sprite (pixie namesake), Human Knight (Fallen Knight), Imp Fiend, Skeleton Warrior. Community wall beyond the first 24 items was not checked; a deeper-wall fairy cannot be ruled out.
- **OGA “50+ Monsters Pack 3D”, CC0, 56 static monsters** (https://opengameart.org/node/167827) — deliberately unnamed/numbered; no row can be claimed from it without inspecting the download contents. A download-inspection pass could still yield finds.
- **Unverified OGA collection listings** (not claimed): FLARE “Crocodile”, OGA “Rigged Horse”, OGA “FPS Character Worm” — best follow-ups for Burrow Worm, Carrion Worm, Crocodile, Pale Horse, along with a Meshy gallery search for worm/horse/crocodile.
- **Unverified leads, not FOUND:** itch.io “FREE Chibi Demon” (custom free license, raw-file redistribution banned — closest free demon body for Oni if the CC-only rule is ever relaxed); MZ4250 “Oni Updated” on Printables (STL print model, license unverified); nemo “Free – Fantasy Creatures Asset Pack” (page states no license, no 3D format; lists Fairy/Witch/Wizard/Knight/Vampire); Sketchfab CC browsing (account-gated, live-browser step) could still surface models; PS1 `enemy_myocene`/`enemy_cannae`/`helichard`/`janga` identities not visually verified by the surveyors.
- **Paid-only near-misses excluded:** Riclmbr Low Poly Animals Pack ($1.99, CC0 — would solve Crocodile + Pale Horse + frog/horse/bear variants); Grimsnout PSX orcs/goblins/ogre ($7.99, sampler license unverified); CGTrader centaur ($80); FactexLab packs ($89–$99); Cults/Tabletop STLs (personal-print licenses, not game licenses); DAZ/MyMiniFactory harpy figures (commercial/STL); “Oni Guardians of the Realm” ($99); KayKit (paid, excluded per task).
- **Jeff's kobold description still pending** (via James) — the true-kobold hunt continues behind the wired goblin.glb fallback; the survey found no true free CC kobold either.

## Appendix E — Pack leads (survey only, Nov 1, 2026)

New-source pack hunt beyond the phase 2 survey (which covered Quaternius, Kenney, OpenGameArt models, Sketchfab, itch.io free model packs, Meshy, Godot Asset Library). Nothing here was wired, bought, or downloaded. Licenses as stated on source pages; anything not verified is marked UNVERIFIED.

### Model packs

- **OGA "50+ Monsters Pack 3D" — VERIFIED CC0 (page-checked Nov 1).** 56 static monsters by isaiah658 (2 designs adapted from j0j0n4th4n, also CC0). Unrigged, no animations, palette textures, details via geometry, numbered not named (trademark reason), Minetest/Zoonami style. Format UNSTATED on the page — needs download inspection before any row can be claimed. Broadest generic coverage for the 51 NO MODEL rows, as static stand-ins only. https://opengameart.org/node/167827
- **nemo "Free – Fantasy Creatures Asset Pack" — UNVERIFIED (page-checked Nov 1: no license, no format stated).** Modular kit, 1.1 MB, creatures: Dwarf, Fairy, Ghost, Knight, Ogre, Skeleton, Vampire, Witch, Wizard, Zombie. Fairy is pixie-adjacent but 3D format is unconfirmed — do not count as a pixie lead until format + license are verified. https://nonemo.itch.io/fantasy-creatures-asset-pack
- **BlendSwap (NEW source) — per-model licenses; filter to CC0/CC-BY only (NC/SA/paid entries excluded).** Category pages: 179 creatures, 992 animals. CC0/CC-BY examples from listings: Forest Monster (CC0), Ogre (CC0), Two-Headed Hydra (CC0), Lizard Creature (CC0), Monster by koumis (CC0), Bigfoot (CC0), Bug monster abandonware (CC0); Dragon (CC-BY), Goblin (CC-BY), European Wasp Rigged (CC-BY — wasp alternative to Bee.glb), Hyena monster (CC-BY), Spider-Boss (CC-BY), Octavior the Octopus (CC-BY). Caveats: .blend files (export to GLB needed), old Blender versions (2.6–2.9), rig/animation varies per model. https://blendswap.com/3d/creatures
- **Gobkit free GitHub repo (same creator, new channel) — CC0, GLB, rigged + animated.** Minion Pack (8), Animal Pack (10: Anglerfish, Shark, Corgi, Bat, Duck, Hippo, …), Nature Kit (41 + scene, static). Check whether the Minion Pack differs from the reviewed a01–d01 minions before claiming anything new. https://github.com/ariescar/gobkit-free-assets/blob/HEAD/README.md
- **KayKit Character Pack: Adventurers (GitHub) — LICENSE CONFLICT, VERIFY BEFORE USE.** Repo claims CC0 (FBX + GLTF, 4 +2 characters, 75 animations, 25+ accessories), but this conflicts with the standing "KayKit paid" note. Contents are human adventurers — limited creature value (Brigand/knight rows at most). https://github.com/kaykit-game-assets/kaykit-character-pack-adventures-1.0/blob/HEAD/README.md
- **Quaternius Ultimate Monsters Pack (same-source follow-up, NOT a new source) — CC0, 50 animated monsters, FBX/OBJ/GLTF/Blend.** Contents unlisted in the doc snippet — harpy-adjacent types possible but NOT claimed. https://quaternius.com/packs/ultimatemonsters.html
- **Poly Pizza — discovery aggregator only (indexes Kenney + Quaternius), CC0 + CC-BY, REST API with free key.** Useful as a search index, not a new asset origin.

### Sound packs (the model survey barely touched sounds)

- **OGA "80 CC0 creature SFX" — CC0, 80 sounds** (alien 6, bug 4, grunt 5, monster 7, roar 3, scream 2, troll 3, cute 10, hurt 5, weird 5, …). https://Opengameart.org/content/80-cc0-creature-sfx
- **OGA "80 CC0 creture SFX #2" (rubberduck) — CC0, 80 sounds** (monster 13, roar 3, slime 8, bug 9, attack 5, die 4, grunt 4, human 8, misc 13, weird 4). https://opengameart.org/content/80-cc0-creture-sfx-2?destination=node%2F86875
- **OGA "Monster Sound Effects 2" (Ogrebane) — CC0, 17 WAV** (guttural, die, hit, attack, defend, idle). Note: Ogrebane and rubberduck are already in the project audio credits — check for duplicates before adding. https://opengameart.org/content/monster-sound-effects-2
- **OGA CC0 Sounds Library (LPC collection) — CC0**, incl. Ghost breath, Ghost Monster Voice Moaning & Growling, Monster or beast sounds, high pitch screams. https://lpc.opengameart.org/content/cc0-sounds-library
- **Assetsmith (itch store) — CC0 stated: 212 monster SFX** (growls, roars, screeches, ghoul moans, zombie groans, hisses, howls, WAV+OGG) **+ 763 fantasy RPG SFX (CC0) + 150 haunted-house SFX (CC0).** Strongest single vocal-pool source found. https://assetsmithpixels.itch.io
- **Signature Sounds "Monster Growls And Grunts SFX" — £0.00, CC0 stated.** Count unstated. https://signaturesounds.squarespace.com/
- **Freesound — per-file CC licenses (free registration to download).** CC0: CVLTIV8R creature/monster alien vocal FX (CC0 certificate exists for the author's part-2 file; confirm per-file badge). CC-BY 4.0: Artninja monster/snake/roar sounds (attribution required). Banshee: the "banshee" tag yields dedicated wail candidates — "Banshee Wail (distant)" by Dylan Kelk/SilverIllusionist (credit requested, CC-BY-consistent; per-file license MUST be confirmed on the file page) plus "banshee screaming" vocalizations. https://freesound.org/browse/tags/?f=tag:%22banshee%22
- **itch.io monsters + sound-effects tag page — browse target, per-item license verification required.** One CC0-stated item: "Goofy Sounds for Scary Monsters" (goofy tone caveat). https://itch.io/game-assets/tag-monsters/tag-sound-effects

### Near-misses (NOT CC0/CC-BY — need a rule call if ever used)

- Outta This World "Free Halloween Monster Sounds" (6 sounds incl. ghost wail, vampire hiss, bats, mummy moan, demon laugh): custom royalty-free, no attribution, no standalone redistribution.
- Halloween SFX Vol 1 free starter (5 sounds incl. Ghost Wail): custom license, optional attribution, no standalone resale/redistribution.
- Uppbeat banshee wailing: Uppbeat royalty-free, account-gated, not CC.

### Paid packs deliberately skipped (one line)

Unity Asset Store / Superhive / MonsterONE creature packs (e.g., Fantasy Enemy Pack $29.90, Low Poly Animated Fantasy Creatures, Fantasy 3D Models $99) and the paid Unity Monster Sound FX Pack 2 (a pirate mirror of it was found and is excluded outright).

### Gap coverage

- **Pixie:** no new lead (nemo Fairy unverified + format unknown; Gobkit Sprite COMING SOON remains the watch item).
- **Harpy:** no new lead (no free harpy in any new source; Quaternius Ultimate Monsters contents unlisted, not claimed).
- **Banshee (model):** no new lead. **Banshee (wail):** Freesound banshee tag (best); OGA ghost-adjacent CC0 (Ghost breath, Ghost Monster Voice); itch "Banshees and Growls" (license unverified).
- **Oni:** no true oni in new sources; closest stand-ins: BlendSwap Ogre (CC0), Gobkit minions/demons, FLARE Troll (from survey).
- **51 NO MODEL rows:** OGA 50+ (56 static, unnamed — broad generic coverage after inspection); BlendSwap individuals (hyena, wasp-alt, ogre, hydra, lizard, goblin, spider-boss, octopus, bigfoot); Gobkit Animal Pack (aquatic/animal rows); sound packs cover vocal gaps broadly via pools, not per-monster.

### Inventory — 4 packs downloaded and inspected on disk (Nov 1, 2026)

Staging: `~/workspace/build/pack-inventory/` (gobkit, oga50, oga80a, oga80b). Nothing wired; inventory only.

#### 1. Gobkit free GitHub repo (CC0, GLB, 70 files, 2.9 MB)

- **Minion Pack (8):** minion-a01/a02/b01/b02/c01/c02/d01/d02 — SAME 4 body types as the already-reviewed a01–d01 (identical node structure: body01–04, Root, Hips, Head, RightArm, LeftArm; 1 baked "movement" track, vs 3 animations in the on-disk exports). The 02 files are second variants of the same 4 bodies (near-identical sizes; b02 differs from b01 only in file bytes, not structure). Verdict: the a01–d01 REJECTION (floating-heads-with-hands look, ears vanish from the back) almost certainly still applies — same characters, new export. The 02 variants need James's eyeball before any reconsideration; do not wire on the assumption they differ.
- **Animal Pack (10, GLB, 1 baked track each, idle/attack/dead/walk ranges):** Anglerfish, Bat, Corgi, Duck, Hippo, Jellyfish, Platypus, Red (species unclear from filename — likely Red Panda, appearance unverified), Rhino, Shark + Texture001.png. Coverage: Bat duplicates an already-covered row; the other 9 species have NO matching bestiary row — value is as future/variant creatures or weak proxies (Shark/Rhino/Hippo as large-beast proxies), not as 51-row coverage.
- **Nature Kit (41 + scene, static GLB):** Bush 2, Cliff 3, Cloud 3, Grass 3, Hill 3, HillSand 3, Mountain 3, MountainFar 3, Reed 2, Rock 3, Stalactite 3, TreeHigh 3, TreeLow 4, TreeMed 3 + nature-kit-scene.glb. Not creatures — dungeon/zone dressing (Stalactites especially fit cave themes; trees/rocks fit Forest zones).

#### 2. OGA 50+ Monsters Pack 3D (CC0, 286 files, 4.9 MB)

- **56 models, all .obj, static, unrigged, no animations.** Verts 158–1119 (avg 458). All 56 have UVs; only 3 reference an .mtl — the rest rely on palette textures: 56 Normal Color palettes + 56 Alternative Color palettes (recolor variants = variant fodder). Conversion to GLB via Blender is required before any wiring; style is blocky Minetest-grade, so these are stand-ins, not 1K-realistic-anchored models.
- **All 56 identified from Front + Side previews** (numbered, not named): #1 armored knight, #2 robot drone, #3 plant sprout, #4 crystal blob, #5 long-neck dino, #6 bee/wasp, #7 leaf insect, #8 ice blob, #9 winged sword spirit, #10 hatching chick, #11 pink worm, #12 crab, #13 spider, #14 bat, #15 moth, #16 mole/mouse, #17 leaf sprite, #18 boar, #19 white biped, #20 spiky blob, #21 turtle, #22 sheet ghost, #23 clawed beast, #24 owl, #25 pufferfish, #26 flute-snake, #27 swordfish, #28 tentacle creature, #29 boxing rabbit, #30 fish orb, #31 robot crab, #32 blob mouse, #33 living armor, #34 raptor, #35 round arm-beast, #36 mushroom beast, #37 potted plant, #38 fruit creature, #39 land shark, #40 seal, #41 golem, #42 crocodile (FULL body confirmed in side view), #43 dino, #44 horned quadruped, #45 hooded wisp, #46 wizard, #47 elephant/mollusc, #48 fox, #49 white bird, #50 plant walker, #51 owl-bird, #52 blob, #53 spider, #54 ant, #55 island turtle, #56 chick blob.
- **Coverage of the 51 NO MODEL rows — STRONG (2):** #11 pink worm → Burrow Worm / Carrion Worm; #42 crocodile → Crocodile (full body confirmed).
- **Coverage — WEAK (stand-in only, needs James's eyeball):** #9 winged sword spirit → Seraph / Fallen Valkyrie; #17 leaf sprite → Sprite (weak for Pixie); #22 sheet ghost → Banshee (genderless sheet, not a wailing female ghost); #28 tentacle creature → Kraken (small, not colossal); #40 seal → Selkie (animal form only); #45 hooded figure → Will-o'-wisp (a figure, not a light); #50 plant walker → Corpse Flower (plant, not flower); #54 ant → Scarab Swarm (insect, multi-instance read); #21/#55 turtles → Tarasque (weak); #49 white bird → Cockatrice (very weak, no dragon features).
- **Pending families:** #6 bee/wasp is a true-wasp alternative to Bee.glb for Cave Wasp (still needs James's eyeball); NO frog, zombie, kobold, harpy, or oni in this pack. Pixie: #17 is the only new lead and it is weak.
- **Everything else** (knight, robots, dino, crab, moth, owl, fish, rabbit, raptor, mushroom, fruit, shark, fox, wizard, elephant, bird, ant, blobs) has no matching 51-row — usable as generic dungeon creatures or variant fodder only.

#### 3. OGA 80 CC0 creature SFX (CC0, 80 .ogg, 2.2 MB)

alien 6, barking 2, breath 1, bug 4, burble 2, burp 2, cough 3, cute 10, eat 4, grunt 5, howl 1, hurt 5, misc 9, monster 7, nose 1, ooh 1, roar 3, scream 2, snore 1, spit 3, troll 3, weird 5. No readme/license file in the zip (CC0 per the OGA page).

#### 4. OGA 80 CC0 creature SFX #2, rubberduck (CC0, 80 .ogg, 2.1 MB)

alien 6, attack 5, breath 1, bug 9, die 4, grunt 4, human 8, misc 13, monster 13, roar 3, slime 8, snore 1, stomp 1, weird 4. No readme/license file in the zip (CC0 per the OGA page).

#### Sound duplicates check

- **Zero filename collisions** with the project's existing audio (160 new .ogg filenames, none already present).
- **Caution, not a duplicate:** Ogrebane and rubberduck are already credited in the project audio — meaning SOME of their sounds are already in the project from other packs. These two 80-packs are new files on disk, but the vocal pools should be checked for near-duplicate CONTENT (same roar under a different name) before wiring. No dedicated banshee wail in either pack (scream 2 + roar/growl categories only — the Freesound banshee-tag lead remains the wail candidate).

#### Needs James's eyeball before wiring

- OGA #11 worm, #42 crocodile (strong candidates, still need his look).
- OGA weak candidates (#9, #17, #22, #28, #40, #45, #50, #54) — only if he accepts the fit.
- Gobkit minion 02 variants (same characters as the rejected a01–d01 until proven otherwise).
- Gobkit "Red" species identity (likely Red Panda, unverified).
- OGA #6 wasp vs Bee.glb for Cave Wasp (both await his review).
