extends Area

signal tutorial_complete

var stage := 0
onready var tyler := get_parent()

func _ready():
	if Global.stat(get_stat_name()):
		tyler.chase = false
		queue_free()

func _on_tutorial_area_body_entered(_body):
	var anim := "TutStage" + str(stage)
	stage += 1
	if $AnimationPlayer.has_animation(anim):
		$AnimationPlayer.play(anim)
	else:
		Global.add_stat(get_stat_name())
		emit_signal("tutorial_complete")
	$CollisionShape.disabled = true

func _on_AnimationPlayer_animation_finished(_anim_name):
	$CollisionShape.disabled = false
	tyler.wave()

func get_stat_name() -> String:
	return str(get_path()) + "/complete"
