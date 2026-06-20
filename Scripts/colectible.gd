extends Area2D

@export var orbit_center: Node2D
@export var orbit_radius: float = 150.0
@export var orbit_speed: float = 1.5

var angle: float = 0.0

func _ready():

	# Start at a random orbit position
	angle = randf() * TAU

	body_entered.connect(_on_body_entered)

func _process(delta):

	if orbit_center == null:
		return

	angle += orbit_speed * delta

	global_position = (
		orbit_center.global_position +
		Vector2(
			cos(angle),
			sin(angle)
		) * orbit_radius
	)

func _on_body_entered(body):

		

	print("Touched:", body.name)

	if body.has_method("collect_shard"):

		print("Found collect_shard function")

		body.collect_shard()

	queue_free()
