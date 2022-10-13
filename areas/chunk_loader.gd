extends Object
class_name ChunkLoader

signal load_complete
signal load_start

var _thread := Thread.new()
var _active_mutex := Mutex.new()
var _load_mutex := Mutex.new()
var _nodes := {}
var _active := {}
var _lowres := {}
var _loaded_content := {}
var _deletion_queue := []

const PATH_CONTENT := "res://areas/chunks/%s.tscn"
const PATH_LOWRES := "res://areas/chunks/%s_lowres.tscn"

func update():
	if !_deletion_queue.empty():
		_deletion_queue.pop_front().queue_free()

func start_loading(chunks: Array):
	var _x = _thread.start(self, "_load_everything", chunks)

func _load_everything(chunks: Array):
	call_deferred("emit_signal", "load_start")
	for chunk in chunks:
		var name:String = chunk.name
		print("checking ", name)
		_nodes[name] = chunk

		var hires_file :String = PATH_CONTENT % name
		if ResourceLoader.exists(hires_file):
			print(hires_file)
			var content = load(hires_file)
			_set_loaded(_loaded_content, name, content)
			if is_active(name):
				call_deferred("_add_content", name, content)

		var lowres_file: String = PATH_LOWRES % name
		if ResourceLoader.exists(lowres_file):
			print(lowres_file)
			var content = load(lowres_file)
			var l = content.instance()
			l.name = "lowres"
			_set_loaded(_lowres, name, l)
			if !is_active(name):
				call_deferred("_add_lowres", name, content)
	call_deferred("emit_signal", "load_complete")

func _set_loaded(dict: Dictionary, name: String, content: PackedScene):
	_load_mutex.lock()
	dict[name] = content
	_load_mutex.unlock()

func quit():
	if _thread.is_alive():
		_thread.wait_to_finish()

func _add_lowres(chunk: String, scn: PackedScene):
	var node = scn.instance()
	node.name = "lowres"
	_lowres[chunk] = node
	if !is_active(chunk):
		_nodes[chunk].add_child(node)

func _add_content(chunk: String, content: PackedScene):
	var c:Node = _nodes[chunk]
	print("Adding content to ", chunk)
	if c.has_node("dynamic_content"):
		return
	else:
		if chunk in _lowres:
			_nodes[chunk].remove_child(_lowres[chunk])
		var n = content.instance()
		n.name = "dynamic_content"
		c.add_child(n)

func is_alive():
	return _thread.is_alive()

func _get_content(dic:Dictionary, chunk: String):
	var res
	_load_mutex.lock()
	res = dic.get(chunk)
	_load_mutex.unlock()
	return res

func queue_load(chunk: Spatial):
	set_active(chunk.name, true)
	print(chunk.name, " is active")
	if chunk.has_node("dynamic_content"):
		return

	if chunk.has_node("lowres"):
		chunk.remove_child(chunk.get_node("lowres"))
	var c = _get_content(_loaded_content, chunk.name)

	if c is PackedScene:
		var n:Node = c.instance()
		n.name = "dynamic_content"
		chunk.add_child(n)
	
func queue_unload(chunk: Spatial):
	set_active(chunk.name, false)
	if chunk.has_node("dynamic_content"):
		var d = chunk.get_node("dynamic_content")
		chunk.remove_child(d)
		_deletion_queue.push_back(d)
	var c = _get_content(_loaded_content, chunk.name)
	if c is Node:
		chunk.add_child(c)

func is_active(name: String) -> bool:
	var res: bool
	_active_mutex.lock()
	res = name in _active and _active[name]
	_active_mutex.unlock()
	return res

func set_active(name: String, value: bool):
	_active_mutex.lock()
	_active[name] = value
	_active_mutex.unlock()
