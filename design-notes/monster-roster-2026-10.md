# Monster Roster — A Non-Copyrighted Bestiary for Abysmal

*Researched Oct 11, 2026. For Abysmal — a 2.5D first-person idle dungeon crawler roguelike (Godot 4.7, Android-first). Current live roster is 3 monsters (Slime, Bat, Skeleton, `scripts/enemy.gd`). James's ask: an extensive roster of non-copyrighted monsters, "more and more," ceiling ~1,000 total (not 10,000). This paper is the master list, the system that multiplies it, and an honest note on which of these can ever have real models.*

**Status: DESIGN / ROSTER PAPER — no code changes.** Nothing here is implemented. Entries are written to drop into the `TYPES` dictionary pattern in `enemy.gd` when their turn comes.

---

## 1. How to read this roster

- **~300 base creatures** are listed, organized by family. Each entry: **name**, one-line identity, **depth band**, **combat flavor**.
- **Depth bands:** `T` = Tutorial depths 1–10 · `D` = Delve 11–50 · `Dp` = Deeps 51–200 · `A` = Abyss 200+. A band is where a creature *debuts*; everything also appears deeper via the existing depth scaling.
- **Combat flavors:** swarm (many, weak), skirmisher (fast, light), brute (slow, heavy hits), tank (huge HP, low threat), charger (gap-closing burst), ambusher (first-strike / hidden), ranged, caster (spells/debuffs), controller (gazes, lures, roots, fear), support (buffs/summons allies), flyer, lifedrain, phase (ignores positioning), regen.
- **Variants are a separate system** (Section 5). A "Frost Wolf" is not a roster entry — it's the Wolf entry plus an attunement. That's how 300 becomes ~1,000 without 1,000 models.
- Cross-family duplicates are marked *(see Family N)* and counted **once** in the totals.

---

## 2. IP hygiene — where these come from, and what we refuse to touch

### Safe sources (everything in this roster)

1. **Ancient mythology & world folklore.** Greek, Norse, Egyptian, Mesopotamian, Hindu, Chinese, Japanese, Celtic, Slavic, African, Mesoamerican, Persian, Arabian, and Indigenous American traditions. These works are millennia old; their creatures belong to everyone. Traditional names (Minotaur, Kappa, Leshy, Rakshasa) are used as-is — they are public domain.
2. **Generic archetypes.** Vampire, werewolf, ghost, witch, golem, dragon, demon. No one owns the *idea* of a vampire; specific modern vampires are owned, the archetype is not.
3. **Biblical & medieval material.** Seraphim, ophanim, golems, gargoyles — public domain for centuries.
4. **Real animals & extinct species.** Wolf, cave bear, smilodon, dire wolf (a real extinct species, *Aenocyon dirus*). Nature holds no copyright.
5. **Lovecraft — handled carefully.** Lovecraft died in 1937 and his core mythos is widely treated as public domain, but the estate/licensing picture has historically been murky. This roster therefore uses **generic cosmic-horror archetype names of our own coinage** (Void Horror, Null Seraph) rather than Cthulhu, Deep Ones, or other named Lovecraft entities. Same flavor, zero exposure.

### What we avoid, and why

| Avoid | Why |
|---|---|
| **Beholder, Mind Flayer, Displacer Beast, Owlbear, Rust Monster, Bulette, Gelatinous Cube** | Invented for Dungeons & Dragons (1970s–80s). Several are literally Wizards of the Coast "Product Identity." The single most dangerous shelf to reach onto. |
| **Treant / Ent** | "Treant" was coined by D&D specifically to dodge Tolkien; "Ent" is Tolkien's creation (his estate is active). We say **Walking Oak / Elder Tree**. |
| **Myconid, Ochre Jelly, Black Pudding (as named)** | D&D coinages. Fungus folk and oozes are fine archetypes — under our own names (Fungal Shambler, Amber Ooze). |
| **Mimic (treasure-chest monster)** | Popularized in its chest form by D&D (1977). Object-spirits are ancient though — Japanese **tsukumogami** (Karakasa, Chōchin-obake) do the same job from genuine folklore. |
| **Tiamat as a five-headed dragon, Bahamut as a dragon god** | The *names* are ancient (Mesopotamian goddess; Arabic sea beast); the dragon *forms* are D&D's. We don't use either form. |
| **Slimes with faces / specific video-game monsters** (e.g., anything recognizably from Dragon Quest, Pokémon, Zelda, Final Fantasy) | Modern game IP. Our Slime stays the generic blob it already is — the blob predates all of them. |
| **Named modern cryptids as characters** (Mothman as a character, etc.) | 20th-century folklore is legally greyer than ancient myth. A few appear below only as generic types (e.g., "Death Bat" rather than Camazotz-the-character), and even then as folklore *types*, not the modern copyrighted depictions. |
| **Anything from living authors' worlds** (no Sanderson spren, no Martin wights-by-name, no Rowling anything) | Obvious, but stated for the record. |

**Rule of thumb for future additions:** if the creature's first appearance is a book, game, or film from the last ~100 years with a living rights-holder, it doesn't go in. If shepherds were warning children about it before printing existed, it does.

---

## 3. Depth band philosophy

| Band | Depths | Feel | Roster sources |
|---|---|---|---|
| **T — Tutorial** | 1–10 | Cave wildlife, low undead, minor pests. Teaches combat verbs one at a time. | Cave fauna, vermin, basic undead, goblin-kin, imps |
| **D — The Delve** | 11–50 | The dungeon proper. Tribes, tombs, haunted places, first folklore heavyweights. | Orcs/trolls, Greek & Japanese & Celtic families, constructs, demons |
| **Dp — The Deeps** | 51–200 | Mythic weight. Named traditions' major creatures; petrification, possession, real magic. | Dragons, liches, rakshasa, gorgons, celestials' shadows |
| **A — The Abyss** | 200+ | World-myth tier. Things shepherds *prayed* about. Boss-grade as standard spawns. | Titans, ancient dragons, fallen seraphim, cosmic archetypes |

---
## 4. The base roster

