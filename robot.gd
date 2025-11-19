extends CharacterBody2D
#---------------------------
#VARIABLES DE LA CAMARA
#---------------------------
@onready var cam := $Camera2D
var camera_mode = 1            # 1 = sin rotación, 2 = con rotación
var forward_offset := 100      # cuánto se mueve hacia adelante
var reverse_offset := -50.0    # cuánto hacia atrás
var camera_smooth := 5.0       # suavidad del movimiento
#---------------------------
#VARIABLES DEL MINIMAPA
#---------------------------
@export var hud_path: NodePath
var hud
var world_size = Vector2(4500, 4500) #Escala del Mapa Real = 1500 x 3
var minimap_size = Vector2(3750, 3750) #Escala del Mapa Low POly = 1500 x 2.5
var scale_factor = minimap_size / world_size #Operacion matematica para escalar la posicion 
var minimap_robot: Node2D = null
# ----------------------------------------
# PARÁMETROS DEL VEHÍCULO
# ----------------------------------------
@export var wheel_base_px: float = 120.0
@export var max_steer_deg: float = 35.0
@export var steer_speed_deg: float = 200.0
@export var max_speed: float = 900.0             #Velocidad maxima
@export var max_reverse_speed: float = 600.0     #Velocidad en reversa maxima
@export var accel_rate: float = 800.0
@export var decel_rate: float = 800.0
@export var reverse_accel_rate: float = 800.0
@export var coast_drag: float = 100.0            #Cuanto tiempo tarda en frenar // Mayor numero mas rapido
@export var throttle_response: float = 1.8
var accel_input: float = 0.0                     #Variable de Arranque = No acelerar cuando se abre la aplicacion
# ----------------------------------------
#PARAMETROS DEL DEADMANSWITCH
# ----------------------------------------
@export var deadman_required: bool = true
@export var deadman_action: String = "deadman"
@export var deadman_immediate_stop: bool = false
@export var deadman_brake_decay: float = 400.0   #Cuanto tiempo tarda en frenar // Mayor numero mas rapido
@export var deadman_brake_curve: float = 1.0
@export var deadman_min_brake: float = 200.0
var deadman_image: TextureRect = null
# ----------------------------------------
#PARAMETRO DE LOS GEARS
# ----------------------------------------
@export var gear_names := ["1", "2", "3"]
@export var gear_speed_factors := [0.23, 0.32, 0.45]  #Factores de velocidad // Cambia la velocidad
@export var gear_accel_factors := [0.6, 1.0, 1.4]     #Multiplicadores de factores
@export var gear_index: int = 0                      #Variable de arranque = Estar en Gear 1 al abrir el programa
# ----------------------------------------
#PARAMETRO DEL GIRO
# ----------------------------------------
@export var gear_steer_scales := [2.0, 1.6, 1.2]      #Giro dependiente de velocidad
@export var clamp_effective_steer_to_max_deg: bool = true
@export var steer_scale_at_low_speed: float = 1.6
# ----------------------------------------
#PARAMETROS DEL UI
# ----------------------------------------
@export var gear_label_path: NodePath = NodePath("GearLabel")   #Gears Informacion
var _gear_label: Label = null
@export var pixels_per_meter: float = 100.0                     #Transformacion de PixelxM
@export var speed_label_path: NodePath = NodePath("SpeedLabel") #Velocidad Informacion
var _speed_label: Label = null
# ----------------------------------------
#VARIABLES DE ARRANQUE
# ----------------------------------------
var speed: float = 0.0
var steer_angle: float = 0.0
var _prev_deadman_pressed: bool = true
# ----------------------------------------
#FUNCION DE RADIANES A GRADOS
# ----------------------------------------
func rad_to_rad(value: float) -> float:
	return deg_to_rad(value)
