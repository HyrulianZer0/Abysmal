ABYSMAL — House Texture Pack (own resource pack)
Producer/Director: Aethelwarden Solas

STATUS: DECIDED Nov 1, 2026 (James). Not built yet — this is the
blueprint a future push builds from.

## The decision

Blend all dungeon/model textures into ONE house resource pack —
Abysmal's own pack — instead of shipping each source family's look
side by side. The pack is a treatment pipeline, not a replacement
program: source textures go in, house-style textures come out.

## Anchor: 1K quality, realistic

- Target resolution: 1K (1024x1024). NOT 4K; 2K likely too high.
  (James, Nov 1: "1k quality is the anchor i want.")
- Look: realistic, unified finish — same palette family, same
  finish, same filtering across every texture. Photoreal sources
  need linear filtering (dungeon_view.gd currently uses
  TEXTURE_FILTER_NEAREST for pixel art — the pack pass must set
  filtering per the house style, not inherit the pixel-art default).
- Reference point (James): Minecraft vanilla is 16x16 per texture;
  1K is 64x that per side — far more detail, still phone-kind.
  Android-first target: 1K stays light on memory and GPU where
  2K/4K would not.

## Quality tiers — 1K is high/extreme, lower is fallback ONLY

Decided Nov 1, 2026 (James): 1K is the high/extreme setting. Lower
resolutions (512, then 256) exist ONLY as a fallback, if need be —
for weaker devices or if performance demands it. The fallback costs
almost nothing extra to produce: the pack pipeline already
downscales sources to 1K, so 512/256 variants are the same step
with a smaller target. Hooks into the existing Quality setting
(High/Low) in the Settings panel; fallback is BOTH player-chosen
(Low setting) and automatic (drop a tier when the game struggles).
Decided and signed Nov 1, 2026 (James).

Nov 1: settings tiers High/Medium/Low; starting standard (default)
= 512; High = 1K maximum; Low = 256 fallback. The anchor is
unchanged (1K stays the top tier) — 512 is simply the out-of-box
setting players start on. Confirmed Nov 1 (James): Medium = 512
starting standard, High = 1K maximum, anchor unmoved,
player-adjustable.

## Expansion ladder (proposed Nov 1, if we expand)

- 1K: high/extreme
- 512: high/medium
- 256: medium/low
- 128: low

Same power-of-two downscale steps as the fallback ladder, with 128
added as the bottom rung for the weakest devices. This does not
change the signed anchor — 1K high/extreme stays the top tier; the
extra rungs wait in the wings until expansion is wanted.

## What the pack does NOT fix

Texture blending unifies surfaces. Geometry differences remain
(Quaternius cartoon shapes vs PS1 blocky vs Gobkit stylized vs
realistic proportions) — they matter less once materials speak one
language, but they do not vanish. A geometry pass is a separate
decision, not part of this pack.

## Credit — resources AND inspiration

Policy (James, Nov 1): the pack still credits every original dev,
for resources and for inspiration. Pack manifest lists each source
as "blended and re-textured for Abysmal." CC-BY sources REQUIRE
credit + a note that the work was changed; CC0 sources are credited
under the credit-them-all policy. The pack's LICENSES file carries
the full source list (see assets/resources-phase1/*/LICENSES.md).

## Sources feeding the pack (Oct 27 set)

- Poly Haven CC0 1K diffuse JPGs (~19 MB, 24 textures, 9 variation
  folders) in assets/textures/dungeon/ — the pack's starting body.
- Model textures from Phase 1/1b (Gobkit, PS1, Kenney, 3DAssets.dev,
  OGA) as their models wire in.
- Missing sets (Flooded Deep, Bone Wastes, Fungal Grotto, Void Scar,
  Storm Spire) join the pack when sourced; Thornwild ≈ forest +
  mossy_dark until then.
