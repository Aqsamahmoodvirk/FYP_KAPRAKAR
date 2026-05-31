import bpy
import sys

argv = sys.argv
argv = argv[argv.index("--") + 1:]

user_height = float(argv[0])
user_width = float(argv[1])
texture_path = argv[2]

obj = bpy.data.objects['Mannequin']

obj.scale[2] = user_height / 1.8
obj.scale[0] = user_width / 0.5
obj.scale[1] = user_width / 0.5

mat = bpy.data.materials.get("DressMaterial")

nodes = mat.node_tree.nodes

texture_node = nodes.get("Image Texture")

texture_node.image = bpy.data.images.load(texture_path)

bpy.context.scene.render.filepath = "preview_output.png"

bpy.ops.render.render(write_still=True)