extends Resource
class_name AudioChannel

export(float) var vol: float
export(bool) var muted: bool
export(String) var bus_name: String

func _init(name: String = ""):
	resource_name = "AudioChannel"
	bus_name = name
	var bi = AudioServer.get_bus_index(bus_name)
	if bi >= 0:
		muted = AudioServer.is_bus_mute(bi)
		vol = db_to_percent(AudioServer.get_bus_volume_db(bi))

func apply(c):
	vol = c.vol
	muted = c.muted
	var bi = AudioServer.get_bus_index(bus_name)
	if bi >= 0:
		AudioServer.set_bus_mute(bi, muted)
		AudioServer.set_bus_volume_db(bi, percent_to_db(vol))

func percent_to_db(percent):
	return 50*log(0.99*percent + 0.01)/log(10)

func db_to_percent(db):
	return (pow(10, db/50) - 0.01) /0.99
