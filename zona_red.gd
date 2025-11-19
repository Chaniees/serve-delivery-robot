extends Node2D

# Script sencillo para un obstáculo estático.
# Requisitos en la escena:
# - Nodo root: StaticBody2D (añade este script)
# - Hijo: CollisionShape2D (con RectangleShape2D o CircleShape2D)
# - Hijo opcional: Sprite2D (para la imagen)

@export var size: Vector2 = Vector2(64, 64)            # usado si la CollisionShape es RectangleShape2D
@export var radius: float = 32.0                       # usado si la CollisionShape es CircleShape2D
@export var sprite_texture: Texture2D = null           # asigna desde el Inspector
@export var collision_layer_bits: int = 1              # capa (1 = layer 1)
@export var collision_mask_bits: int = 1               # máscara (qué colisiones "ve")
@export var add_to_group_name: String = "obstacle"     # grupo para identificar obstáculos

func _ready() -> void:
	# Añadir al grupo para que puedas identificarlo desde código
	if add_to_group_name != "":
		add_to_group(add_to_group_name)



	# Configurar CollisionShape2D si existe y su tipo
	var cs = $CollisionShape2D if has_node("CollisionShape2D") else null
	if cs:
		var sh = cs.shape
		if sh is RectangleShape2D:
			sh.extents = size * 0.5
		elif sh is CircleShape2D:
			sh.radius = radius
		# Si quieres otra shape, configúrala en editor o aquí por código

	# Poner textura al Sprite2D si existe y se asignó
	if has_node("Sprite2D") and sprite_texture:
		$Sprite2D.texture = sprite_texture

	# Opcional: puedes fijar un CollisionLayer/Mask por nombre en lugar de número si prefieres
	# (aquí usamos bits enteros directos).
