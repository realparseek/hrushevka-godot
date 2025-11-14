extends Interaction

@export var animation : AnimationPlayer

@onready var is_opened : bool = false

func open() -> void:
	if is_opened or animation.is_playing():
		return
	animation.play("Action", -1, 2)
	is_opened = true
	
func close() -> void:
	if not is_opened or animation.is_playing():
		return
	animation.play_backwards("Action", -1)
	is_opened = false

func interacte() -> void:
	if is_opened:
		close()
	else:
		open()
