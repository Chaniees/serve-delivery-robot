# Este script va en el nodo Camera2D
extends Camera2D

var shake_amount := 10.0     # magnitud del temblor en píxeles
var shake_time := 0.0        # tiempo restante del shake
var shake_decay := 5.0       # velocidad a la que el shake se desvanece
var original_offset := Vector2.ZERO

func _ready():
	original_offset = offset

func _process(delta):
	if shake_time > 0:
		shake_time -= delta
		# Movimiento aleatorio dentro de shake_amount
		offset = original_offset + Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
	else:
		offset = original_offset
