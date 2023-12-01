class_name MyProgressBar
extends TextureProgressBar

enum Colors {
	NONE, RED, GREEN, BLUE, YELLOW
}
@export_group("Color")
@export var color_from_editor: Colors = Colors.NONE
var is_setup: bool = false


static func create(color: Colors) -> MyProgressBar:
	var node := Preloader.my_progress_bar.instantiate() as MyProgressBar
	return node.setup(color)


func setup(color: Colors) -> MyProgressBar:
	match color:
		Colors.RED:
			self.texture_progress = Preloader.texture_red_progress_bar
		Colors.GREEN:
			self.texture_progress = Preloader.texture_green_progress_bar
		Colors.BLUE:
			self.texture_progress = Preloader.texture_blue_progress_bar
		Colors.YELLOW:
			self.texture_progress = Preloader.texture_yellow_progress_bar
	is_setup = true
	return self


func _ready() -> void:
	if not is_setup:
		setup(color_from_editor)
