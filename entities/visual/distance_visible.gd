extends Spatial

enum Mode {
	NodeAndChildren,
	InstanceLayer
}

export(float, 0, 1000) var distance := 30.0
export(Mode) var mode := Mode.NodeAndChildren
onready var dist_sq = distance*distance
onready var starting_layers = 0 if !("layers" in self) else self.layers

func _ready():
	add_to_group("distance_activated")

func process_player_distance(player_pos):
	if !is_inside_tree():
		return
	var r2 := Global.render_distance*Global.render_distance
	var should_show: bool = (player_pos - global_transform.origin).length_squared() <= dist_sq*r2
	if mode == Mode.NodeAndChildren:
		visible = should_show
	elif mode == Mode.InstanceLayer and "layers" in self:
		self.layers = starting_layers if should_show else 0
