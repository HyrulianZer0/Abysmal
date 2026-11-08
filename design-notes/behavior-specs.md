# Abysmal — Behavior Specs (master)

Status: SPECS ONLY, Nov 4, 2026. No game code, scripts, scenes, registry, models, or textures were changed to produce this document. Code application belongs to the systems step, which comes later in the locked chain: bones > wiring > mesh > textures > behavior.

How to use this document: each creature entry gives movement style, signature attack(s) with a player-readable telegraph, awareness (what draws it / what it ignores), a player counter, and an optional Deeper note (a complexity change at greater depth — monsters vary by difficulty AND complexity, not stats alone). No HP/ATK/DEF or other stat numbers appear anywhere in these specs; stats and balance belong to the systems step.

Outbound stance (James, Nov 4, for the record): the game is FREE for everyone to grab and play, and to keep alive as a legacy — but Abysmal's own original work is NOT for others to copy as their own. Free-to-play is not free-to-copy. The release-license choice itself is a later decision; nothing in this document assigns one.

Public code ingredients: a separate vetted list lives at [public-code-ingredients.md](behavior-specs/public-code-ingredients.md) — public behavior/AI code (MIT, verified on source pages Nov 4, 2026) that the systems step MAY adapt, with credit, as ingredients. Nothing there is a wholesale copy, and no code from it is pasted anywhere in this document.

## Index — 28 families, 300 creatures, 0 family-pattern groups

Every creature below has its own individual entry. "(also X)" overlap tags in the tracker are thematic notes, not separate rows, so no creature is specced twice.

| Family | Creatures | Part |
| --- | --- | --- |
| Oozes & Slimes | 8 | [part-1.md](behavior-specs/part-1.md) |
| Vermin & Cave Crawlers | 17 | [part-1.md](behavior-specs/part-1.md) |
| Plants & Fungi | 8 | [part-1.md](behavior-specs/part-1.md) |
| Aquatic & the Drowned Deep | 6 | [part-1.md](behavior-specs/part-1.md) |
| Beasts | 23 | [part-2.md](behavior-specs/part-2.md) |
| Sky & Storm | 6 | [part-2.md](behavior-specs/part-2.md) |
| Mesoamerican & Andean | 6 | [part-2.md](behavior-specs/part-2.md) |
| African Traditions | 6 | [part-2.md](behavior-specs/part-2.md) |
| Goblin-Kin & Cave Folk | 12 | [part-3.md](behavior-specs/part-3.md) |
| Orcs, Trolls & Giant-Kin | 15 | [part-3.md](behavior-specs/part-3.md) |
| Humans & the Damned Living | 11 | [part-3.md](behavior-specs/part-3.md) |
| The Undead | 23 | [part-4.md](behavior-specs/part-4.md) |
| Celestials & the Fallen | 6 | [part-4.md](behavior-specs/part-4.md) |
| Demons, Devils & the Damned | 11 | [part-4.md](behavior-specs/part-4.md) |
| Greek & Mediterranean Myth | 17 | [part-5.md](behavior-specs/part-5.md) |
| Norse & Germanic | 10 | [part-5.md](behavior-specs/part-5.md) |
| Celtic & British Isles | 8 | [part-5.md](behavior-specs/part-5.md) |
| Slavic | 11 | [part-5.md](behavior-specs/part-5.md) |
| Egyptian & Near East | 9 | [part-6.md](behavior-specs/part-6.md) |
| Mesopotamian | 8 | [part-6.md](behavior-specs/part-6.md) |
| South Asian | 8 | [part-6.md](behavior-specs/part-6.md) |
| Chinese & East Asian | 9 | [part-6.md](behavior-specs/part-6.md) |
| Japanese Yōkai | 13 | [part-6.md](behavior-specs/part-6.md) |
| Fey & Nature Spirits | 11 | [part-7.md](behavior-specs/part-7.md) |
| Elementals & Primal Spirits | 10 | [part-7.md](behavior-specs/part-7.md) |
| Golems & Constructs | 9 | [part-7.md](behavior-specs/part-7.md) |
| Dragons & Great Serpents | 10 | [part-7.md](behavior-specs/part-7.md) |
| The Abyssal & Cosmic | 9 | [part-7.md](behavior-specs/part-7.md) |

**Coverage totals:** 300/300 creatures specced · 28/28 families · 0 family-pattern groups (all individual entries) · 52 thin-lore flags · 63 needs-systems flags.

## Thin lore — director call (52)

These creatures had thin or contradictory lore; no backstory was invented for them. The director decides their final behavior.

**Part 1** (Oozes & Slimes, Vermin & Cave Crawlers, Plants & Fungi, Aquatic & the Drowned Deep): Cave Jelly, Amber Ooze, Mire Pudding, Gloom Ooze, Mercury Slime, Primordial Ooze, Grotto Snapper, Thornhound, Spore Servant, Lanternjaw.

**Part 2** (Beasts, Sky & Storm, Mesoamerican & Andean, African Traditions): Crag Ram, Deep Stag, Grotto Bull, Blind Mole, Pale Horse, Storm Wraith, Cipactli Brood.

**Part 3** (Goblin-Kin & Cave Folk, Orcs, Trolls & Giant-Kin, Humans & the Damned Living): Goblin Sneak, Goblin Champion, Half-Ogre, Marsh Troll, Ogre Mage, Bandit Chief, Mad Alchemist, Plague Bearer.

**Part 4** (The Undead, Celestials & the Fallen, Demons, Devils & the Damned): Phantom, Strigoi, Wight Lord, Ashen Seraph, Pit Brute, Larva of the Damned.

**Part 5** (Greek & Mediterranean Myth, Norse & Germanic, Celtic & British Isles, Slavic): Sea Serpent, Dark Elf (Dökkálfar), Alfar Raider, Bauchan, Fachan, Afanc, Mora.

**Part 6** (Egyptian & Near East, Mesopotamian, South Asian, Chinese & East Asian, Japanese Yōkai): Guardian Scorpion, Serpopard, Sha Beast, Falcon Sphinx, Cedar Guardian, Mountain Yaoguai, Mogwai, River Long.

**Part 7** (Fey & Nature Spirits, Elementals & Primal Spirits, Golems & Constructs, Dragons & Great Serpents, The Abyssal & Cosmic): Bramble Imp, Void Horror, Null Seraph, Entropy Wraith, Star Horror, The Hollow Choir.

## Needs systems step (63)

These behaviors need a NEW game system (not just AI patterns) and are flagged, not solved, here. The systems step decides how each is implemented; mechanisms live in the entries themselves.

**Part 1** (Oozes & Slimes, Vermin & Cave Crawlers, Plants & Fungi, Aquatic & the Drowned Deep): Mercury Slime, Primordial Ooze, Hornet Matriarch, Mandrake, Fungal Shambler, World Wurm.

**Part 2** (Beasts, Sky & Storm, Mesoamerican & Andean, African Traditions): Phoenix, Ahuizotl, Death Bat, Nagual, Tzitzimitl, Tokoloshe, Adze, Mami Wata.

**Part 3** (Goblin-Kin & Cave Folk, Orcs, Trolls & Giant-Kin, Humans & the Damned Living): Spriggan, Gremlin, Púca, Cultist, Necromancer.

**Part 4** (The Undead, Celestials & the Fallen, Demons, Devils & the Damned): Mummy, Vampire, Strigoi, Vetala, Wight Lord, Lich, Penanggalan, Ophanim, Succubus, Incubus, Contract Devil.

**Part 5** (Greek & Mediterranean Myth, Norse & Germanic, Celtic & British Isles, Slavic): Siren, Gorgon, Sphinx, Empusa, Hydra, Nixie, Hulder, Mare, Kraken, Kelpie, Selkie, Bean-nighe, Rusalka, Striga, Leshy, Alkonost, Gamayun, Mora, Firebird.

**Part 6** (Egyptian & Near East, Mesopotamian, South Asian, Chinese & East Asian, Japanese Yōkai): Devourer Beast, Bhūta, Rakshasa, Hulijing, Hundun, Bake-danuki, Kitsune, Yuki-onna, Jorōgumo, Nure-onna.

**Part 7** (Fey & Nature Spirits, Elementals & Primal Spirits, Golems & Constructs, Dragons & Great Serpents, The Abyssal & Cosmic): Will-o'-wisp, Changeling, Cockatrice, Basilisk.

## Apex, Jalastram, and canon notes

- **Apex uniques (16) are NOT specced here.** Their treatments live in `apex-bosses-lore-strategies.txt` and `wave4-apex-bosses.md`. Where a bestiary creature shares a base with an apex (Hellhound/Cerberus, Hydra/Orochi, Great Wolf/Fenrir, Kraken, Cedar Guardian/Humbaba, Anzu, Rakshasa/Ravana, Oni/Shuten-dōji, Elder Wyrm/Fafnir, Tarasque, Ur-Dragon/Typhon), the bestiary entry is the non-apex creature and the apex is referenced in one line at most.
- **Jalastram is NOT a bestiary row** and has no entry here. Its set spec stands: magic-detector sentinel, vocal louder near magic, never sleeps, loud noise draws its attention, vocal = proximity loop, not one-shot.
- **Cerberus attacks are already in treatment data** (Triple Bite + horn stab as additional damage, Tail Serpent, Gate Roar) and are referenced, not redesigned, here.
- **Kobold canon:** gadget-tinker core (traps/gadgets as signature); color open; dragonkin NOT required.
- **"Qilin, Corrupted" is ONE creature** (a corrupted qilin), not two.
- **Mercy (10% current HP per trigger) and apex-1-per-floor-after-10 spawn are systems-step rules** and are not specced as behaviors here.

---


---

[Part file: behavior-specs/part-1.md](behavior-specs/part-1.md)

## Part 1 — Oozes & Slimes, Vermin & Cave Crawlers, Plants & Fungi, Aquatic & the Drowned Deep

SPECS ONLY — no game code, stats, or systems are changed by this document. Telegraphs are written to read at a glance on a phone screen: wind-ups, pauses, eye glow, shadows, and approach lines do the talking. Hidden or lurking creatures always carry a faint visual hint before they are fully revealed. Monsters vary by difficulty AND complexity, not stats alone; the Deeper note on each entry carries that change.

## Oozes & Slimes

Slow, shapeless, and patient, the oozes punish careless footing and greedy positioning rather than speed. Most of them telegraph through swelling, shivering, colour change, or a visible shift in surface texture, so the player always gets a beat to step aside before the mass lands.

### Slime

- **Move:** Wobbles forward in a steady, waddling advance with no retreat and no flanking; it simply keeps coming.
- **Attack:** Body-slam — it swells visibly, pauses, then flops forward onto the player's position.
- **Awareness:** Drawn to nearby movement and warmth; ignores distant noise and still, quiet targets.
- **Counter:** Step aside during the swell and strike from behind while it recovers its shape.
- **Deeper:** It chains slams in a short flurry instead of one at a time, and sometimes feints a swell before committing.

### Cave Jelly

- **Move:** Creeps along walls and ceilings as often as the floor, sliding into place above or beside a passage before dropping.
- **Attack:** Drop-and-envelop — a faint glisten overhead is the tell, then it falls and tries to smother its target in place.
- **Awareness:** Drawn to vibrations and light passing beneath it; ignores anything that never comes under its perch.
- **Counter:** Watch ceilings in narrow passages, keep moving under a glistening patch, and hit it while it is still pooled on the floor after a missed drop.
- **Deeper:** It repositions between drops, so a missed drop is followed by a second perch rather than a slow crawl.
- **Flags:** thin lore — director call

### Amber Ooze

- **Move:** Oozes forward slowly, leaving a faint sticky sheen on the ground it crosses.
- **Attack:** Adhesive lunge — it stretches, brightens, and snaps forward, trying to glue its target in place for follow-up slams.
- **Awareness:** Drawn to anything that steps in its sheen or brushes against it; ignores targets that keep clear of its trail.
- **Counter:** Stay off the sheen, sidestep the stretch, and strike while it is still stretched thin.
- **Deeper:** Its trail widens into patches that slow passage, forcing the player to route around it rather than through it.
- **Flags:** thin lore — director call

### Mire Pudding

- **Move:** Lurks half-sunk in mud, shallow pools, and boggy floor, barely distinguishable from the ground until it moves.
- **Attack:** Surge-and-grab — the surface ripples, then a tendril of muck lashes out to drag the target toward its bulk.
- **Awareness:** Drawn to splashing, heavy footfalls, and anything wading through its mire; ignores quiet, dry-footed passers.
- **Counter:** Spot the ripple, keep to firm ground, and break the tendril's grip by moving laterally instead of pulling straight back.
- **Deeper:** It throws out a second tendril after the first, so dodging once is no longer enough.
- **Flags:** thin lore — director call

### Acid Blob

- **Move:** Pulsing, restless advance — quicker than most oozes, with a visible churn building inside it as it closes in.
- **Attack:** Corrosive spit — it rears back, its surface bubbles and brightens, then looses a splashing glob that eats at whatever it lands on.
- **Awareness:** Drawn to anything in its line of sight that moves; ignores targets behind cover or out of its spit arc.
- **Counter:** Break line of sight during the rear-back, sidestep the glob, and close in while it settles after spitting.
- **Deeper:** It spits in a spreading fan instead of a single glob, and leaves a briefly sizzling patch where each glob lands.

### Gloom Ooze

- **Move:** Drifts through dark stretches of tunnel, dimming the light around itself as it goes, and favours shadows over open ground.
- **Attack:** Smothering gloom — it swells and darkens, then folds over its target, blinding and pressing at once.
- **Awareness:** Drawn to light sources moving through darkness; ignores targets that douse their light and stand still.
- **Counter:** Keep distance in the dark, watch for the unnatural patch of deeper shadow, and strike during the swell before it folds.
- **Deeper:** It dims a wider area and holds its fold longer, so escaping takes deliberate movement rather than a single step.
- **Flags:** thin lore — director call

### Mercury Slime

- **Move:** Flows with a quicksilver quickness unusual for an ooze, pooling and reforming its shape as it slides.
- **Attack:** Shard spray — it shivers, throws off bright droplets in a scatter, then reforms and lunges while the target is dodging the spray.
- **Awareness:** Drawn to motion and reflected light; ignores slow, steady movement and still targets.
- **Counter:** Dodge the scatter first, then step in while it is still gathering itself back together.
- **Deeper:** It splits into smaller flowing parts that attack from separate angles, then rejoins into one mass.
- **Flags:** thin lore — director call; needs systems step

### Primordial Ooze

- **Move:** An ancient, slow tide of a thing — it advances relentlessly, reshaping itself around obstacles rather than going around them.
- **Attack:** Engulfing wave — it draws itself up like a rising tide, pauses at full height, then crashes forward over everything in front of it.
- **Awareness:** Drawn to any living presence in its chamber; ignores nothing once it has noticed a target, and does not lose interest easily.
- **Counter:** Read the rising pause, get to high or clear ground, and hit it from the side while the wave is spent.
- **Deeper:** It shifts its surface to echo the last kind of attack it faced, changing how it meets the next blow — a puzzle as much as a fight.
- **Flags:** thin lore — director call; needs systems step

## Vermin & Cave Crawlers

The cave's small things survive by numbers, speed, and ambush rather than strength. Rats and bats swarm and scatter, spiders and scorpions wait, and the worms and great crawlers turn the ground itself into a threat. Most telegraphs here are sound and motion: skittering, wingbeats, a raised tail, a coiling body.

### Cave Rat

- **Move:** Darting skirmisher — quick dashes with pauses, circling to nip from the side rather than charging head-on.
- **Attack:** Gnawing bite — it crouches low and still for a beat, then darts in for a snap at the legs.
- **Awareness:** Drawn to food smells, noise, and exposed packs; flees from firelight and loud, sudden movement unless cornered.
- **Counter:** Face it during its crouch, strike as it commits to the dash, and keep it from getting behind you.
- **Deeper:** It feints a dash, breaks off, and comes back from a new angle instead of repeating the same line.

### Rat Swarm

- **Move:** A seething mass that flows across the floor as one body, splitting around obstacles and rejoining on the far side.
- **Attack:** Overwhelming gnaw — the mass surges forward in a wave, teeth everywhere at once, with a rising chitter as its tell.
- **Awareness:** Drawn to any warm, moving target in the open; ignores targets that climb out of reach or stand in bright light.
- **Counter:** Keep moving, use wide sweeping strikes against the mass rather than single-target blows, and break its surge by stepping through it at the right moment.
- **Deeper:** The swarm splits into two smaller masses that approach from different directions and rejoin behind the player.

### Cave Bat

- **Move:** Erratic flight — swooping loops and sudden dives, never holding a straight line for long.
- **Attack:** Diving nip — it climbs, hangs for a beat with wings spread, then dives along a visible line at the player's head.
- **Awareness:** Drawn to sound and movement in open caverns; ignores still, silent targets and anything in tight cover.
- **Counter:** Watch the hang, step off the dive line, and strike while it pulls out of the dive low to the ground.
- **Deeper:** It dives in pairs of linked swoops, the second dive correcting toward wherever the player dodged the first.

### Cave Spider

- **Move:** Patient ambusher — it waits motionless in a webbed corner or ceiling nook, then scuttles fast once prey is close.
- **Attack:** Web-snare and bite — it raises its front legs, looses a strand to slow its target, then closes in for a venomous bite.
- **Awareness:** Drawn to vibrations on its web and to movement in its corner; ignores anything that never disturbs the web.
- **Counter:** Spot the faint webbing before entering, cut or avoid the snare line, and hit it while it rears for the bite.
- **Deeper:** It retreats up its web after biting, then drops again from a new angle instead of staying in the open.

### Cave Wasp

- **Move:** Aggressive, hovering flight — it circles its target at a distance, darting in and out rather than landing.
- **Attack:** Stinging dive — it hovers, dips low, and buzzes louder for a beat before driving in with its sting.
- **Awareness:** Drawn to movement near its nest and to bright colours; ignores targets that retreat well clear of the nest.
- **Counter:** Listen for the rising buzz, sidestep the dip, and strike during its hover when it steadies to aim.
- **Deeper:** It stings in a quick double-dip, and circles faster between dives so its hover window shrinks.

### Cave Scorpion

- **Move:** Slow, deliberate ground advance, claws open, tail carried high and curled.
- **Attack:** Pincer hold and tail strike — it snaps a claw shut to hold its target, then the tail arcs overhead with a visible coil before stabbing down.
- **Awareness:** Drawn to ground vibrations and warmth; ignores flying targets and anything that stays out of claw reach.
- **Counter:** Stay out of claw range, dodge sideways as the tail coils, and strike the tail or flank while it recovers from a missed stab.
- **Deeper:** It feints with one claw while the tail strikes from the other side, so watching only the claws gets the player stung.

### Centipede

- **Move:** Rippling ground crawl — fast for its size, hugging walls and floor seams, able to double back on itself.
- **Attack:** Wrapping bite — it rears its head segments, pauses with mandibles spread, then lashes forward to bite and curl around its target.
- **Awareness:** Drawn to warmth and to movement in dark crevices; ignores targets in bright, open ground.
- **Counter:** Step back as it rears, strike the head segments during the pause, and keep it from completing a curl.
- **Deeper:** It coils into a defensive ring when struck, then uncoils into a faster lunge from the ring.

### Cave Frog

- **Move:** Hopping advance — long leaps with a crouched pause between them, able to clear low obstacles.
- **Attack:** Tongue snatch and leap-slam — it inflates its throat as a tell, then either flicks its tongue out to drag prey closer or leaps bodily onto its target.
- **Awareness:** Drawn to small movements and insects; ignores large, still targets unless they come close.
- **Counter:** Move laterally during the throat inflation, and strike while it is crouched and recovering from a leap.
- **Deeper:** It chains leaps into a bouncing approach, changing direction mid-hop so a single sidestep no longer clears it.

### Giant Rat

- **Move:** Bold, heavy skirmisher — it does not dart like its smaller kin but charges in short, shoulder-first rushes.
- **Attack:** Lunging maul — it rears onto its hind legs, bares its teeth, then throws itself forward in a mauling rush.
- **Awareness:** Drawn to food and to wounded or isolated targets; ignores well-lit, defended positions unless hungry enough to press.
- **Counter:** Meet the rear with a sidestep, and strike its exposed flank while it skids past after a missed rush.
- **Deeper:** It rushes, wheels around, and rushes again without pausing, turning a single charge into a sustained press.

### Vampire Bat

- **Move:** Silent, gliding flight — quieter and steadier than a cave bat, circling low and close before committing.
- **Attack:** Draining latch — it drops onto its target from above with wings folded, latching on and feeding until shaken off.
- **Awareness:** Drawn to warmth, breath, and sleeping or resting targets above all; ignores armoured, moving targets in favour of exposed ones.
- **Counter:** Keep moving and stay covered overhead, shake it off with a sharp movement the moment it latches, and strike it while it clings.
- **Deeper:** It latches, releases, and relatches from a new perch in the same encounter, so shaking it off once only buys a brief rest.

### Widow Spider

- **Move:** Stillness itself — it hangs in a dense, tangled web and barely moves until prey is committed.
- **Attack:** Venom bite from the web — it drops on a thread, bites, and climbs back up, leaving its target slowed and hurting.
- **Awareness:** Drawn to anything thrashing in its web; ignores anything that moves slowly and carefully around the web's edge.
- **Counter:** Spot the tangled webbing and the faint red marking before stepping in, avoid the drop line, and strike while it climbs back up.
- **Deeper:** It lays a second, nearly invisible snare line across the escape route, so fleeing the first web can mean walking into another.

### Emperor Scorpion

- **Move:** Heavy, armoured advance — slow and unstoppable-looking, claws wide, tail swaying overhead.
- **Attack:** Crushing pincer and overhead sting — it spreads both claws as a tell, snaps one shut, then brings the tail down in a slow, readable arc.
- **Awareness:** Drawn to anything that enters its territory and stays; ignores targets that leave its ground quickly.
- **Counter:** Bait the claw snap, dodge the tail arc sideways, and strike the joints and tail base during its long recovery.
- **Deeper:** It alternates claw and tail in a steady rhythm, and sometimes holds the tail strike for a beat longer to catch an early dodge.

### Stag Beetle

- **Move:** Plodding, armoured ground advance — it faces its target squarely and does not dodge.
- **Attack:** Mandible toss — it lowers its great jaws, paws the ground, then charges a short distance and tries to lift and throw its target.
- **Awareness:** Drawn to challengers that face it directly; ignores targets that slip past without confronting it.
- **Counter:** Sidestep the pawing charge, and strike its unarmoured underside or rear while it recovers from a missed toss.
- **Deeper:** It charges, turns faster than expected, and charges again, and its toss aims toward walls and hazards rather than open ground.

### Burrow Worm

- **Move:** Subterranean — it travels unseen beneath the floor, betrayed only by a moving ridge of disturbed earth.
- **Attack:** Eruption bite — the ridge stops, the ground bulges, then the worm bursts upward with jaws open.
- **Awareness:** Drawn to footsteps and ground vibrations; ignores targets that stand on stone or stay perfectly still.
- **Counter:** Watch the ridge, step off its line when it stops, and strike the exposed head while it is still half out of the ground.
- **Deeper:** It erupts, dives, and erupts again from a new point without warning, chaining two or three breaches in one approach.

### Carrion Worm

- **Move:** Sluggish crawl through rot and refuse, drawn to where things have died; it follows decay more than it hunts.
- **Attack:** Rotting spray — it rears its head, its body pulses, then it sprays a foul, sickening mist that clings and weakens.
- **Awareness:** Drawn to corpses, refuse, and wounded targets; ignores healthy, clean, fast-moving targets unless they linger.
- **Counter:** Keep upwind and keep moving, step out of the spray arc during the pulse, and strike while it is still rearing.
- **Deeper:** Its spray lingers as a foul patch on the ground, and it sprays a second burst to cover its retreat.

### Hornet Matriarch

- **Move:** Commanding hover — she holds the air above her nest, directing her brood, and only dives when pressed.
- **Attack:** Royal sting and brood call — she dips and shrieks, her brood dives in a wave, then she follows with a heavy sting of her own.
- **Awareness:** Drawn to any threat near the nest; ignores anything that withdraws well beyond the nest's ground.
- **Counter:** Break the brood's dive line, strike her during her hover between calls, and keep the nest itself out of the fight if possible.
- **Deeper:** She calls her brood in staggered waves rather than all at once, so the pressure never fully lets up.
- **Flags:** needs systems step

### Ōmukade

- **Move:** A great, rippling crawl — this giant centipede of Japanese folklore winds through mountain passes and cave floors, its many legs moving in waves. (Also tagged Japanese Yōkai — written here, with the overlap noted.)
- **Attack:** Coiling crush and venomous bite — it rears its head high, mandibles spread wide, then strikes and tries to wrap its long body around its target.
- **Awareness:** Drawn to warmth and movement in its territory, and in the old tales it is a foe even of great serpents; ignores targets that leave its ground and do not return.
- **Counter:** Step back from the rear, strike the head during the pause, and never let it complete a coil — break free laterally the moment it starts to wrap.
- **Deeper:** It coils defensively around itself when struck, then uncoils into a sweeping bite that covers a wider arc.

## Plants & Fungi

Rooted things that hunt without moving far: vines that reach, trees that wake, fungi that spread, and flowers that lure. The counterplay is almost always the same shape — spot the plant before it spots you, respect its reach, and strike the stem, root, or bloom while it is committed to a grab or a cry.

### Grotto Snapper

- **Move:** Rooted ambusher — it sits motionless like an ordinary grotto plant until prey comes within reach, then snaps with startling speed.
- **Attack:** Jaw snap — its maw opens slowly as the tell, then slams shut on anything inside its reach.
- **Awareness:** Drawn to movement and warmth inside its reach; ignores anything that passes outside it, however close.
- **Counter:** Probe its reach from outside it, watch for the slow jaw-open, and strike the stem while the maw is still open after a miss.
- **Deeper:** It snaps twice in quick succession, the second snap aimed where the player dodged the first.
- **Flags:** thin lore — director call

### Mandrake

- **Move:** Rooted, with a shuffling, stumbling waddle when torn from the earth — it does not chase far, but it does not stay put either.
- **Attack:** Piercing shriek — in folklore the root screams when pulled from the ground, and here it throws its head back, mouth wide, and looses a scream that staggers and disorients everything nearby.
- **Awareness:** Drawn to anything that disturbs the soil around it; ignores targets that pass without digging or trampling its bed.
- **Counter:** Cover distance before it finishes drawing breath, strike during the head-throw wind-up, and pull back the moment the shriek starts.
- **Deeper:** It shrieks in a rising series rather than once, so the player must time movement between screams instead of weathering a single cry.
- **Flags:** needs systems step

### Vampire Vine