# ----------------------------------------
#CODIGO DE ARRANQUE // LO PRIMERO QUE HACE AL ABRIR EL PROGRAMA
# ----------------------------------------
func _ready() -> void:
	hud = get_node(hud_path)  #Asigna el enlace con la UI
	set_physics_process(true) #Arranca el proceso de las fisicas
	_gear_label = get_node_or_null(gear_label_path)  #Se relaciona con la informacion de los gears
	_speed_label = get_node_or_null(speed_label_path) #Se relaciona con la informacion de la velocidad
	deadman_image = hud.get_node_or_null("DeadmanImage") #Se relaciona con la imagen del Park
	minimap_robot = hud.get_node_or_null("MinimapViewport/RobotMini") #Se relaciona con el minimapa
	gear_index = clamp(gear_index, 0, max(0, gear_speed_factors.size() - 1)) #Realiza la operacion para determinar el gear actual
	if gear_steer_scales.size() < gear_speed_factors.size():  #El que modifica el Gear
		var needed = gear_speed_factors.size() - gear_steer_scales.size()
		for i in range(needed):
			gear_steer_scales.append(steer_scale_at_low_speed)
	_update_gear_label()  #Actualiza los datos y los manda a la UI
	_update_speed_label() #Actualiza los datos y los manda a la UI
# ----------------------------------------
#
# ----------------------------------------
func _process(delta: float) -> void:
	# Cambiar modo con la acción (asegúrate de crear camera_change en Input Map)
	if Input.is_action_just_pressed("camera_change"):
		camera_mode = 2 if camera_mode == 1 else 1
		print("Modo de cámara:", camera_mode)
	apply_camera_mode(delta)
	update_camera_offset(delta)
	accel_input = clamp(sign(velocity.dot(Vector2.RIGHT.rotated(rotation))) * (velocity.length() / max_speed), -1, 1)
# ----------------------------------------
#FUNCION DEL ZOOM DE LA CAMARA 2
# ----------------------------------------
func update_camera_offset(delta):
	if (camera_mode==2):
		var forward_dir = Vector2.RIGHT.rotated(rotation)
		var target_offset := Vector2.ZERO
		if accel_input > 0:  # acelerando adelante
			target_offset = forward_dir * forward_offset    #Al acelerar la camara se mueve hacia adelante 
		elif accel_input < 0: # reversa
			target_offset = forward_dir * reverse_offset    #Al frenar la camara se mueve hacia atras
		cam.offset = cam.offset.lerp(target_offset, delta * camera_smooth) #Esto lo vuelve suave
# ----------------------------------------
#FUNCION DE MODO DE CAMARA
# ----------------------------------------
func apply_camera_mode(delta: float) -> void:
	if camera_mode == 1:   # Modo 1: mantener la cámara sin rotación global (orientación del mundo)
		cam.global_rotation = 0.0 #Hacer que no rote linkeando a la global
		$Camera2D.offset = Vector2(310, 20)  #Mover el offset de la camara para que se centre
		$Camera2D.position = Vector2(0, 0)  #Reinicia la posicion de la camara para que no se mueva fuera de lugar
	elif camera_mode == 2:  # Modo 2: que la cámara rote con el robot -> aseguramos rotación relativa 0
		cam.rotation = 0.0  #Hacer que rote la camara siguiendo la del robot
		cam.rotation_degrees = 90  # Rota junto al robot + offset de 90
		$Camera2D.position = Vector2(-35, 330)  #Acomoda la camara para estar centrada
# ----------------------------------------
#FUNCION DE VELOCIDAD
# ----------------------------------------
func _update_speed_label() -> void:
	if _speed_label:
		var ms = (speed / pixels_per_meter) if pixels_per_meter != 0 else 0.0 #Transforma los pixeles en m/s
		_speed_label.text = "%0.2f m/s" % ms   #Manda la informacion al UI
# ----------------------------------------
#FUNCION DE GEARS
# ----------------------------------------
func set_gear(idx: int) -> void:
	gear_index = clamp(idx, 0, max(0, gear_speed_factors.size() - 1)) #Hace el cambio de gears
	_update_gear_label()  #Actualiza los gears constantemente
