# Wave 1 — Godot import verification (Phase 1b GLBs)

**Date:** Oct 29, 2026. **Engine:** Godot 4.7.2 headless (`Godot_v4.7.2-stable_linux.x86_64`).
**Method (read-only on the real project):** a scratch project in `/tmp/wave1-import-check`
(NOT the game folder), the 18 `.glb` files copied in flat, an editor import pass
(`--headless --import`) plus a `GLTFDocument` scene walk (mesh instances, skeletons/bones,
AnimationPlayer clips, surface materials, world AABB). Nothing in the real project was
modified, imported, released, or uploaded; no APK, no publish. Credits use
**Aethelwarden Solas** only.

**Editor import result: all 18 PASS.** Import exited 0, produced 18 `.scn` files under
`.godot/imported/`, and the import log contained **zero ERROR/WARNING lines**.
"Import PASS" below therefore means "Godot accepted the file". The per-file columns
record what actually survived inside it — and for most files that is less than the
source promised. This was a headless check only: no visual/render pass was done, so
geometry deformation questions (flagged below) still need an eyeball pass in the editor.

## Per-file table

| File | Import | MeshInstances (glTF meshes) | Skeleton (bones) | Animation clips | Textures | Overall AABB size, approx (m, X × Y × Z) | Verdict |
|---|---|---|---|---|---|---|---|
| bat_v5.glb | PASS | 5 (5) | 2 × 32 | Bat_Attack, Bat_Die, Bat_Flying, Bat_preview_position | RESOLVED (embedded) | 10.32 × 0.95 × 4.31 | SAFE TO WIRE |
| cerberus_v002.glb | PASS | 1 (1) | 1 × 49 | Walk only | MISSING (flat grey) | 9.41 × 10.32 × 17.36 | CONDITIONAL |
| enemy_bandit.glb | PASS | 11 (11) | none | none | MISSING (flat grey) | 2.79 × 2.45 × 0.46 | CONDITIONAL (static only) |
| enemy_cannae.glb | PASS | 11 (11) | none | none | MISSING (flat grey) | 0.85 × 1.12 × 3.80 | CONDITIONAL (static only) |
| enemy_cereptera.glb | PASS | 3 (3) | none | none | MISSING (flat grey) | 0.40 × 0.79 × 2.50 | CONDITIONAL (static only) |
| enemy_clod.glb | PASS | 6 (6) | none | none | MISSING (flat grey) | 2.00 × 1.05 × 0.86 | CONDITIONAL (static only) |
| enemy_cobracon.glb | PASS | 7 (7) | none | none | MISSING (flat grey) | 0.78 × 1.84 × 2.63 | CONDITIONAL (static only) |
| enemy_helichard.glb | PASS | 2 (2) | none | none | MISSING (flat grey) | 0.87 × 0.73 × 0.87 | CONDITIONAL (static only) |
| enemy_janga.glb | PASS | 8 (8) | none | none | MISSING (flat grey) | 2.07 × 1.42 × 1.72 | CONDITIONAL (static only) |
| enemy_myocene.glb | PASS | 5 (5) | none | none | MISSING (flat grey) | 0.90 × 1.02 × 1.04 | CONDITIONAL (static only) |
| enemy_rattler.glb | PASS | 5 (5) | none | none | MISSING (flat grey) | 0.44 × 0.33 × 2.89 | CONDITIONAL (static only) |
| enemy_revenant.glb | PASS | 13 (13) | none | none | MISSING (flat grey) | 6.20 × 1.92 × 1.28 | CONDITIONAL (static only) |
| enemy_scorpion.glb | PASS | 6 (6) | none | none | MISSING (flat grey) | 1.17 × 1.07 × 1.33 | CONDITIONAL (static only) |
| enemy_tardigrade.glb | PASS | 2 (2) | none | none | MISSING (flat grey) | 0.38 × 1.59 × 2.46 | CONDITIONAL (static only) |
| enemy_ungulate.glb | PASS | 6 (6) | none | none | MISSING (flat grey) | 1.14 × 1.42 × 3.40 | CONDITIONAL (static only) |
| goblin.glb | PASS | 1 (1) | 1 × 39 | none | MISSING (flat colours only) | 1.81 × 1.49 × 0.53 | CONDITIONAL (skinned, no clips) |
| rat.glb | PASS | 1 (1) | none | none | MISSING (flat grey) | 1.24 × 1.64 × 7.16 | UNUSABLE AS-IS |
| snappa-kappa.glb | PASS | 2 (2) | 1 × 21 | none | MISSING (flat colours only) | 3.82 × 2.97 × 2.01 | CONDITIONAL (skinned, no clips) |

