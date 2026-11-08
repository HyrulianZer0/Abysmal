# Sound-Library Index — Abysmal (v0.12.0 sounds phase, part 1)

Built Nov 4, 2026. Local-only pass: no browser, no downloads, no sign-ins.
This index names **files that actually exist on disk** and the license each
one ships under. It does not index files we hope to get.

## The gate (do not skip)

- **Shippable backbone ONLY:** Freesound CC0, Sonniss GDC, Pixabay, Audacity
  derivatives of shippable files, and OGA files whose license is verified.
- **PROTOTYPING ONLY — nothing from these ships:** SoundFactory and Violet
  Recording (terms check Nov 4: SoundFactory has no accessible terms/license;
  Violet's Terms grant only personal/non-commercial site access and contain
  no generated-output license). Generations from either are placeholders
  until a shippable source clears the same sound.
- **Never shippable:** BBC (personal/educational/research only), Meta
  AudioCraft (CC BY-NC), Zapsplat free tier (MP3 + attribution + limits),
  SFXMint (personal use).
- **Credit policy (James, Oct 29, 2026):** credit ALL creators, including
  CC0. Game credits use the pseudonym "Aethelwarden Solas" for James's own
  work; that never replaces third-party credit lines.

## How vocals play (current wiring)

- `scripts/voice_map.gd` — data only. 13 pools, 397 wired clips, 28 monster
  types (`TYPE_VOICE`), contexts idle/attack/death, per-type pitch + volume.
- `autoload/audio_manager.gd` — `play_monster_vocal(type, context)` reads
  VoiceMap. No per-monster vocals exist anywhere in the staged library:
  all mapping is family-level or generic. That gap is what the sounds
  phase closes.
- Tests: `tests/voice_map_test.gd`, `tests/audio_manager_test.gd`.

## A. Staged + shippable — `assets/resources-phase1/audio/` (670 files)

Full license text: `assets/resources-phase1/audio/LICENSES.md`.
Per-folder catalog: `assets/resources-phase1/audio/CATALOG.md`.

| Source | Files | License | Credit line for game credits |
|---|---|---|---|
| Ogrebane — Monster Sound Effects 2 (OGA) | 17 WAV | CC0 | Ogrebane (not required, credited per policy) |
| rubberduck — 80 CC0 creature SFX #2 (OGA) | 80 OGG | CC0 | rubberduck (not required, credited per policy) |
| Little Robot Sound Factory — Voices | 455 MP3 | CC-BY 3.0 | "Attribute Little Robot Sound Factory, and provide this link where possible: www.littlerobotsoundfactory.com" |
| Little Robot Sound Factory — Fantasy | 33 MP3 | CC-BY 3.0 | Same Little Robot Sound Factory notice |
| Little Robot Sound Factory — Horror | 46 MP3 | CC-BY 3.0 | Same Little Robot Sound Factory notice |
| jalastram — Monster and Creatures PACK 001 (OGA) | 10 MP3 | CC-BY 3.0 | "Jesús Lastra" (collaborator: piacenti) |
| Kenney — Voiceover Pack war shouts (OGA mirror) | 29 OGG | CC0 | Kenney / www.kenney.nl (courtesy) |

- **Totals: 670 files, ~36 MB. CC0: 126. CC-BY 3.0: 544.**
- Wired now: 397 clips in 13 pools (ooze 8, vermin 9, beast 28,
  goblin-kin 5, orc 51, undead 79, spirit 19, demon 33, fey 65,
  construct 48, dragon 2, generic 45, human_scream 5).
- Staged but NOT in vocal pools: 39 rubberduck #2 files in `attacks/`
  (5), `movement/` (1), `vocals-abyssal/` (10: alien_07–12, weird_06–09),
  `vocals-human/` (8: human_01–08), plus the non-pool remainder of
  `vocals-generic/` — these serve attacks/movement or are apex-pool
  candidates, not wired vocals. The `vocals-abyssal/` and `vocals-human/`
  dirs are named by `APEX_VOCAL_POOLS` but hold no wired pool: apex
  voices are Wave 4 data only.
- Known thin spots in the wired pools (from `TYPE_VOICE` notes):
  dragon = only 2 growls; snake = beast roars pitched down (no hiss);
  frog/kappa = generic grunts pitched down (no croak/gurgle); harpy =
  beast roars pitched up (no bird call); banshee = scream over breaths
  (no true wail in a shippable file).

