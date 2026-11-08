# Abysmal — Model Guide Library (Index)

Docs only: this library tells a builder how to procedurally build
a creature model in Blender. It does not wire anything into the game.

## How a builder uses this

1. Search the creature's name in this index (or in the full mapping below).
2. Open that archetype's guide file and follow it step by step in Blender.
   Before export, select all meshes and set Shade Smooth (right-click >
   Shade Smooth) — without it, spheres render faceted.
3. Apply the per-creature tweaks listed for the priority rows (or invent
   fitting tweaks for a non-priority row, and record them here).
4. Export a GLB: Y-up, grounded (lowest point at y=0 in Godot, i.e. min Z = 0
   in Blender), target size ~1.0 m tall unless the row says otherwise,
   textures treated to the 1K realistic anchor.
5. Hand the GLB to the wiring step (visual review first — nothing here is
   pre-approved for the game).

## Archetype guides

- **blob-ooze** — `blob-ooze.md` (9 rows)
- **worm-serpent** — `worm-serpent.md` (23 rows)
- **quadruped-beast** — `quadruped-beast.md` (51 rows)
- **biped-humanoid** — `biped-humanoid.md` (117 rows)
- **winged** — `winged.md` (34 rows)
- **spider-arachnid** — `spider-arachnid.md` (14 rows)
- **aquatic** — `aquatic.md` (13 rows)
- **plant-fungal** — `plant-fungal.md` (11 rows)
- **ghost-wisp** — `ghost-wisp.md` (15 rows)
- **golem-construct** — `golem-construct.md` (13 rows)

## Pass 1 priority rows (55 unique: 51 NO MODEL FOUND + 7 pending families,
3 overlap: Pixie, Harpy, Banshee)

These rows have per-creature tweaks. Build these first.

| creature | family | archetype | guide | tweaks |
| --- | --- | --- | --- | --- |
| Burrow Worm | Vermin & Cave Crawlers | worm-serpent | worm-serpent.md | Long segmented pink worm, burrowing S-pose, no limbs. |
| Carrion Worm | Vermin & Cave Crawlers | worm-serpent | worm-serpent.md | As Burrow Worm, putrid coloring, ichor sheen. |
| Crocodile | Beasts | quadruped-beast | quadruped-beast.md | Low-slung armored quadruped, long jaw, heavy tail. |
| Pale Horse | Beasts | quadruped-beast | quadruped-beast.md | Gaunt pale horse, no rider, hollow eyes. |
| Ettin | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md | Giant biped, two heads side by side. |
| Cyclops | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md | Giant biped, single central eye. |
| Banshee (also Celtic & British Isles) | The Undead | ghost-wisp | ghost-wisp.md | Wailing female ghost, flowing hair and robes, translucent (see ghost guide). |
| Jiangshi (also Chinese & East Asian) | The Undead | biped-humanoid | biped-humanoid.md | Stiff hopping undead, arms thrust forward, official's robes + talisman. |
| Dullahan (also Celtic & British Isles) | The Undead | biped-humanoid | biped-humanoid.md | Headless biped in dark cloak, holding its own head in one hand (on foot; mounted variant later). |
| Penanggalan | The Undead | ghost-wisp | ghost-wisp.md | Flying head with trailing entrails, no body. |
| Satyr | Greek & Mediterranean Myth | biped-humanoid | biped-humanoid.md | Biped, goat legs + horns, human torso. |
| Harpy (also Sky & Storm) | Greek & Mediterranean Myth | winged | winged.md | Winged, woman torso + large bird wings + taloned legs. |
| Centaur | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md | Quadruped horse body + human torso. |
| Siren | Greek & Mediterranean Myth | winged | winged.md | Winged, woman torso + bird wings (Greek form; aquatic variant is a different guide note). |
| Gorgon | Greek & Mediterranean Myth | biped-humanoid | biped-humanoid.md | Biped, woman with serpent hair, scaled skin. |
| Chimera | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md | Quadruped, lion body, goat head + serpent tail-head. |
| Sphinx | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md | Quadruped, lion body, human head, wings optional. |
| Manticore | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md | Quadruped, lion body, human face, scorpion tail. |
| Lamia | Greek & Mediterranean Myth | worm-serpent | worm-serpent.md | Serpent body + woman torso. |
| Empusa | Greek & Mediterranean Myth | biped-humanoid | biped-humanoid.md | Biped, demon woman, mismatched legs (one bronze, one donkey). |
| Hydra (also Dragons & Great Serpents) | Greek & Mediterranean Myth | worm-serpent | worm-serpent.md | Multi-headed serpent, 5+ heads on long necks. |
| Nixie | Norse & Germanic | aquatic | aquatic.md | Aquatic, water-spirit woman, reed/water hair. |
| Hulder | Norse & Germanic | biped-humanoid | biped-humanoid.md | Biped, forest woman, hollow back, cow tail. |
| Mare | Norse & Germanic | ghost-wisp | ghost-wisp.md | Ghost/wisp, nightmare spirit woman, shadowy, crouching pose. |
| Fallen Valkyrie (also Celestials & the Fallen) | Norse & Germanic | winged | winged.md | Winged, armored woman, tarnished wings. |
| Kraken (also Aquatic & the Drowned Deep) | Norse & Germanic | aquatic | aquatic.md | Aquatic, colossal tentacled mass (build at reduced scale; tentacles = tapered cylinders). |
| Scarab Swarm | Egyptian & Near East | spider-arachnid | spider-arachnid.md | Arachnid, multi-instance: build ONE scarab; the game spawns many. |
| Sha Beast | Egyptian & Near East | quadruped-beast | quadruped-beast.md | Quadruped, dog-like, square ears, forked tail. |
| Devourer Beast | Egyptian & Near East | quadruped-beast | quadruped-beast.md | Quadruped, large beast, gaping maw. |
| Karakasa | Japanese Yōkai | golem-construct | golem-construct.md | Construct, animated umbrella: one eye, one leg, hopping pose. |
| Chōchin-obake | Japanese Yōkai | ghost-wisp | ghost-wisp.md | Ghost/wisp, floating paper lantern with a face. |
| Kelpie (also Aquatic & the Drowned Deep) | Celtic & British Isles | aquatic | aquatic.md | Aquatic, water horse, dark coat, mane of reeds. |
| Merrow (also Aquatic & the Drowned Deep) | Celtic & British Isles | aquatic | aquatic.md | Aquatic, merfolk with cap/hood. |
| Selkie | Celtic & British Isles | aquatic | aquatic.md | Aquatic, seal form (build the seal; human form is a later note). |
| Cat Sìth | Celtic & British Isles | quadruped-beast | quadruped-beast.md | Quadruped, large black cat, white chest spot. |
| Mami Wata | African Traditions | aquatic | aquatic.md | Aquatic, mermaid; snake companion optional. |
| Pixie | Fey & Nature Spirits | winged | winged.md | Winged, tiny fey, dragonfly wings, small scale (~0.3). |
| Sprite | Fey & Nature Spirits | winged | winged.md | Winged, tiny leaf sprite (distinct from Pixie: leafy, green). |
| Naiad | Fey & Nature Spirits | aquatic | aquatic.md | Aquatic, freshwater nymph, flowing water hair. |
| Faun | Fey & Nature Spirits | biped-humanoid | biped-humanoid.md | Biped, goat legs + horns, smaller and slighter than a satyr. |
| Will-o'-wisp | Fey & Nature Spirits | ghost-wisp | ghost-wisp.md | Ghost/wisp, floating light orb + wispy tail, no body. |
| Seraph | Celestials & the Fallen | winged | winged.md | Winged, six wings, radiant. |
| Ophanim | Celestials & the Fallen | golem-construct | golem-construct.md | Construct, spinning wheel ringed with eyes. |
| Ashen Seraph | Celestials & the Fallen | winged | winged.md | Winged, six wings, ashen/grey coloring. |
| Corpse Flower | Plants & Fungi | plant-fungal | plant-fungal.md | Plant/fungal, giant carrion flower, open bloom + stench petals. |
| Cockatrice | Dragons & Great Serpents | winged | winged.md | Winged, small dragon-bird: rooster head + serpent tail. |
| Jaculus | Dragons & Great Serpents | worm-serpent | worm-serpent.md | Serpent, small javelin snake in a launching pose (wings optional). |
| Amphiptere | Dragons & Great Serpents | worm-serpent | worm-serpent.md | Serpent, winged serpent with feathered wings, no legs. |
| Tarasque | Dragons & Great Serpents | quadruped-beast | quadruped-beast.md | Quadruped, turtle shell + dragon/lion head + back spikes. |
| Null Seraph | The Abyssal & Cosmic | winged | winged.md | Winged, dark six-winged seraph, void coloring. |
| The Hollow Choir | The Abyssal & Cosmic | ghost-wisp | ghost-wisp.md | Ghost/wisp, abstract: cluster of hollow wisps/faces (no single body). |
| Cave Frog | Vermin & Cave Crawlers | aquatic | aquatic.md | Aquatic, squat frog, big hind legs, procedural hop motion. |
| Zombie | The Undead | biped-humanoid | biped-humanoid.md | Biped, shambling undead, rotting, arms forward. |
| Cave Wasp | Vermin & Cave Crawlers | winged | winged.md | Winged, wasp with stinger, striped abdomen. |
| Oni | Japanese Yōkai | biped-humanoid | biped-humanoid.md | Biped, large ogre, horns, iron club optional. |

## Full mapping (all 300 rows)

Rows outside the priority set point at their archetype guide without
per-creature detail; add tweaks here as guides are written for them.

