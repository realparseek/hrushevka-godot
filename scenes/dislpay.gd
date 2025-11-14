extends MeshInstance3D

@export var video_channels: Array[VideoStream] = []
var video_player: VideoStreamPlayer
var player_in_range: bool = false
var is_on: bool = false
var current_channel: int = 0

func _ready():
	setup_video_player()
	setup_interaction_area()

func setup_video_player():
	video_player = VideoStreamPlayer.new()
	add_child(video_player)
	video_player.focus_mode = Control.FOCUS_NONE
	video_player.mouse_filter = Control.MOUSE_FILTER_IGNORE

func setup_interaction_area():
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 3.0
	collision.shape = shape
	area.add_child(collision)
	add_child(area)
	area.connect("body_entered", _on_player_entered)
	area.connect("body_exited", _on_player_exited)

func _on_player_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		print("Игрок в зоне!")

func _on_player_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		print("Игрок вышел из зоны")

func _input(event):
	if event.is_action_pressed("interact") and player_in_range:
		if not is_on:
			turn_on()
		else:
			switch_channel()

func turn_on():
	is_on = true
	update_screen()

func switch_channel():
	if video_channels.size() > 0:
		current_channel = (current_channel + 1) % video_channels.size()
	update_screen()

func update_screen():
	var material = get_surface_override_material(0)
	if material == null:
		material = StandardMaterial3D.new()
		set_surface_override_material(0, material)
	
	if is_on and video_channels.size() > current_channel:
		video_player.stream = video_channels[current_channel]
		var video_texture = video_player.get_video_texture()
		if video_texture:
			material.albedo_texture = video_texture
			material.emission_enabled = true
			material.emission_texture = video_texture
			video_player.play()
	else:
		video_player.stop()
		material.albedo_color = Color.BLACK
		material.emission_enabled = false
