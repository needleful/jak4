extends Resource
class_name ItemDescription

export(Texture) var icon
export(PackedScene) var preview_3d
export(String) var full_name
export(String, MULTILINE) var description
# key: item id
# value: visual name
export(Dictionary) var extra_items
