extends Node

@export var spawners : Array

@onready var room0 : Resource = preload("res://prefabs/room3_0.tscn")
@onready var room1 : Resource = preload("res://prefabs/room3_1.tscn")
@onready var room2 : Resource = preload("res://prefabs/room3_2.tscn")
@onready var is_spawned : bool = false
@onready var is_room0 : bool = false
@onready var is_room1 : bool = false

@onready var room0_inst : Node3D = null
@onready var room1_inst : Node3D = null
@onready var room2_inst : Node3D = null

func _ready() -> void:
	is_room0 = false
	is_room1 = false

func _process(delta: float) -> void:
	if not is_spawned:
		var pos : Vector3 = spawners[0]
		room0_inst = room0.instantiate()
		room0_inst.position = pos
		get_parent().add_child(room0_inst)
		is_spawned = true
		is_room0 = true

func regenerate() -> void:
	if is_room0:
		room0_inst.queue_free()
		room0_inst = null
		var pos : Vector3 = spawners[0]
		room1_inst = room1.instantiate()
		room1_inst.position = pos
		get_parent().add_child(room1_inst)
		is_room0 = false
		is_room1 = true
	elif is_room1:
		room1_inst.queue_free()
		room1_inst = null
		var pos : Vector3 = spawners[0]
		room2_inst = room2.instantiate()
		room2_inst.position = pos
		get_parent().add_child(room2_inst)
		is_room1 = false
	else:
		room2_inst.queue_free()
		room2_inst = null
		var pos : Vector3 = spawners[0]
		room0_inst = room0.instantiate()
		room0_inst.position = pos
		get_parent().add_child(room0_inst)
		is_room0 = true
