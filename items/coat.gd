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

func generate_material() -> Material:
	var mat = ShaderMaterial.new()
	mat.shader = load("res://material/coat.shader")
	
	var gt := GradientTexture.new()
	gt.gradient = gradient
	mat.set_shader_param("gradient", gt)
	mat.set_shader_param("softness", 0.25)
	mat.set_shader_param("palette", palette)
	
	return mat

func _init():
	resource_name = "Coat"
