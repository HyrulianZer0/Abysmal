# Archetype Guide — Biped Humanoid

Covers: goblins, kobolds, orcs, ogres, trolls, skeletons, zombies,
vampires, humans, demons, and humanoid giants. Example rows: Goblin,
Kobold, Orc, Ogre, Troll, Skeleton, Zombie, Vampire, Ettin, Cyclops, Oni.

## Overview

A biped is a vertical figure: legs, torso, arms, head. It is the largest
archetype in the library (most fantasy creatures are humanoid-shaped), and
the most forgiving: a slightly wrong proportion still reads as a humanoid.

## Base primitives

- Legs (2): 2 cylinders each (thigh + shin), radius ~0.09.
- Torso: box with beveled edges, or a UV Sphere (radius 0.5) scaled to
  (0.55, 0.35, 0.50) — 0.55 wide, 0.35 deep, 0.50 tall, matching step 3.
- Arms (2): 2 cylinders each (upper + forearm), radius ~0.07.
- Hands (2): small spheres or boxes.
- Head: UV Sphere (~0.16 radius).
- Feet (2): small flattened boxes.
- Extras as needed: horns (cones), ears (cones), armor plates (boxes),
  weapons (cylinder + box, e.g. an oni's iron club).

## Step by step (Blender, Z-up in the viewport)

1. Delete the default cube, camera, and light.
2. Legs: two thigh cylinders from Z = 0.55 down to Z = 0.30, and two shin
   cylinders from Z = 0.30 down to Z = 0.05, at X = ±0.14. Feet: flattened
   boxes at Z = 0.03, pointing forward (+Y).
3. Torso: beveled box or scaled sphere centered at Z = 0.78, roughly
   0.55 wide, 0.35 deep, 0.50 tall.
4. Arms: shoulder at Z = 0.95, X = ±0.33. Upper cylinder down to Z = 0.70,
   forearm down to Z = 0.45, hand sphere at Z = 0.42, arms slightly angled
   outward.
5. Head: sphere at Z = 1.12, radius 0.16. (Total height ~1.28 with this
   build — scale the whole figure to the row's target, see Proportions.)
6. Extras: horns (cones on the head, e.g. oni: two forward-curving cones);
   pointed ears (small cones on the head sides, e.g. goblin); armor plates
   (thin boxes on torso/shoulders, e.g. knight/brigand); weapons in a hand.
7. Giant variants (Ettin, Cyclops, Ogre): same build, scaled up, plus the
   defining feature — Ettin: two heads side by side (duplicate the head,
   offset X ±0.16); Cyclops: one central eye (single larger eye sphere on
   the face center).
8. Undead variants (Skeleton, Zombie): same build; skeleton uses a bone
   material and a visible ribcage (torus segments or thin boxes around the
   torso); zombie uses a rotting skin material and arms angled forward.
9. Select all parts, Object > Apply > All Transforms.

## Proportions (stylized game humanoid, total height = 1.0 after scaling)

- Legs: ~0.50 of height. Torso: ~0.30. Head: ~0.20 (stylized big head;
  realistic would be ~0.13 — the bigger head reads better at game scale).
- Shoulder width: ~0.45 of height. Arms: reach to mid-thigh.
- Small types (goblin, kobold): total height ~0.7–1.0 m. Human-sized:
  ~1.7–1.9 m. Giants (ogre, ettin, cyclops): ~2.5–3.5 m. Scale the whole
  figure uniformly to the row's target.

## Defining features

- Silhouette first: horns, ears, bulk, and posture identify the type
  faster than surface detail.
- Posture carries character: goblin (hunched, arms low), zombie (shambling,
  arms forward), knight (upright, armored), ogre (massive torso, small head
  relative to body).
- Hands and feet can stay simple (spheres/boxes) on a first build.

## Materials & colors

- Skin: one material per type (goblin green, orc grey-green, human tan,
  zombie rotting grey-green, skeleton bone white).
- Cloth/armor: separate materials (leather brown, iron grey, cloth muted
  colors). Horns/claws: bone or dark material.
- Textures to the 1K realistic anchor; flat colors first.

## Rig & motion

- First build: no armature. Procedural "breathe" (torso scale pulse
  1.00 → 1.02 → 1.00) is acceptable as an idle.
- Rigged build (advanced): one armature — hips, spine, chest, neck, head,
  upper/lower arms + hands, upper/lower legs + feet (17 bones, matching
  the project's humanoid rig convention). Animations (idle, walk, attack,
  hit, death) can then be authored or retargeted.

## Godot export notes

- Select all parts, File > Export > glTF 2.0 (.glb), format GLB, +Y Up
  enabled.
- Before export: Apply All Transforms; feet at Z = 0 in Blender (grounded
  at y = 0 in Godot).
- Target size: scale uniformly to the row's target (small ~0.7–1.0 m,
  human ~1.7–1.9 m, giant ~2.5–3.5 m).
- Name the file `<creature>.glb` (lowercase, hyphens for spaces).
