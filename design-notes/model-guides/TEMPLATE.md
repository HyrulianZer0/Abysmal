# Template — New Creature Guide

Copy this file when a creature needs its own guide (rather than just an
archetype guide + tweaks in INDEX.md). Save it as
`<creature>.md` in this folder and point the creature's INDEX.md row at it.

---

# Creature Guide — <Name>

- Family: <family from the bestiary tracker>
- Archetype: <one of the 10 archetype guides>
- Survey status: <FOUND / STAND-IN / NO MODEL FOUND / wired / pending>
- Target size: <height in meters, e.g. ~1.0; note if length- or span-based>
- Grounding: <grounded at y=0, or hover height in meters>

## Defining features

- <The 2–4 features that make this creature read as itself, not its
  archetype. E.g. "two heads", "six wings", "serpent hair", "no legs".>
- <Color/pattern notes that carry the type.>

## Build notes (differences from the archetype guide)

1. <Step that differs, with primitives and numbers.>
2. <Another differing step, or "none — follow the archetype guide as-is.">

## Materials

- <Material 1: color + roughness/metallic/emission.>
- <Material 2, if any.>

## Motion

- <Idle: breathe pulse / sway / bob / hop / slither / flap — pick one and
  give its parameters (amplitude, speed).>
- <Any special motion the row needs, or "none beyond idle".>

## Export checklist

- [ ] All transforms applied.
- [ ] Lowest point at Z = 0 in Blender (or hover height noted above).
- [ ] GLB, +Y Up, file named `<creature>.glb`.
- [ ] Visual review by James before wiring (nothing here is pre-approved).
