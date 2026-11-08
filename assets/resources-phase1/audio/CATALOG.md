# CATALOG — Phase 1 creature audio (Abysmal)

Staged Oct 29, 2026 under `assets/resources-phase1/audio/`. **No game
code was touched; nothing here spawns or plays yet.** Mapping below is
by pack description and filename only — files were not auditioned
individually. Phase 2 should audition each folder's picks before
wiring, and may pitch-shift / layer these (e.g. a troll = orc voice
pitched down; a banshee = scream layered over scared breath).

Licence details live in LICENSES.md in this same folder. Short version:
CC0 = Ogrebane, rubberduck #2, Kenney (126 files, no attribution
required). CC-BY 3.0 = all Little Robot Sound Factory files and
jalastram (544 files, attribution required — see LICENSES.md).

## Counts by folder (753 files, ~36 MB)

| Folder | Files | What it holds |
|---|---|---|
| vocals-generic/ | 104 | Ogrebane monster (17 WAV), jalastram monster voices (10), Horror Monster (7), rubberduck monster (13) + grunt (4) + die (4) + misc (13) + breath (1) + snore (1) |
| vocals-undead/ | 78 | Little Robot Zombie voices (73) + Horror Zombie (5) |
| vocals-human/ | 94 | Little Robot Human (50: evil + good + dying breath), rubberduck human (8), Horror male screams (5), Kenney war shouts M+F (29) |
| vocals-orc/ | 54 | Little Robot Orc voices (51) |
| vocals-demon/ | 33 | Little Robot Demon (30) + Horror evil laughs (3) |
| vocals-fey/ | 75 | Little Robot Small Creature (65) — also usable for vermin/small beasts |
| vocals-abyssal/ | 107 | Little Robot Alien funny+scientist (91), rubberduck alien (6) + weird (4) |
| vocals-beast/ | 34 | Little Robot Dinosaur (25) + rubberduck roars (3) |
| vocals-construct/ | 48 | Little Robot Robot (48) — golems/automatons |
| vocals-spirit/ | 25 | Horror scared breaths (19) — ghostly breathing bed |
| vocals-vermin/ | 13 | rubberduck bug/chitter (9) |
| vocals-ooze/ | 10 | rubberduck slime (8) |
| vocals-goblin-kin/ | 5 | Little Robot Fantasy Goblin (5) |
| vocals-dragon/ | 2 | Little Robot Fantasy Dragon Growl (2) |
| vocals-kappa/ | 1 | Kappa water-gurgle sample, shaped with ffmpeg from OGA pack #1 burble_01/02 (rubberduck, CC0), James-approved Nov 4 |
| vocals-frog/ | 1 | Frog croak sample (OGA Frog Croaks croak_01, EZduzziteh, CC0, normalized), James-approved Nov 7 |
| vocals-harpy/ | 1 | Harpy screech (SoundBible Screaming Hawk, PsychoBird, CC BY 3.0), James-approved Nov 7 |
| attacks/ | 45 | rubberduck attacks (5), Little Robot Splat (22), Fantasy spells (5) + traps (3), Horror bonecracks (4) + knife stabs (3) |
| movement/ | 19 | Fantasy footsteps dirt (10) + water (8), rubberduck stomp (1) |
| actions/ | 4 | OGA pack #1 eat (4) — feeding audio, staged Nov 7, NOT wired (no feeding context exists yet) |
| **Total** | **753** | |

Note: folder counts sum from the curation script; a few rubberduck
prefix groups (e.g. `misc_`) were kept whole in vocals-generic, so the
generic folder is a mixed pool by design — pick per-monster from it
in Phase 2 rather than wiring it wholesale.

## Per-family coverage (roster families, honest version)

"Covered" = a dedicated vocal pool exists. "Fallback" = no dedicated
pool; use the named generic pool in Phase 2. No per-monster audio
exists in any free pack found — all mapping is family-level or
generic, which the task explicitly allows.

