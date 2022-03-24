extends Control

var player: PlayerBody

var keeper: Node
onready var items_window := $Panel/items

const proper_name: Dictionary = {
	"gem": "Moonstones",
	"bug": "Deathgnats"
}

var stock := {}

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		exit()

func _ready():
	set_process_input(false)

func start_shopping(source: Node):
	if !source.has_method("get_inventory"):
		print_debug("Shop owner doesn't have an inventory!")
		exit()
		return
	keeper = source
	stock.clear()
	draw_shop_window()
	$input_timer.start()
	show()

func exit():
	set_process_input(false)
	player.stop_shopping()

func draw_shop_window():
	for c in items_window.get_children():
		c.queue_free()
	var inventory: Dictionary = keeper.get_inventory()
	
	if "persistent" in inventory:
		var p: Array = inventory["persistent"]
		populate_window(p, true)
	if "temporary" in inventory:
		var t: Array = inventory["temporary"]
		populate_window(t, false)

func populate_window(items: Array, persistent: bool):
	var default_currency := "bug" if persistent else "gem"
	for item in items:
		#Terrible lol
		var currency := default_currency
		if item["I"] == "bug":
			currency = "gem"

		var amount = item["C"]
		var label = Label.new()
		var amount_label = Label.new()
		label.text = item["I"].capitalize()
		amount_label.text = str(amount) + " Left"

		var buy_button := Button.new()
		buy_button.text = "Buy for %d %s" % [item["$$"], proper_name[currency]]
		var _x = buy_button.connect(
			"pressed",
			self, "_on_buy_pressed", [item["I"]])
		
		items_window.add_child(label)
		items_window.add_child(amount_label)
		items_window.add_child(buy_button)
				
		stock[item["I"]] = {
			"cost":item["$$"],
			"amount":item["C"],
			"currency":currency,
			"buy_button":buy_button,
			"amount_label":amount_label,
			"persistent":persistent
		}
	update_available()

func update_available():
	for item_id in stock.keys():
		var item: Dictionary = stock[item_id]
		item.amount_label.text = str(item.amount)
		if item.amount <= 0:
			item.buy_button.disabled = true
			item.buy_button.text = "Sold Out!"
		var wallet = Global.count(item.currency)
		if wallet < item.cost:
			item.buy_button.disabled = true

func _on_buy_pressed(item_id: String):
	if !item_id in stock:
		print_debug("BUG: Tried to buy non-existant item ", item_id)
	var item: Dictionary = stock[item_id]
	var cost : int = int(item.cost)
	var currency : String = item.currency
	var amount : int = int(item.amount)
	if amount < 0:
		print_debug("BUG: Tried to buy out-of-stock ", item_id)
	var player_wallet:int = Global.count(currency)
	if player_wallet < cost:
		print_debug("BUG: Tried to buy unaffordable", item_id)
	item.amount -= 1
	var _x = Global.add_item(currency, -cost)
	_x = Global.add_item(item_id)
	keeper.mark_sold(item_id)
	update_available()

func _on_input_timer_timeout():
	if visible:
		if items_window.get_child_count() >= 3:
			items_window.get_child(2).grab_focus()
		set_process_input(true)
