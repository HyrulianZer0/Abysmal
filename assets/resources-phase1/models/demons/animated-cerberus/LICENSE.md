# Animated Cerberus — license note (Phase 1b, Oct 29, 2026)

- **Source page:** https://opengameart.org/content/animated-cerberus
- **Direct files:**
  - https://opengameart.org/sites/default/files/cerberus_v002.blend
    (1,254,592 bytes, matching the page's "1.3 Mb" listing)
  - https://opengameart.org/sites/default/files/cerberus_texture_0.png
    (downloaded as `cerberus_texture.png`, the display name on the page;
    81,295 bytes, matching the page's "81.3 Kb" listing)
- **Authors:** Clement Wu, Nikolaus & Botanic (submitted by Botanic)
- **License CHOSEN: CC-BY 3.0** — picked from the multi-license offer on
  the source page (CC-BY 3.0 / CC-BY-SA 3.0 / GPL 3.0 / GPL 2.0; user
  picks one). CC-BY 3.0 was chosen deliberately because it is the
  non-copyleft option: it requires attribution only, and does NOT
  impose share-alike or GPL terms on Abysmal. No copyleft decision is
  triggered by this choice — had CC-BY-SA or GPL been picked, that
  would have been flagged for a decision instead.
- **Attribution string (REQUIRED under CC-BY 3.0 — must appear in the
  game credits):**
  `Animated Cerberus by Clement Wu, Nikolaus & Botanic (CC-BY 3.0)`
- **Contents:** `cerberus_v002.blend` (fully animated: Attack, Idle, Hit,
  Pose, Walk per the source page) + `cerberus_texture.png`.
- **Roster fit (proposal, not wired):** Cerberus (apex boss, hellhound).

## Wave 1B re-export note (Oct 29, 2026) — ⚠️ HELD, DO NOT WIRE

- New export: `cerberus_v002_full.glb` (333,540 bytes) — 5 clips
  (`Attack`, `die`, `hit`, `Idle`, `Walk`), 49-joint skin, texture
  embedded. The old `cerberus_v002.glb` (Walk only, flat grey) was
  left untouched for reference.
- **Correction to the contents line above:** the source `.blend`
  actually contains `Attack`, `Idle`, `hit`, `Walk`, and `die` — there
  is **no `Pose` action in the file**, so no Pose clip could be
  recovered and none was authored.
- **HELD per the Wave 1B brief:** this file must NOT be wired into
  the game until the CC-BY 3.0 election is confirmed (the source page
  offers CC-BY 3.0 / CC-BY-SA 3.0 / GPL 3.0 / GPL 2.0). The election
  recorded above is unchanged by this note; Wave 2 must confirm it
  before any in-game use. Re-export method (NLA strips + texture
  re-link, source `.blend` not saved): see `phase1b-oga-ledger.md`
  addendum and `.wave1b-logs/fix_cerberus_export.py`.