- **Move:** Creeping reach — it spreads along walls and floors toward prey, its tendrils questing ahead of the main stem.
- **Attack:** Coiling drain — a tendril rises and sways as its tell, then whips out to coil around its target and drain strength while it holds.
- **Awareness:** Drawn to warmth and to blood; ignores cold, still, and inanimate things.
- **Counter:** Cut or dodge the rising tendril before it coils, break the coil by moving sharply sideways, and strike the main stem while a tendril is extended.
- **Deeper:** It sends out a second tendril while the first holds, so freeing one coil can mean being caught by another.

### Fungal Shambler

- **Move:** Lurching, shambling advance — slow, uneven, and hard to read, with spores drifting off it as it moves.
- **Attack:** Spore burst and bludgeoning swipe — it raises both arms as a tell, then either swings heavily or bursts a cloud of spores around itself.
- **Awareness:** Drawn to warmth and breath in damp places; ignores targets that keep clear of its spore drift.
- **Counter:** Stay out of the spore cloud's edge, strike during the arm-raise, and step back the moment the cloud blooms.
- **Deeper:** It bursts spores when struck hard, not only when it chooses to, so every heavy blow has a cost.
- **Flags:** needs systems step

### Walking Oak

- **Move:** Slow, ponderous, root-tearing advance — it uproots itself and strides, shaking the ground with each step.
- **Attack:** Branch sweep and root slam — it draws a great limb back, then sweeps it across a wide arc, or drives a root down where its target stands.
- **Awareness:** Drawn to anything that harms the grove or cuts green wood nearby; ignores quiet passers that leave the trees alone.
- **Counter:** Read the limb draw-back, step out of the sweep arc, and strike the trunk or roots while the limb is still recovering.
- **Deeper:** It sweeps and then slams in one combination, so dodging the sweep can put the player exactly where the root comes down.

### Thornhound

- **Move:** Loping, pack-hunting plant-beast — it bounds through undergrowth on vine-wrapped limbs, circling prey like a hound.
- **Attack:** Thorn rake and entangling pounce — it crouches low, brambles bristling, then pounces to rake with thorns and tangle its target in vines.
- **Awareness:** Drawn to movement through brush and to wounded prey; ignores targets that stay on open, clear ground.
- **Counter:** Keep to open ground, sidestep the crouch-pounce, and strike while it untangles itself after a miss.
- **Deeper:** It hunts in a loose pack, with one hound driving prey toward another's pounce.
- **Flags:** thin lore — director call

### Spore Servant

- **Move:** Slow, puppet-like shamble — a husk animated by fungus, moving with jerky, stop-start steps.
- **Attack:** Spore-laden grasp — it reaches out with both arms spread, then clutches and presses its spore-covered body against its target.
- **Awareness:** Drawn to warmth and breath; ignores anything it cannot sense breathing, and wanders aimlessly when no target is near.
- **Counter:** Keep distance, strike during the arm-spread wind-up, and step back before the clutch closes.
- **Deeper:** It sheds a lingering spore cloud when it falls, so finishing it at close range is a worse bargain than finishing it from afar.
- **Flags:** thin lore — director call

### Corpse Flower

- **Move:** Rooted lure — it does not move at all, but sways and opens its great bloom to draw prey closer.
- **Attack:** Carrion lure and engulfing bloom — it opens wide, releasing a heavy, sweet-rot scent, and when prey steps inside its petals, the bloom snaps shut around them.
- **Awareness:** Drawn to anything that approaches its scent; ignores anything that passes at a distance without coming closer.
- **Counter:** Recognise the scent and the open bloom as a trap, stay outside petal reach, and strike the stem or bloom while it is still open.
- **Deeper:** It sways and opens in stages, luring with a faint scent first and only snapping shut once prey is well inside.

## Aquatic & the Drowned Deep

Water in the dungeon is never just scenery: things strike from below the surface, from flooded passages, and from the deep dark itself. The tell is usually on the water — a ripple, a glow, a shadow passing under the surface — and the counter is almost always to leave the waterline, watch the surface, and strike while the creature is exposed.

### Cave Moray

- **Move:** Serpentine ambusher of flooded crevices — it waits coiled in a hole or crack, head out, body hidden.
- **Attack:** Lunging bite — its head draws back into the crevice as a tell, then it shoots out to snap at anything passing the opening.
- **Awareness:** Drawn to shadows and movement passing its crevice; ignores anything that keeps clear of the opening.
- **Counter:** Spot the crevice and the head within it, pass outside lunge range, and strike the head while it is still extended after a miss.
- **Deeper:** It lunges, retreats, and lunges again from a second opening nearby, so one crevice can hide two threats.

### Drowned Sailor

- **Move:** Slow, dragging wade — it rises from flooded ground and shambles forward, water streaming off it, never hurrying.
- **Attack:** Dragging grasp — it reaches out with both arms, moaning as it closes, and tries to seize its target and pull it toward the water.
- **Awareness:** Drawn to the living, to light, and to sound near water; ignores targets that leave the flooded ground entirely.
- **Counter:** Keep to dry ground, break the grasp by stepping sideways, and strike while its arms are still extended after a missed grab.
- **Deeper:** It rises with a second drowned figure nearby, so the drag comes from two directions at once.

### Giant Octopus

- **Move:** Flowing, boneless movement — it squeezes through gaps, jets across flooded chambers, and climbs wet walls.
- **Attack:** Tentacle wrap and beak bite — a tentacle rises and hovers as its tell, then whips out to wrap its target and draw it toward the beak.
- **Awareness:** Drawn to movement in the water and to anything that disturbs the surface; ignores targets that stay on dry ground and out of tentacle reach.
- **Counter:** Watch the rising tentacle, dodge the wrap, and strike the tentacle or head while it is extended.
- **Deeper:** It wraps with two tentacles at once from different angles, and inks the water to hide its retreat and next approach.

### Deep Crab

- **Move:** Sideways scuttle — fast laterally, slow to turn, hugging the floor of flooded chambers and shore edges.
- **Attack:** Crushing claw snap — it raises one great claw high as a tell, then snaps it shut on whatever is in front of it.
- **Awareness:** Drawn to movement on the floor near the waterline; ignores targets that stay well back from the shore or above it.
- **Counter:** Sidestep the raised claw, strike from the rear or the claw's blind side, and keep it turning — its turn is its weakness.
- **Deeper:** It snaps with alternating claws in a steady rhythm, and sometimes holds a snap for a beat to catch an early dodge.

### Lanternjaw

- **Move:** Lurking drift in dark water — it hangs motionless below the surface, its lure glowing faintly, and only moves when prey comes close.
- **Attack:** Lure-and-lunge — the glow brightens and bobs as its tell, then the great jawed head surges upward and snaps shut.
- **Awareness:** Drawn to anything that approaches its light in the dark; ignores anything that passes without looking toward the glow.
- **Counter:** Treat any lone glow in dark water as a warning, not an invitation, keep back from the water's edge, and strike the head while it is still out of the water after a miss.
- **Deeper:** It dims its lure and relights it elsewhere, so the glow the player is watching is no longer where the jaws are.
- **Flags:** thin lore — director call

### World Wurm

- **Move:** A vast, coiling serpent of the deep — this bestiary-row wurm draws on the world-serpent motif of Norse myth, a creature so great it encircles whole realms, but it is written here as a dungeon creature in its own right, not as the apex Jörmungandr, which is spec'd separately.
- **Attack:** Coiling crush and sweeping bite — it rears a length of its body high as a tell, then either sweeps its head across a wide arc or coils its body around its target to crush.
- **Awareness:** Drawn to anything that enters its flooded chamber and disturbs the water; ignores targets that leave the water and do not return.
- **Counter:** Read the rear, step out of the sweep arc, and strike the exposed head or mid-body while the coil is still forming.
- **Deeper:** It coils around the chamber itself, narrowing the safe ground and forcing the player to fight from a shrinking patch of dry footing.
- **Flags:** needs systems step

## Sources consulted

- https://en.wikipedia.org/wiki/%C5%8Cmukade
- https://en.wikipedia.org/wiki/midgard_snake
- https://en.wikipedia.org/wiki/Mandragora_(demon)
- https://www.worldhistory.org/Jormungandr/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC539425/

## Public code ingredients

References and adaptation notes only — no third-party code is pasted into this file, and no game code is changed by it. Each source below was checked on its own repository page, which lists its license as MIT and carries a LICENSE file. Code application belongs to the systems step, which must keep Abysmal's own models, presentation, and state names and credit each source used. Note the fit caveat: all three sources are two-dimensional demos, while Abysmal is a first-person dungeon crawler, so movement, facing, and telegraphs must be reworked for first-person readability rather than carried over as-is.

- **CodingQuests godot-enemy-ai** — https://github.com/CodingQuests/godot-enemy-ai — License: MIT (verified on the repository page, which lists "MIT License" and a LICENSE file).
  - What we would adapt: the shared state-machine shape (idle, chase, telegraph, attack, recovery) and its readable telegraph-then-recovery rhythm, which matches this part's specs for skirmishers, chargers, and ambushers (Cave Rat, Giant Rat, Stag Beetle, Cave Spider, Cave Scorpion) and the telegraphed ground attacks of the oozes and plants.
  - How the result stays Abysmal-original: only the state-machine pattern is borrowed; every creature's states, telegraphs, timings, and attacks are written fresh from the specs above, with Abysmal's own models and first-person presentation, and the source is credited.
- **CodingQuests godot-state-machine** — https://github.com/CodingQuests/godot-state-machine — License: MIT (verified on the repository page, which lists "MIT License" and a LICENSE file).
  - What we would adapt: the node-per-state machine shape (one node per state, transitions by signal) and its demo slime's idle-roam-chase-leap flow, which maps directly onto this part's Slime, Cave Jelly, Acid Blob, and other oozes, plus the lurching Plants & Fungi entries.
  - How the result stays Abysmal-original: the machine is a generic scaffold, not a creature; Abysmal's oozes get their own state sets, swell-and-pause telegraphs, and depth-complexity changes from the specs above, and the source is credited.
- **LimboAI** — https://github.com/limbonaut/limboai — License: MIT (verified on the repository page, which lists "MIT License" and a LICENSE file; its logo and demo art are separately CC-BY and are not needed here).
  - What we would adapt: only if the systems step wants behavior trees or hierarchical states for this part's most layered creatures — pack coordination for Rat Swarm and Thornhound, staged lure-then-strike for Lanternjaw and Corpse Flower, and multi-phase coils for Ōmukade and World Wurm — as an optional heavier framework behind Abysmal's own tasks and states.
  - How the result stays Abysmal-original: the framework carries no Abysmal creatures; every task, condition, and state would be authored from the specs above for Abysmal's own roster, and the source is credited. Its GDExtension form also needs an export-target check before any adoption, which is a systems-step call.


---

[Part file: behavior-specs/part-2.md](behavior-specs/part-2.md)

## Part 2 — Beasts, Sky & Storm, Mesoamerican & Andean, African Traditions

SPECS ONLY. No game code, stats, drops, mercy rules, or apex-spawn rules are specified here. Behavior only: how each creature moves, attacks, reads to the player, and can be answered. Telegraphed tells must read at a glance on a phone screen, per the game's existing AI vocabulary: wind-ups, pawing, inhaling, eye glow, dive lines, and shadows. Where lore is thin or a behavior would need a new game system, the entry is flagged rather than invented or assumed.

## Beasts

Ground predators, herd beasts, and cave hunters. Most of this family is honest melee — charges, lunges, bites, and pack pressure — so variety comes from approach, telegraph, and grouping rather than from exotic powers.

### Wolf

- **Move:** Circles at mid-range, harrying, darting in and out rather than trading blows head-on.
- **Attack:** Quick nips from the flank; when packmates close in, the pack converges for a coordinated burst, telegraphed by the tightening circle.
- **Awareness:** Drawn by movement and noise; loses interest if the player breaks line of sight and keeps distance.
- **Counter:** Face the circling wolf, punish the nip's recovery, and never let the circle close unanswered.
- **Deeper:** Pack bursts come faster and from more angles as depth increases.

### Wild Boar

- **Move:** Paws the ground and snorts, then rushes in a straight line; slow to turn after a miss.
- **Attack:** The charge itself is the hit, ending in a gore on contact; the pawing and snorting are the tell.
- **Awareness:** Aggravated by close approach and sudden movement; ignores distant, quiet players.
- **Counter:** Sidestep the line, then strike during the slow turn-around.
- **Deeper:** Shorter telegraphs and chained re-charges at greater depth.

### Hyena

- **Move:** Loping pack skirmisher that circles and laughs, probing for an opening rather than committing alone.
- **Attack:** Snapping bites from the side and rear, with packmates striking in the same window once numbers join.
- **Awareness:** Drawn by noise, carrion cues, and a lone-looking target; wary of a player who stands ground and faces it.
- **Counter:** Keep moving so no flank settles, and break the pack up instead of dueling one hyena at a time.
- **Deeper:** Larger, bolder packs that split around the player instead of circling as one ring.

### Giant Serpent

- **Move:** Lies coiled in cover, still, then lunges and re-coils to wait again.
- **Attack:** A fast lunge from concealment, followed by a coiling squeeze threat if the player stays close; the coil silhouette in cover is the faint pre-signal.
- **Awareness:** Strikes at prey that wanders into its reach; ignores anything that never comes near its coil.
- **Counter:** Spot the coil, bait the lunge from outside its reach, and strike during the re-coil.
- **Deeper:** Faster re-coils and lunges from deeper cover, with less time between strikes.

### Grizzly

- **Move:** Steady, deliberate advance; no retreat, no flanking dance.
- **Attack:** Heavy overhead swipes with a long, readable wind-up — the raised paw is the dodge window — and a punishing follow-through.
- **Awareness:** Drawn by close presence and provocation; ignores distant players.
- **Counter:** Dodge the wind-up, punish the long recovery, and never trade blows standing still.
- **Deeper:** Wider swipe arcs and a second swipe after the first at greater depth.

### Dire Wolf

- **Move:** A heavier pack brute that circles like a wolf but commits harder, driving the player toward the rest of the pack.
- **Attack:** Lunging bites that carry it forward, telegraphed by a lowered head and a short crouch before the spring.
- **Awareness:** Drawn by the same cues as a wolf, but holds its ground longer once engaged.
- **Counter:** Sidestep the lunge, strike the flank, and separate it from its packmates.
- **Deeper:** Lunges chain into a second spring if the first connects or narrowly misses.

### Warhound

- **Move:** Charger that paws, bays, and rushes in a straight line, then wheels for another run.
- **Attack:** A driving charge ending in a bite; the baying and pawing are the tell, and the wheel after a miss is the opening.
- **Awareness:** Keyed to sound and movement; once it has bayed, it commits to the chase.
- **Counter:** Step off the charge line and hit it while it turns.
- **Deeper:** Quicker wheels and feinted half-charges that stop short before the real rush.

### Cave Bear

- **Move:** Slow, unstoppable plod that blocks corridors and refuses to be pushed around.
- **Attack:** Infrequent heavy slams, telegraphed by a rearing lift of both forepaws; the slam punishes standing still, not chasing.
- **Awareness:** Aggravated by intrusion into its den space; otherwise slow to notice.
- **Counter:** Keep moving, dodge the rearing slam, and strike during the long settle after it lands.
- **Deeper:** Slam shockwaves reach farther along the ground, forcing wider dodges.

### Razorback

- **Move:** Charger-brute: paws, snorts, charges down corridors, then follows with tusk swipes in the open.
- **Attack:** The charge is the entry; once the charge ends, it turns to close-range tusk swipes with a head-toss wind-up.
- **Awareness:** Provoked by close approach and noise; in open ground it is quicker to abandon a second charge for swipes.
- **Counter:** Dodge the line, then stay mobile through the swipe follow-up rather than assuming the charge was the whole attack.
- **Deeper:** Swipe combos after a blocked or missed charge, and charges that rebound off walls into a second angle.

### Panther

- **Move:** Silent ambusher that stalks from shadow, holds still, then springs.
- **Attack:** A leaping pounce from concealment, telegraphed only by a faint shadow shift and a crouch in the last moment before the spring.
- **Awareness:** Drawn by a player who moves without checking shadows; ignores players who stay in the open and watch.
- **Counter:** Check shadowed ground, bait the pounce, and strike during the landing recovery.
- **Deeper:** Pounces from higher and darker perches, with a second spring if the first is dodged cleanly.

### Cave Python

- **Move:** Heavy ambusher-tank that drapes across a path or coils in a crevice and waits.
- **Attack:** A constricting lunge that wraps and squeezes if it connects, telegraphed by a slow coil-tightening before the strike.
- **Awareness:** Strikes at warmth and movement passing its coil; ignores distant, still players.
- **Counter:** Spot the drape, keep range, and break the coil's rhythm before it tightens.
- **Deeper:** Coils cover wider paths, and a missed lunge still leaves a sweeping tail threat.

### Cave Ape

- **Move:** Knuckle-walking brute that advances steadily, climbs low ledges, and uses its reach.
- **Attack:** Heavy overhead arm swings with a long wind-up, plus a chest-beating roar that signals the next swing.
- **Awareness:** Drawn by intrusion and noise; backs off briefly if struck hard mid-wind-up.
- **Counter:** Interrupt or dodge the wind-up, punish the recovery, and avoid fighting it in a narrow dead end.
- **Deeper:** Swing chains and ground-pounding follow-ups that punish players who hug its feet.

### Baboon Troop

- **Move:** Swarm-skirmisher: many bodies darting, chattering, and repositioning, never holding ground alone.
- **Attack:** Quick nips and thrown debris from many angles, then a break-off; the troop's massing and chatter are the tell.
- **Awareness:** Drawn by noise and by any player who lingers; scatters briefly when one member is struck hard.
- **Counter:** Keep moving, strike the boldest members to thin the pressure, and avoid being surrounded.
- **Deeper:** Larger troops that split into two flanking groups instead of one mass.

### Crag Ram

- **Move:** Sure-footed charger that paws rocky ground, then rushes in a straight line, even across uneven floors.
- **Attack:** A head-lowered charge ending in a horn impact; pawing and a lowered head are the tell.
- **Awareness:** Provoked by close approach on its ledge or path; ignores distant players.
- **Counter:** Step off the line and strike during the slow turn after a miss.
- **Deeper:** Charges that angle slightly mid-rush, so a single sidestep is no longer always enough.
- **Flags:** thin lore — director call

### Deep Stag

- **Move:** Proud charger that paws, lowers its antlers, and rushes, then wheels with surprising grace.
- **Attack:** An antler charge followed by sweeping antler tosses if the player stays close after the rush.
- **Awareness:** Drawn by intrusion into its glade or corridor; wary of players who hold still and face it.
- **Counter:** Dodge the line, then strike before the antler toss recovers.
- **Deeper:** Toss follow-ups chain into a second charge without a full reset.
- **Flags:** thin lore — director call

### Grotto Bull

- **Move:** Charger-brute that paws, bellows, and charges down corridors, then follows with horn swipes in the open.
- **Attack:** The charge is the entry; horn swipes with a head-swing wind-up are the follow-up once the charge ends.
- **Awareness:** Provoked by noise and close presence; the bellow is both a warning and a tell.
- **Counter:** Dodge the line, stay mobile through the swipes, and punish the pause between charge and swipe.
- **Deeper:** Bellows stagger briefly before a charge, and swipes widen at greater depth.
- **Flags:** thin lore — director call

### Blind Mole

- **Move:** Burrowing ambusher that moves unseen beneath loose ground, surfacing only to strike.
- **Attack:** A sudden surfacing lunge from below, telegraphed by a faint ripple or mound shifting in the floor before it breaks through.
- **Awareness:** Drawn entirely by vibration and footsteps; ignores a player who stands still.
- **Counter:** Stand still to starve it of cues, watch the floor ripple, and step off the mound before it surfaces.
- **Deeper:** Faster surfacing and multiple false ripples that force the player to read the real one.
- **Flags:** thin lore — director call

### Crocodile

- **Move:** Ambusher-tank that lies still at a waterline or path edge, barely moving until prey is close.
- **Attack:** A sideways lunging bite with a death-roll follow-up if it connects, telegraphed by a slight jaw gape and tail shift.
- **Awareness:** Strikes at anything that comes within reach of its still form; ignores distant players.
- **Counter:** Spot the still shape, keep range, and punish the long recovery after a missed lunge.
- **Deeper:** Lunges from farther back, with a tail sweep guarding its flank after a miss.

### Lion

- **Move:** Brute-pack hunter that advances steadily and circles with pride-mates, driving prey toward the group.
- **Attack:** Heavy paw swipes with a readable wind-up, plus coordinated bites when pride-mates close in.
- **Awareness:** Drawn by movement and by a player who separates from cover; holds ground once engaged.
- **Counter:** Face the lead lion, avoid being driven into the pride, and punish swipe recoveries.
- **Deeper:** Pride coordination tightens, with one lion pinning attention while another flanks.

### Sabertooth

- **Move:** Ambusher-charger that crouches in cover, springs, and then charges if the spring misses.
- **Attack:** A leaping pounce ending in a fang bite, telegraphed by a low crouch and bared fangs; a missed pounce flows into a short charge.
- **Awareness:** Drawn by prey that wanders near its cover; ignores players who scan and avoid the ambush spot.
- **Counter:** Bait the pounce from range, sidestep it, and strike before the follow-up charge lines up.
- **Deeper:** Pounces chain into charges with almost no pause, and the crouch reads later.

### Tiger

- **Move:** Solitary ambusher that stalks low, holds still in shadow, then explodes into motion.
- **Attack:** A bounding pounce with raking claws, telegraphed by a flattening crouch and a tail lash in the final moment.
- **Awareness:** Drawn by lone, moving prey; loses the trail if the player breaks sight and stays quiet.
- **Counter:** Watch shadow lines, bait the pounce, and punish the landing.
- **Deeper:** Stalks longer before striking, and the pounce covers more ground with less warning.

### Cave Hyena

- **Move:** Cave-dwelling pack skirmisher that circles in the dark, using echo and shadow to probe.
- **Attack:** Snapping bites from the dark side, with packmates striking together once the circle closes.
- **Awareness:** Drawn by noise echoing in caves; wary of light and of a player who faces the pack.
- **Counter:** Keep a wall at your back where possible, face the circle, and break it before it closes.
- **Deeper:** Packs hunt in total-dark stretches, striking from alternating sides.

### Pale Horse

- **Move:** Unnerving, silent wanderer that drifts toward the player without hurry, ignoring normal animal caution.
- **Attack:** A sudden rearing strike and trampling rush, telegraphed by a stillness that breaks all at once into motion.
- **Awareness:** Drawn to the player regardless of noise or stillness; it does not behave like a shy herd animal.
- **Counter:** Do not let its slow approach lull you — keep distance, dodge the rear, and strike during the settle after it lands.
- **Deeper:** Its approach quickens without warning, and the rear flows into a longer trampling run.
- **Flags:** thin lore — director call

## Sky & Storm

Great birds and storm spirits. Flight is the core problem: these creatures attack from above, disengage upward, and only become hittable on a dive, a perch, or a cast. Telegraphs are dive lines, wing shadows, and storm build-up.

### Storm Crow

- **Move:** Flyer-swarm that circles overhead in a ragged flock, diving one or two at a time.
- **Attack:** Dive-pecks from above, telegraphed by a circling bird breaking formation and dropping along a visible line.
- **Awareness:** Drawn by noise and by a player caught in the open; scatters when the flock is struck hard.
- **Counter:** Watch the sky, step off the dive line, and strike the diver during its climb-away.
- **Deeper:** Flocks dive in staggered pairs, so dodging one dive lines the player up for the next.

### Roc

- **Move:** Colossal flyer that circles high, casting a great wing shadow, then stoops in a long dive.
- **Attack:** A talon stoop that rakes along its dive path, telegraphed by the widening wing shadow and a folding of the wings before the drop.
- **Awareness:** Drawn by large, moving prey in the open; ignores players under solid cover.
- **Counter:** Get under cover or step off the shadow line, and punish the long climb after a missed stoop.
- **Deeper:** Stoops come in a low pass followed by a wing-buffet turn, forcing two dodges instead of one.

### Phoenix

- **Move:** Flyer-fire caster that hovers and circles, shedding embers, then dives or casts from the air.
- **Attack:** Sweeping fire from above and a diving ember rake, telegraphed by a brightening glow and an inhale-like flare before the burst.
- **Awareness:** Drawn by open ground and by players who linger; drifts to a new vantage after each cast.
- **Counter:** Move off the glowing ground, strike during the perch or the climb-away, and never camp under its hover.
- **Deeper:** Fire lingers on the ground longer, and the dive follows the cast with less delay.
- **Flags:** needs systems step

### Thunderbird

- **Move:** Flyer-storm caster that rides high winds, circling and beating its wings to build a storm.
- **Attack:** Storm strikes called down from above — thunderclaps and lightning — telegraphed by wing beats quickening and a brightening eye glint before the strike lands.
- **Awareness:** Drawn by open ground during storm build-up; ignores players who shelter under cover.
- **Counter:** Shelter or keep moving so the strike point misses, and strike during the calm between wing-beat volleys.
- **Deeper:** Strikes chain in patterns rather than singles, and the storm builds faster.

### Simurgh

- **Move:** Majestic flyer-caster that circles slowly and deliberately, rarely hurrying, with long glides between actions.
- **Attack:** Sweeping wing gusts and radiant feather volleys from above, telegraphed by a slow wing raise and a shimmer along the feathers before release.
- **Awareness:** Drawn to players who linger in the open; patient, and slow to abandon a chosen vantage.
- **Counter:** Read the slow wing raise, step out of the gust line, and punish the long glide after a volley.
- **Deeper:** Volleys fan wider and gusts push the player, turning positioning into the fight.

### Ziz

- **Move:** Immense sky bird whose passing darkens the ground; it circles at great height and stoops rarely but hugely.
- **Attack:** A vast stooping rake along a long dive line, telegraphed by the sun dimming under its wings and a long shadow sweeping the floor.
- **Awareness:** Drawn by anything moving in the open beneath its circle; ignores sheltered players entirely.
- **Counter:** Shelter the moment the light dims, step far off the shadow line, and strike only during the long recovery after a stoop.
- **Deeper:** The stoop's shadow sweeps faster and the bird passes lower, shrinking the safe window.

## Mesoamerican & Andean

Water, night, and sky beings from Mexica, Maya, and Andean traditions. Lures, grabs, and transformations dominate: several of these creatures want the player to come closer, or to look away, before they strike.

### Ahuizotl

- **Move:** Aquatic ambusher that lurks just below a waterline or pool edge, still and low, then surges out.
- **Attack:** A grabbing tail-hand snatch that drags the player toward the water, telegraphed by ripples and a faint cry like a distressed animal luring the curious closer.
- **Awareness:** Drawn by approach to the water's edge and by curiosity toward its lure cry; ignores players who keep their distance from the pool.
- **Counter:** Do not approach the lure; strike the tail-hand during its reach, and break free the moment the drag starts.
- **Deeper:** Lure cries come from multiple directions, and the snatch reaches farther from the waterline.
- **Flags:** needs systems step

