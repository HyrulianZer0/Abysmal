# Behavior Catalog — Phase 1 (Abysmal)

**Status: DOC ONLY — Phase 1 resource-hunting reference for Phase 2 to build from.**
No code changed, no build, no APK, no release. Nothing here spawns, wires a
mechanic, or changes a stat.

**Credits:** Aethelwarden Solas only. Never James's real name.

**Sources (in priority order where they disagree):**

- `design-notes/monster-sourcing-notes.md` (Oct 27, 2026) — the 28-type staged
  set, its locked balance, and what is staged vs. future wiring.
- `scripts/enemy.gd` `TYPES` (Oct 27) — the one-line behavior text per staged
  type, quoted or closely paraphrased below. Staged base HP/ATK are **depth-1
  values and provisional stand-ins** (per the file's own comments), to be
  balanced by a soak before any type goes live.
- `design-notes/monster-roster-2026-10.md` — the ~300-base roster across
  28 families, with per-entry combat flavors.
- `design-notes/idle-ai-behavior-spec.md` — the idle delve AI, enemy facing /
  backstab, and the perception / trap rules that constrain ambusher and
  trapper behavior.
- `design-notes/apex-bosses-lore-strategies.txt` — the 16 apex bosses'
  folklore-rooted attack patterns (patterns only; see §5).
- `design-notes/morning-briefing-2026-10-11.md` (Oct 27 + Oct 29 entries) —
  Phase 1 is staged hunting + cataloging; Phase 2 builds, gated on
  verification. The Oct 27 staged state (3 live + 25 placeholders, spawn
  picker untouched) is unchanged by this document.

**How to read this catalog:** each archetype entry gives the staged
reference pattern first, then the general implementation shape Phase 2
builds from it, then tuning hooks, then which roster monsters/families
use it. Anything not grounded in a source above is marked **[OPEN]** —
it is a question for Phase 2 / James, not an assertion.

**Public-domain rule (from the roster paper):** folklore roots only. No lore,
design, or mechanic borrowed from other games. The roster's §2 exclusion
list (D&D Product Identity, Tolkien coinages, modern-game monsters, named
modern cryptids as characters, living authors' worlds) still applies to
every new behavior detail added in Phase 2.

---

## 1. Locked tuning framework (applies to every archetype)

From `scripts/main.gd` `_new_depth()` via the sourcing notes — do not
contradict these:

- `HP = base_HP × depth^1.2`
- `ATK = base_ATK × depth^1.05`
- `DEF stays FLAT at its base value at every depth.`

Depth-10 spot checks (from the sourcing notes; `HP × ≈15.85`, `ATK × ≈11.22`):

| Staged type | Base HP / ATK | Depth-10 HP | Depth-10 ATK |
|---|---|---|---|
| Pixie (frailest) | 7 / 4 | 111 | 45 |
| Troll (heaviest staged tank) | 48 / 7 | 761 | 79 |
| Clay Golem (existing) | 45 / 8 | 713 | 90 |
| Banshee | 22 / 9 | 349 | 101 |

**Per-archetype tuning hooks** (the numbers Phase 2 tunes; behavior-knob
values are **[OPEN]** — this catalog names the knobs, it does not set them):

- Universal: `base_hp`, `base_atk`, `def` (flat), spawn band + spawn weight
  **[OPEN]**, move speed, attack cooldown, wind-up duration, recovery
  duration, aggro / leash range **[OPEN]**.
- Archetype-specific knobs are listed per entry below (e.g. charge speed
  multiplier, venom DPS + duration, regen % max HP / s, scream radius,
  breath-cone angle + range, grapple hold duration + break-out rule,
  trap trigger radius + effect, dazzle duration + effect).
- Balance soak still required across depths 1–50 (sourcing notes §"Still
  missing"), especially D-band brutes/tanks at depth 10+.

**Cross-cutting combat rules Phase 2 must respect (already locked):**

- **Enemy facing + backstab** (idle-ai spec, Oct 7): enemies face travel
  direction, not the camera. Striking from behind the enemy's facing — or
  striking a sleeper — deals ×1.5 ("Backstab!"). Facing persists through
  save/load. This is why skirmisher / ambusher / charger positioning
  matters: flanking and rear attacks are a real reward, and a charger's
  slow turn after a miss is a real opening.
- **Idle AI threat order** (idle-ai spec, Oct 7): foes → doors → chests.
  The idle companion finishes a fight before going to loot, and
  "double checks" before opening a chest. Behavior patterns must assume
  the player (or idle AI) does not break off mid-fight to chase loot.
- **Perception / faint hints** (idle-ai spec, Oct 7, locked design):
  traps and hidden enemies are gated behind a perception check, but there
  must be a *very faint* visual hint even before perception reveals them
  fully. Subtle, not invisible. This constrains ambusher and trapper
  telegraphs: a hidden monster is never zero-signal.
- **Phone-first readability:** telegraphs must read at a glance on a
  phone screen. Wind-ups, dive lines, shadows, pawing, inhaling, and eye
  glow are the established readable tells (see entries below); a tell
  that only reads on a large monitor is a failed tell.

**Locked materials (the ONLY drop mappings stated here — everything else
stays blank for James to fill in, per the Oct 24 lock and the sourcing
notes):**

- Wolf → fur · Wild Boar → leather · Cave Spider → silk.
- Light leather from small beasts, heavy leather from large beasts
  (bears and their weight class) — a size-tier rule, not per-monster claims.
- Teeth/fangs as Undercrucible reagents: grind for damage + a status
  effect, or mount on weapons directly. Locked example: snake fangs,
  ground → damage + poison.
- No other material mapping is asserted in this catalog. Boss signature
  drops are likewise **[OPEN]** — see §5.

---

## 2. Archetype entries

### 2.1 Brawler

- **Staged reference:** Slime ("Wobbles forward and body-slams; no split
  mechanic staged"), Skeleton ("Shambles forward and chops; flat defense,
  honest bruiser").
- **Movement pattern:** steady ground advance toward the player, no
  retreat, no flanking, no flight. Slime wobbles; skeleton shambles.
  Speed is ordinary — the threat is persistence, not pace.
- **Attack pattern:** single close-range melee hit (body-slam / chop),
  repeated on cooldown once in range. No ranged option, no combo, no
  special rider in the staged pattern.
- **Telegraph / wind-up:** minimal — the approach itself is the tell.
  A short raise / squash-anticipation before the slam or chop is the
  Phase 2 readability hook **[OPEN: exact wind-up duration]**.
- **Special mechanic:** none staged. The roster's split-ooze idea (Amber
  Ooze "splits into lesser blobs when struck"; Primordial Ooze, tank /
  splitter) is a *roster flavor*, not a staged brawler mechanic —
  see §4, splitter **[OPEN]**.
- **Tuning hooks:** `base_hp`, `base_atk`, `def` (flat; skeleton 2, slime 0
  at depth 1 in the staged data), move speed, attack cooldown, wind-up
  duration.
- **Roster monsters / families:** Oozes & Slimes — Slime (T). The Undead —
  Skeleton (T). Brawler is the tutorial baseline: the two live, modeled
  types. No other roster entry carries the bare "brawler" flavor; heavier
  honest melee falls under brute (§2.2) instead.

### 2.2 Brute

- **Staged reference:** Orc ("Advances steadily and swings heavy overhead
  chops; slow windup, punishing if it connects"), Oni ("Slow, deliberate
  club work: raises the iron club high (the tell), then slams a wide arc;
  no rush, no retreat").
- **Movement pattern:** steady, deliberate advance. No retreat, no
  flanking dance. The oni explicitly does not rush and does not retreat;
  the orc advances steadily. Speed below skirmisher, above tank.
- **Attack pattern:** heavy overhead chop / wide club arc, single large
  hit per swing. Damage is the point; attack rate is low.
- **Telegraph / wind-up:** LONG and readable — the defining brute trait.
  Orc: slow windup before the chop. Oni: iron club raised high before the
  wide-arc slam. The wind-up is the dodge window; the recovery after a
  connected or missed swing is the punish window.
- **Special mechanic:** none beyond weight of hit. Double-strike variants
  (Ettin: "two heads, two attacks") and elemental riders (Frost Giant:
  brute / frost caster; Fire Giant: brute / fire) are roster flavors
  layered on the brute base **[OPEN: whether riders are separate
  archetype variants or attunement layers — see §4]**.
- **Tuning hooks:** `base_hp`, `base_atk`, `def` (flat; orc 1, oni 2 at
  depth 1 staged), wind-up duration, arc width / range, recovery duration,
  damage multiplier on a clean connect **[OPEN]**.
- **Roster monsters / families:** the Delve's heavy infantry, across many
  families — Orcs, Trolls & Giant-Kin (Orc, Orc Berserker as charger/brute,
  Half-Ogre, Ogre as brute/tank, Ettin double-strike, Cyclops as
  brute/ranged, Frost Giant, Ogre Mage as caster/brute, Fire Giant);
  Beasts (Giant Rat, Grizzly, Cave Ape, Lion as brute/pack, Cave Hyena);
  Goblin-Kin (Hobgoblin, Goblin Champion); The Undead (Barrow Wight,
  Draugr as tank/brute); Greek (Chimera as brute/multi-attack);
  Mesopotamian (Cedar Guardian, Ugallu, Mušḫuššu, Asag as brute/plague
  caster); South Asian (Yaksha as brute/guardian, Asura as brute/caster);
  Egyptian (Serpopard); Celtic (Bauchan, Fachan); Demons (Pit Brute,
  Shaitan as brute/caster); Abyssal (Titan, Star Horror); Norse
  (Great Wolf is charger/boss-tier, not a plain brute — see §5).

### 2.3 Tank

- **Staged reference:** Clay Golem ("Plods, absorbs hits, answers with a
  heavy slam").
- **Movement pattern:** slow plod toward the player. Never fast, never
  retreating. The tank's job is to be in the way and stay there.
- **Attack pattern:** infrequent heavy slam once in range. Low attack
  rate, high per-hit weight — but per the roster definition, "huge HP,
  low threat": the slam punishes standing still, it does not chase you
  down.
- **Telegraph / wind-up:** the plod + a raised-arm / heavy-slam wind-up.
  Readable because it is slow **[OPEN: exact wind-up / slam AoE radius]**.
- **Special mechanic:** absorption — high base HP + non-zero flat defense
  (golem: 45 HP / def 3 at depth 1 staged, the joint-heaviest staged
  profile with the troll). No regen in the plain tank pattern (regen is
  §2.18, tank/regen).
- **Tuning hooks:** `base_hp`, `base_atk`, `def` (flat — the tank's
  signature number), move speed (slow), slam cooldown, slam radius
  **[OPEN]**.
- **Roster monsters / families:** Golems & Constructs (Clay Golem, Living
  Statue, Haunted Armor as tank/brute, Stone Golem, Iron Golem, Crystal
  Golem as tank/caster); Oozes (Amber Ooze as tank/splitter, Mire Pudding,
  Primordial Ooze as tank/splitter boss-tier); Vermin (Emperor Scorpion
  as tank/venom, Carrion Worm); Beasts (Cave Bear as tank/brute,
  Crocodile as ambusher/tank); The Undead (Skeleton Knight, Mummy as
  tank/curse caster, Draugr as tank/brute, Gashadokuro as tank
  boss-tier); Greek (Nemean Lion); Japanese (Tsuchigumo as tank
  boss-tier); Slavic (Vodyanoy as aquatic tank); South Asian (Naga as
  caster/tank, Makara as aquatic tank); Chinese (Taotie as tank
  devourer, Hundun as tank/controller, Terracotta Soldier); Elementals
  (Water Elemental, Earth Elemental, Magma Elemental as fire/earth
  tank); Aquatic (Deep Crab, World Wurm as tank boss-tier); Humans
  (Fallen Knight as tank/brute); Plants (Fungal Shambler as tank/spore,
  Walking Oak); Mesopotamian (Lamassu as tank/caster guardian);
  Abyssal (Ashen Titan as tank boss-tier); Dragons (Wyrm as burrower
  tank, Tarasque as tank boss-tier).

### 2.4 Skirmisher

- **Staged reference:** Cave Frog ("Hops into range, tongue-lashes, hops
  back out"), Centipede ("Very fast and very low; weaves side to side so
  it is hard to lead, but folds to a single solid hit").
- **Movement pattern:** fast in-and-out. Hop in, strike, hop out
  (frog); or continuous low weaving that makes leading the target hard
  (centipede). Never stands in range trading blows. Ground-based, unlike
  flyer/skirmisher (§2.7).
- **Attack pattern:** light, fast, single-target strike (tongue-lash /
  bite), then disengage. Damage per hit is low; the threat is tempo —
  it hits while you are still turning to face it.
- **Telegraph / wind-up:** short — a hop crouch / weave commit is the
  only tell. The counter is prediction (lead the weave; strike during
  the hop's landing) rather than reacting to a long wind-up.
- **Special mechanic:** fragility as balance: the centipede "folds to a
  single solid hit" despite its speed. High evasion-by-motion, low HP.
- **Tuning hooks:** `base_hp` (low), `base_atk`, `def` (flat, 0 staged),
  move / hop speed, weave amplitude + frequency **[OPEN]**, in-range
  dwell time before disengaging **[OPEN]**, attack cooldown.
- **Roster monsters / families:** Vermin & Cave Crawlers (Centipede,
  Cave Frog; Mercury Slime as skirmisher among Oozes); The Undead
  (Ghoul); Goblin-Kin (Redcap as skirmisher-speed); Norse (Dark Elf as
  skirmisher/caster); Egyptian (Jackal Guardian, Sha Beast); South
  Asian (Piśāca); Fey (Bramble Imp as plant skirmisher, Faun, Brownie);
  Chinese (Mogwai as skirmisher/caster); Demons (Possessed Cultist as
  caster/skirmisher, Incubus as skirmisher/caster); Plants (Thornhound);
  Aquatic (Drowned Sailor as undead skirmisher, Selkie as aquatic
  skirmisher); Humans (Brigand); Slavic (Domovoi); Elementals (Gnome as
  earth skirmisher, Salamander as fire skirmisher); Celtic (Cat Sìth
  as ambusher skirmisher, Tokoloshe as ambusher skirmisher — see §2.14
  for the ambusher half).

### 2.5 Charger

- **Staged reference:** Wild Boar ("Paws the ground and snorts as a
  telegraph, then charges in a straight line; slow to turn after a miss").
- **Movement pattern:** two-phase — a stationary telegraph phase, then
  a fast straight-line rush. Cannot steer mid-charge in the staged
  pattern. After a miss, slow to turn: the charger must re-orient before
  it can charge again, which is the punish window.
- **Attack pattern:** the charge itself is the attack (gore / impact on
  contact along the line). No follow-up combo in the plain charger
  pattern; charger/brute (§3.5) adds horn swipes after the charge.
- **Telegraph / wind-up:** EXPLICIT and readable by design — pawing the
  ground + snorting. Phase 2 must keep a distinct, audible + visual
  telegraph phase before every charge; a charger with no tell is a
  failed charger.
- **Special mechanic:** straight-line commitment. Wall / obstacle impact
  behavior is **[OPEN: stun on wall impact? damage on impact? — not
  staged]**.
- **Tuning hooks:** telegraph duration, charge speed multiplier, charge
  range / distance, turn-recovery duration after a miss, contact damage
  (uses scaled ATK), charge cooldown **[OPEN values]**.
- **Roster monsters / families:** Beasts (Wild Boar, Warhound, Crag Ram,
  Deep Stag, Grotto Bull as charger/brute, Razorback as charger/brute,
  Pale Horse); Vermin (Stag Beetle); The Undead (Jiangshi as
  charger/tank, Revenant as relentless charger, Dullahan as
  charger/caster); Greek (Hellhound as pack charger, Centaur as
  ranged/charger, Bronze Bull as charger/fire); Japanese (Ōmukade as
  charger/brute); Celtic (Kelpie as aquatic charger); Chinese (Xiezhi,
  Qilin Corrupted as charger/caster); Norse (Great Wolf as charger
  boss-tier — see §5 Fenrir); Greek/Norse dragons (Jaculus as
  flyer/charger, Wyvern as flyer/venom charger); Humans (Berserker as
  charger/brute); Mesopotamian (Galla); Dragons (Sea Serpent as aquatic
  charger); Fey-adjacent (Sabertooth as ambusher/charger — see §2.14).

### 2.6 Flyer (pure)

- **Staged reference:** NONE. Every staged flyer is a compound archetype
  (flyer/skirmisher, flyer/caster, flyer/swarm, flyer/brute — see §§2.7,
  2.8, 3.1, 3.6). There is no staged monster whose archetype is bare
  "flyer".
- **Movement pattern (inferred from the compound flyers, [OPEN] as a
  standalone):** sustained airborne movement; never lands (bat pattern).
  Height / hover band **[OPEN]**. Ground melee cannot reach it except
  during a dive or perch — which is why every staged flyer pairs flight
  with a second archetype that defines what it does when it comes down
  or casts.
- **Attack pattern:** **[OPEN as a standalone]** — in practice, flyers
  attack via their compound half (dive-rake, bolt, sting).
- **Telegraph / wind-up:** the dive line (harpy), the perch / hover
  pause (imp, pixie), the swoop commit (drake) — see the compound entries.
- **Special mechanic:** altitude as partial immunity to ground melee and
  to ground-based hazards **[OPEN: exact melee-reach vs. altitude rule]**.
- **Tuning hooks:** hover height, dive speed, perch duration, climb-away
  speed **[OPEN]**.
- **Roster monsters / families (bare "flyer" flavor):** Elementals (Air
  Elemental — "flyer (fast)"); Dragons (Amphiptere — winged serpent).
  Every other roster flyer carries a compound flavor (flyer/skirmisher,
  flyer/caster, flyer/swarm, flyer/brute, flyer/ranged, flyer/tank,
  flyer/ambusher, flyer/storm caster, etc.) and is cataloged under its
  compound entry. **Gap note:** Phase 2 should decide whether bare
  "flyer" remains a real archetype or is retired in favor of always
  pairing flight with a combat role **[OPEN]**.

### 2.7 Flyer / skirmisher

- **Staged reference:** Cave Bat ("Darts in, bites, retreats; never
  lands"), Harpy ("Circles overhead shrieking, then dive-rakes with
  talons and climbs away; the dive line is the tell").
- **Movement pattern:** airborne circling / darting at height, then a
  committed dive into melee range, then an immediate climb-away. Never
  lands, never stays in reach. The bat darts; the harpy circles first,
  which is a longer, more readable setup.
- **Attack pattern:** bite (bat) / talon dive-rake (harpy) — one fast
  melee hit per dive, then disengage. Like ground skirmisher (§2.4) but
  the disengage is vertical.
- **Telegraph / wind-up:** the dive line itself (harpy — explicitly "the
  dive line is the tell") and the circling / shrieking setup. The bat's
  dart is shorter-telegraphed; the harpy's circle is the readable version.
- **Special mechanic:** vertical disengage — after the strike it is out
  of ground-melee reach until the next dive. Backstab (§1) applies on
  the dive approach if the player gets behind its facing.
- **Tuning hooks:** circle / setup duration, dive speed, dive-line
  visibility, climb-away speed, time between dives **[OPEN]**.
- **Roster monsters / families:** Vermin (Cave Bat); Greek (Harpy);
  Fey (Sprite as flyer skirmisher); Sky & Storm (Storm Crow is
  flyer/swarm — see §3.1); plus flyer-adjacent skirmishers whose second
  flavor is ambush or lifedrain (Sasabonsam as flyer/ambusher, Death Bat
  as flyer/lifedrain — see §§2.14, 4).

### 2.8 Flyer / caster

- **Staged reference:** Imp ("Erratic hovering flight; lobs small fire
  bolts from odd angles, then flits to a new perch"), Pixie ("Tiny, fast,
  and annoying by design: dazzles, darts, and nicks; folds to any clean
  hit. Dazzle is future wiring").
- **Movement pattern:** erratic hovering flight between perches. The
  imp flits perch-to-perch; the pixie darts. Neither lands to fight
  hand-to-hand. Movement is deliberately hard to track (erratic angles).
- **Attack pattern:** ranged spell / bolt from the air (imp fire bolts),
  plus a nuisance rider (pixie dazzle + nick). Low per-hit damage, high
  annoyance / disruption. The pixie folds to any clean hit — fragility
  is the balance for its disruption.
- **Telegraph / wind-up:** the perch pause before a bolt volley (imp);
  the dazzle flash itself (pixie) **[OPEN: dazzle effect — blind?
  miss chance? duration? — future wiring, not staged]**.
- **Special mechanic:** dazzle (pixie) — effect undefined, see above.
  Fire bolts (imp) are the staged caster half: small, lobbed, from odd
  angles, i.e. not a straight-line duel.
- **Tuning hooks:** perch duration, bolts per volley, bolt speed /
  spread, dazzle duration + effect **[OPEN]**, reposition speed,
  `base_hp` (pixie 7 at depth 1 staged — the frailest staged type).
- **Roster monsters / families:** Demons (Imp); Fey (Pixie, Sylph as
  flyer caster); Japanese (Tengu as flyer/caster, Nue as flyer/caster);
  Greek (Stymphalian Bird is flyer/ranged — see §2.10); Mesopotamian
  (Anzu as flyer/caster — apex, see §5); Chinese (River Long as
  flyer/caster); South Asian (Garuda as flyer/charger); Sky & Storm
  (Phoenix as flyer/fire caster with rebirth, Thunderbird as
  flyer/storm caster, Simurgh as flyer/caster, Firebird as flyer/fire
  caster); Celestials (Seraph as flyer/caster, Fallen Angel as
  flyer/brute/caster); Abyssal-adjacent (Fallen Valkyrie as
  flyer/brute/caster).

### 2.9 Caster

- **Staged reference:** Banshee ("Floats at range and wails: an area
  scream with a long windup, then drifts to a new vantage; AoE is future
  wiring").
- **Movement pattern:** holds range, floats / drifts. After casting, drifts
  to a new vantage — it does not stand still to be rushed, but it does
  not close to melee either.
- **Attack pattern:** area-effect spell at range (the wail / scream).
  No melee pattern in the staged caster; if closed on, the expected
  response is drift-away, not a melee combo **[OPEN: exact flee vs.
  fight response when cornered]**.
- **Telegraph / wind-up:** LONG windup before the scream — the defining
  caster tell. The long windup is the interrupt / escape window, and the
  drift-after-cast is the repositioning that prevents camping one spot.
- **Special mechanic:** AoE scream — radius, falloff, and whether it
  damages, staggers, fears, or debuffs are all future wiring
  **[OPEN: radius, damage vs. stagger vs. fear split, line-of-sight
  rule]**. Do not assume a damage-only scream; the roster's banshee
  flavor is "caster (AoE scream)" and the lore root is a death-messenger
  whose wail is the weapon.
- **Tuning hooks:** wind-up duration, scream radius + falloff, scream
  cooldown, drift distance + speed after casting, `base_hp` / `base_atk`
  (banshee 22 / 9 at depth 1 staged — high ATK for a caster, which is
  why the long windup matters).
- **Roster monsters / families:** The Undead (Banshee; Mummy as tank/curse
  caster; Vetala as caster/possessor; Lich as caster boss-tier; Wight
  Lord as brute/caster); Goblin-Kin (Goblin Shaman as caster/support);
  Orcs (Orc Shaman); Greek (Siren is controller/lure, Sphinx is
  caster/controller, Lamia — see §4 controller); Japanese (Kitsune as
  caster/illusion, Jorōgumo as caster/ambusher, Chōchin-obake);
  Slavic (Kikimora as ambusher/caster, Alkonost as caster/controller,
  Gamayun as caster/support, Mora as phase caster, Bean-nighe as
  caster/omen debuffs); South Asian (Naga as caster/tank, Rakshasa as
  shapeshifter/caster/brute); Chinese (Hulijing as caster/illusion);
  Mesoamerican (Storm Wraith as storm caster, Tzitzimitl as caster
  boss-tier); African (Mami Wata as aquatic caster); Fey (Dryad as
  plant caster, Naiad as aquatic caster, Elder Dryad as caster/tank);
  Demons (Possessed Cultist as caster/skirmisher, Djinn, Contract Devil
  as caster/controller, Warlock, Necromancer as caster/support);
  Celestials (Deva, Null Seraph, The Hollow Choir as caster/swarm);
  Elementals (Fire Elemental as fire caster/brute, Undine as water
  caster, Storm Elemental, Frost Elemental); Plants (Mandrake as caster
  scream — a stationary scream variant, see §4); Humans (Cultist,
  Witch as caster/controller); Norse (Nixie as aquatic caster, Hulder
  as controller/caster, Mare as phase caster/sleep).

### 2.10 Ranged

- **Staged reference:** Skeleton Archer ("Holds distance and looses
  arrows; steps back when closed on, never charges").
- **Movement pattern:** distance-keeping. Holds a preferred range band;
  steps back when the player closes. Never charges, never closes to
  melee voluntarily.
- **Attack pattern:** projectile volleys (arrows) from range. Single
  projectile type in the staged pattern; alchemical / spine / feather
  variants are roster flavors (see below).
- **Telegraph / wind-up:** draw / aim pause before loosing
  **[OPEN: draw duration, projectile speed, arc vs. straight]**.
  The skeleton archer's bow sound (bow twang + arrow whistle) is marked
  PROCEDURAL in the staged data — no file staged.
- **Special mechanic:** kiting — the step-back response is the mechanic.
  If cornered with no step-back room, behavior is **[OPEN]**.
- **Tuning hooks:** preferred range band (min / max), step-back distance
  + speed, draw duration, projectile speed + damage (scaled ATK),
  volley size + cooldown **[OPEN]**.
- **Roster monsters / families:** The Undead (Skeleton Archer); Greek
  (Centaur as ranged/charger, Stymphalian Bird as flyer/ranged,
  Manticore as ranged/flyer); Norse (Alfar Raider, Cyclops as
  brute/ranged with thrown boulders); Mesopotamian (Scorpion Man as
  ranged/tank); Humans (Mad Alchemist as ranged/alchemical); plus
  projectile-adjacent casters whose "ranged" is spell-based rather than
  weapon-based (cataloged under §2.9, not here).

### 2.11 Grappler

- **Staged reference:** Kappa ("Waddles in behind its shell, grabs and
  drags, then wrestles at close range; grapple is future wiring, posture
  is staged"). The grappler/tank compound is §3.7; this entry covers the
  grappler half.
- **Movement pattern:** slow waddle-in behind a defensive posture
  (shell). Closes to contact range deliberately; does not dart or charge.
- **Attack pattern:** grab → drag → wrestle at close range. The grab is
  the attack; the wrestle is sustained close-range damage / control
  while held. No strike combo in the staged pattern.
- **Telegraph / wind-up:** the waddle-in + reach-out before the grab
  **[OPEN: grab telegraph duration, grab range, grab vs. block/dodge
  interaction]**.
- **Special mechanic:** grapple hold — hold duration, damage-while-held,
  break-out rule (mash? timed? damage threshold? ally interrupt?),
  and what the player can / cannot do while held are ALL future wiring
  **[OPEN — nothing staged]**. This is one of the largest unwired
  mechanics in the catalog (see §6 gaps).
- **Tuning hooks:** grab range, grab telegraph, hold duration, hold DPS,
  break-out threshold, drag distance + speed **[OPEN values]**.
- **Roster monsters / families:** Japanese (Kappa as grappler/tank);
  Plants (Vampire Vine as grappler/ambusher); Aquatic (Giant Octopus
  as grappler/tank — "eight arguments, all grapples"); Mesoamerican
  (Ahuizotl as aquatic ambusher with a grabbing tail-hand —
  grappler-adjacent **[OPEN: confirm as grappler or ambusher-only]**).
  No other roster entry carries the grappler flavor explicitly.

### 2.12 Trapper

- **Staged reference:** Kobold ("Darts between cover, jabs with a spear,
  and flees toward its pack; trap-setting is future wiring, not staged").
  The trapper/swarm compound is §3.4; this entry covers the trapper half.
- **Movement pattern:** dart between cover, jab, flee toward its pack.
  Cover-to-cover movement, never a stand-up fight. The trapper's
  positioning is the setup for its traps: it wants you to chase it.
- **Attack pattern:** spear jab at close range, then immediate retreat.
  The jab is light; the trap is the real damage. Trap types, trigger
  rules, and trap damage are future wiring.
- **Telegraph / wind-up:** the flee-toward-pack movement is itself a
  lure tell; placed traps must follow the perception rule (§1) — a very
  faint hint even before perception reveals them **[OPEN: trap visual
  hint design, trap trigger radius, trap arming time]**.
- **Special mechanic:** traps — type(s), placement rule (pre-placed vs.
  placed during combat), trigger (proximity? pressure? trip?), effect
  (damage? root? slow?), disarm rule, and whether traps persist after
  the kobold dies are ALL **[OPEN — nothing staged beyond the word
  "trap-setting"]**.
- **Tuning hooks:** trap count / placement cooldown, trigger radius,
  trap damage / effect duration, disarm check **[OPEN values]**.
- **Roster monsters / families:** Goblin-Kin (Kobold — the ONLY roster
  entry with the explicit "trapper" flavor). Trap-adjacent roster
  patterns (not labeled trapper): Japanese (Jorōgumo as caster/ambusher
  — a web-trap by folklore logic, but the roster flavor does not say
  "trapper" **[OPEN: confirm]**); Plants (Grotto Snapper as stationary
  ambusher — a disguised jaw, not a placed trap); Celtic (Kelpie as
  aquatic charger — a lure, not a trap). **Gap note:** trapper is the
  thinnest archetype in the catalog — one staged monster, one roster
  entry, zero wired mechanics (see §6).

### 2.13 Swarm / swarmer

- **Staged reference:** Cave Rat ("Darts in numbers; quick nips, then
  breaks off"). The swarm compounds (flyer/swarm, skirmisher/swarm,
  tank/swarm, trapper/swarm) are §3; this entry covers the swarm half.
- **Movement pattern:** many bodies, fast darts, constant repositioning.
  Individuals do not hold ground; the swarm's shape is the threat.
  Presentation note from the roster: Rat Swarm is "one HP bar, forty
  bodies (presentation)" — a swarm may be one mechanical entity with a
  swarm presentation, or many weak entities **[OPEN: per-type choice]**.
- **Attack pattern:** quick nips from many angles, then break-off.
  Individual damage is trivial; aggregate damage while surrounded is
  the threat.
- **Telegraph / wind-up:** minimal per-individual; the swarm's approach
  / massing is the tell **[OPEN: massing cue design]**.
- **Special mechanic:** numbers — spawn count, respawn / reinforcement
  rule, and whether killing individuals thins the swarm's damage are
  **[OPEN]**. The roster's Horde Lord rank ("spawns with a pack") and
  Young stature ("swarm-spawned") interact here **[OPEN: interaction
  with rank/stature system]**.
- **Tuning hooks:** individual `base_hp` / `base_atk` (rat 10 / 3 at depth 1
  staged — low), spawn count, nip cooldown, break-off distance
  **[OPEN]**.
- **Roster monsters / families:** Vermin (Cave Rat, Rat Swarm,
  Scarab Swarm); Beasts (Baboon Troop as swarm/skirmisher); Demons
  (Larva of the Damned); The Undead (Sluagh as flyer/swarm); Sky
  (Storm Crow as flyer/swarm); Plants (Spore Servant as swarm/caster);
  plus every compound swarm (goblin, zombie, kobold, wasp — see §3).

### 2.14 Ambusher

- **Staged reference:** Cave Spider ("Wall-clings above the path, drops
  on prey, venom bite (venom rider is future wiring, not a staged
  mechanic)"), Giant Serpent ("Lies coiled in cover, lunges, then
  re-coils; constrict flavor only").
- **Movement pattern:** stationary hidden wait (wall-cling above the
  path / coiled in cover), then a single explosive entry (drop / lunge),
  then either sustained fight (spider) or re-coil to wait again (serpent).
  The serpent's re-coil is the distinctive loop: strike, withdraw, wait,
  strike again.
- **Attack pattern:** first-strike burst — the drop / lunge hit, with
  the spider adding a venom bite rider (future wiring) and the serpent
  adding constrict flavor only (not a staged hold — contrast grappler,
  §2.11).
- **Telegraph / wind-up:** the perception rule (§1) governs this entire
  archetype: a very faint hint before perception reveals the ambusher
  (spider silhouette above the path; serpent coil in cover), then the
  drop / lunge commit itself. An ambusher with zero pre-signal violates
  the locked design. Post-first-strike, the serpent's re-coil is itself
  a readable reset.
- **Special mechanic:** hidden-state + first-strike bonus **[OPEN:
  first-strike damage multiplier? guaranteed? — not staged]**. Venom
  rider (spider) is future wiring (see §2.17). Constrict (serpent) is
  flavor only, not a hold mechanic.
- **Tuning hooks:** hidden-state detection radius, perception threshold
  **[OPEN]**, drop / lunge speed + range, first-strike multiplier
  **[OPEN]**, re-coil delay + re-hide time (serpent) **[OPEN]**.
- **Roster monsters / families:** Vermin (Cave Spider as ambusher/venom,
  Widow Spider as venom/ambusher, Burrow Worm, Cave Jelly as ambusher
  among Oozes); Beasts (Giant Serpent, Panther, Tiger, Sabertooth as
  ambusher/charger, Cave Python as tank/ambusher, Crocodile as
  ambusher/tank, Blind Mole); Goblin-Kin (Goblin Sneak, Bugbear as
  ambusher/brute, Boggart); Japanese (Karakasa, Jorōgumo as
  caster/ambusher, Nure-onna as aquatic ambusher); Celtic (Cat Sìth
  as ambusher skirmisher, Tokoloshe as ambusher skirmisher); African
  (Sasabonsam as flyer/ambusher); Mesoamerican (Ahuizotl as aquatic
  ambusher); Aquatic (Cave Moray, Lanternjaw); Golems (Gargoyle as
  flyer/ambusher — sleeps as stone, then moves); Plants (Grotto Snapper
  as stationary ambusher, Vampire Vine as grappler/ambusher, Corpse
  Flower as stationary controller); Humans (Grave Robber); Abyssal
  (Living Shadow as phase ambusher, Penanggalan as flyer/ambusher);
  Fey (Changeling as shapeshifter ambusher — see §4).

### 2.15 Pack skirmisher

- **Staged reference:** Cave Wolf ("Circles and harries; pack bursts
  when numbers join it").
- **Movement pattern:** circling + harrying — orbits the player at
  mid-range, darting in for nips, never committing alone. The circle
  tightens / the tempo rises as pack numbers join.
- **Attack pattern:** harrying nips solo; "pack bursts" when numbers
  join — a coordinated multi-wolf attack window. Solo wolf = skirmisher
  tempo; pack wolf = burst threat.
- **Telegraph / wind-up:** the circling formation + pack convergence
  is the tell for a burst **[OPEN: burst trigger — pack size threshold?
  timer? — not staged]**.
- **Special mechanic:** pack scaling — how damage / burst frequency
  scales with alive pack members is future wiring **[OPEN]**.
- **Tuning hooks:** circle radius + speed, nip cooldown, pack-burst
  trigger threshold, burst damage multiplier, pack size (spawn count)
  **[OPEN values]**; `base_hp` / `base_atk` (wolf 22 / 7 at depth 1 staged).
- **Roster monsters / families:** Beasts (Wolf, Hyena, Dire Wolf as
  pack brute, Lion as brute/pack); Greek (Hellhound as pack charger —
  the pack pattern with a charge attack; Cerberus is the apex form,
  §5); Plants (Thornhound is a single skirmisher, not pack — do not
  confuse with pack hounds); plus pack-adjacent troop patterns
  (Baboon Troop as swarm/skirmisher — swarm, not pack, see §2.13).

### 2.16 Phase skirmisher

- **Staged reference:** Wraith ("Drifts through positioning and
  phase-strikes; no footsteps, no cover respect").
- **Movement pattern:** drift (not walk, not fly — float) through
  positioning: ignores cover and, by the staged text, does not respect
  the positioning rules other monsters obey. No footsteps (no audio
  footstep cue to track it by).
- **Attack pattern:** phase-strike — a fast strike delivered from the
  drift, then drift-away. Skirmisher tempo (§2.4) with phase movement.
- **Telegraph / wind-up:** drift commit + materialization shimmer
  **[OPEN: visibility rule — always faintly visible? fully invisible
  between strikes? — not staged]**. The "no footsteps" note means audio
  cannot be the tell; the visual drift must carry it.
- **Special mechanic:** phase — exactly what phase ignores (walls?
  cover? player attacks? traps?) and whether the wraith is hittable
  mid-drift are ALL future wiring **[OPEN — the staged text says "no
  cover respect" for its own movement; it does not say it is
  untargetable]**.
- **Tuning hooks:** drift speed, phase-strike cooldown, visibility /
  materialization duration, strike damage (wraith ATK 8 at depth 1
  staged — high for a skirmisher, balanced by HP 15) **[OPEN values]**.
- **Roster monsters / families:** The Undead (Wraith as the staged name
  for the generic shade; Specter as phase skirmisher, Phantom as phase);
  South Asian (Bhūta as phase); Norse (Mare as phase caster/sleep,
  not a pure phase skirmisher); Slavic (Mora as phase caster); Abyssal
  (Living Shadow as phase ambusher, Entropy Wraith as phase caster);
  plus phase-adjacent casters cataloged under §2.9.

### 2.17 Venom skirmisher

- **Staged reference:** Cave Scorpion ("Sidesteps to flank, snaps with
  claws, then tail-stings; venom rider is future wiring, not a staged
  mechanic").
- **Movement pattern:** sidestep-to-flank — lateral movement to reach
  the player's side / rear (where backstab geometry, §1, cuts both
  ways), then strike. Skirmisher tempo with a flanking bias, distinct
  from the frog's hop-in/hop-out and the centipede's weave.
- **Attack pattern:** two-stage — claw snap(s) first, then the tail-sting
  as the venom delivery. The sting is the payload; the claws are the
  setup. This two-stage order matters for Phase 2: interrupting or
  dodging the sting specifically should negate the venom even if the
  claws landed **[OPEN: confirm as design intent]**.
- **Telegraph / wind-up:** the sidestep + tail raise before the sting
  **[OPEN: tail-raise duration]**.
- **Special mechanic:** venom DoT — damage per tick, duration, stack
  rule, cleanse / resistance interaction are ALL future wiring
  **[OPEN]**. The only locked venom-adjacent fact is the reagent rule:
  snake fangs, ground → damage + poison (Undercrucible, §1) — that is
  a crafting rule, not the combat DoT's numbers.
- **Tuning hooks:** flank sidestep speed, claw damage (scaled ATK),
  sting cooldown, venom DPS, venom duration, venom stack cap + refresh
  rule, cleanse availability **[OPEN values]**; `base_hp` / `base_atk` /
  `def` (scorpion 16 / 5 / 1 at depth 1 staged).
- **Roster monsters / families:** Vermin (Cave Scorpion, Emperor
  Scorpion as tank/venom — the tank half is §2.3, the venom half is
  here; Widow Spider as venom/ambusher; Cave Spider as ambusher/venom);
  Egyptian (Asp as venom skirmisher, Guardian Scorpion as tank/venom);
  Dragons (Wyvern as flyer/venom charger, Basilisk as
  controller/venom); plus venom-adjacent breath / spit patterns whose
  venom is area-based rather than sting-based (Fafnir / Jörmungandr
  poison breath / spray — apex, §5; Echidna venom spit pools — apex,
  §5). Combat venom DoT numbers for any of these are **[OPEN]**.

### 2.18 Tank / regen

- **Staged reference:** Troll ("Hunched wall that lumbers in and swats;
  slow regeneration flavor (regen rate is future tuning, not staged)").
- **Movement pattern:** lumbering advance — slower than plain tank
  (§2.3) in feel ("hunched wall that lumbers"), same never-retreat shape.
- **Attack pattern:** swat — a wide, heavy, low-rate melee hit. Less
  formal than the golem's slam; the troll's threat is outlasting, not
  out-hitting.
- **Telegraph / wind-up:** the lumber + swat wind-up
  **[OPEN: wind-up duration, swat arc]**.
- **Special mechanic:** regeneration — rate formula is the named
  tuning hook and is explicitly future tuning, not staged. The hook
  shape Phase 2 tunes is: `regen_per_second = [OPEN coefficient] ×
  max_HP` (scaled HP, so regen scales with depth via the HP curve) vs.
  a flat `regen_per_second = [OPEN value]`, plus interrupt rules
  (does damage pause regen? does fire interrupt it? — folklore trolls
  vary; our troll's rule is **[OPEN]** — do not import another game's
  fire/acid rule without James's say-so).
- **Tuning hooks:** regen coefficient / flat rate, regen tick interval,
  regen interrupt / pause rule, `base_hp` / `base_atk` / `def`
  (troll 48 / 7 / 2 at depth 1 staged — the heaviest staged HP).
- **Roster monsters / families:** Orcs, Trolls & Giant-Kin (Troll,
  Marsh Troll as regen/ambusher, Cave Troll as tank/regen); Greek
  (Hydra as regen tank boss-tier — heads regrow, which is a regen
  variant with a head-count mechanic, not plain HP regen **[OPEN:
  head-regrow rule]**); plus regen-adjacent apex patterns (Phoenix
  rebirth — a full revive, not regen; Yamata no Orochi drunken stagger
  — a slow window, not regen; see §5).

---

## 3. Composite archetypes in the staged set

These staged archetype strings combine two §2 archetypes. Phase 2
implements them by composing the two halves below, not by inventing a
third pattern. Each composite's staged monster is its reference.

### 3.1 Flyer / swarm — Cave Wasp

- Pattern: "Hovers, dive-stings, repositions; never stays in reach."
  Flyer/skirmisher dive tempo (§2.7) + swarm numbers (§2.13), with a
  sting instead of a bite/rake. Individuals are frail (9 HP at depth 1
  staged); the threat is many dive-stings from many angles.
- Tuning hooks: §2.7 dive knobs + §2.13 spawn-count knobs; sting vs.
  bite damage split **[OPEN]**.
- Roster: Vermin (Cave Wasp); also Hornet Matriarch as flyer/support
  (summons) — a swarm-leader variant, not a plain flyer/swarm (§4).

### 3.2 Skirmisher / swarm — Goblin

- Pattern: "Cowardly alone, brave in numbers; hit-and-run stabs."
  Skirmisher hit-and-run (§2.4) gated by a courage rule: solo goblin
  behavior differs from pack goblin behavior (retreat / hesitation solo,
  committed stabs in numbers).
- Tuning hooks: §2.4 skirmisher knobs + courage threshold (allied count
  at which behavior flips) **[OPEN]**.
- Roster: Goblin-Kin (Goblin); Beasts (Baboon Troop as swarm/skirmisher
  — the same composition, reversed emphasis).

### 3.3 Tank / swarm — Zombie

- Pattern: "Slow, tireless advance; grabs and bites; numbers over speed."
  Tank HP + advance (§2.3, slower, lower per-hit threat) + swarm numbers
  (§2.13). The grab-and-bite is a sustained close-range attack, not a
  grapple hold (contrast §2.11 — zombie grab has no staged hold rule).
- Tuning hooks: §2.3 tank knobs + §2.13 spawn-count knobs; grab damage
  vs. bite damage split **[OPEN]**.
- Roster: The Undead (Zombie); also Sluagh-adjacent mass-undead
  (flyer/swarm, §3.1) and Larva of the Damned (plain swarm, §2.13).

### 3.4 Trapper / swarm — Kobold

- Pattern: "Darts between cover, jabs with a spear, and flees toward its
  pack; trap-setting is future wiring, not staged." Trapper (§2.12) +
  swarm numbers (§2.13). The pack is both the trapper's audience and its
  retreat destination.
- Tuning hooks: §2.12 trapper knobs + §2.13 spawn-count knobs.
- Roster: Goblin-Kin (Kobold — only trapper entry, see §2.12 gap note).

### 3.5 Charger / brute — Minotaur

- Pattern: "Paws and bellows as a telegraph, gore-charges down corridors,
  then follows with horn swipes in the open." Charger (§2.5) + brute
  (§2.2): the charge is the entry, the horn swipes are the follow-up
  once the charge ends (especially in open ground where a second charge
  has no corridor to run down).
- Tuning hooks: §2.5 charge knobs + §2.2 brute wind-up / arc knobs;
  corridor-vs-open behavior switch rule **[OPEN]**.
- Roster: Greek (Minotaur); Beasts (Razorback, Grotto Bull as
  charger/brute); Vermin/Japanese (Ōmukade as charger/brute); Humans
  (Berserker as charger/brute).

### 3.6 Flyer / brute — Drake

- Pattern: "Swoops low, breathes a short cone of fire, then climbs to
  reposition; the inhale before the breath is the tell." Flyer movement
  (§2.6/§2.7 swoop shape) + brute weight (§2.2) + a breath-cone special
  (below). The drake does not dive-rake like the harpy; it swoops and
  breathes, then climbs.
- Breath cone (future wiring): cone angle, range, linger / ground-fire
  duration, and damage-vs.-burn-DoT split are **[OPEN]**. The inhale
  before the breath is the locked tell shape.
- Tuning hooks: swoop speed + height, inhale (wind-up) duration, cone
  angle + range, breath cooldown, climb-away speed **[OPEN values]**.
- Roster: Dragons (Drake); plus breath-adjacent roster entries whose
  breath is a variant (Bronze Bull as charger/fire, Hellhound
  fire-breath by folklore, Chimera multi-attack — each **[OPEN: cone vs.
  line vs. pool]**).

### 3.7 Grappler / tank — Kappa

- This is the staged kappa's full archetype string; the grappler half
  is §2.11 and the tank half is §2.3. Pattern: "Waddles in behind its
  shell, grabs and drags, then wrestles at close range." The shell is
  the tank presentation (def 2 at depth 1 staged); the grab-drag-wrestle
  is the grappler mechanic (future wiring, §2.11).
- Tuning hooks: §2.11 grappler knobs + §2.3 tank knobs.
- Roster: Japanese (Kappa); Aquatic (Giant Octopus as grappler/tank).

---

## 4. Roster flavors with no staged implementation reference

These roster flavors exist in `monster-roster-2026-10.md` but have NO
staged monster and NO staged behavior text. They are listed so Phase 2
does not mistake "in the roster" for "has a reference implementation."
Each needs a design decision before build; each is **[OPEN]**.

- **Controller (gaze, lure, root, fear, sleep, petrify):** Gorgon
  (petrify gaze), Basilisk (petrify gaze / venom), Cockatrice (slow
  statue-gaze), Siren / Rusalka / Alkonost (lure song), Poltergeist
  (ranged debris control), Sphinx (caster/controller), Leshy (path
  scrambling), Will-o'-wisp (path-lure), Succubus (controller/caster),
  Contract Devil (caster/controller), Ophanim / Watcher
  (controller/caster), Plague Bearer (disease aura), Corpse Flower
  (stationary controller), Mare (sleep), Yuki-onna (frost
  controller), Bean-nighe (omen debuffs). Gaze/petrify timing,
  cure, and resistance rules are **[OPEN]** — the apex Medusa entry
  (§5) gives the pattern shape (telegraphed eye-glow → slow → stone-hold)
  but no numbers.
- **Support (buffs / summons allies):** Goblin Shaman (caster/support),
  Gamayun (caster/support), Necromancer (caster/support, summons),
  Hornet Matriarch (flyer/support, summons), Echidna's Brood Call
  (apex, §5). Summon caps, summon duration, and buff magnitudes are
  **[OPEN]**.
- **Lifedrain:** Gloom Ooze, Vampire Bat, Vampire, Strigoi, Adze,
  Death Bat, Null Seraph attunement-adjacent. Drain fraction (damage
  dealt → HP restored) is **[OPEN]**.
- **Splitter:** Amber Ooze, Primordial Ooze ("splits into lesser blobs
  when struck"). Split count, split HP fraction, split chain depth are
  **[OPEN]** — and note the staged slime explicitly does NOT split
  ("no split mechanic staged").
- **Def-shredder:** Acid Blob ("eats armor defense"). Shred amount,
  duration, stack rule vs. flat defense are **[OPEN]**.
- **Shapeshifter:** Púca, Empusa, Bake-danuki, Rakshasa, Nagual,
  Changeling (shapeshifter ambusher). Form-change trigger, form list,
  and whether stats change per form are **[OPEN]**.
- **Saboteur (debuffs / gear-breaking flavor):** Gremlin ("breaks your
  gear's day"). Effect scope is **[OPEN]** — gear damage is a sensitive
  system; do not implement without James's design call.
- **Guardian:** Spriggan (tank/guardian), Yaksha (brute/guardian),
  Ushabti (tank/guardian), Lamassu (tank/caster guardian), Jackal
  Guardian (skirmisher by flavor, guardian by name). What "guardian"
  means mechanically (defends a spot? buffs allies? enrages if its
  charge is attacked?) is **[OPEN]**.
- **Stationary:** Grotto Snapper (stationary ambusher), Corpse Flower
  (stationary controller), Mandrake (caster scream — stationary by
  nature). Stationary monsters' aggro / activation radius is **[OPEN]**.
- **Aquatic (movement medium, not a combat archetype):** Kelpie, Merrow,
  Selkie, Rusalka, Vodyanoy, Naga, Makara, Nure-onna, Ahuizotl, Cave
  Moray, Drowned Sailor, Giant Octopus, Deep Crab, Lanternjaw,
  Sea Serpent, Nixie, Afanc, Mami Wata, Inkanyamba, Cipactli Brood,
  Marid, Undine, Water Elemental, Kappa (aquatic tank/grappler).
  Whether aquatic monsters fight differently on dry dungeon floors vs.
  in water zones — and whether flooded-room rules exist at all — is
  **[OPEN]**. Do not assume water zones exist; the texture sets staged
  Oct 27 do not include a Flooded Deep set (sourcing notes: missing
  sets include Flooded Deep, Bone Wastes, Fungal Grotto, Void Scar,
  Storm Spire).
- **Variant axes (roster §6) — not archetypes, but they layer onto every
  archetype above:** Attunement (Ember / Frost / Storm / Venom /
  Radiant / Void — material tint + particle color + one rider: burn DoT,
  slow, chain spark, poison, blind, lifedrain); Corruption
  (Grave-touched / Hollow — desaturated palette, eye-glow, undead
  resistances, phase-touch for Hollow); Stature (Dire ×1.4 scale +
  HP/ATK, Young ×0.7 swarm-spawned); Rank (Champion elite, Horde Lord
  spawns-with-pack, Named Apex). How each rider interacts with the
  base archetype's telegraphs and tuning hooks is **[OPEN]** — e.g. a
  Venom-attuned charger vs. a venom-skirmisher sting are different
  deliveries of "poison" and must not share one unwritten DoT number.

---

## 5. Apex bosses — signature behavior patterns (high level only)

Source: `design-notes/apex-bosses-lore-strategies.txt`. Patterns only.
**No stats are invented here beyond the locked curves in §1** (apex
stats ride the matching base type with multiplied stats per the roster
paper — the multiplier itself is **[OPEN]**). **No drop mapping is
stated here:** the lore file's boss→body-slot mapping is marked
PROPOSAL ONLY (James decides) and is therefore NOT reproduced as a
mapping. Boss signature drops stay **[OPEN]** / blank, per the task
constraint and the Oct 24 lock (only wolf→fur, boar→leather,
spider→silk, light/heavy leather by size, teeth/fangs reagents are
locked).

| Boss | Base type (roster) | Signature behavior pattern (high level) |
|---|---|---|
| Cerberus | Hellhound | Triple Bite — three heads strike in sequence, front arc. Tail Serpent — sideways tail lash with little warning. Gate Roar — bellowing stagger, front arc, long windup. Counter-shape: flank so one head tracks; leave the front arc during roar windup; punish after the triple bite (heads need a breath). |
| Medusa | Gorgon | Petrifying Gaze — telegraphed eye-glow; facing her when it fires → slowed, then stone-held. Serpent Hair — snakes strike independently, multi-hit, close range, separately targetable. Stone Shards — thrown projectiles. Counter-shape: turn/strafe during gaze windup; attack during the long gaze cooldown; clear snakes for safe windows. |
| Typhon | Ur-Dragon class | Storm Winds — arena-wide knockback gusts. Serpent Volley — lesser heads spit projectile fans. Eruption — ground bursts under the player, telegraphed by cracks. Counter-shape: keep moving; step off cracked ground; main head is the damage target, lesser heads are a dodge-not-farm distraction. |
| Echidna | Lamia class | Brood Call — summons lesser monsters in waves. Tail Sweep — wide ground sweep around coils. Venom Spit — arcing poison pools. Counter-shape: choose burn-her-down vs. clear-brood-first; never stand in the sweep ring; step out of venom pools at once. |
| Fenrir | Great Wolf | Bone Bite — single crushing frontal bite (frontal cone, never trade). Pounce — long telegraphed leap, lands where the player stood. Death Howl — fear stagger at close range. Counter-shape: sidestep the bite; keep moving so the pounce misses by itself; punish the long recovery after a missed pounce. |
| Jörmungandr | World Wurm | Tail Sweep — arena-edge sweeps; the rim is dangerous. Venom Spray — lingering poison pools. Coil Surge — rising wave pushing the player back. Counter-shape: fight near the head, not the rim; move out of pools, never stand in them; poison resistance / cleanse near-mandatory (per lore file). |
| Surtr | Fire Giant | Flame Sword Arc — huge sweeping arcs, front and sides, slow windup, long recovery. Fire Wave — travelling wall of flame. Eruption Pillars — fire columns under the player, telegraphed. Counter-shape: fire resistance first; punish sword-arc recovery; never stand on scorched ground; ranged shines during fire-wave windup. |
| Fafnir | Elder Wyrm | Poison Breath — frontal cone of lingering venom cloud. Tail Sweep — heavy rear arc. Hoard Charge — straight-line rush across the room, cannot turn. Counter-shape: flank (breath frontal, tail rear); sidestep the charge; charge recovery is the best damage window. |
| Baba Yaga | Witch | Mortar Dive — flying slam, telegraphed by its shadow (watch the shadow, not the witch). Pestle Sweep — wide melee arcs. Skull Volley — fence-skull projectiles (totems destructible to thin the volley). Hex — casting debuff (slow + weaken), interruptible. Counter-shape: interrupt the hex; destroy skull totems; punish the post-dive pause. |
| Koschei the Deathless | Lich | Death Bolts — heavy ranged magic. Deathless Guard — invulnerable phases while a hidden vessel lives. Bone Summons — skeletal adds screening him. Life Drain — channeled beam that heals him. Counter-shape: each phase, find and break the hidden vessel to end invulnerability; interrupt the drain channel at all costs; ignore summons while a vessel is exposed. Vessel-hiding / finding rules are **[OPEN]** as mechanics. |
| Humbaba | Cedar Guardian | Cedar Slam — trunk-sized arms smash ground, shockwave ring, long recovery. Terror Roar — fear stagger, wide radius. Root Snare — vines erupt under the player, telegraphed by cracks. Boulder Throw — slow, heavy, arena-wide AoE. Counter-shape: step off cracked ground; punish slam recovery; spread from roar center; one sidestep clears boulders. |
| Shuten-dōji | Oni | Great Club Slam — slow, devastating overhead blows (dodge the windup, always; never trade). Sake Breath — drunken haze (confuse + slow). Oni Charge — bull rush across the room. Drunken Frenzy — speeds up as the fight goes on. Counter-shape: punish his mid-fight drinking pause (the legendary opening); confusion protection or distance vs. sake breath; end it fast — frenzy means longer fights get harder. |
| Yamata no Orochi | Hydra | Eight-Head Volley — bites from many angles at once. Drunken Stagger — after drinking, heads droop and slow (damage window). Tail Sweep — massive rear arc from eight tails. Storm Breath — wide elemental cone. Counter-shape: focus one head at a time (each head downed thins the volley); punish the droop window; front is safer than rear. Head-count / head-regrow mechanics are **[OPEN]** (cf. Hydra regen, §2.18). |
| Ravana | Rakshasa | Ten-Head Volley — multi-projectile fans from many heads. Sorcery Bolts — heavy aimed magic. Blade Flurry — fast melee storm at close range, long recovery. Illusion Doubles — phantom Ravanas mirroring attacks. Counter-shape: learn the true-Ravana tell (illusions flicker, per lore file) and ignore fakes; dodge volleys laterally, never backward; punish flurry recovery. |
| Anzu | Anzu | Storm Dive — plunging aerial slam, telegraphed by shadow. Wind Gusts — knockback walls across the room. Lightning Strikes — marked ground zones that detonate. Tablet Pulse — radial shockwave. Counter-shape: leave marked zones before lightning lands; punish dive recovery; position with back to a wall so gusts cannot throw the player into hazards. |
| Tarasque | Tarasque | Shell Charge — rolling charge, fast in a straight line, cannot turn. Tail Lash — heavy rear arc. River Surge — water wave across the room. Bite — short-range snap. Counter-shape: sidestep the charge (long recovery); shell shrugs off frontal hits — attack the softer underside after a missed charge; water resistance helps vs. surge. |

**Apex pattern notes for Phase 2:**

- Every apex pattern is built from §2/§3 primitives (charge, sweep, cone,
  volley, summon, AoE scream/roar, shadow-telegraphed dive, ground-crack
  telegraph, drink-pause window) plus one boss-specific twist (vessel
  phases, illusion doubles, head-count thinning, frenzy escalation).
  Phase 2 should implement the primitives first, then the twist —
  not a bespoke system per boss.
- Telegraph families reused across bosses (so players learn once, apply
  everywhere): ground cracks → eruption/snare under the player; shadow →
  aerial dive landing spot; eye-glow → gaze; inhale → breath cone;
  pawing/bellowing → charge; long windup → interrupt-or-escape window;
  post-attack recovery → punish window. Keep these consistent; do not
  reassign a tell to a different meaning for one boss.
- Apex bosses are NOT mini-bosses. The mini-boss tier is separate
  (Mimic / Tsukumogami chest-monsters, per the morning briefing) and is
  out of this catalog's scope except as noted in §6.

---

## 6. Gaps and [OPEN] register

**Archetypes with no clear implementation reference (thinnest coverage):**

1. **Trapper (§2.12)** — one staged monster (kobold), one roster entry,
   zero wired mechanics. No trap type, trigger, effect, or disarm rule
   exists anywhere in the sources. Phase 2 cannot build trapper from
   this catalog alone; it needs a trap design decision first.
2. **Grappler (§2.11)** — posture staged (kappa), hold mechanics entirely
   unwired (duration, break-out, damage-while-held, player agency while
   held all **[OPEN]**).
3. **Pure flyer (§2.6)** — no staged example; all staged flyers are
   compounds. Decide whether bare "flyer" survives as an archetype.
4. **Controller, support/summoner, lifedrain, splitter, def-shredder,
   shapeshifter, saboteur, guardian, stationary (§4)** — roster flavors
   with no staged monster and no staged behavior text. Each needs a
   design decision before build.

**Mechanics named in staged behavior text but explicitly future wiring
(not staged, per the sourcing notes):** venom DoT (scorpion, spider),
troll regen rate, banshee AoE scream, drake fire-breath cone, kappa
grapple, kobold traps, pixie dazzle, boar/minotaur charge telegraphs
(the telegraph *descriptions* are staged; the charge *mechanics* are
not wired). Phase 2's first job for each is to set the numbers in the
tuning hooks listed above — this catalog deliberately sets none of them.

**Other [OPEN] items collected from the entries above:**

- Spawn wiring: `dungeon_gen._pick_type()` still returns only
  slime/bat/skeleton; per-band spawn weights, horde-floor weak-only
  rules, and pack sizes are all **[OPEN]** (sourcing notes).
- Pack-burst trigger (§2.15), phase visibility / targetability (§2.16),
  first-strike bonus (§2.14), charger wall-impact behavior (§2.5),
  cornered-ranged / cornered-caster responses (§§2.9–2.10), aquatic
  floor rules (§4), variant-rider interactions (§4).
- Apex multipliers, vessel-hiding rules (Koschei), head-count /
  head-regrow rules (Orochi / Hydra), illusion tell implementation
  (Ravana), and all boss signature drops (§5).
- Materials: everything except the §1 locked list stays blank for
  James (Drive: Milo/Abysmal/Monsters materials list, per the Oct 29
  brief). No drop mapping is filled in here.
- Models/voices: this catalog covers behavior only. Model gaps (25
  staged placeholders, Quaternius human clickthrough outstanding) and
  vocal gaps (all vocalizations procedural specs, no files) are tracked
  by the sibling Phase 1 workstreams, not here.

**What Phase 2 should do first (suggested order, not a directive):**
implement the §2 primitives with the most staged coverage (brawler,
brute, tank, skirmisher, charger, flyer/skirmisher, flyer/caster,
ranged, caster) against the locked curves with a depth 1–50 soak; then
the unwired riders (venom, regen, scream, breath, dazzle); then grapple
and traps as designed systems (they need decisions first); then the §4
roster-only flavors; then apex twists on top of the primitives.

---

*End of Phase 1 behavior catalog. Doc only — no .gd file, scene, test,
or asset was modified to produce it.*