# ----------------------------------------
#FUNCION DE LAS FISICAS
# ----------------------------------------
func _physics_process(delta: float) -> void:
	#Envia los cambios a la UI
	if hud:
		hud.current_speed = _speed_label.text
		hud.current_gear = _gear_label.text
	# Actualizar robot en minimapa
	if minimap_robot:
		var scaled_pos = global_position * scale_factor
		minimap_robot.position = global_position  # sigue la posición del robot real
		minimap_robot.position = scaled_pos
	# Cambio de Gears
	if Input.is_action_just_pressed("gear_up"):
		set_gear(gear_index + 1)                 #sube de gears
	if Input.is_action_just_pressed("gear_down"):
		set_gear(gear_index - 1)                 #baja de gears
	# Parámetros según la marcha
	var current_max_speed = max_speed * gear_speed_factors[gear_index]
	var current_max_reverse = max_reverse_speed * gear_speed_factors[gear_index]
	var current_accel = accel_rate * gear_accel_factors[gear_index]
	var current_decel = decel_rate * gear_accel_factors[gear_index]
	var current_reverse_accel = reverse_accel_rate * gear_accel_factors[gear_index]
	# Inputs
	var raw_throttle = Input.get_action_strength("throttle")
	var raw_rev = Input.get_action_strength("reverse")
	var steer_input = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var deadman_pressed = not deadman_required or Input.is_action_pressed(deadman_action)
	# Actualizar visibilidad de la imagen
	if deadman_image:
		deadman_image.visible = not deadman_pressed
	var skip_coast := false
	# Deadman NO presionado → frenado fuerte + gear 1
	if not deadman_pressed:
		if deadman_immediate_stop:
			speed = 0.0
			set_gear(0)
			_update_speed_label()
			return
		else:
			var abs_spd = abs(speed)
			if abs_spd > 0.001:
				var speed_ratio = clamp(abs_spd / current_max_speed, 0.0, 1.0)
				var curved = pow(speed_ratio, deadman_brake_curve)
				var applied_decel = lerp(deadman_min_brake, deadman_brake_decay, curved)
				speed = move_toward(speed, 0.0, applied_decel * delta)
			else:
				speed = 0.0
			raw_throttle = 0.0
			raw_rev = 0.0
			skip_coast = true
			set_gear(0) # gear 1
	# Curva de respuesta
	var throttle = pow(raw_throttle, throttle_response)
	var rev = pow(raw_rev, throttle_response)
	# Steering smoothing
	var max_steer_rad = rad_to_rad(max_steer_deg)
	var target_steer = clamp(steer_input, -1.0, 1.0) * max_steer_rad
	var max_delta = rad_to_rad(steer_speed_deg) * delta
	steer_angle = move_toward(steer_angle, target_steer, max_delta)
	# Target speed base
	var target_speed := 0.0
	if throttle > 0.0:
		target_speed = throttle * current_max_speed
	elif rev > 0.0:
		target_speed = -rev * current_max_reverse
	else:
		target_speed = speed # mantener velocidad actual para coast
	# --- Movimiento de velocidad ---
	if throttle > 0.0:
		var max_change = current_accel * delta
		if speed < 0.0:
			max_change = current_decel * delta
		speed = move_toward(speed, target_speed, max_change)
	elif rev > 0.0:
		var max_change = current_reverse_accel * delta
		if speed > 0.0:
			max_change = current_decel * delta
		speed = move_toward(speed, target_speed, max_change)
	else:
		# Deadman presionado → desaceleración suave + volver a gear 1
		if deadman_pressed:
			if speed > 0.0:
				speed = max(0.0, speed - coast_drag * delta)
			elif speed < 0.0:
				speed = min(0.0, speed + coast_drag * delta)
			set_gear(0) # volver a gear 1 si no se está acelerando
		else:
			pass # Deadman suelto ya manejado
	# Clamp
	speed = clamp(speed, -current_max_reverse, current_max_speed)
	# Steering con bicycle model (sin invertir giro en reversa)
	var abs_speed2 = abs(speed)
	var speed_ratio2 = clamp(abs_speed2 / current_max_speed, 0.0, 1.0)
	var gear_base_steer_scale = gear_steer_scales[gear_index]
	var steer_scale = lerp(gear_base_steer_scale, 1.0, speed_ratio2)
	var effective_steer = steer_angle * steer_scale
	if clamp_effective_steer_to_max_deg:
		effective_steer = clamp(effective_steer, -max_steer_rad, max_steer_rad)
	var yaw_rate = (speed / wheel_base_px) * tan(effective_steer) # no invertimos en reversa
	rotation += yaw_rate * delta
	var forward = Vector2.RIGHT.rotated(rotation)
	velocity = forward * speed
	move_and_slide()
	_prev_deadman_pressed = deadman_pressed
	_update_speed_label()
	# Referencia automática a la UI
# ----------------------------------------
#FUNCION DE GEARS
# ----------------------------------------
func _update_gear_label() -> void:
	if _gear_label:
		if gear_index >= 0 and gear_index < gear_names.size():
			name = gear_names[gear_index]
		else:
			name = str(gear_index + 1)
		_gear_label.text = "Gear: %s" % name
#Esto nada mas manda la informacion de los Gears al UI
