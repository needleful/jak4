extends Resource
class_name Coat

enum Rarity {
	Common,
	Uncommon,
	Rare,
	SuperRare,
	Sublime
}

export(int) var rarity = Rarity.Common
export(Texture) var palette: Texture
export(Gradient) var gradient: Gradient

func generate_material(backface_culling := true) -> Material:
	var mat = ShaderMaterial.new()
	if !backface_culling:
		mat.shader = load("res://material/coat_doublesided.shader")
	else:
		mat.shader = load("res://material/coat.shader")
	
	var gt := GradientTexture.new()
	gt.gradient = gradient
	gt.width = 64
	mat.set_shader_param("gradient", gt)
	mat.set_shader_param("softness", 0.25)
	mat.set_shader_param("palette", palette)
	
	return mat

func _init():
	resource_name = "Coat"
