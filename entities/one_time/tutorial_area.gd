extends Area

signal tutorial_complete

export(NodePath) var prompts_node
onready var prompts = get_node(prompts_node)

var stage := 0
onready var tyler := get_parent()
var dialog_viewer: Node

func _ready():
	if Global.stat(get_stat_name()):
		tyler.chase = false
		queue_free()

func _on_tutorial_area_body_entered(body):
	if stage == 0:
		if !(body is PlayerBody):
			print_debug("BUG: Non-player triggered dialog node ", get_path())
			return
		if body.can_talk():
			dialog_viewer = body.get_dialog_viewer()
			var s: Node
			body.start_dialog(self, tyler.dialog, tyler)
	else:
		next_stage()

func next_stage():
	if stage == 0:
		for c in prompts.get_children():
			if "enabled" in c:
				c.enabled = true
	var anim := "TutStage" + str(stage)
	stage += 1
	if $AnimationPlayer.has_animation(anim):
		$AnimationPlayer.play(anim)
	else:
		Global.add_stat(get_stat_name())
		dialog_viewer.resume()
		emit_signal("tutorial_complete")
		for c in prompts.get_children():
			if "enabled" in c:
				c.enabled = false
	$CollisionShape.disabled = true

func _on_AnimationPlayer_animation_finished(_anim_name):
	$CollisionShape.disabled = false
	tyler.wave()

func get_stat_name() -> String:
	return str(get_path()) + "/complete"
