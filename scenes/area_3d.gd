extends Area3D

@export var target_radio: SteamAudioPlayer

func _on_body_entered(body: Node3D):
	if body is CharacterBody3D:
		if target_radio and target_radio.has_method("start_radio"):
			target_radio.start_radio()

func _on_body_exited(body: Node3D):
	if body is CharacterBody3D:
		if target_radio and target_radio.has_method("stop_radio"):
			target_radio.stop_radio()
