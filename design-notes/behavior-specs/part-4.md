# Behavior specs — The Undead, Celestials & the Fallen, Demons, Devils & the Damned

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
