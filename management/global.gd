extends Node

signal inventory_changed
signal item_changed(item)
signal stat_changed(tag, value)

var using_gamepad := false

var game_state := GameState.new()

var coat_textures: Array

const save_path := "user://autosave.tres"
var valid_game_state := false
var can_pause := true

var color_common := Color.white
var color_uncommon := Color.chartreuse
var color_rare := Color.darkcyan
var color_super_rare := Color.darkorchid
var color_sublime := Color.coral

# Items that also have a "stat" value, 
# measuring the total collected 
var tracked_items = ["bug", "capacitor"]
var checkpoint_position : Vector3

func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _input(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if !using_gamepad:
			print("Switched to gamepad")
		using_gamepad = true
	elif event is InputEventMouse or event is InputEventKey:
		if using_gamepad:
			print("Switched to keyboard")
		using_gamepad = false

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

func get_player() -> Node:
	return get_tree().current_scene.get_node("player")

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

func add_item(item: String, amount:= 1) -> int:
	if item in game_state.inventory:
		game_state.inventory[item] += amount
	else:
		game_state.inventory[item] = amount
	if item in tracked_items:
		var _x = add_stat(item, amount)
	emit_signal("inventory_changed")
	emit_signal("item_changed", item)
	return game_state.inventory[item]

func remove_item(item: String, amount := 1) -> bool:
	if count(item) >= amount:
		game_state.inventory[item] -= amount
		emit_signal("inventory_changed")
		return true
	else:
		return false

func set_stat(tag: String, value):
	game_state.stats[tag] = value
	emit_signal("stat_changed", tag, value)
	return value

func add_stat(tag: String, amount := 1) -> int:
	if tag in game_state.stats:
		game_state.stats[tag] += amount
	else:
		game_state.stats[tag] = amount
	var value =  game_state.stats[tag]
	emit_signal("stat_changed", tag, value)
	return value

func add_coat(coat: Coat):
	game_state.all_coats.append(coat)

func remove_coat(coat: Coat):
	var index: int = game_state.all_coats.find(coat)
	if index >= 0:
		game_state.all_coats.remove(index)

func mark_picked(path: NodePath):
	game_state.picked_items.append(path)

func is_picked(path: NodePath) -> bool:
	return path in game_state.picked_items

func is_activated(node: Node) -> bool:
	return node.get_path() in game_state.activated

func mark_activated(node: Node):
	if !node.get_path() in game_state.activated:
		game_state.activated.append(node.get_path())

func get_rarity_color(rarity: int) -> Color:
	match rarity:
		Coat.Rarity.Common:
			return color_common
		Coat.Rarity.Uncommon:
			return color_uncommon
		Coat.Rarity.Rare:
			return color_rare
		Coat.Rarity.SuperRare:
			return color_super_rare
		Coat.Rarity.Sublime:
			return color_sublime
		_:
			return Color.white

#Saving and loading

func save_checkpoint(pos: Vector3):
	checkpoint_position = pos
	save_sync()

func save_game():
	save_sync()

func load_sync():
	if ResourceLoader.exists(save_path):
		game_state = ResourceLoader.load(save_path, "", true)
		valid_game_state = true
		checkpoint_position = game_state.player_transform.origin
		var _x = get_tree().reload_current_scene()
	else:
		print_debug("Tried to load with no save at ", save_path)
		valid_game_state = false

func save_sync():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "pre_save_object", "prepare_save")
	var _x = ResourceSaver.save(save_path, game_state)
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "post_save_object", "complete_save")
