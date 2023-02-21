extends Spatial

export(bool) var curtains := true

func _ready():
	if !curtains:
		$curtains.queue_free()
