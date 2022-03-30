extends KinematicBody

export(Resource) var dialog
export(String) var visual_name
onready var anim := $lil_man/AnimationPlayer

func _ready():
	anim.play("Idle-loop")
	anim.seek(rand_range(0, anim.current_animation_length))
	if !dialog:
		$dialog.queue_free()

func _on_dialog_body_entered(body):
	if body is PlayerBody and body.can_talk():
		body.start_dialog(self, dialog, self)
