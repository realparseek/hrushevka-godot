extends SteamAudioPlayer

@export var tracks = [
	preload("res://sounds/radio/commuter_train.ogg"),
	preload("res://sounds/radio/Cuckoo.ogg"),
	preload("res://sounds/radio/Summer_will_be_over.ogg")
]

var current_track_index = 0
var radio_playing = false
var time_out_of_zone = 0.0
var timer_started = false

func _ready():
	select_random_track()
	self.finished.connect(_on_track_finished)
	self.stream_paused = true

func _process(delta):
	if timer_started:
		time_out_of_zone += delta

func select_random_track():
	if tracks.size() > 0:
		current_track_index = randi() % tracks.size()

func _on_track_finished():
	current_track_index = (current_track_index + 1) % tracks.size()
	play_current_track()

func play_current_track():
	if tracks.size() > 0:
		self.stream = tracks[current_track_index]
		self.play()
		radio_playing = true

func start_radio():
	if tracks.size() > 0:
		if time_out_of_zone > 60.0:
			select_random_track()
			play_current_track()
		if not radio_playing:
			self.stream = tracks[current_track_index]
			self.play()
		radio_playing = true
		self.stream_paused = false
		timer_started = false
		time_out_of_zone = 0.0

func stop_radio():
	self.stream_paused = true
	timer_started = true
