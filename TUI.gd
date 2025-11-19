extends CanvasLayer
# ----------------------------------------
#Exporta las variables mandadas en el Script del robot
# ----------------------------------------
@export var speed_label_path: NodePath
@export var gear_label_path: NodePath
# ----------------------------------------
#Crea sus variables locales
# ----------------------------------------
var speed_label: Label
var gear_label: Label
var current_speed: float = 0.0
var current_gear: int = 1
# ----------------------------------------
#Actualiza el estado de UI cada vez que abre reinciando todo a 0
# ----------------------------------------
func _ready():
	speed_label = get_node_or_null(speed_label_path) as Label
	gear_label = get_node_or_null(gear_label_path) as Label
	print("SpeedLabel encontrado: ", speed_label)
	print("GearLabel encontrado: ", gear_label)
	update_ui()
# ----------------------------------------
#MANDA A ACTUALIZA CONSTANTEMENTE LA UI
# ----------------------------------------
func _process(_delta):
	update_ui()
# ----------------------------------------
#ACTUALIZA CONSTANTEMENTE LA UI (SPEED Y GEARS)
# ----------------------------------------
func update_ui():
	if speed_label:
		speed_label.text = str(current_speed) + " m/s"
	if gear_label:
		gear_label.text = "GEAR " + str(current_gear)
