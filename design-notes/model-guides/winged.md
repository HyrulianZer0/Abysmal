# Archetype Guide — Winged

Covers: bats, wasps, harpies, birds, pixies, sprites, phoenixes, dragons,
and winged humanoids (valkyries, seraphs). Example rows: Cave Bat, Cave
Wasp, Harpy, Pixie, Sprite, Phoenix, Fallen Valkyrie, Seraph, Cockatrice,
Wyvern.

## Overview

A winged creature is a body (biped, quadruped, or serpent, per the relevant
guide) plus a pair of wings. Build the body first from its own archetype
guide, then add wings. The wings are the defining feature — get their size
and attachment right and the rest follows.

## Base primitives (wings, per wing)

- Wing membrane/shape: 1 flattened, tapered box, or a plane extruded to
  give it thickness (scale Z to ~0.05).
- Wing fingers/struts (bat/dragon style): 3–4 thin cylinders fanning from
  the shoulder.
- Feathers (bird style): a row of small flattened cones along the wing's
  trailing edge.
- Wing shoulder joint: 1 small sphere where the wing meets the body.

## Step by step (Blender, Z-up in the viewport)

1. Build the body first from its archetype guide (biped for harpy/valkyrie/
   seraph; quadruped for griffin-style beasts; serpent for amphiptere-style;
   small biped for pixie/sprite). Keep the body at its normal ground
   position — wings do not change grounding.
2. Wing shape: add a flattened box, scale it to roughly (0.7 long, 0.35
   wide, 0.05 thick) for a human-sized flier, and taper it: in Edit Mode,
   move the outer end's vertices inward so the tip is narrower than the
   root. (Mirror it for the other side, or build one wing and use a Mirror
   modifier across X = 0.)
3. Attach: place the wing root at the shoulder (biped: Z ~0.95 for a
   human-sized ~1.7 m body; scale with body height — about 0.75× body
   height, so ~0.75 for a 1.0 m generic proof — X = ±0.30, scaled likewise
   for smaller bodies). Angle the wing slightly upward at rest
   (tips above the shoulder line reads as "ready to fly"; drooping tips
   read as "resting"). Proof note: a 12–20° upward tilt reads best, and
   preview a winged build from a 3/4 angle — a straight front view sees
   horizontal wings edge-on, as thin slats, and hides the membrane.
4. Bat/dragon style: add 3–4 thin cylinders from the shoulder joint
   fanning across the wing membrane, longest at the front edge.
5. Bird style: add a row of small flattened cones along the trailing edge,
   overlapping like feathers, longest near the middle of the wing.
6. Harpy/valkyrie/seraph: wings attach at the shoulder blades of the biped
   body; the body keeps its arms (harpy also gets taloned legs — claws from
   small cones on the feet).
7. Pixie/sprite: wings are small and delicate — dragonfly style: two pairs
   of thin, translucent-looking flattened planes per side, total wingspan
   ~1.5× body height; body scale ~0.3 m total (tiny fey). Proof note:
   size the dragonfly wings to actually reach that 1.5× span — a 0.3
   length factor gave only a 0.225 m span on a 0.3 m body, while 0.6
   lands at 0.45 m ≈ 1.5× body height.
8. Seraph: six wings — three pairs at shoulder, mid-back, and lower back,
   each pair smaller going down.
9. Select all parts, Object > Apply > All Transforms.

## Proportions

- Wingspan: ~1.5–2.0× body height for a strong flier (bat, harpy, dragon);
  ~1.2× for a small flier (pixie, wasp — wasp wings are small membranes,
  span ~1.0× body length).
- Wing root chord (front-to-back at the shoulder): ~0.4× wingspan per wing.
- Body scale per its own archetype guide (pixie ~0.3 m, harpy ~1.7 m,
  phoenix ~1.0 m, wyvern ~2.0 m+).

## Defining features

- Wing shape carries the type: membrane + fingers (bat/dragon), feathers
  (bird/valkyrie/phoenix), insect membrane (wasp/pixie), six wings (seraph).
- A winged silhouette must read from the side: wings above the body line,
  not hidden behind it.

## Materials & colors

- Membranes: one material per type (bat dark brown-grey, dragon leathery,
  wasp translucent amber — keep opaque for export safety on a first build,
  pixie pale iridescent).
- Feathers: a second material, lighter than the body, with a darker tip
  color if you add separate tip cones.
- Textures to the 1K realistic anchor; flat colors first.

## Rig & motion

- First build: no armature. Procedural motion options:
  - Flap: rotate both wings around their root (X-axis at the shoulder)
    ±25° in opposite phase — reads as flying/hovring without a rig.
  - Breathe: body scale pulse for a perched idle.
- Rigged build (advanced): add 2 wing bones per wing (root + tip) to the
  body's armature; flap by rotating the root bone.

## Godot export notes

- Select all parts, File > Export > glTF 2.0 (.glb), format GLB, +Y Up
  enabled.
- Before export: Apply All Transforms; feet (or body bottom, for a
  hovering pose) at Z = 0 in Blender. Note: if the creature is posed
  hovering, the guide for that row should say so — otherwise ground it.
- Target size: per the row's target (body height); wingspan follows the
  proportions above.
- Name the file `<creature>.glb` (lowercase, hyphens for spaces).
