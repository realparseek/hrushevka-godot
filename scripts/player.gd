extends Node3D

var current_tv: Node = null

func _ready():
	add_to_group("player")
	print("Игрок готов")

func set_current_tv(tv_node):
	current_tv = tv_node
	print("Телевизор доступен для взаимодействия")

func clear_current_tv():
	current_tv = null
	print("Телевизор недоступен")

func _input(event):
	if event.is_action_pressed("interact"):
		if current_tv != null:
			print("Игрок взаимодействует с телевизором!")
			current_tv.interact_with_tv()
		else:
			print("Обычное взаимодействие игрока")
