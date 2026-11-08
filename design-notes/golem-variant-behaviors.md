# Golem Variant Behaviors (Nov 4, 2026)

Wiring round: the 5 geometrically-differentiated golem variants are wired
as ROSTER rows (no TYPES entry, no stats, no spawn — same status as the
other guide-built rows). They are static models, so like other guide-built
rows they use procedural motion until a TYPES step gives them a home.
These behavior assignments are spec-doc assignments for the systems step
to apply later; no game code changes were made here.

Shared base (all five): the Stone Golem spec (behavior-specs part-7) —
slow, grinding plod that blocks corridors by sheer bulk; wide ground
slam and a shoulder charge down straight lines, telegraphed by a
grinding crouch; drawn to noise and movement in its corridor, ignores a
quiet player in a side passage; counter is dodging the charge line, then
striking from the side during its slow turn after a missed charge;
deeper: charges come down longer lines and end in a slam, not just a
stop.

## golem-stone — Stone Golem (direct)

Behavior: the Stone Golem spec above, unchanged. Support: DIRECT — the
Stone Golem spec and lore entry both exist; the stone variant (moss
clumps + vine strands) is that spec's mesh. No flag.

## golem-fire — Stone Golem base + Magma Elemental flavor (Abysmal take)

Behavior: Stone Golem plod, slam, and charge, with Magma Elemental
flavor — molten slam at close range and a lobbed magma glob that bursts
into a burning patch, telegraphed by a long gather; the lava drips are
the magma source, and the trail it leaves is hot ground. Counter: keep
moving, never stand on its trail, and strike during the long gather
before a magma lob.
Support: ABYSMAL TAKE — no traditional fire or lava golem exists in
lore part-7 (golem lore covers Clay/Stone/Bone/Brass/Iron/Crystal);
this combines the Stone Golem spec with the Magma Elemental spec. The
Fire Elemental's flame lash is the recorded alternate flavor if James
prefers flame over magma.

## golem-ice — Stone Golem base + Frost Elemental flavor (Abysmal take)

Behavior: Stone Golem plod, slam, and charge, with Frost Elemental
flavor — freezing shard volley at range and a chilling slam at close
range, telegraphed by a brightening ice sheen; the ground it crosses
spreads frost that slows footing. Counter: strike during the sheen's
brightening, before the volley releases, and never fight standing on
its frost.
Support: ABYSMAL TAKE — no traditional ice golem in lore part-7; this
combines the Stone Golem spec with the Frost Elemental spec.

## golem-storm — Stone Golem base + Storm Elemental flavor (Abysmal take)

Behavior: Stone Golem plod, slam, and charge, with Storm Elemental
flavor — lightning bolt strikes telegraphed by a gathering charge
glow, plus a gusting shockwave burst. Counter: shelter under cover
during the charge glow, then strike in the quiet beat after a bolt
lands; bolts chain to storm-charged ground, so ground where a bolt
just fell is unsafe.
Support: ABYSMAL TAKE + adaptation note — no traditional storm golem
in lore part-7; this combines the Stone Golem spec with the Storm
Elemental spec. The Storm Elemental's crackling leaping flight does
NOT adapt (the variant is ground-based); only the bolts and the
shockwave carry over.

## golem-water — Stone Golem base + Water Elemental flavor (Abysmal take)

Behavior: Stone Golem plod, slam, and charge, with Water Elemental
flavor — crashing wave slam at close range and a surging water jet at
range; after each slam it reforms, and that thinnest moment is the
strike window. Counter: hold high, dry ground and strike as it reforms
after a slam.
Support: ABYSMAL TAKE + adaptation note — no traditional water golem
in lore part-7; this combines the Stone Golem spec with the Water
Elemental spec. The Water Elemental's flowing, splitting advance does
NOT adapt (the variant plods); only the slam, the jet, and the
reform window carry over.

## Elemental camouflage — active blend (James, Nov 4 — proposal)

Idea (James): a golem blends into its own element — a stone golem in
a stone-surrounded dungeon may go unseen until too late unless the
player's perception is high enough to spot even the smallest things.
Kind of like active camouflage.
- Rule (proposal): when a variant's element matches the dungeon theme
  (stone in stone, fire in ember/foundry, ice in frozen vault, storm
  in storm spire, water in flooded deep), the golem is camouflaged:
  the player must pass a perception check to spot it before it acts.
  Unspotted = the golem gets the drop (surprise first action — mirrors
  the mimic "free first bite" rule, adapted for golems).
- Themes are random (locked), so camouflage is situational, not
  constant: when the theme does NOT match the variant's element, no
  camouflage (reduced blend is TBD, not assumed).
- Perception (proposal): high perception spots even small tells; low
  perception misses until too late. Threshold numbers TBD — same open
  item as mimic perception numbers; none invented here.
- Tells (proposal, for the systems step): each variant keeps a small
  tell even when blended (stone: moss/vine seam; fire: lava glow;
  ice: ice sheen; storm: charge crackle; water: ripples) — high
  perception catches the tell.
- Player setting (James, Nov 4): ambush/jump-scare intensity —
  toned down / standard / harsher ("why not all"). Even though
  Abysmal has no horror monsters or Phasmophobia-style content,
  surprise mechanics can still startle: toned down softens the
  surprise, standard is as designed, harsher intensifies it. Applies
  to ALL surprise mechanics (golem camouflage + mimic free first
  bite), not just golems. Exact effects TBD (systems step).

## Open items (systems step, not decided here)

- Variant selection: how a golem-type spawn picks among the five
  variants is undecided. The animated TYPES golem (Clay Golem election
  model, golem_mirrored.glb) is UNTOUCHED by this round — in-game golem
  spawns still use it until a variant-selection step is decided.
- Stats/bands: none invented. TYPES promotion of any variant is still
  a systems-step design task.
- Paint note: emissive rune materials (all five), emissive lava drips
  (fire), and emissive bolts (storm) were left untextured by the
  glow/lightning skip rules — correctly, since they genuinely glow
  (emissiveFactor present); they keep their glow read instead of a
  diffuse texture.