### Family 1 — Oozes & Slimes (8)
*The dungeon's immune system. Slow, honest, everywhere.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Slime | The generic blob. Already in game. | T | brawler |
| Cave Jelly | Translucent sheet-ooze that drops from ceilings. | T | ambusher |
| Amber Ooze | Golden, tar-slow, splits into lesser blobs when struck. | D | tank / splitter |
| Mire Pudding | Swamp-black mass that swallows dropped gear (flavor). | D | tank |
| Acid Blob | Hissing corrosive that eats armor defense. | D | def-shredder |
| Gloom Ooze | Light-drinking shadow slime from the dark bands. | Dp | lifedrain |
| Mercury Slime | Quicksilver-fast, nearly liquid metal. | Dp | skirmisher |
| Primordial Ooze | A cell of the first living thing, still dividing. | A | tank / splitter boss-tier |

### Family 2 — Vermin & Cave Crawlers (16)
*Teaches swarms, venom, and flying in the tutorial band.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Cave Rat | Ordinary rat, dungeon-sized attitude. | T | swarm |
| Rat Swarm | A carpet of them. One HP bar, forty bodies (presentation). | T | swarm |
| Cave Bat | Already in game. | T | flyer / skirmisher |
| Cave Spider | Wall-clinging ambusher with mild venom. | T | ambusher / venom |
| Cave Wasp | Territorial nest-defender. | T | flyer / swarm |
| Cave Scorpion | Armored tail, honest warning colors. | T | venom skirmisher |
| Centipede | Six feet of fast decisions. | T | skirmisher |
| Cave Frog | Bloated, venom-skinned, surprisingly loud. | T | skirmisher |
| Giant Rat | Dog-sized matriarch of the warrens. | T | brute |
| Vampire Bat | Drinks what it wounds. | D | flyer / lifedrain |
| Widow Spider | The venom stops being "mild." | D | venom / ambusher |
| Emperor Scorpion | Chitin like plate mail. | D | tank / venom |
| Stag Beetle | A battering ram with horns. | D | charger |
| Burrow Worm | Erupts from the floor mid-room. | D | ambusher |
| Carrion Worm | Feeds on the dungeon's dead; fights like it too. | Dp | tank |
| Hornet Matriarch | A wasp the size of a hound, with a court. | Dp | flyer / support (summons) |
| Ōmukade | The giant centipede of Japanese folklore, big enough to hunt dragons. | Dp | charger / brute *(also Family 10)* |

### Family 3 — Beasts (23)
*Real animals and their extinct, bigger cousins. No magic — just teeth.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Wolf | Pack hunter of the upper caves. | T | pack skirmisher |
| Wild Boar | All charge, no brakes. | T | charger |
| Hyena | Laughing pack opportunist. | T | pack skirmisher |
| Giant Serpent | Ten feet of patient muscle. | T | ambusher |
| Grizzly | A wall that stands up. | T | brute |
| Dire Wolf | The real Ice-Age wolf, heavier in every way. | D | pack brute |
| Warhound | Armored, trained, escaped from someone. | D | charger |
| Cave Bear | Bigger than the grizzly and it knows the dark. | D | tank / brute |
| Razorback | Scarred boar whose charges dent stone. | D | charger / brute |
| Panther | You see the eyes first, if you're lucky. | D | ambusher |
| Cave Python | Squeezes first, swallows later. | D | tank / ambusher |
| Cave Ape | Territorial, tool-curious, furious. | D | brute |
| Baboon Troop | A screaming committee of thieves. | D | swarm / skirmisher |
| Crag Ram | Headbutts echo two rooms away. | D | charger |
| Deep Stag | Antlers like roots, charges like weather. | D | charger |
| Grotto Bull | Blind, massive, charges at sound. | D | charger / brute |
| Blind Mole | Burrowing brute that hunts by tremor. | D | ambusher |
| Crocodile | A log with opinions. | D | ambusher / tank |
| Lion | Pack royalty on a hunt. | D | brute / pack |
| Sabertooth | Ice-Age ambush perfected. | Dp | ambusher / charger |
| Tiger | The panther, upgraded in every stat. | Dp | ambusher |
| Cave Hyena | Extinct giant hyena; crushes bone and armor alike. | Dp | brute |
| Pale Horse | Gaunt, silent, wrong. A bad omen with hooves. | Dp | charger |

### Family 4 — Goblin-Kin & Cave Folk (12)
*Folklore's small peoples, from German mine-spirits to Celtic murder-goblins.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Kobold | German mine-spirit; sets traps, resents miners. | T | trapper / swarm |
| Goblin | The generic cave goblin. Cowardly alone, brave in dozens. | T | skirmisher / swarm |
| Goblin Sneak | The one with the knife, behind you. | T | ambusher |
| Goblin Shaman | Bone-rattle spell-slinger of the tribe. | D | caster / support |
| Hobgoblin | The disciplined, militarized cousin. | D | brute |
| Bugbear | The original bogey — big, hairy, waits in the dark. | D | ambusher / brute |
| Boggart | A household spirit gone feral in the deep. | D | ambusher |
| Redcap | Celtic goblin that dyes its cap in blood. Must keep killing. | D | skirmisher (speed) |
| Spriggan | Cornish treasure-guardian, swells to giant size when angered. | D | tank / guardian |
| Gremlin | 1920s RAF folklore, naturalized in the deep; breaks your gear's day. | D | saboteur (debuffs) |
| Púca | Celtic shapeshifter; never fights in the same shape twice. | Dp | shapeshifter skirmisher |
| Goblin Champion | The tribe's answer to adventurers. | Dp | brute |

