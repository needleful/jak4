tool
extends Spatial

export(Material) var hologram_material
export(Material) var hidden_material

export(bool) var real_visible := false setget set_real_visible

func _ready():
	for m in $Armature/Skeleton.get_children():
		m.material_overlay = hologram_material

func hello():
	$AnimationPlayer.play("IntroWalk")
	$vis_anim.play("Show")
	$Armature/Skeleton.refresh()

func bye():
	$vis_anim.play("Hide")

func set_real_visible(v):
	real_visible = v
	if is_inside_tree():
		var mat = null if v else hidden_material
		for m in $Armature/Skeleton.get_children():
			if m is MeshInstance:
				m.material_override = mat
