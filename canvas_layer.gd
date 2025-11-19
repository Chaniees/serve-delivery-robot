extends CanvasLayer

# ----------------------------------------
# RUTAS A LOS ELEMENTOS DE UI
# ----------------------------------------
@export var speed_label_path: NodePath
@export var gear_label_path: NodePath

# Nodos reales
var speed_label: Label
var gear_label: Label

# ----------------------------------------
# VARIABLES QUE EL ROBOT ACTUALIZARÁ
# ----------------------------------------
var current_speed: float = 0.0   # Lo actualiza el robot
var current_gear: int = 1        # Lo actualiza el robot


func _ready():
	speed_label = get_node(speed_label_path) as Label
	gear_label = get_node(gear_label_path) as Label


	if speed_label == null:
		push_error("El speed_label_path NO apunta a un Label.")
	if gear_label == null:
		push_error("El gear_label_path NO apunta a un Label.")

	update_ui()
	print("SpeedLabel es tipo: ", speed_label, " (", speed_label.get_class(), ")")
	print("GearLabel es tipo: ", gear_label, " (", gear_label.get_class(), ")")
# ----------------------------------------
# FUNCIÓN PARA ACTUALIZAR EL UI
# ----------------------------------------
func update_ui():
	if speed_label:
		speed_label.text = str(round(current_speed)) + " km/h"
	if gear_label:
		gear_label.text = "GEAR " + str(current_gear)
