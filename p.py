import pyautogui
import time

text = """
extends Camera2D

@export var max_look_ahead := 120.0
@export var smooth_speed := 2.0
@export var min_speed_for_look_ahead := 100.0

@onready var ship: RigidBody2D = get_parent()

func _ready():

	# Camera boundaries
	limit_left = -620
	limit_right = 1820

	limit_top = -310
	limit_bottom = 1010

	# Smooth camera
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0


func _process(delta):

	if ship == null:
		return

	var velocity = ship.linear_velocity

	var target_offset = Vector2.ZERO

	if velocity.length() > min_speed_for_look_ahead:

		var amount = clamp(
			velocity.length() / 1500.0,
			0.0,
			1.0
		)

		target_offset = (
			velocity.normalized()
			* max_look_ahead
			* amount
		)

	offset = offset.lerp(
		target_offset,
		smooth_speed * delta
	)


"""

print("Click inside a text box in 5 seconds...")
time.sleep(5)

while True:
    for char in text:
        pyautogui.write(char)
        time.sleep(0.07)

    time.sleep(1)

    for _ in text:
        pyautogui.press("backspace")
        time.sleep(0.04)

    time.sleep(1)