### Death Bat

- **Move:** Flyer-lifedrain that circles in the dark, darting in for quick bites and climbing away, never landing to fight.
- **Attack:** A diving bite that drains as it clings briefly, telegraphed by a circling shriek and a dive line that steepens at the last moment.
- **Awareness:** Drawn by movement and warmth in dark spaces; loses the trail if the player shelters and stays still.
- **Counter:** Step off the dive line, strike during the cling, and do not let it chain dives unanswered.
- **Deeper:** Dives come in quick succession from alternating directions, and the cling lasts longer.
- **Flags:** needs systems step

### Nagual

- **Move:** Shapeshifter that approaches in one animal form, then changes shape mid-fight to change its movement — from ground lope to skitter to flight-like dart.
- **Attack:** The attack changes with the form: bites, claws, or a darting strike, each telegraphed by a shimmer and a posture shift in the moment before the change completes.
- **Awareness:** Drawn by lone players and by players who fixate on one form; it changes form when its current approach is answered.
- **Counter:** Read the shimmer, not the form — strike during the change itself, and adapt to the new movement rather than chasing the old one.
- **Deeper:** Form changes come faster and mid-attack, so the player must read the shimmer rather than memorize a form.
- **Flags:** needs systems step

### Storm Wraith

- **Move:** Storm caster that drifts at range, riding gusts, and repositions after every cast rather than closing to melee.
- **Attack:** Wind and lightning bursts from range, telegraphed by a long, visible gathering of storm light before each release.
- **Awareness:** Drawn by open ground and by players who stand still; drifts away when rushed.
- **Counter:** Close during the long gathering, interrupt or dodge the release, and punish the drift.
- **Deeper:** Bursts chain into storm fronts that sweep the floor, forcing movement between casts.
- **Flags:** thin lore — director call

### Tzitzimitl

- **Move:** Skeletal star-being caster that descends slowly from above and holds a high vantage, drifting rather than walking.
- **Attack:** Starlight volleys and a dread gaze that slows the player, telegraphed by a brightening of its skeletal eyes and a stillness before the volley.
- **Awareness:** Drawn by players who linger under open sky; slow to notice sheltered or fast-moving players.
- **Counter:** Break line of sight during the eye-brightening, move between volleys, and strike during the long cooldown after a gaze.
- **Deeper:** Volleys fan wider and the gaze holds longer, turning the fight into a rhythm of cover and advance.
- **Flags:** needs systems step

### Cipactli Brood

- **Move:** Ravenous swarm of small primordial crocodilian young that surge forward in a mass, flowing around obstacles.
- **Attack:** Many small bites from all sides at once, telegraphed by the massing surge and a churning ripple of bodies before they close.
- **Awareness:** Drawn by movement and by anything that smells of prey; the brood follows the loudest, nearest target.
- **Counter:** Keep moving, avoid being surrounded, and thin the leading edge to break the surge's momentum.
- **Deeper:** The brood splits into flanking surges instead of one mass, and reforms after being scattered.
- **Flags:** thin lore — director call

## African Traditions

Spirits and water beings from West, Central, and Southern African traditions. Small size, invisibility, and treachery are the themes: several of these creatures are most dangerous when unseen, unheard, or mistaken for something harmless. Impundulu is also tagged Sky & Storm elsewhere; it is written here only, with that overlap noted.

### Tokoloshe

- **Move:** Tiny ambusher-skirmisher that darts between cover at ankle height, vanishing between strikes.
- **Attack:** Quick low strikes and tripping grabs from unexpected cover, telegraphed by a faint rustle and a glimpse of movement at ground level before it darts.
- **Awareness:** Drawn by sleepers, the unwary, and players who ignore low cover; ignores players who watch the ground line.
- **Counter:** Watch low cover, strike the rustle's source, and never assume a cleared room stays cleared.
- **Deeper:** Darts come from alternating cover points with almost no pause, and the rustle reads later.
- **Flags:** needs systems step

### Adze

- **Move:** Firefly-form skirmisher that drifts innocently as a small light, then shifts to a striking form at close range.
- **Attack:** A draining bite delivered after drifting close under the guise of a harmless light, telegraphed by the light hovering too long and brightening before the shift.
- **Awareness:** Drawn to sleeping or still players; wary of players who watch the light and keep it at range.
- **Counter:** Do not let the light settle near you — strike or drive it off while it still looks harmless.
- **Deeper:** Multiple lights drift at once, and only one is the true Adze, forcing the player to read the hovering tell.
- **Flags:** needs systems step

### Impundulu

- **Move:** Lightning bird and storm caster that circles high, dives, and rides storm winds; also tagged Sky & Storm, written here only.
- **Attack:** Lightning strikes called from its circling flight and a diving talon rake, telegraphed by a brightening storm glint and a steepening dive line.
- **Awareness:** Drawn by storm build-up and by players in the open; ignores sheltered players.
- **Counter:** Shelter during the glint, step off the dive line, and strike during the climb-away.
- **Deeper:** Lightning chains between strikes, and dives follow strikes with less delay.

### Sasabonsam

- **Move:** Flyer-ambusher that hangs motionless in high branches or canopy cover, then drops onto prey below.
- **Attack:** A dropping ambush with hooked feet and iron teeth, telegraphed by a faint silhouette above the path and a rustle in the canopy just before the drop.
- **Awareness:** Strikes at lone travelers passing beneath its perch; ignores players who scan above and avoid the drop zone.
- **Counter:** Look up, avoid the perch zone, and punish the landing recovery if it drops and misses.
- **Deeper:** Drops come from higher perches with less canopy warning, and a missed drop flows into a winged lunge.

### Mami Wata

- **Move:** Aquatic caster that holds a waterline vantage, drifting and beckoning, never closing to honest melee.
- **Attack:** Luring calls and water magic from range, telegraphed by a shimmering, beautiful display and a stillness before the lure takes hold.
- **Awareness:** Drawn by players who approach the water and linger; loses hold on players who turn away and break the lure.
- **Counter:** Do not approach the display; break line of sight during the shimmer, and strike from range during the cooldown.
- **Deeper:** Lures layer — a second display begins while the first is still fading, punishing players who only break one.
- **Flags:** needs systems step

### Inkanyamba

- **Move:** Great storm serpent that coils in deep water and rises with storms, moving in heavy surges rather than quick darts.
- **Attack:** Storm-lashed coils and sweeping tail strikes, telegraphed by water churning and a rising serpent silhouette before each surge.
- **Awareness:** Drawn by storms and by players near deep water; slow to notice players far from its pool.
- **Counter:** Keep away from the waterline, read the churn, and strike during the settle after a surge.
- **Deeper:** Surges summon storm gusts that push the player toward the water, tightening the safe ground.

## Public code ingredients

Appendix only — references and adaptation notes, no code pasted here. Nothing in this appendix changes a spec above; code application belongs to the systems step. Each source below had its license verified on its own source page during this research. One candidate found in search — a paid itch.io horror-creature pack advertising a CreatureAI script — is deliberately NOT listed, because no license could be verified on its page.

- **CodingQuests — Enemy AI (Godot 4)** — https://store.godotengine.org/asset/codingquests/enemy-ai/ — License: MIT for the code, verified on the asset page. — What we would adapt: the shared state shape (idle, chase, telegraph, attack, recovery) and its readable telegraphs (ring and line markers), plus its charger (locks a direction, shows a long line, then dashes) and its weaving skirmisher. Fits the chargers, brutes, and skirmishers in Beasts, and the dive telegraphs of the Sky & Storm birds once translated from flat arena steering to height and dive lines. — Abysmal-original: Abysmal's own creatures, models, tells, and depth-scaled complexity replace the demo's four enemies wholesale; only the state-machine shape and telegraph-readability idea are adapted, with credit to the source.
- **CodingQuests — State Machine (Godot 4)** — https://store.godotengine.org/asset/codingquests/state-machine/ — License: MIT for the code, verified on the asset page. — What we would adapt: the node-per-state pattern (one node per state, transitions by signal, forced transitions from outside for hit interruption) and its telegraphed leap enemy, whose leap only hits on landing and leaves a vulnerable window after. Fits ambushers (Panther, Tiger, Sasabonsam), flyers' dives, and any creature whose attack needs a clear vulnerable window. — Abysmal-original: states are named and tuned for Abysmal's own creatures and its backstab and perception rules; the demo slime, sprites, and room are not reused.
- **LimboAI — Behavior Trees & State Machines for Godot 4** — https://github.com/limbonaut/limboai/blob/HEAD/README.md — License: MIT-style, verified on the project README (logo and demo art separately under CC-BY, not needed here). — What we would adapt: behavior-tree composition for the most complex creatures — pack coordination (Wolf, Hyena, Baboon Troop), form-change logic (Nagual, once the systems step defines shapeshifting), and multi-phase storm patterns (Thunderbird, Impundulu, Inkanyamba) — plus its hierarchical state machines where a creature needs nested states (for example, a charger that is also a brute). — Abysmal-original: trees are built from Abysmal's own spec bullets in this file, not from the demo project's charger or tutorial trees; LimboAI is infrastructure, credited as such, and Abysmal's behaviors remain its own design.

## Sources consulted

- https://en.wikipedia.org/wiki/Ahuizotl_(mythology)
- https://www.mexicolore.co.uk/aztecs/aztefacts/water-dog-detective
- https://en.wikipedia.org/wiki/Ziz
- https://en.wikipedia.org/wiki/Sotz
- https://fictionhorizon.com/top-15-creatures-from-african-mythology/
- https://storytellingdb.com/monsters-african-mythology/
- https://mythicalencyclopedia.com/aztec-mythology-creatures/
- https://www.birdful.org/what-is-the-great-bird-in-mythology/
- https://worldhistoryedu.com/mythical-birds-from-pantheons-around-the-world/
- https://store.godotengine.org/asset/codingquests/enemy-ai/
- https://store.godotengine.org/asset/codingquests/state-machine/
- https://github.com/limbonaut/limboai/blob/HEAD/README.md


---

[Part file: behavior-specs/part-3.md](behavior-specs/part-3.md)

## Part 3 — Goblin-Kin & Cave Folk, Orcs, Trolls & Giant-Kin, Humans & the Damned Living

Specs only: behavior patterns for the systems step to implement. No stat numbers anywhere in this file — behavior only. Game canon honored throughout: the Kobold's core is gadget-tinker (traps and gadgets are its signature behavior; color is open and dragonkin is NOT required), and goblin coloration (including grey) is cosmetic only, never a behavior difference. Mercy and apex-spawn rules are systems-step matters and are not specced here. AI vocabulary follows the game's existing archetypes (brawler, brute, tank, skirmisher, charger, caster, ranged, grappler, trapper, ambusher, pack skirmisher, tank/regen).

## Goblin-Kin & Cave Folk

Small, cunning cave-dwellers who win by numbers, tricks, and terrain rather than honest strength. The family's signature is misdirection: traps, ambushes, sabotage, and guardians who punish greed. Lone members are pests; packs are a problem.

### Kobold

- **Move:** scurries low along walls and through side passages, keeping cover between itself and the player; retreats toward its own devices when pressed.
- **Attack:** gadget-tinker signature — it lays traps and triggers small devices (snares, spring-jaw contraptions, sputtering noisemakers) rather than fighting fair; its own melee is a weak jab used only when cornered.
- **Awareness:** drawn to noise and to players lingering near its devices; ignores players who pass quickly without disturbing anything.
- **Counter:** watch the floor and walls for the faint trap hint the game always gives, trigger devices from range or from behind, and corner it away from its gear.
- **Deeper:** devices chain together at greater depth — one trap herds the player into another, and the kobold resets spent devices if left alone.

### Goblin

- **Move:** pack skirmisher — darts in loose groups, circling and repositioning rather than holding a line.
- **Attack:** quick stabs and thrown stones or darts, with one goblin darting in while others hang back; the telegraph is a short crouch-and-lunge readable at a glance.
- **Awareness:** drawn to combat noise and to wounded or isolated targets; scatters briefly when a packmate falls.
- **Counter:** break the pack's rhythm — drop one fast, keep moving so the circle cannot close, and attack from behind while one is winding up.
- **Deeper:** packs coordinate at greater depth, with some goblins holding back as throwers while others rush.

### Goblin Sneak

- **Move:** ambusher — creeps along edges and waits in shadowed alcoves, moving only when the player looks away or passes.
- **Attack:** a single backstab-style lunge from concealment, telegraphed by a faint shimmer/hint just before it springs, then it flees to a new hiding spot.
- **Awareness:** drawn to players who linger near cover; ignores fast-moving players it cannot get behind.
- **Counter:** sweep alcoves before looting, keep moving, and strike the moment the hint appears — it is fragile once revealed.
- **Deeper:** chains hiding spots at greater depth, repositioning twice before committing to a lunge.
- **Flags:** thin lore — director call

### Goblin Shaman

- **Move:** caster — hangs back behind other goblins, repositioning to keep allies between itself and the player.
- **Attack:** spits crackling bolts and raises a warding gesture (a raised staff and a visible glow) that rallies nearby goblins to press harder; the staff-raise is the tell.
- **Awareness:** drawn to ongoing fights involving its pack; ignores players who have not yet engaged the pack.
- **Counter:** cut through the pack to reach it, or interrupt the staff-raise — without the shaman, the pack's pressure collapses.
- **Deeper:** at greater depth it rotates between bolt volleys and rally gestures, forcing the player to choose which to interrupt.

### Hobgoblin

- **Move:** disciplined skirmisher — advances in a loose line, holds ground instead of scattering, and re-forms after a push.
- **Attack:** drilled spear thrusts and shield bashes in sequence; the spear is leveled visibly before each thrust, giving a clean dodge window.
- **Awareness:** drawn to formation fights and to players who challenge it head-on; ignores bait that would break its line.
- **Counter:** flank it — the line is strong forward and weak at the edges — and punish the recovery after a missed thrust.
- **Deeper:** at greater depth it fights in pairs that cover each other's recovery, so a single dodge no longer opens both.

### Bugbear

- **Move:** ambusher/brute — stalks silently despite its bulk, then bursts from cover at close range.
- **Attack:** a heavy grab-and-maul rush; the tell is a sudden stillness, then a roar and charge with no further warning.
- **Awareness:** drawn to lone, quiet players and to players who have stopped moving; ignores noisy groups it cannot isolate.
- **Counter:** never stand still in its territory — keep moving, listen for the stillness, and sidestep the rush to punish its long recovery.
- **Deeper:** at greater depth it feints a rush, checks, and rushes again from a new angle.

### Boggart

- **Move:** haunting skirmisher — flickers between hiding spots in a room, never holding one place, moving in short unsettling hops.
- **Attack:** escalating mischief turned violent: first it harries with thrown clutter and sudden noises, then it lunges with clawed swipes once the player is rattled; the escalation itself is the tell.
- **Awareness:** drawn to players who settle in one place (looting, resting, lingering); ignores players passing through briskly.
- **Counter:** do not camp in its room — keep moving, finish business fast, and strike during the pause between its hops.
- **Deeper:** at greater depth the mischief phase shortens and the violent phase starts sooner.

### Redcap

- **Move:** relentless brawler — stomps forward in iron-shod boots, never retreating, never circling, straight at the player.
- **Attack:** savage pikestaff thrusts and talon rakes; the tell is the staff being drawn back and the cap's glow flaring before each thrust.
- **Awareness:** drawn to anyone sheltering or lingering in its claimed ruin-room; ignores players who flee its territory outright.
- **Counter:** dodge the thrust and punish the recovery; do not trade blows head-on, and do not let it corner you against a wall.
- **Deeper:** at greater depth it grows frenzied after landing a blow, chaining thrusts with shorter pauses between them.
- **Note:** also tagged Celtic; written here per assignment, overlap noted.

### Spriggan

- **Move:** guardian skirmisher — small and quick around its guarded spot (a hoard, a barrow, a treasure nook), darting between cover and refusing to be lured far.
- **Attack:** spiteful swipes plus a signature swell — it visibly inflates, limbs lengthening, before delivering a giant-strength slam; the swelling is the telegraph.
- **Awareness:** drawn overwhelmingly to players approaching or touching its guarded spot; ignores players who keep their distance from it.
- **Counter:** bait the swell from range, dodge the slam, and punish while it shrinks back down; never fight it standing on its hoard.
- **Deeper:** at greater depth it swells more than once in a fight and guards a wider area.
- **Flags:** needs systems step
- **Note:** also tagged Celtic; written here per assignment, overlap noted.

### Gremlin

- **Move:** saboteur skirmisher — tiny, fast, and almost always in motion, darting underfoot and around the player's flanks.
- **Attack:** sabotage first, claws second — it tampers with the player's gear and surroundings (jamming, snagging, misdirecting) and nips while the player is distracted; the tell is a flurry of small motions around the player's feet or pack.
- **Awareness:** drawn to machinery, gear, and players fussing with equipment; ignores players who are simply walking past.
- **Counter:** keep moving and swat it the moment it settles to tamper — it cannot stand a direct hit — and check gear after any encounter.
- **Deeper:** at greater depth it tampers faster and in pairs, so one distracts while the other works.
- **Flags:** needs systems step

### Púca

- **Move:** shapeshifting trickster — approaches in one form (most often a dark horse-like shape, sometimes a smaller beast shape) and moves with an uncanny, playful gait, circling the player.
- **Attack:** a wild-ride lure — it invites approach, then bursts into a bucking charge that carries the player off-balance, followed by mischievous swipes; the form-change shimmer is the telegraph.
- **Awareness:** drawn to lone travelers and to players who follow it; ignores players who refuse the lure and walk on.
- **Counter:** refuse the bait — do not chase it — and strike during the shimmer, when it is between forms and briefly vulnerable.
- **Deeper:** at greater depth it changes form mid-fight more than once, so the player must re-read its attacks each time.
- **Flags:** needs systems step
- **Note:** also tagged Celtic; written here per assignment, overlap noted.

### Goblin Champion

- **Move:** brute leader — strides at the head of its pack, holding the center while lesser goblins circle.
- **Attack:** heavy overhead chops with a long wind-up (weapon raised high, the defining brute tell), plus a rallying bellow that sends nearby goblins surging forward.
- **Awareness:** drawn to the thickest fighting; ignores lone stragglers while its pack is engaged.
- **Counter:** dodge the overhead chop and punish the recovery, or cut down its pack first so the bellow has no one to rally.
- **Deeper:** at greater depth it alternates chops with a sweeping arc, so the safe side keeps changing.
- **Flags:** thin lore — director call

## Orcs, Trolls & Giant-Kin

The heavy end of the dungeon: honest brutality at increasing scale. Orcs bring numbers and warcraft, trolls bring regeneration and reach, giants bring terrain-shaking blows. The counter is almost always the same shape — read the long wind-up, dodge, punish — but the scale and the company keep changing.

### Orc

- **Move:** brute — advances steadily, no retreat, no flanking dance, straight toward the player.
- **Attack:** heavy overhead chops with a slow, readable wind-up; punishing if it connects, harmless if dodged.
- **Awareness:** drawn to combat noise and visible players; ignores players it has not seen or heard.
- **Counter:** sidestep the chop, strike during the recovery, and never stand in front of it trading blows.
- **Deeper:** at greater depth it chains a second chop after a missed first, so the punish window arrives later.

### Orc Berserker

- **Move:** charger — paces, then erupts into a sprinting rush once it has a clear line.
- **Attack:** a frenzied flurry of wild swings; the tell is a chest-beating pause and a scream before the rush, then swings with almost no wind-up once it arrives.
- **Awareness:** drawn to the nearest visible foe and to fresh wounds; ignores everything else once the rush begins.
- **Counter:** sidestep the rush and let it overshoot into a wall or open ground, then punish while it recovers its footing.
- **Deeper:** at greater depth it recovers from a missed rush faster and may turn into a second rush instead of stopping.

### Half-Ogre

- **Move:** heavy skirmisher — lumbers forward, faster than a full ogre but with the same directness, and occasionally breaks into a short bull-rush.
- **Attack:** club swings with a long wind-up, plus the occasional shoulder-barge; the club raise is the tell for the swing, a lowered head for the barge.
- **Awareness:** drawn to visible players and to food or loot left in the open; ignores hidden players.
- **Counter:** dodge the swing, step aside from the barge, and punish from behind while it turns.
- **Deeper:** at greater depth it alternates swing and barge without pausing, so the player must read which tell is showing.
- **Flags:** thin lore — director call

### Ogre

- **Move:** brute/tank — slow, deliberate advance; does not rush, does not retreat, simply keeps coming.
- **Attack:** massive club slams in a wide arc; the tell is the club raised high overhead and held a beat before falling.
- **Awareness:** drawn to noise and movement; ignores still, quiet players until close.
- **Counter:** stay mobile, dodge the arc, and strike during the long recovery after each slam.
- **Deeper:** at greater depth its slams send a shockwave along the ground, so dodging sideways is no longer enough — dodge back as well.

### Marsh Troll

- **Move:** lurking tank — wades and waits in wet, low ground, moving slowly but rising suddenly when a player comes near.
- **Attack:** long-armed swipes and a grappling grab that drags the player closer; the tell is water or muck stirring before it rises.
- **Awareness:** drawn to splashing and movement through its wet ground; ignores players who skirt the marsh edge.
- **Counter:** fight it on dry ground — lure it out of the wet — and break the grab early by moving away the moment it reaches.
- **Deeper:** at greater depth it uses the wet ground itself, lunging from further out and retreating into it between swipes.
- **Flags:** thin lore — director call

### Troll

- **Move:** tank/regen — relentless shambling advance; wounds visibly close over time, so it does not slow as the fight goes on.
- **Attack:** crushing fists and sweeping arm blows; the tell is both arms drawing back before a double slam.
- **Awareness:** drawn to any visible player; ignores nothing once engaged — it simply does not stop.
- **Counter:** keep pressure on without pause (pauses let it recover), dodge the double slam, and punish from the side.
- **Deeper:** at greater depth it recovers faster between exchanges, so the player must chain attacks with fewer gaps.

### Orc Shaman

- **Move:** caster — holds back behind orc fighters, shifting position to keep a screen of allies in front.
- **Attack:** searing bolts and a war-drum rhythm that visibly emboldens nearby orcs; the drum-beat and raised fetish are the tells.
- **Awareness:** drawn to ongoing orc fights; ignores players who have not engaged its warband.
- **Counter:** cut through the screen to reach it, or interrupt the drum-beat — without it, the warband's pressure falls off.
- **Deeper:** at greater depth it alternates bolts and drum-beats in a faster rhythm, forcing the player to pick which to interrupt.

### Cave Troll

- **Move:** ambush tank — waits motionless in dark cave stretches, then lumbers out once the player is close.
- **Attack:** boulder-hurling from range (the lifted stone is the tell) followed by crushing club work up close.
- **Awareness:** drawn to light and noise in its cave stretch; ignores players who pass silently in darkness.
- **Counter:** keep distance until the stone is thrown, dodge it, then close in while it switches to the club.
- **Deeper:** at greater depth it throws from further off and chains a second stone before closing.

### Ettin

- **Move:** brute with two heads — lurches forward, each head scanning a different direction, so it is very hard to approach unseen.
- **Attack:** twin club swings, one from each side, landing in sequence rather than together; the tells are the two separate club raises, left then right.
- **Awareness:** drawn to movement on either side; ignores almost nothing — the two heads cover each other's blind spots.
- **Counter:** dodge the first swing, then dodge again — the second swing is the trap — and punish only after both have fallen.
- **Deeper:** at greater depth the two swings overlap more tightly, shrinking the gap between them.

### Cyclops

