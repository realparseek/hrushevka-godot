extends Node

@export var animation : AnimationPlayer
@export var outline_mesh : MeshInstance3D

@onready var outline_material : Resource = preload("res://materials/outline/outline.tres")
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
	
func set_hover(state : bool) -> void:
	if state:
		outline_mesh.material_overlay = outline_material
	else:
		outline_mesh.material_overlay = null
