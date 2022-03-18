extends Node

var game_state := GameState.new()

var coat_textures: Array

const save_path := "user://autosave.tres"
var valid_game_state := false

func _input(event):
	if event.is_action_pressed("quick_save"):
		save_sync()
	elif event.is_action_pressed("quick_load"):
		load_sync()

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

func stat(index: String):
	if index in game_state.stats:
		return game_state.stats[index]
	else:
		return 0

func count(item: String) -> int:
	if item in game_state.inventory:
		return game_state.inventory[item]
	else:
		return 0

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

func load_sync():
	if ResourceLoader.exists(save_path):
		game_state = ResourceLoader.load(save_path, "", true)
		valid_game_state = true
		var _x = get_tree().reload_current_scene()
	else:
		print_debug("Tried to load with no save at ", save_path)
		valid_game_state = false

func save_sync():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "pre_save_object", "prepare_save")
	var _x = ResourceSaver.save(save_path, game_state)
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "post_save_object", "complete_save")
