extends Control

export(int) var bronze := 10 setget set_bronze
export(int) var silver := 20 setget set_silver
export(int) var gold := 40 setget set_gold
export(float) var time_remaining := 60.0 setget set_time
export(float) var combo_countdown := 1.0 setget set_combo_countdown
export(int) var combo := 0 setget set_combo

func set_time(t: float):
	time_remaining = t
	$p/m/v/g/TimeRemaining.text = "%.2f" % t

func set_combo(c: int):
	combo = c
	$p/m/v/combo_label.text = "Combo: %d" % combo

func set_combo_countdown(c: float):
	if c < 0:
		c = 0
	if c > 1:
		c = 1
	combo_countdown = c
	$p/m/v/combo_countdown.value = c

func set_best(best: int):
	$p/m/v/g/LabelBest.show()
	$p/m/v/g/Best.show()
	$p/m/v/g/Best.text = str(best)

func new_best(best:int):
	$p/m/v/g/LabelBest.show()
	$p/m/v/g/Best.show()
	$p/m/v/g/Best.text = str(best)
	$best.text = "New Best: %d" % best
	$AnimationPlayer.play("new_best")

func set_gold(g: int):
	$p/m/v/g/Gold.text = str(g)
	gold = g

func set_silver(s: int):
	$p/m/v/g/Silver.text = str(s)
	silver = s
	
func set_bronze(b: int):
	$p/m/v/g/Bronze.text = str(b)
	bronze = b

func color_combo(c: Color):
	$p/m/v/combo_label.modulate = c

func color_bronze(c: Color):
	$p/m/v/g/LabelBronze.modulate = c
	$p/m/v/g/Bronze.modulate = c

func color_silver(c: Color):
	$p/m/v/g/LabelSilver.modulate = c
	$p/m/v/g/Silver.modulate = c

func color_gold(c: Color):
	$p/m/v/g/LabelGold.modulate = c
	$p/m/v/g/Gold.modulate = c