| creature | family | archetype | guide |
| --- | --- | --- | --- |
| Slime | Oozes & Slimes | blob-ooze | blob-ooze.md |
| Cave Jelly | Oozes & Slimes | blob-ooze | blob-ooze.md |
| Amber Ooze | Oozes & Slimes | blob-ooze | blob-ooze.md |
| Mire Pudding | Oozes & Slimes | blob-ooze | blob-ooze.md |
| Acid Blob | Oozes & Slimes | blob-ooze | blob-ooze.md |
| Gloom Ooze | Oozes & Slimes | blob-ooze | blob-ooze.md |
| Mercury Slime | Oozes & Slimes | blob-ooze | blob-ooze.md |
| Primordial Ooze | Oozes & Slimes | blob-ooze | blob-ooze.md |
| Cave Rat | Vermin & Cave Crawlers | quadruped-beast | quadruped-beast.md |
| Rat Swarm | Vermin & Cave Crawlers | spider-arachnid | spider-arachnid.md |
| Cave Bat | Vermin & Cave Crawlers | winged | winged.md |
| Cave Spider | Vermin & Cave Crawlers | spider-arachnid | spider-arachnid.md |
| Cave Wasp | Vermin & Cave Crawlers | winged | winged.md |
| Cave Scorpion | Vermin & Cave Crawlers | spider-arachnid | spider-arachnid.md |
| Centipede | Vermin & Cave Crawlers | spider-arachnid | spider-arachnid.md |
| Cave Frog | Vermin & Cave Crawlers | aquatic | aquatic.md |
| Giant Rat | Vermin & Cave Crawlers | quadruped-beast | quadruped-beast.md |
| Vampire Bat | Vermin & Cave Crawlers | winged | winged.md |
| Widow Spider | Vermin & Cave Crawlers | spider-arachnid | spider-arachnid.md |
| Emperor Scorpion | Vermin & Cave Crawlers | spider-arachnid | spider-arachnid.md |
| Stag Beetle | Vermin & Cave Crawlers | spider-arachnid | spider-arachnid.md |
| Burrow Worm | Vermin & Cave Crawlers | worm-serpent | worm-serpent.md |
| Carrion Worm | Vermin & Cave Crawlers | worm-serpent | worm-serpent.md |
| Hornet Matriarch | Vermin & Cave Crawlers | winged | winged.md |
| Ōmukade (also Japanese Yōkai) | Vermin & Cave Crawlers | spider-arachnid | spider-arachnid.md |
| Wolf | Beasts | quadruped-beast | quadruped-beast.md |
| Wild Boar | Beasts | quadruped-beast | quadruped-beast.md |
| Hyena | Beasts | quadruped-beast | quadruped-beast.md |
| Giant Serpent | Beasts | worm-serpent | worm-serpent.md |
| Grizzly | Beasts | quadruped-beast | quadruped-beast.md |
| Dire Wolf | Beasts | quadruped-beast | quadruped-beast.md |
| Warhound | Beasts | quadruped-beast | quadruped-beast.md |
| Cave Bear | Beasts | quadruped-beast | quadruped-beast.md |
| Razorback | Beasts | quadruped-beast | quadruped-beast.md |
| Panther | Beasts | quadruped-beast | quadruped-beast.md |
| Cave Python | Beasts | worm-serpent | worm-serpent.md |
| Cave Ape | Beasts | quadruped-beast | quadruped-beast.md |
| Baboon Troop | Beasts | quadruped-beast | quadruped-beast.md |
| Crag Ram | Beasts | quadruped-beast | quadruped-beast.md |
| Deep Stag | Beasts | quadruped-beast | quadruped-beast.md |
| Grotto Bull | Beasts | quadruped-beast | quadruped-beast.md |
| Blind Mole | Beasts | quadruped-beast | quadruped-beast.md |
| Crocodile | Beasts | quadruped-beast | quadruped-beast.md |
| Lion | Beasts | quadruped-beast | quadruped-beast.md |
| Sabertooth | Beasts | quadruped-beast | quadruped-beast.md |
| Tiger | Beasts | quadruped-beast | quadruped-beast.md |
| Cave Hyena | Beasts | quadruped-beast | quadruped-beast.md |
| Pale Horse | Beasts | quadruped-beast | quadruped-beast.md |
| Kobold | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Goblin | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Goblin Sneak | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Goblin Shaman | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Hobgoblin | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Bugbear | Goblin-Kin & Cave Folk | quadruped-beast | quadruped-beast.md |
| Boggart | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Redcap (also Celtic & British Isles) | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Spriggan (also Celtic & British Isles) | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Gremlin | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Púca (also Celtic & British Isles) | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Goblin Champion | Goblin-Kin & Cave Folk | biped-humanoid | biped-humanoid.md |
| Orc | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Orc Berserker | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Half-Ogre | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Ogre | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Marsh Troll | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Troll | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Orc Shaman | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Cave Troll | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Ettin | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Cyclops | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Hill Giant | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Stone Giant | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Frost Giant (also Norse & Germanic) | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Ogre Mage | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Fire Giant (also Norse & Germanic) | Orcs, Trolls & Giant-Kin | biped-humanoid | biped-humanoid.md |
| Skeleton | The Undead | biped-humanoid | biped-humanoid.md |
| Skeleton Archer | The Undead | biped-humanoid | biped-humanoid.md |
| Zombie | The Undead | biped-humanoid | biped-humanoid.md |
| Skeleton Knight | The Undead | biped-humanoid | biped-humanoid.md |
| Ghoul (also Demons, Devils & the Damned) | The Undead | biped-humanoid | biped-humanoid.md |
| Barrow Wight | The Undead | biped-humanoid | biped-humanoid.md |
| Specter | The Undead | ghost-wisp | ghost-wisp.md |
| Poltergeist | The Undead | ghost-wisp | ghost-wisp.md |
| Draugr (also Norse & Germanic) | The Undead | biped-humanoid | biped-humanoid.md |
| Mummy (also Egyptian & Near East) | The Undead | biped-humanoid | biped-humanoid.md |
| Phantom | The Undead | ghost-wisp | ghost-wisp.md |
| Banshee (also Celtic & British Isles) | The Undead | ghost-wisp | ghost-wisp.md |
| Vampire | The Undead | biped-humanoid | biped-humanoid.md |
| Strigoi | The Undead | biped-humanoid | biped-humanoid.md |
| Jiangshi (also Chinese & East Asian) | The Undead | biped-humanoid | biped-humanoid.md |
| Vetala (also South Asian) | The Undead | biped-humanoid | biped-humanoid.md |
| Revenant | The Undead | biped-humanoid | biped-humanoid.md |
| Sluagh (also Celtic & British Isles) | The Undead | ghost-wisp | ghost-wisp.md |
| Wight Lord | The Undead | biped-humanoid | biped-humanoid.md |
| Lich | The Undead | biped-humanoid | biped-humanoid.md |
| Dullahan (also Celtic & British Isles) | The Undead | biped-humanoid | biped-humanoid.md |
| Gashadokuro (also Japanese Yōkai) | The Undead | biped-humanoid | biped-humanoid.md |
| Penanggalan | The Undead | ghost-wisp | ghost-wisp.md |
| Satyr | Greek & Mediterranean Myth | biped-humanoid | biped-humanoid.md |
| Harpy (also Sky & Storm) | Greek & Mediterranean Myth | winged | winged.md |
| Centaur | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md |
| Siren | Greek & Mediterranean Myth | winged | winged.md |
| Hellhound (also Demons, Devils & the Damned) | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md |
| Minotaur | Greek & Mediterranean Myth | biped-humanoid | biped-humanoid.md |
| Stymphalian Bird (also Sky & Storm) | Greek & Mediterranean Myth | winged | winged.md |
| Bronze Bull | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md |
| Gorgon | Greek & Mediterranean Myth | biped-humanoid | biped-humanoid.md |
| Chimera | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md |
| Sphinx | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md |
| Griffin (also Sky & Storm) | Greek & Mediterranean Myth | winged | winged.md |
| Manticore | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md |
| Lamia | Greek & Mediterranean Myth | worm-serpent | worm-serpent.md |
| Empusa | Greek & Mediterranean Myth | biped-humanoid | biped-humanoid.md |
| Nemean Lion | Greek & Mediterranean Myth | quadruped-beast | quadruped-beast.md |
| Hydra (also Dragons & Great Serpents) | Greek & Mediterranean Myth | worm-serpent | worm-serpent.md |
| Sea Serpent | Norse & Germanic | worm-serpent | worm-serpent.md |
| Nixie | Norse & Germanic | aquatic | aquatic.md |
| Hulder | Norse & Germanic | biped-humanoid | biped-humanoid.md |
| Mare | Norse & Germanic | ghost-wisp | ghost-wisp.md |
| Dark Elf (Dökkálfar) | Norse & Germanic | biped-humanoid | biped-humanoid.md |
| Alfar Raider | Norse & Germanic | biped-humanoid | biped-humanoid.md |
| Fallen Valkyrie (also Celestials & the Fallen) | Norse & Germanic | winged | winged.md |
| Great Wolf | Norse & Germanic | quadruped-beast | quadruped-beast.md |
| Lindworm (also Dragons & Great Serpents) | Norse & Germanic | worm-serpent | worm-serpent.md |
| Kraken (also Aquatic & the Drowned Deep) | Norse & Germanic | aquatic | aquatic.md |
| Scarab Swarm | Egyptian & Near East | spider-arachnid | spider-arachnid.md |
| Asp | Egyptian & Near East | worm-serpent | worm-serpent.md |
| Jackal Guardian | Egyptian & Near East | quadruped-beast | quadruped-beast.md |
| Guardian Scorpion | Egyptian & Near East | spider-arachnid | spider-arachnid.md |
| Serpopard | Egyptian & Near East | worm-serpent | worm-serpent.md |
| Sha Beast | Egyptian & Near East | quadruped-beast | quadruped-beast.md |
| Falcon Sphinx | Egyptian & Near East | quadruped-beast | quadruped-beast.md |
| Devourer Beast | Egyptian & Near East | quadruped-beast | quadruped-beast.md |
| Ushabti (also Golems & Constructs) | Egyptian & Near East | golem-construct | golem-construct.md |
| Karakasa | Japanese Yōkai | golem-construct | golem-construct.md |
| Chōchin-obake | Japanese Yōkai | ghost-wisp | ghost-wisp.md |
| Kappa | Japanese Yōkai | biped-humanoid | biped-humanoid.md |
| Oni | Japanese Yōkai | biped-humanoid | biped-humanoid.md |
| Bake-danuki | Japanese Yōkai | quadruped-beast | quadruped-beast.md |
| Kasha | Japanese Yōkai | quadruped-beast | quadruped-beast.md |
| Kitsune | Japanese Yōkai | quadruped-beast | quadruped-beast.md |
| Tengu | Japanese Yōkai | winged | winged.md |
| Yuki-onna | Japanese Yōkai | biped-humanoid | biped-humanoid.md |
| Jorōgumo | Japanese Yōkai | spider-arachnid | spider-arachnid.md |
| Nure-onna | Japanese Yōkai | worm-serpent | worm-serpent.md |
| Nue | Japanese Yōkai | biped-humanoid | biped-humanoid.md |
| Tsuchigumo | Japanese Yōkai | spider-arachnid | spider-arachnid.md |
| Kelpie (also Aquatic & the Drowned Deep) | Celtic & British Isles | aquatic | aquatic.md |
| Merrow (also Aquatic & the Drowned Deep) | Celtic & British Isles | aquatic | aquatic.md |
| Selkie | Celtic & British Isles | aquatic | aquatic.md |
| Cat Sìth | Celtic & British Isles | quadruped-beast | quadruped-beast.md |
| Bauchan | Celtic & British Isles | biped-humanoid | biped-humanoid.md |
| Fachan | Celtic & British Isles | biped-humanoid | biped-humanoid.md |
| Afanc | Celtic & British Isles | aquatic | aquatic.md |
| Bean-nighe | Celtic & British Isles | ghost-wisp | ghost-wisp.md |
| Domovoi | Slavic | biped-humanoid | biped-humanoid.md |
| Kikimora | Slavic | biped-humanoid | biped-humanoid.md |
| Rusalka (also Aquatic & the Drowned Deep) | Slavic | biped-humanoid | biped-humanoid.md |
| Vodyanoy | Slavic | biped-humanoid | biped-humanoid.md |
| Striga | Slavic | biped-humanoid | biped-humanoid.md |
| Leshy (also Plants & Fungi) | Slavic | plant-fungal | plant-fungal.md |
| Alkonost | Slavic | winged | winged.md |
| Gamayun | Slavic | winged | winged.md |
| Mora | Slavic | biped-humanoid | biped-humanoid.md |
| Zmey (also Dragons & Great Serpents) | Slavic | worm-serpent | worm-serpent.md |
| Firebird (also Sky & Storm) | Slavic | winged | winged.md |
| Cedar Guardian | Mesopotamian | plant-fungal | plant-fungal.md |
| Galla | Mesopotamian | biped-humanoid | biped-humanoid.md |
| Scorpion Man | Mesopotamian | spider-arachnid | spider-arachnid.md |
| Ugallu | Mesopotamian | biped-humanoid | biped-humanoid.md |
| Lamassu | Mesopotamian | quadruped-beast | quadruped-beast.md |
| Mušḫuššu | Mesopotamian | biped-humanoid | biped-humanoid.md |
| Anzu (also Sky & Storm) | Mesopotamian | winged | winged.md |
| Asag | Mesopotamian | biped-humanoid | biped-humanoid.md |
| Naga (also Aquatic & the Drowned Deep) | South Asian | worm-serpent | worm-serpent.md |
| Yaksha | South Asian | biped-humanoid | biped-humanoid.md |
| Bhūta | South Asian | biped-humanoid | biped-humanoid.md |
| Piśāca | South Asian | biped-humanoid | biped-humanoid.md |
| Rakshasa | South Asian | biped-humanoid | biped-humanoid.md |
| Makara (also Aquatic & the Drowned Deep) | South Asian | aquatic | aquatic.md |
| Asura | South Asian | biped-humanoid | biped-humanoid.md |
| Garuda (also Sky & Storm) | South Asian | winged | winged.md |
| Terracotta Soldier (also Golems & Constructs) | Chinese & East Asian | golem-construct | golem-construct.md |
| Mountain Yaoguai | Chinese & East Asian | biped-humanoid | biped-humanoid.md |
| Xiezhi | Chinese & East Asian | quadruped-beast | quadruped-beast.md |
| Hulijing | Chinese & East Asian | quadruped-beast | quadruped-beast.md |
| Mogwai | Chinese & East Asian | biped-humanoid | biped-humanoid.md |
| River Long (also Dragons & Great Serpents) | Chinese & East Asian | worm-serpent | worm-serpent.md |
| Taotie | Chinese & East Asian | biped-humanoid | biped-humanoid.md |
| Hundun | Chinese & East Asian | blob-ooze | blob-ooze.md |
| Qilin, Corrupted | Chinese & East Asian | quadruped-beast | quadruped-beast.md |
| Ahuizotl | Mesoamerican & Andean | aquatic | aquatic.md |
| Death Bat | Mesoamerican & Andean | winged | winged.md |
| Nagual | Mesoamerican & Andean | quadruped-beast | quadruped-beast.md |
| Storm Wraith | Mesoamerican & Andean | ghost-wisp | ghost-wisp.md |
| Tzitzimitl | Mesoamerican & Andean | biped-humanoid | biped-humanoid.md |
| Cipactli Brood | Mesoamerican & Andean | aquatic | aquatic.md |
| Tokoloshe | African Traditions | biped-humanoid | biped-humanoid.md |
| Adze | African Traditions | ghost-wisp | ghost-wisp.md |
| Impundulu (also Sky & Storm) | African Traditions | winged | winged.md |
| Sasabonsam | African Traditions | winged | winged.md |
| Mami Wata | African Traditions | aquatic | aquatic.md |
| Inkanyamba | African Traditions | worm-serpent | worm-serpent.md |
| Pixie | Fey & Nature Spirits | winged | winged.md |
| Sprite | Fey & Nature Spirits | winged | winged.md |
| Bramble Imp | Fey & Nature Spirits | quadruped-beast | quadruped-beast.md |
| Brownie | Fey & Nature Spirits | biped-humanoid | biped-humanoid.md |
| Dryad (also Plants & Fungi) | Fey & Nature Spirits | plant-fungal | plant-fungal.md |
| Naiad | Fey & Nature Spirits | aquatic | aquatic.md |
| Sylph (also Elementals & Primal Spirits) | Fey & Nature Spirits | winged | winged.md |
| Faun | Fey & Nature Spirits | biped-humanoid | biped-humanoid.md |
| Will-o'-wisp | Fey & Nature Spirits | ghost-wisp | ghost-wisp.md |
| Changeling | Fey & Nature Spirits | biped-humanoid | biped-humanoid.md |
| Elder Dryad (also Plants & Fungi) | Fey & Nature Spirits | plant-fungal | plant-fungal.md |
| Imp | Demons, Devils & the Damned | biped-humanoid | biped-humanoid.md |
| Possessed Cultist | Demons, Devils & the Damned | biped-humanoid | biped-humanoid.md |
| Succubus | Demons, Devils & the Damned | biped-humanoid | biped-humanoid.md |
| Incubus | Demons, Devils & the Damned | biped-humanoid | biped-humanoid.md |
| Pit Brute | Demons, Devils & the Damned | biped-humanoid | biped-humanoid.md |
| Djinn | Demons, Devils & the Damned | biped-humanoid | biped-humanoid.md |
| Larva of the Damned | Demons, Devils & the Damned | worm-serpent | worm-serpent.md |
| Ifrit | Demons, Devils & the Damned | biped-humanoid | biped-humanoid.md |
| Marid | Demons, Devils & the Damned | biped-humanoid | biped-humanoid.md |
| Contract Devil | Demons, Devils & the Damned | biped-humanoid | biped-humanoid.md |
| Shaitan | Demons, Devils & the Damned | biped-humanoid | biped-humanoid.md |
| Deva | Celestials & the Fallen | biped-humanoid | biped-humanoid.md |
| Seraph | Celestials & the Fallen | winged | winged.md |
| Ophanim | Celestials & the Fallen | golem-construct | golem-construct.md |
| Watcher (Grigori) | Celestials & the Fallen | biped-humanoid | biped-humanoid.md |
| Fallen Angel | Celestials & the Fallen | biped-humanoid | biped-humanoid.md |
| Ashen Seraph | Celestials & the Fallen | winged | winged.md |
| Gnome | Elementals & Primal Spirits | biped-humanoid | biped-humanoid.md |
| Salamander | Elementals & Primal Spirits | quadruped-beast | quadruped-beast.md |
| Fire Elemental | Elementals & Primal Spirits | biped-humanoid | biped-humanoid.md |
| Water Elemental | Elementals & Primal Spirits | biped-humanoid | biped-humanoid.md |
| Earth Elemental | Elementals & Primal Spirits | biped-humanoid | biped-humanoid.md |
| Air Elemental | Elementals & Primal Spirits | biped-humanoid | biped-humanoid.md |
| Undine | Elementals & Primal Spirits | biped-humanoid | biped-humanoid.md |
| Storm Elemental | Elementals & Primal Spirits | biped-humanoid | biped-humanoid.md |
| Magma Elemental | Elementals & Primal Spirits | biped-humanoid | biped-humanoid.md |
| Frost Elemental | Elementals & Primal Spirits | biped-humanoid | biped-humanoid.md |
| Clay Golem | Golems & Constructs | golem-construct | golem-construct.md |
| Gargoyle | Golems & Constructs | golem-construct | golem-construct.md |
| Living Statue | Golems & Constructs | golem-construct | golem-construct.md |
| Haunted Armor | Golems & Constructs | golem-construct | golem-construct.md |
| Stone Golem | Golems & Constructs | golem-construct | golem-construct.md |
| Bone Golem | Golems & Constructs | golem-construct | golem-construct.md |
| Brass Automaton | Golems & Constructs | golem-construct | golem-construct.md |
| Iron Golem | Golems & Constructs | golem-construct | golem-construct.md |
| Crystal Golem | Golems & Constructs | golem-construct | golem-construct.md |
| Grotto Snapper | Plants & Fungi | plant-fungal | plant-fungal.md |
| Mandrake | Plants & Fungi | plant-fungal | plant-fungal.md |
| Vampire Vine | Plants & Fungi | plant-fungal | plant-fungal.md |
| Fungal Shambler | Plants & Fungi | plant-fungal | plant-fungal.md |
| Walking Oak | Plants & Fungi | plant-fungal | plant-fungal.md |
| Thornhound | Plants & Fungi | quadruped-beast | quadruped-beast.md |
| Spore Servant | Plants & Fungi | plant-fungal | plant-fungal.md |
| Corpse Flower | Plants & Fungi | plant-fungal | plant-fungal.md |
| Cave Moray | Aquatic & the Drowned Deep | worm-serpent | worm-serpent.md |
| Drowned Sailor | Aquatic & the Drowned Deep | biped-humanoid | biped-humanoid.md |
| Giant Octopus | Aquatic & the Drowned Deep | aquatic | aquatic.md |
| Deep Crab | Aquatic & the Drowned Deep | spider-arachnid | spider-arachnid.md |
| Lanternjaw | Aquatic & the Drowned Deep | biped-humanoid | biped-humanoid.md |
| World Wurm | Aquatic & the Drowned Deep | worm-serpent | worm-serpent.md |
| Drake | Dragons & Great Serpents | winged | winged.md |
| Wyvern | Dragons & Great Serpents | winged | winged.md |
| Cockatrice | Dragons & Great Serpents | winged | winged.md |
| Jaculus | Dragons & Great Serpents | worm-serpent | worm-serpent.md |
| Wyrm | Dragons & Great Serpents | worm-serpent | worm-serpent.md |
| Basilisk | Dragons & Great Serpents | worm-serpent | worm-serpent.md |
| Amphiptere | Dragons & Great Serpents | worm-serpent | worm-serpent.md |
| Peluda | Dragons & Great Serpents | quadruped-beast | quadruped-beast.md |
| Elder Wyrm | Dragons & Great Serpents | worm-serpent | worm-serpent.md |
| Tarasque | Dragons & Great Serpents | quadruped-beast | quadruped-beast.md |
| Brigand | Humans & the Damned Living | biped-humanoid | biped-humanoid.md |
| Grave Robber | Humans & the Damned Living | biped-humanoid | biped-humanoid.md |
| Cultist | Humans & the Damned Living | biped-humanoid | biped-humanoid.md |
| Witch | Humans & the Damned Living | biped-humanoid | biped-humanoid.md |
| Berserker | Humans & the Damned Living | biped-humanoid | biped-humanoid.md |
| Bandit Chief | Humans & the Damned Living | biped-humanoid | biped-humanoid.md |
| Mad Alchemist | Humans & the Damned Living | biped-humanoid | biped-humanoid.md |
| Necromancer | Humans & the Damned Living | biped-humanoid | biped-humanoid.md |
| Warlock | Humans & the Damned Living | biped-humanoid | biped-humanoid.md |
| Plague Bearer | Humans & the Damned Living | quadruped-beast | quadruped-beast.md |
| Fallen Knight | Humans & the Damned Living | biped-humanoid | biped-humanoid.md |
| Storm Crow | Sky & Storm | winged | winged.md |
| Roc | Sky & Storm | winged | winged.md |
| Phoenix | Sky & Storm | winged | winged.md |
| Thunderbird | Sky & Storm | winged | winged.md |
| Simurgh | Sky & Storm | winged | winged.md |
| Ziz | Sky & Storm | winged | winged.md |
| Living Shadow | The Abyssal & Cosmic | ghost-wisp | ghost-wisp.md |
| Titan | The Abyssal & Cosmic | biped-humanoid | biped-humanoid.md |
| Void Horror | The Abyssal & Cosmic | biped-humanoid | biped-humanoid.md |
| Null Seraph | The Abyssal & Cosmic | winged | winged.md |
| Entropy Wraith | The Abyssal & Cosmic | ghost-wisp | ghost-wisp.md |
| Star Horror | The Abyssal & Cosmic | biped-humanoid | biped-humanoid.md |
| The Hollow Choir | The Abyssal & Cosmic | ghost-wisp | ghost-wisp.md |
| Ashen Titan | The Abyssal & Cosmic | biped-humanoid | biped-humanoid.md |
| Ur-Dragon | The Abyssal & Cosmic | winged | winged.md |

