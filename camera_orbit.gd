extends Camera3D

@export var pivot: Vector3 = Vector3(0.0, 0.5, 0.0)
@export var distance: float = 18.0
@export var yaw: float = 0.0
@export var pitch: float = -25.0
@export var mouse_sensitivity: float = 0.3
@export var zoom_speed: float = 1.5
@export var min_distance: float = 5.0
@export var max_distance: float = 50.0
@export var min_pitch: float = -80.0
@export var max_pitch: float = -5.0

var _orbiting: bool = false


func _ready() -> void:
	_apply_transform()
	print("camera_orbit _ready: pos=", global_position)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_orbiting = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			distance = max(min_distance, distance - zoom_speed)
			_apply_transform()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			distance = min(max_distance, distance + zoom_speed)
			_apply_transform()
	elif event is InputEventMouseMotion and _orbiting:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, min_pitch, max_pitch)
		_apply_transform()


func _apply_transform() -> void:
	var yaw_rad := deg_to_rad(yaw)
	var pitch_rad := deg_to_rad(pitch)
	var offset := Vector3(
		distance * cos(pitch_rad) * sin(yaw_rad),
		distance * -sin(pitch_rad),
		distance * cos(pitch_rad) * cos(yaw_rad)
	)
	global_position = pivot + offset
	look_at(pivot, Vector3.UP)