- **Move:** slow brute — ponderous advance, head turning to track the player with its single eye.
- **Attack:** a massive club sweep and a grabbed boulder throw; the tell is the eye fixing on the player and the arm drawing far back before either.
- **Awareness:** drawn to movement in its line of sight; its blind side (away from the eye's gaze) is its weak side, and it is slow to turn.
- **Counter:** circle to its blind side, dodge the sweep, and strike while it re-aims.
- **Deeper:** at greater depth it sweeps in a wider arc and throws sooner after a missed sweep.

### Hill Giant

- **Move:** towering brute — strides forward, shaking the ground with each step, too big to be subtle and too stubborn to stop.
- **Attack:** a tree-limb club brought down in a huge overhead arc; the tell is the limb raised high and the giant planting its feet.
- **Awareness:** drawn to noise and visible players at range; ignores small, still targets until close.
- **Counter:** stay close and mobile — the arc is deadliest at range — dodge under the swing and strike at its legs during recovery.
- **Deeper:** at greater depth it follows a missed arc with a ground-stomp, so standing still after a dodge is punished.

### Stone Giant

- **Move:** patient tank — advances slowly, often from a motionless stance that reads as part of the cave itself.
- **Attack:** hurled rocks from range (the raised arm and braced stance are the tell) and crushing fists up close.
- **Awareness:** drawn to movement across open ground; ignores players who stay behind cover.
- **Counter:** use cover to break its line of sight, close during the pause after a throw, and dodge the fists from the side.
- **Deeper:** at greater depth it throws in pairs, so the player must dodge twice before closing.

### Frost Giant

- **Move:** chilling brute — strides through cold ground, leaving frost in its wake, advancing steadily without haste.
- **Attack:** a great axe sweep plus a freezing breath that visibly mists before it blows; the inhale and the mist are the tells.
- **Awareness:** drawn to warmth and movement; ignores cold, still places.
- **Counter:** dodge the breath sideways (never backward into the cone) and punish the axe recovery; keep moving so the cold cannot settle.
- **Deeper:** at greater depth the breath lingers as a freezing patch on the ground, denying the player that footing.
- **Note:** also tagged Norse; written here per assignment, overlap noted.

### Ogre Mage

- **Move:** caster brute — advances like an ogre but pauses at range to work its magic, keeping distance when it can.
- **Attack:** bolts of conjured force plus a sudden blinking reposition (a shimmer and a vanishing puff mark the departure, and it reappears at a new angle); the raised hands and gathering glow are the tells.
- **Awareness:** drawn to visible players at range; ignores players who close to melee before it can cast.
- **Counter:** close the distance fast — it is weakest up close — and watch for the shimmer to re-acquire it after each blink.
- **Deeper:** at greater depth it blinks more often and casts immediately on reappearing, so the player must dodge on the shimmer, not on the reappearance.
- **Flags:** thin lore — director call

### Fire Giant

- **Move:** blazing brute — advances through hot ground, trailing heat, with the same deliberate stride as other giants.
- **Attack:** a blazing sword sweep plus a wave of flame breathed or hurled forward; the tell is the sword or maw glowing brighter before release.
- **Awareness:** drawn to movement and to cool, unburned ground it can set alight; ignores players sheltering behind stone.
- **Counter:** dodge the flame sideways, fight from stone cover, and punish the sword recovery — never stand in the burned ground it leaves behind.
- **Deeper:** at greater depth the flame leaves burning patches that narrow the safe ground as the fight goes on.
- **Note:** also tagged Norse; written here per assignment, overlap noted.

## Humans & the Damned Living

Not monsters by nature but by choice or curse: outlaws, cultists, and the damned who walk the dungeon with human cunning. They fight with tools, plans, and malice rather than bulk — traps, poisons, rituals, and ambushes — and they are the family's real danger because they think.

### Brigand

- **Move:** skirmisher — darts between cover, strikes, and falls back, never holding a losing position.
- **Attack:** quick blade cuts and thrown knives; the tell is a brief pause in cover before each darting strike.
- **Awareness:** drawn to lone players and to players carrying visible loot; ignores well-guarded groups.
- **Counter:** deny it cover — force it into the open — and punish the moment it pauses before a strike.
- **Deeper:** at greater depth brigands hunt in pairs, one flushing the player toward the other's knives.

### Grave Robber

- **Move:** skulking skirmisher — creeps along walls and around burial nooks, fleeing the moment it is spotted, returning when the player is busy.
- **Attack:** a desperate shovel or knife swipe when cornered, plus scattering debris to blind and distract; the tell is the sudden turn-and-swing when its escape is cut off.
- **Awareness:** drawn to burial sites, tombs, and unattended loot; ignores players who are not near anything worth stealing.
- **Counter:** cut off its escape route first, then engage — in the open it folds quickly.
- **Deeper:** at greater depth it lays a parting snare on its escape path, so chasing it blindly is punished.

### Cultist

- **Move:** fanatic skirmisher — advances chanting, heedless of danger, in loose groups that converge on the player.
- **Attack:** ritual dagger lunges plus a channeled rite (raised arms, glowing circle, rising chant) that calls something forth if completed; the rite's glow and chant are the tells.
- **Awareness:** drawn to ritual sites and to players who disturb them; ignores players who avoid the ritual ground.
- **Counter:** interrupt the rite — strike the chanter before the chant peaks — and scatter the group before it converges.
- **Deeper:** at greater depth the rite completes faster and the group guards its chanter, so the player must break the guard first.
- **Flags:** needs systems step

### Witch

- **Move:** cackling caster — keeps distance, circling on foot or with uncanny hops, always repositioning after each cast.
- **Attack:** hexes and thrown phials — a curse gesture (pointed finger, muttered words, a visible dark wisp) that withers and slows, and bottles that burst into clinging effects; the gesture and the raised bottle are the tells.
- **Awareness:** drawn to players who linger in her claimed ground and to players who have wronged her coven-mates; ignores passing travelers who leave her ground alone.
- **Counter:** close fast and interrupt the gesture — she is fragile up close — and dodge the phials sideways rather than backing away.
- **Deeper:** at greater depth she chains a hex into a phial throw, so the player must dodge twice in sequence.

### Berserker

- **Move:** charger — paces at range, then erupts into a headlong rush with no regard for its own safety.
- **Attack:** a whirlwind of axe swings once it arrives; the tell is a roaring pause and a stamped foot before the rush, then swings with almost no wind-up.
- **Awareness:** drawn to the nearest foe and to fresh blood; ignores everything else once the rush begins.
- **Counter:** sidestep the rush, let it overshoot, and punish while it gathers itself for another run.
- **Deeper:** at greater depth it chains a second rush immediately after a missed first, with only a breath between them.

### Bandit Chief

- **Move:** commander skirmisher — holds the center of a bandit group, directing with shouts and gestures, moving to wherever the fight is thickest.
- **Attack:** skilled bladework with feints — a raised blade that may become a cut or a thrust — plus a shouted order that sends nearby bandits surging; the shout and the raised blade are the tells.
- **Awareness:** drawn to the thickest fighting and to players who threaten its band; ignores lone stragglers while its band is engaged.
- **Counter:** silence the orders by engaging the chief directly, or cut down its band first so the orders have no one to carry out.
- **Deeper:** at greater depth it rotates between bladework and orders faster, forcing the player to choose which to answer.
- **Flags:** thin lore — director call

### Mad Alchemist

- **Move:** erratic caster — staggers and darts unpredictably, changing direction mid-approach, never moving in a straight line for long.
- **Attack:** a barrage of thrown phials with mixed effects — bursting, clinging, choking — each telegraphed by the phial's color and the wind-up of the throw; the unpredictability is in which phial comes next, never in whether a throw is coming.
- **Awareness:** drawn to noise and to players who disturb its workbenches and stockpiles; ignores players who avoid its workshop ground.
- **Counter:** read the phial color, dodge sideways, and close during the pause when it fumbles for the next bottle.
- **Deeper:** at greater depth it mixes two phials in one throw, so the player must answer two effects at once.
- **Flags:** thin lore — director call

### Necromancer

- **Move:** deathly caster — drifts at the back of the fight, behind a screen of its own risen dead, repositioning only when that screen thins.
- **Attack:** bolts of grave-cold force plus a raising gesture (raised staff, green glow, corpses stirring) that brings fallen foes back to fight; the staff-raise and the stirring are the tells.
- **Awareness:** drawn to battlefields and burial ground where bodies are plentiful; ignores players in places with nothing to raise.
- **Counter:** cut through the risen screen to reach it, or interrupt the staff-raise — without the necromancer, the risen fall with it.
- **Deeper:** at greater depth it raises faster and from further off, so the player must interrupt earlier.
- **Flags:** needs systems step

### Warlock

- **Move:** pact caster — keeps range, circling slowly, always with a patron's mark glowing as it casts.
- **Attack:** eldritch bolts and a channeled blast (gathering dark glow, a raised hand, a beat of stillness) that hits hard if allowed to complete; the glow and the stillness are the tells.
- **Awareness:** drawn to players who carry magic or who disturb its pact-site; ignores players who avoid that ground.
- **Counter:** interrupt the channel — strike during the stillness — and keep moving so the bolts cannot track.
- **Deeper:** at greater depth the channel completes faster and the bolts track longer, so the interrupt window shrinks.

### Plague Bearer

- **Move:** shambling carrier — advances slowly and inevitably, trailing sickness, never hurrying and never stopping.
- **Attack:** a coughing miasma that spreads around it and clinging, diseased swipes; the tell is a deep, rattling inhale before each miasma burst.
- **Awareness:** drawn to crowds and to the living in general; ignores nothing once it has scented the player.
- **Counter:** fight at range and never stand in the miasma — dodge the inhale sideways — and finish it fast rather than trading blows up close.
- **Deeper:** at greater depth the miasma lingers longer on the ground, shrinking the safe footing as the fight goes on.
- **Flags:** thin lore — director call

### Fallen Knight

- **Move:** disciplined brute — advances in a knight's measured stride, shield raised, never rushing, never breaking form.
- **Attack:** a shield bash followed by a heavy sword cut, in sequence; the tells are the shield drawing back for the bash and the sword rising for the cut.
- **Awareness:** drawn to honorable challenges and to players who face it head-on; ignores bait that would break its stance.
- **Counter:** dodge the bash, then dodge the cut — the punish window opens only after both — and strike from the shield's blind side.
- **Deeper:** at greater depth it chains a second cut after the first, so the safe moment arrives one beat later.

## Sources consulted

- https://en.wikipedia.org/wiki/Redcap
- https://en.wikipedia.org/wiki/Pwca
- https://en.wikipedia.org/wiki/Spriggans
- https://en.wikipedia.org/wiki/boggarts
- https://en.wikipedia.org/wiki/Kobold
- https://en.wikipedia.org/wiki/Gremlin
- https://nerdsonearth.com/2019/01/ettin/
- https://www.danielkirkpatrick.co.uk/irish-mythology/puca-irish-mythology/
- https://www.spookyisles.com/what-are-spriggans/
- https://www.royalaviationmuseum.com/gremlims/
- Game canon and AI vocabulary: `design-notes/behavior-catalog-phase1.md` (skimmed for archetype vocabulary only; no text copied).

## Public code ingredients

References and adaptation notes only — no code pasted here, and no game code changed. Code application stays with the systems step. Each source below had its license verified on its own page during this task (Nov 4, 2026). All three are structural frameworks, not behavior content: Abysmal's own creature patterns above are the content, and any adopted framework code would be adapted to Abysmal's existing AI and credited, never cloned wholesale.

- **Beehave** — https://github.com/bitbrain/beehave — License: MIT (verified on the repository page, which lists "License: MIT License (MIT)" and a LICENSE file). Pure-GDScript behavior-tree addon for Godot 4 (branch godot-4.x, v2.10+ for Godot 4.5+). What we would adapt: the tree/composite/decorator/leaf structure and blackboard as the skeleton for complex patterns in this file — pack coordination (Goblin, Hobgoblin), the Púca's form-change decisions, and the shamans' cast-vs-rally choices — with all leaf actions written fresh for Abysmal. Stays Abysmal-original because only the generic tree machinery is reused; every behavior, telegraph, and timing is Abysmal's own spec, and the MIT notice is kept in credits.
- **LimboAI** — https://github.com/limbonaut/limboai — License: MIT-style (verified on the README, which states use is governed by an MIT-style license in its LICENSE file). Behavior trees plus hierarchical state machines for Godot 4, with GDScript support for custom tasks and states; current releases target Godot 4.6+ (module builds for Godot 4.7). What we would adapt: the HSM-plus-tree combination for creatures with coarse modes plus fine decisions — e.g., Spriggan (guard vs. swell-slam modes), Ettin (two-head decision detail inside a brute mode), and the Necromancer (screen vs. raise modes) — with all states and tasks written fresh. Stays Abysmal-original because the addon supplies only the state/tree engine; Abysmal's creature logic, tells, and depth changes are original, and the MIT notice is kept in credits. Note for the systems step: LimboAI ships as a GDExtension, so export targets need its prebuilt binaries; its demo art is CC-BY 4.0 and is NOT needed.
- **CodingQuests Enemy AI** — https://github.com/CodingQuests/godot-enemy-ai — License: MIT for the code (stated on the Godot Asset Store listing, which also notes its sprites are Kenney CC0 and not part of the code license). A single shared state machine (IDLE, CHASE, TELEGRAPH, ATTACK, RECOVERY, DEAD) with per-enemy AI functions, built for Godot 4.7. What we would adapt: only the telegraph/recovery state discipline as a readability pattern for this file's brutes and chargers (Orc, Ogre, Berserker, Fallen Knight) — the explicit TELEGRAPH and RECOVERY states match how these specs already telegraph and punish. Stays Abysmal-original because the pattern is a generic state shape, not copied enemy behavior; Abysmal's attacks, tells, and timings are its own, and the MIT notice is kept in credits.


---

[Part file: behavior-specs/part-4.md](behavior-specs/part-4.md)

## Part 4 — The Undead, Celestials & the Fallen, Demons, Devils & the Damned

Specs only. No game code, stats, or spawn rules are set here. Every telegraph below is meant to read at a glance on a phone screen: a wind-up, a sound, a shape on the ground, or a change in posture before the hit lands. Hidden or drifting foes always leave a faint visible hint first — nothing in this part attacks from zero signal.

## The Undead

The dead here do not share one tempo. Some shamble and trade blows honestly, some drift and refuse to be cornered, and some rule the lesser dead around them. What unites them is persistence: they do not tire, retreat out of fear, or lose interest the way living hunters do.

### Skeleton

- **Move:** Shambles forward on foot, steady and direct, never flanking or fleeing.
- **Attack:** A plain chop with a short weapon-raise before it lands; the approach itself is the warning.
- **Awareness:** Drawn by movement and sound nearby; ignores loot, doors, and anything that is not a living target.
- **Counter:** Step aside during the raise and strike from behind or during its recovery.
- **Deeper:** Skeletons begin arriving in loose groups, so the player must deal with overlapping chop timings rather than a single rhythm.

### Skeleton Archer

- **Move:** Holds a preferred distance on foot, stepping back when the player closes in; never charges.
- **Attack:** Looses arrows after a visible draw-and-aim pause, with the bowstring sound as a second tell.
- **Awareness:** Drawn by line of sight at range; loses interest in targets it can no longer see or hear.
- **Counter:** Close during the draw, break line of sight behind cover, or strike while it steps back.
- **Deeper:** Archers reposition to new vantage points after each volley instead of standing in one spot.

### Zombie

- **Move:** Slow, tireless advance in a shambling group; numbers matter more than speed.
- **Attack:** Grabs and bites at close range, with arms reaching out before the bite lands.
- **Awareness:** Drawn by sound and by the movement of other zombies toward a target; ignores quiet, still prey at a distance.
- **Counter:** Keep moving, do not let the group surround you, and strike during the slow grab reach.
- **Deeper:** Larger groups press from more than one direction at once, so a single escape line stops being safe.

### Skeleton Knight

- **Move:** A deliberate, armored advance; slower than a skeleton, and it never breaks formation to chase recklessly.
- **Attack:** Heavy sword swings with a long, readable raise, followed by a slow recovery.
- **Awareness:** Drawn to the nearest armed threat and holds its ground against it; ignores distant noise once engaged.
- **Counter:** Dodge the raised swing, then punish the long recovery; never trade blows face to face.
- **Deeper:** The knight chains a second swing after a blocked or dodged first swing, so the punish window comes later, not sooner.

### Ghoul

- **Move:** Low, fast skirmishing — darts in, snaps, and breaks away, circling rather than standing to fight. Also tagged Demons in the roster; written here, with the overlap noted.
- **Attack:** Quick lunging bites and claw swipes with only a short crouch as warning.
- **Awareness:** Drawn strongly by the smell and sound of the wounded and the dead; ignores uninjured, quiet targets until they move.
- **Counter:** Predict the dart-in and strike as it lands or turns, rather than chasing it mid-dart.
- **Deeper:** Ghouls begin hunting in pairs that alternate their lunges, so one is always recovering while the other commits.

### Barrow Wight

- **Move:** Heavy, unhurried advance out of its resting place, weapon carried high.
- **Attack:** Wide, punishing weapon arcs with a long raise; the arc's sweep line is the tell.
- **Awareness:** Wakes at intrusion into its barrow ground and fixates on the intruder; ignores anything outside its ground once the intruder leaves.
- **Counter:** Step out of the arc's sweep and strike during the slow recovery after a missed swing.
- **Deeper:** The wight adds a cold, staggering shout before its heaviest arc, forcing the player to move before the swing even starts.

### Specter

- **Move:** Drifts rather than walks, passing through open ground without footsteps and ignoring cover as an obstacle to its own movement.
- **Attack:** A phase-strike delivered from the drift: it shimmers into solidity, strikes, and drifts away. It stays faintly visible throughout, so phase here is movement flavor, never untargetability.
- **Awareness:** Drawn by the living passing near its haunt; it does not hear footsteps, so quiet movement alone does not hide the player from it.
- **Counter:** Watch for the shimmer that precedes solidity, then strike as it materializes or sidestep the strike.
- **Deeper:** The specter chains its drift into a second strike from a new angle before withdrawing.

### Poltergeist

- **Move:** Never shows a body to chase; it stays hidden and works through the room itself.
- **Attack:** Hurls loose debris across the room, with objects rattling and lifting just before they fly — the rattle is the telegraph.
- **Awareness:** Drawn by noise and by objects being disturbed; it ignores a player who stays still and quiet.
- **Counter:** Move when the rattle starts, keep away from cluttered ground, and close on the room's center where debris is thinnest.
- **Deeper:** Debris begins arriving in short bursts from several directions, so one dodge no longer clears the whole attack.

### Draugr

- **Move:** A heavy, plodding advance, weapon in hand, that does not hurry and does not retreat. Also tagged Norse in the roster; written here, with the overlap noted.
- **Attack:** Crushing weapon blows with a long raise, sometimes followed by a shoulder-barge when the player stands too close.
- **Awareness:** Guards its hoard-ground and wakes at intrusion; ignores distant fights once the intruder is driven off.
- **Counter:** Dodge the raised blow, punish the recovery, and do not stand in grappling range after a blocked swing.
- **Deeper:** The draugr's barge becomes a chain: a missed blow flows into a barge instead of a recovery pause.

### Mummy

- **Move:** Slow, inexorable advance on foot, wrappings trailing; it never runs, and never needs to. Also tagged Egyptian in the roster; written here, with the overlap noted.
- **Attack:** Heavy, wrapping-laden strikes at close range, plus a spoken curse at range — the curse is announced by a raised hand and a distinct chanting sound before it lands.
- **Awareness:** Drawn by tomb intrusion and by the living approaching its resting place; ignores anything that leaves its tomb ground.
- **Counter:** Close the distance during the curse chant to interrupt the ranged threat, then dodge the heavy close strikes.
- **Deeper:** The curse chant shortens and the mummy begins cursing while still advancing, so standing at range stops being safe.
- **Flags:** needs systems step

### Phantom

- **Move:** A silent, gliding drift that circles the player at mid-range, never quite committing until it strikes.
- **Attack:** A sudden gliding lunge from the circle, telegraphed by the phantom turning to face the player and brightening before it moves.
- **Awareness:** Drawn by the living entering its haunt; ignores noise and movement outside that ground.
- **Counter:** Face it during the brightening, sidestep the lunge line, and strike as it passes.
- **Deeper:** The phantom's circle tightens and its lunge feints once — a brightening that does not commit — before the real lunge.
- **Flags:** thin lore — director call

### Banshee

- **Move:** Floats at range, drifting to a new vantage after each attack rather than closing to melee.
- **Attack:** The signature wail: a long, unmistakable wind-up — head thrown back, mouth opening, sound rising — followed by an area scream that the player must leave or interrupt before it fires. The wail sound itself is a known audio gap; this spec treats the wail as an attack with a clear visual and rising-audio telegraph regardless.
- **Awareness:** Drawn by the living approaching, and by death and grief in a place; ignores quiet targets at long range until they come closer.
- **Counter:** Break line of sight, move out of the scream's area during the long wind-up, or interrupt the wind-up.
- **Deeper:** The banshee chains a second, shorter wail from its new vantage before drifting again.

### Vampire

- **Move:** Smooth, confident movement — walks in like a guest, closes fast when it decides to feed, and withdraws gracefully when denied.
- **Attack:** A lunge-and-bite that restores the vampire as it harms the player, telegraphed by a pause, a bared-teeth posture, and a direct stare before the lunge.
- **Awareness:** Drawn by blood and by the living at close range; ignores armored, distant, or still targets in favor of an exposed one.
- **Counter:** Dodge the telegraphed lunge, never stand still in its stare, and punish the recovery after a missed bite.
- **Deeper:** The vampire begins feinting the lunge — a stare and posture shift with no commit — before the real bite.
- **Flags:** needs systems step

### Strigoi

- **Move:** Restless, uneven movement that alternates between a shambling walk and sudden bursts of speed, never settling into one rhythm.
- **Attack:** Clawing rushes and a draining bite, telegraphed by a crouch and a hiss before each burst.
- **Awareness:** Drawn by the living at night and by blood; ignores the player during any lull in its restless pacing until it notices movement again.
- **Counter:** Do not trust its slow pace — be ready to dodge the burst — and strike during the pause after a burst ends.
- **Deeper:** The strigoi's bursts come in pairs, with the second burst aimed at where the player dodged to, not where they stood.
- **Flags:** thin lore — director call, needs systems step

### Jiangshi

- **Move:** Stiff, rhythmic hopping with arms held out, unable to bend or turn smoothly; it commits to each hop's direction. Also tagged Chinese in the roster; written here, with the overlap noted.
- **Attack:** Slamming arm strikes and a draining grasp delivered at the end of a hop, with the hop's arc itself as the tell.
- **Awareness:** Drawn by breath and movement rather than sight; a perfectly still player is harder for it to track, while a moving one is found at once.
- **Counter:** Sidestep the hop's landing line, strike during the landing pause, and keep changing direction so its straight hops overshoot.
- **Deeper:** The jiangshi's hops lengthen into a leaping charge, with a longer crouch before the leap as the new tell.

### Vetala

- **Move:** An uncanny, too-fluid movement in a borrowed corpse — it moves like something wearing a body, not living in one. Also tagged South Asian in the roster; written here, with the overlap noted.
- **Attack:** Cunning close strikes mixed with a whispered riddle-chant at range; the chant is announced by the corpse stopping, turning its head, and speaking before the effect lands.
- **Awareness:** Drawn by the living entering charnel ground and by clever, talking prey most of all; ignores mindless or silent targets until they approach.
- **Counter:** Interrupt the chant by closing in, and strike during the stiff pause when the spirit shifts its hold on the body.
- **Deeper:** The vetala begins slipping its hold from one fallen body to another nearby, so defeating one vessel does not end the fight in the way the player expects.
- **Flags:** needs systems step

### Revenant

- **Move:** Relentless, unhurried pursuit in a straight line; it does not sprint, does not flank, and does not stop.
- **Attack:** Heavy, gripping strikes, telegraphed by the revenant raising both arms before each blow.
- **Awareness:** Fixated on one target — the one it came back for — and ignores everything else, including other threats and loot.
- **Counter:** Use its single-mindedness: lead it into hazards or around obstacles, dodge the raised-arm blow, and strike during its slow turn.
- **Deeper:** The revenant stops pausing after missed blows and keeps advancing through them, so the punish window shrinks to the turn itself.

### Sluagh

- **Move:** A flying host, not a single body: a dark, wheeling flock that moves as a crescent across the room. Also tagged Celtic in the roster; written here, with the overlap noted.
- **Attack:** Diving nips from many angles at once, telegraphed by the flock wheeling and tightening overhead before the dive.
- **Awareness:** Drawn to the dying and the exposed, and to the living caught alone in the open; ignores sheltered or grouped targets until they step out.
- **Counter:** Keep moving under cover where possible, dodge when the flock tightens, and strike the flock's leading edge as it dives.
- **Deeper:** The host splits into two wheeling groups that dive from opposite directions in turn.

### Wight Lord

- **Move:** A commanding, unhurried advance at the head of lesser undead, directing them by gesture rather than rushing ahead itself.
- **Attack:** Heavy weapon blows with a long raise, plus shouted commands that send nearby lesser undead surging at the player — the raised weapon and the shout are the tell for both.
- **Awareness:** Drawn to battle and to the living as a commander; ignores lone, distant targets while it still has lesser dead to send.
- **Counter:** Break the lesser dead around it first or dodge past them during the command shout, then punish the lord's own slow recovery.
- **Deeper:** The lord begins repositioning its lesser dead between its own blows, so the player is never fighting the lord alone.
- **Flags:** thin lore — director call, needs systems step

### Lich

- **Move:** A slow, gliding advance that holds range, never hurrying, never cornering itself.
- **Attack:** Ranged death-magic bolts and a raised-staff area blast, each announced by staff glow and a chanting wind-up before it fires.
- **Awareness:** Drawn by intrusion into its sanctum and by the living carrying magic; ignores unarmed, distant targets until they approach.
- **Counter:** Break line of sight during the staff glow, move out of the blast area during the chant, and close in during the recovery after a blast.
- **Deeper:** The lich layers its attacks: a bolt volley forces movement, then the area blast lands where the player was driven to.
- **Flags:** needs systems step

### Dullahan

- **Move:** A mounted charge on a dark horse, riding a straight line at speed and wheeling to charge again. Also tagged Celtic in the roster; written here, with the overlap noted.
- **Attack:** A spine-whip sweep as it passes, plus a thrown-head strike: the rider raises the carried head high and hurls it, with the raised head as the tell before it flies.
- **Awareness:** Drawn by the dying and by names called out in the dark; it fixates on its chosen target and ignores others in its path.
- **Counter:** Sidestep the charge line, dodge the thrown head, and strike during the slow wheel after a missed charge.
- **Deeper:** The dullahan's charge line begins curving slightly toward the player's dodge direction, so a single sidestep stops being enough.

### Gashadokuro

- **Move:** A towering, rattling advance; its bone-clatter announces it before it is seen, and it moves slowly but covers ground with each step. Also tagged Japanese Yōkai in the roster; written here, with the overlap noted.
- **Attack:** Enormous sweeping grabs and a biting lunge, telegraphed by the skeleton rearing back and its eye-glow brightening before it strikes.
- **Awareness:** Drawn by lone travelers and by the living in the open; ignores sheltered or grouped targets until they step out.
- **Counter:** Stay out of the sweep's arc, move when the eye-glow brightens, and strike during the long recovery after a missed grab.
- **Deeper:** The gashadokuro's sweep becomes a double sweep — a low grab followed by a high one — so ducking once no longer clears it.

### Penanggalan

- **Move:** Silent, floating flight as a detached head with trailing organs, drifting at head height and circling before it commits.
- **Attack:** Trailing-organ lashes followed by a draining bite, telegraphed by the head rearing back and the organs coiling before the lash.
- **Awareness:** Drawn by blood and by the living at rest; ignores moving, alert targets until they pause.
- **Counter:** Keep moving, dodge when the organs coil, and strike during the pause after a missed lash.
- **Deeper:** The penanggalan begins lashing while still circling, so the coil warning comes from the side rather than head-on.
- **Flags:** needs systems step

## Celestials & the Fallen

These are not gentle presences. Even the unfallen ones fight like instruments: precise, patient, and without hesitation. The fallen keep the same discipline and turn it toward cruelty, which is what makes them harder to read — their tells are cleaner, and their follow-through is colder.

### Deva

- **Move:** A calm, gliding advance that holds a measured distance, never rushing and never retreating in panic.
- **Attack:** Radiant bolts from range, each announced by a hand raised and a gathering glow before the bolt flies.
- **Awareness:** Drawn to disorder and to the living who threaten what it guards; ignores quiet passers-by who do not disturb its charge.
- **Counter:** Move during the gathering glow, break line of sight, and close in during the pause after a volley.
- **Deeper:** The deva begins firing its bolts in a short, aimed sequence rather than singly, so the player must keep moving through the whole volley.

### Seraph

- **Move:** Sustained flight overhead, circling and holding height, descending only to strike.
- **Attack:** A diving radiant strike plus ranged light bolts from the air, telegraphed by wings folding before a dive and a glow gathering before each bolt.
- **Awareness:** Drawn by the living below and by defiance in its presence; ignores grounded targets that stay under cover.
- **Counter:** Watch the wing-fold for the dive, sidestep the dive line, and strike during the climb-away.
- **Deeper:** The seraph chains a bolt volley into its climb-away, so the ground under the dive line is not safe the moment it passes.

### Ophanim

- **Move:** Rolling movement in any direction without turning, like a wheel that never needs to face its target.
- **Attack:** Sweeping eye-beams that track across the ground, telegraphed by the wheel slowing and its many eyes brightening before the beam fires.
- **Awareness:** Sees in every direction at once; stealth, flanking, and backstabs do not hide the player from it, though cover still blocks its beams.
- **Counter:** Use cover to break the beam, move perpendicular to the sweep, and strike during the slow roll after a beam ends.
- **Deeper:** The ophanim begins rolling while its beam is still sweeping, so the safe ground shifts during the attack itself.
- **Flags:** needs systems step

### Watcher (Grigori)

- **Move:** A still, hovering presence that watches from a distance, drifting slowly to keep the player in view rather than closing in.
- **Attack:** After a long, silent stare — the only warning is the watcher's gaze fixing and brightening — it calls down a column of light on the player's position.
- **Awareness:** Drawn by the living entering its watch and by hidden or secretive movement most of all; ignores open, unhurried passers-by until they linger.
- **Counter:** Never stand still under the fixing gaze; move the moment it brightens, and close in while it recovers from calling the light down.
- **Deeper:** The watcher begins calling light down in a short sequence of columns, each telegraphed by the gaze shifting to the next spot.

### Fallen Angel

- **Move:** Flight with the same discipline as a seraph, but it descends to fight hand to hand and does not climb away as readily.
- **Attack:** Heavy wing-assisted sword blows with a long raise, plus a dark bolt from range announced by a gathering shadow-glow.
- **Awareness:** Drawn by the living who resist or defy it; ignores fleeing targets once they are out of its ground, preferring a standing fight.
- **Counter:** Dodge the raised sword blow, punish the recovery, and break line of sight during the shadow-glow.
- **Deeper:** The fallen angel begins mixing its ranged bolt into its melee rhythm, firing during the recovery of a dodged sword blow.

### Ashen Seraph

- **Move:** A ragged, uneven flight — circling like a seraph, but with stuttering wingbeats and sudden drops that break its rhythm.
- **Attack:** A diving strike that leaves a trail of ash, plus scattered ember bolts, telegraphed by a shuddering wing-fold before the dive and a dull glow before each bolt.
- **Awareness:** Drawn by fire, light, and the living below; ignores targets that stay dark and still under cover.
- **Counter:** Read the shuddering wing-fold rather than the dive itself, sidestep the ash trail, and strike during the ragged climb-away.
- **Deeper:** The ashen seraph's dives begin scattering ember bolts on impact, so the landing spot stays dangerous after it climbs away.
- **Flags:** thin lore — director call

## Demons, Devils & the Damned

This family does not fight fair, and it does not fight the same way twice. Imps and cultists harass, succubi and devils bargain and beguile, and the greater names — ifrit, marid, shaitan — fight like forces of nature that happen to have a grudge. The throughline is cunning: every one of them wants the player to make the first mistake.

### Imp

- **Move:** Erratic hovering flight between perches, flitting to a new perch after each attack and never landing to fight hand to hand.
- **Attack:** Small lobbed fire bolts from odd angles, announced by a perch pause and a gathering ember-glow before the volley.
- **Awareness:** Drawn by noise and movement, and by the player standing in the open; ignores still targets until they move.
- **Counter:** Strike during the perch pause, keep moving so the lobbed bolts miss, and do not chase it from perch to perch.
- **Deeper:** The imp begins lobbing from two perches in quick succession, so its new perch is already a firing position.

### Possessed Cultist

- **Move:** A jerky, skirmishing advance — darts in, strikes, and breaks away, with movements that do not quite belong to the body making them.
- **Attack:** Wild melee swipes plus a chanted bolt at range, telegraphed by a head-tilt and a rising chant before the bolt fires.
- **Awareness:** Drawn by the living and by the presence of whatever possesses it; ignores other cultists and quiet targets until it notices movement.
- **Counter:** Interrupt the chant by closing in, dodge the dart-in swipe, and strike during the stumble after a missed swipe.
- **Deeper:** The cultist's chant begins mid-dart, so the ranged threat arrives while it is still closing.

### Succubus

- **Move:** A graceful, circling approach that closes slowly, holding eye contact and mid-range rather than rushing.
- **Attack:** A beguiling lure — a raised hand and a fixing gaze as the tell — followed by a draining embrace at close range if the player stays within it.
- **Awareness:** Drawn by desire, loneliness, and the living at rest; ignores alert, moving groups in favor of an isolated target.
- **Counter:** Break the gaze, keep moving, and never stand inside the lure's area during its tell; strike during the recovery after a missed embrace.
- **Deeper:** The succubus begins layering its lure with a second, shorter lure from a new position, so breaking one gaze does not end the threat.
- **Flags:** needs systems step

### Incubus

- **Move:** A prowling skirmish — stalks at mid-range, darts in for a grapple, and breaks away if the grapple fails.
- **Attack:** A grappling embrace that drains as it holds, telegraphed by a crouch and arms spreading before the lunge.
- **Awareness:** Drawn by the living at rest and by isolated targets; ignores alert groups until one member separates.
- **Counter:** Dodge the spreading-arms lunge, break the hold quickly if caught, and strike during the recovery after a missed lunge.
- **Deeper:** The incubus chains a second lunge at the player's dodge direction after a missed first lunge.
- **Flags:** needs systems step

### Pit Brute

- **Move:** A slow, deliberate advance that never flanks and never retreats, built to be in the way.
- **Attack:** Heavy overhead slams with a long weapon raise, followed by a wide ground-shaking stomp announced by a foot lifting before it lands.
- **Awareness:** Drawn by the nearest threat and by noise in its pit; ignores distant targets once engaged.
- **Counter:** Dodge the raised slam, step out of the stomp's area, and punish the long recovery after each heavy blow.
- **Deeper:** The brute's stomp begins following its slam without a pause, so the punish window moves to after the stomp, not after the slam.
- **Flags:** thin lore — director call

### Djinn

- **Move:** A shimmering, smoke-form movement that blinks short distances and re-forms, never walking a straight line for long.
- **Attack:** Conjured fire bolts and a smoke-blink strike — it vanishes in smoke and re-forms beside the player to strike, with the smoke gathering as the tell.
- **Awareness:** Drawn by the living entering its place and by spoken names and wishes; ignores quiet passers-by who do not call attention to themselves.
- **Counter:** Watch the smoke gather, move before it re-forms, and strike during the brief solidity after a blink-strike.
- **Deeper:** The djinn begins blinking twice before striking, so the first re-forming is a feint and the second is the real strike. No wish-granting is spec'd as combat here; any bargain belongs to a systems step, not this pattern.

### Larva of the Damned

- **Move:** A crawling, writhing mass movement — slow as a whole, with constant squirming at its edges that makes its exact outline hard to read.
- **Attack:** Gnawing bites from many mouths at once at close range, telegraphed by the mass rearing and surging forward before it bites.
- **Awareness:** Drawn by the living and by suffering nearby; ignores still, quiet targets until they move.
- **Counter:** Keep moving, do not let the mass surround you, and strike during the pause after a surge.
- **Deeper:** The larva mass begins splitting its surge into two waves — a first surge that falls short, then a second that reaches further.
- **Flags:** thin lore — director call

### Ifrit

- **Move:** A towering, striding advance wreathed in heat, closing steadily and never retreating from fire.
- **Attack:** Sweeping fire blasts and a ground-slam that sends flame outward, each announced by the ifrit inhaling and its core brightening before it fires.
- **Awareness:** Drawn by the living and by open flame; ignores targets that stay behind cover or in water-logged ground.
- **Counter:** Move out of the blast's path during the inhale, use cover against the flame spread, and strike during the recovery after a slam.
- **Deeper:** The ifrit's flame begins lingering on the ground after a blast, so the blast area stays dangerous after the attack ends.

### Marid

- **Move:** A flowing, gliding advance that moves like water finding a slope — smooth, patient, and hard to predict at close range.
- **Attack:** Conjured water bolts and a surging tide-push that drives the player back, telegraphed by the marid gathering water around itself before each attack.
- **Awareness:** Drawn by the living near water and by thirst and heat; ignores targets that stay on high, dry ground until they descend.
- **Counter:** Move to high ground, sidestep the tide-push's line, and strike during the pause while it gathers water again.
- **Deeper:** The marid begins firing its water bolts in a sweeping fan, so a single sidestep no longer clears the volley.

### Contract Devil

- **Move:** An unhurried, precise advance that holds range and never rushes, like a negotiator who knows it has time.
- **Attack:** Binding bolts and a spoken bargain-offer at range — the offer is announced by a raised hand and a formal address before its effect lands, and refusing it by moving out of range or striking during the address is the counter.
- **Awareness:** Drawn by the desperate, the ambitious, and the living who linger to listen; ignores targets that walk past without stopping.
- **Counter:** Do not linger for the address; move out of range during it, or interrupt it by closing in.
- **Deeper:** The devil begins offering its bargain while still firing binding bolts, so the player must dodge and decide at the same time.
- **Flags:** needs systems step

### Shaitan

- **Move:** A heavy, storm-paced advance — part brute, part caster — that closes steadily and does not break stride for obstacles.
- **Attack:** Crushing weapon blows with a long raise, plus storm bolts from range announced by a gathering crackle before they fire.
- **Awareness:** Drawn by defiance and by the living who stand their ground; ignores fleeing targets in favor of the nearest standing threat.
- **Counter:** Dodge the raised blow, break line of sight during the crackle, and punish the recovery after a bolt volley.
- **Deeper:** The shaitan begins chaining a storm bolt into the recovery of a dodged weapon blow, so the punish window comes after the bolt, not after the blow.

## Public code ingredients

References and adaptation notes only — no code is pasted here, and no game code has been changed. Code application stays with the systems step. Each source below had its license verified on its own page during this research.

- **CodingQuests — Godot Enemy AI** — https://github.com/CodingQuests/godot-enemy-ai — License: MIT, verified on the repository page (repository details list MIT, and the README's License section states MIT for the code).
  - **What we would adapt:** The shared-state-machine shape (IDLE, CHASE, TELEGRAPH, ATTACK, RECOVERY, DEAD) and its telegraph-first discipline: every attack waits in TELEGRAPH, and RECOVERY leaves a punish window. That maps directly onto this part's brawlers and brutes (Skeleton Knight, Pit Brute, Shaitan), its weaver (Ghoul, as the Skitterling-style short-telegraph skirmisher), and its charger (Dullahan, as the line-telegraph charger).
  - **How the result stays Abysmal-original:** Adapt the pattern only — Abysmal's own creatures, lore-rooted tells (Banshee's rising wail wind-up, Jiangshi's hop arc, Ophanim's eye-brightening), first-person 2.5D presentation, and depth-complexity changes are written fresh for this game, and the source is credited. The demo itself is 2D with no line-of-sight or hearing and no pathfinding, so Abysmal's Awareness rules (breath-tracking Jiangshi, all-seeing Ophanim, sound-drawn Zombie) must be built, not copied.
