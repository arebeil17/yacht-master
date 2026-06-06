extends Node3D

const CABIN_SCENE := preload("res://cabin.tscn")

@onready var hull: RigidBody3D = $Hull
@onready var camera: Camera3D = $Camera3D

var _highlight_mat: StandardMaterial3D
var _sockets: Array[Marker3D] = []
var _hovered_socket: Marker3D = null
var _hull_hovered: bool = false
var _occupied_sockets: Dictionary = {}


func _ready() -> void:
	_highlight_mat = StandardMaterial3D.new()
	_highlight_mat.albedo_color = Color(1.0, 0.9, 0.1, 1.0)
	_highlight_mat.emission_enabled = true
	_highlight_mat.emission = Color(0.8, 0.7, 0.0)
	_highlight_mat.emission_energy_multiplier = 2.0
	_highlight_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	for child in hull.get_children():
		if child is Marker3D:
			_sockets.append(child)


func _process(_delta: float) -> void:
	_do_raycast()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _hovered_socket != null and not _occupied_sockets.has(_hovered_socket):
				_place_module(_hovered_socket)


func _do_raycast() -> void:
	var space_state := get_world_3d().direct_space_state
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_end := ray_origin + camera.project_ray_normal(mouse_pos) * 1000.0

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result := space_state.intersect_ray(query)

	var hit_hull: bool = result.has("collider") and result["collider"] == hull

	if hit_hull:
		if not _hull_hovered:
			_hull_hovered = true
			_set_sockets_visible(true)
		var nearest := _find_nearest_socket(result["position"])
		if nearest != _hovered_socket:
			if _hovered_socket != null:
				_set_socket_highlight(_hovered_socket, false)
			_hovered_socket = nearest
			if _hovered_socket != null:
				_set_socket_highlight(_hovered_socket, true)
	else:
		if _hull_hovered:
			_hull_hovered = false
			_set_sockets_visible(false)
			if _hovered_socket != null:
				_set_socket_highlight(_hovered_socket, false)
				_hovered_socket = null


func _find_nearest_socket(point: Vector3) -> Marker3D:
	var nearest: Marker3D = null
	var nearest_dist_sq := INF
	for socket in _sockets:
		if _occupied_sockets.has(socket):
			continue
		var d := socket.global_position.distance_squared_to(point)
		if d < nearest_dist_sq:
			nearest_dist_sq = d
			nearest = socket
	return nearest


func _set_sockets_visible(show: bool) -> void:
	for socket in _sockets:
		if _occupied_sockets.has(socket):
			continue
		var indicator := socket.get_node_or_null("Indicator")
		if indicator:
			indicator.visible = show


func _set_socket_highlight(socket: Marker3D, highlighted: bool) -> void:
	var indicator := socket.get_node_or_null("Indicator")
	if indicator == null:
		return
	indicator.material_override = _highlight_mat if highlighted else null


func _place_module(socket: Marker3D) -> void:
	var cabin: RigidBody3D = CABIN_SCENE.instantiate()
	cabin.freeze = true
	cabin.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	hull.add_child(cabin)
	var attach: Marker3D = cabin.get_node("SocketAttach")
	cabin.global_transform = socket.global_transform * attach.transform.affine_inverse()
	_occupied_sockets[socket] = cabin
	var indicator := socket.get_node_or_null("Indicator")
	if indicator:
		indicator.visible = false
