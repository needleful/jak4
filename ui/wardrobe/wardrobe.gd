extends Control

signal exited

var player: PlayerBody

var coats_by_rarity := {}
var viewing_rarity = Coat.Rarity.Common
var viewing_index := 0

const f_sorting := "Sorting through: %s coats"
const f_coats := "Coat %d of %d"
var old_coat: Coat

func _input(event):
	if event.is_action_pressed("ui_accept"):
		Global.save_checkpoint(player.global_transform.origin)
		exit()
	elif event.is_action_pressed("ui_cancel"):
		Global.save_checkpoint(player.global_transform.origin)
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

func set_active(active):
	if active and !player:
		enter(Global.get_player())
	elif !active and player:
		player.wardrobe_unlock()
		player = null
	set_process_input(active)

func enter(p: PlayerBody):
	coats_by_rarity = {}
	player = p
	old_coat = player.current_coat
	for c in Global.game_state.all_coats:
		if !(c.rarity in coats_by_rarity):
			coats_by_rarity[c.rarity] = []
		coats_by_rarity[c.rarity].append(c)
	viewing_rarity = old_coat.rarity
	viewing_index = coats_by_rarity[viewing_rarity].find(old_coat)
	player.wardrobe_lock()
	view()

func exit():
	if player:
		player.wardrobe_unlock()
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