## Verdicts for Wave 2 wiring

### Safe to wire

- **bat_v5.glb (Vampire Bat)** — the only fully intact export: skeleton(s),
  animation clips, and embedded textures resolved by Godot (the import even produced
  `.ctex` files for `bat_tex`, `bat_tex_n`, `frost_bat_tex`). Wire it first; it is the
  reference for what a good export looks like. Two cleanups: (1) it ships a black
  2×2 m `Plane` mesh (almost certainly a source ground/shadow plane) — hide or delete
  it on wiring, it is not part of the bat; (2) it contains BOTH the normal and frost
  variants (static + animated copies of each), so Wave 2 should pick one variant
  subtree, not instance the whole scene. Note the bat clips all report 0.33 s in Godot
  (Attack 10 tracks, Die 38, Flying 20) plus a 0.04 s `Bat_preview_position` pose —
  play-check loop timing before relying on them, and treat the preview clip as a pose,
  not a gameplay animation.

### Conditional — wire only within the stated limits

- **cerberus_v002.glb** — skinned (49 bones) with Walk only; texture must be re-linked
  manually; Attack/Idle/Hit/Pose are missing (see warning check).
- **goblin.glb, snappa-kappa.glb** — skeletons present, no animation clips. Wire as
  skinned static/posed models, or author animations in Godot. Their materials are flat
  colours (goblin: green flesh, white eyes, black pupils, pinkish and brown surfaces;
  kappa: orange/red/brown/black surfaces) — no textures, but that suits their stylised
  look; confirm the intended appearance before adding texture work.
- **All 13 PS1 enemies** — wire as static meshes only. No skeleton, no clips, no
  textures (every surface flat grey). See "The PS1 pack problem" below.

### Unusable as-is — rework before any wiring

- **rat.glb (Evil Giant Rat)** — do not wire. What imports is not a rat, it is one
  stray mesh (see warning check).

## Recorded Blender warnings — do they matter in Godot?

### Vampire Bat (`bat_v5.glb`) — warnings do NOT block use

- "Mesh Cube.009 / Cube.000 is not valid, and may be exported wrongly" — Godot imported
  all 5 glTF meshes as 5 instances with textures and 4 clips. No mesh is missing
  relative to the glTF, so the flagged cubes appear to be minor/invisible parts, not the
  bat body. A visual check is still advised, but nothing in the Godot result shows damage.
- "The active Vertex Color will not be exported" — no visible consequence in Godot:
  the bat's materials carry the embedded JPG textures, so colour comes from textures,
  not vertex colours.
- "More than 4 joint vertex influences…" — truncated to the 4 strongest weights,
  normalised. Minor: deformation on heavily-weighted vertices may differ slightly from
  Blender. Only a visual animation check can confirm; it does not block wiring.

### Evil Giant Rat (`rat.glb`) — warning is FATAL to this export

- Recorded warning: "Mesh Cylinder.002 is not valid, and may be exported wrongly."
  Godot imported **exactly one mesh instance — Cylinder_002 — and nothing else**: no
  skeleton, no animations, no texture, and no other rat body parts. Its world AABB is
  1.24 × 1.64 × 7.16 m — one long thin thing, not a rat. The flagged mesh is not a
  damaged detail; it is the *entire* export. Either the source `.blend` only had that
  object visible/selected at export, or the rest of the model failed to export.
  **Wave 2 action: re-open `rat.blend`, confirm the full rat (body, head, tail, limbs,
  armature) exists, and re-export with all objects/armature included. Do not attempt to
  fix this GLB.**

### Animated Cerberus (`cerberus_v002.glb`) — warning does NOT break the rig, but the clip set is incomplete

- Recorded warning: "Armature must be the parent of skinned mesh…" — Godot produced a
  49-bone skeleton driving the single skinned mesh, so the armature parenting survived
  well enough in practice. The warning did not break the rig.
- Bigger issue, not a warning: the source page lists Attack, Idle, Hit, Pose, Walk, but
  the GLB (and Godot) contain **only Walk** (1.29 s, 43 tracks). The other four actions
  were not in the export — likely only the active action was exported. Wave 2 must either
  re-export with all actions (NLA strips / one action per clip) or author the missing
  clips in Godot.
- Texture: `cerberus_texture.png` sits next to the source `.blend` but was NOT embedded
  in the GLB; Godot shows a flat grey material. Re-link the texture manually on import —
  do not ship grey.

