extends Spatial

const MIN_DIST_LOAD := 325
const MIN_SQDIST_UPDATE := 25

const LOAD_TIME := 5.0
const UNLOAD_TIME := 4.0

const MAX_ACTIVE_CHUNKS := 4

var chunks: Array

var active_chunks: Array
onready var player: PlayerBody = $player

onready var player_last_postion: Vector3 = player.global_transform.origin

export(Material) var debug_active_chunk_material
export(Material) var debug_inactive_chunk_material

func _ready():
	for c in get_children():
		if c.name.begins_with("chunk"):
			chunks.append(c)
	print(chunks.size(), " chunks")
	update_active_chunks(player_last_postion)

func _process(delta):
	var player_new_position = player.global_transform.origin
	if (player_last_postion - player_new_position).length_squared() >= MIN_SQDIST_UPDATE:
		update_active_chunks(player_new_position)
		player_last_postion = player_new_position

func update_active_chunks(position: Vector3):
	for ch in chunks:
		var diff = ch.global_transform.origin - position
		if abs(diff.x) < MIN_DIST_LOAD and abs(diff.z) < MIN_DIST_LOAD:
			mark_active(ch)
		else:
			mark_inactive(ch)

func mark_active(chunk: Spatial):
	if (chunk in active_chunks):
		return
	active_chunks.append(chunk)
	#chunk.material_override = debug_active_chunk_material

func mark_inactive(chunk: Spatial):
	if !(chunk in active_chunks):
		return
	active_chunks.remove(active_chunks.find(chunk))
	#chunk.material_override = debug_inactive_chunk_material
