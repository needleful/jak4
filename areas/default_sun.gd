extends DirectionalLight

var distance := 1.0 setget set_distance
var high_quality := true setget set_quality

var d_split1 := directional_shadow_split_1
var d_split2 := directional_shadow_split_2
var d_distance := directional_shadow_max_distance

const orthogonal_shadow_distance = 30.0

func set_distance(d):
	distance = d
	directional_shadow_max_distance = (d_distance*distance if high_quality else orthogonal_shadow_distance)
	directional_shadow_split_1 = lerp(0.1, d_split1, distance)
	directional_shadow_split_2 = lerp(0.2, d_split2, distance)

func set_quality(q):
	high_quality = q
	if high_quality:
		directional_shadow_mode = DirectionalLight.SHADOW_PARALLEL_4_SPLITS
	else:
		directional_shadow_mode = DirectionalLight.SHADOW_ORTHOGONAL
	
	directional_shadow_max_distance = (d_distance*distance if high_quality else orthogonal_shadow_distance)
