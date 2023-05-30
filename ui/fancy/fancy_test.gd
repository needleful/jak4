tool
extends Control

export(bool) onready var active:bool setget set_active

onready var mat:ShaderMaterial = $TextureRect.material

func set_active(a):
	active = a
	var t := get_tree().create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(mat, "shader_param/value", 1.2*float(active), 1.0)
