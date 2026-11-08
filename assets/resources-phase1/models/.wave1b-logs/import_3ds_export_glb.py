import bpy
import sys
import os

argv = sys.argv
argv = argv[argv.index("--") + 1:]
src, dst = argv[0], argv[1]
print(f"IMPORT3DS-START src={src} dst={dst}")
import addon_utils
addon_utils.enable("io_scene_3ds")
print("3DS addon enabled:", addon_utils.check("io_scene_3ds"))
bpy.ops.wm.read_homefile(use_empty=True)
bpy.ops.import_scene.autodesk_3ds(filepath=src)
print("IMPORTED objects:", [o.name for o in bpy.context.scene.objects])
print("IMPORTED meshes:", [m.name for m in bpy.data.meshes])
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_yup=True)
print(f"EXPORT-DONE dst={dst} size={os.path.getsize(dst)}")