| Roster family | Coverage | Suggested pool |
|---|---|---|
| Oozes & Slimes | COVERED (dedicated) | vocals-ooze (slime) + vocals-generic |
| Vermin & Cave Crawlers | COVERED (dedicated) | vocals-vermin (bug/chitter) + vocals-fey (small creature) |
| Beasts | COVERED (dedicated) | vocals-beast (roars, dinosaur) + vocals-generic |
| Goblin-Kin & Cave Folk | COVERED (dedicated) | vocals-goblin-kin (5) + vocals-orc + vocals-generic |
| Orcs, Trolls & Giant-Kin | COVERED (dedicated) | vocals-orc (51; pitch down for trolls/giants) |
| The Undead | COVERED (dedicated) | vocals-undead (78) + vocals-spirit (breaths) |
| Greek & Mediterranean | FALLBACK only | vocals-generic (monster), vocals-beast (minotaur/harpy), vocals-spirit (siren — no song pool exists) |
| Norse & Germanic | FALLBACK only | vocals-orc (giants), vocals-beast (wolves), vocals-generic |
| Egyptian & Near East | FALLBACK only | vocals-generic, vocals-vermin (scarab swarm) |
| Japanese Yōkai | FALLBACK only | vocals-orc (oni), vocals-generic, vocals-spirit (yuki-onna — no ice-vocal pool) |
| Celtic & British Isles | FALLBACK only | vocals-spirit (banshee — screams live in vocals-human; layer with breaths), vocals-generic |
| Slavic | FALLBACK only | vocals-human (witch = evil human), vocals-generic |
| Mesopotamian | FALLBACK only | vocals-generic, vocals-demon (storm demons) |
| South Asian | FALLBACK only | vocals-demon (rakshasa), vocals-generic |
| Chinese & East Asian | FALLBACK only | vocals-dragon (long), vocals-generic |
| Mesoamerican & Andean | FALLBACK only | vocals-abyssal, vocals-generic |
| African Traditions | FALLBACK only | vocals-beast, vocals-generic |
| Fey & Nature Spirits | COVERED (dedicated) | vocals-fey (small creature 65) |
| Demons, Devils & the Damned | COVERED (dedicated) | vocals-demon (33) |
| Celestials & the Fallen | FALLBACK only | vocals-abyssal (alien — closest to "otherworldly"), vocals-human |
| Elementals & Primal Spirits | NOT COVERED (vocal) | No elemental vocal pool found; spell/attack sounds only. Elementals are arguably better as layered attack/ambience than vocals |
| Golems & Constructs | COVERED (dedicated) | vocals-construct (robot 48) |
| Plants & Fungi | FALLBACK only | vocals-generic; mandrake scream has NO dedicated pool (Horror male screams are the nearest stand-in) |
| Aquatic & the Drowned Deep | FALLBACK only | movement water footsteps (8); no swim/gurgle vocal pool |
| Dragons & Great Serpents | COVERED (thin) | vocals-dragon (only 2 growls) + vocals-beast roars + vocals-generic |
| Humans & the Damned Living | COVERED (dedicated) | vocals-human (92) |
| Sky & Storm | FALLBACK only | vocals-beast (bird-adjacent roars only); no wing-flap or bird-call pool |
| The Abyssal & Cosmic | COVERED (dedicated) | vocals-abyssal (101 alien/weird) |

## Apex bosses (16 named) — suggested pools, no named audio exists
- Cerberus → vocals-beast + vocals-demon; Medusa → vocals-spirit +
  vocals-human screams; Typhon → vocals-dragon + vocals-abyssal;
  Echidna → vocals-generic + vocals-demon; Fenrir → vocals-beast;
  Jörmungandr → vocals-dragon + vocals-beast; Surtr → vocals-demon +
  vocals-orc (pitched down); Fafnir → vocals-dragon + vocals-beast;
  Baba Yaga → vocals-human (evil); Koschei → vocals-undead +
  vocals-spirit; Humbaba → vocals-orc (pitched down) + vocals-generic;
  Shuten-dōji → vocals-orc + vocals-demon; Yamata no Orochi →
  vocals-dragon; Ravana → vocals-demon + vocals-human; Anzu →
  vocals-dragon + vocals-beast; Tarasque → vocals-dragon +
  vocals-beast. All are Phase 2 layering suggestions, not staged
  per-boss files.

## Gaps (no free-use source found this pass)
1. **Per-monster vocals** — none exist in the packs found; everything
   is family-level or generic.
2. **Banshee wail / siren song / mandrake scream** — no dedicated
   scream-song pool; nearest stand-ins are Horror male screams +
   scared breaths (layer them in Phase 2).
3. **Real animal vocals** (wolf howl, lion roar, bear growl, snake
   hiss, bird calls) — Wikimedia Commons searches surfaced mostly
   human imitations and unrelated recordings, not a clean CC0
   animal-vocal set; not staged rather than staging poor fits.
