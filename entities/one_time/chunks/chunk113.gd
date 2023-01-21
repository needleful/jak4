tool
extends Chunk

export(String) var fall_stat = "capacitor_113"
onready var anim := $AnimationPlayer
onready var anim2 := $secondary_animation

var save_path := "res://entities/one_time/chunks/tower_113_fall.anim"

func _enter_tree():
	if !Engine.editor_hint:
		hide()

func _ready():
	call_deferred("show")
	print("113 ready")
	if Engine.editor_hint:
		# Generate the animation data
		var fall_anim := Animation.new()
		for a in anim.get_animation_list():
			if a == "tower_113_fall":
				continue
			var part_anim:Animation = anim.get_animation(a)
			for t1 in range(part_anim.get_track_count()):
				part_anim.copy_track(t1, fall_anim)
				fall_anim.length = max(fall_anim.length, part_anim.length)
		print("Fall anim has %d tracks" % fall_anim.get_track_count())
		var _x = ResourceSaver.save(save_path, fall_anim)
		return
	else:
		if !anim.has_animation("tower_113_fall"):
			print_debug("WARNING: animation missing: ", save_path)
	if Global.stat(fall_stat):
		fall(true)
	else:
		var _x = Global.connect("stat_changed", self, "_on_stat_changed")
		anim2.play("fall")
		anim2.advance(0)
		anim2.stop()

func _on_stat_changed(stat, _val):
	if stat == fall_stat:
		fall()

func fall(instant := false):
	print("falling!")
	anim2.play("fall")
	if instant:
		get_tree().call_group("113_tower_only", "queue_free")
		anim2.seek(anim2.current_animation_length)
		anim2.advance(0)
		anim2.stop()
	else:
		Global.disconnect("stat_changed", self, "_on_stat_changed")
	get_tree().call_group("113_delete", "queue_free")
	
	var env = $environment
	if env.get_overlapping_bodies().size() > 0:
		env._on_body_exited(null)
	env.queue_free()
	
	if !instant:
		var flags:Area = $flag_check
		for flag in flags.get_overlapping_bodies():
			flag.queue_free()
		var dss_rid := get_world().space
		var dss := PhysicsServer.space_get_direct_state(dss_rid)
		var intersect := dss.intersect_point(
			Global.game_state.checkpoint_position,
			4, [], 0x7FFFFFFF, false, true)
		for shape in intersect:
			print("intersect: ", shape.collider.name)
			if shape.collider == flags:
				Global.game_state.checkpoint_position = $player_new_checkpoint.global_transform.origin