- **LimboAI — Behavior Trees & State Machines for Godot 4** — https://github.com/limbonaut/limboai — License: MIT-style, verified on the repository page (repository details list MIT, and the README's License section points to its MIT license file).
  - **What we would adapt:** Only the framework idea, if the systems step ever wants it: behavior trees with a blackboard for the most layered creatures here (Wight Lord commanding lesser dead, Watcher fixing a gaze before calling light down, Lich layering bolts and blasts), plus hierarchical states for creatures that switch modes (Vampire's stalk-then-feed, Sluagh's wheel-then-dive).
  - **How the result stays Abysmal-original:** LimboAI would be a tool, not a creature: every tree, task, and tell in this part is Abysmal's own design, and no LimboAI demo behavior is reused as a monster. Its C++ GDExtension weight and Godot-version requirements also make it an optional, systems-step decision — not a default — and the source is credited if used.

## Sources consulted

- https://en.wikipedia.org/wiki/Penanggalan
- https://en.wikipedia.org/wiki/Vetala
- https://en.wikipedia.org/wiki/Sluagh
- https://en.wikipedia.org/wiki/Gashadokuro
- https://en.wikipedia.org/wiki/Kangshi
- https://en.wikipedia.org/wiki/Dullahan
- https://en.m.wikipedia.org/wiki/Ophanim
- https://www.livescience.com/59664-genies-jinn-facts.html
- https://github.com/CodingQuests/godot-enemy-ai
- https://github.com/limbonaut/limboai


---

[Part file: behavior-specs/part-5.md](behavior-specs/part-5.md)

## Part 5 — Greek & Mediterranean Myth, Norse & Germanic, Celtic & British Isles, Slavic

Specs only. No game code, stats, or spawn rules are set here. Telegraphs must read at a glance on a phone screen: a wind-up, a line, a glow, a sound cue, or a posture change, never a silent instant hit. Hidden or lure creatures always give a faint hint before they strike.

## Greek & Mediterranean Myth

A family of open-ground fighters, flyers, and controllers: charges and brute swings beside songs, gazes, and riddles that pull the player out of position. The danger is rarely just the blow — it is being lured, rooted, or caught facing the wrong way when the blow lands.

### Satyr
- **Move:** Bounds and dances around the player in loose arcs, never standing still to trade blows, closing only in short rushes.
- **Attack:** A leaping butt or club swing, telegraphed by a crouch and a stamp; in a group, satyrs harry from different sides rather than attacking together.
- **Awareness:** Drawn by movement and noise; ignores a still, distant player and drifts back to roaming.
- **Counter:** Strike during the landing pause after a leap, or step aside from the rush line and punish the recovery.
- **Deeper:** More satyrs join the harrying circle, so the player is turned constantly instead of facing one foe.

### Harpy
- **Move:** Circles overhead, shrieking, then commits to a dive and climbs away; never lands to fight on the ground.
- **Attack:** A dive-rake with talons, telegraphed by the dive line and a rising shriek just before the drop.
- **Awareness:** Drawn by an exposed player in open ground; ignores a player under cover, circling until a line opens.
- **Counter:** Sidestep the dive line and strike as it pulls up, when its path is fixed and its back is turned.
- **Deeper:** Dives come in quicker succession, with a second harpy diving on the dodge line of the first.

### Centaur
- **Move:** Gallops to a preferred range, wheels, and repositions; closes only when its ranged line is denied.
- **Attack:** Loosed arrows or thrown javelins from range, telegraphed by a draw and a pause to aim; a close-range charge with a lowered weapon if the player rushes in.
- **Awareness:** Drawn by a visible target at range; ignores a player who breaks line of sight, repositioning to regain a shooting lane.
- **Counter:** Close under cover, then strike during the wheel-and-turn after a charge, when it cannot shoot or turn quickly.
- **Deeper:** It kites more aggressively, shooting while retreating and charging only from a flank.

### Siren
- **Move:** Holds a perch or a shoreline spot and does not chase; drifts to a new vantage if the player closes.
- **Attack:** A lure song that pulls the player toward her, followed by close talon strikes once the player is drawn in; the song is telegraphed by a rising, visible melody cue before it takes hold.
- **Awareness:** Drawn by any player in earshot; ignores a player who never comes within song range.
- **Counter:** Break line of hearing by moving away or behind cover before the song builds, then rush during the pause between songs.
- **Deeper:** The song builds faster and the lure path leads through other dangers, so the player must choose the route, not just resist the pull.
- **Flags:** needs systems step

### Hellhound
- **Move:** Runs in a pack, circling and harrying, then bursting in coordinated rushes; apex Cerberus is separate — this is the pack hound, not the gate guardian.
- **Attack:** A lunging bite, telegraphed by a lowered head and a growl, sometimes backed by a short burst of flame breath signalled by a glowing maw.
- **Awareness:** Drawn by a fleeing or isolated player; the pack converges on the first hound that finds a target and ignores distant loot or doors.
- **Counter:** Hold ground against one hound rather than running, strike the lead hound to break the pack's nerve, and sidestep the lunge line.
- **Deeper:** Pack bursts grow tighter, with hounds attacking from opposite sides in the same window.

### Minotaur
- **Move:** Paws and bellows, then gore-charges down a corridor in a straight line; in open ground it slows to heavy horn swipes.
- **Attack:** The charge itself, telegraphed by pawing, snorting, and a lowered head; after a charge, wide horn swipes, telegraphed by a raised-head wind-up.
- **Awareness:** Drawn by a target directly ahead in a corridor; ignores side targets until the charge ends.
- **Counter:** Step out of the charge line and strike during the slow turn after a miss, or punish the swipe recovery in the open.
- **Deeper:** Charges chain more quickly and the minotaur feints a paw before committing, so the first tell is not always the real charge.

### Stymphalian Bird
- **Move:** Flies in a loose flock, wheeling overhead and never settling in melee reach.
- **Attack:** A volley of bronze feathers loosed in a fan, telegraphed by a wing flare and a metallic glint before release; close birds also dive-rake.
- **Awareness:** Drawn by an exposed player below the flock; ignores a player under solid cover, wheeling until a gap appears.
- **Counter:** Move under cover during the wing-flare tell, then strike a bird that dips low to rake.
- **Deeper:** Feather volleys come in staggered waves, so dodging one wave puts the player in the path of the next unless the pattern is read.

### Bronze Bull
- **Move:** Plods forward relentlessly, turning slowly, and charges in a straight line once it has a clear run.
- **Attack:** A gore charge, telegraphed by pawing and a snort of steam, and a breath of fire at close range, telegraphed by a glowing mouth and a deep inhale.
- **Awareness:** Drawn by heat and movement ahead; ignores side targets and quiet, still players.
- **Counter:** Sidestep the charge and strike the flank during its slow turn; step out of the breath cone during the inhale.
- **Deeper:** The bull chains a charge into a breath, covering the recovery ground where a player would normally punish it.

### Gorgon
- **Move:** Advances slowly and steadily, head raised, never rushing; turns to keep the player in front of her gaze.
- **Attack:** A petrifying gaze, telegraphed by glowing eyes and a held stare, that slows and then holds a player who keeps facing her; serpent hair strikes independently at close range, telegraphed by hissing and coiling.
- **Awareness:** Drawn by a player who faces her; ignores a player who turns away or breaks line of sight, repositioning to regain the stare.
- **Counter:** Turn or strafe during the eye-glow wind-up, attack during the long gaze cooldown, and clear the hair snakes for safe windows.
- **Deeper:** The gaze wind-up shortens and the hair strikes while the gaze is charging, punishing a player who only watches the eyes.
- **Flags:** needs systems step

### Chimera
- **Move:** Prowls forward with a heavy, uneven gait, rearing before it commits to a close attack.
- **Attack:** A rotating set of close attacks — lion bite, goat butt, and serpent snap — each telegraphed by the head that is about to strike rearing or hissing, plus a short fire breath signalled by an inhale.
- **Awareness:** Drawn by any close target; each head tracks its own side, so it notices flanking moves late but not never.
- **Counter:** Learn which head is winding up and punish the other side, striking during the recovery after a full rotation of heads.
- **Deeper:** Heads attack in quicker sequence with less pause between them, and the breath follows a bite instead of standing alone.

### Sphinx
- **Move:** Holds a guarded spot, pacing a short beat and returning to it; does not chase far from her post.
- **Attack:** A riddle challenge that roots or staggers a player who answers wrong or hesitates, telegraphed by a spoken cue and a raised posture; if the riddle is refused or failed, she follows with heavy paw swipes.
- **Awareness:** Drawn by a player entering her guarded ground; ignores players who pass at a distance without engaging.
- **Counter:** Answer or move before the spoken cue resolves, then strike during the pause after a riddle round; do not trade swipes head-on.
- **Deeper:** Riddle rounds come faster and a wrong answer leaves a longer opening for her swipes, raising the cost of guessing.
- **Flags:** needs systems step

### Griffin
- **Move:** Soars overhead, then swoops low in a long arc, climbing to reposition after each pass.
- **Attack:** A swooping talon rake, telegraphed by a folded-wing dive line, and a close beak snap if the player closes while it is grounded.
- **Awareness:** Drawn by an exposed player in open ground; ignores a player under cover, circling until a swoop line opens.
- **Counter:** Sidestep the dive line and strike as it pulls up, when its path is fixed.
- **Deeper:** Swoops chain into a second, tighter pass, and the griffin feints a climb before dropping again.

### Manticore
- **Move:** Paces at range on the ground or in short flights, keeping a shooting distance rather than closing.
- **Attack:** A volley of tail spines, telegraphed by a raised, bristling tail and a shudder before release; a lunging bite if the player closes.
- **Awareness:** Drawn by a visible target at range; ignores a player who breaks line of sight, repositioning for a new volley lane.
- **Counter:** Close under cover during the tail-raise tell, then strike during the tail's reload pause.
- **Deeper:** Spine volleys split into staggered fans, so one dodge line is covered by a second fan.

### Lamia
- **Move:** Slithers and coils, holding ground in a loose coil and lunging from it, then recoiling to wait again.
- **Attack:** A lunging bite, telegraphed by a raised coil and a hiss, followed by a draining grasp that saps the player while held; the grasp is telegraphed by reaching arms.
- **Awareness:** Drawn by a close, lone player; ignores distant targets and does not pursue far from her coil.
- **Counter:** Strike during the recoil after a missed lunge, and break the grasp quickly rather than trading while held.
- **Deeper:** She chains a lunge into a grasp without recoiling, so the safe window after a miss shrinks.

### Empusa
- **Move:** Shifts shape as she approaches — beast, then woman, then beast again — moving in short, deceptive rushes and never holding one form for long.
- **Attack:** A seductive lure that draws the player close, followed by a sudden bite and claw rake, telegraphed by a shimmer and a form-change snap just before the strike.
- **Awareness:** Drawn by a lone, unwary player; ignores a player who keeps distance or attacks during a form change.
- **Counter:** Strike during the shimmer of a form change, when she is committed and unguarded, and never follow the lure into a corner.
- **Deeper:** Form changes come faster and the lure mimics a friendly shape for longer before snapping to the attack form.
- **Flags:** needs systems step

### Nemean Lion
- **Move:** Stalks forward in a low, deliberate prowl, circling to keep the player in front of it.
- **Attack:** A heavy paw swipe and a lunging bite, telegraphed by a crouch, a tail lash, and a roar before the lunge.
- **Awareness:** Drawn by movement and by a player who turns away; ignores a still, facing player at a distance, circling instead.
- **Counter:** Face it and sidestep the lunge, striking the flank during the landing recovery.
- **Deeper:** The lion chains a swipe into a lunge, and its circling tightens so the player is turned before the lunge lands.

### Hydra
- **Move:** Coils in a marshy hold, heads weaving above the body, advancing only in short lunges from the coil.
- **Attack:** Multiple heads strike in sequence — bite, snap, bite — each telegraphed by the striking head rearing back; severed heads regrow unless the regrowth is stopped, and the body breathes a short spray at close range.
- **Awareness:** Drawn by any close target; heads track different sides, so flanking one head does not blind the others. Apex Orochi is separate — this is the marsh hydra, not that apex.
- **Counter:** Focus one head at a time, strike during the pause after a full sequence, and stop regrowth before the next sequence begins.
- **Deeper:** More heads join each sequence and regrowth quickens, forcing the player to interrupt the cycle rather than outlast it.
- **Flags:** needs systems step

## Norse & Germanic

Cold, watchful, and patient: water spirits that lure, forest wardens that mislead, night visitors that strike while the player rests, and great beasts that charge or coil. Many of these foes win by patience — the player who rushes the water, the woods, or the dark is already in their pattern.

### Sea Serpent
- **Move:** Coils and uncoils in water and across wet ground, surging forward in long, serpentine rushes and recoiling to wait again.
- **Attack:** A lunging bite, telegraphed by a raised head and a hiss, and a sweeping tail lash at close range, telegraphed by a coil tightening.
- **Awareness:** Drawn by movement in or near water; ignores a still player on dry ground at a distance.
- **Counter:** Strike during the recoil after a missed lunge, and keep to the head's blind side while it re-coils.
- **Deeper:** Lunges chain into a tail sweep, covering the ground where a player would punish the miss.
- **Flags:** thin lore — director call

### Nixie
- **Move:** Glides through water and along banks, holding a watery post and drifting to a new one if closed on; does not chase far onto dry ground.
- **Attack:** A lure song or shimmering display that draws the player toward the water, followed by a dragging grasp once the player is at the edge; the song is telegraphed by a rising melody cue.
- **Awareness:** Drawn by a player near water; ignores a player who stays well back from the bank.
- **Counter:** Break the song by moving away from the water before it builds, then strike during the pause between songs.
- **Deeper:** The lure path leads into deeper water, and the grasp follows the song with less pause.
- **Flags:** needs systems step

### Hulder
- **Move:** Moves through forest ground with a smooth, gliding step, appearing from cover and fading back into it rather than charging openly.
- **Attack:** A charming call that slows and draws the player toward her, telegraphed by a soft song cue and a beckoning posture, followed by close, strong strikes if the player is drawn in.
- **Awareness:** Drawn by a lone traveller in wooded ground; ignores a player who keeps moving and does not stop to listen.
- **Counter:** Keep moving through the call, strike during the pause after a charm attempt, and do not follow her into cover.
- **Deeper:** The charm builds faster and she appears from a second patch of cover, so the player must track two possible positions.
- **Flags:** needs systems step

### Mare
- **Move:** Drifts silently, with no footsteps, through positioning other foes respect; appears close, strikes, and drifts away.
- **Attack:** A sleep pressure that weighs the player down, telegraphed by a dimming, heavy haze around her, followed by close, smothering strikes while the player is slowed.
- **Awareness:** Drawn by a resting or slowed player; ignores a fast, alert player at a distance, drifting to a new vantage instead.
- **Counter:** Keep moving and strike during the drift-in, before the haze builds; do not stand still in her presence.
- **Deeper:** The haze builds faster and she returns sooner after drifting away, giving less time to recover.
- **Flags:** needs systems step

### Dark Elf (Dökkálfar)
- **Move:** Moves low and fast through shadowed ground, darting between cover and never standing in open light to fight.
- **Attack:** A quick dagger stab from cover, telegraphed by a brief glint and a crouch before the dart, then an immediate retreat to new cover.
- **Awareness:** Drawn by a player who enters shadowed ground; ignores a player in bright, open ground, waiting for cover to return.
- **Counter:** Strike during the landing pause of a dart, or force it into the open where it loses its cover rhythm.
- **Deeper:** Darts come from alternating cover points, so the player must track the last cover, not the elf itself.
- **Flags:** thin lore — director call

### Alfar Raider
- **Move:** Advances in a loose skirmish line, darting between cover and holding a preferred range rather than closing to melee.
- **Attack:** Loosed arrows and thrown spears, telegraphed by a draw and aim pause, with a quick sword cut if the player closes.
- **Awareness:** Drawn by a visible target at range; ignores a player who breaks line of sight, repositioning to regain a shooting lane.
- **Counter:** Close under cover during the draw pause, then strike during the reload after a volley.
- **Deeper:** Raiders coordinate volleys, with one drawing the player's dodge while another looses on the dodge line.
- **Flags:** thin lore — director call