4. **Movement variety** — only dirt/water footsteps + 1 stomp.
   No wing flaps, slithering, swimming, hopping, or heavy
   giant footfalls beyond the single stomp.
5. **Attack variety** — no bow release, fire-breath, poison-spit,
   or bite-specific sounds (rubberduck pack #1, which advertises
   "spit", could not be downloaded — see LICENSES.md).
6. **Elemental / plant / aquatic vocals** — none found; these
   families will need synth/layered Phase 2 work or a later hunt.
7. **Sonniss GDC bundles** — verified royalty-free but 7.47 GB
   (2026) with no per-file target list; left for a future pass
   with a size budget, not staged.
8. **BBC Sound Effects** — excluded on licence (RemArc:
   personal/educational/research only), not on availability.

## Already in-project (not duplicated here)
`assets/audio/kenney/` (Impact Sounds, Interface Sounds, Music
Jingles, RPG Audio — all CC0) already covers attack cues and
footsteps for the 28 staged monsters. This folder adds the missing
piece: vocalizations, plus extra attack/movement variety.

---

# WAVE 2 AUDITION — voice wiring (Oct 29, 2026)

Method: `design-notes/phase2-wave2-audition-method.md` (James's
priorities: Layer 1 full, Layer 2 trial, Layer 3 backup reels).
Data lives in `scripts/voice_map.gd`; playback API in
`autoload/audio_manager.gd` (`play_monster_vocal(type, context)`,
`resolve_monster_vocal()`, `has_monster_voice()`). Enemy-side voice
triggers are NOT wired here — the Wave 2 integration step calls the
API from `enemy.gd`. No APK, no release, no publish.

## Layer 1 — scripted analysis, FULL (609/609 vocal files)

Tool: ffmpeg 8.1.2 + ffprobe + numpy (sox/librosa not installed).
Per file: duration, sample rate, channels, RMS/peak loudness,
clipping fraction, frame silence fraction, ffmpeg `silencedetect`
(-50 dB, 0.1 s), spectral centroid/bandwidth, file-sha256 and
decoded-PCM-sha256 duplicate detection. Full per-file table:
`analysis/layer1_results.json` (+ `.csv`).

- **Analyzed: 609 vocal files. PASS: 608. FLAG: 1.**
- Ranges across all files: duration 0.28–16.3 s (median 1.12 s);
  RMS −34.1 to −8.0 dBFS (median −17.6); peak max −0.0 dBFS;
  clipping fraction max 0.0003 (no file near the 5% flag line);
  silence fraction max 0.56 (no file near the 90% flag line).
  **No broken, near-silent, all-clipping, or duplicate files found.**
- Flag rules: duration < 0.05 s = BROKEN; < 0.10 s = TOO_SHORT;
  > 15 s = OVERLONG; ≥ 90% silent frames with RMS < −45 dBFS =
  NEAR_SILENT; RMS < −50 dBFS = VERY_QUIET; > 5% full-scale samples
  = CLIPPING; identical file bytes or decoded PCM = DUPLICATE.

### Flags (NOT wired, pending James's confirmation)

| File | Reason |
|---|---|
| `vocals-undead/jalastram-voice-008.mp3` | OVERLONG: 16.3 s, RMS −28.3 dBFS, 1.8% silent — likely a multi-vocal take, not a single vocal clip. Was listed in `VoiceMap.FLAGGED_FILES` and in no pool. **REPURPOSED Nov 1, 2026 (James, after listening): zombie/ghoul gasping loop, undead ambient — moved from FLAGGED to the vocals-undead pool in the v0.12.0 monster step (file physically moved from vocals-generic/).** |

## Layer 2 — spectrogram spot-checks, TRIAL (12/12 wired families)

One `showspectrumpic` (1024×512) per wired family, saved in
`analysis/spectrograms/<family>.png`, reviewed visually:

