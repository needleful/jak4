extends KinematicBody
class_name FollowerNPC

enum MetaState {
	# Not doing anything
	Idle,
	# Fighting enemies
	Combat,
	# Following the player
	Follow,
	# Travelling somewhere
	TravelTo,
	# Observing an object from a specific position
	ObservePoint,
	# Play a contextual animation
	Act 
}

var velocity := Vector3.ZERO
var meta_state = MetaState.Idle
var target : Spatial
var entry_next: NodePath

onready var dialog:DialogTrigger = $dialog_zone

func _ready():
	set_mstate(MetaState.Idle)

func _physics_process(delta):
	match meta_state:
		MetaState.TravelTo:
			if !target:
				set_mstate(MetaState.Idle)
				return
			var pos = target.global_transform.origin
			var dir = pos - global_transform.origin
			$nav_pointer/final.global_transform = $nav_pointer/final.global_transform.looking_at(pos, Vector3.UP)
			dir.y = 0
			if dir.length() < 0.2:
				get_next_point()
			else:
				var vy = velocity.y
				velocity = dir.normalized()*9
				velocity.y = vy
	velocity = move_and_slide(velocity + Vector3.DOWN*24*delta)

func get_next_point():
	if target and "action" in target and "next" in target:
		if target.action == NavPoint.Action.Jump:
			velocity += target.global_transform.basis.z*5 + Vector3.UP*5
		if target.chunk_entry:
			var t = target.chunk_entry.split(":")
			assert(t.size() == 2)
			var chunk_name = t[0]
			entry_next = t[1]
			var world = get_tree().current_scene
			target = world.get_node(chunk_name)
			
			if world.is_active(chunk_name):
				_on_chunk_activated(target)
			else:
				if !world.is_connected("activated", self, "_on_chunk_activated"):
					world.connect("activated", self, "_on_chunk_activated")
		elif target.has_node(target.next):
			target = target.get_node(target.next)
		else:
			target = null
			entry_next = ""

func _on_chunk_activated(chunk):
	if chunk == target:
		var world = get_tree().current_scene
		var d = world.get_dynamic_content(chunk.name)
		var gt = global_transform
		get_parent().remove_child(self)
		d.add_child(self)
		global_transform = gt
		assert(d.has_node(entry_next))
		target = d.get_node(entry_next)
		entry_next = ""
		
		if world.is_connected("activated", self, "_on_chunk_activated"):
			world.disconnect("activated", self, "_on_chunk_activated")
	
func travel_to(place:String, custom_exit := ""):
	if has_node(custom_exit):
		target = get_node(custom_exit)
	dialog.enabled = false
	print("travelling to ", place)
	set_mstate(MetaState.TravelTo)

func set_mstate(new_mstate):
	meta_state = new_mstate
	set_physics_process(meta_state != MetaState.Idle)
