extends Object
class_name DifficultySettings

enum DamageFactor {
	HalfDamage,
	NormalDamage,
	DoubleDamage
}

enum Aggression {
	LowAggression,
	NormalAggression,
	HighAggression
}

export(DamageFactor) var enemy_damage = DamageFactor.NormalDamage
export(DamageFactor) var player_damage = DamageFactor.NormalDamage
export(Aggression) var aggression = Aggression.NormalAggression


func get_name():
	return "Difficulty"