| Family (rep file) | What the spectrogram shows |
|---|---|
| ooze (`rd2-slime_01.ogg`) | Short broadband wet-splat bursts, low-mid emphasis — plausible slime |
| vermin (`rd2-bug_05.ogg`) | Sustained high buzz band ~2–16 kHz — clearly distinct, plausible insect |
| beast (`lrsf-voices-dinosaur_00.mp3`) | Strong low harmonic bands ~0–2 kHz with pitch contours — plausible roar |
| dragon (`lrsf-fantasy-Dragon_Growl_00.mp3`) | Sustained low rumble, dense low-mid energy — plausible growl |
| orc (`lrsf-voices-orc_00.mp3`) | Loud broadband shout, strong mid energy, clean onset |
| undead (`lrsf-voices-zombie_00.mp3`) | Long sustained groan (4.7 s) with breath gaps — plausible zombie |
| spirit (`lrsf-horror-Breath_Scared_00.mp3`) | Breathy broadband noise, two quiet phrases — clearly distinct, plausible breaths |
| fey (`lrsf-voices-smallcreature1_00.mp3`) | Dense chattery broadband, rapid modulation — plausible small creature |
| demon (`lrsf-voices-demon_00.mp3`) | Low growl, strong sub-2 kHz energy, breath gap — plausible demon |
| construct (`lrsf-voices-robot1_00.mp3`) | Unmistakable synthetic harmonic sweeps/chirps — clearly NOT a humanoid vocal |
| goblin-kin (`lrsf-fantasy-Goblin_00.mp3`) | Chattery multi-phrase vocal bursts — plausible goblin |
| generic (`ogrebane-monster-1.wav`) | Sustained mid growl/roar — plausible generic monster |

