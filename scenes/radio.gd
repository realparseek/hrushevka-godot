extends "res://scripts/radio.gd"


# Ссылка на узел игрока (слушателя)
@export var player_node: Node3D
# Ссылка на наш RayCast3D
@export var occlusion_raycast: RayCast3D

# Максимальная дистанция, на которой звук слышен без помех
@export var max_hear_distance: float = 10.0
# Громкость звука, когда луч НЕ перекрыт (радио и игрок в одной комнате)
@export var clear_volume_db: float = 0.0
# Громкость звука, когда луч перекрыт стеной
@export var occluded_volume_db: float = -20.0

# Опционально: фильтр низких частот для "приглушенного" звука
var occlusion_filter: AudioEffectLowPassFilter
var bus_index: int

func _ready():
	# Находим луч, если он не назначен вручную
	if not occlusion_raycast:
		occlusion_raycast = $RayCast3D

	# Создаем и настраиваем аудиофильтр
	occlusion_filter = AudioEffectLowPassFilter.new()
	occlusion_filter.cutoff_hz = 2000 # Изначально высокий порог = звук чистый

	# Добавляем фильтр в аудиосервер и назначаем его на шину этого плеера
	bus_index = AudioServer.get_bus_count()
	AudioServer.add_bus(bus_index)
	AudioServer.add_bus_effect(bus_index, occlusion_filter)
	self.bus = AudioServer.get_bus_name(bus_index)

func _process(_delta):
	if not player_node or not occlusion_raycast:
		return

	# Направляем луч от радио к игроку
	var player_position = player_node.global_transform.origin
	occlusion_raycast.target_position = to_local(player_position)

	# Принудительно обновляем луч
	occlusion_raycast.force_raycast_update()

	# Проверяем, есть ли столкновение
	if occlusion_raycast.is_colliding():
		# Получаем объект, в который попал луч
		var collider = occlusion_raycast.get_collider()

		# Если луч уперся именно в игрока, значит, стены нет
		if collider == player_node:
			set_occlusion(false)
		else:
			# Если луч уперся во что-то другое (стену), значит, звук должен быть приглушен
			set_occlusion(true)
	else:
		# На всякий случай, если луч ни во что не попал
		set_occlusion(false)

func set_occlusion(is_occluded: bool):
	if is_occluded:
		self.volume_db = occluded_volume_db
		occlusion_filter.cutoff_hz = 2000 # Низкий порог = высокие частоты срезаются
	else:
		self.volume_db = clear_volume_db
		occlusion_filter.cutoff_hz = 5000 # Высокий порог = все частоты проходят
