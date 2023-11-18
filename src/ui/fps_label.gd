class_name FPSLabel
extends Label


func _ready() -> void:
	self.label_settings = LabelSettings.new()
	self.label_settings.font_size = 36


func _process(delta: float) -> void:
	self.text = str(Engine.get_frames_per_second())
