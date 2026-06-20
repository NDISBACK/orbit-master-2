extends Area2D

@export var fuel_amount := 30.0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if body.has_method("refuel"):

		body.refuel(fuel_amount)

		queue_free()
