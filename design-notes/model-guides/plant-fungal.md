# Archetype Guide — Plant / Fungal

Covers: treants, mushroom folk, sprouts, flowers, vines, moss creatures,
and plant spirits. Example rows: Walking Oak, Vampire Vine, Corpse
Flower, Mandrake, Spore Servant, Grotto Snapper, Fungal Shambler, Leshy,
Dryad, Cedar Guardian.

## Overview

A plant/fungal creature is built from plant parts: a trunk or stem, a
canopy or cap, and roots or vines. It is usually slow and bulky. Build
the stem first, then the canopy/cap, then the face/details (if any).

## Base primitives

- Trunk/stem: cylinder (radius ~0.15–0.25, height per type).
- Canopy: 3–5 UV Spheres clustered at the top (treant, dryad).
- Mushroom cap: UV Sphere scaled flat (Z ~0.4) or a cone, on a stem.
- Roots/vines: thin cylinders, curved by rotation, at the base.
- Flower bloom: flattened spheres (petals) arranged in a ring + a center
  sphere.
- Face (optional): small dark spheres (eyes) + a slit (thin box) on the
  trunk/cap.

## Step by step (Blender, Z-up in the viewport)

1. Delete the default cube, camera, and light.
2. Trunk/stem: cylinder centered at Z = half its height, so its base is
   at Z = 0. Treant: radius 0.22, height 1.4. Mushroom folk: radius 0.15,
   height 0.6. Vine creature: thinner radius 0.08, longer, and curved
   (rotate segments).
3. Roots: 3–5 thin cylinders from the trunk base, angled outward and down
   to Z = 0, splayed like feet. These ground the model. Proof note: aim
   root ends at Z ≈ 0.05, not exactly 0 — a cylinder's own radius can
   push its lowest vertices below the ground plane and break the
   grounded (min Z = 0) check; the stem base at Z = 0 is what grounds
   the model.
4. Canopy (treant/dryad/leshy): 3–5 spheres (radius ~0.35) clustered at
   the top of the trunk, overlapping, forming a crown. Add 2 arm branches:
   thick cylinders from the upper trunk, angled outward-down, with
   twig fingers (thin cylinders) at the ends.
5. Mushroom cap (mushroom folk, spore servant): a flattened sphere or
   cone on top of the stem, radius ~0.4, plus a small face (two dark eye
   spheres) on the stem under the cap if the type has one.
6. Flower (Corpse Flower): a wide ring of petal spheres (6–8 flattened
   spheres, radius ~0.25) around a center sphere (radius ~0.3), on a short
   thick stem; petals angled outward-up like an open bloom.
7. Vine (Vampire Vine): a coiling chain of thin cylinders along the
   ground + a few thorn cones + a small maw (two flattened boxes as jaws)
   at one end if the type has one.
8. Snapper (Grotto Snapper): a low plant with two jaw halves (flattened
   boxes hinged at the base) + teeth (small cones along the jaw edges).
9. Shambler (Fungal Shambler): a biped-shaped fungal mass — use the
   biped-humanoid proportions with a mushroom cap on the head and lumpy
   (overlapping-sphere) limbs instead of clean cylinders.
10. Select all parts, Object > Apply > All Transforms.

## Proportions

- Treant: total height ~1.8–2.2 m (tall; scale to the row's target).
- Mushroom folk: ~0.8–1.2 m. Flower: bloom diameter ~0.8–1.0 m on a
  0.5 m stem. Vine: length ~1.5–2.0 m along the ground.
- Roots splay to ~0.8× the canopy width for stability in the silhouette.

## Defining features

- Plant parts (not animal parts): trunk, canopy, cap, petals, roots.
- The face, if any, is minimal (eyes on the trunk/cap) — plants do not
  get full animal faces on a first build.
- Color carries the type: greens (treant, vine), browns (oak), spotted
  caps (mushroom), carrion reds/purples (corpse flower).

## Materials & colors

- Bark/stem: brown, Roughness ~0.9 (matte).
- Leaves/canopy: greens, Roughness ~0.8. Cap: per type (red with white
  spots needs a texture or small white spheres dotted on the cap).
- Flower: petal red/purple, center yellow-green.
- Textures to the 1K realistic anchor; flat colors first.

## Rig & motion

- First build: no armature. Procedural motion options:
  - Sway: slow rotation of the canopy/cap (a few degrees) — reads as alive.
  - Breathe: slow scale pulse on the trunk/canopy.
- Rigged build (advanced): rarely needed for plants; a simple trunk bone
  + branch bones if the game needs a swipe attack.

## Godot export notes

- Select all parts, File > Export > glTF 2.0 (.glb), format GLB, +Y Up
  enabled.
- Before export: Apply All Transforms; roots at Z = 0 in Blender
  (grounded at y = 0 in Godot).
- Target size: per the row's target (treant tall, mushroom folk ~1.0 m).
- Name the file `<creature>.glb` (lowercase, hyphens for spaces).
