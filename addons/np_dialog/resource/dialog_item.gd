extends Resource
class_name DialogItem

enum Type {
	MESSAGE,
	REPLY,
	NARRATE
}

export(int) var next: int = -1
export(int) var child : int = -1 
export(int) var parent : int = -1
export(String) var text
export(String) var speaker
export(Array) var conditions
