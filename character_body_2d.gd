extends CharacterBody2D

# Car controller con colisiones (Godot 4)
# Versión ajustada: el signo del giro viene del input del volante (steer_angle),
# de modo que "girar a la derecha" siempre rote en el mismo sentido visual
# independientemente de si vas hacia adelante o en reversa.
#
# Entradas requeridas en Input Map: throttle, reverse, steer_left, steer_right, deadman, gear_up, gear_down
# Añadir Label hijos opcionales: GearLabel, SpeedLabel

@export var wheel_base_px: float = 120.0
@export var max_steer_deg: float = 35.0
@export var steer_speed_deg: float = 200.0

# --- parámetros base ---
@export var max_speed: float = 900.0
@export var max_reverse_speed: float = 900.0
@export var accel_rate: float = 800.0
@export var decel_rate: float = 800.0
@export var reverse_accel_rate: float = 800.0

@export var coast_drag: float = 200.0
@export var throttle_response: float = 1.8

# --- deadman ---
@export var deadman_required: bool = true
@export var deadman_action: String = "deadman"
@export var deadman_immediate_stop: bool = false
@export var deadman_brake_decay: float = 3000.0
@export var deadman_brake_curve: float = 1.0
@export var deadman_min_brake: float = 200.0

# --- gears ---
@export var gear_names := ["1", "2", "3"]
@export var gear_speed_factors := [0.17, 0.23, 0.32]
@export var gear_accel_factors := [0.7, 1.0, 1.4]
@export var gear_index: int = 1

# --- UI nodes (assign in inspector or leave default names) ---
@export var gear_label_path: NodePath = NodePath("GearLabel")
@export var speed_label_path: NodePath = NodePath("SpeedLabel")
@export var pixels_per_meter: float = 100.0

var _gear_label: Label = null
var _speed_label: Label = null

# --- steering tuning per gear ---
@export var gear_steer_scales := [2.0, 1.6, 1.2]
@export var steer_scale_at_low_speed: float = 1.6
@export var clamp_effective_steer_to_max_deg: bool = true

# Control de inversión / comportamiento del volante
@export var invert_steer_in_reverse: bool = false
@export var force_steer_by_input: bool = true  # si true, signo del giro = signo del input del volante

# Depuración
@export var debug_steer: bool = false

# --- collision response tuning ---
@export var collision_response: String = "stop"  # opciones: "stop", "bounce", "slide"
@export var bounce_coefficient: float = 0.5

# internals
var speed: float = 0.0
var steer_angle: float = 0.0
var _prev_deadman_pressed: bool = true

# helper
func rad_to_rad(value: float) -> float:
	return deg_to_rad(value)

func _ready() -> void:
	set_physics_process(true)
	_gear_label = get_node_or_null(gear_label_path) if gear_label_path != NodePath("") else null
	_speed_label = get_node_or_null(speed_label_path) if speed_label_path != NodePath("") else null

	gear_index = clamp(gear_index, 0, max(0, gear_speed_factors.size() - 1))
	if gear_steer_scales.size() < gear_speed_factors.size():
		var need = gear_speed_factors.size() - gear_steer_scales.size()
		for i in range(need):
			gear_steer_scales.append(steer_scale_at_low_speed)

	_update_gear_label()
	_update_speed_label()
	_prev_deadman_pressed = not deadman_required or Input.is_action_pressed(deadman_action)

func _update_gear_label() -> void:
	if _gear_label:
		var name = gear_names[gear_index] if (gear_index >= 0 and gear_index < gear_names.size()) else str(gear_index + 1)
		_gear_label.text = "Gear: %s" % name

func _update_speed_label() -> void:
	if _speed_label:
		var ms = speed / pixels_per_meter if pixels_per_meter != 0.0 else 0.0
		_speed_label.text = "Speed: %0.2f m/s" % ms

func set_gear(idx: int) -> void:
	gear_index = clamp(idx, 0, max(0, gear_speed_factors.size() - 1))
	_update_gear_label()

