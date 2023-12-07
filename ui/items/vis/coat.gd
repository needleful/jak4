extends MeshInstance

func _ready():
	if Global.valid_game_state:
		set_surface_material(0, Global.game_state.current_coat.generate_material())
