class_name MyProgressBar
extends TextureProgressBar

enum Colors {
	NONE, RED, GREEN, BLUE, YELLOW
}
enum ValueDisplayType {
	NONE, PERCENTAGE_INT, FRACTION
}
@export_group("Color")
@export var color_from_editor: Colors = Colors.NONE
@export var value_display_type: ValueDisplayType = ValueDisplayType.NONE
@export_group("Children")
@export var label: Label
var is_setup: bool = false


static func create(color: Colors, display := ValueDisplayType.NONE) -> MyProgressBar:
	var node := Preloader.my_progress_bar.instantiate() as MyProgressBar
	return node.setup(color, display)


func setup(color: Colors, display: ValueDisplayType) -> MyProgressBar:
	match color:
		Colors.RED:
			self.texture_progress = Preloader.texture_red_progress_bar
		Colors.GREEN:
			self.texture_progress = Preloader.texture_green_progress_bar
		Colors.BLUE:
			self.texture_progress = Preloader.texture_blue_progress_bar
		Colors.YELLOW:
			self.texture_progress = Preloader.texture_yellow_progress_bar
	
	if display == ValueDisplayType.NONE:
		label.hide()
	
	is_setup = true
	return self


func _ready() -> void:
	if not is_setup:
		setup(color_from_editor, value_display_type)


func set_bar_value(value: float):
	self.value = value
	if label.visible:
		match value_display_type:
			ValueDisplayType.PERCENTAGE_INT:
				label.text = str(roundi(value / max_value * 100.0)) + "%"
			ValueDisplayType.FRACTION:
				label.text = str(int(value)) + "/" + str(int(self.max_value))