### Fallen Valkyrie
- **Move:** Flies in short, controlled arcs, landing to fight and taking wing again to reposition; never stays grounded for long.
- **Attack:** A diving spear thrust, telegraphed by a raised spear and a dive line, followed by sweeping sword cuts on the ground, telegraphed by a wide wind-up.
- **Awareness:** Drawn by a worthy, fighting player; ignores a fleeing player, returning to a perch rather than pursuing.
- **Counter:** Sidestep the dive line and strike during the landing pause, before she takes wing again.
- **Deeper:** Dive and sword sequences chain without a wing pause, and she feints a landing before diving a second time.

### Great Wolf
- **Move:** Circles and harries at mid-range, darting in for nips and breaking off; apex Fenrir is separate — this is the great wolf, not that apex.
- **Attack:** A harrying nip, telegraphed by a lowered head and a circling tighten, and a lunging pounce, telegraphed by a deep crouch.
- **Awareness:** Drawn by a player who turns or flees; ignores a still, facing player, circling instead until an opening appears.
- **Counter:** Face the wolf, sidestep the pounce, and strike during the long recovery after a missed pounce.
- **Deeper:** The circle tightens faster and pounces follow nips without a pause, so the player must read the crouch, not the nip.

### Lindworm
- **Move:** Slithers low with a serpent's coil, rearing on its forelegs to strike and dropping back to coil again.
- **Attack:** A lunging bite, telegraphed by a raised head and a hiss, and a tail sweep at close range, telegraphed by a coil tightening.
- **Awareness:** Drawn by movement ahead on the ground; ignores still, distant players, coiling in wait instead.
- **Counter:** Strike during the drop back to coil after a missed lunge, from the flank the head is not tracking.
- **Deeper:** The lindworm chains a bite into a tail sweep, and its coil shifts position between lunges so the safe flank moves.

### Kraken
- **Move:** Holds a watery arena and reaches across it with long limbs; the body itself rarely moves, but the limbs reposition constantly.
- **Attack:** Tentacle grabs and slams, telegraphed by a limb rising and coiling before it falls, and a dragging pull toward the water once a limb holds.
- **Awareness:** Drawn by any player in or near the water; ignores a player who stays well back from the edge.
- **Counter:** Strike a raised limb before it falls, break a hold quickly, and keep to dry ground where limbs cannot drag.
- **Deeper:** More limbs attack in sequence, with one limb covering the dodge line of another.
- **Flags:** needs systems step

## Celtic & British Isles

Water, shore, and household edges: horses that are not horses, seals that are not seals, cats that watch from the dark, and a washer at the ford who is an omen before she is a foe. The pattern here is misdirection — what the creature seems to be is the trap.

### Kelpie
- **Move:** Appears as a calm horse near water, then surges in a straight charge once the player is close; in water it coils and drags.
- **Attack:** An adhesive lure — the player who touches or mounts the horse form is held — followed by a drag toward the water, telegraphed by a sudden rearing and a wet, gleaming coat.
- **Awareness:** Drawn by a player approaching the water's edge; ignores a player who keeps distance and does not touch the horse form.
- **Counter:** Do not touch the horse form; strike during the rearing tell before the drag begins, and keep to dry ground.
- **Deeper:** The horse form holds its calm longer, so the lure is harder to spot, and the charge follows a failed drag without pause.
- **Flags:** needs systems step

### Merrow
- **Move:** Glides through water and along shores, holding a watery post and retreating to deeper water if closed on.
- **Attack:** A lure call and a dragging grasp at the water's edge, telegraphed by a rising song cue, followed by close claw strikes if the player is drawn in.
- **Awareness:** Drawn by a player near water; ignores a player who stays well back from the shore.
- **Counter:** Move away from the shore before the call builds, then strike during the pause between calls.
- **Deeper:** The call builds faster and the grasp follows the call with less pause, so the player must break the pattern early.

### Selkie
- **Move:** Moves between seal and human form, swimming swiftly in water and walking slowly on land; sheds or takes up her skin with a visible pause.
- **Attack:** A swift water rush and bite, telegraphed by a surfacing ripple and a turn toward the player, and a close claw strike on land if cornered.
- **Awareness:** Drawn by a player who threatens her skin or her shore post; ignores a player who passes at a distance.
- **Counter:** Strike during the skin-change pause, when she is committed and unguarded, and keep her on land where her rush cannot build.
- **Deeper:** Form changes come faster, and she uses the water rush to reposition rather than only to attack.
- **Flags:** needs systems step

### Cat Sìth
- **Move:** Stalks low through shadow, wall-clinging and dropping from above, then darting to new cover; never holds ground.
- **Attack:** A dropping pounce with claws, telegraphed by a faint silhouette above the path and a tail lash before the drop, followed by a quick rake and retreat.
- **Awareness:** Drawn by a player passing beneath a perch; ignores a player who looks up and holds still, repositioning to a new perch instead.
- **Counter:** Watch for the faint silhouette, sidestep the drop line, and strike during the landing pause.
- **Deeper:** Pounces chain from one perch to another without a ground pause, so the player must track the next perch, not the cat.

### Bauchan
- **Move:** Darts between cover in short, hobgoblin rushes, jabbing and fleeing toward a household post rather than standing to fight.
- **Attack:** A spear or club jab, telegraphed by a crouch and a raised arm, then an immediate retreat; sometimes a thrown object from cover, telegraphed by a wind-up behind cover.
- **Awareness:** Drawn by a player who enters its household ground; ignores a player who leaves that ground, returning to its post.
- **Counter:** Strike during the jab's recovery before it retreats, or cut off its retreat line to its post.
- **Deeper:** Jabs come from alternating cover points and the retreat line shifts, so the player must guard two exits.
- **Flags:** thin lore — director call

### Fachan
- **Move:** Hops and lurches forward on a single leg, slow to turn and unable to strafe, but steady once it has a line.
- **Attack:** A heavy single-hand slam, telegraphed by a raised arm and a long wind-up, and a hopping body slam if the player stays in its path.
- **Awareness:** Drawn by a target directly ahead; ignores side targets until it has turned, which takes time.
- **Counter:** Sidestep the slam line and strike the flank during its slow turn, never trading head-on.
- **Deeper:** The slam chains into a second hop-slam, covering the ground where a player would punish the first miss.
- **Flags:** thin lore — director call

### Afanc
- **Move:** Lurks in water, surfacing in a surge and submerging again; on wet ground it drags itself forward in short rushes.
- **Attack:** A surging bite, telegraphed by a ripple and a rising back before the surge, and a tail thrash at close range.
- **Awareness:** Drawn by movement in or near water; ignores a still player on dry ground at a distance.
- **Counter:** Strike during the submerge pause after a missed surge, and keep to dry ground where its rush cannot build.
- **Deeper:** Surges come in pairs, with the second surge aimed at the dodge line of the first.
- **Flags:** thin lore — director call

### Bean-nighe
- **Move:** Holds a ford or stream post, washing and keening, and does not chase; drifts to a new water post if closed on.
- **Attack:** An omen wail that weighs the player down with dread, telegraphed by a rising keen and a visible shroud cue, followed by close, weak strikes only if the player stays in the wail.
- **Awareness:** Drawn by a player approaching the ford; ignores a player who passes at a distance without engaging.
- **Counter:** Move away from the ford before the keen builds, then strike during the pause between wails.
- **Deeper:** The keen builds faster and the dread lingers after the player leaves the ford, so the player must break the pattern early.
- **Flags:** needs systems step

## Slavic

Household spirits, forest wardens, and water lords: small foes that torment and mislead, great birds that sing the player into forgetting, and serpents that breathe fire. Many of these foes do not want a fair fight — they want the player lost, lured, or asleep.

### Domovoi
- **Move:** Darts between cover in a household space, slipping behind hearths and thresholds and never standing in the open.
- **Attack:** A quick, unseen shove or trip from cover, telegraphed by a faint scuffle and a moving shadow, followed by a small club strike if the player is knocked off balance.
- **Awareness:** Drawn by a player who disturbs its household ground; ignores a player who passes quietly and leaves things undisturbed.
- **Counter:** Strike during the scuffle tell before the shove lands, or force it into the open where its cover rhythm breaks.
- **Deeper:** Shoves come from alternating cover points and chain into a strike, so the player must guard two directions at once.

### Kikimora
- **Move:** Slips through household shadows, spinning and tangling, appearing at a loom or threshold and vanishing to another.
- **Attack:** A tangling snare that slows and trips the player, telegraphed by a whirring spin cue and a thread glint, followed by close, scratching strikes while the player is tangled.
- **Awareness:** Drawn by a player who lingers in a household space; ignores a player who moves through quickly.
- **Counter:** Break the snare before the spin cue resolves, and strike during the pause after a snare attempt.
- **Deeper:** Snares chain across the room, so breaking one puts the player in the path of the next unless the pattern is read.

### Rusalka
- **Move:** Glides through water and along banks, holding a watery post and drifting to a new one if closed on; does not chase far onto dry ground.
- **Attack:** A lure song that draws the player toward the water, telegraphed by a rising melody cue, followed by a dragging grasp at the edge.
- **Awareness:** Drawn by a player near water, especially a lone one; ignores a player who stays well back from the bank.
- **Counter:** Move away from the water before the song builds, then strike during the pause between songs.
- **Deeper:** The song builds faster and the lure path leads through deeper water, raising the cost of following it.
- **Flags:** needs systems step

### Vodyanoy
- **Move:** Plods through water and wet ground, slow and heavy, never retreating from its watery hold.
- **Attack:** A heavy club-like slam, telegraphed by a raised arm and a long wind-up, and a dragging grasp at the water's edge, telegraphed by reaching arms.
- **Awareness:** Drawn by a player entering its water; ignores a player who stays on dry ground at a distance.
- **Counter:** Strike the flank during the slam recovery, and keep to dry ground where the grasp cannot reach.
- **Deeper:** Slams chain into a grasp, covering the ground where a player would punish the slam.

### Striga
- **Move:** Flits in owl form through the dark, perching and dropping, then shifting to a gaunt humanoid form on the ground.
- **Attack:** A dropping talon strike, telegraphed by a wing flare and a screech, and a draining bite in humanoid form, telegraphed by a lunge with outstretched arms.
- **Awareness:** Drawn by a lone, resting, or slowed player; ignores an alert, moving player, perching and waiting instead.
- **Counter:** Strike during the landing pause after a drop, and break the draining bite quickly rather than trading while held.
- **Deeper:** Form shifts come faster, and the owl drop chains into a draining bite without a ground pause.
- **Flags:** needs systems step

### Leshy
- **Move:** Shifts through forest ground, changing height and shape as it moves, appearing from one tree line and vanishing into another.
- **Attack:** A path-scrambling call that turns the player's route, telegraphed by a whispering wind cue and shifting shadows, followed by heavy branch swipes, telegraphed by a raised limb.
- **Awareness:** Drawn by a player who enters its forest ground; ignores a player who leaves the woods, returning to its post.
- **Counter:** Hold a fixed landmark during the whisper cue, strike during the pause after a scramble, and do not follow it deeper into cover.
- **Deeper:** Scrambles come more often and the swipes follow a scramble without pause, so the player must anchor before the call resolves.
- **Flags:** needs systems step

### Alkonost
- **Move:** Flies in slow, circling arcs, perching high and singing; never lands to fight on the ground.
- **Attack:** A joyous, forgetful song that slows and stills the player, telegraphed by a rising melody cue and a bright glow, followed by a diving wing buffet if the player stays entranced.
- **Awareness:** Drawn by a player who stops to listen; ignores a player who keeps moving and does not pause under her perch.
- **Counter:** Keep moving during the melody cue, strike during the pause between songs, and do not stand beneath the perch.
- **Deeper:** The song builds faster and the glow lingers after the song ends, so the player must break the pattern early.
- **Flags:** needs systems step

### Gamayun
- **Move:** Flies in high, circling arcs, perching far above the fight and repositioning between verses.
- **Attack:** A prophetic song that steadies her allies and unsettles the player, telegraphed by a spoken verse cue before the effect lands, followed by a diving feather volley if the player closes.
- **Awareness:** Drawn by a player who engages her allies; ignores a lone player who does not approach, singing from a distance instead.
- **Counter:** Strike during the pause between verses, and disrupt the verse cue before it resolves rather than trading with her allies under its effect.
- **Deeper:** Verses come faster and the feather volley follows a verse without pause, punishing a player who only watches the song.
- **Flags:** needs systems step

### Mora
- **Move:** Drifts silently, with no footsteps, appearing close to a resting or slowed player and fading away after a strike.
- **Attack:** A nightmare pressure that weighs the player down, telegraphed by a dimming haze, followed by close, smothering strikes while the player is slowed.
- **Awareness:** Drawn by a resting or slowed player; ignores a fast, alert player, fading to a new vantage instead.
- **Counter:** Keep moving and strike during the drift-in, before the haze builds; do not stand still in her presence.
- **Deeper:** The haze builds faster and she returns sooner after fading, giving less time to recover.
- **Flags:** thin lore — director call
- **Flags:** needs systems step

### Zmey
- **Move:** Coils and rears, heads weaving above the body, advancing in short lunges from the coil and recoiling to wait again.
- **Attack:** Multiple heads strike in sequence — bite, snap, bite — each telegraphed by the striking head rearing back, plus a short fire breath, telegraphed by a glowing maw and an inhale.
- **Awareness:** Drawn by any close target; heads track different sides, so flanking one head does not blind the others.
- **Counter:** Focus one head at a time, strike during the pause after a full sequence, and step out of the breath cone during the inhale.
- **Deeper:** More heads join each sequence and the breath follows a bite instead of standing alone.

### Firebird
- **Move:** Flies in swift, darting arcs, never settling in melee reach, and repositions with a burst of light.
- **Attack:** A blinding feather flash, telegraphed by a brightening glow before it fires, followed by a diving feather volley and a short burst of flame, telegraphed by a wing flare.
- **Awareness:** Drawn by a player who chases its light; ignores a player who looks away and holds cover, circling until a line opens.
- **Counter:** Look away or take cover during the brightening tell, then strike during the pause after a dive.
- **Deeper:** Flashes chain into dives without pause, so the player must read the glow, not the dive, to time the dodge.
- **Flags:** needs systems step

## Sources consulted

- https://en.wikipedia.org/wiki/Hulder
- https://en.wikipedia.org/wiki/Empusa
- https://www.ancient-origins.net/myths-legends/alkonost-and-gamayun-mythical-beings-slavic-folklore-004076
- https://discover.hubpages.com/education/Creatures-and-Characters-in-Scottish-Mythology
- https://www.expresstorussia.com/experience-russia/supernatural-creatures-in-early-russian-mythology-and-folklore.html
- https://www.mentalfloss.com/history/strangest-creatures-greek-mythology
- https://kingdompen.org/six-underutilized-creatures-from-british-mythology/

Lore in this file is paraphrased in the author's own words, not copied from any source.

## Public code ingredients

No code is pasted here — references and adaptation notes only. Each license below was verified on its source page during this task. Code application stays with the systems step; these are ingredients for that step to adapt, credit, and rebuild in Abysmal's own style, never wholesale clones. Abysmal's creatures, telegraphs, lore framing, and first-person idle presentation remain original even where a generic state-machine or steering pattern is reused.

- **CodingQuests — Enemy AI (Godot)** — https://store.godotengine.org/asset/codingquests/enemy-ai/ — License: MIT for the code, verified on the asset page ("MIT for the code").
  - What we would adapt: the shared state shape (idle, chase, telegraph, attack, recovery) and its readable telegraph idea — a shown shape before a hit lands — plus the charger pattern of locking a direction, showing a line, then dashing.
  - Fits: Centaur and Minotaur and Bronze Bull charges, Harpy and Griffin dive lines, and the generic telegraph-then-strike rhythm used across this file.
  - Abysmal-original: keep only the state shape and the telegraph concept; rewrite the states, timings, tells, and creature behaviours from the specs above, with Abysmal's own models, pacing, and idle AI, and credit the source in the credits file.
- **CodingQuests — State Machine (Godot)** — https://store.godotengine.org/asset/codingquests/state-machine/ — License: MIT for the code, verified on the asset page ("MIT for the code").
  - What we would adapt: the node-per-state structure with transitions by signal and enter, exit, update, and physics-update hooks, so each creature's pattern (roam, chase, telegraph, attack, recover, drift, perch) is a small, separate state.
  - Fits: lure and perch creatures that need clean state changes (Siren, Nixie, Hulder, Alkonost, Gamayun, Firebird) and ambushers that need a hidden-wait state (Cat Sìth, Lamia, Sea Serpent).
  - Abysmal-original: use the structure only; every state in Abysmal is written from these specs, with Abysmal's own names, transitions, and tells, and the source is credited.
- **godot-behavior-tree-plugin (Godot Asset Library)** — http://godotassetlibrary.com/asset/W8b2oo/godot-behavior-tree-plugin — License: MIT, verified on the asset page ("released under the terms of the MIT License").
  - What we would adapt: the behaviour-tree idea of sequences, selectors, and a blackboard memory, for creatures whose choices branch — for example, a lure creature that sings, then grabs only if the player is drawn in, or a pack creature that bursts only when allies are near.
  - Fits: multi-step creatures (Chimera head rotation, Hydra and Zmey head sequences, Hellhound pack bursts, Leshy scramble-then-swipe) where a flat state list would tangle.
  - Abysmal-original: adopt the tree pattern, not any creature tree from the plugin; all sequences, conditions, and actions are authored from the specs above, and the source is credited.
- **OpenSteer (steering behaviours)** — https://opensteer.sourceforge.net/doc.html — License: MIT, verified on the documentation page ("distributed as open source software in accordance with the MIT License").
  - What we would adapt: the classic steering ideas of seek, flee, pursuit, evasion, obstacle avoidance, and flocking (separation, alignment, cohesion) as movement maths, re-implemented for Godot's first-person dungeon space.
  - Fits: pack and flock movement (Hellhound circling and pack bursts, Stymphalian Bird flock wheeling, Great Wolf circling and harrying, Satyr harrying arcs) and pursuit versus evasion for chargers and skirmishers.
  - Abysmal-original: reuse only the published steering concepts; the movement code, tuning, and creature behaviour are Abysmal's own, and the source is credited. Note this is a C++ library, not Godot code, so it is a concept ingredient to re-implement, not a drop-in.

Not listed: any source whose licence could not be verified on its own page was left out, including a Godot behaviour-tree entry whose page showed conflicting licence text.


---

[Part file: behavior-specs/part-6.md](behavior-specs/part-6.md)

## Part 6 — Egyptian & Near East, Mesopotamian, South Asian, Chinese & East Asian, Japanese Yōkai

SPECS ONLY — no game code, stats, or spawn rules are set here. Each entry gives movement, attack, awareness, a player counter, and an optional deeper-floor change. No stat numbers appear anywhere in this file.

## Egyptian & Near East

Tomb, temple, and desert guardians dominate this family: patient watchers, swarming vermin, and composite beasts whose threat is a sudden lunge or a punishing close-range bite rather than a long duel.

### Scarab Swarm
- **Move:** Scuttles across the floor in a shifting mass that flows around obstacles and reforms behind the player, never holding one shape for long.
- **Attack:** Many small nips from all sides at once; the danger is being surrounded, not any single bite. A rising rustle and a thickening carpet of shells telegraph a massing push.
- **Awareness:** Drawn to movement and to bodies on the ground; ignores still, distant targets and will drift toward the nearest moving prey.
- **Counter:** Keep moving and do not let the mass close a ring around you; strike while it is still spreading out, before it settles into a bite.
- **Deeper:** The mass splits around the player and closes from two sides at once instead of pushing from one direction.

### Asp
- **Move:** Low, quick sidewinding dashes with long pauses coiled in cover, repositioning between strikes rather than standing to trade blows.
- **Attack:** A fast rearing strike with a raised head and flared hood as the tell, followed by a venom bite; it slips back into cover right after the lunge.
- **Awareness:** Drawn to heat and motion at close range; ignores slow, distant targets and will not chase far from its chosen cover.
- **Counter:** Bait the rearing strike, step clear of the lunge line, and hit it while it is recovering from the missed bite.
- **Deeper:** Feints a rear before committing, so the first rise is not always the real strike.

### Jackal Guardian
- **Move:** Loping, circling harrier that orbits at mid-range, darting in for quick nips and peeling away before the player can turn on it.
- **Attack:** Snap-and-retreat bites aimed at the flanks; when more than one is present they time their darts so the player is pressed from alternating sides.
- **Awareness:** Drawn to lone, wounded, or distracted prey and to tomb thresholds it seems to guard; ignores targets that hold a strong facing and do not overextend.
- **Counter:** Face each dart squarely, punish the landing moment, and break the circle by moving through it rather than backing away.
- **Deeper:** Packs tighten their orbit and chain their darts with less pause between them.

### Guardian Scorpion
- **Move:** Slow, deliberate sidestepping advance that angles toward the player's side, claws raised, tail carried high and ready.
- **Attack:** Claw snaps to pin and distract, then a raised-tail sting as the real payload; the tail lift is the clear warning to move.
- **Awareness:** Drawn to vibration and close movement; ignores distant or airborne targets and holds its ground near whatever it guards.
- **Counter:** Dodge the sting itself even if a claw snap lands, and strike from the front while the tail is still lowering.
- **Deeper:** Adds a second, quicker sting after the first is dodged, punishing players who rush in too early.
- **Flags:** thin lore — director call

### Serpopard
- **Move:** Bounding feline advance with a long, questing serpent neck that reaches and snaps ahead of the body, letting it strike from slightly beyond its own bulk.
- **Attack:** A neck-lunge bite that arrives before the body does, telegraphed by the neck drawing back and coiling; followed by leaping claw swipes once it closes.
- **Awareness:** Drawn to open ground and to movement in the open; ignores prey that stays behind cover, where its long neck cannot reach cleanly.
- **Counter:** Use cover to break the neck's line, sidestep the lunge, and close only after the neck has overextended.
- **Deeper:** The neck starts striking around corners and over low cover, so a single wall no longer guarantees safety.
- **Flags:** thin lore — director call

### Sha Beast
- **Move:** Erratic, storm-like bounding: sudden sprints broken by sharp, unpredictable turns, as if blown sideways by a gust.
- **Attack:** Snapping bites and head-butts delivered mid-sprint, with a stiff-legged rear and a braying call as its warning before a rush.
- **Awareness:** Drawn to noise and to targets that run; ignores still prey and tends to lose interest if the player simply stops and holds ground.
- **Counter:** Stand your ground through the warning call, sidestep the rush, and strike during its awkward turn after a miss.
- **Deeper:** Rushes chain into a second, reversed rush without the full warning call between them.
- **Flags:** thin lore — director call

### Falcon Sphinx
- **Move:** Heavy, ground-bound lion's lope with short wing-assisted hops that carry it over low obstacles and into striking range.
- **Attack:** A wing-spread, head-high display before a leaping claw rake; the spread wings and fixed stare are the tell, and it lands into a forward swipe.
- **Awareness:** Drawn to intruders crossing a threshold or open approach; ignores targets that retreat beyond its guarding ground, which it will not abandon.
- **Counter:** Do not cross its line while the wings are spread; step aside from the leap and punish the landing.
- **Deeper:** Guards a wider ground and pairs its leap with a second swipe on landing instead of a single rake.
- **Flags:** thin lore — director call

### Devourer Beast
- **Move:** Crouching, hippo-heavy stalk that stays low near judgment ground, then surges forward in a short, unstoppable-looking rush when its prey falters.
- **Attack:** A triple-threat sequence — crocodile-jaw snap, lion-claw rake, and a hippo-bulk shoulder charge — with the jaw opening wide as the clearest tell before the snap.
- **Awareness:** Drawn to faltering, cornered, or retreating prey; ignores strong, steady opponents and waits for a mistake rather than opening the fight.
- **Counter:** Never let it catch you backing into a corner; keep a clean retreat line, dodge the jaw snap, and strike while it recovers from the charge.
- **Deeper:** Its rush triggers sooner, on smaller stumbles, so brief hesitations become openings for it.
- **Flags:** needs systems step

### Ushabti
- **Move:** Stiff, shuffling march in a loose rank, arms held in a worker's pose; it does not run, but it does not stop either, and ranks close gaps left by fallen members.
- **Attack:** Repeated blunt tool-strikes — hoe-like chops and thrusts — with a slow arm raise as the tell; several figures striking in loose rhythm are harder to dodge than one alone.
- **Awareness:** Drawn to movement inside the tomb chamber it serves; ignores anything outside that chamber and returns to stillness if the intruder leaves it.
- **Counter:** Fight one figure at a time at a doorway or corner, and use the slow arm raise as the dodge cue rather than trying to out-trade the rank.
- **Deeper:** Figures wake in larger ranks and keep their rhythm even as members fall, instead of breaking formation.

## Mesopotamian

Gate guardians, underworld enforcers, and storm-born hybrids fill this family: heavy, deliberate fighters, watchful threshold keepers, and one plague-bringer whose ground itself turns hostile.

### Cedar Guardian
- **Move:** Slow, rooted advance like a tree walking — heavy steps, long pauses, arms spread wide as if still holding the forest's edge. (The apex Humbaba is a separate entry and is not specced here.)
- **Attack:** Wide, sweeping arm blows and a bellowing roar that staggers the unwary; the arms drawing back and the chest swelling are the twin tells.
- **Awareness:** Drawn to intruders entering its grove ground; ignores anything that does not cross into that ground and will not pursue far beyond it.
- **Counter:** Step inside the sweep's arc after it passes, or slip behind it during the long roar, and never trade blows in front of it.
- **Deeper:** Roars chain into a second sweep with less pause, closing the safe window after the bellow.
- **Flags:** thin lore — director call

### Galla
- **Move:** Relentless, tireless pursuit that never sprints and never rests — a steady, dragging advance that follows the player through corridors without breaking off.
- **Attack:** Clutching grabs and dragging pulls, telegraphed by both arms reaching wide; if a grab lands, it tries to haul the player backward rather than strike.
- **Awareness:** Drawn to the living and to anyone fleeing; ignores the dead, the still, and anything behind a sealed threshold it cannot cross.
- **Counter:** Break line of sight at a corner and change direction sharply; it follows steadily but turns slowly, so a sharp reversal buys distance.
- **Deeper:** Pursues in pairs that split at junctions, cutting off the straight retreat line.

### Scorpion Man
- **Move:** Upright, watchful patrol of a threshold or mountain pass, bow in hand, tail curled and ready behind him.
- **Attack:** Ranged bow shots from a held position, stepping back to keep distance when closed on; if cornered, a tail sting replaces the bow, with the tail rearing as the tell.
- **Awareness:** Drawn to anyone approaching its guarded pass; ignores passersby who keep their distance and do not enter its ground.
- **Counter:** Rush during the bow's draw, or force it into a corner where the bow is useless — then watch the tail, not the bow.
- **Deeper:** Alternates bow volleys with a tail sting in the same exchange, so closing distance no longer ends the ranged threat.

