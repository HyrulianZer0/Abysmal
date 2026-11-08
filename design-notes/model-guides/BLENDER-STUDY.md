# Blender Study Notes — for the Abysmal Model-Guide Library

Docs only. This file teaches builders how to make the library's models
in Blender. It does not change any game code, scene, or asset, and it
contains no project-private information, so it can be shared with other
builders.

## Project conventions these notes assume

These conventions come from the library's own index, not from any
outside tutorial. Every archetype guide in this folder should follow
them, and every lesson below is judged against them:

- **Build from primitives.** Start with cubes, spheres, cylinders, and
  cones; shape them with edits and modifiers. Do not sculpt a unique
  high-poly mesh per creature.
- **Low-poly, game-ready form first.** Judge the silhouette before any
  detail. Prefer modifiers and baked maps over real geometry for detail.
- **Export as GLB for Godot:** Y-up, grounded (lowest point at y = 0 in
  Godot, i.e. min Z = 0 in Blender), target size ~1.0 m tall unless the
  creature row says otherwise (for example, a tiny fey at ~0.3 m).
- **Textures to a 1K realistic anchor.** One 1024 px texture set per
  creature is the default budget; go higher only for a hero asset.
- **Shade Smooth before export.** Select all meshes and set Shade
  Smooth, or spheres render faceted.
- **Visual review first.** Nothing built from these notes is
  pre-approved for the game; a human review pass decides what ships.

---

## 1. Procedural modeling with primitives + modifiers

### Technique

Modifiers are non-destructive operations stacked on an object: the
stack is evaluated top-first, and the base mesh stays editable until
the stack is applied. The library's core seven, and what each one does:

| Modifier | What it does | Library recipe |
| --- | --- | --- |
| **Mirror** | Mirrors the mesh about the object origin on X, Y, and/or Z. | Model one half of any symmetric creature, delete the other half first, turn on Clipping so centre vertices weld. |
| **Array** | Repeats the object in a line, grid, or along a curve. | Repeated body segments, legs, teeth, spikes, scales, vertebrae. Pair Array with Curve to follow a path. |
| **Curve** | Bends a mesh along a curve object. | Serpent bodies, tails, tentacles, vines, necks — model straight, then pose the curve into an S or coil. |
| **Subdivision Surface** | Smooths by subdividing faces (Catmull-Clark or Simple). | Turn a blocky primitive body into an organic form at level 1–2 for the viewport. Control sharpness with edge loops near edges you want to keep crisp, or with creases (`Shift+E`). |
| **Lattice** | Deforms a mesh through a surrounding cage of control points. | Squash-and-stretch a whole body (blob, frog belly, golem torso) without touching individual vertices. |
| **Bevel** | Rounds edges, as a modifier or an edit-mode operation (`Ctrl+B`). | A small bevel on every hard edge: nothing real has a razor edge, and a bevel catches light so a low-poly model reads as finished rather than CGI-flat. Keep segments low (1–2) for game meshes. |
| **Displace** | Offsets vertices from a texture. | Surface variation — warty toad skin, rocky golem hide, bark — without adding hand-placed geometry. Keep strength low; bake the result rather than exporting a live texture-driven modifier. |

**Canonical stack order (top = evaluated first):** generate topology
(Mirror, Array, Screw, Skin) → cut/combine (Boolean) → thickness
(Solidify) → round corners (Bevel) → smooth/densify (Subdivision) →
deform (Armature, Lattice, Curve, Simple Deform) → fix shading
(Weighted Normal) → reduce/finalize (Decimate, Triangulate, Weld).
Getting this order wrong is the most common reason a stack "looks
broken": Bevel before Subdivision rounds then smooths; Subdivision
before Bevel smooths then rounds a much denser mesh.

### Why it matters for this library

The whole library is 300 creatures from 10 archetype recipes. If each
creature were hand-sculpted, the library would never finish. A
modifier recipe is *reusable*: the same Array + Curve spine builds a
worm, a serpent, a tail, and a tentacle, with only counts, radii, and
proportions changed. Keeping modifiers live as long as possible also
means a per-creature tweak (longer neck, wider hips, more segments)
is a number change, not a remodel.