### snappaKappa (`snappa-kappa.glb`) — warnings are HARMLESS in Godot, but there are no animations

- Recorded warnings: same armature-parent warning as Cerberus, plus "Mesh 'Mesh' has no
  primitives and will be omitted." Godot imported a 21-bone skeleton and both real meshes
  (an unskinned 2-surface `Cube` plus a skinned 6-surface `Cube_002`), so the armature
  warning did not break the rig, and the omitted mesh was an empty placeholder. Neither
  warning blocks use.
- No animation clips survived (page says rigged, not necessarily animated). Wire as a
  posed/skinned static model, or animate in Godot.

### Goblin (`goblin.glb`) — flagged mesh DID import; influence truncation is the only open question

- Recorded warnings: "Mesh GEO-goblin is not valid, and may be exported wrongly" +
  ">4 joint influences…" Godot imported GEO-goblin (5 surfaces) on a 39-bone skeleton,
  so the validity warning did not prevent import. Geometry and skinning still need a
  **visual** check — headless import cannot prove the mesh is undeformed.
- No animation clips (page describes a simple weight-painted rig, not a clip set). Wire
  as skinned static/posed, or author animations in Godot.

## The PS1 pack problem (all 13) — clean Blender logs, incomplete Godot result

All 13 PS1 exports were "clean, no warnings" in Blender, but Godot shows the same gap in
every one: **meshes present, no skeleton, no animation clips, and no textures — every
material is flat grey** (glTF base colour 0.8 grey, shown in Godot as albedo ≈ 0.9063
after sRGB→linear conversion). The glTF files themselves contain no images at all, so
this is an export loss, not a Godot import failure: the Blender 2.79 sources use
pre-Principled materials, and the exporter dropped the PNG texture links (the
`enemy_*.png` files still sit next to the sources; since the GLB references no image,
they cannot be picked up automatically and must be re-linked by hand, per limb).

What DID survive, and matters for Wave 2: the PS1 "limbs as separate models" structure
is intact — each enemy imports as a set of separate MeshInstance nodes (bandit 11,
revenant 13), not a merged blob. That means Wave 2 can animate them procedurally by
moving individual limb nodes even with no skeleton or clips. Caveat: this check did not
verify limb pivot positions or node grouping (that needs the editor), so do not assume
limbs rotate about their joints until confirmed. Shipping the PS1 enemies as-is means
grey, static, untextured enemies — **rework (texture re-link + either procedural limb
animation or a re-export with Principled/textured materials) is required before they
read as PS1 enemies in-game.**

## Scale, origin, and bounds — read before wiring

Overall AABBs above are the generated scene's world AABB after Godot's glTF import
(Y-up). They are useful for relative sizing and collision-shape starting points, NOT
as final gameplay scale: these models come from unrelated sources with unrelated unit
conventions, so Wave 2 must normalise scale per enemy against the player capsule.

- **Raw sizes vary wildly:** cerberus 17.36 m long, bat 10.32 m wingspan, revenant
  6.20 m wide (limbs splayed — check its pose), versus goblin 1.49 m tall and most PS1
  enemies ~1–2 m. Nothing here can be dropped in at import scale.
- **Origins are inconsistent — check foot placement per file** (Y-min of the overall
  AABB): most PS1 enemies sit at Y ≈ 0 (good), but **cereptera floats at Y +0.94** and
  **helichard floats at Y +0.99**; **rattler dips to Y −0.25, rat to −0.95, bat to −0.69,
  kappa to −1.99, and cerberus to −6.49** (its mesh extends 6.49 m below the origin).
  Each of these needs a Y-offset / re-centre on wiring or it will float or sink.
- **Rattler carries a node scale:** its local segment lengths (~2.6 m) appear at ~0.65 m
  in world space, i.e. its nodes are scaled ~0.25. Do not "fix" this by rescaling the
  mesh without checking the node transforms.

## Per-file Godot detail

Sources are relative to
`assets/resources-phase1/models/` in the game project. "Import: PASS" means the editor
produced a `.scn` with no ERROR/WARNING in the import log and `GLTFDocument` generated
a scene. AABB format: position (min corner) and size.

### bat_v5.glb — SAFE

- Source: `vermin/vampire-bat-animated/bat_v5.glb` (3,585,524 bytes)
- MeshInstances (5): Bat_LP (2 surfaces, static), Frost_Bat_LP (2, static),
  Bat_LP_Anim (2, skinned, skeleton `..`), Frost_Bat_LP_Anim (2, skinned), Plane
  (1 surface, black, 2×2 m — source ground plane, remove on wiring)
