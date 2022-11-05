extends Spatial

signal cleared

var enemies := {}

func _ready():
	for e in get_children():
		if e is EnemyBody and !e.is_dead():
			enemies[e.get_path()] = e
			var _x = e.connect("died", self, "_on_enemy_died", [], CONNECT_ONESHOT)
	if enemies.empty():
		mark_cleared()

func mark_cleared():
	emit_signal("cleared")

func _on_enemy_died(_id, path):
	if path in enemies:
		var _x = enemies.erase(path)
	if enemies.empty():
		mark_cleared()