### Ugallu
- **Move:** Bounding, storm-driven charges with a wolf-like lope between rushes, head low and jaws snapping at the air.
- **Attack:** A dagger-and-mace flurry at close range after the charge, telegraphed by the weapon arm drawing high and the head throwing back; storm gusts around it push the player off balance before the rush.
- **Awareness:** Drawn to open ground and to targets caught in the open; ignores prey behind solid cover, where its charge cannot run straight.
- **Counter:** Take cover to break the charge line, sidestep the rush, and strike while it recovers from the weapon flurry.
- **Deeper:** Charges arrive with a gust that precedes the body, so the wind itself becomes an early warning to move.

### Lamassu
- **Move:** Slow, stately advance that holds its ground like a living gate, wings half-spread, turning to face intruders with deliberate calm.
- **Attack:** Heavy paw swipes and a forward horned-head butt, with the head lowering and wings flaring as the tell; a short, sweeping wing buffet pushes back anyone crowding its flanks.
- **Awareness:** Drawn to intruders at a gate or threshold; ignores anything that does not threaten the ground it guards and will not chase beyond it.
- **Counter:** Do not fight it head-on at the gate; draw it slightly out of position, then strike from the side while its wings are still folding.
- **Deeper:** Adds a second, wider wing buffet after the head butt, punishing players who linger at its flank.

### Mušḫuššu
- **Move:** Serpentine slither with lion-like foreleg bounds — it coils, lunges, and re-coils, never staying in one spot after a strike.
- **Attack:** A coiling lunge with a snapping bite, telegraphed by the body drawing into a tight coil and the head pulling back; venom follows the bite, and a tail lash covers its retreat.
- **Awareness:** Drawn to movement within its coiled ground; ignores distant targets and returns to a coil if the player backs away.
- **Counter:** Bait the coil, step clear of the lunge line, and strike while it is re-coiling and its head is low.
- **Deeper:** Lunges chain into a sideways lash before it re-coils, so the safe moment after a miss shortens.

### Anzu
- **Move:** High circling flight on broad wings, with long, screaming dives that end in a climbing retreat; it never lands to fight on the ground. (The apex Anzu is a separate entry and is not specced here.)
- **Attack:** A talon dive-rake along a visible dive line, plus a gusting wing-beat on the climb that pushes the player sideways; the circling scream and the dive line are the twin tells.
- **Awareness:** Drawn to targets in the open and to movement below its circle; ignores prey under solid cover, where it cannot dive cleanly.
- **Counter:** Stay under cover during the circle, step off the dive line at the scream's peak, and strike during the low pull-out before it climbs away.
- **Deeper:** Dives arrive in quicker succession with a shorter circle between them, and the climb gust pushes harder.

### Asag
- **Move:** Shuddering, uneven advance over broken ground, limbs jerking as if the earth itself were moving through it; it does not run, but the ground around it seems to boil.
- **Attack:** Rocky, flailing limb strikes plus a spreading plague ground — cracked, foul earth that punishes standing still — telegraphed by the ground darkening and cracking under the player's feet before it takes hold.
- **Awareness:** Drawn to living targets and to water or damp ground, which it fouls as it passes; ignores the already-dead and the far distant.
- **Counter:** Keep moving off cracked ground the moment it darkens, never plant yourself to trade blows, and strike during its shuddering pauses.
- **Deeper:** The fouled ground spreads wider and lingers longer, forcing constant repositioning rather than brief steps aside.

## South Asian

This family mixes guardians, hungry ghosts, and sky hunters: serpent coils and heavy demonic brutes beside drifting, hard-to-hit spirits whose threat is misdirection as much as damage.

### Naga
- **Move:** Fluid, coiling advance that keeps its hooded upper body raised, sliding between coils so it is rarely fully exposed at once.
- **Attack:** A hood-flare display before a spitting strike and a coiling lunge; the flare is the tell, and the spit arrives on a short arc the player can step out of.
- **Awareness:** Drawn to intruders near water, treasure ground, or its coils; ignores distant targets and will not abandon its ground to chase.
- **Counter:** Step out of the spit's arc, strike while the hood is still flared and its head is high, and do not let it coil around your position.
- **Deeper:** Spits arrive in a fanned pair instead of a single arc, covering both sidestep directions.

### Yaksha
- **Move:** Heavy, swaggering advance with a guardian's patience — it walks to its ground and holds it, turning slowly but striking hard.
- **Attack:** Overhead club and fist blows with a long arm raise as the tell, plus a sudden ground-stomp that shakes the footing of anyone standing too close.
- **Awareness:** Drawn to intruders near groves, springs, or treasure ground; ignores passersby who do not approach what it guards.
- **Counter:** Dodge on the arm raise, punish the long recovery after a missed overhead blow, and never stand inside the stomp's ring.
- **Deeper:** Stomps arrive after an overhead miss as a follow-up, closing the punish window for careless rushes.

### Bhūta
- **Move:** Drifting, footstep-free glide that passes through positioning other monsters respect, fading faintly between strikes rather than walking away.
- **Attack:** A sudden materializing strike from the drift, telegraphed by a brief shimmer where it will appear; it fades again immediately after hitting.
- **Awareness:** Drawn to the living and to places of death or grief; ignores the still and the hidden, and drifts toward sound and movement.
- **Counter:** Watch for the shimmer, not footsteps; strike the moment it solidifies, before it can fade, and keep moving so it cannot settle on your position.
- **Deeper:** Shimmers shorten and it reappears from a different angle than the one it faded from, so the last position no longer predicts the next.
- **Flags:** needs systems step

### Piśāca
- **Move:** Crouching, carrion-quick skittering between shadows, with sudden bursts of speed toward exposed prey and quick retreats when faced.
- **Attack:** Raking claw swipes and snapping bites delivered in a flurry, then an immediate break-off; a hunched, trembling crouch is its tell before a burst.
- **Awareness:** Drawn to the wounded, the alone, and the recently dead; ignores strong, grouped opponents and flees from a firm, faced challenge.
- **Counter:** Face it squarely to check its burst, punish the landing after a flurry, and do not let it drag you into shadowed corners.
- **Deeper:** Flurries arrive from two directions in quick succession as it circles faster between bursts.

### Rakshasa
- **Move:** Heavy, swaggering brute advance that can suddenly change shape or seeming — a looming figure one moment, a different form the next — to wrong-foot the player. (The apex Ravana is a separate entry and is not specced here.)
- **Attack:** Brutal claw and weapon blows with a slow, taunting wind-up, plus illusionary doubles that mirror its movements; the real blow lands a beat after the false ones begin.
- **Awareness:** Drawn to challengers and to anyone who meets its gaze or answers its taunts; ignores prey that slips away quietly without engaging.
- **Counter:** Ignore the doubles and watch the true body's feet and wind-up; punish the slow real swing, not the mirrored feints.
- **Deeper:** Doubles linger longer and the real form shifts position between swings, so tracking the true body takes more attention.
- **Flags:** needs systems step

### Makara
- **Move:** Heavy, crocodile-jawed bulk that lumbers on land in short surges and turns slowly, guarding water edges and thresholds.
- **Attack:** A gaping jaw snap with the mouth opening wide as the tell, followed by a tail sweep that covers its rear; it can also surge forward in a short, water-assisted rush near wet ground.
- **Awareness:** Drawn to movement near water and thresholds; ignores distant inland targets and will not pursue far from wet ground.
- **Counter:** Sidestep the jaw snap, stay clear of the tail's arc, and strike from the side while its bulk is still turning.
- **Deeper:** Jaw snaps chain into a tail sweep without the usual pause, covering both the front and the rear escape.

### Asura
- **Move:** Proud, deliberate advance of a warrior-demon — measured steps, weapon carried high, never hurrying, never retreating from a challenge.
- **Attack:** Powerful weapon combos with a raised-weapon wind-up as the tell, plus a shouted challenge that precedes a heavier, committed strike; the shout is the warning to clear the front arc.
- **Awareness:** Drawn to challengers who stand and fight and to displays of power; ignores fleeing prey, which it considers beneath pursuit.
- **Counter:** Dodge the shouted heavy strike rather than blocking it, punish the recovery after a full combo, and do not meet it head-on at its own pace.
- **Deeper:** Combos lengthen by a further strike and the shouted blow arrives with less pause after the combo ends.

### Garuda
- **Move:** Soaring circling flight with sharp, stooping dives, wings beating hard enough to buffet the air as it passes.
- **Attack:** A screaming stoop into a talon rake along a visible dive line, followed by a wing buffet on the climb; the scream and the dive line are the tells, and it is most exposed at the bottom of the stoop.
- **Awareness:** Drawn to serpent-like prey above all, and to movement in the open; ignores prey under solid cover and will not dive where it cannot pull out cleanly.
- **Counter:** Step off the dive line at the scream, strike during the low pull-out, and use cover to force it into longer, more readable circles.
- **Deeper:** Stoops arrive with a feinted first pass — a low flyover without a rake — before the true dive, so the first pass is not always the attack.

## Chinese & East Asian

Law, gluttony, chaos, and trickery run through this family: a judge that gores liars, a devourer that never stops eating, a faceless confusion-bringer, and fox and mountain spirits that win by misdirection.

### Terracotta Soldier
- **Move:** Rigid, drilled march in rank — identical steps, identical turns, holding formation even as individual figures fall.
- **Attack:** Synchronized spear thrusts and halberd chops with a shared arm raise as the tell; the threat is the rank's rhythm, not any single soldier's blow.
- **Awareness:** Drawn to intruders entering the tomb ground; ignores anything outside that ground and reforms its line if the player retreats.
- **Counter:** Break the line at a corner or doorway so only one or two can reach you, and strike during the shared wind-up rather than between thrusts.
- **Deeper:** Ranks hold formation while advancing instead of only while standing, pressing the player backward step by step.

### Mountain Yaoguai
- **Move:** Loping, bestial mountain stride with sudden scrambles over rough ground, using height and broken terrain to approach from above.
- **Attack:** Claw rakes and shoulder charges delivered from a scramble, telegraphed by a crouch and a scramble-start before the rush.
- **Awareness:** Drawn to travelers on mountain paths and to noise in its territory; ignores prey that leaves the mountain ground.
- **Counter:** Hold flat ground where its scramble cannot gain height, sidestep the charge, and strike while it recovers from the scramble.
- **Deeper:** Scrambles arrive from higher, less predictable angles, so the approach line is harder to read.
- **Flags:** thin lore — director call

### Xiezhi
- **Move:** Stately, deliberate advance with a judge's calm — it walks straight at its target without hurry and without deviation.
- **Attack:** A single-horn gore delivered after a long, fixed stare; the stare and the horn lowering are the tell, and the gore runs in a straight line.
- **Awareness:** Drawn to wrongdoers and to anyone who stands and faces it; ignores those who flee, whom it does not consider worth judging.
- **Counter:** Do not stand in its line during the stare; step aside at the horn's lowering and strike from the flank while it recovers from the gore.
- **Deeper:** The stare shortens and the gore follows with less warning, so the dodge window tightens.

### Hulijing
- **Move:** Graceful, gliding approach that shifts seeming as it moves — a beautiful figure one moment, a fox shape the next — never quite where the eye expects it.
- **Attack:** Beguiling feints and sudden fox-fire flickers that dazzle and misdirect, followed by a real claw strike from an unexpected angle; the flicker is the warning that the next strike is false or true.
- **Awareness:** Drawn to the unwary, the lonely, and those who follow a lure; ignores cautious targets who do not chase its seeming.
- **Counter:** Do not chase the lure; hold ground, watch the true body's movement rather than the flickers, and strike when the fox shape solidifies.
- **Deeper:** Flickers multiply and the true strike arrives from behind the player's facing more often.
- **Flags:** needs systems step

### Mogwai
- **Move:** Quick, rain-quick darting between cover, in small numbers, with a skittering, mischievous tempo that never settles into a stand-up fight.
- **Attack:** Nipping bites and snatching grabs at gear and hands, telegraphed by a brief massing chatter before a dart; individuals break off after a single nip.
- **Awareness:** Drawn to rain, damp ground, and careless travelers; ignores wary, still targets and scatters when faced firmly.
- **Counter:** Face the chatter squarely, strike the darting individual on its landing, and do not chase the scatter into cover.
- **Deeper:** Numbers grow and darts arrive in overlapping waves rather than one at a time.
- **Flags:** thin lore — director call

### River Long
- **Move:** Serpentine, water-smooth gliding that coils and uncoils along riverbanks and wet ground, with short airborne surges over low obstacles.
- **Attack:** A coiling lunge with a snapping bite, plus a sweeping tail lash as it uncoils; the coil tightening is the tell before the lunge.
- **Awareness:** Drawn to movement near water and to prey crossing its river ground; ignores distant inland targets.
- **Counter:** Bait the coil, step clear of the lunge line, and strike while it is uncoiling and its tail is still settling.
- **Deeper:** Lunges chain into a second, reversed coil-lunge, so the recovery window after a miss shortens.
- **Flags:** thin lore — director call

### Taotie
- **Move:** Heavy, shuffling bulk that lumbers toward anything edible, mouth always open, never hurrying but never stopping.
- **Attack:** A gaping, devouring bite with the mouth opening wider as the tell, followed by a swallowing lunge that pulls prey inward; it will also snap at dropped items and loose gear in reach.
- **Awareness:** Drawn to food, gear, and movement of anything it can eat; ignores inedible, still objects and anything it cannot reach with its mouth.
- **Counter:** Stay out of the mouth's front arc, dodge the swallowing lunge sideways, and strike from the flank while its jaws are still closing.
- **Deeper:** The swallowing lunge reaches farther and it snaps at a second target immediately after the first bite.

### Hundun
- **Move:** Faceless, shambling drift that wanders without apparent direction, turning and lurching as if it cannot see where it is going — which makes its approach hard to predict.
- **Attack:** Confusing, directionless flails and a disorienting presence that scrambles the player's sense of where the next blow comes from; a shuddering stillness precedes a flurry, and that stillness is the only tell.
- **Awareness:** Drawn to the virtuous and the orderly, and to anyone trying to hold a formation; ignores the chaotic and the already-confused.
- **Counter:** Do not try to read its facing — it has none to read; watch the shuddering stillness, step clear of the flurry, and strike during the lull that follows.
- **Deeper:** Flurries arrive with less stillness beforehand, so the warning shrinks even as the confusion grows.
- **Flags:** needs systems step

### Qilin, Corrupted
- **Move:** Once-gentle, now jerking charger — a stately walk broken by sudden, corrupted rushes, hooves striking sparks as it turns.
- **Attack:** A horn gore delivered after a pawing, head-lowering charge telegraph, plus a corrupted aura-flare that precedes a wider, sweeping horn arc; the pawing is the warning to clear the line.
- **Awareness:** Drawn to the righteous and the orderly, whom its corrupted nature now resents; ignores prey that flees without standing to be judged.
- **Counter:** Sidestep the charge at the pawing, strike from the flank during the turn after a miss, and clear the arc when the flare shows.
- **Deeper:** Charges chain into a second rush with only a brief pawing between them, and the flare arc widens.

## Japanese Yōkai

Tool spirits, water dwellers, mountain demons, and snow women crowd this family: tricksters that ambush from ordinary objects, spiders that lure and web, and a few heavy brutes whose slow, readable blows punish standing still.

### Karakasa
- **Move:** Hopping, one-legged bounces with a lolling tongue and a wide, grinning eye, bounding around the player in playful, erratic hops.
- **Attack:** Tongue-lash flicks and hopping body-slams, telegraphed by a high hop and a tongue flick before the drop; it never stays in reach after landing.
- **Awareness:** Drawn to the unwary and to anyone startled by it; ignores cautious targets and tends to bounce away if firmly faced.
- **Counter:** Strike on its landing, when the single leg must steady itself, and do not chase its bounces into corners.
- **Deeper:** Hops arrive in quicker chains with less pause on landing, so the punish window tightens.

### Chōchin-obake
- **Move:** Floating, bobbing drift like a lantern on a breeze, swaying toward the player with sudden, short dashes.
- **Attack:** A split-mouth snap and a burst of lantern flame, telegraphed by the lantern flaring bright and the mouth opening wide before the burst.
- **Awareness:** Drawn to light and to travelers at night; ignores targets in bright, steady light and drifts toward darkness and movement.
- **Counter:** Step out of the flame's short arc at the flare, strike while the mouth is still open and the lantern is dimming, and keep a steady light if you can.
- **Deeper:** Flame bursts arrive in a fanned pair instead of a single arc, covering both sidestep directions.

### Kappa
- **Move:** Waddling, shell-backed advance that closes steadily to contact range, head dish carried level; it does not dart or charge.
- **Attack:** A reaching grab followed by a dragging wrestle at close range, telegraphed by both arms reaching wide; the shell turns aside glancing blows while it closes.
- **Awareness:** Drawn to prey near water and to anyone who approaches its river ground; ignores distant inland targets.
- **Counter:** Keep distance and strike while it is still waddling in; if grabbed, break the hold by forcing its head dish to spill — by movement, not by trading blows inside the wrestle.
- **Deeper:** Grabs chain into a second drag attempt if the first is broken, so a single escape no longer ends the wrestle.

### Oni
- **Move:** Slow, deliberate, heavy-footed advance with a club carried high, never hurrying and never retreating from a fight. (The apex Shuten-dōji is a separate entry and is not specced here.)
- **Attack:** Overhead club slams with a long, high club raise as the tell, plus a wide, sweeping club arc after a missed slam; the raise is the dodge cue and the recovery after a slam is the punish window.
- **Awareness:** Drawn to challengers and to noise; ignores fleeing prey, which it considers beneath pursuit, and holds its ground once engaged.
- **Counter:** Dodge on the club raise, step inside the arc after a missed slam, and never trade blows in front of the club.
- **Deeper:** Slams chain into a second, reversed sweep with less recovery between them.

### Bake-danuki
- **Move:** Shambling, shape-shifting approach — a tanuki shape, a human shape, an object shape — that changes as it closes, making its true position hard to fix.
- **Attack:** Drumming-belly feints and sudden transformation strikes, where a harmless seeming snaps into a clawed or weaponed form; the drumbeat quickening is the tell before the true strike.
- **Awareness:** Drawn to the unwary and to travelers who follow a lure; ignores cautious targets who do not chase its seemings.
- **Counter:** Watch the true body's feet and the drumbeat, not the seeming; strike when the form solidifies for the real blow.
- **Deeper:** Seemings change mid-strike, so the form at the wind-up is not always the form that lands.
- **Flags:** needs systems step

### Kasha
- **Move:** Fiery, cat-like bounding on burning wheels of flame, circling funeral ground and corpses with a hungry, prowling tempo.
- **Attack:** A flaming pounce with claws extended, telegraphed by a crouch and a flare of corpse-fire around its wheels; after the pounce it drags at its target as if hauling a body away.
- **Awareness:** Drawn to corpses, funeral ground, and the recently dead; ignores the living unless they stand between it and a body.
- **Counter:** Do not stand between it and a corpse; sidestep the pounce at the flare, and strike during the drag, when its head is low and its wheels slow.
- **Deeper:** Pounces chain into a second, reversed pounce without the full crouch between them.

### Kitsune
- **Move:** Swift, fox-quick darting with illusionary afterimages trailing behind it, so the eye follows a false fox while the true one circles.
- **Attack:** Fox-fire bolts flicked from range, plus a sudden close claw strike from an afterimage's position; the fire gathering at its tails is the tell before a bolt.
- **Awareness:** Drawn to the unwary, the lonely, and those who chase a lure; ignores cautious targets who hold ground and watch the true body.
- **Counter:** Do not chase the afterimages; watch the tails, dodge the bolt's line, and strike the body that gathers fire, not the one that flickers.
- **Deeper:** Afterimages linger longer and bolts arrive in fanned pairs, covering both sidestep directions.
- **Flags:** needs systems step

### Tengu
- **Move:** Swift, winged darting between high perches, with sudden swoops that end in a climbing retreat; it rarely fights on the ground.
- **Attack:** A fan-driven gust that pushes the player off balance, followed by a swooping sword or claw strike along a visible dive line; the fan raising is the tell before the gust.
- **Awareness:** Drawn to the proud, the noisy, and intruders in mountain ground; ignores quiet, humble passersby who do not challenge it.
- **Counter:** Brace for the gust, step off the dive line at the fan's raise, and strike during the low pull-out before it climbs to a perch.
- **Deeper:** Gusts arrive before the swoop more often, so the player is already off balance when the dive line appears.

### Yuki-onna
- **Move:** Silent, gliding drift through snow and cold air, appearing where the cold thickens and fading where it thins, never leaving footprints.
- **Attack:** A freezing breath and a chilling touch, telegraphed by the air frosting visibly around her and her sleeves rising before the breath; the cold slows and stills anyone caught standing in it.
- **Awareness:** Drawn to travelers lost in snow and cold, and to warmth; ignores the well-sheltered and those who do not enter the cold ground.
- **Counter:** Keep moving through the cold, step clear of the frosted air at the sleeve raise, and strike during the pause after a breath.
- **Deeper:** The frosted ground lingers longer after each breath, so safe footing shrinks with every exchange.
- **Flags:** needs systems step

### Jorōgumo
- **Move:** A beautiful seeming that waits, then a spider's scuttle once the lure is taken — slow and inviting first, blindingly fast once the web is sprung.
- **Attack:** A web-cast that snares and slows, telegraphed by silk threads shimmering faintly in the air before the cast, followed by a venom bite once the prey is tangled; the shimmer is the warning to move.
- **Awareness:** Drawn to the lonely and to anyone who follows a lure into its ground; ignores wary targets who do not approach the seeming.
- **Counter:** Do not approach the seeming; step clear the moment silk shimmers, cut or break the web rather than fighting inside it, and strike while it is casting, not after the bite.
- **Deeper:** Webs cover a wider area and a second cast follows the first if the prey breaks free.
- **Flags:** needs systems step

### Nure-onna
- **Move:** Serpent-bodied gliding near water and shorelines, upper body raised like a woman, tail coiling behind her in the shallows.
- **Attack:** A serpent's lunge and a constricting coil, plus a handed burden — a seeming child pressed on the player — that weighs down and slows anyone who takes it; the arms extending with the burden are the tell.
- **Awareness:** Drawn to travelers near water at night and to anyone who accepts what she offers; ignores those who refuse the burden and keep their distance.
- **Counter:** Refuse the burden and keep distance; if the coil lands, break it by striking the tail, not the raised upper body, and step out of the lunge line.
- **Deeper:** The burden is offered sooner and the coil follows faster after a refusal, so the safe refusal window tightens.
- **Flags:** needs systems step

### Nue
- **Move:** Chimeric, night-cloud movement — a monkey-faced, tiger-limbed, serpent-tailed shape that drifts and pounces from darkness, never moving in a straight, readable line.
- **Attack:** A mixed assault — a monkey's snapping bite, tiger claw rakes, and a serpent-tail lash — delivered in an unpredictable order, telegraphed only by a low, eerie cry before the pounce.
- **Awareness:** Drawn to the sleeping, the ill, and the fearful at night; ignores the alert and the well-lit, and fades from darkness that is broken by light.
- **Counter:** Listen for the cry, do not try to predict which limb strikes first, and strike during the pause after a full mixed assault, when all its parts must reset.
- **Deeper:** The assault order changes between exchanges, so learning one sequence no longer predicts the next.

### Tsuchigumo
- **Move:** Heavy, ground-hugging spider advance with a slow, inexorable tread, holding webbed ground and rarely leaving it.
- **Attack:** A wide web-cast that snares, followed by crushing leg strikes and a venom bite; the legs rearing and silk shimmering are the twin tells before the cast.
- **Awareness:** Drawn to intruders entering its webbed ground and to heroes who challenge it; ignores prey that leaves the webbed ground.
- **Counter:** Stay out of the webbed ground where possible, step clear at the silk shimmer, and strike the legs while they are reared, before the cast completes.
- **Deeper:** Webs cover a wider area and leg strikes follow the cast without the usual pause, closing the punish window.

## Sources consulted

- https://en.wikipedia.org/wiki/List_of_mythical_creatures_in_Egyptian_mythology
- https://www.egypttoursportal.com/blog/ancient-egyptian-civilization/ancient-egyptian-mythical-creatures-and-monsters/
- https://fictionhorizon.com/top-15-creatures-from-egyptian-mythology/
- https://nzt-eth.ipns.dweb.link/wiki/List_of_Mesopotamian_deities.html
- https://timelessmyths.com/stories/ugallu/
- https://dyerbolical.com/the-10-most-ancient-demons-from-sumerian-and-babylonian-lore/
- https://babylonian.mythologyworldwide.com/mythical-creatures-of-akkadian-lore-from-lamassu-to-humbaba/
- https://godsandmonsters.info/anzu/
- https://ancientegyptonline.co.uk/ammit/
- https://learningmole.com/3-interesting-types-of-egyptian-statues/
- https://beastsoflegend.com/bestiary/asia-2/south-asian/
- https://fictionhorizon.com/top-15-creatures-from-hindu-mythology/
- https://en.wikipedia.org/wiki/List_of_legendary_creatures_from_China
- https://en.wikipedia.org/wiki/List_of_Chinese_mythology
- https://immortalmountain.wordpress.com/glossary/chinese-bestiary/
- https://www.yokailore.com/
- https://www.nihongomaster.com/blog/20-well-known-yokai-in-japanese-folklore
- https://historyofjapan.co.uk/wiki/supernatural-creatures/


---

[Part file: behavior-specs/part-7.md](behavior-specs/part-7.md)

## Part 7 — Fey & Nature Spirits, Elementals & Primal Spirits, Golems & Constructs, Dragons & Great Serpents, The Abyssal & Cosmic

Specs only. No game code is changed by this document. Behavior only — no stat numbers anywhere. Lore is paraphrased in original wording, never copied from sources. Where lore is thin or a behavior would need a new game system, the entry is flagged rather than invented or assumed.

## Fey & Nature Spirits

Small, old, and hard to pin down: the fey of folklore are tricksters, household helpers, and spirits bound to a tree, a spring, or a stretch of air. In the delve they rarely fight fair — they dart, dazzle, mislead, and vanish, and the player wins by refusing the bait and striking during the brief moment they commit.

### Pixie

- **Move:** Tiny, fast, erratic fluttering flight; darts between perches and never holds a straight line.
- **Attack:** Dazzling flash followed by a quick nicking strike, then an immediate dart away.
- **Awareness:** Drawn to movement and noise; ignores a still, quiet player until approached.
- **Counter:** Strike during the perch pause or just after the flash, when its flight path steadies.
- **Deeper:** Darts in loose pairs that alternate flashes, so one flash covers the other's approach.

### Sprite

- **Move:** Swift, light flight with weaving skirmish runs at mid-range.
- **Attack:** Quick darting sting or nip, then a climbing retreat out of melee reach.
- **Awareness:** Reacts to the player entering its patch of ground; ignores distant fighting.
- **Counter:** Time a swing to the bottom of its dive, when it briefly commits to a line.
- **Deeper:** Dive runs come in quicker succession with shorter climbs between them.

