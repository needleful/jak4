tool
extends Chunk

func _ready():
	if Global.stat("capacitor_113"):
		get_tree().call_group("113_delete", "hide")
		get_tree().call_group("113_fallen_only", "show")
	else:
		get_tree().call_group("113_fallen_only", "hide")
		get_tree().call_group("113_delete", "show")
		