## Adding a new creature guide

See `TEMPLATE.md` in this folder. In short: copy the archetype guide,
fill in the creature's defining features and proportions, add the row to
the priority table above with its tweaks, and keep the full mapping row
pointing at the new guide file.

## Pass 1 priority builds (Nov 1–2, 2026) — 55/55 built, 0 stuck

All 55 priority rows were built in Blender (primitives only, headless)
from their archetype guide + per-row tweaks, exported as GLB, rendered
as a 256×256 Cycles preview, and verified by fresh reimport. Base dir
for every file below: `~/workspace/build/model-guides-proof/priority/`
(script `build_<slug>.py`, model `<slug>.glb`, preview `<slug>.png` per
row). Full per-row numbers live in the three build logs:
`build-log-winged-aquatic-golem.md`, `build-log-quadruped-ghost-plant-spider.md`,
`build-log-biped-worm.md` (same directory).

Standing caveats for all 55: flat colors + emission only, no textures
yet (the 1K realistic anchor is a later pass). NOTHING here is wired
into the game or pre-approved — James's visual review comes first.
Ghost rows bake the guide's hover (min Z = 0.3) instead of grounding.
Preview eyeball coverage: winged/aquatic/golem and quadruped/ghost/
plant/spider previews were rendered; biped/worm previews were eyeballed
for Lamia, Hydra, and Dullahan only, the other 14 passing numeric
reimport checks without an individual eyeball.

