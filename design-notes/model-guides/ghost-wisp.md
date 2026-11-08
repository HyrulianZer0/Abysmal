# Archetype Guide — Ghost / Wisp

Covers: ghosts, specters, wraiths, banshees, wisps, shadows, and spirit
hosts. Example rows: Banshee, Specter, Wraith, Will-o'-wisp, Penanggalan,
Mare, Sluagh, Poltergeist, Bean-nighe, The Hollow Choir.

## Overview

A ghost/wisp is a translucent, floating form: a body that fades at the
bottom (no legs, no grounding) or a pure light. Build it from soft,
rounded shapes with a glowing, see-through material. Ghosts hover — they
do not stand on the ground plane the way other archetypes do (see the
export note on hover height).

## Base primitives

- Body: UV Sphere scaled tall (0.6, 0.6, 1.0) or a cone (point down) for a
  classic sheet-ghost taper.
- Tail/wisp trail: cone, tapered downward, or a stretched sphere.
- Eyes: 2 small spheres, emissive material (glowing).
- Orb (wisp): 1 small UV Sphere, emissive.
- Head (Penanggalan): 1 sphere + trailing entrail cylinders (thin,
  curved, reddish).

## Step by step (Blender, Z-up in the viewport)

1. Delete the default cube, camera, and light.
2. Body: sphere (base radius 0.5) scaled (0.6, 0.6, 1.0), center at
   Z = 0.8 — floating, with the bottom of the body around Z = 0.3
   (hovering, not grounded; see the export note). Proof note: step 2
   as written yields a 1.0 m body, not the 1.6–1.8 m in Proportions
   below — to reach the full humanoid-ghost height, scale the finished
   body ×1.7 and then translate it so its lowest point sits at Z = 0.3
   again (do not just scale in place, or the hover height scales too).
3. Taper: in Edit Mode, select the bottom ring of vertices and scale them
   inward (0.5×) so the body narrows toward the bottom like a sheet ghost.
   For a wisp trail, add a cone below the body, point down, same material.
4. Face: two small emissive eye spheres on the front (+Y side) of the
   upper body. Banshee: add flowing hair — 3–5 thin, curved cylinders or
   flattened boxes trailing backward/down from the head, same ghost
   material, slightly darker. Banshee robes: the body itself is the robe
   (long, flowing — scale the body taller, 1.2×, and flare the bottom).
5. Wisp variant (Will-o'-wisp): skip the body — one small emissive sphere
   (radius ~0.15) + a short wispy tail cone behind it. No face.
6. Penanggalan variant: a head sphere (radius ~0.25) + 3–5 thin entrail
   cylinders trailing below/behind it (reddish material), no body.
7. Choir variant (The Hollow Choir): a cluster of 3–5 small ghost bodies
   (per steps 2–3, scaled ~0.5) grouped together, no single dominant body.
8. Select all parts, Object > Apply > All Transforms.

## Proportions

- Humanoid ghost: total height ~1.6–1.8 m (hovering, bottom around
  Z = 0.3 in Blender).
- Wisp: orb ~0.3 m across + tail ~0.5 m long.
- Eyes: small (~0.05 m radius) but bright — the glow carries the read.

## Defining features

- No legs, no feet — the floating, tapering bottom is the identifier.
- Translucency + glow: the material does more work than the geometry.
- Banshee: female form + flowing hair/robes (not a genderless sheet —
  that is the SheetGhost stand-in's weakness; a true banshee build needs
  the hair and robe shape).

## Materials & colors

- Body: pale grey-white or faint blue-green, transparent (Alpha ~0.5) with
  an emissive tint. NOTE: transparency needs GLB blend-mode setup —
  for a first build, use an opaque pale material with strong emission
  instead, and note "add transparency at wiring" in the row entry.
- Eyes: emissive material (bright white, yellow, or red per type),
  Emission Strength 3–5.
- Wisp orb: emissive, Emission Strength 5+ (a light source look).
- Textures to the 1K realistic anchor; flat colors + emission first.

## Rig & motion

- First build: no armature. Procedural motion options:
  - Hover bob: Location Z sine (±0.1 m, slow loop) — the essential ghost
    motion.
  - Breathe: slow body scale pulse.
  - Wisp drift: slow X/Y wander + bob.
- Rigged build (advanced): rarely needed; a single body bone for bob/sway
  if the game needs it.

## Godot export notes

- Select all parts, File > Export > glTF 2.0 (.glb), format GLB, +Y Up
  enabled.
- Before export: Apply All Transforms. Hover height: ghosts hover — set
  the model's lowest point at Z = 0.3 in Blender and NOTE the hover height
  (0.3 m) in the row entry, so wiring can reproduce it in Godot (or bake
  it by lowering the model to Z = 0 and letting the game add the hover —
  follow the row entry's instruction, and be consistent).
- Target size: per the row's target (humanoid ghost ~1.7 m tall).
- Name the file `<creature>.glb` (lowercase, hyphens for spaces).
