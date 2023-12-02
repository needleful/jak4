extends Control

enum Mode {
	Paused,
	Gameing,
	Dialog,
	DebugConsole,
	StoryTime,
	Custom
}

var mode:int = Mode.Gameing setget set_mode
var mode_before_pause:int = Mode.Gameing

export(Color) var stamina_color = Color(0xacff97)
export(Color) var drained_stamina_color = Color.red
onready var game := $gameing/gameing
onready var dialog := $dialog/dialog/viewer
onready var status := $status_menu
onready var equipment := $gameing/gameing/equipment
onready var debug_ui := $gameing/gameing/debug
var equipment_path_f := "res://items/usable/%s.gd"

var custom_ui : Control
var loaded_ui : PackedScene
var input_blocked := false
var prompt_queue : Array

const VISIBLE_ITEMS := [
	"bug",
	"capacitor",
	"gem",
]

const UPGRADE_ITEMS := [
	"armor",
	"damage_up",
	"health_up",
	"jump_height_up",
	"move_speed_up",
	"stamina_booster",
	"stamina_up",
	"hover_speed_up"
]

var AMMO := {
	"pistol" : 100,
	"wave_shot" : 70,
	"grav_gun" : 40
}

const WEAPONS := [
	"wep_pistol",
	"wep_wave_shot",
	"wep_grav_gun",
	"wep_time_gun"
]

var choose_time := 0.0
const TIME_CHOOSE_ITEM := 0.25

var equipment_inventory: Dictionary
onready var player := get_parent()
var choosing_item := false

func _init():
	equipment_inventory = {}
	prompt_queue = []

func _ready():
	var _x = Global.connect("item_changed", self, "on_item_changed")
	_x = Global.connect("journal_updated", self, "on_journal_updated")
	_x = Global.connect("task_completed", self, "on_task_completed")
	set_mode(Mode.Gameing)
	set_process_input(true)
	InputManagement.ui = self

func activate():
	update_inventory(true)
	equip(0)

func _input(event):
	match mode:
		Mode.Gameing, Mode.Dialog:
			if event.is_action_pressed("pause"):
				set_mode(Mode.Paused)
				get_tree().set_input_as_handled()
			elif using_console(event):
				set_mode(Mode.DebugConsole)
				get_tree().set_input_as_handled()
		Mode.Paused:
			if event is InputEventMouse:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if event.is_action_pressed("pause"):
				var _x = unpause()
				get_tree().set_input_as_handled()
			elif event.is_action_pressed("ui_page_up"):
				status.next()
				get_tree().set_input_as_handled()
			elif event.is_action_pressed("ui_page_down"):
				status.prev()
				get_tree().set_input_as_handled()
			elif using_console(event):
				set_mode(Mode.DebugConsole)
				get_tree().set_input_as_handled()
		Mode.Custom:
			if event.is_action_pressed("pause"):
				set_mode(Mode.Gameing)
				get_tree().set_input_as_handled()
			elif using_console(event):
				set_mode(Mode.DebugConsole)
				get_tree().set_input_as_handled()
		Mode.DebugConsole:
			if using_console(event):
				var _x = unpause()
				get_tree().set_input_as_handled()
		Mode.StoryTime:
			if !$story_time.exit_ready:
				return
			if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
				set_mode(Mode.Paused)

func _process(delta):
	if mode == Mode.Gameing:
		var scn = get_tree().current_scene
		if scn.has_method("get_time"):
			debug_ui.get_node("stats/a10").text = "Time: " + str(scn.get_time())
		debug_ui.get_node("stats/a7").text = str(player.timers)
	
		debug_ui.get_node("stats/a4").text = "Gr: " + str(player.ground_normal)
		if player.holding("choose_item"):
			choose_time += delta
			if choose_time > TIME_CHOOSE_ITEM:
				choosing_item = true
				equipment.open()
		else:
			choose_time = 0
		
		if choosing_item and !player.holding("choose_item"):
			choosing_item = false
			equipment.close()

func using_console(event: InputEvent):
	 return (
		Settings.sub_options["Difficulty"].enable_console
		and event.is_action_pressed("debug_console"))

