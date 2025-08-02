extends Button

func _ready() -> void:
	pressed.connect(_button_pressed)

func _button_pressed():
	var roomgen : Node = get_parent().get_child(0)
	roomgen.regenerate()
