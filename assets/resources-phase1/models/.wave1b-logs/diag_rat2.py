import bpy, sys
argv = sys.argv; argv = argv[argv.index("--")+1:]
bpy.ops.wm.open_mainfile(filepath=argv[0])
print("total bpy.data.objects:", len(bpy.data.objects))
for o in bpy.data.objects:
    print(f"  {o.type} {o.name!r} users={o.users}")
for c in bpy.data.collections:
    print(f"collection {c.name!r} objects={[o.name for o in c.objects]} children={[ch.name for ch in c.children]} exclude={c.hide_viewport}")
print("scene collection children:", [ch.name for ch in bpy.context.scene.collection.children])
print("scene collection objects:", [o.name for o in bpy.context.scene.collection.objects])
print("view_layer objects:", [(o.name, o.hide_viewport) for o in bpy.context.view_layer.objects])
