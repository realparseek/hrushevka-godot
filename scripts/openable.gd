extends Node

@export var animation : AnimationPlayer
@export var outline_mesh : MeshInstance3D

@onready var outline_material = load("res://materials/outline/outline.tres")

func open() -> void:
	animation.play("Animation", -1, 2)
	
func set_hover(state : bool) -> void:
	if state:
		outline_mesh.material_overlay = outline_material
	else:
		outline_mesh.material_overlay = null

func _process(delta: float) -> void:
	pass
