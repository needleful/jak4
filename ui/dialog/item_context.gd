extends Panel

signal item_picked(id, description)
signal cancelled

onready var coat := $VBoxContainer/coat
onready var bar_buttons := $VBoxContainer/bar_buttons

var buttons: Array

func _init():
	buttons = []

func _input(event):
	if event.is_action_pressed("dialog_item") or event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		update_inventory()
		coat.grab_focus()
		set_process_input(is_visible_in_tree())

func update_inventory():
	for c in buttons:
		c.queue_free()
	buttons.clear()
	
	var inventory := Global.get_fancy_inventory()
	var button_box = $VBoxContainer
	for item in inventory:
		var button: Button = Button.new()
		buttons.append(button)
		button_box.add_child_below_node(bar_buttons, button)
		
		button.text = inventory[item].full_name
		var _x = button.connect("pressed", self, "use_item", [
			item, inventory[item]
		])
	bar_buttons.visible = buttons.size() > 0

func use_item(id: String, description: ItemDescription = null):
	hide()
	emit_signal("item_picked", id, description)

func _on_coat_pressed():
	use_item("coat")

func _on_cancel_pressed():
	hide()
	emit_signal("cancelled")