### Winged (10) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Harpy | harpy.glb (116,224 B, 29 meshes) | harpy.png | 2.00 × 0.45 × 1.13, min Z 0.0 |
| Siren | siren.glb (101,740 B, 23) | siren.png | 1.80 × 0.45 × 1.09, min Z 0.0 |
| Fallen Valkyrie | fallen-valkyrie.glb (143,700 B, 26) | fallen-valkyrie.png | 1.90 × 0.45 × 1.11, min Z 0.0 |
| Pixie | pixie.glb (98,980 B, 15) | pixie.png | 0.45 × 0.20 × 0.31, min Z 0.0 (~0.3 m body) |
| Sprite | sprite.glb (110,988 B, 23) | sprite.png | 0.45 × 0.20 × 0.31, min Z 0.0 (~0.3 m body) |
| Seraph | seraph.glb (110,136 B, 27) | seraph.png | 2.00 × 0.45 × 1.13, min Z 0.0 (six wings) |
| Ashen Seraph | ashen-seraph.glb (110,004 B, 27) | ashen-seraph.png | 2.00 × 0.45 × 1.13, min Z 0.0 (six wings) |
| Cockatrice | cockatrice.glb (121,500 B, 26) | cockatrice.png | 1.10 × 1.11 × 0.83, min Z 0.0 |
| Cave Wasp | cave-wasp.glb (111,852 B, 17) | cave-wasp.png | 0.69 × 0.91 × 0.50, min Z −0.004 (negligible, tilted-cylinder caps) |
| Null Seraph | null-seraph.glb (110,164 B, 27) | null-seraph.png | 2.00 × 0.45 × 1.13, min Z 0.0 (six wings) |

### Aquatic (8) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Nixie | nixie.glb (75,184 B, 12) | nixie.png | 0.72 × 0.42 × 1.03, min Z 0.0 |
| Kraken | kraken.glb (53,656 B, 11) | kraken.png | 1.73 × 1.73 × 1.23, min Z 0.002 (reduced scale; game scales up) |
| Kelpie | kelpie.glb (71,692 B, 15) | kelpie.png | 0.48 × 1.34 × 1.13, min Z 0.0 |
| Merrow | merrow.glb (80,684 B, 11) | merrow.png | 0.72 × 0.42 × 1.06, min Z 0.0 |
| Selkie | selkie.glb (55,212 B, 8) | selkie.png | 0.70 × 1.33 × 0.48, min Z 0.008 (seal form only) |
| Mami Wata | mami-wata.glb (141,368 B, 16) | mami-wata.png | 0.77 × 0.62 × 1.03, min Z 0.0 (+ snake companion) |
| Naiad | naiad.glb (75,200 B, 12) | naiad.png | 0.72 × 0.42 × 1.03, min Z 0.0 |
| Cave Frog | cave-frog.glb (50,740 B, 10) | cave-frog.png | 0.83 × 0.42 × 0.41, min Z −0.003 (negligible) |

### Golem-construct (2) — grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Karakasa | karakasa.glb (32,400 B, 6) | karakasa.png | 0.90 × 0.94 × 0.97, min Z 0.0 |
| Ophanim | ophanim.glb (123,780 B, 10) | ophanim.png | 0.94 × 0.14 × 0.94, min Z 0.0 |

### Quadruped-beast (10) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Crocodile | crocodile.glb (136,724 B, 30) | crocodile.png | 0.75 × 2.91 × 0.60, min Z 0.0 (low-slung exception: 1.0 m normalization stretched it to 4.85 m) |
| Pale Horse | pale-horse.glb (129,020 B, 25) | pale-horse.png | 0.39 × 1.37 × 1.00, min Z 0.0 |
| Centaur | centaur.glb (171,816 B, 24) | centaur.png | 0.39 × 1.08 × 1.00, min Z 0.0 (head-set normalization compresses the horse body; preview still reads clearly) |
| Chimera | chimera.glb (181,724 B, 33) | chimera.png | 0.63 × 1.74 × 1.00, min Z 0.0 |
| Sphinx | sphinx.glb (175,740 B, 24) | sphinx.png | 0.69 × 1.54 × 1.00, min Z 0.0 |
| Manticore | manticore.glb (155,900 B, 23) | manticore.png | 0.44 × 1.42 × 1.00, min Z 0.0 |
| Sha Beast | sha-beast.glb (123,008 B, 21) | sha-beast.png | 0.56 × 1.79 × 1.00, min Z 0.0 |
| Devourer Beast | devourer-beast.glb (127,984 B, 26) | devourer-beast.png | 0.64 × 1.99 × 1.00, min Z 0.0 |
| Cat Sìth | cat-sith.glb (137,672 B, 22) | cat-sith.png | 0.54 × 1.57 × 1.00, min Z 0.0 |
| Tarasque | tarasque.glb (141,968 B, 26) | tarasque.png | 0.76 × 1.81 × 1.00, min Z 0.0 |

### Ghost-wisp (6) — all HOVER, min Z = 0.3 per the ghost guide

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Banshee | banshee.glb (63,816 B, 10) | banshee.png | 0.78 × 0.73 × 1.00, hover (opaque; transparency added at wiring) |
| Penanggalan | penanggalan.glb (107,636 B, 12) | penanggalan.png | 0.48 × 0.50 × 1.00, hover |
| Mare | mare.glb (63,544 B, 10) | mare.png | 0.66 × 0.74 × 0.80, hover (crouch) |
| Chōchin-obake | chochin-obake.glb (40,208 B, 8) | chochin-obake.png | 0.44 × 0.44 × 0.80, hover (lantern) |
| Will-o'-wisp | will-o-wisp.glb (38,960 B, 4) | will-o-wisp.png | 0.35 × 1.05 × 0.35, hover (orb + 1.05 m tail) |
| The Hollow Choir | the-hollow-choir.glb (189,468 B, 16) | the-hollow-choir.png | 1.08 × 0.94 × 1.00, hover |

### Plant-fungal (1) — grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Corpse Flower | corpse-flower.glb (141,964 B, 16) | corpse-flower.png | 1.48 × 1.02 × 1.15, min Z 0.0 (bloom ~1.02 m; leaves span 1.48 m; petals read flat — steeper outward-up tilt at review) |

### Spider-arachnid (1) — grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Scarab Swarm | scarab-swarm.glb (84,424 B, 21) | scarab-swarm.png | 0.98 × 0.90 × 0.50, min Z 0.0 (ONE scarab; game spawns many) |

### Biped-humanoid (11) — all grounded, ~1.0 m (giants convey size by bulk; scale up in-game if they should tower)

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Ettin | ettin.glb (153,836 B, 19) | ettin.png | 0.637 × 0.285 × 1.000, min Z 0.0 (two heads) |
| Cyclops | cyclops.glb (110,008 B, 15) | cyclops.png | 0.637 × 0.297 × 1.000, min Z 0.0 (single central eye) |
| Jiangshi | jiangshi.glb (127,660 B, 20) | jiangshi.png | 0.625 × 0.695 × 1.055, min Z 0.0 (1.055 = hat) |
| Dullahan | dullahan.glb (119,644 B, 18) | dullahan.png | 0.859 × 0.859 × 0.867, min Z 0.0 (headless height correct) |
| Satyr | satyr.glb (129,124 B, 19) | satyr.png | 0.637 × 0.293 × 1.042, min Z 0.0 (horn tips) |
| Gorgon | gorgon.glb (144,088 B, 24) | gorgon.png | 0.637 × 0.351 × 1.000, min Z 0.0 (serpent-hair cones) |
| Empusa | empusa.glb (126,624 B, 18) | empusa.png | 0.637 × 0.285 × 1.023, min Z 0.0 (horn tips; bronze + donkey legs) |
| Hulder | hulder.glb (139,468 B, 19) | hulder.png | 0.637 × 0.359 × 1.000, min Z 0.0 (hollow back = dark inset disc stand-in, not a true hollow) |
| Faun | faun.glb (126,692 B, 18) | faun.png | 0.541 × 0.232 × 0.870, min Z 0.0 (smaller/slighter than satyr) |
| Zombie | zombie.glb (146,736 B, 20) | zombie.png | 0.625 × 0.617 × 1.000, min Z 0.0 |
| Oni | oni.glb (129,676 B, 20) | oni.png | 0.725 × 0.285 × 1.062, min Z 0.0 (horn tips; bulk torso; iron club) |

### Worm-serpent (6) — grounded, scaled by LENGTH per the worm guide

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Burrow Worm | burrow-worm.glb (130,724 B, 14) | burrow-worm.png | 0.743 × 2.255 × 0.470, min Z 0.0 (pink S-pose) |
| Carrion Worm | carrion-worm.glb (128,500 B, 14) | carrion-worm.png | 0.743 × 2.255 × 0.470, min Z 0.0 (putrid + ichor sheen) |
| Lamia | lamia.glb (204,360 B, 24) | lamia.png | 1.009 × 1.785 × 1.130, min Z 0.0 (serpent chain + woman torso; preview eyeballed) |
| Hydra | hydra.glb (370,232 B, 39) | hydra.png | 1.562 × 1.405 × 1.250, min Z 0.0 (5 heads; preview eyeballed) |
| Jaculus | jaculus.glb (119,132 B, 13) | jaculus.png | 1.878 × 0.480 × 0.850, min Z 0.0 (launching pose + small wings) |
| Amphiptere | amphiptere.glb (139,836 B, 18) | amphiptere.png | 1.726 × 2.375 × 0.470, min Z 0.0 (1.726 m = wingspan) |

## Pass 2 batch (Nov 1–2, 2026) — 222/222 built, 0 stuck

