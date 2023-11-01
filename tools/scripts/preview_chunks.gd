tool
extends EditorScript

const path_f := "res://areas/chunks/%s.tscn"

var load_chunks := false
var take_photo := true

func _run():
	var scn = get_scene()
	if load_chunks:
		print_debug("Previewing chunks...")
		for c in scn.get_children():
			var chunk = path_f % c.name
			if ResourceLoader.exists(chunk):
				var sc: Chunk = load(chunk).instance()
				sc.preview_neighbors = false
				sc.set_active(false)
				c.add_child(sc)
				if sc.has_node("__autogen_preview"):
					sc.get_node("__autogen_preview").queue_free()
		
	if take_photo:
		var mv: Viewport
		scn.get_node("day_night").play("map_screenshot")
		mv = scn.get_node("map_viewport")
		if !(mv is Viewport):
			print_debug("No viewport to save map into")
			return
		else:
			mv.size = Vector2(4096, 4096)
			take_screenshot(mv)

func take_screenshot(mv: Viewport):
	yield(get_scene().get_tree().create_timer(0.1), "timeout")
	print_debug("taking screenshot for the map...")
	var image := mv.get_texture().get_data()
	var res = image.save_png("res://ui/map/map.png")
	if res != OK:
		print_debug("Could not take screenshot: ", res)
	else:
		print_debug("screenshot_saved")
	
