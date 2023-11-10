extends Resource
class_name GameVersion

export(int) var major := 0
export(int) var minor := 0
export(int) var patch := 0

func _init(p_major:=0, p_minor:=0, p_patch:=0):
	major = p_major
	minor = p_minor
	patch = p_patch

func compatible(rhs:GameVersion) -> bool:
	if major != rhs.major:
		return false
	if major == 0 and minor != rhs.minor:
		return false
	return true

func bounds_compatible(rhs: GameVersion) -> bool:
	if major != rhs.major or minor != rhs.minor:
		return false
	elif major == 0:
		return patch == rhs.patch
	return true

func _to_string():
	return "v%d.%d.%d" % [major, minor, patch]