func update_inventory(startup:= false):
	for item in Global.game_state.inventory.keys():
		on_item_changed(item, 0, Global.count(item), startup)
	for item in UPGRADE_ITEMS:
		on_item_changed(item, 0, Global.count(item), startup)
	game.get_node("weapon/ammo/ammo_label").text = str(Global.count(player.current_weapon))

func on_item_changed(item: String, change: int, count: int, startup := false):
	if item in VISIBLE_ITEMS:
		if !startup and !Global.stat("tutorial/items"):
			var _x = Global.add_stat("tutorial/items")
			show_prompt(["show_inventory"], "Show Inventory")
		var l_count: Label = game.get_node("inventory/"+item+"_count")
		l_count.text = str(count)
		if change != 0:
			var added: Label = game.get_node("inventory/"+item+"_added")
			var c = change
			if added.modulate.a > 0.01:
				var old_added = int(added.text)
				c = change + old_added
			added.text = "+ "+str(c) if c > 0 else "- "+str(abs(c))
			var anim = added.get_node("AnimationPlayer")
			anim.stop()
			anim.play("show")
		show_specific_item(item)
		if !startup and item == "capacitor":
			if change > 0:
				write_log("You found a Capacitor!")
			else:
				write_log("You place the Capacitor.")
		return
	elif item in WEAPONS:
		var wep_select := ""
		var wep_name := ""
		var already_has_wep:bool = Global.stat("weapon") > 0
		match item:
			"wep_pistol":
				wep_select = "wep_1"
				wep_name = tr("Pistol")
			"wep_wave_shot":
				wep_select = "wep_2"
				wep_name = tr("Bubble Shot")
			"wep_grav_gun":
				wep_select = "wep_3"
				wep_name = tr("Gravity Cannon")
			"wep_time_gun":
				wep_select = "wep_4"
				wep_name = tr("Time Gun")
		if count > 0:
			player.gun.add_weapon(item, startup)
			if !startup:
				player.gun.swap_to(item)
			show_ammo()
			if !startup:
				show_prompt([wep_select], wep_name)
				if item == "wep_wave_shot":
					queue_prompt(['combat_shoot'], "(Hold) Charge Bubble")
				elif !already_has_wep:
					queue_prompt(['combat_shoot'], "Fire Weapon")
		else:
			player.gun.remove_weapon(item)
		if !startup:
			if change > 0:
				write_log("Weapon found: "+wep_name)
			else:
				write_log("Weapon removed: "+wep_name)
	elif player.current_weapon == item:
		game.get_node("weapon/ammo/ammo_label").text = str(count)
		if player.current_weapon and !game.get_node("weapon").visible:
			show_ammo()
		if !startup and change > 0:
			write_log("Found: "+item.capitalize()+" Ammo")
	elif item in player.mesh.coat_mesh.meshes:
		player.mesh.set_coat_type(item, !startup)
		if !startup and change > 0:
			write_log("New Coat: "+item.capitalize())
	else:
		if !startup:
			if change > 0:
				write_log("Item found: "+ item.capitalize())
			else:
				write_log("Item removed: "+item.capitalize())
		match item:
			"health_up":
				var health_up := count
				var h_factor = (1.0 + player.HEALTH_UP_BOOST*health_up)
				player.max_health = player.DEFAULT_MAX_HEALTH*h_factor
			"stamina_up":
				var stamina_up := count
				var s_factor = (1.0 + player.STAMINA_UP_BOOST*stamina_up)
				player.max_stamina = player.DEFAULT_MAX_STAMINA*s_factor
				player.stamina = player.max_stamina
			"jump_height_up":
				player.jump_factor = (1 + player.JUMP_UP_BOOST*count)
			"move_speed_up":
				player.speed_factor = (1 + player.SPEED_UP_BOOST*count)
			"move_speed_up":
				player.stamina_drain_factor = (1 + player.SPEED_STAMINA_BOOST*count)
			"damage_up":
				var damage_up_count := count
				player.damage_factor = (1 + player.DAMAGE_UP_BOOST*damage_up_count)
				player.max_damage = damage_up_count >= player.MAX_DAMAGE_UP
			"armor":
				var new_armor:int = count
				if new_armor > player.armor:
					player.extra_health += (new_armor - player.armor)*player.ARMOR_BOOST
				player.armor = new_armor
			"stamina_booster":
				player.extra_stamina = count*player.EXTRA_STAMINA_BOOST
				player.energy = count
				
			"hover_speed_up":
				player.hover_speed_factor = 1.0 + player.HOVER_SPEED_BOOST*count
			"hover_scooter":
				if !startup:
					show_prompt(["hover_toggle"], "Use hover-scooter")
			_:
				var old_item_count := equipment_inventory.size()
				if ResourceLoader.exists(equipment_path_f % item):
					if count <= 0 and item in equipment_inventory:
						if equipment_inventory[item] == player.equipped_item:
							if equipment_inventory.size() > 1:
								equip_previous()
							elif player.equipped_item:
								player.equipped_item.unequip()
								player.equipped_item = null
						var _x = equipment_inventory.erase(item)
					elif count > 0 and !(item in equipment_inventory):
						var s: Script = ResourceLoader.load(equipment_path_f % item)
						if s:
							equipment_inventory[item] = s.new()
							if player.equipped_item:
								player.equipped_item.unequip()
							player.equipped_item = equipment_inventory[item]
							player.equipped_item.equip()
							update_equipment()
				if !startup and equipment_inventory.size() > old_item_count:
					if equipment_inventory.size() == 1:
						show_prompt(["use_item"], tr("Use Item"))
					else:
						show_prompt(["choose_item"], tr("(Hold) Swap Item"))