### Family 5 — Orcs, Trolls & Giant-Kin (15)
*The heavy infantry of the Delve. "Orc" is Old English (Beowulf's orcneas); the giants are Norse.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Orc | Brutal raider of the middle depths. | D | brute |
| Orc Berserker | Pain is a rumor to this one. | D | charger / brute |
| Half-Ogre | Half the size, most of the temper. | D | brute |
| Ogre | Fairy-tale man-eater, full-sized. | D | brute / tank |
| Marsh Troll | Regenerating ambusher of the wet dark. | D | regen / ambusher |
| Troll | Norse bridge-and-mountain troll, dungeon branch. | D | tank / regen |
| Orc Shaman | Calls on older, worse gods. | Dp | caster |
| Cave Troll | The troll, scaled for the Deeps. | Dp | tank / regen |
| Ettin | Two heads, two attacks, zero agreement. | Dp | brute (double strikes) |
| Cyclops | One eye, thrown boulders, no depth perception jokes. | Dp | brute / ranged |
| Hill Giant | Throws rocks, carries a tree. | Dp | tank |
| Stone Giant | Patient as geology. | Dp | tank |
| Frost Giant | Jötunn of the cold dark. | Dp | brute / frost caster |
| Ogre Mage | An ogre that learned magic. Everyone's problem now. | A | caster / brute |
| Fire Giant | Jötunn of the burning deep, Surtr's kin in kind if not name. | A | brute / fire |

### Family 6 — The Undead (23)
*The largest family, as it should be — the dungeon is mostly a graveyard that hasn't admitted it.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Skeleton | Already in game. The tutorial bruiser. | T | brawler |
| Skeleton Archer | Same bones, longer arguments. | T | ranged |
| Zombie | Slow, tireless, arrives in groups. | T | tank / swarm |
| Skeleton Knight | Rusted plate over old loyalties. | D | tank |
| Ghoul | Arabian folklore's graveyard eater, fast and starving. | D | skirmisher |
| Barrow Wight | Old English grave-dead, guarding older gold. | D | brute |
| Specter | A death that didn't finish happening. | D | phase skirmisher |
| Poltergeist | Throws the room at you. | D | controller (ranged debris) |
| Draugr | Norse sea-and-barrow revenant, swelling with malice. | D | tank / brute |
| Mummy | Bandaged tomb-royalty with a curse for a voice. | D | tank / curse caster |
| Phantom | Stronger specter; remembers being someone. | Dp | phase |
| Banshee | Irish death-messenger; the wail is the weapon. | Dp | caster (AoE scream) |
| Vampire | The archetype itself, no specific count or sparkle. | Dp | lifedrain / caster |
| Strigoi | Romanian restless dead, vampire's rougher cousin. | Dp | lifedrain skirmisher |
| Jiangshi | Chinese hopping vampire, stiff-limbed and relentless. | Dp | charger / tank |
| Vetala | Hindu corpse-spirit that wears the dead and talks. | Dp | caster / possessor |
| Revenant | Came back for one reason. You're the reason. | Dp | relentless charger |
| Sluagh | Celtic host of the unforgiven dead, a flock of ruin. | Dp | flyer / swarm |
| Wight Lord | What barrow wights kneel to. | A | brute / caster |
| Lich | A sorcerer who filed death under "later." | A | caster, boss-tier |
| Dullahan | Ireland's headless rider, carrying his head and your name. | A | charger / caster |
| Gashadokuro | Japan's giant skeleton, born of mass graves, audible by its teeth. | A | tank, boss-tier |
| Penanggalan | SE-Asian flying terror of the night bands. | A | flyer / ambusher |

### Family 7 — Greek & Mediterranean Myth (17)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Satyr | Goat-legged reveler; the pipes are not for dancing down here. | D | skirmisher / caster |
| Harpy | Filth, wings, and a voice like tearing cloth. | D | flyer / skirmisher |
| Centaur | Archer cavalry of the deep meadows. | D | ranged / charger |
| Siren | The song is the hook; the rocks are the point. | D | controller (lure) |
| Hellhound | Underworld kennel-stock, fire-breathed. | D | pack charger |
| Minotaur | The labyrinth's tenant, finally at home. | D | charger / brute |
| Stymphalian Bird | Bronze-feathered, arrow-shedding flock terror. | D | flyer / ranged |
| Bronze Bull | Colchis fire-breather in bull shape. | Dp | charger / fire |
| Gorgon | Look at her and stay a while. Forever. | Dp | controller (petrify) |
| Chimera | Three animals' worth of bad day in one body. | Dp | brute / multi-attack |
| Sphinx | Answer the riddle or feed the monument. | Dp | caster / controller |
| Griffin | Eagle-lion, hoard-proud and dive-happy. | D | flyer / charger |
| Manticore | Persian man-eater; shoots its tail spines like a bow. | Dp | ranged / flyer |
| Lamia | Serpent-woman who was cursed before curses were fashionable. | Dp | caster |
| Empusa | Bronze-legged shapeshifter of Hecate's retinue. | Dp | shapeshifter skirmisher |
| Nemean Lion | Hide no blade has ever pierced. (Ours can be pierced. Eventually.) | Dp | tank |
| Hydra | Cut one head, argue with two. | A | regen tank, boss-tier |

### Family 8 — Norse & Germanic (10 new; Draugr, Jötnar cross-listed)
*Draugr — see Family 6. Frost/Fire Giants — see Family 5.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Sea Serpent | The sailor's rumor, verified at depth. | Dp | aquatic charger |
| Nixie | Germanic water-spirit; drowns the curious politely. | D | aquatic caster |
| Hulder | Forest spirit whose beauty has one flaw, hidden. | D | controller / caster |
| Mare | The nightmare itself, sitting on your chest at 3 AM. | Dp | phase caster (sleep) |
| Dark Elf (Dökkálfar) | Norse dark elf of the deep earth. | Dp | skirmisher / caster |
| Alfar Raider | Pale elf-raider from brighter, colder halls. | D | ranged |
| Fallen Valkyrie | A chooser of the slain who stopped asking permission. | A | flyer / brute / caster |
| Great Wolf | Fenrir's lesser kin — "lesser" doing heavy lifting. | A | charger, boss-tier |
| Lindworm | Wingless Norse dragon-serpent, poison-breathed. | Dp | brute *(also Family 25)* |
| Kraken | Norwegian folklore's ship-ending island of tentacles. | A | aquatic tank, boss-tier *(also Family 24)* |

### Family 9 — Egyptian & Near East (9 new; Mummy cross-listed)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Scarab Swarm | Jewel-bright, tomb-hungry. | T | swarm |
| Asp | Small, sacred, final. | T | venom skirmisher |
| Jackal Guardian | Tomb-watchers with jackal heads and old orders. | D | skirmisher |
| Guardian Scorpion | Set at the door like a bronze lock. | D | tank / venom |
| Serpopard | The serpent-necked leopard of ancient carvings. | Dp | brute |
| Sha Beast | The Set-animal — no natural species, entirely attitude. | Dp | skirmisher |
| Falcon Sphinx | Hieracosphinx: hawk head, lion body, sky's patience. | Dp | flyer / caster |
| Devourer Beast | Ammit's kind — crocodile, lion, and hippo in one judgment. | A | brute |
| Ushabti | Funerary servant-figure, still serving. | D | tank / guardian *(also Family 22)* |

### Family 10 — Japanese Yōkai (12 new; Gashadokuro & Ōmukade cross-listed)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Karakasa | Tsukumogami: a one-eyed umbrella spirit, hopping and mischievous-turned-mean. | T | ambusher |
| Chōchin-obake | A paper lantern, a century old, with a tongue and opinions. | D | caster |
| Kappa | River imp that wrestles, grapples, and loves cucumbers more than you. | D | aquatic tank / grappler |
| Oni | The ogre-demon of Japanese legend, iron club included. | D | brute |
| Bake-danuki | Shapeshifting tanuki with a drum belly and a con artist's heart. | D | shapeshifter skirmisher |
| Kasha | Corpse-stealing fire cat of the funeral roads. | D | fire skirmisher |
| Kitsune | Fox spirit; illusions first, teeth second. | D | caster (illusion) |
| Tengu | Mountain goblin-bird, swordsmaster and storm-bringer. | Dp | flyer / caster |
| Yuki-onna | The snow woman; a blizzard with a face. | Dp | frost caster / controller |
| Jorōgumo | Four hundred years a spider, now a beautiful trap. | Dp | caster / ambusher |
| Nure-onna | Serpent-woman of the shores, always thirsty. | D | aquatic ambusher |
| Nue | The nightmare chimera whose cry means ill omens. | Dp | flyer / caster |
| Tsuchigumo | The earth spider, big as a house, old as grudges. | A | tank, boss-tier |

### Family 11 — Celtic & British Isles (7 new; Banshee, Dullahan, Sluagh, Redcap, Púca, Spriggan cross-listed)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Kelpie | A beautiful water horse. The beauty is the trap. | D | aquatic charger |
| Merrow | Irish sea-people, drowned-curious. | D | aquatic caster |
| Selkie | Seal-folk, feral when their skin is stolen. | D | aquatic skirmisher |
| Cat Sìth | The fairy cat, black with a white blaze, soul-counter. | D | ambusher skirmisher |
| Bauchan | A hobgoblin "helper" whose help you cannot refuse. | D | brute |
| Fachan | One arm, one leg, one eye, no mercy — Scottish highland terror. | Dp | brute |
| Afanc | Welsh lake monster; floods are its mood swings. | Dp | aquatic tank |
| Bean-nighe | The washer at the ford, rinsing the clothes of the soon-dead. | Dp | caster (omen debuffs) |

### Family 12 — Slavic (11)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Domovoi | House spirit, angered past politeness by the move underground. | T | skirmisher |
| Kikimora | Swamp-and-cellar spirit; tangles, trips, torments. | D | ambusher / caster |
| Rusalka | A drowned spirit whose song is a drowning too. | D | aquatic caster (lure) |
| Vodyanoy | The water's landlord, frog-faced and owed. | D | aquatic tank |
| Striga | Two-hearted, two-souled, hunts by night. | D | lifedrain skirmisher |
| Leshy | The forest's warden, size-shifting and path-scrambling. | Dp | plant caster / controller |
| Alkonost | Bird of paradise whose song makes you forget everything, pleasantly. | Dp | caster / controller |
| Gamayun | Prophetic bird; knowledge with talons. | Dp | caster / support |
| Mora | Night-hag of bad dreams and worse sleep. | Dp | phase caster |
| Zmey | Three-headed Slavic dragon (heads negotiable upward). | Dp | brute / caster *(also Family 25)* |
| Firebird | The Zhar-ptitsa — a living prize of light. Fights like it knows it. | A | flyer / fire caster |

### Family 13 — Mesopotamian (8)
*The oldest written monsters on Earth. If it's here, someone carved it in stone 4,000 years ago.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Cedar Guardian | Humbaba's kind: the forest's appointed monster. | Dp | brute |
| Galla | Underworld demon-draggers of the dead. | Dp | charger |
| Scorpion Man | Aqrabuamelu, who guards where the sun goes. | Dp | ranged / tank |
| Ugallu | Lion-headed storm demon with a dagger and a job. | Dp | brute |
| Lamassu | Winged bull with a man's head and a god's patience. | A | tank / caster, guardian |
| Mušḫuššu | The dragon of Babylon's gate, scaled and horned. | A | brute |
| Anzu | The storm-bird who stole the Tablet of Destinies. | A | flyer / caster |
| Asag | Plague-demon so foul the rivers boiled. | A | brute / plague caster |

### Family 14 — South Asian (8 new; Vetala cross-listed, Naga shared with Family 24 flavor)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Naga | Serpent-people of the watery underworld, jewel-hooded. | D | caster / tank |
| Yaksha | Wild nature-spirit, guardian turned territorial. | D | brute / guardian |
| Bhūta | A ghost that casts no shadow because it *is* one. | D | phase |
| Piśāca | Flesh-eating night fiend, ghoul's older cousin. | Dp | skirmisher |
| Rakshasa | The shapeshifting tiger-demon of epic legend. | Dp | shapeshifter / caster / brute |
| Makara | Crocodile-elephant of the deep waters. | Dp | aquatic tank |
| Asura | A power that heaven itself had to argue with. | A | brute / caster |
| Garuda | The great bird, serpent-eater, sky's enforcer — feral branch. | A | flyer / charger |

### Family 15 — Chinese & East Asian (8 new; Jiangshi cross-listed)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Terracotta Soldier | The First Emperor's clay guard, on eternal shift. | D | tank *(also Family 22)* |
| Mountain Yaoguai | A wild demon-beast of the high places. | D | brute |
| Xiezhi | The one-horned truth-goat, corrupted into judging everyone guilty. | Dp | charger |
| Hulijing | Fox spirits; nine tails at the Abyss end of the family. | Dp | caster (illusion) |
| Mogwai | Cantonese demon of storm nights. | Dp | skirmisher / caster |
| River Long | A Chinese dragon of deep water — not a beast, a weather system. | Dp | flyer / caster *(also Family 25)* |
| Taotie | The gluttonous face on ancient bronzes, given a body and appetite. | A | tank (devourer) |
| Hundun | Faceless primordial chaos, a winged confusion that eats light. | A | tank / controller |
| Qilin, Corrupted | The gentlest omen in Chinese lore — wrong, down here. | A | charger / caster |

### Family 16 — Mesoamerican & Andean (6)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Ahuizotl | Water beast with a hand on its tail, for grabbing. | Dp | aquatic ambusher |
| Death Bat | The bat of the underworld's house (Camazotz's kind, kept generic). | Dp | flyer / lifedrain |
| Nagual | A sorcerer in animal shape, or an animal in sorcerer's. | Dp | shapeshifter skirmisher |
| Storm Wraith | A rain-god's discarded anger, still raining. | Dp | storm caster |
| Tzitzimitl | Star demoness who waits to devour the sun. | A | caster, boss-tier |
| Cipactli Brood | Spawn of the primordial crocodile the world was built on. | A | aquatic tank |