- Skeletons (2 × 32 bones): Body_Main, Leg_1.R/L, Leg_2.R/L, Body_Main.001,
  W_01–W_11.R/L (wing), A_1, A_2, Jaw_Lower, Jaw_Upper, Ear.R/L (same list twice: one
  skeleton per variant)
- AnimationPlayer clips: Bat_Attack (0.33 s, 10 tracks), Bat_Die (0.33 s, 38 tracks),
  Bat_Flying (0.33 s, 20 tracks), Bat_preview_position (0.04 s, 9 tracks, pose only)
- Materials: first surface of each bat mesh has an embedded albedo texture PRESENT
  (bat_tex / frost_bat_tex incl. normal map `bat_tex_n` resolved as `.ctex` on editor
  import); second surfaces have no albedo texture
- Overall AABB: position (-5.16, -0.69, -2.19), size (10.32, 0.95, 4.31)

### cerberus_v002.glb — CONDITIONAL

- Source: `demons/animated-cerberus/cerberus_v002.glb` (95,096 bytes)
- MeshInstances (1): Cerberus (1 surface, skinned)
- Skeleton (49 bones): global, hips, spine_1–4, neck/head/jaw, neck_l/head_l/jaw_l,
  neck_r/head_r/jaw_r, front_leg_1/2/4_l/r, ass, tail_1, tail_2, back_leg_1–4_l/r,
  back_upper_leg_ctrl_l/r, back_leg_ctrl/ik/foot_ctrl_l/r, front_leg_ctrl/ik/foot_ctrl_l/r,
  chest_ctrl, chest_ik, neutral_bone
- AnimationPlayer clips: Walk only (1.29 s, 43 tracks). Attack, Idle, Hit, Pose absent.
- Materials: 1 surface, flat grey, no texture (`cerberus_texture.png` not embedded)
- Overall AABB: position (-4.71, -6.49, -8.24), size (9.41, 10.32, 17.36). Origin warning:
  mesh extends 6.49 m below origin.

### enemy_bandit.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_bandit.glb`
- MeshInstances (11): Plane, Cube_007, Cube_001, Cube_004, Cube_002, Cube_003, Cube_005,
  Cube, Cube_006, Cube_008, Cube_009 (1 surface each)
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-1.15, -0.00, -0.20), size (2.79, 2.45, 0.46)

### enemy_cannae.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_cannae.glb`
- MeshInstances (11): Cube, Cube_001, Cube_002, Cube_003, Cube_005, Cube_007, Cube_006,
  Cube_010, Cube_009, Cube_011, Cube_008 (1 surface each)
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-0.43, -0.00, -2.28), size (0.85, 1.12, 3.80)

### enemy_cereptera.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_cereptera.glb`
- MeshInstances (3): Cube_002, Cube_001, Cube (1 surface each)
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-0.22, 0.94, -1.25), size (0.40, 0.79, 2.50). Origin warning:
  floats 0.94 m above origin.

### enemy_clod.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_clod.glb`
- MeshInstances (6): Cube, Cube_001, Cube_002, Cube_003, Cube_004, Cube_005
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-1.00, -0.01, -0.36), size (2.00, 1.05, 0.86)

### enemy_cobracon.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_cobracon.glb`
- MeshInstances (7): Cube_000, Cube_001, Cube_002, Cube_003, Cube_004, Cube_005, Cube_006
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-0.39, 0.00, -1.53), size (0.78, 1.84, 2.63)

### enemy_helichard.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_helichard.glb`
- MeshInstances (2): Plane, Cylinder (1 surface each)
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-0.43, 0.99, -0.43), size (0.87, 0.73, 0.87). Origin warning:
  floats 0.99 m above origin.

### enemy_janga.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_janga.glb`
- MeshInstances (8): Cube, Cube_001, Cube_002, Cube_003, Cube_004, Cube_005, Cube_006,
  Cube_007
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-1.03, 0.00, -0.91), size (2.07, 1.42, 1.72)

### enemy_myocene.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_myocene.glb`
- MeshInstances (5): Cube_004, Cube_003, Cube_002, Cube_001, Cube
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-0.45, 0.00, -0.52), size (0.90, 1.02, 1.04)

### enemy_rattler.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_rattler.glb`
- MeshInstances (5): Cube_002, Cube_003, Cube, Cube_004, Cube_001 (node scale ~0.25:
  world segments ~0.65 m vs local ~2.6 m)
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-0.22, -0.25, -1.51), size (0.44, 0.33, 2.89). Origin warning:
  dips 0.25 m below origin.