### Concrete tips / mini-recipes

- **Segmented body (worm, centipede, tail):** one squashed-sphere or
  short-cylinder segment → Array with a small forward offset and a
  slight scale falloff via an Object Offset empty → Curve modifier
  along a Bezier path. Pose the curve, not the segments.
- **Symmetric head (biped, quadruped, winged):** block half the skull
  from a cube or UV sphere, Mirror on X with Clipping on, add eyes,
  horns, and ears on the modelled half only. The mirror does the rest.
- **Spikes, teeth, horns:** one cone → Array along a curve or a
  hand-placed set of empties; vary scale per instance by scaling the
  offset object. One spike mesh, reused everywhere, keeps the file
  small and the look consistent.
- **Do not apply the stack early.** Apply only when you must — for
  export, for sculpting on top, or for a step that needs real
  geometry. A live stack is still editable; an applied one is not.
- **Apply scale before anything that measures distance.** After
  scaling in Object mode, `Ctrl+A → Apply Scale` (and rotation before
  rigging or export). Unapplied scale silently breaks Bevel width,
  Solidify thickness, and texture density.
- **Topology rules that keep modifiers happy:** quads where the mesh
  deforms or subdivides; triangles are acceptable on flat, static
  areas; n-gons (5+ sides) cause shading artifacts and subdivision
  pinching — confine them to flat faces. Keep edge loops encircling
  joints (shoulder, elbow, knee, jaw, eye) so deformation has a hinge.
  Steer poles (vertices with 3 or 5+ edges) away from curved or
  deforming areas. Fix flipped normals with `Shift+N` (Recalculate
  Outside) and doubled vertices with `M → Merge by Distance` — the
  classic cure for "black seams" and "subdivision looks crumpled."

### Sources — procedural modeling

- Blender Manual, Object Modifiers index (the authoritative list of
  every modifier, with a page per modifier):
  <https://docs.blender.org/manual/en/latest/modeling/modifiers/index.html>
- Blender modifiers tutorial, non-destructive vs. destructive
  modeling, Array/Bevel/Boolean/Mirror/Subdivision/Curve/Lattice
  walkthrough: <https://renderguide.com/blender-modifiers-tutorial/>
- The Modifier Stack as an ordered evaluation graph (canonical order,
  Boolean solver choice, headless application notes):
  <https://github.com/jangtrinh/design-os-3d-blender/blob/HEAD/knowledge/10-modeling/modifiers.md>
- Blender modeling skill notes — block → refine → detail workflow,
  the "big five" modifiers, topology rules, scale trap:
  <https://github.com/armand0e/little-model-harness/blob/HEAD/skills/blender-modeling/SKILL.md>

---

## 2. Building low-poly characters and creatures from primitives

### Technique

The low-poly workflow is **block → refine → detail**, in that order,
and it is deliberately boring:

1. **Block out** the whole creature from primitives at correct
   proportions first. Judge the silhouette before any detail. Use a
   front/side reference image in the viewport (`Shift+A → Image →
   Reference`, opacity ~0.2–0.5) when the creature has a real-world
   analogue (wolf, horse, frog, spider).
2. **Refine** with loop cuts (`Ctrl+R`), extrusions (`E`), insets
   (`I`), and bevels. Work at the lowest polycount that still holds
   the shape.
3. **Detail last** — and prefer modifiers, material slots, and baked
   normal maps over real geometry.

For animals specifically: start from a scaled cube, enter Edit mode,
shape the torso and neck by moving vertices in the side view, extrude
the head, add the Mirror modifier, adjust body width in the front
view, then extrude legs (loop cut + extrude per leg), refine roundness
with edge slides, and finish with inset/extruded eyes, ears, and
horns/antlers. Colour comes from material slots, and fine features
(eyes, nose, mouth lines) from the Knife tool or separate small
meshes — not from dense geometry.

### Why it matters for this library

Every archetype guide in this folder is, at heart, one block-out
recipe plus a list of per-creature tweaks. A builder who can block a
quadruped from a cube and a cylinder can build all 51 quadruped rows
by changing proportions, head shape, tail, and legs. The same is true
of bipeds (117 rows — the largest archetype): one torso/leg/arm
block-out, varied by height, bulk, head count, horns, and limbs.

