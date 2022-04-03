extends KinematicBody

enum Rarity{
	Common,
	Uncommon,
	Rare,
	SuperRare,
	Sublime
}

export(Rarity) var min_rarity := Rarity.Common
export(Rarity) var max_rarity := Rarity.Uncommon
export(bool) var persistent := true
export(bool) var from_kill := false
export(bool) var gravity := false

var coat setget set_coat

func _ready():
	if persistent and Global.is_picked(get_path()):
		queue_free()
		return
	if !coat:
		set_coat(Coat.new(true, min_rarity, max_rarity))

func _physics_process(delta):
	if gravity:
		var _c = move_and_collide(delta*Vector3.DOWN*15)

func set_coat(c):
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
	light_color.a = 0.5
	$OmniLight.light_color = light_color
	$OmniLight2.light_color = light_color
	$spire.material_override.albedo_color = light_color
	coat = c
	$MeshInstance.material_override = coat.generate_material()

func _on_pickup_timer_timeout():
	$area/CollisionShape.disabled = false

func _on_area_body_entered(b):
	Global.add_coat(coat)
	if b is PlayerBody:
		b.set_current_coat(coat, true)
	if persistent:
		Global.mark_picked(get_path())
	if from_kill:
		var _x = Global.add_stat("kill_coat")
	else:
		var _x = Global.add_stat("found_coat")
	queue_free()
