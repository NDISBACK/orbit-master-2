extends RigidBody2D

var planets = []

var first_phase_target := 9
var second_phase_target := 9

var has_refueled := false
var game_finished := false

var game_time := 0.0
var score := 0

@onready var fuel_bar = $"../CanvasLayer/FuelBar"
@onready var score_label = $"../CanvasLayer/ScoreLabel"
@onready var trajectory_line = $TrajectoryLine

@onready var end_panel = $"../CanvasLayer/EndGame"
@onready var end_score = $"../CanvasLayer/EndGame/ScoreLabel"
@onready var end_time = $"../CanvasLayer/EndGame/timeLabel"

@export var max_fuel := 100.0

@export var min_x := -620.0
@export var max_x := 1820.0
@export var min_y := -310.0
@export var max_y := 1010.0

var fuel := 100.0

@export var fuel_burn_rate := 3.0
@export var reverse_burn_rate := 1.5

@export var thrust_force: float = 300.0
@export var reverse_force: float = 100.0
@export var brake_force: float = 900.0
@export var rotation_speed: float = 4.0
@export var max_speed: float = 1800.0

@export var crystal_scene: PackedScene


func _ready():
	gravity_scale = 0

	planets = get_tree().get_nodes_in_group("planets")

	print("Planets found: ", planets.size())

	linear_velocity = Vector2(0, -140)

	end_panel.visible = false


func _physics_process(delta):

	if game_finished:
		return

	fuel = clamp(fuel, 0.0, max_fuel)

	# ROTATION
	angular_velocity = 0

	if Input.is_action_pressed("ui left"):
		angular_velocity = -rotation_speed

	elif Input.is_action_pressed("ui right"):
		angular_velocity = rotation_speed

	# FORWARD THRUST
	if Input.is_action_pressed("ui up") and fuel > 0:
		fuel -= fuel_burn_rate * delta
		fuel = max(fuel, 0)
		apply_central_force(-transform.y * thrust_force)

	# REVERSE THRUST
	if Input.is_action_pressed("ui down") and fuel > 0:
		fuel -= reverse_burn_rate * delta
		fuel = max(fuel, 0)
		apply_central_force(transform.y * reverse_force)

	# BRAKES
	if Input.is_action_pressed("space"):
		if linear_velocity.length() > 5:
			apply_central_force(
				-linear_velocity.normalized() * brake_force
			)

	# PLANET GRAVITY
	for planet in planets:

		var offset = planet.global_position - global_position

		var distance_sq = max(
			offset.length_squared(),
			2500.0
		)

		var gravity = (
			offset.normalized()
			* planet.gravity_strength
			/ distance_sq
		)

		apply_central_force(gravity)

	# SPEED LIMIT
	if linear_velocity.length() > max_speed:
		linear_velocity = (
			linear_velocity.normalized()
			* max_speed
		)

	# WORLD BOUNDS
	if global_position.x < min_x:
		apply_central_force(Vector2(15000, 0))

	if global_position.x > max_x:
		apply_central_force(Vector2(-15000, 0))

	if global_position.y < min_y:
		apply_central_force(Vector2(0, 15000))

	if global_position.y > max_y:
		apply_central_force(Vector2(0, -15000))


func _process(delta):

	fuel_bar.value = fuel
	score_label.text = "Score: " + str(score)

	if not game_finished:
		game_time += delta

	if fuel <= 0 and not game_finished:
		game_over()


func _on_body_entered(body):

	if body.is_in_group("planets"):
		print("CRASH!")


func collect_shard():

	score += 1

	print("Collected!")
	print("Stars: ", score)

	# FIRST PHASE
	if not has_refueled:

		if score >= first_phase_target:
			print("GO REFUEL!")

	# SECOND PHASE
	else:

		if score >= first_phase_target + second_phase_target:
			win_game()


func refuel(amount):

	if has_refueled:
		return

	if score < first_phase_target:
		print("Collect all stars before refueling!")
		return

	has_refueled = true

	fuel += amount

	fuel = clamp(
		fuel,
		0,
		max_fuel
	)

	print("REFUELED!")

	spawn_new_crystals(second_phase_target)


func spawn_new_crystals(amount):

	var planets = get_tree().get_nodes_in_group("planets")

	for i in range(amount):

		var crystal = crystal_scene.instantiate()

		crystal.global_position = Vector2(
			randf_range(min_x + 100, max_x - 100),
			randf_range(min_y + 100, max_y - 100)
		)

		get_tree().current_scene.add_child(crystal)


func format_time(seconds):

	var minutes = int(seconds / 60)
	var secs = int(seconds) % 60

	return "%02d:%02d" % [minutes, secs]


func game_over():

	if game_finished:
		return

	game_finished = true

	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	sleeping = true

	show_end_screen()


func win_game():

	if game_finished:
		return

	game_finished = true

	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	sleeping = true

	show_end_screen()


func show_end_screen():

	end_panel.visible = true

	end_score.text = "Score: " + str(score)
	end_time.text = "Time: " + format_time(game_time)

	get_tree().paused = true
