extends KinematicBody

export(NodePath) var source_path
onready var main_body = get_node(source_path)

func take_damage(damage, dir, source: Node):
	main_body.take_damage(damage, dir, main_body)
	if "last_attacker" in main_body:
		main_body.last_attacker = source