func on_task_completed(id: String):
	write_log("Task Completed: "+ id.capitalize())

func on_journal_updated(tags: Array):
	var t := PoolStringArray()
	for tag in tags:
		if !Global.has_stat(tag):
			t.append(tag.capitalize())
	write_log("Journal Updated: "+ t.join(", "))

func equip_previous():
	if equipment_inventory.size() == 1:
		return update_equipment()
	else:
		var index = equipment_inventory.values().find(player.equipped_item)
		equip(index - 1)

func equip_next():
	if equipment_inventory.size() == 1:
		return update_equipment()
	else:
		var index = equipment_inventory.values().find(player.equipped_item)
		equip(index + 1)

func equip(index):
	if equipment_inventory.size() == 0:
		return
	if player.equipped_item:
		player.equipped_item.unequip()
	var ln = equipment_inventory.size()
	while index < 0:
		index += ln
	while index >= ln:
		index -= ln
	player.equipped_item = equipment_inventory.values()[index]
	player.equipped_item.equip()
	update_equipment()

func update_equipment():
	var values = equipment_inventory.values()
	var index = values.find(player.equipped_item)
	if index >= 0:
		equipment.temp_show()
		var prev_index = index - 1
		var next_index = index + 1
		var ln = values.size()
		if prev_index < 0:
			prev_index += ln
		if next_index >= ln:
			next_index -= ln
		equipment.preview(values[index], values[prev_index], values[next_index])

func show_inventory():
	var I := game.get_node("inventory")
	for g in I.get_children():
		if g is CanvasItem:
			g.visible = true
	I.show()
	I.get_node("vis_timer").start()
	show_ammo()
	update_equipment()

func show_specific_item(item):
	var I := game.get_node("inventory")
	if !I.visible:
		for g in I.get_children():
			if g is CanvasItem:
				g.visible = false
		I.show()
	I.get_node("vis_timer").start()
	var count = I.get_node(item+"_count")
	var icon = I.get_node(item+"_icon")
	var added = I.get_node(item+"_added")
	if !icon or !count or !added:
		print_debug("BUG: no inventory for ", item)
		return
	added.show()
	icon.show()
	count.show()

func _on_vis_timer_timeout():
	game.get_node("inventory").hide()
	if player.gun.state == Gun.State.Hidden:
		hide_ammo()
		
func show_ammo():
	if player.current_weapon and player.current_weapon != "":
		game.get_node("weapon").show()

func hide_ammo():
	game.get_node("weapon").hide()

func add_label(box: Control, text: String):
	var l := Label.new()
	l.text = text
	box.add_child(l)

