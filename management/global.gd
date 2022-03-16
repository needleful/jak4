extends Node

var coat_textures: Array

func _ready():
	var coat_dir := Directory.new()
	if coat_dir.open("res://material/coat/") == OK:
		var _x = coat_dir.list_dir_begin()
		var file_name = coat_dir.get_next()
		while file_name != "":
			if !coat_dir.current_is_dir() and !file_name.ends_with("import"):
				var texture = load("res://material/coat/" + file_name) as Texture
				if texture:
					coat_textures.append(texture)
			file_name = coat_dir.get_next()
	else:
		print_debug("Could not open coat directory!")


func get_coat(cgen_seed: int) -> ShaderMaterial:
	if coat_textures.size() == 0:
		print_debug("No coat textures!")
		return null
	var rng = RandomNumberGenerator.new()
	rng.seed = cgen_seed
	
	var s = ShaderMaterial.new()
	s.shader = load("res://material/coat.shader")
	
	var colors: int
	if cgen_seed < (1 << 16):
		colors = 7
	elif cgen_seed < (1 << 32):
		colors = 5
	elif cgen_seed < (1 << 36):
		colors = 4
	elif cgen_seed < (1 << 56):
		colors = 3
	else:
		colors = 2
	
	var g := Gradient.new()
	
	for _x in range(colors):
		g.add_point(rng.randf(), Color(rng.randf(), rng.randf(), rng.randf()))
	
	var gt := GradientTexture.new()
	gt.gradient = g
	
	var pt: Texture = coat_textures[cgen_seed % coat_textures.size()]
	
	s.set_shader_param("gradient", gt)
	s.set_shader_param("softness", 0.25)
	s.set_shader_param("palette", pt)
	
	return s
