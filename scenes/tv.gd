extends MeshInstance3D

@export var channel1_video: VideoStreamTheora
@export var channel2_video: VideoStreamTheora

var current_channel = 1
var video_player: VideoStreamPlayer
var player_in_range = false
var mouse_over_tv = false

func _ready():
	print("=== TV SYSTEM STARTED ===")
	print("Look at TV and press E when CLOSE (2m) to switch channels")
	
	setup_video_player()
	switch_channel(1)
	
	# Автопроверка каждые 0.1 секунды
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func setup_video_player():
	video_player = VideoStreamPlayer.new()
	add_child(video_player)
	video_player.visible = false
	video_player.volume_db = -12.0
	video_player.finished.connect(_on_video_finished)
	print("Video player setup complete")

func _on_timer_timeout():
	check_for_player()
	check_mouse_over_simple()

func check_mouse_over_simple():
	var camera = get_viewport().get_camera_3d()
	if not camera:
		mouse_over_tv = false
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	
	var tv_center = global_position
	var to_tv = tv_center - from
	var distance_along_ray = to_tv.dot(direction)
	var closest_point = from + direction * distance_along_ray
	var distance_to_ray = tv_center.distance_to(closest_point)
	
	var is_looking_at_tv = distance_to_ray < 1.0 and distance_along_ray > 0 and distance_along_ray < 10.0
	
	if is_looking_at_tv != mouse_over_tv:
		mouse_over_tv = is_looking_at_tv
		if mouse_over_tv:
			print("👁️✅ Looking at TV!")
		else:
			print("👁️❌ Not looking at TV")

func check_for_player():
	var player = get_node_or_null("../player")
	
	if not player:
		var all_nodes = get_tree().get_nodes_in_group("")
		for node in all_nodes:
			if node.name == "player" and node is Node3D:
				player = node
				break
	
	if player:
		var distance = global_position.distance_to(player.global_position)
		var was_in_range = player_in_range
		player_in_range = distance <= 2.0  # Увеличил до 2 метров
		
		if player_in_range and not was_in_range:
			print("🎯✅ PLAYER CLOSE! Distance: ", distance, "m - CAN SWITCH!")
		elif not player_in_range and was_in_range:
			print("🎯❌ Player moved away")
		
		# ВСЕГДА показываем дистанцию для отладки
		print("📍 Player distance: ", distance, "m | In range:", player_in_range)
	else:
		print("🔍 Player not found")
		player_in_range = false

func _on_video_finished():
	video_player.play()

func switch_channel(channel):
	current_channel = channel
	print("--- SWITCHING TO CHANNEL ", channel, " ---")
	
	video_player.stop()
	await get_tree().create_timer(0.1).timeout
	
	if channel == 1 and channel1_video:
		video_player.stream = channel1_video
		print("✓ Channel 1 video loaded")
	elif channel == 2 and channel2_video:
		video_player.stream = channel2_video
		print("✓ Channel 2 video loaded")
	else:
		print("✗ ERROR: Video stream not assigned in inspector!")
		return
	
	video_player.play()
	print("✓ Video playback started")
	
	await get_tree().create_timer(0.5).timeout
	update_screen_texture()

func update_screen_texture():
	var texture = video_player.get_video_texture()
	if texture:
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = texture
		mat.emission_enabled = true
		mat.emission_texture = texture
		mat.emission_energy = 1.0
		set_surface_override_material(0, mat)
		print("✓ Screen texture updated - Channel ", current_channel)
	else:
		print("⚠ No video texture, retrying...")
		await get_tree().create_timer(0.5).timeout
		update_screen_texture()

func _input(event):
	if event.is_action_pressed("interact"):
		print(">>> E KEY PRESSED <<<")
		print("Player very close:", player_in_range)
		print("Cursor on TV:", mouse_over_tv)
		print("Current channel:", current_channel)
		
		if player_in_range and mouse_over_tv:
			if current_channel == 1:
				switch_channel(2)
			else:
				switch_channel(1)
			print("✅ CHANNEL SWITCHED!")
		else:
			print("❌ CANNOT SWITCH")
			if not player_in_range:
				print("   ❌ Too far from TV - need to be within 2 meters")
			if not mouse_over_tv:
				print("   ❌ Not looking at TV")
	
	if event.is_action_pressed("ui_1"):
		print("=== FORCE CHANNEL 1 ===")
		switch_channel(1)
	if event.is_action_pressed("ui_2"):
		print("=== FORCE CHANNEL 2 ===")
		switch_channel(2)

func _process(_delta):
	update_sound_volume()

func update_sound_volume():
	var player = get_node_or_null("../player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		
		if distance <= 5.0:
			var volume_factor = 1.0 - (distance / 5.0)
			var target_volume = lerp(-80.0, -12.0, volume_factor)
			video_player.volume_db = target_volume
		else:
			video_player.volume_db = -80.0
