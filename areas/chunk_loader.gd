extends Object
class_name ChunkLoader

var _thread := Thread.new()
var _lowres_thread := Thread.new()
var _queue := []
var _active_mutex := Mutex.new()
var _queue_mutex := Mutex.new()
var _active := {}
var _nodes := {}
var _lowres := {}
var _should_run := true
var _loaded_content := {}
var _track_loaded_content := true

const PATH_CONTENT := "res://areas/chunks/%s.tscn"
const PATH_LOWRES := "res://areas/chunks/%s_lowres.tscn"

func _init(nodes: Dictionary, track_loaded_content := true):
	_track_loaded_content = track_loaded_content
	_nodes = nodes
	var lowres_nodes := []
	for c in _nodes.values():
		_active[c.name] = false
		if Global.show_lowres:
			var lowres_file: String = PATH_LOWRES % c.name
			if ResourceLoader.exists(lowres_file):
				lowres_nodes.append(c.name)
	if !lowres_nodes.empty():
		var _x = _lowres_thread.start(self, "_load_lowres", lowres_nodes)
	var _x = _thread.start(self, "_load_loop")

func quit():
	_should_run = false
	_thread.wait_to_finish()

func _load_loop():
	_lowres_thread.wait_to_finish()
	while _should_run:
		var size := queue_size()
		var n = pop_queue()
		while n:
			_load(n)
			size += 1
			n = pop_queue()
		if size > 0:
			print("Loaded %d nodes" % size)
		OS.delay_msec(50)
	print("Thread exiting...")

func _load(name):
	set_active(name, true)
	if _track_loaded_content and name in _loaded_content:
		call_deferred("_add_content", _nodes[name], _loaded_content[name])
		return
	var filepath = PATH_CONTENT % name
	if ResourceLoader.exists(filepath):
		var scn: PackedScene = load(filepath)
		if scn:
			if _track_loaded_content:
				_loaded_content[name] = scn
			call_deferred("_add_content", _nodes[name], scn)

func _load_lowres(names: Array):
	for name in names:
		var lowres_file: String = PATH_LOWRES % name
		var scn: PackedScene = load(lowres_file)
		if scn:
			var node = scn.instance()
			node.name = "lowres"
			_lowres[name] = node
			call_deferred("_add_lowres", _nodes[name], node)

func _add_lowres(chunk: Node, child: Node):
	if !is_active(chunk.name):
		chunk.add_child(child)

func _add_content(chunk: Node, content: PackedScene):
	if chunk.has_node("dynamic_content"):
		print_debug("Error: already loaded ", chunk.name)
	else:
		print("Loaded ", chunk.name)
		if chunk.name in _lowres:
			chunk.remove_child(_lowres[chunk.name])
		var n = content.instance()
		n.name = "dynamic_content"
		chunk.add_child(n)

func _delete(d: Node):
	d.queue_free()

func is_alive():
	return _thread.is_alive()

func queue_unload(chunk: String):
	print("Should unload ", chunk)
	unqueue(chunk)
	if !is_active(chunk):
		return
	set_active(chunk, false)
	if _nodes[chunk].has_node("dynamic_content"):
		var d:Node = _nodes[chunk].get_node("dynamic_content")
		#_nodes[chunk].remove_child(d)
		call_deferred("_delete", d)
	if chunk in _lowres and !_lowres[chunk].get_parent():
		_nodes[chunk].add_child(_lowres[chunk])
	print("Unloaded ", chunk)

func queue_load(chunk: String):
	if is_active(chunk) or is_queued(chunk):
		return
	print(chunk, " queued: ", queue_size())
	_queue_mutex.lock()
	_queue.append(chunk)
	_queue_mutex.unlock()

func unqueue(chunk: String):
	_queue_mutex.lock()
	var i = _queue.find(chunk)
	if i != -1:
		_queue.remove(i)
	_queue_mutex.unlock()

func is_queued(chunk) -> bool:
	var res: bool
	_queue_mutex.lock()
	chunk in _queue
	_queue_mutex.unlock()
	return res

func queue_empty() -> bool:
	var res : bool
	_queue_mutex.lock()
	res = _queue.empty()
	_queue_mutex.unlock()
	return res

func queue_size() -> int:
	var res: int
	_queue_mutex.lock()
	res = _queue.size()
	_queue_mutex.unlock()
	return res

func pop_queue():
	var res
	_queue_mutex.lock()
	if _queue.empty():
		res = null
	else:
		res = _queue.pop_front()
	_queue_mutex.unlock()
	return res

func is_active(name: String) -> bool:
	var res: bool
	_active_mutex.lock()
	res = _active[name]
	_active_mutex.unlock()
	return res

func set_active(name: String, value: bool):
	_active_mutex.lock()
	_active[name] = value
	_active_mutex.unlock()