All 222 non-priority, non-wired bestiary rows were built in Blender (primitives only, headless)
from their archetype guide + a deterministic variation (color/bulk/flags, recorded per row),
exported as GLB, rendered as a 256×256 Cycles preview, and verified by fresh reimport
(grounded at min Z = 0, ghosts hover at min Z = 0.3; controlling dimension within 25% of target).
Base dir for every file below: `~/workspace/build/model-guides-proof/priority2/<archetype>/`
(script `build_<slug>.py`, model `<slug>.glb`, preview `<slug>.png` per row).
Per-archetype run logs (`run.log`) and machine-readable results (`results.tsv`) sit beside the scripts.
Standing caveats for all 222: flat colors + emission only, no textures yet (the 1K realistic
anchor is a later pass). NOTHING here is wired into the game or pre-approved — James's visual
review comes first. Giants are height-normalized to 1.0 m with giant-ness conveyed by bulk,
per the Pass 1 rule. Swarm/troop/brood rows build ONE instance (Rat Swarm = one rat,
Baboon Troop = one baboon, Cipactli Brood = one broodling), as with Pass 1's Scarab Swarm.
Preview eyeball coverage: 3 previews eyeballed in this run (Ur-Dragon, Jorōgumo, Fungal Shambler —
all read clearly as their creature); the other 219 pass numeric reimport checks, with previews
rendered for James's review. Wing membranes read thin from the front-3/4 preview angle (the
winged guide's own caveat) — a side-angle re-render is a review-time option, not a rebuild.
Pipeline fix made during this run (no guide step proved wrong, so no guide edits): the grounding
shift now happens AFTER Apply All Transforms — bound_box corners of rotated objects overshoot
the true mesh, so a pre-bake shift left the baked mesh floating (Asp measured +0.031 before the fix,
exactly 0.0 after). The fix is baked into every Pass 2 script's finish() step.

### Blob / ooze (8) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Acid Blob | acid-blob.glb (45668 B, 5 meshes) | acid-blob.png | 1.4375 × 1.4375 × 1.0, min Z 0.0; variant=blob, skin(0.2, 0.7, 0.3) |
| Amber Ooze | amber-ooze.glb (45592 B, 5 meshes) | amber-ooze.png | 1.4375 × 1.4375 × 1.0, min Z 0.0; variant=blob, skin(0.85, 0.6, 0.1) |
| Cave Jelly | cave-jelly.glb (45668 B, 5 meshes) | cave-jelly.png | 1.4375 × 1.4375 × 1.0, min Z 0.0; variant=blob, skin(0.4, 0.9, 0.85) |
| Gloom Ooze | gloom-ooze.glb (45596 B, 5 meshes) | gloom-ooze.png | 1.4375 × 1.4375 × 1.0, min Z 0.0; variant=blob, skin(0.12, 0.12, 0.15) |
| Hundun | hundun.glb (24804 B, 1 meshes) | hundun.png | 1.4375 × 1.4375 × 1.0, min Z 0.0; variant=blob, skin(0.75, 0.78, 0.8) (1 mesh BY DESIGN — faceless blob; task criteria all pass: grounded, height 1.0, sane bounds) |
| Mercury Slime | mercury-slime.glb (45592 B, 5 meshes) | mercury-slime.png | 1.4375 × 1.4375 × 1.0, min Z 0.0; variant=blob, skin(0.75, 0.78, 0.8) |
| Mire Pudding | mire-pudding.glb (45592 B, 5 meshes) | mire-pudding.png | 1.4375 × 1.4375 × 1.0, min Z 0.0; variant=blob, skin(0.35, 0.3, 0.15) |
| Primordial Ooze | primordial-ooze.glb (45580 B, 5 meshes) | primordial-ooze.png | 1.4375 × 1.4375 × 1.0, min Z 0.0; variant=blob, skin(0.25, 0.15, 0.4) |

### Worm / serpent (16) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Asp | asp.glb (226164 B, 16 meshes) | asp.png | 0.3532 × 1.1766 × 0.2034, min Z 0.0; variant=worm, banding, skin(0.2, 0.3, 0.2) |
| Basilisk | basilisk.glb (227572 B, 16 meshes) | basilisk.png | 0.6475 × 2.1572 × 0.3728, min Z 0.0; variant=worm, banding, skin(0.3, 0.45, 0.2) |
| Cave Moray | cave-moray.glb (227568 B, 16 meshes) | cave-moray.png | 0.6475 × 2.1572 × 0.3728, min Z 0.0; variant=worm, banding, skin(0.35, 0.45, 0.35) |
| Cave Python | cave-python.glb (227556 B, 16 meshes) | cave-python.png | 0.6475 × 2.1572 × 0.3728, min Z 0.0; variant=worm, banding, skin(0.45, 0.4, 0.25) |
| Elder Wyrm | elder-wyrm.glb (227548 B, 16 meshes) | elder-wyrm.png | 0.7652 × 2.5494 × 0.4406, min Z 0.0; variant=worm, banding, skin(0.3, 0.25, 0.2) |
| Inkanyamba | inkanyamba.glb (227568 B, 16 meshes) | inkanyamba.png | 0.6475 × 2.1572 × 0.3728, min Z 0.0; variant=worm, banding, skin(0.6, 0.55, 0.35) |
| Larva of the Damned | larva-of-the-damned.glb (226164 B, 16 meshes) | larva-of-the-damned.png | 0.3532 × 1.1766 × 0.2034, min Z 0.0; variant=worm, banding, skin(0.45, 0.2, 0.15) |
| Lindworm (also Dragons & Great Serpents) | lindworm.glb (227556 B, 16 meshes) | lindworm.png | 0.6475 × 2.1572 × 0.3728, min Z 0.0; variant=worm, banding, skin(0.25, 0.35, 0.45) |
| Naga (also Aquatic & the Drowned Deep) | naga.glb (227568 B, 16 meshes) | naga.png | 0.6475 × 2.1572 × 0.3728, min Z 0.0; variant=worm, banding, skin(0.6, 0.55, 0.35) |
| Nure-onna | nure-onna.glb (227568 B, 16 meshes) | nure-onna.png | 0.6475 × 2.1572 × 0.3728, min Z 0.0; variant=worm, banding, skin(0.6, 0.55, 0.35) |
| River Long (also Dragons & Great Serpents) | river-long.glb (227560 B, 16 meshes) | river-long.png | 0.7652 × 2.5494 × 0.4406, min Z 0.0; variant=worm, banding, skin(0.45, 0.2, 0.15) |
| Sea Serpent | sea-serpent.glb (227560 B, 16 meshes) | sea-serpent.png | 0.7652 × 2.5494 × 0.4406, min Z 0.0; variant=worm, banding, skin(0.15, 0.3, 0.35) |
| Serpopard | serpopard.glb (227556 B, 16 meshes) | serpopard.png | 0.6475 × 2.1572 × 0.3728, min Z 0.0; variant=worm, banding, skin(0.25, 0.35, 0.45) |
| World Wurm | world-wurm.glb (227548 B, 16 meshes) | world-wurm.png | 0.7652 × 2.5494 × 0.4406, min Z 0.0; variant=worm, banding, skin(0.2, 0.2, 0.25) |
| Wyrm | wyrm.glb (227552 B, 16 meshes) | wyrm.png | 0.6475 × 2.1572 × 0.3728, min Z 0.0; variant=worm, banding, skin(0.35, 0.55, 0.25) |
| Zmey (also Dragons & Great Serpents) | zmey.glb (328780 B, 24 meshes) | zmey.png | 1.1105 × 2.1572 × 0.3966, min Z 0.0; variant=worm, heads=3, banding, skin(0.55, 0.45, 0.3) |

### Quadruped beast (38) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Baboon Troop | baboon-troop.glb (126836 B, 20 meshes) | baboon-troop.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=troop, skin(0.7, 0.6, 0.4) |
| Bake-danuki | bake-danuki.glb (124584 B, 20 meshes) | bake-danuki.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.45, 0.35, 0.25) |
| Blind Mole | blind-mole.glb (124548 B, 20 meshes) | blind-mole.png | 0.5535 × 1.8489 × 0.986, min Z 0.0; variant=ratlike, skin(0.25, 0.25, 0.25) |
| Bramble Imp | bramble-imp.glb (143372 B, 26 meshes) | bramble-imp.png | 0.5539 × 1.8049 × 0.986, min Z 0.0; variant=thorny, skin(0.65, 0.55, 0.35) |
| Bronze Bull | bronze-bull.glb (132552 B, 22 meshes) | bronze-bull.png | 0.5327 × 1.7369 × 0.9781, min Z 0.0; variant=horned, skin(0.35, 0.35, 0.35) |
| Bugbear | bugbear.glb (126836 B, 20 meshes) | bugbear.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.65, 0.55, 0.35) |
| Cave Ape | cave-ape.glb (126828 B, 20 meshes) | cave-ape.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.55, 0.5, 0.45) |
| Cave Bear | cave-bear.glb (125408 B, 20 meshes) | cave-bear.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.65, 0.55, 0.35) |
| Cave Hyena | cave-hyena.glb (122344 B, 20 meshes) | cave-hyena.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.35, 0.35, 0.35) |
| Crag Ram | crag-ram.glb (132528 B, 22 meshes) | crag-ram.png | 0.5327 × 1.7369 × 0.9781, min Z 0.0; variant=horned, skin(0.45, 0.35, 0.25) |
| Deep Stag | deep-stag.glb (135792 B, 24 meshes) | deep-stag.png | 0.5132 × 1.6733 × 0.9789, min Z 0.0; variant=horned, skin(0.65, 0.55, 0.35) |
| Dire Wolf | dire-wolf.glb (126836 B, 20 meshes) | dire-wolf.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.65, 0.55, 0.35) |
| Falcon Sphinx | falcon-sphinx.glb (161976 B, 28 meshes) | falcon-sphinx.png | 1.3253 × 1.7703 × 1.0, min Z 0.0; variant=beak_wings, skin(0.45, 0.35, 0.25) |
| Giant Rat | giant-rat.glb (126824 B, 20 meshes) | giant-rat.png | 0.5535 × 1.8489 × 0.986, min Z 0.0; variant=ratlike, skin(0.55, 0.5, 0.45) |
| Great Wolf | great-wolf.glb (122300 B, 20 meshes) | great-wolf.png | 0.7196 × 1.8049 × 0.986, min Z 0.0; bulk 1.30, variant=quad, skin(0.25, 0.25, 0.25) |
| Grizzly | grizzly.glb (126792 B, 20 meshes) | grizzly.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.25, 0.25, 0.25) |
| Grotto Bull | grotto-bull.glb (130284 B, 22 meshes) | grotto-bull.png | 0.6392 × 1.7369 × 0.9781, min Z 0.0; bulk 1.20, variant=horned, skin(0.7, 0.6, 0.4) |
| Hulijing | hulijing.glb (134264 B, 22 meshes) | hulijing.png | 0.5535 × 1.8106 × 0.986, min Z 0.0; variant=fox, tails=3, skin(0.35, 0.35, 0.35) |
| Hyena | hyena.glb (126792 B, 20 meshes) | hyena.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.25, 0.25, 0.25) |
| Jackal Guardian | jackal-guardian.glb (126840 B, 20 meshes) | jackal-guardian.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.65, 0.55, 0.35) |
| Kasha | kasha.glb (126836 B, 20 meshes) | kasha.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.7, 0.6, 0.4) |
| Kitsune | kitsune.glb (146168 B, 24 meshes) | kitsune.png | 0.7171 × 1.8146 × 0.986, min Z 0.0; variant=fox, tails=5, skin(0.45, 0.35, 0.25) |
| Lamassu | lamassu.glb (148708 B, 25 meshes) | lamassu.png | 1.3253 × 1.6239 × 1.0, min Z 0.0; variant=human_wings, skin(0.7, 0.6, 0.4) |
| Lion | lion.glb (126824 B, 20 meshes) | lion.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.45, 0.35, 0.25) |
| Nagual | nagual.glb (126820 B, 20 meshes) | nagual.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.55, 0.5, 0.45) |
| Nemean Lion | nemean-lion.glb (126836 B, 20 meshes) | nemean-lion.png | 0.6642 × 1.8049 × 0.986, min Z 0.0; bulk 1.20, variant=quad, skin(0.65, 0.55, 0.35) |
| Panther | panther.glb (124576 B, 20 meshes) | panther.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.45, 0.35, 0.25) |
| Peluda | peluda.glb (143564 B, 26 meshes) | peluda.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.65, 0.55, 0.35) |
| Plague Bearer | plague-bearer.glb (126824 B, 20 meshes) | plague-bearer.png | 0.5535 × 1.8489 × 0.986, min Z 0.0; variant=ratlike, skin(0.45, 0.35, 0.25) |
| Qilin, Corrupted | qilin-corrupted.glb (146308 B, 27 meshes) | qilin-corrupted.png | 0.5327 × 1.7369 × 0.9781, min Z 0.0; variant=horned, skin(0.35, 0.35, 0.35) |
| Razorback | razorback.glb (143520 B, 26 meshes) | razorback.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.25, 0.25, 0.25) |
| Sabertooth | sabertooth.glb (126796 B, 20 meshes) | sabertooth.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.25, 0.25, 0.25) |
| Salamander | salamander.glb (124576 B, 20 meshes) | salamander.png | 0.5535 × 2.0464 × 0.986, min Z 0.0; variant=lizard, skin(0.55, 0.5, 0.45) |
| Thornhound | thornhound.glb (141112 B, 26 meshes) | thornhound.png | 0.5539 × 1.8049 × 0.986, min Z 0.0; variant=thorny, skin(0.55, 0.5, 0.45) |
| Tiger | tiger.glb (124588 B, 20 meshes) | tiger.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.35, 0.35, 0.35) |
| Warhound | warhound.glb (126844 B, 20 meshes) | warhound.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.35, 0.35, 0.35) |
| Wolf | wolf.glb (124548 B, 20 meshes) | wolf.png | 0.5535 × 1.8049 × 0.986, min Z 0.0; variant=quad, skin(0.25, 0.25, 0.25) |
| Xiezhi | xiezhi.glb (129748 B, 21 meshes) | xiezhi.png | 0.488 × 1.5912 × 0.9856, min Z 0.0; variant=horned, skin(0.25, 0.25, 0.25) |

