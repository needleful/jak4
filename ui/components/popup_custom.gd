extends PanelContainer
signal cancelled
signal confirmed

export(String) var header
export(String, MULTILINE) var body
export(String) var confirm_text

func _ready():
	$content/header.text = header
	$content/body.text = body
	$content/buttons/confirm.text = confirm_text


func _on_cancel_pressed():
	emit_signal("cancelled")
	hide()

func _on_confirm_pressed():
	emit_signal("confirmed")
	hide()

func grab_button_focus():
	$content/buttons/cancel.grab_focus()