### Family 17 — African Traditions (6)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Tokoloshe | The small terror of Zulu & Xhosa lore, sent by malice. | D | ambusher skirmisher |
| Adze | Ewe firefly-vampire; slips through keyholes as light. | D | lifedrain skirmisher |
| Impundulu | The lightning bird; its eggs are thunder. | Dp | flyer / storm caster |
| Sasabonsam | Winged forest ogre with iron teeth, Asante lore. | Dp | flyer / ambusher |
| Mami Wata | Water spirit of wealth and drowning, half serpent. | A | aquatic caster |
| Inkanyamba | The great serpent of the falls, whose temper is the weather. | A | aquatic brute |

### Family 18 — Fey & Nature Spirits (11 new; Púca, Spriggan, Redcap cross-listed)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Pixie | Small, winged, and entirely out of line. | T | flyer / caster (nuisance) |
| Sprite | A darting mote with a needle sword. | T | flyer skirmisher |
| Bramble Imp | A thorn-bush that walks off with things. | T | plant skirmisher |
| Brownie | Household helper; this one's employment ended badly. | T | skirmisher |
| Dryad | A tree's soul, armed with the whole tree's grievances. | D | plant caster |
| Naiad | Spring-and-stream spirit; the water obeys her. | D | aquatic caster |
| Sylph | Paracelsus's air spirit, all grace and edge. | D | flyer caster |
| Faun | Roman goat-spirit, wilder than its Greek cousin. | D | skirmisher |
| Will-o'-wisp | A light that leads travelers wrong on purpose. | D | flyer / controller (path-lure) |
| Changeling | The fair folk's substitute, grown up wrong. | Dp | shapeshifter ambusher |
| Elder Dryad | A dryad as old as the dungeon's first tree. | Dp | caster / tank |

