extends RigidBody3D

@export var water_line: float = 0.0
@export var float_force: float = 25.0
@export var water_drag: float = 3.0
@export var angular_drag: float = 3.0

@onready var target_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	var current_y = global_position.y
	
	if current_y < water_line:
		var depth = water_line - current_y
		var upward_impulse = (mass * target_gravity) + (depth * float_force)
		apply_central_force(Vector3.UP * upward_impulse)
		
		linear_damp = water_drag
		angular_damp = angular_drag
	else:
		linear_damp = 0.0
		angular_damp = 0.0
