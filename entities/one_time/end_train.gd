extends Spatial

func _ready():
	# TODO: condition for showing up
	pass

func end_game():
	$AnimationPlayer.play("end_game")
	Global.get_player().disable()
	get_tree().paused = true

func go_to_credits():
	get_tree().change_scene("res://ui/credits_screen.tscn")