### Concrete tips / mini-recipes

- **The cube-to-creature pass (animal):** cube → scale to torso →
  side-view vertex shaping → extrude neck and head → Mirror →
  front-view width pass → loop-cut and extrude legs → edge-slide for
  roundness → inset eyes, extrude ears/horns. Stop there for a
  game-ready low-poly animal; add colour via material slots.
- **Hands and feet, low-poly style:** do not model fingers and toes
  individually. Extrude the limb end, taper it slightly, and let a
  material change or a single groove read as a hand or paw. Fingers
  are a detail pass for hero creatures only.
- **Silhouette check:** before detailing, view the model as a flat
  silhouette (solid shading, no materials). If the creature is not
  readable as its creature in silhouette, no amount of texture will
  save it. Fix proportions first.
- **One mesh per body part, or one joined mesh?** Keep parts separate
  while blocking (easy to re-proportion), then join (`Ctrl+J`) or keep
  separate per material slot at export. Separate meshes also make
  weight painting easier, because a bone's influence can be limited
  to its part.
- **Swarms are one model, not many.** For swarm rows (rat swarm,
  scarab swarm), build ONE creature well; the game spawns many. Do
  not model a crowd in Blender.

### Sources — low-poly creatures

- Free follow-along: model any low-poly animal from a reference sheet
  (front/side setup, cube body, Mirror, legs, eyes, ears, horns,
  material slots, knife detailing):
  <https://www.classcentral.com/course/youtube-blender-5-for-beginners-model-any-low-poly-animal-detailed-follow-along-guide-510491>
- Low-poly animal in Blender, step by step (reference setup, cube
  block-out, extrusion/scaling/vertex editing, Mirror):
  <https://jsabbott.artstation.com/blog/7olL1/how-do-you-model-a-low-poly-animal-in-blender-3d>
- Fantasy creature workflow at larger scope — anatomy first, then
  break the rules on purpose; retopology to a light low-poly base
  for animation, detail baked to maps:
  <https://www.blenderbasecamp.com/fantasy-creature-sculpting-in-blender/>
- Creature creation pipeline (sculpt rough forms first, retopo,
  Rigify rig, weight-paint fixes, shape keys for problem joints):
  <https://www.project-pangea.com/creature-creation/>

---

## 3. Rigging basics for simple creatures

### Technique

Rigging = building a skeleton (armature) inside the model, then
skinning the mesh to it so vertices follow bones.

1. **Armature:** `Shift+A → Armature`. In Edit mode, extrude (`E`)
   bones outward from the root: hips → spine → head; hips → legs;
   chest → arms. Name every bone now — unnamed `spine.001` chains
   are painful later — and use `.L` / `.R` suffixes so Blender can
   mirror (Symmetrize) the other side.
2. **Bone placement = joint pivots.** Put a bone's head exactly at
   the joint it rotates around (knee head at the actual knee). Build
   a slight forward bend into knees and elbows so IK knows which way
   to fold; a perfectly straight chain has no preferred fold
   direction and will flip.
3. **Skinning:** select mesh, Shift-select armature, `Ctrl+P →
   Armature Deform with Automatic Weights`. This gets roughly 80%
   right; the rest is weight-painting.
4. **Weight painting:** in Weight Paint mode, red = fully driven by
   the selected bone, blue = not at all. Fix "thigh moves the belly"
   and candy-wrapper twists by smoothing or subtracting weights
   around joints. Each vertex's weights are normalized across bones;
   enable Auto-Normalize to keep totals at 1.0.
5. **FK vs. IK:** FK (rotate each bone down the chain) is natural
   for arcs — swinging arms, tails, serpent spines. IK (place a
   target, the chain solves) is for feet planted on the ground and
   hands on fixed objects; use chain length 2 for a leg
   (thigh + shin) with a separate non-deforming target bone and a
   pole target to aim the knee/elbow. Legs are almost always IK;
   arms are FK for gesture, IK for contact.
