extends Node

signal inventory_changed

var game_state := GameState.new()

var coat_textures: Array

const save_path := "user://autosave.tres"
var valid_game_state := false
var can_pause := true

var color_common := Color.white
var color_uncommon := Color.chartreuse
var color_rare := Color.mediumblue
var color_super_rare := Color.darkorchid
var color_sublime := Color.coral

func _ready():
	randomize()
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

func _input(event):
	if event.is_action_pressed("quick_save"):
		save_sync()
	elif event.is_action_pressed("quick_load"):
		load_sync()

# Game state management

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

func add_item(item: String):
	if item in game_state.inventory:
		game_state.inventory[item] += 1
	else:
		game_state.inventory[item] = 1
	emit_signal("inventory_changed")

func remove_item(item: String, amount := 1) -> bool:
	if count(item) >= amount:
		game_state.inventory[item] -= amount
		emit_signal("inventory_changed")
		return true
	else:
		return false

func add_coat(coat: Coat):
	game_state.all_coats.append(coat)

func mark_picked(path: NodePath):
	game_state.picked_items.append(path)

func is_picked(path: NodePath) -> bool:
	return path in game_state.picked_items

func is_activated(node: Node) -> bool:
	return node.get_path() in game_state.activated

func mark_activated(node: Node):
	if !node.get_path() in game_state.activated:
		game_state.activated.append(node.get_path())

# Coats

func get_coat(cgen_seed: int) -> Coat:
	if coat_textures.size() == 0:
		print_debug("No coat textures!")
		return null
	var coat := Coat.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = cgen_seed
	
	var colors: int
	if cgen_seed < (1 << 16):
		colors = 7
		coat.rarity = coat.Rarity.Sublime
	elif cgen_seed < (1 << 32):
		colors = 5
		coat.rarity = coat.Rarity.SuperRare
	elif cgen_seed < (1 << 36):
		colors = 4
		coat.rarity = coat.Rarity.Rare
	elif cgen_seed < (1 << 56):
		colors = 3
		coat.rarity = coat.Rarity.Uncommon
	else:
		colors = 2
		coat.rarity = coat.Rarity.Uncommon
	
	coat.gradient = Gradient.new()
	
	for p in range(colors):
		var o := rng.randf()
		var c := Color(rng.randf(), rng.randf(), rng.randf())
		if p <= 1:
			coat.gradient.colors[p] = c
			coat.gradient.offsets[p] = o
		else:
			coat.gradient.add_point(o, c)
	
	coat.palette = coat_textures[cgen_seed % coat_textures.size()]
	return coat

#Saving and loading

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
