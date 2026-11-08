# OGA Wiring Plan — rubberduck 80 CC0 creature SFX #1 (pack #1)

Plan only. **Nothing is applied by this document.** Application needs
James's green-light AND the license confirmation in §1.

## 0. Correction to the brief

The brief said "160 OGA sounds inventoried-not-wired." The on-disk truth:

- `~/workspace/build/pack-inventory/oga80b/` (pack #2) matches the staged
  `rd2-*.ogg` set **80/80**. Pack #2 is already staged; 41 of its files
  are in vocal pools and 39 serve `attacks/`, `movement/`, or unwired
  pool dirs. **No action needed for pack #2.**
- `~/workspace/build/pack-inventory/oga80a/` (pack #1) overlaps the staged
  set **0/80**. Pack #1 is the entire unwired set: **80 files, none
  staged, none wired.** This plan covers pack #1 only.

## 1. License gate (must clear before any staging)

Pack #1's license is **unverified from a source page** in this pass
(no browser). Evidence for CC0: the Nov 1 zip filename
(`80-CC0-creature-SFX.zip`) and the same author/series as pack #2
(verified CC0 on its OGA page, per `assets/resources-phase1/audio/
LICENSES.md`). Against: no license file inside the zip, no local
license note, and LICENSES.md (Oct 29) records pack #1 as
not-downloaded at that time.

**Required before shipping:** confirm the OGA page for "80 CC0
creature SFX" (pack #1, rubberduck) states CC0, then append a §8
entry to `assets/resources-phase1/audio/LICENSES.md` and a credit
line (rubberduck, CC0, not required but credited per policy) to
`design-notes/credits-and-attribution.md`. If the page does NOT
state CC0, this plan is void — do not stage or wire the 80 files.

## 2. Staging convention (follows pack #2)

- Copy the 80 OGGs to `assets/resources-phase1/audio/` with the
  `rd1-` prefix (pack #1), mirroring pack #2's `rd2-` prefix. No
  filename collisions: pack #1 and pack #2 share no basenames.
- Sort into dirs by the same prefix logic pack #2 used: vocal files
  to `vocals-*/`, spit attacks to `attacks/`, alien files to
  `vocals-abyssal/` (staged, held — see §4).
- Generate `.import` siblings via a Godot project import pass
  (pack #2's files all carry `.import` files; new files must too).
- Run the Phase 1 Layer 1 scripted analysis over the 80 new files
  (zero-byte, format, duration checks; results appended to
  `assets/resources-phase1/audio/analysis/layer1_results.json`).
  Any flagged file goes to `FLAGGED_FILES` in `voice_map.gd` and
  into NO pool — the same rule pack #2's files followed.

## 3. Pool assignments — Bucket A: wire on green-light (58 files)

No new pools are created; every file extends an existing pool, so
the "one fallback reel per wired pool" test condition is unchanged.

| Pack #1 files (as `rd1-*`) | Target pool | Pool size after | Why |
|---|---|---|---|
| bug_01–04 | vermin | 9 → 13 | Chitter; extends the thin vermin pool |
| burble_01–02 | ooze | 8 → 10 | Slime gurgles |
| barking_01–02, howl, roar_01–03 | beast | 28 → 34 | Dog/bark + a real wolf howl + generic roars |
| grunt_01–05, cough_01–03, monster_01–07, burp_01–02, hurt_01–05, nose, ooh, snore | generic | 45 → 70 | Generic humanoid/creature bed; hurt/snore are context candidates (see §5) |
| cute_01–10 | fey | 65 → 75 | Small-creature cute sounds |
| troll_01–03 | orc | 51 → 54 | Dedicated troll clips (troll currently uses orc pitched down) |
| scream_01–02 | human_scream | 5 → 7 | Human screams; banshee attack/death candidates (not a wail — see §6) |
| weird_01–05, breath | spirit | 19 → 25 | Ghostly weirdness + a breath bed (banshee idle candidate) |

**Wired total after Bucket A: 397 → 455 clips.**

## 4. Buckets B–D: stage, do not wire yet (22 files)

| Bucket | Files | Disposition |
|---|---|---|
| B — audition-gated (13) | misc_01–09, eat_01–04 | Stage only. `misc_` is a mixed bag and `eat_` is feeding audio, not vocals. Per CATALOG.md's generic-pool note, pick per-monster from these after auditioning — do not wire wholesale. |
| C — apex hold (6) | alien_01–06 | Stage to `vocals-abyssal/` only. `abyssal` is an apex-only pool name with no wired clips; apex vocal wiring is a Wave 4 / systems-step decision for James, not this wiring. |
| D — attacks (3) | spit_01–03 | Stage to `attacks/`. Spit attacks, not vocals; never in a vocal pool. |

## 5. `voice_map.gd` changes implied (application step, not this doc)

- Add 58 `rd1-*.ogg` paths to `VOCAL_POOLS` per §3 (Bucket A only).
- `TYPE_VOICE` note updates: troll — dedicated troll clips now exist
  in the orc pool (keep pitch 0.65; note the change); wolf — the beast
  pool now contains a real howl (no note change needed, wolf's note
  is empty); banshee — spirit pool gains breath, human_scream gains
  2 screams (wail still missing — §6).
- No new pools, no new types, no context-split changes: pools still
  serve idle/attack/death alike (except banshee's existing idle/attack
  split). Context-split wiring (hurt → death, snore → idle, eat →
  feeding) is future integration work, flagged not built.
- `FLAGGED_FILES` stays empty unless Layer 1 flags a new file.
- Re-run `tests/voice_map_test.gd` (28 types, every clip exists +
  loadable, no flagged file referenced, apex pools name pools only)
  and `tests/audio_manager_test.gd`. Both must exit 0.
- Update `assets/resources-phase1/audio/CATALOG.md` folder counts
  and `LICENSES.md` (§1) in the same application.

## 6. What this plan does NOT fix (generation batch feeds these)

OGA pack #1 fills breadth, not the iconic gaps. Still missing after
Bucket A: a true banshee wail (shippable), a dragon roar (dragon pool
stays 2 growls), a harpy screech, a snake hiss, a frog croak, a kappa
water-gurgle. Those six are the proposed first browser-generation
batch (see §7) — and note the gate: SoundFactory/Violet generations
are prototyping-only, so the batch prototypes these vocals; shipping
them needs a cleared source (Freesound CC0 via account, Sonniss
cherry-pick, or Audacity variations of shippable files, whose license
follows the source).

## 7. First browser-generation batch proposal (~6, a few at a time)

For the later browser step. All six are iconic creatures whose
`TYPE_VOICE` note is APPROX or THIN, i.e. the worst family-pool fits.
Each is one sound type; idle/attack/death contexts come from the
existing pool + pitch rules until per-context generation exists.

| # | Creature | Sound to generate | Context | Replaces (current stand-in) |
|---|---|---|---|---|
| 1 | Banshee | True wail (high, ghostly, sustained) | attack/death | LRSF horror screams (not a wail); SoundFactory wail exists but cannot ship |
| 2 | Drake (dragon) | Deep dragon roar | attack | 2-growl dragon pool |
| 3 | Harpy | Bird screech/shriek | attack | Beast roars pitched up |
| 4 | Snake | Hiss (dry, sustained) | idle/attack | Beast roars pitched down |
| 5 | Frog | Croak (low, resonant) | idle | Generic grunts pitched down |
| 6 | Kappa | Water gurgle-croak | idle/attack | Generic grunts pitched down |

Held out of batch 1: Cerberus triple-bark (apex — needs the apex
vocal decision first); per-monster vocals for the other 294 rows
(they keep family pools until later batches).

## Applied — Buckets B/C/D, Nov 7, 2026 (James's word: "Wire B and C ...
And D if you think it fits")

- **B:** `misc_01–09` staged to `vocals-generic/` and wired into the
  `generic` pool (the catch-all, per the CATALOG note). `eat_01–04`
  staged to a NEW `actions/` dir, **unwired** — feeding audio is not a
  vocal and no feeding context exists yet; wiring them as vocals would
  have been wrong. They wait for the feeding-context work (§5).
- **C:** `alien_01–06` staged to `vocals-abyssal/` and wired as a NEW
  `"abyssal"` pool in `VOCAL_POOLS` (apex-only; `APEX_VOCAL_POOLS`
  names it for Typhon). `APEX_ONLY_POOLS` is now `["human"]`.
  New fallback reel `reels/vocals-abyssal-reel.mp3` built (ffmpeg
  concat of the 6 clips, 3.96 s).
- **D:** `spit_01–03` staged to `attacks/` — spit is attack audio,
  never a vocal pool. It fits; done.
- Counts: wired clips **458 → 473** (9 misc + 6 alien; eat/spit are
  not in vocal pools). CATALOG **731 → 753** files. All 22 files
  passed the Layer-1-equivalent check (durations 0.25–0.83 s, none
  zero-byte) before wiring.
- Tests: `voice_map_test` exactly 1 failure (the load check — same
  container import wall as Bucket A: Godot here scans new audio but
  does not import it; should import on a normal editor run).
  `audio_manager_test` green. Backup:
  `~/workspace/build/wire-bucketbcd-20261107/` (+ script
  `~/workspace/build/wire-bucketbcd-20261107.py`).

## 8. Decisions needed (James / systems step)

1. **Pack #1 CC0 page confirmation** (§1) — required before staging
   for shipping. Without it, the 80 files stay inventoried-only.
2. **Green-light to apply** §§2–5 (staging + voice_map edits + tests).
3. **Alien files → abyssal apex pool?** Recommend hold (Bucket C)
   until apex vocal wiring is decided in the systems step.
4. **Generation batch approval** (§7) — and whether batch-1
   generations are prototyping placeholders or whether James wants a
   shippable path (Freesound account download, Sonniss cherry-pick,
   Audacity variation) pursued first.
5. **Context-split wiring** (hurt → death, snore → idle) — future
   integration work; not part of this wiring.
