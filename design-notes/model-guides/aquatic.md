# Archetype Guide — Aquatic

Covers: fish, sharks, octopuses, krakens, merfolk, water horses, and
amphibians. Example rows: Cave Frog, Giant Octopus, Kraken, Kelpie,
Selkie, Merrow, Nixie, Naiad, Mami Wata, Makara, Ahuizotl, Afanc.

## Overview

An aquatic creature is a streamlined body built for water, with fins or
tentacles instead of legs. Build the body first (streamlined, horizontal),
then fins/tentacles, then the head details. Note: most aquatic rows are
built for dungeon water features or as swimmers — ground them at Z = 0
like any other model unless the row says hovering/swimming.

## Base primitives

- Body: UV Sphere scaled to (0.6, 1.4, 0.6) — long along Y (horizontal).
- Fins: flattened cones or planes (scale Z to ~0.05).
- Tail fin: flattened cone or two flattened boxes angled apart.
- Tentacles (octopus/kraken): tapered cylinders (radius 0.10 → 0.02),
  8 for an octopus, more for a kraken.
- Eyes (2): small spheres on the head sides.
- Frog legs (amphibian): 2 cylinders each, long hind legs folded
  (thigh + shin angled like a Z).

## Step by step (Blender, Z-up in the viewport)

1. Delete the default cube, camera, and light.
2. Body: UV Sphere radius 0.35, scaled (0.6, 1.4, 0.6), center at
   Z = 0.21. That gives a 0.42 m wide, 0.98 m long, 0.42 m tall fish,
   grounded at Z = 0. General rule: center Z = half the scaled height
   (base radius × Z-scale), so the body's bottom sits exactly on the
   ground — state the base radius, not just the scale, or a default
   radius-1 sphere at the old center Z = 0.35 floats 0.05 above the
   ground and builds a 1.4 m body. The long axis runs front-to-back (Y).
3. Head end: the front (+Y) of the body is the head. Add two eye spheres
   on the upper sides near the front.
4. Fins: dorsal fin (flattened cone on top, mid-body), pectoral fins (two
   flattened cones on the sides, angled back), tail fin (flattened cone or
   two angled boxes at the rear, −Y end).
5. Shark variant: add a pointed snout (cone at the front), a tall dorsal
   fin, and a gill suggestion (3 thin dark lines per side — thin boxes
   slightly embedded in the body, or a texture later).
6. Octopus/kraken variant: replace fins with tentacles — 8 (octopus) or
   more (kraken) tapered cylinders radiating from the body's underside,
   curving outward and down, tips touching or near the ground plane.
   Proof note: keep tentacle tip height at ~0.015, not 0.03 — at 0.03
   the reimport AABB min Z measured 0.017, outside the 0.01 tolerance.
   Kraken: build at reduced scale (a colossal kraken is scaled by the game;
   the model itself stays ~1.0–2.0 m) and note the scale in the row entry.
7. Merfolk variant (selkie human-form note aside — build the animal form
   for selkie): fish tail (flattened cone pair) + a biped torso + head at
   the front (per the biped guide, waist up only). Proof note: the
   tail-cone tip must reach Z = 0 — at Z = 0.02 the tail floats 2 cm
   above the ground on reimport.
8. Water-horse variant (kelpie, afanc): quadruped body (per the quadruped
   guide) with a mane of reeds (thin cylinders along the neck) and webbed
   feet (flattened boxes); dark, wet coloring.
9. Frog variant (Cave Frog): squat body (sphere scaled (0.8, 0.7, 0.5)),
   big folded hind legs (thigh + shin in a Z fold at the sides), small
   front legs, large eye spheres on top of the head, wide mouth (thin dark
   box across the front, or a texture later). Hop motion: see Rig notes.
   Proof note: set the shin endpoint at Z = 0.04, not 0.02 — a tilted
   cylinder's end-cap rim dips below its endpoint, and at 0.02 the
   reimport min Z measured −0.0155 (below ground).
10. Select all parts, Object > Apply > All Transforms.

## Proportions

- Fish/shark body: length ~1.5–2.0× height; fins ~0.3× body length.
- Octopus: tentacle span ~1.5× body diameter; body ~0.6 m across.
- Frog: squat — height ~0.5× length; hind legs folded, longer than the body.
- Merfolk: torso ~0.5 m + tail ~1.0 m.

## Defining features

- Streamlining (no legs, fins/tentacles) is the identifier.
- Fin placement: dorsal on top, pectoral on the sides, tail at the rear.
- Frog: the folded hind legs and big eyes are the whole read.

## Materials & colors

- Body: one material per type (fish silver-blue, shark grey, octopus
  mottled brown-purple, frog moist green-brown, kelpie dark wet black).
- Fins/tentacles: slightly darker or translucent-looking material (keep
  opaque for export safety on a first build).
- Wet sheen: Roughness ~0.3, Specular ~0.5.
- Textures to the 1K realistic anchor; flat colors first.

## Rig & motion

- First build: no armature. Procedural motion options:
  - Swim: gentle side-to-side sway of the whole body + tail-fin rotation
    (a few degrees, slow loop).
  - Frog hop: Location Z arc (up and forward, then back) — the procedural
    hop the Cave Frog row needs.
  - Breathe: slow body scale pulse for a resting aquatic.
- Rigged build (advanced): a spine chain (head → tail) with fin bones;
  swim by rotating the spine bones in sequence.

## Godot export notes

- Select all parts, File > Export > glTF 2.0 (.glb), format GLB, +Y Up
  enabled.
- Before export: Apply All Transforms; lowest point at Z = 0 in Blender
  (grounded at y = 0 in Godot; for a swimmer row, note the hover height
  in the row entry instead of grounding).
- Target size: per the row's target (fish ~1.0 m long; kraken model
  ~1.0–2.0 m, game scales it up).
- Name the file `<creature>.glb` (lowercase, hyphens for spaces).
