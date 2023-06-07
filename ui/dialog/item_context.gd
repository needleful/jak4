extends Panel

signal item_picked(id, description)
signal context_reply(item)
signal cancelled

onready var coat := $VBoxContainer/coat
onready var bar_inventory := $VBoxContainer/bar_inventory
onready var bar_context := $VBoxContainer/bar_context
onready var button_box := $VBoxContainer
onready var viewer := $"../viewer"

var item_buttons: Array
var reply_buttons: Array

func _init():
	item_buttons = []
	reply_buttons = []

func _input(event):
	if event.is_action_pressed("dialog_item") or event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		list_contextual_replies()
		update_inventory()
		coat.grab_focus()
		set_process_input(is_visible_in_tree())

func list_contextual_replies():
	wipe(reply_buttons)
	for list in viewer.contextual_replies.values():
		for c in list:
			var button:Button = viewer.multiline_button(c.text)
			reply_buttons.append(button)
			button_box.add_child_below_node(bar_context, button)
			var _x = button.connect("pressed", self, "context_reply", [c])
	bar_context.visible = reply_buttons.size() > 0

func update_inventory():
	wipe(item_buttons)
	var inventory := Global.get_fancy_inventory()
	for item in inventory:
		var button := Button.new()
		item_buttons.append(button)
		button_box.add_child_below_node(bar_inventory, button)
		
		button.text = inventory[item].full_name
		var _x = button.connect("pressed", self, "use_item", [
			item, inventory[item]
		])
	bar_inventory.visible = item_buttons.size() > 0

func context_reply(item: DialogItem):
	hide()
	emit_signal("context_reply", item)

func use_item(id: String, description: ItemDescription = null):
	hide()
	emit_signal("item_picked", id, description)

func wipe(nodes: Array):
	for c in nodes:
		c.queue_free()
	nodes.clear()

func _on_coat_pressed():
	use_item("coat")

func _on_cancel_pressed():
	hide()
	emit_signal("cancelled")
