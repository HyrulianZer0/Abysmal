# Behavior specs — Goblin-Kin & Cave Folk, Orcs, Trolls & Giant-Kin, Humans & the Damned Living

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
