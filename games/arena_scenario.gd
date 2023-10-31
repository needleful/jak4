extends Spatial
class_name ArenaScenario

export(int) var bronze_score := 1000
export(int) var silver_score := 2000
export(int) var gold_score := 3000
export(float) var time_limit := 60.0
export(int) var min_enemies := 2
export(bool) var aggro_automatically := true
export(Resource) var scenario 

func get_wave(wave: int):
	if wave < scenario.waves.size():
		return scenario.waves[wave]
	else:
		return scenario.waves[scenario.waves.size() - 1]
