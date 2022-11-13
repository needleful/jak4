tool
extends Chunk

func _ready():
	if Global.stat("capacitor_113"):
		$tower.hide()
		$inner.hide()
		$rubble.show()
	else:
		$tower.show()
		$inner.show()
		$rubble.show()

