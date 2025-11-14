extends CharacterBody3D

@export var look_sensetivity : float = 6
@export var walk_speed : float = 10.0
@export var sprint_speed : float = 15.0
@export var gravity : float = 9.8
@export var jump_height : float = 9.0
@export var jump_duration : float = 0.25
@export var headbob_size : float = 0.1
@export var headbob_speed : float = 1.25

@onready var pickcast : RayCast3D = $head/Camera3D/RayCast3D

var cur_outline_obj : Object = null
var outline_material : Resource = null

var jump_timer : float = jump_duration
var headbob_timer : float = 0.0
var look_sensetivity_mul : float = 0.001

	
func _ready() -> void:
	outline_material = load("res://materials/outline2/outline2.tres")
	
func _process(delta: float) -> void:
	_handle_jump_timer(delta)
	_handle_headbob(delta)
	
func _physics_process(delta: float) -> void:
	if _is_jumping():
		_handle_jumping_movement()
	else:
		_handle_ground_movement()
		_handle_gravity()
		_handle_jumping()

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed('ui_cancel'):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var pick_obj : Object = _get_hovered_object()
	if pick_obj:
		if not cur_outline_obj:
			cur_outline_obj = pick_obj
		pick_obj.get_child(0).set_hover(true)
	else:
		if cur_outline_obj:
			cur_outline_obj.get_child(0).set_hover(false)
			cur_outline_obj = null
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x*look_sensetivity*look_sensetivity_mul)
			$head/Camera3D.rotate_x(-event.relative.y*look_sensetivity*look_sensetivity_mul)
			$head/Camera3D.rotation.x = clamp($head/Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		if event is InputEventMouseButton:
			if pick_obj:
				var openable : Node = pick_obj.get_child(0)
				if openable.is_opened:
					openable.close()
				else:
					openable.open()


func _handle_ground_movement() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var wdir = Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_back").normalized()
		wdir = global_transform.basis * Vector3(wdir.x, 0.0, wdir.y)
		velocity = wdir*_get_move_speed()
	else:
		velocity = Vector3.ZERO

func _handle_jumping_movement() -> void:
	velocity.y = jump_height

func _handle_gravity() -> void:
	if not is_on_floor():
		velocity.y -= gravity
	else:
		velocity.y = 0.0

func _handle_jumping() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_set_jump_timer()

func _handle_headbob(delta: float) -> void:
	if is_on_floor():
		$head.position.y = sin(headbob_timer)*headbob_size
		headbob_timer += delta*headbob_speed*velocity.length()

func _handle_jump_timer(delta: float) -> void:
	if jump_timer < jump_duration:
		jump_timer += delta

func _get_move_speed() -> float:
	if Input.is_action_pressed("sprint"):
		return sprint_speed
	else:
		return walk_speed

func _set_jump_timer() -> void:
	jump_timer = 0.0

func _is_jumping() -> bool:
	return jump_timer < jump_duration

func _get_hovered_object() -> Object:
	var obj = pickcast.get_collider()
	if obj:
		return obj.get_parent()
	else:
		return null
		