**No family-level mislabel found in any of the 12.**
**Trial verdict: PARTIALLY USEFUL, not decisive.** Spectrograms
cleanly separate gross categories (robot sweeps, insect buzz,
breathy spirit, low rumble, splat bursts) and would catch a gross
mislabel (e.g. a robot file in the zombie folder). But the humanoid
vocal families (orc / undead / demon / goblin-kin / fey) are visually
near-identical broadband noise — this layer cannot validate those
distinctions. The real gate remains Layer 1 (numbers) + the Layer 3
reels (James's ears). Do not treat spectrograms as proof that a
humanoid vocal "sounds right" for its monster.

## Layer 3 — fallback audition reels (BACKUP, not the gate)

One concatenated clip per wired pool (clips in pool order, 0.25 s
silence between), MP3, under `assets/resources-phase1/audio/reels/`:

| Reel | Clips | Length |
|---|---|---|
| `reels/vocals-ooze-reel.mp3` | 8 | 6.1 s |
| `reels/vocals-vermin-reel.mp3` | 9 | 5.4 s |
| `reels/vocals-beast-reel.mp3` | 28 | 38.1 s |
| `reels/vocals-goblin-kin-reel.mp3` | 5 | 10.3 s |
| `reels/vocals-orc-reel.mp3` | 51 | 103.2 s |
| `reels/vocals-undead-reel.mp3` | 78 | 140.2 s |
| `reels/vocals-spirit-reel.mp3` | 19 | 31.4 s |
| `reels/vocals-demon-reel.mp3` | 33 | 53.5 s |
| `reels/vocals-fey-reel.mp3` | 65 | 105.3 s |
| `reels/vocals-construct-reel.mp3` | 48 | 81.2 s |
| `reels/vocals-dragon-reel.mp3` | 2 | 8.1 s |
| `reels/vocals-generic-reel.mp3` | 45 | 57.0 s |
| `reels/vocals-human_scream-reel.mp3` | 5 | 9.4 s |

These exist so James can listen on his own devices when swamped.
They are the backup, not the gate: the primary verdict is Layer 1
(full) + the Layer 2 trial above.

## Voice mapping — 28 staged monsters → family pools

Family pools only — no per-monster vocals exist in any free pack
found, and none are pretended here. Packs are not split by context,
so idle/attack/death share the pool except banshee (breath idle,
scream attack/death, per the catalog's layering suggestion).
`pitch` is the base `pitch_scale` (API adds context modifiers:
attack ×1.05 pitch / ×1.1 volume, death ×0.85 pitch, plus ±0.08
random jitter). "APPROX" = no dedicated pool exists; the named pool
is the nearest stand-in, honestly labeled.

| Monster | Pool(s) | Pitch | Note |
|---|---|---|---|
| slime | ooze | 1.00 | |
| bat | vermin | 1.40 | chitter pitched up for high chirps |
| skeleton | undead | 0.90 | |
| rat | vermin | 1.35 | chitter pitched up for squeaks |
| spider | vermin | 1.10 | chitter for dry chitter |
| snake | beast | 0.90 | APPROX: no hiss pool; roars pitched down |
| wasp | vermin | 1.20 | buzz |
| frog | generic | 0.70 | APPROX: no croak pool; grunts pitched down |
| wolf | beast | 0.95 | |
| goblin | goblin-kin | 1.15 | |
| zombie | undead | 0.85 | |
| ghost (wraith) | spirit | 1.00 | breaths for whisper |
| golem | construct | 0.70 | robot pitched down for stone grind |
| boar | generic | 0.85 | grunt subset for snorts |
| scorpion | vermin | 1.00 | chitter for click-clack |
| centipede | vermin | 1.05 | chitter for leg-rustle |
| skeleton_archer | undead | 0.90 | |
| kobold | goblin-kin | 1.30 | pitched up for yip-chatter |
| imp | demon | 1.35 | pitched up for cackle |
| pixie | fey | 1.50 | pitched up for tinkle |
| orc | orc | 1.00 | |
| troll | orc | 0.65 | catalog suggestion: orc pitched down |
| minotaur | beast | 0.75 | roars pitched down for bellow |
| harpy | beast | 1.30 | APPROX: no bird-call pool; roars pitched up |
| oni | orc | 0.80 | pitched down for oni roar |
| kappa | generic | 0.80 | APPROX: no croak-gurgle pool; grunts pitched down |
| drake | dragon | 1.00 | THIN: dragon pool is only 2 growls |
| banshee | spirit idle / human_scream attack+death | 1.20 | catalog layering suggestion; simultaneous scream+breath layering is future integration work |

**Wired totals: 396 clips across 13 pools** (ooze 8, vermin 9,
beast 28, goblin-kin 5, orc 51, undead 78, spirit 19, demon 33,
fey 65, construct 48, dragon 2, generic 45, human_scream 5).
Generic pool = Ogrebane monster (17) + Horror Monster (7) +
rubberduck monster (13) + grunt (4) + die (4); jalastram takes,
`misc_` mixed bag, snore, and breath are deliberately NOT wired.

## Apex bosses (16) — POOLS ONLY, Wave 4 data

`VoiceMap.APEX_VOCAL_POOLS` names pool names from the Phase 1
catalog suggestions, no clips: Cerberus beast+demon; Medusa
spirit+human_scream; Typhon dragon+abyssal; Echidna generic+demon;
Fenrir beast; Jörmungandr dragon+beast; Surtr demon+orc; Fafnir
dragon+beast; Baba Yaga human; Koschei undead+spirit; Humbaba
orc+generic; Shuten-dōji orc+demon; Yamata no Orochi dragon;
Ravana demon+human; Anzu dragon+beast; Tarasque dragon+beast.
"abyssal" and "human" are apex-only pool names — their clips are
NOT wired and are never returned for enemy types. Apex voices are
not playable through the enemy API.

## What remains UNWIRED (honest)

- **213 of 609 vocal files**: abyssal 101 (apex-only data),
  human non-scream 87 (no staged human monster), generic 25
  (jalastram 10 incl. the 1 flagged file, `misc_` 13, snore 1,
  breath 1). All 213 passed Layer 1 except the 1 flagged file;
  they are simply not picked for the 28 staged monsters.
- **attacks/ (42) and movement/ (19)**: not voice-wired here;
  Kenney attack/footstep cues already cover the 28 in-project.
- **Elemental / plant / aquatic / sky vocals**: no pool exists
  (catalog gaps); nothing invented for them.
- **Simultaneous layering** (banshee scream + breaths at once):
  future integration work, not in this API.
- **Godot import note**: this container's headless editor exits
  before running its import pass (verified across `--import`,
  `--editor --quit`, and Xvfb runs), so the `.import` sidecars for
  the 409 wired files (396 clips + 13 reels) and their
  `.godot/imported/` outputs were produced with Godot's own
  `AudioStream*.load_from_file` + `ResourceSaver` path instead,
  then verified by `ResourceLoader.load` in-headless. A normal
  editor open / export re-imports natively; nothing about the
  audio bytes was altered (imported streams decode to the same
  lengths Layer 1 measured).

## Attribution (unchanged from LICENSES.md)

CC0 (126 files): Ogrebane, rubberduck #2, Kenney — no attribution
required (Kenney credited as courtesy). CC-BY 3.0 (544 files):
**Little Robot Sound Factory** (www.littlerobotsoundfactory.com)
and **Jesús Lastra** — attribution REQUIRED in game credits, in
addition to James's pseudonym **Aethelwarden Solas** (never his
real name).