### Biped humanoid (95) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Air Elemental | air-elemental.glb (119888 B, 16 meshes) | air-elemental.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.85, 0.9, 0.95) |
| Alfar Raider | alfar-raider.glb (129296 B, 21 meshes) | alfar-raider.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; ears, armor, skin(0.4, 0.4, 0.45) |
| Asag | asag.glb (119900 B, 16 meshes) | asag.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.55, 0.45, 0.35) |
| Ashen Titan | ashen-titan.glb (120028 B, 16 meshes) | ashen-titan.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 1.45, skin(0.45, 0.6, 0.35) |
| Asura | asura.glb (126732 B, 18 meshes) | asura.png | 0.5982 × 0.2679 × 0.9793, min Z -0.0; bulk 1.20, horns, skin(0.85, 0.75, 0.6) |
| Bandit Chief | bandit-chief.glb (115436 B, 16 meshes) | bandit-chief.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.55, 0.45, 0.35) |
| Barrow Wight | barrow-wight.glb (121068 B, 17 meshes) | barrow-wight.png | 0.8594 × 0.8594 × 1.0, min Z -0.0; cloak, skin(0.7, 0.72, 0.7) |
| Bauchan | bauchan.glb (117784 B, 16 meshes) | bauchan.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 0.90, skin(0.55, 0.45, 0.35) |
| Berserker | berserker.glb (119880 B, 16 meshes) | berserker.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.85, 0.75, 0.6) |
| Bhūta | bhuta.glb (119900 B, 16 meshes) | bhuta.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.55, 0.45, 0.35) |
| Boggart | boggart.glb (126012 B, 18 meshes) | boggart.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 0.80, ears, skin(0.4, 0.4, 0.45) |
| Brownie | brownie.glb (120052 B, 16 meshes) | brownie.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 0.80, skin(0.45, 0.6, 0.35) |
| Cave Troll | cave-troll.glb (125780 B, 18 meshes) | cave-troll.png | 0.7246 × 0.2852 × 1.0, min Z -0.0; bulk 1.30, club, skin(0.4, 0.4, 0.45) |
| Changeling | changeling.glb (119864 B, 16 meshes) | changeling.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.75, 0.6, 0.45) |
| Contract Devil | contract-devil.glb (126712 B, 18 meshes) | contract-devil.png | 0.5982 × 0.2679 × 0.9793, min Z -0.0; horns, skin(0.85, 0.75, 0.6) |
| Cultist | cultist.glb (118152 B, 17 meshes) | cultist.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.6, 0.6, 0.6) |
| Dark Elf (Dökkálfar) | dark-elf.glb (123596 B, 18 meshes) | dark-elf.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; ears, skin(0.85, 0.75, 0.6) |
| Deva | deva.glb (118144 B, 17 meshes) | deva.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.6, 0.6, 0.6) |
| Djinn | djinn.glb (122584 B, 17 meshes) | djinn.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.45, 0.6, 0.35) |
| Domovoi | domovoi.glb (123308 B, 17 meshes) | domovoi.png | 0.6367 × 0.293 × 1.0, min Z -0.0; beard, skin(0.6, 0.6, 0.6) |
| Draugr (also Norse & Germanic) | draugr.glb (119668 B, 16 meshes) | draugr.png | 0.625 × 0.582 × 1.0, min Z -0.0; arms-forward, skin(0.55, 0.6, 0.55) |
| Drowned Sailor | drowned-sailor.glb (145312 B, 20 meshes) | drowned-sailor.png | 0.625 × 0.6172 × 1.0, min Z -0.0; rotting, arms-forward, skin(0.55, 0.45, 0.35) |
| Earth Elemental | earth-elemental.glb (119868 B, 16 meshes) | earth-elemental.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.45, 0.35, 0.25) |
| Fachan | fachan.glb (120060 B, 16 meshes) | fachan.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 1.15, skin(0.4, 0.4, 0.45) |
| Fallen Angel | fallen-angel.glb (119896 B, 16 meshes) | fallen-angel.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.4, 0.4, 0.45) |
| Fallen Knight | fallen-knight.glb (123336 B, 19 meshes) | fallen-knight.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; armor, skin(0.4, 0.4, 0.45) |
| Fire Elemental | fire-elemental.glb (120084 B, 16 meshes) | fire-elemental.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.8, 0.25, 0.1) |
| Fire Giant (also Norse & Germanic) | fire-giant.glb (120232 B, 16 meshes) | fire-giant.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 1.45, skin(0.8, 0.25, 0.1) |
| Frost Elemental | frost-elemental.glb (119868 B, 16 meshes) | frost-elemental.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.75, 0.85, 0.95) |
| Frost Giant (also Norse & Germanic) | frost-giant.glb (120036 B, 16 meshes) | frost-giant.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 1.45, skin(0.75, 0.85, 0.95) |
| Galla | galla.glb (119880 B, 16 meshes) | galla.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.55, 0.45, 0.35) |
| Gashadokuro (also Japanese Yōkai) | gashadokuro.glb (123488 B, 19 meshes) | gashadokuro.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 1.45, ribs, skin(0.85, 0.82, 0.7) |
| Ghoul (also Demons, Devils & the Damned) | ghoul.glb (146748 B, 20 meshes) | ghoul.png | 0.625 × 0.6172 × 1.0, min Z -0.0; rotting, arms-forward, skin(0.4, 0.4, 0.45) |
| Gnome | gnome.glb (123452 B, 17 meshes) | gnome.png | 0.6367 × 0.293 × 1.0, min Z -0.0; bulk 0.80, beard, skin(0.55, 0.45, 0.35) |
| Goblin Champion | goblin-champion.glb (129432 B, 21 meshes) | goblin-champion.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 0.80, ears, armor, skin(0.75, 0.6, 0.45) |
| Goblin Shaman | goblin-shaman.glb (125996 B, 18 meshes) | goblin-shaman.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 0.80, ears, skin(0.85, 0.75, 0.6) |
| Goblin Sneak | goblin-sneak.glb (126004 B, 18 meshes) | goblin-sneak.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 0.80, ears, skin(0.6, 0.6, 0.6) |
| Grave Robber | grave-robber.glb (119892 B, 16 meshes) | grave-robber.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.45, 0.6, 0.35) |
| Gremlin | gremlin.glb (126020 B, 18 meshes) | gremlin.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 0.80, ears, skin(0.4, 0.4, 0.45) |
| Half-Ogre | half-ogre.glb (123516 B, 18 meshes) | half-ogre.png | 0.7246 × 0.2852 × 1.0, min Z -0.0; bulk 1.30, club, skin(0.85, 0.75, 0.6) |
| Hill Giant | hill-giant.glb (120028 B, 16 meshes) | hill-giant.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 1.45, skin(0.75, 0.6, 0.45) |
| Hobgoblin | hobgoblin.glb (123468 B, 19 meshes) | hobgoblin.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 1.10, armor, skin(0.85, 0.75, 0.6) |
| Ifrit | ifrit.glb (119900 B, 16 meshes) | ifrit.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.4, 0.4, 0.45) |
| Incubus | incubus.glb (126736 B, 18 meshes) | incubus.png | 0.5982 × 0.2679 × 0.9793, min Z -0.0; horns, skin(0.4, 0.4, 0.45) |
| Kikimora | kikimora.glb (119880 B, 16 meshes) | kikimora.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.85, 0.75, 0.6) |
| Lanternjaw | lanternjaw.glb (119864 B, 16 meshes) | lanternjaw.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.75, 0.6, 0.45) |
| Lich | lich.glb (122584 B, 17 meshes) | lich.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.85, 0.82, 0.7) |
| Mad Alchemist | mad-alchemist.glb (119892 B, 16 meshes) | mad-alchemist.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.6, 0.6, 0.6) |
| Magma Elemental | magma-elemental.glb (120100 B, 16 meshes) | magma-elemental.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.7, 0.2, 0.1) |
| Marid | marid.glb (122584 B, 17 meshes) | marid.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.55, 0.45, 0.35) |
| Marsh Troll | marsh-troll.glb (125760 B, 18 meshes) | marsh-troll.png | 0.7246 × 0.2852 × 1.0, min Z -0.0; bulk 1.30, club, skin(0.55, 0.45, 0.35) |
| Mogwai | mogwai.glb (126004 B, 18 meshes) | mogwai.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 0.80, ears, skin(0.85, 0.75, 0.6) |
| Mora | mora.glb (119892 B, 16 meshes) | mora.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.55, 0.45, 0.35) |
| Mountain Yaoguai | mountain-yaoguai.glb (123300 B, 17 meshes) | mountain-yaoguai.png | 0.6367 × 0.293 × 1.0, min Z -0.0; beard, skin(0.6, 0.6, 0.6) |
| Mummy (also Egyptian & Near East) | mummy.glb (122592 B, 17 meshes) | mummy.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.75, 0.7, 0.55) |
| Mušḫuššu | mushussu.glb (132444 B, 19 meshes) | mushussu.png | 0.5982 × 0.5468 × 0.9793, min Z -0.0; horns, tail, skin(0.85, 0.75, 0.6) |
| Necromancer | necromancer.glb (122568 B, 17 meshes) | necromancer.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.85, 0.75, 0.6) |
| Nue | nue.glb (126724 B, 18 meshes) | nue.png | 0.5982 × 0.2679 × 0.9793, min Z -0.0; horns, skin(0.55, 0.45, 0.35) |
| Ogre | ogre.glb (125760 B, 18 meshes) | ogre.png | 0.7246 × 0.2852 × 1.0, min Z -0.0; bulk 1.30, club, skin(0.45, 0.6, 0.35) |
| Ogre Mage | ogre-mage.glb (125760 B, 18 meshes) | ogre-mage.png | 0.7246 × 0.2852 × 1.0, min Z -0.0; bulk 1.30, club, skin(0.6, 0.6, 0.6) |
| Orc Berserker | orc-berserker.glb (119864 B, 16 meshes) | orc-berserker.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.75, 0.6, 0.45) |
| Orc Shaman | orc-shaman.glb (119884 B, 16 meshes) | orc-shaman.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.75, 0.6, 0.45) |
| Pit Brute | pit-brute.glb (126752 B, 18 meshes) | pit-brute.png | 0.5982 × 0.2679 × 0.9793, min Z -0.0; bulk 1.25, horns, skin(0.45, 0.6, 0.35) |
| Piśāca | pisaca.glb (119880 B, 16 meshes) | pisaca.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.75, 0.6, 0.45) |
| Possessed Cultist | possessed-cultist.glb (122584 B, 17 meshes) | possessed-cultist.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.4, 0.4, 0.45) |
| Púca (also Celtic & British Isles) | puca.glb (115600 B, 16 meshes) | puca.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 0.85, skin(0.45, 0.6, 0.35) |
| Rakshasa | rakshasa.glb (126732 B, 18 meshes) | rakshasa.png | 0.5982 × 0.2679 × 0.9793, min Z -0.0; horns, skin(0.85, 0.75, 0.6) |
| Redcap (also Celtic & British Isles) | redcap.glb (120052 B, 16 meshes) | redcap.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 0.85, skin(0.55, 0.45, 0.35) |
| Rusalka (also Aquatic & the Drowned Deep) | rusalka.glb (119896 B, 16 meshes) | rusalka.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.45, 0.6, 0.35) |
| Shaitan | shaitan.glb (126720 B, 18 meshes) | shaitan.png | 0.5982 × 0.2679 × 0.9793, min Z -0.0; horns, skin(0.75, 0.6, 0.45) |
| Skeleton Knight | skeleton-knight.glb (126784 B, 22 meshes) | skeleton-knight.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; armor, ribs, skin(0.85, 0.82, 0.7) |
| Spriggan (also Celtic & British Isles) | spriggan.glb (126004 B, 18 meshes) | spriggan.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 1.15, ears, skin(0.4, 0.4, 0.45) |
| Star Horror | star-horror.glb (119896 B, 16 meshes) | star-horror.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.6, 0.6, 0.6) |
| Stone Giant | stone-giant.glb (120028 B, 16 meshes) | stone-giant.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 1.45, skin(0.45, 0.6, 0.35) |
| Storm Elemental | storm-elemental.glb (120080 B, 16 meshes) | storm-elemental.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.45, 0.35, 0.7) |
| Striga | striga.glb (119880 B, 16 meshes) | striga.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.55, 0.45, 0.35) |
| Strigoi | strigoi.glb (123316 B, 17 meshes) | strigoi.png | 0.8594 × 0.8594 × 1.0, min Z -0.0; cloak, skin(0.9, 0.85, 0.8) |
| Succubus | succubus.glb (124476 B, 18 meshes) | succubus.png | 0.5982 × 0.2679 × 0.9793, min Z -0.0; horns, skin(0.45, 0.6, 0.35) |
| Taotie | taotie.glb (126744 B, 18 meshes) | taotie.png | 0.5982 × 0.2679 × 0.9793, min Z -0.0; bulk 1.20, horns, skin(0.4, 0.4, 0.45) |
| Titan | titan.glb (120044 B, 16 meshes) | titan.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; bulk 1.45, skin(0.45, 0.6, 0.35) |
| Tokoloshe | tokoloshe.glb (119880 B, 16 meshes) | tokoloshe.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.6, 0.6, 0.6) |
| Tzitzimitl | tzitzimitl.glb (122596 B, 17 meshes) | tzitzimitl.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.6, 0.6, 0.6) |
| Ugallu | ugallu.glb (126724 B, 18 meshes) | ugallu.png | 0.5982 × 0.2679 × 0.9793, min Z -0.0; bulk 1.15, horns, skin(0.45, 0.6, 0.35) |
| Undine | undine.glb (117644 B, 16 meshes) | undine.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.3, 0.55, 0.7) |
| Vampire | vampire.glb (123324 B, 17 meshes) | vampire.png | 0.8594 × 0.8594 × 1.0, min Z -0.0; cloak, skin(0.9, 0.85, 0.8) |
| Vetala (also South Asian) | vetala.glb (122608 B, 17 meshes) | vetala.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.6, 0.6, 0.6) |
| Vodyanoy | vodyanoy.glb (119892 B, 16 meshes) | vodyanoy.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.6, 0.6, 0.6) |
| Void Horror | void-horror.glb (119876 B, 16 meshes) | void-horror.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.75, 0.6, 0.45) |
| Warlock | warlock.glb (122584 B, 17 meshes) | warlock.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.6, 0.6, 0.6) |
| Watcher (Grigori) | watcher.glb (120356 B, 17 meshes) | watcher.png | 0.6367 × 0.5 × 1.0, min Z -0.0; robe, skin(0.45, 0.6, 0.35) |
| Water Elemental | water-elemental.glb (117616 B, 16 meshes) | water-elemental.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.2, 0.5, 0.7) |
| Wight Lord | wight-lord.glb (123324 B, 17 meshes) | wight-lord.png | 0.8594 × 0.8594 × 1.0, min Z -0.0; cloak, skin(0.7, 0.72, 0.7) |
| Witch | witch.glb (127368 B, 19 meshes) | witch.png | 0.5906 × 0.4638 × 1.0, min Z 0.0; robe, skin(0.85, 0.75, 0.6) |
| Yaksha | yaksha.glb (119896 B, 16 meshes) | yaksha.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.4, 0.4, 0.45) |
| Yuki-onna | yuki-onna.glb (117644 B, 16 meshes) | yuki-onna.png | 0.6367 × 0.2852 × 1.0, min Z -0.0; skin(0.4, 0.4, 0.45) |

