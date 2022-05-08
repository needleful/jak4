extends MeshInstance

export(String) var fall_stat = "capacitor_113"
export(bool) var high_res = false
onready var anim := $"../anim_lowres"

var flag_deletion: Area
var flag_spawn: Spatial

func _ready():
	if Global.stat(fall_stat):
		anim.play("fall")
		anim.seek(anim.current_animation_length)
		# Disable particles
		for c in $tower_mid.get_children():
			if c is Particles:
				c.emitting = false
				c.queue_free()
		for c in $tower_top.get_children():
			if c is Particles:
				c.emitting = false
				c.queue_free()
	elif high_res:
		flag_deletion = $"../flag_deletion"
		flag_spawn = $"../flag_spawn"
		var res = Global.connect("stat_changed", self, "_on_stat_changed")
		assert(res == OK)

func _on_stat_changed(stat, _val):
	print(stat, " == ", fall_stat)
	if stat == fall_stat:
		fall()

func fall():
	if high_res:
		Global.disconnect("stat_changed", self, "_on_stat_changed")
		print("Falling")
		anim.play("fall")
		for g in flag_deletion.get_overlapping_bodies():
			var l = (g.global_transform.origin - Global.game_state.checkpoint_position).length()
			if l < 3:
				Global.game_state.checkpoint_position = flag_spawn.global_transform.origin
			Global.remove_flag(g.global_transform)
			g.queue_free()
	else:
		print_debug("ERROR: did not expect fall() called in lowres scene!")
