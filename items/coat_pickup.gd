extends Area

export(int) var random_seed = -1
export(bool) var persistent := true

var coat: Coat setget set_coat

func _ready():
	if persistent and Global.is_picked(get_path()):
		queue_free()
		return
	if !coat:
		if random_seed < 0:
			random_seed = randi()
		set_coat(Global.get_coat(random_seed))
	var _x = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(b):
	Global.add_coat(coat)
	if b is PlayerBody:
		b.set_current_coat(coat)
	if persistent:
		Global.mark_picked(get_path())
	queue_free()

func set_coat(c: Coat):
	var light_color : Color
	match c.rarity:
		c.Rarity.Common:
			light_color = Global.color_common
		c.Rarity.Uncommon:
			light_color = Global.color_uncommon
		c.Rarity.Rare:
			light_color = Global.color_rare
		c.Rarity.SuperRare:
			light_color = Global.color_super_rare
		c.Rarity.Sublime:
			light_color = Global.color_sublime
		_:
			light_color = Color.brown
	$OmniLight.light_color = light_color
	$OmniLight2.light_color = light_color
	coat = c
	$MeshInstance.material_override = coat.generate_material()
