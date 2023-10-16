tool
extends EditorScript

var multiMesh := "active_entities/hut_area/corn2"

var step_size := 0.2
var buffer := 1.0
var offset_h := 1.2
var scale_min := 0.4
var scale_max := 1.0

func _run():
	var mm:MultiMeshInstance = get_scene().get_node(multiMesh)
	if !mm:
		print_debug("Not a valid multimesh: ", multiMesh)
		return
	var instances := PoolVector3Array()
	var inv: Transform = mm.global_transform.affine_inverse()
	for c in mm.get_children():
		if c is Path:
			var loc := buffer
			var length :float = c.curve.get_baked_length()
			while loc + buffer < length:
				loc += step_size
				var pos:Vector3 = c.curve.interpolate_baked(loc)
				var global_pos:Vector3 = c.global_transform*pos
				var mm_pos:Vector3 = inv*global_pos + offset_h*(
					Vector3(0.5, 0.0, 0.5) - Vector3(randf(), 0, randf()))
				instances.push_back(mm_pos)
	mm.multimesh.instance_count = instances.size()
	for i in instances.size():
		var t := Transform().rotated(Vector3.UP, randf()*PI*2)
		var scale := rand_range(scale_min, scale_max)
		t = t.scaled(Vector3(scale, scale, scale))
		t.origin = instances[i]
		mm.multimesh.set_instance_transform(i, t)
