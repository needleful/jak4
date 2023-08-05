extends Node

signal enemies_dead
signal spawned_without_enemies

export(bool) var persistent := true
export(String) var stat_name := ""
export(String) var task_id := ""
export(String, MULTILINE) var task_note := ""

var enemies : Array

func _ready():
	if persistent and Global.stat(stat_name):
		emit_signal("spawned_without_enemies")
		queue_free()
		return
	for c in get_children():
		if c is EnemyBody:
			if !c.is_dead():
				enemies.append(c)
				var _x = c.connect("died", self, "_on_died", [], CONNECT_ONESHOT)

func _on_died(_id, path):
	var e = get_node(path)
	var i = enemies.find(e)
	if i >= 0:
		enemies.remove(i)
	if enemies.empty():
		if persistent:
			if stat_name != "":
				var _x = Global.add_stat(stat_name)
			if task_id != "":
				var _x = Global.add_note(task_note, [task_id])
		emit_signal("enemies_dead")
