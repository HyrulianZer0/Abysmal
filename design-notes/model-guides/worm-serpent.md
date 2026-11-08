# Archetype Guide — Worm / Serpent

Covers: worms, serpents, snakes, wyrms, eels, hydras, and serpent-folk
(lamia, amphiptere). Example rows: Burrow Worm, Carrion Worm, Cave Python,
Hydra, Jaculus, Amphiptere, Lamia, Naga, World Wurm, Zmey.

## Overview

A worm/serpent is a long, limbless, segmented body with a head at one end.
Build it as a chain of overlapping spheres (easy, forgiving) or as a single
tapered tube along a curve (smoother, slightly harder). The chain method is
described here; the curve method is noted at the end.

## Base primitives

- Body segments: 8–12 UV Spheres (16 segments, 12 rings), shrinking toward
  the tail.
- Head: 1 UV Sphere, slightly larger than the first body segment.
- Jaw (optional): 1 flattened box or cone under the head.
- Eyes (2): small UV Spheres on the head.
- Tongue (optional): 1 thin flattened cone, forked by scaling.

## Step by step (Blender, Z-up in the viewport)

1. Delete the default cube, camera, and light.
2. Place the head sphere at the front (say, Y = +1.0), radius ~0.22, center
   at Z = 0.25 (so the body rests near the ground).
3. Add body spheres behind the head along a gentle S-curve on the ground
   plane: each next sphere slightly smaller (×0.92) and overlapping the
   previous one by about half its radius, so the chain reads as one body.
   Keep every sphere's bottom at or above Z = 0 (lift the chain so nothing
   sinks below the ground plane).
4. Tail: end with the smallest sphere, or a cone pointing backward.
5. Head details: two small eye spheres on the head's upper sides; an
   optional flattened jaw box under the front of the head; an optional
   forked tongue (thin cone, scaled flat on Z).
6. Multi-head variants (Hydra): duplicate the head + first 2 segments and
   angle each neck outward from a shared body mass; 5+ heads for a hydra.
7. Woman-torso variants (Lamia): replace the head sphere with the
   biped-humanoid torso + head, attached to the front of the serpent chain.
8. Winged variants (Amphiptere): add wings per the winged guide, attached
   at the front third of the body, no legs.
9. Select all parts, Object > Apply > All Transforms.

## Proportions

- Total length: ~2.0–3.0 m for a large serpent, ~1.0–1.5 m for a small worm.
  (The game's ~1.0 target size is the bounding height; a serpent's height is
  small, so scale by length instead and note the row's target in the guide
  file for that creature.)
- Body radius at the head end: ~0.2 m, tapering to ~0.05 m at the tail.
- Head: ~1.2× the first body segment's radius.

## Defining features

- Segmentation reads as "worm": keep the sphere overlaps visible (do not
  merge into one smooth mesh on a first build).
- A head that is distinct from the body (bigger, with eyes) reads as
  "serpent" rather than "tentacle".
- Color and pattern carry the type: pink (burrow worm), putrid green-brown
  (carrion worm), banded (python), dark (wurm).

## Materials & colors

- Body: one material, Base Color per type, Roughness ~0.6 (damp skin, not
  glossy like a slime). A second, darker material on alternating segments
  gives banding cheaply.
- Eyes: dark glossy material. Tongue (if any): red/pink.
- Textures to the 1K realistic anchor; flat colors are fine for a first
  build.

## Rig & motion

- No armature needed for a first build. Procedural motion options:
  - Slither: animate the chain's segments along the S-curve (move each
    segment's X/Y slightly in sequence) — or, simpler, a gentle side-to-side
    sway of the whole body.
  - Breathe: a slow scale pulse on the body (1.00 → 1.02 → 1.00) works as an
    idle for a coiled serpent.
- Curve method (advanced): one tapered cylinder + a Curve modifier on a
  Bezier curve; animate the curve's shape for a smooth slither.

## Godot export notes

- Select all parts, File > Export > glTF 2.0 (.glb), format GLB, +Y Up
  enabled.
- Before export: Apply All Transforms; lowest vertex at Z = 0 in Blender
  (grounded at y = 0 in Godot).
- Scale: normalize so the bounding length matches the row's target (large
  serpents ~2.0–3.0 m long; small worms ~1.0–1.5 m). Note the chosen target
  in the creature's guide entry.
- Name the file `<creature>.glb` (lowercase, hyphens for spaces).
