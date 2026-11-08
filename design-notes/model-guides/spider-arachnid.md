# Archetype Guide — Spider / Arachnid

Covers: spiders, scorpions, centipedes, beetles, crabs, ants, and swarms.
Example rows: Cave Spider, Widow Spider, Cave Scorpion, Emperor Scorpion,
Centipede, Stag Beetle, Scarab Swarm, Ōmukade, Jorōgumo, Tsuchigumo.

## Overview

An arachnid is two body masses (front + rear) with many jointed legs. Build
the two masses first, then legs in pairs, then fangs/mandibles. Leg count
and shape carry the type: 8 legs (spider), claws + tail (scorpion),
many segments (centipede).

## Base primitives

- Front mass (cephalothorax): UV Sphere scaled to (0.8, 0.7, 0.5).
- Rear mass (abdomen): UV Sphere scaled to (1.0, 0.9, 0.6), slightly larger.
- Legs: 2 cylinders each (upper + lower), thin (radius ~0.04).
- Fangs/mandibles: small cones.
- Eyes: tiny spheres (spiders: a cluster of 4–8 on the front mass).
- Scorpion tail: 3–4 small spheres in an arc + a stinger cone.
- Centipede segments: a chain of small spheres (per the worm guide's chain
  method) with one leg pair per segment.

## Step by step (Blender, Z-up in the viewport)

1. Delete the default cube, camera, and light.
2. Front mass: UV Sphere radius 0.22, scaled to (1.0, 0.9, 0.7), at
   Y = +0.18, center Z = 0.32. Rear mass: UV Sphere radius 0.26, scaled
   to (1.0, 0.9, 0.7), at Y = −0.22, center Z = 0.34, slightly larger.
   Overlap them a little so they read as one body. (State the base
   radius, not just the scale: the scale figures alone, on a default
   radius-1 sphere, would build a ~2 m body whose masses sit apart
   instead of overlapping.)
3. Legs: 4 pairs for a spider (8 legs). Attach at the front mass sides:
   upper cylinder angling outward-down to a "knee" at Z = 0.22, lower
   cylinder from the knee down to the ground, foot endpoint at Z = 0.02,
   feet touching the ground plane. (The 0.02 matters: a tilted cylinder's
   cap rim dips ~0.015 below its endpoint, so an endpoint at Z = 0.0
   sinks the feet below the ground; 0.02 lands them exactly on it.)
   Front pairs angle forward, rear pairs angle backward.
4. Fangs: two small cones under the front of the front mass, pointing
   down-forward. Mandibles (beetle): two small cones at the front, pointing
   forward (stag beetle: large curved mandibles — use bent cylinders or
   rotated cones).
5. Eyes: 4–8 tiny spheres (radius ~0.03) on the top-front of the front
   mass.
6. Scorpion variant: replace the rear mass with a narrower abdomen, add
   two large claws at the front (sphere + pincer cones), and a tail: 3–4
   small spheres arcing up and forward over the body, ending in a stinger
   cone pointing down-forward.
7. Centipede variant: replace the two masses with a chain of 10–14 small
   spheres (shrinking toward the tail) along the ground, one short leg pair
   per segment (Ōmukade: giant version, same build, scaled up).
8. Swarm variant (Scarab Swarm): build ONE scarab (this guide, small);
   the game spawns many instances — do not model the whole swarm.
9. Spider-woman variant (Jorōgumo): spider body per this guide + a biped
   torso + head mounted on the front mass (per the biped guide).
10. Select all parts, Object > Apply > All Transforms.

## Proportions

- Body length (front + rear masses): ~0.6–0.8 m for a cave-spider-sized
  build; leg span: ~1.5–2.0× body length (legs splayed wide).
- Legs: thin (radius ~0.04) relative to body — spindly reads as arachnid.
- Total height: ~0.5 m (body sits low, legs splay out).

## Defining features

- Leg count and arrangement are the identifier: 8 splayed legs (spider),
  claws + raised tail (scorpion), many segments + many legs (centipede).
- The two-mass body (vs. one mass) separates arachnids from blobs and
  beetles-with-one-shell (beetles: one large rear shell + small head).

## Materials & colors

- Body: one material per type (cave spider dark brown-grey, widow black
  with a red mark — the mark needs a texture or a small red flattened
  sphere on the abdomen; scorpion chitin brown; centipede segmented
  banding via alternating segment materials).
- Legs: slightly darker than the body. Fangs/claws: dark glossy.
- Textures to the 1K realistic anchor; flat colors first.

## Rig & motion

- First build: no armature. Procedural motion options:
  - Breathe: slow abdomen scale pulse.
  - Skitter: tiny alternating leg rotations (front pairs vs. rear pairs)
    — reads as scuttling without a rig.
- Rigged build (advanced): one bone per leg segment is heavy; prefer a
  simple armature (body + 2 bones per front leg pair) and procedural
  motion for the rest.

## Godot export notes

- Select all parts, File > Export > glTF 2.0 (.glb), format GLB, +Y Up
  enabled.
- Before export: Apply All Transforms; feet at Z = 0 in Blender (grounded
  at y = 0 in Godot).
- Target size: leg span per the row's target (cave spider ~1.0 m span).
- Name the file `<creature>.glb` (lowercase, hyphens for spaces).
