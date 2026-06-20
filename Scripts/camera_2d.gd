extends Camera2D

@export var look_ahead_distance := 250.0
@export var smooth_speed := 5.0

@onready var ship: RigidBody2D = get_parent()

func _process(delta):
	
	var velocity = ship.linear_velocity
	
	var target_offset = Vector2.ZERO
	
	if velocity.length() > 10:
		target_offset = velocity.normalised() * look_ahead_distance
		
	offset = offset.lerp(
		target_offset,
		smooth_speed * delta
	)