## B. Staged + shippable — `assets/audio/` (in-project SFX + music)

| Source | Files | License | Notes |
|---|---|---|---|
| Kenney — Impact Sounds | 130 | CC0 (License.txt in pack) | Attack cues, impacts |
| Kenney — Interface Sounds | 100 | CC0 (License.txt in pack) | UI |
| Kenney — Music Jingles | 86 | CC0 (License.txt in pack) | Jingles |
| Kenney — RPG Audio | 52 | CC0 (License.txt in pack) | Footsteps, RPG SFX |
| Alkakrab — Free 12 Fairytale Magical Fantasy Tracks + Indie Game Trailer Music Pack | 369 staged files (format duplicates of the same tracks: mp3/ogg/wav) | Free packs; terms in each pack's "License Info.pdf" (not re-read in this pass — confirm from the PDFs before any new credit claim) | 8 converted OGG themes live in `assets/audio/music/` (dungeon, calm, deep, tense + alts); mapping in `assets/audio/music/MUSIC_CREDITS.md` |

- Kenney subtotal: 368 files, all CC0.
- Alkakrab is music, not creature vocals — indexed here so the library
  has one front door, not because it fills vocal gaps.

## C. Inventoried, NOT shippable yet — do not wire for shipping

| Item | Files | Status |
|---|---|---|
| rubberduck — 80 CC0 creature SFX #1 (`~/workspace/build/pack-inventory/oga80a/`, from `80-CC0-creature-SFX.zip`, Nov 1 browser batch) | 80 OGG | **License UNVERIFIED from a source page.** Evidence for CC0: the zip filename says CC0, and it is the same author/series as pack #2 (verified CC0 on its OGA page). Against: no license file inside the zip, no local license note, and the Oct 29 LICENSES.md records pack #1 as not-downloaded (no direct URL then) — the Nov 1 batch obtained it later without a recorded page check. **Do not ship any of the 80 until the OGA page for pack #1 is confirmed.** See `design-notes/oga-wiring-plan.md` — the plan is conditional on this confirmation. |
| Sonniss #GameAudioGDC bundles | 0 staged | License verified royalty-free, commercial use, no attribution required (per LICENSES.md, citing sonniss.com/gdc-bundle-license). Bundle not downloaded (2026 bundle alone 7.47 GB). Future pickup only — cherry-pick creature vocals if the size budget allows. |
| Freesound CC0 | 0 staged | Account required to download; not used. Future pickup only (account-gated). |
| Pixabay | 0 staged | No Pixabay files exist in any local inventory. Listed as a backbone source only — zero indexed files until something is actually staged. |

## D. Prototyping only — on disk, never indexed as shippable

| Item | Files | Location | Reason |
|---|---|---|---|
| SoundFactory banshee wail (1.0 s) + goblin growl (2.0 s), Nov 1 — passed James's quality gate | 5 files (raw + trimmed mp3/wav) | `~/workspace/browser_downloads/sess-1935329151/` | No accessible SoundFactory terms/license found (Nov 4 check). Quality-passed, license-blocked. |
| Violet Recording | 0 files | — | Tool page advertises royalty-free; Terms grant only personal/non-commercial site access, no output license. Nothing generated, nothing staged. |
| BBC / Meta AudioCraft / Zapsplat-free / SFXMint | 0 files | — | Never staged; license bars shipping (see gate above). |

## E. What is NOT in this index (and why)

- `assets/resources-phase1/audio/analysis/` — analysis artifacts, not sounds.
- `assets/audio/alkakrab/` format duplicates — counted once per pack above
  (369 files is the on-disk count including duplicates; the distinct
  track count is far smaller).
- The Nov 1 itch.io zips (Quaternius, LOWPO, Gobkit) — models, not audio.
- Anything whose license could not be verified from local inventory is
  in section C, not in sections A/B. Nothing was indexed on filename
  alone.

## Totals

- Shippable + staged: 670 (Phase 1 audio) + 368 (Kenney SFX) + Alkakrab
  music packs (369 staged files, format duplicates) = 1,407 on-disk
  files, of which 1,038 are SFX/vocal files and the rest are music
  (including duplicates).
- Wired vocal clips today: 397. After the OGA plan (conditional):
  455 (+58).
- Inventoried but blocked: 80 (OGA pack #1, license confirmation pending).
- Prototyping-only on disk: 5 (SoundFactory).
