extends Area

const booster_color := Color.darkorange
const checkpoint_color := Color.aqua

export(bool) var checkpoint
export(int, 0, 10) var extra_stamina

var active:bool = false setget set_active

func _ready():
	if has_node("MeshInstance"):
		if extra_stamina:
			var m:ShaderMaterial = $MeshInstance.get_surface_material(0).duplicate()
			m.set_shader_param("color", booster_color)
			$MeshInstance.set_surface_material(0, m)
		elif checkpoint:
			var m:ShaderMaterial = $MeshInstance.get_surface_material(0).duplicate()
			m.set_shader_param("color", checkpoint_color)
			$MeshInstance.set_surface_material(0, m)

func set_active(a):
	active = a
	var area_connected := is_connected("body_entered", self, "_on_body_entered")
	if active:
		if CustomGames.is_active():
			Global.get_player().game_ui.add_target(self)
		if !area_connected:
			var _x = connect("body_entered", self, "_on_body_entered")
	else:
		if CustomGames.is_active():
			Global.get_player().game_ui.remove_target(self)
		if area_connected:
			disconnect("body_entered", self, "_on_body_entered")
	visible = active

func _on_body_entered(b):
	if b is PlayerBody:
		boost_stamina()
		if checkpoint:
			Global.save_checkpoint(b.get_save_transform())
		get_parent().activate_next()

func _on_player_respawn():
	boost_stamina()

func connect_spawn(p: PlayerBody):
	if !p.is_connected("died", self, "_on_player_respawn"):
		var _x = p.connect("died", self, "_on_player_respawn")

func disconnect_spawn(p: PlayerBody):
	if p.is_connected("died", self, "_on_player_respawn"):
		p.disconnect("died", self, "_on_player_respawn")

func boost_stamina():
	if Global.count("stamina_booster") < extra_stamina:
		var _x = Global.set_item_count("stamina_booster", extra_stamina)
