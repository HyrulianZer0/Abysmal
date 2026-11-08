# Archetype Guide — Quadruped Beast

Covers: wolves, bears, boars, big cats, horses, deer, dogs, hounds, and
beast-bodied hybrids (centaur, sphinx, chimera, manticore). Example rows:
Wolf, Grizzly, Sabertooth, Pale Horse, Centaur, Sphinx, Chimera, Manticore,
Crocodile, Qilin (Corrupted).

## Overview

A quadruped is a horizontal body on four legs with a head at the front and
a tail at the back. Build the body first, then legs, then head, then tail
and extras (ears, horns, mane).

## Base primitives

- Body: UV Sphere (radius 0.5) scaled to (0.7, 1.4, 0.7) — a horizontal
  capsule shape, long axis along +Y (or a Capsule if your Blender
  version offers it).
- Legs (4): 2 cylinders each (upper + lower), radius ~0.09, plus small
  sphere paws (radius ~0.10).
- Head: UV Sphere (~0.28 radius) + snout (box or cone, ~0.2 long).
- Ears (2): cones, small. Horns (if any): cones, curved by rotation.
- Tail: tapered cylinder or cone.
- Mane (optional): flattened boxes or a row of small cones along the neck.

## Step by step (Blender, Z-up in the viewport)

1. Delete the default cube, camera, and light.
2. Body: add a UV Sphere of radius 0.5, scale (0.7, 1.4, 0.7) — X width,
   Y length (forward is +Y, so the long axis runs front-to-back), Z height
   — center at Z = 0.75 (so the body underside sits above leg height).
3. Legs: for each of the 4 corners (±0.22 X, ±0.45 Y roughly), add an upper
   cylinder from the body down to Z = 0.35 and a lower cylinder from
   Z = 0.35 to Z = 0.05, slightly angled (front legs angle forward a touch,
   back legs angle back). Add a small sphere paw (radius ~0.10) at
   Z = 0.10, so its bottom touches Z = 0 (a paw at Z = 0.05 with that
   radius would sink halfway below the ground plane).
4. Head: sphere at the front (+Y end), center around Y = +0.85, Z = 0.95.
   Snout: box/cone extending forward (+Y) from the head, slightly lower.
5. Ears: two small cones on top of the head. Horns (if any): cones angled
   outward/backward from the head.
6. Tail: tapered cylinder from the rear (−Y end), angled slightly up or
   down per type (dog up, wolf level, crocodile flat on the ground).
7. Hybrids: Centaur — replace the head with a biped-humanoid torso + head
   mounted where the neck would be. Sphinx — human head on the beast head
   position. Chimera — add a goat head beside the main head and a serpent
   tail-head (small serpent chain per the worm guide) instead of a plain
   tail. Manticore — human face on the head + scorpion tail (segmented
   cylinders + stinger cone).
8. Scale the whole figure uniformly to the row's target height (the
   proof build scales ear-tip height to 1.0 m), then select all parts,
   Object > Apply > All Transforms.

## Proportions

- Total height (shoulder to ground): ~0.6–0.9 m for a wolf/dog-sized beast;
  scale up for bears, horses, and giants (target size per row).
- Body length: ~1.4–1.8× shoulder height.
- Legs: ~0.6–0.7 m long for a wolf-sized beast; paws at Z = 0 (grounded).
- Head: ~0.3 m across for a wolf-sized beast.

## Defining features

- Four legs, clearly separated (not a single block) — the silhouette must
  read as an animal, not a statue.
- Head shape carries the species: long snout (wolf/dog), short muzzle
  (bear/cat), long jaw (crocodile), beak/face (hybrids).
- Tail shape carries the species: bushy (wolf/fox), short (bear), long and
  heavy (crocodile), scorpion (manticore).

## Materials & colors

- Body: one material, Base Color per type (fur grey/brown, golden mane
  hide, striped heavy pelt for tiger — stripes need a texture; flat color
  is fine for a first build, stripes later).
- Muzzle/paws: slightly darker material. Horns/claws: bone or dark material.
- Textures to the 1K realistic anchor; flat colors first.

## Rig & motion

- First build: no armature. Procedural motion options:
  - Breathe: slow body scale pulse (1.00 → 1.02 → 1.00).
  - Walk (simple): rotate the legs alternately (diagonal pairs) a few
    degrees — reads as a trot without a rig.
- Rigged build (advanced): one armature with hips, spine, neck, head, and
  2 bones per leg; the game's existing quadruped animations can then be
  retargeted if the bone names match.

## Godot export notes

- Select all parts, File > Export > glTF 2.0 (.glb), format GLB, +Y Up
  enabled.
- Before export: Apply All Transforms; paws at Z = 0 in Blender (grounded
  at y = 0 in Godot).
- Target size: shoulder height per the row's target (wolf ~0.8 m; scale
  uniformly for larger/smaller types).
- Name the file `<creature>.glb` (lowercase, hyphens for spaces).