### Winged (21) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Alkonost | alkonost.glb (169180 B, 28 meshes) | alkonost.png | 1.7859 × 0.4102 × 1.0, min Z -0.0; variant=winged, body=biped, style=feathered, skin(0.55, 0.55, 0.6) |
| Anzu (also Sky & Storm) | anzu.glb (132216 B, 24 meshes) | anzu.png | 1.88 × 0.9601 × 1.0, min Z 0.0; bulk 1.20, variant=winged, body=bird, style=feathered, skin(0.55, 0.55, 0.6) |
| Death Bat | death-bat.glb (80544 B, 16 meshes) | death-bat.png | 1.7907 × 0.5366 × 0.9839, min Z 0.0; variant=winged, body=bat, style=membrane, skin(0.3, 0.1, 0.1) |
| Firebird (also Sky & Storm) | firebird.glb (132308 B, 24 meshes) | firebird.png | 1.88 × 0.9601 × 1.0, min Z 0.0; variant=winged, body=bird, style=feathered, skin(0.85, 0.3, 0.1) |
| Gamayun | gamayun.glb (166948 B, 28 meshes) | gamayun.png | 1.7859 × 0.4102 × 1.0, min Z -0.0; variant=winged, body=biped, style=feathered, skin(0.65, 0.6, 0.5) |
| Garuda (also Sky & Storm) | garuda.glb (171380 B, 28 meshes) | garuda.png | 1.7859 × 0.4102 × 1.0, min Z -0.0; bulk 1.20, variant=winged, body=biped, style=feathered, skin(0.75, 0.6, 0.25) |
| Griffin (also Sky & Storm) | griffin.glb (181760 B, 32 meshes) | griffin.png | 1.7697 × 1.7631 × 0.9814, min Z 0.0; variant=winged, body=quadruped, style=feathered, skin(0.45, 0.35, 0.25) |
| Hornet Matriarch | hornet-matriarch.glb (95296 B, 16 meshes) | hornet-matriarch.png | 2.3413 × 2.1515 × 1.0, min Z 0.0; variant=winged, body=insect, style=insect, skin(0.7, 0.55, 0.15) |
| Impundulu (also Sky & Storm) | impundulu.glb (132240 B, 24 meshes) | impundulu.png | 1.88 × 0.9601 × 1.0, min Z 0.0; variant=winged, body=bird, style=feathered, skin(0.2, 0.2, 0.22) |
| Phoenix | phoenix.glb (132324 B, 24 meshes) | phoenix.png | 1.88 × 0.9601 × 1.0, min Z 0.0; variant=winged, body=bird, style=feathered, skin(0.85, 0.35, 0.1) |
| Roc | roc.glb (132168 B, 24 meshes) | roc.png | 1.88 × 0.9601 × 1.0, min Z 0.0; bulk 1.50, variant=winged, body=bird, style=feathered, skin(0.25, 0.25, 0.3) |
| Sasabonsam | sasabonsam.glb (136308 B, 24 meshes) | sasabonsam.png | 1.7859 × 0.3621 × 1.0, min Z -0.0; variant=winged, body=biped, style=membrane, skin(0.35, 0.3, 0.25) |
| Simurgh | simurgh.glb (132216 B, 24 meshes) | simurgh.png | 1.88 × 0.9601 × 1.0, min Z 0.0; bulk 1.20, variant=winged, body=bird, style=feathered, skin(0.55, 0.55, 0.6) |
| Storm Crow | storm-crow.glb (132212 B, 24 meshes) | storm-crow.png | 1.88 × 0.9601 × 1.0, min Z 0.0; variant=winged, body=bird, style=feathered, skin(0.15, 0.15, 0.18) |
| Stymphalian Bird (also Sky & Storm) | stymphalian-bird.glb (132176 B, 24 meshes) | stymphalian-bird.png | 1.88 × 0.9601 × 1.0, min Z 0.0; variant=winged, body=bird, style=feathered, skin(0.25, 0.25, 0.3) |
| Sylph (also Elementals & Primal Spirits) | sylph.glb (124456 B, 20 meshes) | sylph.png | 1.6513 × 0.2852 × 1.0, min Z -0.0; variant=winged, body=biped, style=insect, skin(0.85, 0.9, 0.95) |
| Tengu | tengu.glb (171376 B, 28 meshes) | tengu.png | 1.7859 × 0.4102 × 1.0, min Z -0.0; variant=winged, body=biped, style=feathered, skin(0.45, 0.35, 0.25) |
| Thunderbird | thunderbird.glb (132224 B, 24 meshes) | thunderbird.png | 1.88 × 0.9601 × 1.0, min Z 0.0; bulk 1.30, variant=winged, body=bird, style=feathered, skin(0.55, 0.55, 0.6) |
| Ur-Dragon | ur-dragon.glb (145004 B, 28 meshes) | ur-dragon.png | 1.7697 × 1.7631 × 0.9814, min Z 0.0; bulk 1.50, variant=winged, body=quadruped, style=membrane, skin(0.45, 0.35, 0.25) |
| Wyvern | wyvern.glb (147232 B, 28 meshes) | wyvern.png | 1.7697 × 1.7631 × 0.9814, min Z 0.0; variant=winged, body=quadruped, style=membrane, skin(0.65, 0.6, 0.5) |
| Ziz | ziz.glb (132160 B, 24 meshes) | ziz.png | 1.88 × 0.9601 × 1.0, min Z 0.0; bulk 1.40, variant=winged, body=bird, style=feathered, skin(0.25, 0.25, 0.3) |