func debug_show_inventory():
	var state_viewer: Control = debug_ui.get_node("game_state")
	for c in state_viewer.get_children():
		state_viewer.remove_child(c)
	add_label(state_viewer, "Inventory:")
	for i in Global.game_state.inventory:
		add_label(state_viewer, "\t%s: %d" % [i, Global.count(i)])

func prepare_save():
	write_log("Saving...")

func complete_save():
	write_log("SAVED!")

func start_dialog(source: Node, sequence: Resource, speaker: Node, starting_label := ""):
	set_mode(Mode.Dialog)
	dialog.start(source, sequence, speaker, starting_label)

func in_dialog():
	return mode == Mode.Dialog

func set_mode(m):
	if m < 0 or m >= get_child_count():
		print_debug("Bad mode! ", m)
		return
	
	var should_pause: bool = (m == Mode.Paused or m == Mode.DebugConsole)
	if !should_pause:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var toggled_pause := false
	if should_pause and !get_tree().paused:
		toggled_pause = true
		mode_before_pause = mode
	get_tree().paused = should_pause
	
	if should_pause and $story_time.queued_story:
		m = Mode.StoryTime
		$story_time.start_countdown()
	
	if m != Mode.Paused:
		Global.get_player().set_camera_render(true)
	elif toggled_pause:
		take_screen_shot()

	mode = m
	var i = 0
	for c in get_children():
		if !(c is Control):
			continue
		c.visible = i == mode
		i += 1

func show_prompt(actions: Array, text: String, joiner := "+"):
	var tut := game.get_node("tutorial")
	tut.get_node("prompt_timer").stop()
	tut.get_node("joiner").text = joiner
	if actions.size() >= 1:
		tut.get_node("input_prompt").show()
		tut.get_node("input_prompt").action = actions[0]
	else:
		tut.get_node("input_prompt").hide()
	if actions.size() >= 2:
		tut.get_node("joiner").show()
		tut.get_node("input_prompt2").show()
		tut.get_node("input_prompt2").action = actions[1]
	else:
		tut.get_node("joiner").hide()
		tut.get_node("input_prompt2").hide()

	tut.get_node("Label").text = text
	tut.show()
	tut.get_node("prompt_timer").start()

func queue_prompt(actions:Array, text: String, joiner := "+"):
	prompt_queue.append({
		'actions':actions,
		'text':text,
		'joiner':joiner
	})

func hide_prompt():
	game.get_node("tutorial").hide()
	game.get_node("tutorial/prompt_timer").stop()

func _on_prompt_timer_timeout():
	if prompt_queue.empty():
		game.get_node("tutorial").hide()
	else:
		var prompt : Dictionary = prompt_queue.pop_front()
		show_prompt(prompt.actions, prompt.text, prompt.joiner)

# TODO: fix in multi-threaded rendering
func take_screen_shot():
	Global.get_player().set_camera_render(true)
	hide()
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var screen = get_viewport().get_texture().get_data()
	var stex = ImageTexture.new()
	stex.create_from_image(screen)
	$status_menu/TextureRect.texture = stex
	show()
	Global.get_player().set_camera_render(false)

func show_status() -> bool:
	set_mode(Mode.Paused)
	return true

func unpause() -> bool:
	set_mode(mode_before_pause)
	block_input()
	return true

func play_game() -> bool:
	block_input()
	set_mode(Mode.Gameing)
	return true

func open_custom(scene: PackedScene) -> bool:
	if !scene:
		return false

	if loaded_ui == scene:
		set_mode(Mode.Custom)
		return true

	var cui := scene.instance() as Control
	if !cui:
		return false

	if custom_ui:
		$custom_ui.remove_child(custom_ui)
		custom_ui.queue_free()
	custom_ui = cui
	$custom_ui.add_child(custom_ui)

	if custom_ui.has_signal("exited"):
		var _x = custom_ui.connect("exited", self, "play_game")
	
	loaded_ui = scene
	
	set_mode(Mode.Custom)
	custom_ui.show()
	return true

func block_input():
	input_blocked = true
	yield(get_tree().create_timer(0.1), "timeout")
	input_blocked = false

func write_log(message: String):
	game.get_node("log").echo(message)
	dialog.get_node("log").echo(message)
	$debug_console.echo(message)
