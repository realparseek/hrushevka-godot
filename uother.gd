extends AudioStreamPlayer3D

var water_drop_sounds: Array = [
	"res://sounds/surround/rnd_drop_3.ogg",
	"res://sounds/surround/rnd_drop_6.ogg",
	"res://sounds/surround/waterdrop1.ogg",
	
]
var timer: Timer
var play_queue: Array = []

var min_interval: float = 4.0
var max_interval: float = 6.0

func _ready():
	
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	
	reset_play_queue()
	
	start_next_sound()

func reset_play_queue():
  
	play_queue = water_drop_sounds.duplicate()
	play_queue.shuffle()

func start_next_sound():
	if play_queue.is_empty():
		reset_play_queue()
	
	var next_sound_path = play_queue.pop_back()
	var audio_stream = load(next_sound_path)  
	
	if audio_stream:
		self.stream = audio_stream
		self.play()
	
	var next_interval = randf_range(min_interval, max_interval)
	timer.start(next_interval)

func _on_timer_timeout():
	start_next_sound()

func set_intervals(min_interval_sec: float, max_interval_sec: float):
	min_interval = min_interval_sec
	max_interval = max_interval_sec

func stop_dripping():
	timer.stop()
	self.stop()

func start_dripping():
	if not timer.is_stopped():
		timer.stop()
	start_next_sound()
