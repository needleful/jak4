extends Spatial


func _ready():
	$AnimationTree.active = false
	$anim.play("Sitting_Floor-loop")
