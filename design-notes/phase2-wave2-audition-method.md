# Phase 2 Wave 2 — Audio audition method (STEER, parent directive)

Literal listening is IMPOSSIBLE in this container: no ears, no audio
playback, Audacity cannot launch here (no FUSE/display). Do NOT treat
"audition before wiring" as blocked. Use these three layers instead.

## Priorities (James, Oct 29 — refines this steer)
- **Layer 1 (scripted analysis) = YES, full run.** Mandatory, every
  file actually wired.
- **Layer 2 (spectrogram spot-checks) = MAYBE, trial it.** Attempt
  it, and report whether it proved useful or not — a trial, not a
  guaranteed pass.
- **Layer 3 (per-family audition reels) = BUILD AS BACKUP.** Still
  produce the reels, but as a fallback set for when James is swamped
  with other things — NOT the primary path. The primary verdict
  comes from Layer 1 (full) + Layer 2 (trial).
Nothing else in this steer changes.

## Layer 1 — Scripted analysis of every file actually wired [FULL RUN]
For each audio file wired into the enemy system, measure with
ffmpeg/ffprobe (VERIFIED present on this VM: /usr/bin/ffmpeg,
/usr/bin/ffprobe; sox and librosa are NOT installed — do not depend
on them):
- duration, sample rate, channels
- RMS loudness + peak level
- spectral centroid / bandwidth (via ffmpeg astats/astats + afftdn
  or showfreqs-style analysis as available)
- silence detection (silencedetect), clipping detection, and
  duplicate detection (audio fingerprint/hash comparison)
This objectively flags broken or mislabeled files — e.g. a "roar"
that is 0.2s of near-silence, a file that is all clipping, or two
"different" vocals that are byte-identical. Any flagged file is NOT
wired until a human (James) confirms it, and the flag is recorded.

## Layer 2 — Spectrogram spot-checks per family [TRIAL]
Generate spectrograms with ffmpeg showspectrumpic for at least one
representative file per vocal family wired, and review them visually:
a growl's spectrogram vs a squeak's are structurally different, so
this catches family-level mislabels that raw numbers miss. Save the
spectrogram images next to the analysis results, note any mismatch
found, AND report whether this layer proved useful — it is a trial,
and an honest "it did not help" is an acceptable result.

## Layer 3 — Per-family audition reels for James [FALLBACK SET]
Build ONE concatenated clip per vocal family actually wired (not 670
individual files) and save them under
assets/resources-phase1/audio/ (e.g. reels/vocals-undead-reel.mp3).
These are a BACKUP for when James is swamped with other things, not
the primary path: they exist so he can still listen on his own
devices when he has competing demands, rather than being the default
gate for every file. List every reel path in the audio catalog.

## Recording
Record the Layer 1 analysis results (per file, pass/flag + reason),
the Layer 2 trial notes (including whether it proved useful), and
all reel paths in assets/resources-phase1/audio/CATALOG.md (append
a Wave 2 audition section; do not rewrite the Phase 1 catalog).
Flagged files stay unwired pending James's confirmation.

## Unchanged
Exclusions stand (3DAssets.dev AI models held, Cerberus/Fire-Ice-
Stone Golem/Bone Golem elections unconfirmed, itch.io/Freesound/
paid/ripped forbidden). BUILD ONLY — no APK, no release, no publish.
