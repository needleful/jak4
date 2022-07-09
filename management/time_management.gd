extends ColorRect

const slow_time_rate := 0.25
var time_slowed := false

func slow_time(time):
	time_slowed = true
	$Timer.start(time)
	$AnimationPlayer.play("Slow")
	Engine.time_scale = slow_time_rate
	AudioServer.global_rate_scale = 1.0/slow_time_rate

func resume():
	time_slowed = false
	$Timer.stop()
	$AnimationPlayer.play("Resume")
	Engine.time_scale = 1.0
	AudioServer.global_rate_scale = 1.0

func _on_Timer_timeout():
	resume()
