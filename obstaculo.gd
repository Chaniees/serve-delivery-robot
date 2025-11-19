extends Node2D

@export var size: Vector2 = Vector2(64, 64)            # usado si la CollisionShape es RectangleShape2D
@export var radius: float = 32.0                       # usado si la CollisionShape es CircleShape2D
@export var sprite_texture: Texture2D = null           # asigna desde el Inspector
@export var collision_layer_bits: int = 1              # capa (1 = layer 1)
@export var collision_mask_bits: int = 1               # máscara (qué colisiones "ve")
@export var add_to_group_name: String = "obstacle"     # grupo para identificar obstáculos
# ----------------------------------------
#FUNCION PARA OBSTACULOS
# ----------------------------------------
func _ready() -> void:
	if add_to_group_name != "":
		add_to_group(add_to_group_name)
	var cs = $CollisionShape2D if has_node("CollisionShape2D") else null
	if cs:
		var sh = cs.shape
		if sh is RectangleShape2D:
			sh.extents = size * 0.5
		elif sh is CircleShape2D:
			sh.radius = radius
	if has_node("Sprite2D") and sprite_texture:
		$Sprite2D.texture = sprite_texture
