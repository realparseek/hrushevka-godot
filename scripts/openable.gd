extends Node

@onready var animation : AnimationPlayer = $"../AnimationPlayer"

#func _ready() -> void:
	#animation.play()

func open() -> void:
	animation.play("Animation", -1, 2)
	

func _process(delta: float) -> void:
	pass