### Family 19 — Demons, Devils & the Damned (10 new; Ghoul, Hellhound cross-listed)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Imp | Everyone's first demon. Small horns, big plans. | T | flyer / caster |
| Possessed Cultist | The robes came with something already inside. | D | caster / skirmisher |
| Succubus | Medieval dream-demon; the dream fights back. | Dp | controller / caster |
| Incubus | The counterpart, heavier on the nightmare. | Dp | skirmisher / caster |
| Pit Brute | Hell's generic heavy labor. | Dp | brute |
| Djinn | Bound once, blamed on you personally. | Dp | caster |
| Larva of the Damned | A soul reduced to appetite, arriving in dozens. | Dp | swarm |
| Ifrit | Arabian fire-demon of smoke and old grudges. | A | fire brute / caster |
| Marid | The mightiest djinn kind, water-aspected and proud. | A | aquatic caster / tank |
| Contract Devil | It has paperwork. The paperwork has teeth. | A | caster / controller |
| Shaitan | A devil of the old desert kind. | A | brute / caster |

### Family 20 — Celestials & the Fallen (6 new; Fallen Valkyrie cross-listed)
*At Abyss depth, the things hunting the demons start hunting you.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Deva | A celestial of Hindu & Buddhist cosmology, off-mission. | A | caster |
| Seraph | Six-winged and burning; "fear not" was not a promise. | A | flyer / caster |
| Ophanim | The wheel of eyes and fire. Biblical, and deeply strange. | A | controller / caster |
| Watcher (Grigori) | The angels who came down and never went back. | A | caster / controller |
| Fallen Angel | Wings intact, orders rescinded, grudge eternal. | A | flyer / brute / caster |
| Ashen Seraph | A seraph that burned and kept going. | A | brute / caster |

### Family 21 — Elementals & Primal Spirits (9 new; Sylph cross-listed)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Gnome | Paracelsus's earth-spirit — not the garden ornament, the landlord. | T | earth skirmisher |
| Salamander | The fire-lizard that lives *in* flame, unbothered. | D | fire skirmisher |
| Fire Elemental | A bonfire that decided to stand up. | D | fire caster / brute |
| Water Elemental | A wave with intent. | D | water tank |
| Earth Elemental | The floor, objecting. | D | earth tank |
| Air Elemental | Weather indoors. | D | flyer (fast) |
| Undine | Paracelsian water spirit given form and grievance. | D | water caster |
| Storm Elemental | A thunderhead at ground level. | Dp | storm caster |
| Magma Elemental | The mountain's blood, walking. | Dp | fire/earth tank |
| Frost Elemental | Winter, concentrated. | Dp | frost caster |