### enemy_revenant.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_revenant.glb`
- MeshInstances (13): Cube, Cube_002, Cube_001, Cube_003, Cube_004, Cube_005, Cube_007,
  Cube_006, Cube_008, Cube_009, Cube_011, Cube_010, Cube_012
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-3.77, -0.00, -0.64), size (6.20, 1.92, 1.28). Pose warning:
  6.20 m wide — limbs appear splayed; check the pose in the editor before wiring.

### enemy_scorpion.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_scorpion.glb`
- MeshInstances (6): Cube_005, Cube_004, Cube_003, Cube_002, Cube_001, Cube
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-0.58, -0.03, -0.77), size (1.17, 1.07, 1.33)

### enemy_tardigrade.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_tardigrade.glb`
- MeshInstances (2): Cube_001, Cube
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-0.00, -0.00, -1.57), size (0.38, 1.59, 2.46)

### enemy_ungulate.glb — CONDITIONAL (static only)

- Source: `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/enemy_ungulate.glb`
- MeshInstances (6): Cube, Cube_001, Cube_002, Cube_003, Cube_004, Cube_005
- Skeleton: none. Clips: none. Materials: all flat grey, no textures.
- Overall AABB: position (-0.57, -0.00, -1.03), size (1.14, 1.42, 3.40)

### goblin.glb — CONDITIONAL (skinned, no clips)

- Source: `goblin-kin/goblin/goblin.glb` (94,608 bytes)
- MeshInstances (1): Goblin (5 surfaces, skinned)
- Skeleton (39 bones): base, spine, neck, head, jaw, arm_L/R, forearm_L/R, a1/a2_L/R,
  b1/b2_L/R, c1/c2_L/R, d1/d2_L/R, t1/t2_L/R, thigh_L/R, shin_L/R, foot_L/R,
  ik_foot_L/R, ik_knee_L/R
- AnimationPlayer clips: none.
- Materials: 5 surfaces, flat colours only (green flesh, white, black, pinkish, brown),
  no textures.
- Overall AABB: position (-0.90, -0.04, -0.17), size (1.81, 1.49, 0.53)

### rat.glb — UNUSABLE AS-IS

- Source: `vermin/evil-giant-rat/rat.glb` (38,436 bytes)
- MeshInstances (1): Cylinder_002 (1 surface) — the Blender-flagged mesh, and the only
  mesh in the file. No other rat parts exist in this GLB.
- Skeleton: none. Clips: none. Materials: 1 surface, flat grey, no texture.
- Overall AABB: position (-0.62, -0.95, -2.83), size (1.24, 1.64, 7.16) — one long thin
  object, not a rat. Re-export from `rat.blend` required.

### snappa-kappa.glb — CONDITIONAL (skinned, no clips)

- Source: `yokai/snappakappa-3d/snappa-kappa.glb` (73,508 bytes)
- MeshInstances (2): Cube (2 surfaces, unskinned), Cube_002 (6 surfaces, skinned)
- Skeleton (21 bones): Bone.003, Bone.03, leg.l, calf.l, foot.l, claw.l, Bone.05, Bone.06,
  leg.r, calf.r, foot.r, claw.r, Bone.09, Bone, Bone.001, Bone.002, Bone.12,
  claw.l.001, claw.l.002, claw.r.001, claw.r.002
- AnimationPlayer clips: none.
- Materials: 8 surfaces total, flat colours only (orange, grey, olive, dark red, black),
  no textures.
- Overall AABB: position (-2.08, -1.99, -1.01), size (3.82, 2.97, 2.01). Origin warning:
  mesh extends 1.99 m below origin.

## What Wave 2 must still do (not done here)

1. Visual pass in the editor for goblin skinning, bat wing deformation, and the PS1
   limb pivots/grouping — headless import cannot prove these.
2. Re-export the rat from `rat.blend` with the full model + armature; re-export (or
   author) Cerberus Attack/Idle/Hit/Pose; author or re-export animations for goblin
   and kappa.
3. Re-link textures by hand: all 13 PS1 `enemy_*.png` files and Cerberus's
   `cerberus_texture.png`. Nothing in these GLBs references an external texture, so
   this is manual material work, not an import setting.
4. Normalise scale and ground offset per enemy (see scale/origin notes); remove the
   bat's `Plane` and pick one bat variant before wiring.
5. If Cerberus or snappaKappa ship, their REQUIRED credits apply (CC-BY 3.0 and
   CC-BY 4.0 respectively, per the Phase 1b ledger) — a credits question for the parent,
   not something this verification changed.
