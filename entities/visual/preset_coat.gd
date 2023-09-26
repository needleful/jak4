tool
extends Node

export(Resource) var coat setget set_coat

var coatlike: CoatLike

func _ready():
	if coat and _find_coatlike(self):
		if Engine.editor_hint or !coatlike.was_traded():
			print("Set coat at ready")
			coatlike.set_coat(coat)

func _find_coatlike(node: Node) -> bool:
	for c in node.get_children():
		if c is CoatLike:
			coatlike = c
			return true
		if _find_coatlike(c):
			return true
	return false

func set_coat(c: Coat):
	coat = c
	if coatlike or _find_coatlike(self):
		if Engine.editor_hint or (
			coatlike.is_inside_tree() and !coatlike.was_traded()
		):
			coatlike.set_coat(coat)