6. **Do not hand-build a production humanoid rig.** Blender's bundled
   **Rigify** add-on generates a full IK/FK-switching rig from a
   metarig fitted to the character (a "wolf" preset exists for
   quadrupeds; add sample bones for extra parts such as a sail or
   extra limbs). Test any rig by bending every joint to its extreme
   and watching the deformation; fix weights before animating.

### Basic idle / walk motion

- **Keyframes:** `I` inserts a keyframe on the selected bone
  (Location / Rotation / Scale). Block poses on Constant
  (stepped) interpolation first, judge timing by scrubbing, then
  convert to Bezier and polish in the Graph Editor: ease-in/out
  clustering at pose extremes, offset limb curves by a few frames
  so limbs do not all peak together (overlap), and flatten foot
  curves during ground contact to kill foot-slide. `Shift+E`
  (cyclic modifier) makes a walk loop.
- **Walk cycle, 24–32 frames, 4 key poses per side:** Contact (heel
  strikes, legs widest) → Down (weight lands, body lowest) →
  Passing (free leg passes, body rising) → Up (push off). Animate
  the hips first — they carry the mass (bounce twice per cycle, sway
  side to side, rotate) — with arms opposite legs.
- **Idle:** a small breathing loop (chest scale or spine rotation,
  a few frames, cyclic) plus an occasional head turn or tail sway.
  Idle is the cheapest animation that makes a dungeon creature feel
  alive; do it before any attack animation.
- **Multiple clips for games:** each clip (idle, walk, hop, attack)
  is an **Action** in the Dope Sheet's Action Editor. Give each
  Action a fake user (shield icon) or Blender discards unused
  actions on save — the classic lost-work trap. Stash actions into
  NLA tracks; on glTF export each action becomes a named clip the
  engine can play and crossfade.

### Shape keys as an alternative (and as a complement)

