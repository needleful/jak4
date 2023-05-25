extends Control

signal active(active)
signal exited

var player: PlayerBody

export(bool) var pause_menu := false

var coats_by_rarity: Dictionary
var viewing_rarity = Coat.Rarity.Common
var viewing_index := 0
var show_background := false

const f_sorting := "Sorting through: %s coats"
const f_coats := "Coat %d of %d"
const f_mesh := "Coat Type: %s"
var old_coat: Coat
var is_active := false

var coat_type: int
var available_coat_types: Array

onready var ctype_nodes := [
	$window/info/MarginContainer/box/grid/ctype_label1,
	$window/info/MarginContainer/box/grid/ctype_label2,
	$window/info/MarginContainer/box/grid/ctype_prompt1,
	$window/info/MarginContainer/box/grid/ctype_prompt2,
	$window/player_view/coat_type
]

func _init():
	coats_by_rarity = {}
	available_coat_types = []

func _ready():
	set_process_input(false)

func _input(event):
	if !is_visible_in_tree() or !player:
		set_process_input(false)
		return
	if event.is_action_pressed("ui_accept"):
		Global.save_checkpoint(player.get_save_transform())
		exit()
	elif !pause_menu and event.is_action_pressed("ui_cancel"):
		Global.save_checkpoint(player.get_save_transform())
		player.set_current_coat(old_coat)
		exit()
	elif event.is_action_pressed("ui_up"):
		viewing_rarity += 1
		if viewing_rarity > Coat.Rarity.Sublime:
			viewing_rarity = Coat.Rarity.Common
		viewing_index = 0
		view()
	elif event.is_action_pressed("ui_down"):
		viewing_rarity -= 1
		if viewing_rarity < Coat.Rarity.Common:
			viewing_rarity = Coat.Rarity.Sublime
		viewing_index = 0
		view()
	elif event.is_action_pressed("ui_left"):
		if !(viewing_rarity in coats_by_rarity):
			return
		var l = coats_by_rarity[viewing_rarity].size()
		if l != 0:
			viewing_index += l - 1
			viewing_index = viewing_index % l
			view()
	elif event.is_action_pressed("ui_right"):
		if !(viewing_rarity in coats_by_rarity):
			return
		var l = coats_by_rarity[viewing_rarity].size()
		if l != 0:
			viewing_index += 1
			viewing_index = viewing_index % l
			view()
	elif event.is_action_pressed("combat_shoot"):
		set_coat_type(coat_type + 1)
	elif event.is_action_pressed("mv_crouch"):
		set_coat_type(coat_type - 1)

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_active(is_visible_in_tree())

func set_active(active):
	if is_active == active:
		return
	is_active = active
	if active and !player:
		enter(Global.get_player())
	elif !active and player:
		player.cam_rig.pause_mode = PAUSE_MODE_STOP
		player.wardrobe_unlock(pause_menu)
		player = null
	if player:
		player.call_deferred("set_camera_render", true)
	set_process_input(active)
	emit_signal("active", active)

func enter(p: PlayerBody):
	if pause_menu:
		p.cam_rig.pause_mode = PAUSE_MODE_PROCESS
	coats_by_rarity = {}
	player = p
	old_coat = player.current_coat
	for c in Global.game_state.all_coats:
		if !(c.rarity in coats_by_rarity):
			coats_by_rarity[c.rarity] = []
		coats_by_rarity[c.rarity].append(c)
	viewing_rarity = old_coat.rarity
	viewing_index = coats_by_rarity[viewing_rarity].find(old_coat)
	player.wardrobe_lock(pause_menu)
	view()

func exit():
	if player:
		player.cam_rig.pause_mode = PAUSE_MODE_STOP
		player.wardrobe_unlock(pause_menu)
	player = null
	emit_signal("exited")

func view():
	var v = (
		viewing_rarity in coats_by_rarity
		and coats_by_rarity[viewing_rarity].size() > 0)
	$window/player_view/no_coats.visible = !v
	$window/player_view/coat.visible = v
	var rarity_name = Coat.Rarity.keys()[viewing_rarity]
	$window/player_view/sorting.text = f_sorting % rarity_name
	var color:Color = Global.get_rarity_color(viewing_rarity)
	$window/player_view/sorting.modulate = color
	if v:
		$window/player_view/coat.text = f_coats % [
			viewing_index + 1,
			coats_by_rarity[viewing_rarity].size()
		]
		$window/player_view/coat.modulate = color
		var coat:Coat = coats_by_rarity[viewing_rarity][viewing_index]
		player.set_current_coat(coat, true)
	
	available_coat_types = []
	var coat_mesh = player.mesh.coat_mesh
	for t in coat_mesh.meshes:
		if Global.count(t):
			available_coat_types.append(t)

	var vis := available_coat_types.size() > 1
	for n in ctype_nodes:
		n.visible = vis

	var i = 0
	for c in available_coat_types:
		if coat_mesh.mesh == coat_mesh.meshes[c]:
			coat_type = i
			break
		i += 1
	set_coat_type(coat_type)

func set_coat_type(type:int):
	coat_type = type
	var type_count := available_coat_types.size()
	if type_count <= 1:
		return
	# TODO: evaluate negative modulo (should be type_count - n)
	type = type % type_count

	var mesh_name = available_coat_types[type]
	$window/player_view/coat_type.text = f_mesh % mesh_name.capitalize()
	player.mesh.coat_mesh.set_coat_type(mesh_name)
