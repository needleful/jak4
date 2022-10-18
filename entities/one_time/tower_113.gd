tool
extends Chunk

export(String) var fall_stat = "capacitor_113"
onready var anim := $AnimationPlayer
onready var anim2 := $secondary_animation

var save_path := "res://entities/one_time/tower_113_fall.anim"

func _ready():
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
		ResourceSaver.save(save_path, fall_anim)
		return
	else:
		if !anim.has_animation("tower_113_fall"):
			print_debug("WARNING: animation missing: ", save_path)
	if Global.stat(fall_stat):
		#anim.play("tower_113_fall")
		#anim.seek(anim.current_animation_length)
		anim2.play("fall")
		anim2.seek(anim2.current_animation_length)
	else:
		var _x = Global.connect("stat_changed", self, "_on_stat_changed")

func _on_stat_changed(stat, _val):
	print("Stat: ", stat)
	if stat == fall_stat:
		fall()

func fall():
	print("falling!")
	Global.disconnect("stat_changed", self, "_on_stat_changed")
	#anim.play("tower_113_fall")
	anim2.play("fall")
