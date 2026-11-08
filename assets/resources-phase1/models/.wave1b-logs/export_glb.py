import bpy
import sys
import os

argv = sys.argv
argv = argv[argv.index("--") + 1:]
src, dst = argv[0], argv[1]
print(f"EXPORT-START src={src} dst={dst}")
bpy.ops.wm.open_mainfile(filepath=src)
print(f"OPENED {src}")
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_yup=True)
print(f"EXPORT-DONE dst={dst} size={os.path.getsize(dst)}")
