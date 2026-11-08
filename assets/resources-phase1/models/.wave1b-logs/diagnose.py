import bpy
import sys

argv = sys.argv
argv = argv[argv.index("--") + 1:]
src = argv[0]
bpy.ops.wm.open_mainfile(filepath=src)
print(f"=== DIAG {src} ===")
print(f"scenes: {[s.name for s in bpy.data.scenes]}")
print(f"collections: {[c.name for c in bpy.data.collections]}")
print(f"--- scene objects ({len(bpy.context.scene.objects)}):")
for o in bpy.context.scene.objects:
    dims = None
    try:
        dims = tuple(round(d, 3) for d in o.dimensions)
    except Exception as e:
        dims = f"ERR {e}"
    print(f"  {o.type:10s} {o.name!r} parent={o.parent.name if o.parent else None!r} "
          f"hide_vp={o.hide_viewport} hide_render={o.hide_render} "
          f"visible={o.visible_get()} dims={dims}")
print(f"--- all meshes in file ({len(bpy.data.meshes)}):")
for m in bpy.data.meshes:
    print(f"  mesh {m.name!r} verts={len(m.vertices)} polys={len(m.polygons)} users={m.users}")
print(f"--- armatures ({len(bpy.data.armatures)}):")
for a in bpy.data.armatures:
    print(f"  armature {a.name!r} bones={len(a.bones)}")
print(f"--- actions ({len(bpy.data.actions)}):")
for act in bpy.data.actions:
    try:
        fr = act.frame_range
    except Exception:
        fr = "?"
    print(f"  action {act.name!r} frames={fr} users={act.users} "
          f"fcurves={len(act.fcurves) if hasattr(act, 'fcurves') else 'n/a (layered)'}")
print(f"--- animated objects (animation_data):")
for o in bpy.data.objects:
    ad = o.animation_data
    if ad is not None:
        act = ad.action.name if ad.action else None
        tracks = [(t.name, len(t.strips)) for t in ad.nla_tracks] if ad.nla_tracks else []
        print(f"  obj {o.name!r} active_action={act!r} nla_tracks={tracks}")
print(f"--- materials ({len(bpy.data.materials)}):")
for mat in bpy.data.materials:
    use_nodes = mat.use_nodes
    imgs = []
    if use_nodes and mat.node_tree:
        for n in mat.node_tree.nodes:
            if n.type == 'TEX_IMAGE' and n.image:
                imgs.append((n.name, n.image.name, n.image.filepath))
    print(f"  material {mat.name!r} use_nodes={use_nodes} images={imgs}")
print(f"--- images ({len(bpy.data.images)}):")
for im in bpy.data.images:
    print(f"  image {im.name!r} filepath={im.filepath!r} packed={bool(im.packed_file)} size={im.size[:]}")
print("=== END DIAG ===")
