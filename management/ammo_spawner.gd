extends Node

# Ammo drop logic
const ammo_path_f := "res://items/ammo/%s_pickup.tscn"
const WEIGHTS := {
	"pistol": 1.12,
	"wave_shot": 1.07,
	"grav_gun": 1.0
}

var MAX := {
	"pistol": 100.0,
	"wave_shot":70.0,
	"grav_gun": 25.0
}

const COUNTS := {
	"pistol": 10,
	"wave_shot":7,
	"grav_gun": 2
}

func get_random_ammo():
	var best_wep := ""
	var best_desire := -INF
	for a in WEIGHTS.keys():
		if Global.count("wep_"+a):
			var n:float = (MAX[a] - Global.count(a))/MAX[a]
			var desire = WEIGHTS[a]*(n + randf()*0.5)
			if desire >= best_desire:
				best_wep = a
				best_desire = desire
	if best_wep != "":
		var tscn = load(ammo_path_f % best_wep) as PackedScene
		var ammo = tscn.instance() as ItemPickup
		ammo.quantity = COUNTS[best_wep]
		return ammo
	else:
		return null
