extends Object
class_name ChunkLoader

signal first_item_loaded

enum Status {
	Unloaded,
	Loaded,
	Loading
}

var _nodes : Dictionary
var _status : Dictionary

var _lowres : Dictionary
var _hires : Dictionary

const PATH_CONTENT := "res://areas/chunks/%s.tscn"
const PATH_LOWRES := "res://areas/chunks/%s_lowres.tscn"

var exit_thread := false
var _load_mutex := Mutex.new()
var _content_mutex := Mutex.new()
var _load_queue : Array
var _load_thread := Thread.new()

var loaded_first := false

func _init():
	_status = {}
	_lowres = {}
	_hires = {}
	_load_queue = []
	var _x = _load_thread.start(self, "_load_wait")

func start_loading(chunks: Array):
	for c in chunks:
		_nodes[c.name] = c
		_status[c.name] = Status.Unloaded
	_load_lowres(chunks)

func _load_lowres(chunks: Array):
	var first_loaded = false
	for chunk in chunks:
		var name:String = chunk.name
		var hires_file :String = PATH_CONTENT % name
		if ResourceLoader.exists(hires_file):
			_hires[name] = hires_file
		var lowres_file: String = PATH_LOWRES % name
		if ResourceLoader.exists(lowres_file):
			var content = load(lowres_file)
			call_deferred("_add_lowres", name, content)
		if !first_loaded:
			first_loaded = true

func _set_loaded(dict: Dictionary, name: String, content):
	dict[name] = content

func _load_wait():
	while !exit_thread:
		_load_mutex.lock()
		var empty = _load_queue.empty()
		_load_mutex.unlock()

		if empty:
			OS.delay_msec(30)
			continue
		
		_load_mutex.lock()
		var chunk : Spatial = _load_queue.pop_front()
		_load_mutex.unlock()
		
		if is_active(chunk):
			return
		var c = _get_content(_hires, chunk.name)
		call_deferred("_add_content", chunk, c as PackedScene)

func quit():
	exit_thread = true
	if _load_thread.is_active():
		_load_thread.wait_to_finish()

func _add_lowres(chunk: String, content: PackedScene):
	var l = content.instance()
	l.name = "lowres"
	_set_loaded(_lowres, chunk, l)
	if !is_loaded(_nodes[chunk]):
		_nodes[chunk].add_child(l)

func _add_content(chunk: Spatial, content: PackedScene, active: bool = false):
	if chunk.has_node("dynamic_content") or !content:
		return
	else:
		if chunk.has_node("lowres"):
			var l = chunk.get_node("lowres")
			chunk.remove_child(l)
		var n = content.instance()
		n.name = "dynamic_content"
		n.set_active(active)
		chunk.add_child(n)
		_status[chunk.name] = Status.Loaded

func is_alive():
	return _load_thread.is_alive()

func _get_content(dic:Dictionary, chunk: String):
	_content_mutex.lock()
	var res
	res = dic.get(chunk)
	if res is String:
		var data = ResourceLoader.load(res)
		dic[chunk] = data
		_content_mutex.unlock()
		return data
	else:
		_content_mutex.unlock()
		return res

func unload_all():
	for c in _nodes.values():
		unload(c)

func load_active(chunk: Spatial):
	if is_active(chunk):
		return
	var c = _get_content(_hires, chunk.name)
	_add_content(chunk, c as PackedScene)
	activate(chunk)

func queue_load(chunk: Spatial, synchronous: bool):
	if _status[chunk.name] != Status.Unloaded:
		return
	_status[chunk.name] = Status.Loading
	if !(chunk.name in _hires):
		return
	if chunk.has_node("dynamic_content"):
		return
	
	if !synchronous:
		_load_mutex.lock()
		_load_queue.push_back(chunk)
		_load_mutex.unlock()
	else:
		_add_content(chunk, _get_content(_hires, chunk.name))
		_status[chunk.name] = Status.Loaded

func unload(chunk: Spatial):
	if _status[chunk.name] != Status.Loaded:
		return
	_status[chunk.name] = Status.Unloaded
	if chunk.has_node("dynamic_content"):
		chunk.get_node("dynamic_content").queue_free()
	if chunk.name in _hires:
		var r = _hires[chunk.name]
		if r is Resource:
			_hires[chunk.name] = r.resource_path
	if !chunk.has_node("lowres"):
		var c = _get_content(_lowres, chunk.name)
		if c is Node:
			if !c.is_inside_tree():
				c.request_ready()
				chunk.add_child(c)
			else:
				c.name = "lowres"

func activate(chunk: Spatial):
	if chunk.has_node("dynamic_content"):
		chunk.get_node("dynamic_content").set_active(true)

func deactivate(chunk: Spatial):
	if chunk.has_node("dynamic_content"):
		chunk.get_node("dynamic_content").set_active(false)

func is_loaded(chunk: Spatial):
	return chunk and _status[chunk.name] == Status.Loaded

func is_active(chunk: Spatial):
	return (chunk 
		and chunk.has_node("dynamic_content/active_entities"))

func empty_queue():
	return _load_queue.empty()
