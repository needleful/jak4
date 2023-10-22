extends Object
class_name DifficultySettings

enum DamageFactor {
	NoDamage,
	HalfDamage,
	NormalDamage,
	DoubleDamage,
	OneHitKill
}

enum Aggression {
	LowAggression,
	NormalAggression,
	HighAggression
}

enum DialogHints {
	NoHints,
	OnlyReplies,
	ItemsAndNotes
}

export(DamageFactor) var enemy_damage = DamageFactor.NormalDamage
export(DamageFactor) var player_damage = DamageFactor.NormalDamage
export(Aggression) var aggression = Aggression.NormalAggression
export(DialogHints) var dialog_hints = DialogHints.ItemsAndNotes

func get_name():
	return "Difficulty"

func get_factor(f) -> float:
	match f:
		DamageFactor.NoDamage:
			return 0.0
		DamageFactor.HalfDamage:
			return 0.5
		DamageFactor.DoubleDamage:
			return 2.0
		DamageFactor.OneHitKill:
			return 1000000.0
		_:
			return 1.0