Shape keys (Blender's blend shapes) store a deformed version of the
mesh and blend toward it with a slider. They are the right tool when
a bone rig is overkill or cannot reach the deformation:

- **When shape keys win:** blobs and oozes (squash, wobble, bulge),
  ghosts and wisps (billow, stretch, dissolve), facial expressions,
  breathing, and any single-part squash-and-stretch. No bones, no
  weights, no skinning errors — just a Basis key plus one key per
  pose, driven by a slider or keyframed directly.
- **When bones win:** anything with limbs, a spine, or a tail that
  must bend at a joint. A shape key cannot rotate a limb around a
  knee; an armature can.
- **Best practice — use both:** rig with bones first, then add
  shape keys only for what bones cannot do well (a neck fold that
  collapses under extreme head poses, a blink, a jaw open). Rule of
  thumb from creature work: do everything you can with the armature
  first, and let shape keys handle only the leftovers. Note that
  glTF exports shape keys as morph targets, which Godot supports —
  but a morph target needs the same vertex count and order as the
  base mesh, so add shape keys before any operation that changes
  topology.
- **For this library specifically:** the blob-ooze archetype (already
  proven) is the natural shape-key showcase — a wobble is a shape
  key, not a rig. The ghost-wisp archetype is the second: billow and
  stretch are cheaper and cleaner as morphs than as a bone chain.

### Rigging traps to avoid

- Apply rotation and scale (`Ctrl+A`) **before** rigging. Applying
  after breaks weights.
- Root the character at the world origin with feet at Z = 0, or the
  engine import will need a corrective offset on every creature.
- Pose mode is where animation happens; Edit mode edits the rest
  pose. `Alt+G/R/S` clears a bone's pose.
- Engines cannot evaluate Blender constraints or IK — bake/sample
  animations to plain keyframes on export (see §5).
- Test the exported `.glb` in an independent glTF viewer before
  blaming the engine for a rig problem.

### Sources — rigging and animation

- Blender animation & rigging notes — keyframes, Graph Editor
  workflow, armature setup, weight painting, IK/FK, walk-cycle
  recipe, NLA/actions, glTF export checklist:
  <https://github.com/armand0e/little-model-harness/blob/HEAD/skills/blender-animation-rigging/SKILL.md>
- Blender Manual, Object Modifiers index — Armature, Lattice, and
  Curve modifiers sit in the Deform group; read their pages from
  the index for exact settings:
  <https://docs.blender.org/manual/en/latest/modeling/modifiers/index.html>
- Fantasy creature rigging and animation basics (armature
  placement, hierarchy, weight painting, keyframed walk cycle):
  <https://www.blenderbasecamp.com/fantasy-creature-sculpting-in-blender/>

---

## 4. Materials and UVs for game export

### Technique

**Materials — keep them Principled and simple.** The Principled BSDF
is the everything-shader for game work: Base Color, Roughness,
Metallic (0 or 1, rarely between), Normal. Image textures plug into
those sockets via Image Texture nodes — and data maps (roughness,
normal, metallic) must be set to **Non-Color** colour space, while
albedo stays sRGB. Anything beyond Principled BSDF — procedural
Noise/Voronoi/Musgrave textures, complex mix-node graphs, subsurface
scattering, volumetrics — does **not** survive glTF export (see §5).
If the look depends on a procedural shader, bake it to an image
first, then rebuild the material as a single Principled BSDF using
the baked images.

**UV unwrapping — the contract between mesh and texture.** A UV map
flattens the model's surface into 2D so a texture can be applied
without distortion. The workflow:

1. **Mark seams** in Edit mode (`Ctrl+E → Mark Seam`) along hidden
   edges — like a tailor's seams: hairlines, behind ears, soles of
   feet, inside of arms, undersides, hard edges, material boundaries.
   Cylinders get one seam on the least-visible edge plus cap loops.
2. **Unwrap** (`U → Unwrap`, Angle-Based for organic/character
   meshes, Conformal when angle preservation matters). For a quick
   pass on hard-surface props only, Smart UV Project (angle limit
   66°, island margin ~0.02) is acceptable; it is not a substitute
   for hand-placed seams on a creature.
3. **Average Islands Scale** after unwrapping, so islands share a
   consistent texel density, then **Pack Islands** with a margin
   (fraction ≈ 4 px / texture size; ~0.004–0.008 at 1024 px) to
   prevent mipmap bleed between islands.
4. **Check with a checker texture** at the target resolution: squares
   must stay square and evenly sized. A pinch or skew marks a bad
   seam or a non-planar fold. Target ≥70–80% UV-space fill, all
   islands inside 0–1 space, no overlaps on the bake/colour map
   (overlaps are only acceptable for deliberately tiled trim
   textures).

**Texel density — the most-overlooked concept.** Texel density is
pixels per world unit; uniform density means uniform texture quality
across the model. For this library, 1024 px across a ~1.0 m creature
is the anchor (~1024 px/m); a 0.3 m fey on the same 1024 px texture
will look sharper than a 1.0 m creature, which is fine — the rule is
consistency within an asset, not identical density across all 300.
Do not use UDIM tiles for game assets: one atlas per asset, always.

**Baking (when the material is too complex to export directly):**

1. Create a second, non-overlapping UV map for baking.
2. Bake with Cycles: Combined/albedo, Roughness, Metallic, Normal
   (non-color, OpenGL Y+).
3. Replace the node tree with a single Principled BSDF using the
   baked images, then export.

**A shortcut that fits this library:** many creatures do not need a
full painted texture at all. Solid Principled colours per material
slot (body, belly, horns, eyes) plus a baked 1K texture only where
the creature needs pattern (scales, stripes, stone, bark) keeps the
build fast and the file small. Defer UV work on a block-out until a
concrete texture requirement appears — but do it before baking or
export, never after.

### Why it matters for this library

The 1K realistic anchor is a *shared* look: if one creature's texture
is stretched, bleeding, or twice as dense as its neighbours, the
dungeon stops looking coherent. Seams hidden on undersides and hard
edges, consistent density, and Principled-only materials are what
make 300 separately-built creatures read as one bestiary.

### Concrete tips / mini-recipes

- **Stone golem:** one Principled material, mid-grey Base Color,
  Roughness ~0.9, Metallic 0; Displace or a baked noise texture for
  surface variation; seams on the back and underside, never across
  the chest face.
- **Ghost/wisp translucency:** glTF supports alpha, but translucency
  is an engine-side material decision. Build the ghost mesh clean,
  export it opaque with a pale Base Color, and let the engine
  material handle transparency — do not try to bake a Blender-only
  transparency trick into the export.
- **Striped or scaled creature (wasp, serpent, crocodile):** paint
  the pattern onto the 1K texture with the UV islands laid out over
  it, or bake a procedural stripe/scale shader to the 1K image and
  rebuild as Principled. Never export the procedural node graph
  itself — Godot will not see it.
- **Checker test before every export:** assign a UV-grid/checker
  texture, orbit the model, confirm squares stay square. This one
  check catches most UV mistakes in under a minute.

### Sources — materials and UVs

- UV unwrapping skill notes — seam placement, texel-density classes,
  1024 px typical / 2048 px hero, one atlas per asset, no UDIM,
  padding math, checker distortion check:
  <https://github.com/mot1209/rustgame/blob/HEAD/.opencode/skills/uv-unwrapping/SKILL.md>
- UV unwrapping, packing & texel density — seam methods, unwrap
  methods by use case, packing margins, lightmap second channel:
  <https://github.com/jangtrinh/design-os-3d-blender/blob/HEAD/knowledge/10-modeling/uv-unwrapping.md>
- UV + texturing + baking overview — unwrap method decision tree
  (hard-surface vs. organic vs. cylindrical vs. Subdivision base
  mesh), texel-density targets, pro unwrap workflow:
  <https://github.com/roble3/cc-blender-skill/blob/HEAD/knowledge/06-uv-texturing/00-overview.md>
- Blender modeling skill notes — Principled BSDF sockets, Non-Color
  data maps, UV unwrap + checker test, high-to-low baking path:
  <https://github.com/armand0e/little-model-harness/blob/HEAD/skills/blender-modeling/SKILL.md>
- PBR checklist for Godot 4 — preparing UVs, building the Principled
  material, baking, glTF export, Godot import:
  <https://supermatrix.studio/blog/how-to-create-realistic-pbr-materials-in-blender-for-godot-4>
- Blender-to-Godot UV guide — why procedural gradients fail on
  export and how a single image texture + arranged UV islands fixes
  it: <https://supermatrix.studio/blog/guide-to-uv-mapping-for-perfect-gradients>

---

## 5. glTF export best practices for Godot

### Technique

glTF 2.0 (`.glb` binary) is the recommended Blender → Godot path.
Godot imports it natively, and Blender's exporter maps ordinary
mesh, PBR material, skeleton, and animation data to it well. The
settings that matter:

| Setting | Value for this library | Why |
| --- | --- | --- |
| Format | glTF Binary (`.glb`) | One file per creature; easy to move, review, and wire. Separate `.gltf + .bin + textures` only when textures are edited externally. |
| Limit to | Visible Objects, or an Active Collection (e.g. `_EXPORT`) | Reproducibility: only the finished creature exports, never a work-in-progress duplicate or a reference image. |
| Apply Modifiers | ON | Critical for Subdivision, Mirror, Solidify — otherwise Godot receives the unmodified base mesh. |
| UVs / Normals / Tangents | ON | Godot needs UV0 for textures; tangents are needed for normal mapping. |
| Materials Export | ON | Exports Principled BSDF parameters. Image Format: Automatic (PNG lossless, JPEG smaller). |
| +Y Up | ON | Godot is Y-up; this avoids a corrective rotation node on import. |
| Scale | 1.0, Blender units in metres | A 1.0 m creature in Blender must be 1.0 m in Godot. |
| Animations | ON, All Actions / NLA Strips when multiple clips exist; Always Sample, Force Sampling | Constraints, drivers, and IK do not export — sampling bakes them to plain keyframes the engine can play. Sampling rate 24 or 30 keeps files small. |
| Draco compression | OFF | Godot decompresses at import; it adds import cost without reducing runtime memory. Use Godot's own import compression instead. |
| Loose Edges / Loose Points | OFF | Not rendered by Godot anyway. |

### What does NOT export — plan around it

Procedural textures (Noise, Voronoi, Musgrave) → bake to image
first. Shader nodes beyond Principled BSDF → bake or simplify.
Geometry Nodes → apply as a real mesh. Curves, surfaces,
metaballs, and text objects → convert to mesh. Physics, layered
materials, subsurface scattering, volumetrics → rebuild or accept
the loss in Godot. Drivers and constraints → bake to keyframes.

### Pre-export checklist (run for every creature)

1. Apply rotation and scale (`Ctrl+A`); feet at Z = 0, root at
   world origin.
2. Shade Smooth on all meshes.
3. Apply (or leave ON at export) all modifiers; remove stray
   modifiers that do nothing.
4. Merge doubled vertices; recalculate normals outside.
5. UV map present and checker-tested; material is Principled-only
   (or baked to Principled).
6. Object and bone names sensible (`.L` / `.R` pairs, no default
   `Cube.003` clutter in the export).
7. Animations: every Action has a fake user; NLA strips set if
   multiple clips; sampling ON.
8. Export `.glb`, then validate — Khronos glTF Validator (online
   or CLI) — and open the file in an independent glTF viewer before
   handing it to the game. An invalid file can crash the Godot
   importer or fail silently; a viewer check separates a Blender
   problem from a Godot problem.
9. Keep the `.blend` as the source of truth, but do not keep both
   `.blend` and generated `.glb` under version control unless the
   project has a reason to own both; the `.glb` is a build artifact.

### Sources — glTF / Godot export

- Godot-compatible glTF export settings — format choice, detailed
  export panels, what does not export, baking strategy, batch
  export script, Draco notes, validation:
  <https://github.com/buckster123/hermes-vr-devkit/blob/HEAD/skills/blender-godot-pipeline/references/gltf-export.md>
- Blender → Godot game-asset notes — keep materials simple until
  the form works, defer UV work until a texture requirement exists,
  choose `.blend` vs. explicit `.glb` deliberately, keep gameplay
  behaviour in Godot rather than in the source asset:
  <https://github.com/lungren2/blender-godot-super/blob/HEAD/src/super_mcp/game_repo_template/.agents/skills/blender-game-assets/SKILL.md>
- Blender modeling skill notes — glTF 2.0 (`.glb`) export, +Y-up,
  Principled-only materials, packed/relative textures, sensible
  object names:
  <https://github.com/armand0e/little-model-harness/blob/HEAD/skills/blender-modeling/SKILL.md>
- Blender animation & rigging notes — export checklist: apply
  scale/rotation before rigging, root at origin with feet at Z = 0,
  sample/bake constraints and IK, test in a glTF viewer:
  <https://github.com/armand0e/little-model-harness/blob/HEAD/skills/blender-animation-rigging/SKILL.md>

---

## 6. How each lesson maps to our archetypes

| Archetype (rows) | Techniques that carry it | Notes |
| --- | --- | --- |
| **blob-ooze** (9) | Lattice + Subdivision + shape keys; Displace for surface wobble | Already proven by a Blender build. No bones needed: squash, bulge, and wobble are shape keys. Lattice gives whole-body squash-and-stretch. Keep the mesh a single blobby volume; eyes and mouth are separate small meshes or material slots. |
| **worm-serpent** (23) | Array + Curve; FK bone chain or shape-key undulation | The Array + Curve spine is the archetype's core recipe: one segment, repeated, posed by a curve. Multi-headed rows (Hydra) reuse the same spine per neck. FK bones suit a slither cycle; a shape-key wave suits a static or idle-only serpent. |
| **quadruped-beast** (51) | Mirror + block-out + loop cuts; IK legs; Rigify wolf preset | The largest animal archetype. Mirror halves the work; IK legs plant feet for walk cycles. Centaur, Chimera, Sphinx, and Manticore are quadruped bodies with a second torso/head grafted on — build the quadruped first, then the graft. |
| **biped-humanoid** (117) | Mirror + block-out; full armature; Rigify humanoid metarig; weight painting | The largest archetype overall. One torso/leg/arm block-out, varied by bulk, height, heads, horns, and limbs. Rigify saves the most time here. Weight-paint the shoulders, hips, and knees carefully — these are where automatic weights fail most visibly. |
| **winged** (34) | Mirror + Array (feathers); FK wing bones or shape-key flap | Wings: one feather mesh, Arrayed along a wing-arm curve, mirrored. Flap is either an FK bone chain (shoulder → elbow → wingtip) or a single shape key (wings up / wings down) for cheap idle flight. Six-winged rows (Seraph) are three Arrayed wing pairs, not three separate builds. |
| **spider-arachnid** (14) | Mirror + Array (legs); IK or FK legs | Eight legs = one leg mesh, Arrayed/mirrored four times per side. Build ONE leg well, with a slight joint bend for IK pole direction. Swarm rows: build one scarab/beetle; the game spawns many. |
| **aquatic** (13) | Curve + Lattice; FK tail/fin bones; shape-key swim undulation | Tails, tentacles, and fins are Curve-deformed tapers. Kraken tentacles are tapered cylinders on curves — build one, vary length and curl. A swim idle is a travelling FK wave down the spine/tail, or a shape-key undulation for a static display model. |
| **plant-fungal** (11) | Array + Curve (vines, petals); Displace (bark, cap texture) | Petals and leaves are Arrayed planes with a Solidify + Bevel edge; vines are Curve-deformed cylinders. Displace gives bark and mushroom-cap texture cheaply; bake it for export. |
| **ghost-wisp** (15) | Lattice + shape keys; no rig (usually) | Billow, stretch, and dissolve are shape keys, not bones. Build the robe/wisp as a flowing, low-poly shell, add a tail that trails behind, and let the engine material handle translucency. Banshee hair and robes are Lattice-deformed planes, not sculpted strands. |
| **golem-construct** (13) | Bevel + block-out; simple FK/IK rig; Principled stone/metal materials | Hard edges with small bevels read as carved stone or cast metal; sharp, unbevelled edges read as unfinished. Joints are blocky and few — a golem rig can be 6–10 bones total. Ophanim (wheel ringed with eyes) is a torus + Arrayed eye spheres, spinning on one axis. |

### Cross-cutting rules for all 10 archetypes

- **Mirror first, detail second.** Every symmetric archetype (all
  except some blobs and wisps) starts mirrored; asymmetric details
  (scars, a missing eye, a tilted horn) are added after the mirror
  is applied or on a separate mesh.
- **Bones only where joints bend.** If a part does not bend at a
  joint, it does not need a bone — parent it to the nearest bone or
  leave it static. A 300-creature library cannot afford a 40-bone
  rig on every row.
- **Shape keys for squash, bones for limbs.** When in doubt, ask:
  does this part rotate around a joint (bone) or deform in place
  (shape key)?
- **One 1K texture set per creature, Principled-only, baked when
  needed.** No creature ships with a live procedural shader graph.
- **Export checklist (§5) for every creature, no exceptions.** The
  checklist is what turns 300 individual builds into one coherent,
  importable bestiary.

---

## 7. Further reading (all free)

- Blender Manual — the authoritative reference for every tool and
  modifier above; start at the Modifiers index and follow the
  per-modifier pages:
  <https://docs.blender.org/manual/en/latest/modeling/modifiers/index.html>
- Blender modifiers tutorial (RenderGuide):
  <https://renderguide.com/blender-modifiers-tutorial/>
- Blender modeling skill notes (workflow, modifiers, topology,
  materials, export):
  <https://github.com/armand0e/little-model-harness/blob/HEAD/skills/blender-modeling/SKILL.md>
- Blender animation & rigging skill notes (keyframes, Graph Editor,
  armatures, weight painting, walk cycles, NLA, export):
  <https://github.com/armand0e/little-model-harness/blob/HEAD/skills/blender-animation-rigging/SKILL.md>
- Godot-compatible glTF export reference (settings, baking,
  validation):
  <https://github.com/buckster123/hermes-vr-devkit/blob/HEAD/skills/blender-godot-pipeline/references/gltf-export.md>

*Study notes compiled from the free public sources above, November
2026. Blender version references follow the current Blender Manual
(5.x) unless a source states otherwise; where a tutorial targets an
older version, the workflow (not the exact button location) is what
transfers.*
