extends Resource

export(Dictionary) var dialog
export(Dictionary) var labels

func _init():
	resource_name = "NPSequence"

func get(index) -> DialogItem:
	if index is String:
		index = labels[index]
	return dialog[index]

func next(item) -> DialogItem:
	if !(item is DialogItem):
		item = get(item)
	return item.next in dialog

func child(item) -> DialogItem:
	if !(item is DialogItem):
		item = get(item)
	return item.child in dialog
	
func parent(item) -> DialogItem:
	if !(item is DialogItem):
		item = get(item)
	return item.parent in dialog
