# Archetype Guide — Blob / Ooze

Covers: slimes, jellies, oozes, blobs, puddings, amorphous creatures.
Example rows: Slime, Cave Jelly, Amber Ooze, Mire Pudding, Acid Blob,
Gloom Ooze, Mercury Slime, Primordial Ooze, Hundun (faceless chaos blob).

## Overview

A blob is one squashed, rounded mass sitting on the ground, optionally with
eyes. It is the simplest archetype in the library and the recommended first
build for a new builder (see the proof build in
`~/workspace/build/model-guides-proof/`).

## Base primitives

- Body: UV Sphere (Add > Mesh > UV Sphere), 32 segments, 16 rings.
- Eyes (optional, 2): UV Sphere, 16 segments, 8 rings.
- Pupils (optional, 2): UV Sphere, 8 segments, 6 rings.

## Step by step (Blender, Z-up in the viewport)

1. Delete the default cube, camera, and light.
2. Add a UV Sphere. This is the body.
3. Scale it to (1.15, 1.15, 0.8) — wider than it is tall.
4. Move it so its bottom touches the ground: with radius 0.5 and Z-scale 0.8,
   the half-height is 0.4, so set Location Z = 0.4. Check: in Object Mode,
   the lowest point of the mesh is at Z = 0.
5. (Optional) Flatten the very bottom slightly: in Edit Mode, select the
   bottom ring of vertices and scale Z to 0.9. This stops the blob looking
   like it floats on a point.
6. (Optional) Eyes: add two small spheres (radius 0.09) on the front (+Y side),
   at about (±0.20, 0.44, 0.62) — placed so about half of each sphere sits
   proud of the body surface at that height, or the eyes sink into the body
   and vanish. Add two smaller black spheres (radius 0.045) just in front of
   each eye (about (±0.225, 0.495, 0.62)) as pupils.
7. (Optional) Wobble shape: in Edit Mode, grab a few side vertices and pull
   them out slightly so the silhouette is not a perfect sphere.
8. Shade Smooth: select all meshes, right-click > Shade Smooth (or set
   every polygon's use_smooth). Without this the spheres render faceted.
9. Select all parts, then Object > Apply > All Transforms (Ctrl+A) so scale
   and location are baked in before export.

## Proportions

- Total height: ~0.8–1.0 m (target size ~1.0; a small slime may be 0.6).
- Width: ~1.1–1.3× the height.
- Eyes (if any): each ~0.1× the body width, placed in the upper third.

## Defining features

- Rounded, soft silhouette — no hard edges, no limbs.
- A glossy, wet look sells "slime" more than geometry does (see Materials).
- Color carries the type: green (common slime), amber (resin), grey-black
  (gloom), silver (mercury), luminous (cave jelly — add emission).

## Materials & colors

- One material for the body: Base Color per type (e.g. Slime green
  (0.20, 0.70, 0.30)), Roughness ~0.25, Specular ~0.5 for a wet sheen.
- Keep the body opaque for export safety (transparency needs extra GLB
  blend-mode setup; skip it for a first build).
- Eyes: white material; pupils: near-black material.
- Treat textures to the 1K realistic anchor: for a first build, flat colors
  are fine; add a subtle noise texture later, never above 1K.

## Rig & motion

- No armature needed. Procedural motion is acceptable and is the project's
  fallback for static models: a "breathe" pulse (scale the body
  1.00 → 1.03 → 1.00 on a slow loop) reads as alive in game.
- If the game needs a hop (frog-adjacent blobs), animate Location Z with a
  small arc instead — same principle, no rig.

## Godot export notes

- Select all parts, File > Export > glTF 2.0 (.glb), format GLB, +Y Up
  enabled (the default). This converts Blender's Z-up to Godot's Y-up.
- Before export: Apply All Transforms; check the lowest vertex is at Z = 0
  in Blender (so it lands at y = 0 in Godot, grounded, not floating or sunk).
- Target size ~1.0 m tall (bounding-box height). If the row's game target
  differs, scale uniformly to that target instead.
- Name the file `<creature>.glb` (lowercase, hyphens for spaces).