### Family 22 — Golems & Constructs (9 new; Ushabti, Terracotta Soldier cross-listed)
*Golem is Jewish folklore (Prague's is the famous one); the rest are animated matter of every tradition.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Clay Golem | River-mud and a written word. | D | tank |
| Gargoyle | French legend's dragon become architecture; sleeps as stone. | D | flyer / ambusher |
| Living Statue | It was a statue. Past tense. | D | tank |
| Haunted Armor | Nobody inside. Still offended. | D | tank / brute |
| Stone Golem | The clay golem, promoted. | Dp | tank |
| Bone Golem | Built from the dungeon's leftovers. All of them. | Dp | brute |
| Brass Automaton | Clockwork soldier of a drowned empire. | Dp | brute |
| Iron Golem | The golem line's endgame. | A | tank |
| Crystal Golem | Geode-hearted, refracts spells and tempers. | A | tank / caster |

### Family 23 — Plants & Fungi (8 new; Leshy, Dryads cross-listed)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Grotto Snapper | A stationary jaw disguised as decoration. | T | stationary ambusher |
| Mandrake | Pull it and hear the scream. It's already pulled. | T | caster (scream) |
| Vampire Vine | Drinks through the skin, politely, over hours. | D | grappler / ambusher |
| Fungal Shambler | A corpse the mushrooms finished first. (Our name — not "myconid.") | D | tank / spore |
| Walking Oak | An elder tree that walks its grievance to you. (Not "treant"/"ent" — see §2.) | D | tank |
| Thornhound | A hunting pack-beast grown, not born. | D | skirmisher |
| Spore Servant | The shambler's congregation. | Dp | swarm / caster |
| Corpse Flower | Rafflesia's dungeon cousin; the smell is a weapon system. | Dp | stationary controller |

### Family 24 — Aquatic & the Drowned Deep (6 new; Kraken, Sea Serpent, Kelpie, Merrow, Rusalka, Naga, Makara cross-listed)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Cave Moray | Six feet of teeth in a rock crack. | D | ambusher |
| Drowned Sailor | Still on watch, centuries after the water. | D | undead skirmisher |
| Giant Octopus | Eight arguments, all grapples. | Dp | grappler / tank |
| Deep Crab | A siege engine that grew in a shell. | Dp | tank |
| Lanternjaw | Abyssal angler horror — our coinage for a real deep-sea archetype. | A | ambusher |
| World Wurm | The serpent the maps end at. | A | tank, boss-tier |

### Family 25 — Dragons & Great Serpents (10 new; Hydra, Zmey, Lindworm, River Long cross-listed)
*Dragon is the most public-domain word in fantasy. We use the whole world's dragon traditions, not any one game's.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Drake | Lesser dragon, all appetite and wing. | D | flyer / brute |
| Wyvern | Two legs, one stinger, endless spite. | D | flyer / venom charger |
| Cockatrice | The serpent-egg rooster; its look is a slow statue-maker. | D | flyer / controller |
| Jaculus | The javelin-serpent; launches itself horn-first from trees. | D | flyer / charger |
| Wyrm | The old earth-dragon: no wings, all hoard and hunger. | Dp | burrower tank |
| Basilisk | King of serpents; the gaze problem, original edition (pre-dates every game). | Dp | controller (petrify) / venom |
| Amphiptere | Winged serpent of old bestiaries. | Dp | flyer |
| Peluda | The shaggy dragon of French rivers, quill-spined. | Dp | aquatic / poison brute |
| Elder Wyrm | A dragon old enough to have a geology. | A | brute / caster, boss-tier |
| Tarasque | The French river-dragon six saints couldn't out-fight, only out-pray. | A | tank, boss-tier |

### Family 26 — Humans & the Damned Living (11)
*Sometimes the monster is a person with a knife and a debt.*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Brigand | Toll-collector of lightless roads. | T | skirmisher |
| Grave Robber | Here for the same gold as you, fewer scruples. | T | ambusher |
| Cultist | Found a god in the deep. It answered. | D | caster |
| Witch | The generic, ancient article: cunning-folk gone to the dark. | D | caster / controller |
| Berserker | Norse fury, human-shaped. | D | charger / brute |
| Bandit Chief | A brigand with subordinates and standards. | D | brute / leader |
| Mad Alchemist | Throws his research notes. They're flasks. | D | ranged (alchemical) |
| Necromancer | Raises the dungeon's dead as staff. | Dp | caster / support (summons) |
| Warlock | A cultist who negotiated better terms. | Dp | caster |
| Plague Bearer | Carries the deep's fevers like a profession. | Dp | controller (disease aura) |
| Fallen Knight | Swore an oath once. Ask the armor how it went. | Dp | tank / brute |

### Family 27 — Sky & Storm (5 new; Harpy, Griffin, Stymphalian Bird, Anzu, Firebird, Garuda, Impundulu cross-listed)

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Storm Crow | Thunder's advance scouts, in murders. | D | flyer / swarm |
| Roc | The Arabian giant bird; elephants are its portion size. | A | flyer / tank |
| Phoenix | Greek-Egyptian fire-bird; killing it is a temporary arrangement. | A | flyer / fire caster (rebirth) |
| Thunderbird | The storm-being of Indigenous North American traditions. | A | flyer / storm caster |
| Simurgh | Persia's great bird, older than empires. | A | flyer / caster |
| Ziz | The Hebrew sky-behemoth, counterpart to Leviathan. | A | flyer / brute |

### Family 28 — The Abyssal & Cosmic (9)
*All names our own coinage for archetypes older than print — deliberately avoiding any modern author's named entities (see §2).*

| Name | Identity | Band | Flavor |
|---|---|---|---|
| Living Shadow | A shadow whose owner died at noon. | Dp | phase ambusher |
| Titan | Greece's first generation, at human-hurting scale. | Dp | brute |
| Void Horror | It is shaped like the part of the dark you're not looking at. | A | controller |
| Null Seraph | A choir position, emptied. | A | caster |
| Entropy Wraith | What's left when a ghost gives up. | A | phase caster |
| Star Horror | It fell a long way to be here. | A | brute |
| The Hollow Choir | Many voices, one hunger, no singers. | A | caster / swarm |
| Ashen Titan | A titan that burned with its world and kept walking. | A | tank, boss-tier |
| Ur-Dragon | Not the first dragon. The reason there are dragons. | A | caster / brute, boss-tier |

**Base roster total: ≈300 unique creatures** (cross-listed entries counted once).

---

## 5. Named apex bosses — public-domain legends

One-off named encounters for milestone depths, Delve Endlessly capstones, and horde-floor finales. All are figures of public-domain myth — using them as *named characters* is exactly what folklore is for. (In-game these ride the matching base type with a name, a title, and multiplied stats — no unique models required.)

| Boss | Source | Base type | Note |
|---|---|---|---|
| **Cerberus** | Greek | Hellhound | Three heads, snake tail, the original door guard. |
| **Medusa** | Greek | Gorgon | The gorgon whose name survived. |
| **Typhon** | Greek | Ur-Dragon class | The monster the gods themselves fled. |
| **Echidna** | Greek | Lamia class | "Mother of Monsters" — a fitting depth-100 tribute. |
| **Fenrir** | Norse | Great Wolf | The wolf the gods chained. Chains sold separately. |
| **Jörmungandr** | Norse | World Wurm | The serpent that circles the world. |
| **Surtr** | Norse | Fire Giant | The fire that ends a world. |
| **Fafnir** | Norse | Elder Wyrm | A dwarf, then a dragon, then a hoard with teeth. |
| **Baba Yaga** | Slavic | Witch | The hut has chicken legs; the witch has your number. |
| **Koschei the Deathless** | Slavic | Lich | His death is hidden elsewhere. Bring time. |
| **Humbaba** | Mesopotamian | Cedar Guardian | From the oldest written story we have (Gilgamesh, public domain for ~4,000 years). |
| **Shuten-dōji** | Japanese | Oni | The drunken demon king of Mt. Ōe. |
| **Yamata no Orochi** | Japanese | Hydra | Eight heads, eight tails, one legendary appetite. |
| **Ravana** | Hindu epic | Rakshasa | The ten-headed king of Lanka (Ramayana, ancient & public domain). |
| **Anzu** | Mesopotamian | Anzu | Stole the Tablet of Destinies once already. |
| **The Tarasque** | French | Tarasque | As a *named individual* for a milestone floor. |

---
## 6. The variant system — how ~300 becomes ~1,000

Nobody models 1,000 monsters. Instead, four **variant axes** multiply the base roster. Each axis is a data-and-presentation layer over a base type — exactly the shape `enemy.gd` already uses (one `TYPES` entry × depth multipliers), extended.

### The four axes

1. **Attunement (6)** — Ember / Frost / Storm / Venom / Radiant / Void. Presentation: material tint + particle color + one rider effect (burn DoT, slow, chain spark, poison, blind, lifedrain). Ties directly into the Oct 10 elements decision (damage types + resistances + interactions — an Ember creature in a flooded room is a *system*, not a skin).
2. **Corruption (2)** — Grave-touched (undead version of a living creature) / Hollow (void-eroded, phase-touched). Presentation: desaturated palette, eye-glow, undead resistances. Lore-free: the dungeon *ruins* things.
3. **Stature (2)** — Dire (×1.4 scale, +HP/ATK) / Young (×0.7 scale, swarm-spawned). Presentation: transform scale only. Beasts and brutes take Dire; anything takes Young when a floor wants a swarm.
4. **Rank (3)** — Champion (elite: +stats, larger, crown/trim presentation) / Horde Lord (spawns with a pack) / **Named Apex** (Section 5's bosses). Rank is a stat-and-presentation layer, not new content — it applies to *everything* and is therefore **not counted** in the math below (honesty: it would double-count).

### The math (counted conservatively)

| Layer | Rule | Adds | Running total |
|---|---|---|---|
| Base roster | Section 4, unique types | 300 | **300** |
| Attunements | ~60% of base (180 types) can sensibly carry attunements; avg. 2 sensible attunements each (a Frost Wolf yes, a Frost Phoenix no) | +360 | **660** |
| Corruption | ~40% of base (120 living types) × 1 corruption form each | +120 | **780** |
| Stature | ~45% of base (135 types) × 1 variant each (Dire *or* Young, where sensible) | +135 | **915** |
| Named apex bosses | Section 5 | +16 | **931** |
| Delve Endlessly exclusives | Endlessly-only reskins/combos (attuned apex forms, Hollow named) — a deliberate reserve so the mode James greenlit Oct 11 has its own shelf | ~70 | **≈1,000** |

**The honest summary:** ~300 base creatures, **~300 models at the absolute ceiling** (fewer in practice — stature and attunement variants reuse the base model), and ≈1,000 distinct roster *entries* a player can encounter, name, and fight. The ceiling James set (~1,000, not 10,000) is met by the system, not by an art team that doesn't exist.

---

## 7. Model reality check — what can actually be seen on screen

Abysmal's rule stands: **staged CC0 assets only, no AI-generated assets**, primitive fallback when no model exists. Status key: ✅ verified to exist as CC0 · 🔍 plausible sibling in a verified CC0 line — exact contents need a sourcing check before download · 🧊 no known CC0 low-poly source — primitive/procedural build (the route the project already uses for chests/props).

| Family | Status | Basis |
|---|---|---|
| Slimes, Bat, Skeleton (live 3) | ✅ | Already staged from Quaternius *LowPoly Animated Monsters* (CC0). The same pack's tags include **Dragons** — a dragon sibling is plausible in this exact line 🔍 for Family 25 starters. |
| Vermin (rat, spider, snake, wasp, frog) | ✅ | Quaternius *Animated Easy Enemies* (itch.io tags verified: rat, spider, snake, wasp, frogs; CC0, movement/attack/death clips). Five of Family 2 covered by one pack. |
| Beasts (quadrupeds) | 🔍 | Quaternius *Low Poly Animated Animals* exists and is CC0 (a horse from it is in use by other Godot projects). Whether it carries wolf/bear/boar-grade predators needs a sourcing check; the *Dinosaurs* pack (CC0, verified) can cover "primordial" deep variants as stand-ins meanwhile. |
| Human foes, Haunted Armor, Fallen Knight | 🔍 | Quaternius *Animated Knight* (CC0) verified; KayKit character packs (CC0 — Adventurers pack verified: rigged humans, 75 animations) plausibly cover cultists/brigands/witches via robe-and-hood variants. Verify contents before relying on it. |
| Undead — Zombie | ✅/🔍 | Kenney *Animated Characters 3* is tagged zombie/survivor and CC0-listed. KayKit's line includes skeleton characters used by other projects (four skeleton variants) — 🔍 verify the exact pack before download. |
| Goblin-kin, Orcs, Trolls, Giants | 🧊 | A Quaternius goblin model circulates as CC0 in other projects' credits 🔍, but no verified full "tribes" pack. Plan: primitive builds, scaled/tinted per type (the stature axis does most of the visual work). |
| Undead (rest), Ghosts/phase types | 🧊 | Phase creatures are the *cheapest* primitives in the game: a translucent billboard-ish shroud form reads perfectly in first person. Procedural. |
| Greek / Norse / Egyptian / Yokai / Celtic / Slavic / Mesopotamian / South Asian / Chinese / Mesoamerican / African / Fey / Celestial families | 🧊 | No known CC0 low-poly packs cover these traditions. This is the roster's long tail: primitive/procedural silhouettes (the game's existing fallback), prioritized by how iconic the silhouette is (Minotaur horns, Kappa dish-head, Dullahan-with-head all read at phone distance from primitives). |
| Dragons | 🔍/🧊 | See Slimes row — one Quaternius-line dragon may exist; everything beyond it (wyvern/wyrm/long silhouettes) is procedural or scaled-primitive work. |
| Elementals, Golems, Plants | 🧊 | Procedural by nature — an elemental *is* a particle system wearing a silhouette; golems are stacked-primitive naturals. Arguably better procedural than modeled. |
| Constructs (automatons) | 🔍 | Quaternius robot packs (CC0) are sci-fi in flavor; a brass reskin is possible but anachronistic — primitive preferred, robot line only if James likes the joke. |

**Rollout reality:** the first real expansion wave should be the ✅/🔍 families — Vermin (one pack, +5 types), Zombie, Knight-armor humans, a Dragon — roughly **+10–14 modeled types** for near-zero art risk. Everything else ships on primitives and gets modeled opportunistically if a CC0 source surfaces. The variant system was designed so tint/scale/material carries identity where models can't.

---

## 8. Suggested rollout order (when James greenlights build work)

1. **Wave 1 (models exist):** Cave Rat, Cave Spider, Giant Serpent (easy-enemies line), Zombie, Cave Wolf (primitive pending animal-pack check), Skeleton Archer (skeleton reskin/rig reuse).
2. **Wave 2 (tutorial completion):** the rest of band T — Goblin line, Kobold, Imp, Pixie, Scarab Swarm, Mandrake, Brigand, Domovoi, Gnome. Tutorial band goes 3 → ~20 types.
3. **Wave 3 (Delve identity):** Orc/Troll/Goblin-kin blocks + Greek and Yokai headliners (Minotaur, Harpy, Oni, Kappa).
4. **Wave 4 (variants on):** attunement system + elements integration (Oct 10 decision), corruption forms.
5. **Wave 5 (Deeps & Abyss):** dragons, liches, celestials, cosmic family, named apex bosses, Delve Endlessly exclusives.

---

## Design takeaways

1. **Folklore is the deepest free content library on Earth.** ~300 distinct, evocative, legally-clean creatures without inventing a single name from whole cloth — and players arrive already knowing what a banshee *is*. That recognition is free game design.
2. **The roster is wide so the variant system can be honest.** Attunements/corruptions multiply *encounters*, not art debt: ≈1,000 roster entries stand on ~300 base builds, most of them primitives.
3. **Depth bands are a curriculum.** Tutorial = cave wildlife; Delve = the world's folklore middleweight class; Deeps = mythic heavyweights; Abyss = the figures whole religions were about. Power fantasy reads as *mythology deepening*, which fits Abysmal's "depth 10 is only the tutorial / 100s then 1,000s of depths" vision.
4. **Named bosses are free drama.** Cerberus, Fafnir, Baba Yaga, Koschei — public-domain celebrities that cost no model and no license, deployed as stat-and-name layers.
5. **IP hygiene is a feature, not a constraint.** Every exclusion in §2 (beholder, treant, myconid…) has a folklore equivalent that's older, stranger, and ours forever.

## Open questions for James

1. **Which families excite you?** The rollout order above is my guess — if one tradition (Yōkai? Slavic? Mesopotamian, the weird old stuff?) makes you grin, it jumps the queue.
2. **Boss picks:** the 16 named apex bosses in §5 — any you want cut, any legends you love that I missed (a favorite myth from childhood reading)?
3. **Attunement count:** 6 attunements (Ember/Frost/Storm/Venom/Radiant/Void) proposed. Fewer (4) keeps the elements system tighter; more (8–10) feeds the 1,000-math harder. Your call.
4. **Human enemies:** Family 26 (brigands, cultists, necromancers) — some games keep dungeons monster-only. Keep humans in, or does killing *people* feel wrong for Abysmal's tone?
5. **Lovecraft line:** I kept named Lovecraft entities out entirely (generic cosmic coinages only). Comfortable, or do you want a sourcing/legal double-check on the core mythos later?
6. **Wave 1 scope:** +10–14 modeled types from verified CC0 lines is the low-risk first step. Greenlight for when build time comes — or do you want primitives-first for everything and models only for headliners?
7. **Delve Endlessly exclusives (~70):** worth reserving roster entries only endless-mode players see, or should everything be reachable in normal play?
