# Archetype Guide — Golem / Construct

Covers: golems, constructs, animated armor, statues, automatons, and
object-spirits. Example rows: Clay Golem, Stone Golem, Iron Golem,
Gargoyle, Ushabti, Terracotta Soldier, Karakasa, Ophanim.

## Overview

A golem/construct is a heavy, blocky figure built from hard materials:
stone, clay, iron, or animated objects. Build it from boxes and cylinders
with visible joints — chunky beats smooth here. Weight is the whole read:
wide stance, thick limbs, small head relative to body.

## Base primitives

- Torso: box with beveled edges (or a cube scaled to (0.8, 0.5, 0.9)).
- Head: box or cube, smaller than the torso.
- Arms (2): 2 boxes/cylinders each (upper + forearm), thick (radius ~0.14).
- Legs (2): 2 boxes/cylinders each (thigh + shin), thick, with wide feet
  (flattened boxes).
- Joints: small spheres or short cylinders at shoulders, elbows, hips,
  knees.
- Fists: boxes or spheres, oversized.
- Runes (optional): thin emissive planes on the torso/head.

## Step by step (Blender, Z-up in the viewport)

1. Delete the default cube, camera, and light.
2. Legs: two thigh boxes from Z = 0.75 down to Z = 0.40, and two shin
   boxes from Z = 0.40 down to Z = 0.05, at X = ±0.28 (wide stance). Feet:
   flattened boxes at Z = 0.03, larger than humanoid feet.
3. Torso: beveled box centered at Z = 1.05, roughly 0.85 wide, 0.55 deep,
   0.70 tall — massive relative to the head.
4. Arms: shoulders at Z = 1.30, X = ±0.55. Upper boxes down to Z = 0.95,
   forearms down to Z = 0.60, fist boxes at Z = 0.55 (fists hang low and
   large — golem fists are ~1.5× humanoid hands).
5. Head: box at Z = 1.55, ~0.35 across — small relative to the torso.
   Eyes: two small emissive spheres or boxes on the face (glowing eyes
   read as "animated" instantly).
6. Joints: small spheres at shoulders, elbows, hips, knees — visible
   joints sell "constructed" over "grown".
7. Runes (optional): thin emissive planes on the chest and forehead
   (a glowing line or symbol — keep it simple: a straight glowing slit
   reads as a rune at game scale).
8. Elemental variants (the 5 golem colorways in the project spec): same
   mesh, different materials — ice (light blue, near base), stone (grey,
   cracked + moss/vines: thin green cylinders along the sides), fire
   (red + dripping lava: small orange emissive drips), storm (purple +
   lightning: emissive white-blue zigzag planes), water (blue + dark blue
   + coral/seaweed on the feet: small pink/green blobs at the base).
9. Object-spirit variant (Karakasa): an umbrella — cone (canopy) + thin
   cylinder (handle) + one eye sphere + one leg cylinder, hopping pose.
   Proof note: place the eye sphere ON the canopy surface (proof build:
   Y = 0.42 on the surface) — an eye placed deeper (Y = 0.30) sits
   buried inside the cone and does not read.
10. Wheel variant (Ophanim): a torus (wheel) + eye spheres spaced around
    its rim + a smaller inner torus, spinning (see Rig notes). Proof
    note: rotate the tori 90° about X so the wheel faces the camera
    plane — a default torus lies in the XY plane and reads edge-on
    from a front camera; place the rim eyes in the matching plane.
11. Select all parts, Object > Apply > All Transforms.

## Proportions (total height ~1.9 m for a standard golem, per the project)

- Legs: ~0.75 m. Torso: ~0.70 m tall, ~0.85 m wide. Head: ~0.35 m.
- Proof note: the step-by-step Z values above actually sum to ~1.73 m
  (head center 1.55 + half-height 0.175), not 1.9 m. To hit 1.9 m, scale
  all step sizes and Z positions ×1.10; to hit a ~1.0 m proof/target,
  scale them ×0.58 (feet bottom stays at Z = 0 either way).
- Stance: wide (feet ~0.55 m apart) — stability reads as weight.
- Fists: ~0.25 m across (oversized vs. a humanoid hand).

## Defining features

- Blocky, angular silhouette — no soft curves (contrast with blobs and
  beasts).
- Visible joints and seams (segmented limbs, not one smooth mesh).
- Glowing eyes/runes: the "it is alive" signal for a construct.

## Materials & colors

- Stone: grey, Roughness ~0.95. Clay: brown, Roughness ~0.9. Iron: dark
  grey, Metallic ~0.6, Roughness ~0.5. Ice: light blue, Roughness ~0.3.
- Eyes/runes: emissive material (orange for fire, blue for ice/storm,
  green for moss-light), Emission Strength 2–4.
- Moss/vines: green, small cylinders/planes on the sides (stone variant).
- Textures to the 1K realistic anchor; flat colors first.

## Rig & motion

- First build: no armature. Procedural motion options:
  - Stomp: slow, heavy Location Z bob on alternate steps (or just a
    breathe pulse for an idle — golems idle well).
  - Wheel spin (Ophanim): rotate the wheel around its axle, steady loop.
- Rigged build (advanced): a humanoid-style armature with thick-bone
  proportions; golem attacks are slow, heavy swings.

## Godot export notes

- Select all parts, File > Export > glTF 2.0 (.glb), format GLB, +Y Up
  enabled.
- Before export: Apply All Transforms; feet at Z = 0 in Blender (grounded
  at y = 0 in Godot).
- Target size: per the row's target (standard golem ~1.9 m tall — matches
  the wired Clay Golem's normalized size).
- Name the file `<creature>.glb` (lowercase, hyphens for spaces).
