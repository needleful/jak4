extends Control

var player: PlayerBody

var coats_by_rarity := {}
var viewing_rarity = Coat.Rarity.Common
var viewing_index := 0

const f_sorting := "Sorting through: %s coats"
const f_coats := "Coat %d of %d"

func _input(event):
	if event.is_action_pressed("ui_cancel"):
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
		var l = coats_by_rarity[viewing_rarity].size()
		if l != 0:
			viewing_index += l - 1
			viewing_index = viewing_index % l
			view()
	elif event.is_action_pressed("ui_right"):
		var l = coats_by_rarity[viewing_rarity].size()
		if l != 0:
			viewing_index += 1
			viewing_index = viewing_index % l
			view()
func _ready():
	exit()

func enter(p: PlayerBody):
	player = p
	for c in Global.game_state.all_coats:
		if !(c.rarity in coats_by_rarity):
			coats_by_rarity[c.rarity] = []
		coats_by_rarity[c.rarity].append(c)
	show()
	set_process_input(true)
	Global.can_pause = false
	player.wardrobe_lock()
	view()

func exit():
	Global.can_pause = true
	if player:
		player.wardrobe_unlock()
	hide()
	player = null

func view():
	var v = (
		viewing_rarity in coats_by_rarity
		and coats_by_rarity[viewing_rarity].size() > 0)
	$window/player_view/no_coats.visible = !v
	$window/player_view/coat.visible = v
	var rarity_name = Coat.Rarity.keys()[viewing_rarity]
	$window/player_view/sorting.text = f_sorting % rarity_name
	var color := Global.get_rarity_color(viewing_rarity)
	$window/player_view/sorting.modulate = color
	if v:
		$window/player_view/coat.text = f_coats % [
			viewing_index + 1,
			coats_by_rarity[viewing_rarity].size()
		]
		$window/player_view/coat.modulate = color
		var coat:Coat = coats_by_rarity[viewing_rarity][viewing_index]
		player.set_current_coat(coat)