### Spider / arachnid (10) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Deep Crab | deep-crab.glb (113968 B, 21 meshes) | deep-crab.png | 0.9915 × 0.6504 × 0.4468, min Z 0.0; variant=crab, skin(0.35, 0.25, 0.15) |
| Emperor Scorpion | emperor-scorpion.glb (181988 B, 31 meshes) | emperor-scorpion.png | 0.8986 × 1.0 × 0.7345, min Z 0.0; bulk 1.20, variant=scorpion, skin(0.3, 0.2, 0.25) |
| Guardian Scorpion | guardian-scorpion.glb (181984 B, 31 meshes) | guardian-scorpion.png | 0.8986 × 1.0 × 0.7345, min Z 0.0; variant=scorpion, skin(0.35, 0.25, 0.15) |
| Jorōgumo | jorogumo.glb (169252 B, 32 meshes) | jorogumo.png | 0.9862 × 0.6693 × 0.9812, min Z 0.0; variant=jorogumo, skin(0.45, 0.3, 0.15) |
| Rat Swarm | rat-swarm.glb (104056 B, 15 meshes) | rat-swarm.png | 0.3276 × 0.9914 × 0.3509, min Z 0.0; variant=rat, skin(0.35, 0.25, 0.15) |
| Scorpion Man | scorpion-man.glb (245592 B, 37 meshes) | scorpion-man.png | 0.8986 × 1.0 × 0.9889, min Z 0.0; variant=scorpion_man, skin(0.15, 0.15, 0.15) |
| Stag Beetle | stag-beetle.glb (90616 B, 18 meshes) | stag-beetle.png | 0.9658 × 0.9904 × 0.5065, min Z 0.0; variant=beetle, skin(0.35, 0.25, 0.15) |
| Tsuchigumo | tsuchigumo.glb (105084 B, 26 meshes) | tsuchigumo.png | 0.9862 × 0.6693 × 0.4004, min Z 0.0; bulk 1.20, variant=spider, skin(0.15, 0.15, 0.15) |
| Widow Spider | widow-spider.glb (111940 B, 27 meshes) | widow-spider.png | 0.9862 × 0.6693 × 0.4487, min Z 0.0; variant=spider, skin(0.08, 0.08, 0.08) |
| Ōmukade (also Japanese Yōkai) | omukade.glb (313420 B, 39 meshes) | omukade.png | 0.2919 × 1.0 × 0.1582, min Z 0.0; bulk 1.30, variant=centipede, skin(0.2, 0.15, 0.12) |

### Aquatic (5) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Afanc | afanc.glb (100608 B, 23 meshes) | afanc.png | 0.5208 × 1.698 × 1.0, min Z 0.0; variant=horse, skin(0.15, 0.2, 0.2) |
| Ahuizotl | ahuizotl.glb (71560 B, 8 meshes) | ahuizotl.png | 0.611 × 1.2 × 0.5639, min Z 0.0; variant=fish, extra=tail_hand, skin(0.35, 0.4, 0.45) |
| Cipactli Brood | cipactli-brood.glb (54388 B, 8 meshes) | cipactli-brood.png | 0.5643 × 1.2 × 0.5208, min Z 0.0; variant=fish, extra=jaw, skin(0.4, 0.45, 0.3) |
| Giant Octopus | giant-octopus.glb (72584 B, 11 meshes) | giant-octopus.png | 1.4559 × 1.4559 × 0.61, min Z 0.0; variant=octopus, skin(0.45, 0.3, 0.4) |
| Makara (also Aquatic & the Drowned Deep) | makara.glb (57764 B, 8 meshes) | makara.png | 0.5211 × 1.185 × 0.481, min Z -0.0; variant=fish, extra=trunk, skin(0.3, 0.45, 0.4) |

### Plant / fungal (10) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Cedar Guardian | cedar-guardian.glb (97108 B, 13 meshes) | cedar-guardian.png | 0.7592 × 0.5368 × 1.0, min Z 0.0; variant=treant, skin(0.45, 0.35, 0.2) |
| Dryad (also Plants & Fungi) | dryad.glb (106108 B, 15 meshes) | dryad.png | 0.7592 × 0.5368 × 1.0, min Z 0.0; variant=dryad, face, skin(0.2, 0.45, 0.2) |
| Elder Dryad (also Plants & Fungi) | elder-dryad.glb (110512 B, 15 meshes) | elder-dryad.png | 0.7592 × 0.5368 × 1.0, min Z 0.0; variant=dryad, face, skin(0.3, 0.5, 0.25) |
| Fungal Shambler | fungal-shambler.glb (141156 B, 15 meshes) | fungal-shambler.png | 0.6331 × 0.3165 × 1.0, min Z -0.0; variant=shambler, face, skin(0.2, 0.45, 0.2) |
| Grotto Snapper | grotto-snapper.glb (36216 B, 9 meshes) | grotto-snapper.png | 1.7738 × 1.0047 × 1.0, min Z 0.0; variant=snapper, skin(0.25, 0.55, 0.3) |
| Leshy (also Plants & Fungi) | leshy.glb (110544 B, 15 meshes) | leshy.png | 0.7592 × 0.5368 × 1.0, min Z 0.0; variant=treant, face, skin(0.2, 0.45, 0.2) |
| Mandrake | mandrake.glb (54880 B, 7 meshes) | mandrake.png | 0.8163 × 0.8163 × 1.0, min Z 0.0; variant=mushroom, face, skin(0.25, 0.55, 0.3) |
| Spore Servant | spore-servant.glb (54880 B, 7 meshes) | spore-servant.png | 0.8163 × 0.8163 × 1.0, min Z 0.0; variant=mushroom, face, skin(0.45, 0.35, 0.2) |
| Vampire Vine | vampire-vine.glb (38036 B, 11 meshes) | vampire-vine.png | 0.6104 × 1.7 × 0.2041, min Z 0.0; variant=vine, skin(0.35, 0.15, 0.15) |
| Walking Oak | walking-oak.glb (97092 B, 13 meshes) | walking-oak.png | 0.7592 × 0.5368 × 1.0, min Z 0.0; variant=treant, skin(0.55, 0.45, 0.25) |

### Ghost / wisp (9) — all HOVER, min Z = 0.3 per the ghost guide

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Adze | adze.glb (38564 B, 4 meshes) | adze.png | 0.4633 × 0.4788 × 1.0, min Z 0.3; variant=ghost, skin(0.7, 0.75, 0.8) |
| Bean-nighe | bean-nighe.glb (42160 B, 6 meshes) | bean-nighe.png | 0.7342 × 0.4788 × 1.0, min Z 0.3; variant=ghost, arms, skin(0.7, 0.78, 0.85) |
| Entropy Wraith | entropy-wraith.glb (53180 B, 7 meshes) | entropy-wraith.png | 0.4455 × 0.4603 × 0.9846, min Z 0.3; variant=ghost, tattered, skin(0.3, 0.25, 0.4) |
| Living Shadow | living-shadow.glb (38584 B, 4 meshes) | living-shadow.png | 0.4633 × 0.4788 × 1.0, min Z 0.3; variant=ghost, skin(0.05, 0.05, 0.08) |
| Phantom | phantom.glb (38576 B, 4 meshes) | phantom.png | 0.4633 × 0.4788 × 1.0, min Z 0.3; variant=ghost, skin(0.8, 0.85, 0.9) |
| Poltergeist | poltergeist.glb (41052 B, 6 meshes) | poltergeist.png | 0.7679 × 0.4788 × 1.0, min Z 0.3; variant=ghost, props, skin(0.8, 0.85, 0.9) |
| Sluagh (also Celtic & British Isles) | sluagh.glb (53200 B, 7 meshes) | sluagh.png | 0.4455 × 0.4603 × 0.9846, min Z 0.3; variant=ghost, tattered, skin(0.4, 0.45, 0.5) |
| Specter | specter.glb (38576 B, 4 meshes) | specter.png | 0.4633 × 0.4788 × 1.0, min Z 0.3; variant=ghost, skin(0.8, 0.85, 0.9) |
| Storm Wraith | storm-wraith.glb (53208 B, 7 meshes) | storm-wraith.png | 0.4455 × 0.4603 × 0.9846, min Z 0.3; variant=ghost, tattered, skin(0.6, 0.7, 0.8) |

### Golem / construct (10) — all grounded

| creature | GLB | preview | verified dims X×Y×Z (m) |
| --- | --- | --- | --- |
| Bone Golem | bone-golem.glb (90652 B, 30 meshes) | bone-golem.png | 0.8116 × 0.3304 × 1.0, min Z 0.0; variant=bone, skin(0.85, 0.82, 0.7) |
| Brass Automaton | brass-automaton.glb (82676 B, 25 meshes) | brass-automaton.png | 0.8116 × 0.3304 × 1.0, min Z 0.0; variant=brass, skin(0.7, 0.55, 0.2) |
| Crystal Golem | crystal-golem.glb (84168 B, 25 meshes) | crystal-golem.png | 0.8116 × 0.3304 × 1.0, min Z 0.0; variant=crystal, skin(0.65, 0.8, 0.9) |
| Gargoyle | gargoyle.glb (89460 B, 29 meshes) | gargoyle.png | 0.8677 × 0.3027 × 0.9873, min Z 0.0; variant=gargoyle, skin(0.5, 0.5, 0.52) |
| Haunted Armor | haunted-armor.glb (88568 B, 26 meshes) | haunted-armor.png | 0.7089 × 0.2886 × 1.0, min Z 0.0; variant=armor, skin(0.25, 0.25, 0.28) |
| Iron Golem | iron-golem.glb (82680 B, 25 meshes) | iron-golem.png | 0.8116 × 0.3304 × 1.0, min Z 0.0; variant=iron, skin(0.3, 0.3, 0.33) |
| Living Statue | living-statue.glb (82632 B, 25 meshes) | living-statue.png | 0.8116 × 0.3304 × 1.0, min Z 0.0; variant=statue, skin(0.75, 0.75, 0.73) |
| Stone Golem | stone-golem.glb (90260 B, 28 meshes) | stone-golem.png | 0.8116 × 0.3304 × 1.0, min Z 0.0; variant=stone, skin(0.55, 0.55, 0.55) |
| Terracotta Soldier (also Golems & Constructs) | terracotta-soldier.glb (83764 B, 26 meshes) | terracotta-soldier.png | 0.8116 × 0.3304 × 1.0, min Z 0.0; variant=terracotta, skin(0.65, 0.4, 0.25) |
| Ushabti (also Golems & Constructs) | ushabti.glb (83780 B, 26 meshes) | ushabti.png | 0.8116 × 0.3304 × 1.0, min Z 0.0; variant=sand, skin(0.7, 0.62, 0.45) |
