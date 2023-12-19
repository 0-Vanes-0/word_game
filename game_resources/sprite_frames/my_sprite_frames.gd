class_name MySpriteFrames
extends SpriteFrames

@export var offset: Vector2
@export_group("Separate offsets")
@export var separate_offsets: Dictionary = {} # String: Vector2


func get_placeholder_texture() -> Texture2D:
	return get_frame_texture("idle", 0)