func _physics_process(delta: float) -> void:
	# cambios de marcha
	if Input.is_action_just_pressed("gear_up"):
		set_gear(gear_index + 1)
	if Input.is_action_just_pressed("gear_down"):
		set_gear(gear_index - 1)

	# parámetros según marcha
	var current_max_speed = max_speed * (gear_speed_factors[gear_index] if gear_index < gear_speed_factors.size() else 1.0)
	var current_max_reverse = max_reverse_speed * (gear_speed_factors[gear_index] if gear_index < gear_speed_factors.size() else 1.0)
	var current_accel = accel_rate * (gear_accel_factors[gear_index] if gear_index < gear_accel_factors.size() else 1.0)
	var current_decel = decel_rate * (gear_accel_factors[gear_index] if gear_index < gear_accel_factors.size() else 1.0)
	var current_reverse_accel = reverse_accel_rate * (gear_accel_factors[gear_index] if gear_index < gear_accel_factors.size() else 1.0)

	# entradas
	var raw_throttle = Input.get_action_strength("throttle")
	var raw_rev = Input.get_action_strength("reverse")
	var steer_input = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var deadman_pressed = not deadman_required or Input.is_action_pressed(deadman_action)

	# deadman
	var skip_coast: bool = false
	if not deadman_pressed:
		if deadman_immediate_stop:
			speed = 0.0
			_prev_deadman_pressed = deadman_pressed
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

	# aplicar curva de respuesta
	var throttle = pow(clamp(raw_throttle, 0.0, 1.0), throttle_response)
	var rev = pow(clamp(raw_rev, 0.0, 1.0), throttle_response)

	# steering smoothing (steer_angle conserva signo del input)
	var max_steer_rad = rad_to_rad(max_steer_deg)
	var target_steer = clamp(steer_input, -1.0, 1.0) * max_steer_rad
	var max_delta = rad_to_rad(steer_speed_deg) * delta
	steer_angle = move_toward(steer_angle, target_steer, max_delta)

	# target speed
	var target_speed: float = 0.0
	if throttle > 0.0:
		target_speed = throttle * current_max_speed
	elif rev > 0.0:
		target_speed = -rev * current_max_reverse
	else:
		target_speed = 0.0

	# update speed
	if target_speed > speed:
		var max_change = current_accel * delta
		if speed < 0.0:
			max_change = current_decel * delta
		speed = move_toward(speed, target_speed, max_change)
	elif target_speed < speed:
		var max_change = current_decel * delta
		if target_speed < 0.0 and speed > 0.0:
			max_change = current_reverse_accel * delta
		speed = move_toward(speed, target_speed, max_change)

	# coast drag
	if not skip_coast and raw_throttle == 0.0 and raw_rev == 0.0 and target_speed == 0.0:
		if speed > 0.0:
			speed = max(0.0, speed - coast_drag * delta)
		elif speed < 0.0:
			speed = min(0.0, speed + coast_drag * delta)

	# clamp
	speed = clamp(speed, -current_max_reverse, current_max_speed)

	# movimiento con colisiones
	var forward = Vector2.RIGHT.rotated(rotation)
	var displacement : Vector2 = forward * speed * delta
	var collision = move_and_collide(displacement)
	if collision:
		if collision_response == "stop":
			speed = 0.0
		elif collision_response == "bounce":
			var normal = collision.get_normal()
			var vel = forward * speed
			var reflected = vel.bounced(normal) * bounce_coefficient
			speed = reflected.length()
			if speed > 1.0:
				rotation = reflected.angle()
		elif collision_response == "slide":
			var n = collision.get_normal()
			var vel = forward * speed
			var tangent = Vector2(n.y, -n.x)
			var along = vel.dot(tangent.normalized())
			speed = abs(along)
			if speed > 1.0:
				rotation = tangent.normalized().angle() * sign(along)

	# actualizar estado
	_prev_deadman_pressed = deadman_pressed

	# --- cálculo de giro (bicycle model) con signo tomado del input suavizado ---
	var abs_speed_for_yaw = abs(speed)
	var speed_ratio2 = clamp(abs_speed_for_yaw / current_max_speed, 0.0, 1.0)
	var base_steer_scale = steer_scale_at_low_speed
	if gear_index < gear_steer_scales.size():
		base_steer_scale = gear_steer_scales[gear_index]
	var steer_scale = lerp(base_steer_scale, 1.0, speed_ratio2)

	# effective_steer mantiene signo del steer_angle (input suavizado)
	var effective_steer = steer_angle * steer_scale

	# Forzar que el signo del yaw venga del input (steer_angle) cuando force_steer_by_input = true
	# Calculamos magnitud con abs(effective_steer) y aplicamos sign(steer_angle) al resultado.
	var steer_sign = 0.0
	if abs(steer_angle) > 0.0001:
		steer_sign = sign(steer_angle)
	else:
		steer_sign = 0.0

	# Magnitud del ángulo (evitamos cambios de signo por speed)
	var mag_steer = abs(effective_steer)
	if clamp_effective_steer_to_max_deg:
		var max_steer_rad2 = rad_to_rad(max_steer_deg)
		mag_steer = clamp(mag_steer, 0.0, max_steer_rad2)

	var yaw_rate: float = 0.0
	if force_steer_by_input:
		# magnitud basada en velocidad absoluta; signo basado en steer_angle
		yaw_rate = (abs_speed_for_yaw / wheel_base_px) * tan(mag_steer) * steer_sign
	else:
		# comportamiento físico: velocidad con signo determina la dirección
		var steer_sign_phys = 1.0
		if invert_steer_in_reverse and speed < 0.0:
			steer_sign_phys = -1.0
		yaw_rate = (speed / wheel_base_px) * tan(effective_steer * steer_sign_phys)

	# Aplicar rotación
	rotation += yaw_rate * delta

	# Depuración opcional: imprime valores para verificar signo/comportamiento
	if debug_steer:
		prints("dbg: steer_input=", steer_input,
			   " steer_angle_deg=", rad_to_deg(steer_angle),
			   " speed=", speed,
			   " mag_steer_deg=", rad_to_deg(mag_steer),
			   " steer_sign=", steer_sign,
			   " yaw_rate=", yaw_rate)

	_update_speed_label()
	_update_gear_label()
