extends PanelContainer

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		var days = Global.stat("current_day") + 1
		$margin/stats/date.text = "%s %s of travel" % [
			NumberToString.verbose(days).capitalize(),
			"day" if days == 1 else "days" ] 
		if get_tree().current_scene.has_method("get_time"):
			var time = get_tree().current_scene.get_time()
			var t := NumberToString.say_time(time, true, true)
			var t2 := t.split(' ')
			t2[0] = t2[0].capitalize()
			t = t2.join(' ')
			$margin/stats/time.text = "%s" % t