### Bramble Imp

- **Move:** Low, scrambling ground skirmisher that weaves through undergrowth and cover.
- **Attack:** Thorned jab from cover, then a scramble to a new hiding spot.
- **Awareness:** Drawn to a player pushing through brush or cover; ignores open-ground passers-by.
- **Counter:** Do not chase into cover — wait at the edge and strike as it emerges for the jab.
- **Deeper:** Lays more false rustles, so the player must watch which rustle ends in a jab.
- **Flags:** thin lore — director call

### Brownie

- **Move:** Quiet, scurrying ground movement; slips between cover and keeps to edges and shadows.
- **Attack:** Hit-and-run prod or trip-style swipe, always followed by a retreat to cover.
- **Awareness:** Drawn to a player who lingers or makes a mess of its ground; ignores a player who passes through cleanly and quickly.
- **Counter:** Hold ground and punish the return trip — it always comes back along the same edge.
- **Deeper:** Retreating runs chain between several cover spots instead of one, lengthening the chase.

### Dryad

- **Move:** Rooted to one spot, swaying and shifting within a small grove area; does not roam.
- **Attack:** Lashing branch sweeps at close range and a slow, arcing seed or thorn volley at range.
- **Awareness:** Wakes when its grove is entered or disturbed; ignores anything outside the grove.
- **Counter:** Fight at the edge of its reach, stepping in only during the pause after a branch sweep.
- **Deeper:** Branch sweeps chain into a second sweep from the opposite side before the pause returns.

### Naiad

- **Move:** Fluid, drifting movement that hugs water, damp ground, and low mist.
- **Attack:** Splashing wave lash at range and a dragging pull when the player stands in wet ground.
- **Awareness:** Drawn to movement in or near water; ignores a player who keeps to dry ground.
- **Counter:** Lure it onto dry ground, where its movement slows and its pull fails to grip.
- **Deeper:** Mist thickens around it, making its wave wind-up harder to read until it commits.

### Sylph

- **Move:** Constant, airy flight that circles high and drifts on gusts; never lands to fight.
- **Attack:** Gust bolts and swirling wind slashes thrown from above, then a drift to a new angle.
- **Awareness:** Drawn to open movement and to players standing in the open; ignores a player sheltering under cover.
- **Counter:** Fight from cover and strike during the hover pause before each gust volley.
- **Deeper:** Gusts arrive from two angles in sequence, forcing a reposition between volleys.

### Faun

- **Move:** Nimble, bounding ground skirmisher that leaps in, strikes, and bounds out.
- **Attack:** Bounding kick or horn jab, then an immediate leap back out of range.
- **Awareness:** Drawn to a player who approaches boldly; ignores a player who holds still and watches.
- **Counter:** Strike at the landing of its leap, when it is briefly planted before bounding away.
- **Deeper:** Leap chains add a second, shorter bound before the retreat, changing the landing point.

### Will-o'-wisp

- **Move:** Slow, floating drift that beckons ahead, always just out of comfortable reach.
- **Attack:** No direct strike — it lures the player onward, then flares in a burst when the player follows too far or stands too close.
- **Awareness:** Drawn to any player who follows its light; ignores a player who refuses to follow.
- **Counter:** Refuse the lure, hold position, and let it drift back — its flare only triggers on pursuit or close approach.
- **Deeper:** The lure path bends past hazards and other waiting foes instead of running straight.
- **Flags:** needs systems step

### Changeling

- **Move:** Shifting, deceptive movement — it approaches in a borrowed shape, then breaks shape to strike.
- **Attack:** Ambush strike at the moment its disguise drops, followed by a scrambling retreat to re-disguise.
- **Awareness:** Drawn to a player who approaches it trustingly; ignores a player who keeps distance and watches.
- **Counter:** Do not approach an unfamiliar figure blindly — watch for the tell as the shape breaks, and strike in that window.
- **Deeper:** It re-disguises mid-fight, forcing the player to re-identify it before the next ambush.
- **Flags:** needs systems step

### Elder Dryad

- **Move:** Slow, immense, rooted presence; shifts its grove slowly but never leaves it.
- **Attack:** Wide root sweeps, falling branch strikes, and a slow thorn volley that fills its grove.
- **Awareness:** Wakes when its grove is disturbed or entered with force; ignores quiet passage at the grove edge.
- **Counter:** Work the grove edge, punish the long recovery after a root sweep, and never stand where roots have already churned the ground.
- **Deeper:** Root sweeps arrive in a pattern across the grove floor, herding the player toward the branch-strike zone.

## Elementals & Primal Spirits

The old fourfold scheme gives each element a spirit that lives in it as people live in air: earth, water, air, and fire, with storm, magma, and frost as wilder crossings. In the delve each elemental fights as its element moves — plodding, flowing, gusting, or flaring — and the counter is always to deny it its element's ground.

### Gnome

- **Move:** Low, scuttling ground skirmisher that pops between cover and burrows briefly out of sight.
- **Attack:** Quick earth jab or tossed stone, then a duck back into cover or soil.
- **Awareness:** Drawn to a player crossing open stone or earth; ignores a player who stays on raised or paved ground.
- **Counter:** Strike as it surfaces — the pop-up pause before the jab is its only steady window.
- **Deeper:** Pop-ups chain from several spots in sequence, so the player must track the last hole, not the first.

### Salamander

- **Move:** Quick, flickering ground skirmisher that darts through flame and hot ground.
- **Attack:** Flame lick at close range and a short fire-spit at mid-range, both telegraphed by a brightening glow.
- **Awareness:** Drawn to heat and to players standing on hot ground; ignores a player on cold ground.
- **Counter:** Step off hot ground and strike during the dimming pause after its flame brightens and fires.
- **Deeper:** Its fire-spit leaves a brief burning patch, shrinking the safe ground around it.

### Fire Elemental

- **Move:** Roiling, surging advance that flows forward in waves rather than walking.
- **Attack:** Sweeping flame lash at close range and a lobbed fireball at range, telegraphed by a swelling flare.
- **Awareness:** Drawn to movement and to open ground; ignores a player sheltering behind stone.
- **Counter:** Strike during the flare's swell, before it releases — or step behind stone and punish the recovery after the lob.
- **Deeper:** Flame lashes chain into a second sweep, and lobbed fire splits its landing zone.

### Water Elemental

- **Move:** Slow, flowing advance that pools and reforms, sliding around obstacles rather than climbing them.
- **Attack:** Crashing wave slam at close range and a surging water jet at range.
- **Awareness:** Drawn to players standing in or near water; ignores a player who keeps to high, dry ground.
- **Counter:** Hold high ground and strike as it reforms after a slam, when its shape is thinnest.
- **Deeper:** After each slam it splits its advance, approaching from two flowing lines at once.

### Earth Elemental

- **Move:** Slow, heavy plod that never hurries and never retreats.
- **Attack:** Massive ground slam with a long raised-arm wind-up, plus a shock ripple along the ground.
- **Awareness:** Drawn to sustained noise and vibration; ignores a still, quiet player.
- **Counter:** Step out of the slam line during the long wind-up, then strike during the slow recovery.
- **Deeper:** Slam ripples travel farther and arrive in a second, delayed wave after the first.

### Air Elemental

- **Move:** Fast, swirling flight that circles and dives without ever landing.
- **Attack:** Cutting gust slash from a dive and a buffeting wind burst that pushes the player off balance.
- **Awareness:** Drawn to open movement; ignores a player under solid cover.
- **Counter:** Fight from cover and strike as it pulls out of a dive, when its path straightens.
- **Deeper:** Dives come in pairs from opposite directions, so the second dive punishes dodging the first the same way twice.

### Undine

- **Move:** Graceful, drifting movement tied to water and mist; glides rather than walks.
- **Attack:** Lashing water whip at range and a chilling mist burst at close range.
- **Awareness:** Drawn to players near water or mist; ignores a player on dry, clear ground.
- **Counter:** Draw it onto dry ground, where its whip loses reach, and strike during the mist burst's fade.
- **Deeper:** Mist bursts linger, narrowing visibility and masking the wind-up of the next whip.

### Storm Elemental

- **Move:** Crackling, leaping flight that blinks between storm fronts in short hops.
- **Attack:** Lightning bolt strikes telegraphed by a gathering charge glow, plus a gusting shockwave burst.
- **Awareness:** Drawn to players standing in the open or on high ground; ignores a player under cover.
- **Counter:** Shelter under cover during the charge glow, then strike in the quiet beat after a bolt lands.
- **Deeper:** Bolts chain to nearby storm-charged ground, so standing where a bolt just fell becomes unsafe.

### Magma Elemental

- **Move:** Slow, oozing advance that leaves a trail of hot ground behind it.
- **Attack:** Molten slam at close range and a lobbed magma glob that bursts into a burning patch.
- **Awareness:** Drawn to players on stone or hot ground; ignores a player who keeps moving across cold ground.
- **Counter:** Keep moving, never stand on its trail, and strike during the long gather before a magma lob.
- **Deeper:** Its trail widens and its globs burst into spreading patches, steadily shrinking safe footing.

### Frost Elemental

- **Move:** Gliding, creeping advance that spreads frost across the ground it crosses.
- **Attack:** Freezing shard volley at range and a chilling slam at close range, telegraphed by a brightening ice sheen.
- **Awareness:** Drawn to movement across open ground; ignores a player who stays behind warm cover.
- **Counter:** Strike during the sheen's brightening, before the volley releases, and never fight standing on its frost.
- **Deeper:** Frost patches linger and slow the player's footing, forcing fights to keep relocating.

## Golems & Constructs

Made things, not born things: clay, stone, bone, brass, iron, and crystal shaped into servants, guardians, and haunted shells. They are slow, stubborn, and honest — they telegraph every blow, absorb punishment, and punish a player who trades blows instead of dodging and striking the recovery.

### Clay Golem

- **Move:** Slow, heavy plod straight toward the player; never retreats, never hurries.
- **Attack:** Heavy overhead slam with a long raised-arm wind-up.
- **Awareness:** Drawn to movement and noise in its chamber; ignores a still player outside its chamber.
- **Counter:** Sidestep during the wind-up and strike during the slow recovery after the slam.
- **Deeper:** Slams chain into a second, wider slam if the first misses, punishing a sidestep that stays too close.

### Gargoyle

- **Move:** Stone-still perch, then sudden winged swoops and dives; returns to a perch between attacks.
- **Attack:** Dive rake with talons, telegraphed by the dive line, plus a close-range claw swipe when grounded.
- **Awareness:** Wakes when a player passes beneath its perch; ignores a player who never enters its perch zone.
- **Counter:** Watch the perch for the faint shift before it moves, dodge the dive line, and strike as it climbs away.
- **Deeper:** It changes perches mid-fight, so the dive line comes from a new angle each time.

### Living Statue

- **Move:** Motionless until triggered, then a slow, deliberate advance with heavy footfalls.
- **Attack:** Sweeping stone arm strike and a crushing two-handed blow, both with long wind-ups.
- **Awareness:** Wakes on approach or touch; ignores a player who passes at a distance without disturbing it.
- **Counter:** Trigger it from range, step out of the sweep arc during the wind-up, and punish the recovery.
- **Deeper:** Its strikes alternate sides, so dodging the same direction twice stops working.

### Haunted Armor

- **Move:** Stiff, marching advance in a straight line, turning slowly to track the player.
- **Attack:** Sword chop with a formal raised-blade wind-up, plus a shield shove at close range.
- **Awareness:** Drawn to a player who enters its guard post; ignores a player who leaves the post.
- **Counter:** Circle to its slow-turning side and strike during the pause after a chop.
- **Deeper:** Chops chain into a second chop from the opposite side before the pause returns.

### Stone Golem

- **Move:** Slow, grinding plod; blocks corridors by sheer bulk.
- **Attack:** Wide ground slam and a shoulder charge down straight lines, telegraphed by a grinding crouch.
- **Awareness:** Drawn to noise and movement in its corridor; ignores a quiet player in a side passage.
- **Counter:** Dodge the charge line, then strike from the side during its slow turn after a missed charge.
- **Deeper:** Charges come down longer lines and end in a slam, not just a stop.

### Bone Golem

- **Move:** Rattling, shambling advance that reassembles its posture as it moves.
- **Attack:** Raking bone-claw sweeps and a throwing-bone volley at range.
- **Awareness:** Drawn to the living and to noise; ignores a still player among bones and rubble.
- **Counter:** Strike during the rattle-pause before a volley, when its frame steadies to aim.
- **Deeper:** Its sweeps shed loose bones that briefly litter the ground, complicating footing.

### Brass Automaton

- **Move:** Clockwork, ticking advance in measured steps, with whirring turns to face the player.
- **Attack:** Piston punch with a winding wind-up and a steam burst at close range, telegraphed by a rising hiss.
- **Awareness:** Drawn to movement in its patrol line; ignores a player who stays off that line.
- **Counter:** Step off its patrol line during the winding, then strike during the hiss-and-vent recovery after the steam burst.
- **Deeper:** Its step pattern speeds up in bursts, breaking the steady rhythm the player learned.

### Iron Golem

- **Move:** Slowest, heaviest plod; shakes the ground as it advances and never deviates.
- **Attack:** Crushing fist slam with a very long wind-up and a ground-shaking stomp that ripples outward.
- **Awareness:** Drawn to sustained vibration and noise; ignores a still, silent player.
- **Counter:** Read the long wind-up, step clear of the slam, and strike only during the deep recovery.
- **Deeper:** Stomp ripples arrive in two waves, so the safe moment after the first wave is a trap.

### Crystal Golem

- **Move:** Gliding, chiming advance that refracts light as it moves.
- **Attack:** Shard volley at range, telegraphed by a brightening facet glow, plus a slicing crystal-edge strike at close range.
- **Awareness:** Drawn to light and movement; ignores a player who stays in shadow and stillness.
- **Counter:** Strike during the facet glow, before the volley releases, and fight from shadow where its glow reads clearest.
- **Deeper:** Shard volleys refract into split lines, so one volley covers two angles at once.

## Dragons & Great Serpents

Not all dragons fly, and not all serpents are small: this family runs from the swooping drake to the burrowing wyrm, the winged serpent, and the armored tarasque. The shared grammar is breath, gaze, and charge — every one of them telegraphs its worst attack, and the fight is won by reading that tell, not by outlasting it. Apex forms Fafnir and Tarasque are separate and are referenced only, not specced here.

### Drake

- **Move:** Low swooping flight that climbs to reposition between attacks.
- **Attack:** Short cone of fire breath, telegraphed by a visible inhale, plus a swooping claw rake.
- **Awareness:** Drawn to movement in the open; ignores a player under solid cover.
- **Counter:** Step out of the breath line during the inhale, then strike as it climbs away.
- **Deeper:** Breath cones sweep sideways across the ground instead of firing straight ahead.

### Wyvern

- **Move:** Fast, agile flight with circling passes and steep dives.
- **Attack:** Dive sting with its tail barb, telegraphed by the dive line and a raised tail, plus a biting pass at close range.
- **Awareness:** Drawn to a player in the open; ignores a player who shelters under cover.
- **Counter:** Dodge the dive line and strike during the climb-out, when its tail is still raised and exposed.
- **Deeper:** Dives chain into a second, shallower dive before it climbs clear.

### Cockatrice

- **Move:** Strutting, fluttering ground movement with short hopping flights.
- **Attack:** Pecking strikes and a slowing statue-gaze, telegraphed by a brightening eye glow.
- **Awareness:** Drawn to a player who faces it directly; ignores a player who keeps moving past it.
- **Counter:** Turn or strafe during the eye-glow wind-up, and strike during the long cooldown after the gaze.
- **Deeper:** The gaze wind-up shortens and its pecking strikes chain, shrinking the safe window.
- **Flags:** needs systems step

### Jaculus

- **Move:** Coiled wait in trees or high cover, then a javelin-like launching dive at prey.
- **Attack:** The launch itself is the attack — a high-speed piercing strike — followed by a coiling retreat to cover.
- **Awareness:** Drawn to a player passing beneath its cover; ignores a player who never enters that shadow.
- **Counter:** Watch high cover for the coiling tell, sidestep the launch line, and strike while it recoils.
- **Deeper:** Launches come from a second hiding spot after the first miss, so the launch line changes.

### Wyrm

- **Move:** Burrowing advance that surfaces in lunges, then dives back underground.
- **Attack:** Surfacing lunge and bite, telegraphed by churning ground, plus a tail sweep when fully surfaced.
- **Awareness:** Drawn to ground vibration and footsteps; ignores a still player.
- **Counter:** Step off the churning ground line and strike during the surfacing pause before it dives again.
- **Deeper:** It surfaces in a pattern of short lunges, surfacing closer each time before the full bite.

### Basilisk

- **Move:** Slow, upright serpentine advance, head raised, never hurrying.
- **Attack:** Petrifying gaze telegraphed by eye glow, plus a venomous bite at close range.
- **Awareness:** Drawn to any creature that faces it; ignores a player who approaches from behind or with eyes averted.
- **Counter:** Face away or strafe during the eye-glow wind-up, and strike during the long gaze cooldown.
- **Deeper:** The gaze fires in a sweeping arc rather than a fixed stare, forcing movement through the whole wind-up.
- **Flags:** needs systems step

### Amphiptere

- **Move:** Sustained winged-serpent flight that coils and uncoils in the air.
- **Attack:** Coiling constriction dive from above, telegraphed by the coil tightening, plus a snapping bite.
- **Awareness:** Drawn to movement in open air; ignores a player under a roof or canopy.
- **Counter:** Dodge the coil line and strike as it uncoils after a missed dive.
- **Deeper:** Dives tighten into a double coil, so the second snap follows the first without a climb.

### Peluda

- **Move:** Shambling, quilled advance that bristles as it closes; moves through water and mud with ease.
- **Attack:** Quill volley at range, telegraphed by a bristling shake, plus a trampling charge down straight lines.
- **Awareness:** Drawn to noise and movement near water; ignores a quiet player on dry, high ground.
- **Counter:** Step off the charge line during its pawing tell, and strike during the bristle-settling pause after a volley.
- **Deeper:** Quill volleys spread wider and charges chain into a second charge from the rebound.

### Elder Wyrm

- **Move:** Massive burrowing and coiling presence; surfaces across a wide area rather than one point.
- **Attack:** Multi-point surfacing bites, ground-churning tail sweeps, and a long breath wash along the ground.
- **Awareness:** Drawn to sustained ground vibration; ignores a still player who has stopped moving.
- **Counter:** Track the churn pattern, stay off the newest churn line, and strike the exposed segment during the pause between surfacings.
- **Deeper:** Surfacings overlap, so two segments threaten at once and the safe ground between them narrows.

### Tarasque

- **Move:** Heavy, six-limbed plod that shrugs through obstacles; slow to turn.
- **Attack:** Shell-shoulder charge down straight lines, a poisonous breath wash telegraphed by a swelling throat, and a serpent-tail lash behind it.
- **Awareness:** Drawn to movement and noise in its territory; ignores a player who slips out of its territory quietly.
- **Counter:** Dodge the charge line, circle to its slow-turning flank, and strike during the recovery after the breath wash. Note: this is the non-apex tarasque; the apex Tarasque is separate and is not specced here.
- **Deeper:** Charges end in a tail lash, punishing a player who chases directly behind it after a miss.

## The Abyssal & Cosmic

What lives past the edge of the map: shadows that phase, titans that shake the floor, and horrors whose shapes and voices do not belong to any one folklore. Their lore is deliberately thin in places — where it is, the entry says so instead of inventing a backstory. Apex Typhon is separate and is referenced only, not specced here.

### Living Shadow

- **Move:** Phase drift that ignores cover and positioning rules other monsters obey; no footsteps to track it by.
- **Attack:** Phase strike delivered from the drift, then a drift-away, telegraphed by a materializing shimmer.
- **Awareness:** Drawn to a player's shadow and movement; ignores a still player in bright, open light.
- **Counter:** Watch for the shimmer, strike as it materializes, and fight in bright ground where its drift reads clearest.
- **Deeper:** Its drift leaves a fading afterimage, so the player must strike the solidifying shape, not the fading one.

### Titan

- **Move:** Slow, mountainous advance that shakes the ground with every step; never retreats.
- **Attack:** Colossal overhead slam and a ground-shaking stomp ripple, both with very long wind-ups.
- **Awareness:** Drawn to sustained noise and large movements; ignores a small, still player.
- **Counter:** Read the long wind-ups, step clear of the slam and ripple lines, and strike only during the deep recovery.
- **Deeper:** Slams chain into a stomp ripple, so the ground stays dangerous after the slam itself passes.

### Void Horror

- **Move:** Unsteady, drifting advance that flickers in and out of clear sight.
- **Attack:** Grasping tendril lash at range and a draining close-range grip, telegraphed by a darkening ripple.
- **Awareness:** Drawn to light and movement; ignores a player who stays still in darkness.
- **Counter:** Strike during the ripple's darkening, before the lash releases, and keep moving so the grip cannot settle.
- **Deeper:** Tendril lashes arrive from two directions at once, forcing a dodge that does not end in the second lash.
- **Flags:** thin lore — director call

### Null Seraph

- **Move:** Slow, hovering flight in a fixed halo pattern, circling above the fight.
- **Attack:** Radiant beam volleys from above, telegraphed by a gathering halo glow, plus a silencing aura pulse at close range.
- **Awareness:** Drawn to spellcasting and bright effects; ignores a player who fights plainly and quietly.
- **Counter:** Strike during the halo glow, before the beam releases, and break line of sight during the pulse wind-up.
- **Deeper:** Beam volleys sweep across the ground instead of striking one point.
- **Flags:** thin lore — director call

### Entropy Wraith

- **Move:** Fading, drifting phase movement that thins and thickens as it moves.
- **Attack:** Withering touch at close range and a decay wave at mid-range, telegraphed by a paling shimmer.
- **Awareness:** Drawn to movement and to lingering effects; ignores a player who passes quickly and leaves nothing behind.
- **Counter:** Strike during the paling shimmer, before the wave releases, and never linger in ground it has already decayed.
- **Deeper:** Decay waves leave withered ground behind them, steadily shrinking safe footing.
- **Flags:** thin lore — director call

### Star Horror

- **Move:** Slow, tumbling drift through open space, limbs and light shifting as it turns.
- **Attack:** Starlight burst volleys telegraphed by a brightening core, plus a gravitational pull that drags the player toward it.
- **Awareness:** Drawn to movement in open ground; ignores a player anchored behind heavy cover.
- **Counter:** Brace behind cover during the core brightening, then strike during the dimming pause after a burst.
- **Deeper:** Bursts arrive in a star pattern, covering several angles at once instead of one line.
- **Flags:** thin lore — director call

### The Hollow Choir

- **Move:** A drifting mass of voices that advances as a loose swarm, reforming around the player.
- **Attack:** Layered scream volleys from several voices at once, telegraphed by a rising harmonic swell, plus a close-range wailing press.
- **Awareness:** Drawn to noise and to players who answer or approach the sound; ignores a player who moves quietly away from it.
- **Counter:** Break line of sight during the swell, strike the nearest voice during the pause after a volley, and never stand in the center of the mass.
- **Deeper:** Voices split into two groups that alternate volleys, removing the single shared pause.
- **Flags:** thin lore — director call

### Ashen Titan

- **Move:** Slow, ash-trailing plod that leaves a grey wake; shakes loose ash as it moves.
- **Attack:** Ash-cloud slam at close range, telegraphed by a rising ash plume, plus an ember volley at range.
- **Awareness:** Drawn to movement through its ash wake; ignores a player who stays on clean ground.
- **Counter:** Fight from clean ground, step out of the plume line during the rise, and strike during the settling pause after a slam.
- **Deeper:** Ash clouds linger after slams, masking the wind-up of the next attack until it commits.

### Ur-Dragon

- **Move:** Vast, coiling flight and ground presence that shifts between swooping passes and rearing ground attacks.
- **Attack:** Sweeping breath wash telegraphed by a deep inhale, tail sweeps around its coils, and a crushing bite on a rearing lunge.
- **Awareness:** Drawn to sustained movement and noise across a wide area; ignores a still player who has broken contact.
- **Counter:** Step out of the breath line during the inhale, punish the recovery after a rearing lunge, and never stand inside the coil ring during a tail sweep. Note: this is the non-apex Ur-Dragon; apex Typhon is separate and is not specced here.
- **Deeper:** Breath washes sweep across the ground and tail sweeps follow the breath, chaining the two danger zones.

## Sources consulted

- https://faeryfae.com/definitions-comprehensive-list-of-fae/
- http://www.themystica.com/mystica/articles/e/elementals.html
- https://en.m.wikipedia.org/wiki/Elemental#p-lang
- https://en.wikipedia.org/wiki/Tarasque
- https://tvtropes.org/pmwiki/pmwiki.php/Main/BasiliskAndCockatrice

## Public code ingredients

No code is pasted here — references and adaptation notes only. Code application stays with the systems step. Each source below had its license verified on its own page during this research.

- **LimboAI — Behavior Trees & State Machines for Godot** — https://github.com/limbonaut/limboai/blob/HEAD/README.md — License: MIT-style, verified on the source page (license section points to the MIT license; demo art is separately CC-BY and is not needed here). What we would adapt: the behavior-tree and hierarchical-state-machine structure — blackboard variables, condition and action tasks, and state transitions — as the skeleton for per-creature patterns such as telegraph, attack, and recovery states. How it stays Abysmal-original: only the generic tree and state machinery is borrowed, with credit; every creature's states, tells, timings, and attacks are written fresh from the specs above, and no demo enemy, scene, or artwork is copied.
- **CodingQuests Enemy AI — shared state machine with telegraphed attacks** — https://store.godotengine.org/asset/codingquests/enemy-ai/ — License: MIT for the code, verified on the asset page. What we would adapt: the shared-state shape (idle, chase, telegraph, attack, recovery) and the readable-telegraph idea — a visible shape showing where an attack is about to land — which maps directly onto this file's wind-ups, dive lines, and glow tells for drakes, wyverns, golems, and elementals. How it stays Abysmal-original: the state names and telegraph concept are generic patterns, while Abysmal's enemy types, tells, and attack shapes are its own; the demo arena, sprites (separately CC0), and boss are not reused.
- **CodingQuests State Machine — node-based finite state machine** — https://store.godotengine.org/asset/codingquests/state-machine/ — License: MIT for the code, verified on the asset page. What we would adapt: the small node-per-state pattern with signal transitions and enter, exit, and update hooks, as a lightweight alternative for simpler creatures such as golems and brutes that need only a few states. How it stays Abysmal-original: only the tiny generic machine pattern is adapted, with credit; all creature states and transitions are designed from these specs, and the demo slime enemy is not copied.

