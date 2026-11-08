import bpy
import sys
import os

argv = sys.argv
argv = argv[argv.index("--") + 1:]
src, dst = argv[0], argv[1]
print(f"CERB-FIX-START src={src} dst={dst}")
bpy.ops.wm.open_mainfile(filepath=src)

# --- diagnostics before fix ---
mesh_obj = bpy.data.objects.get("Cerberus")
mesh = mesh_obj.data if mesh_obj else None
if mesh:
    print("mesh UV layers:", [uv.name for uv in mesh.uv_layers])
    print("mesh material slots:", [s.material.name if s.material else None for s in mesh_obj.material_slots])
arm = bpy.data.objects.get("Armature")
print("armature visible_get:", arm.visible_get() if arm else None)
print("actions in file:", sorted(a.name for a in bpy.data.actions))

# --- fix 1: NLA strips, one track per action, then clear active action ---
# (glTF exporter exports NLA strips + active action; the old export had only
# the active action 'Walk' because there were no NLA tracks. This recovers
# every action already present in the file; it authors nothing new.)
ad = arm.animation_data
if ad is None:
    ad = arm.animation_data_create()
for track in list(ad.nla_tracks):
    ad.nla_tracks.remove(track)
for act_name in sorted(a.name for a in bpy.data.actions):
    act = bpy.data.actions[act_name]
    track = ad.nla_tracks.new()
    track.name = act_name
    start = int(act.frame_range[0])
    strip = track.strips.new(act_name, start, act)
    print(f"  NLA track {track.name!r} strip {strip.name!r} action {act.name!r} "
          f"frames {act.frame_range[0]}-{act.frame_range[1]}")
ad.action = None
ad.use_nla = True

# --- fix 2: re-link texture via a node tree (old Blender Internal material
# had use_nodes=False, so the exporter could not see the texture) ---
# The image datablock already points at //cerberus_texture.png next to the
# .blend; this only wires it into a Principled node tree. No new texture.
mat = bpy.data.materials.get("Material.001")
if mat is not None:
    mat.use_nodes = True
    nt = mat.node_tree
    for node in list(nt.nodes):
        nt.nodes.remove(node)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.get("cerberus_texture.png")
    print("  texture node image:", tex.image.name if tex.image else None,
          "filepath:", tex.image.filepath if tex.image else None)
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    nt.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

# --- export WITHOUT saving the .blend (source stays pristine) ---
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_yup=True)
print(f"EXPORT-DONE dst={dst} size={os.path.getsize(dst)}")
print("NOTE: .blend was NOT saved; fixes live only in this export + this script.")
