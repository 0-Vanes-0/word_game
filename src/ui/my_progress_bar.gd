class_name MyProgressBar
extends TextureProgressBar

enum Colors {
	NONE, RED, GREEN, BLUE, YELLOW
}


static func create(color: Colors) -> MyProgressBar:
	return MyProgressBar.new(color)


func _init(color: Colors) -> void:
	super()
	self.nine_patch_stretch = true
	self.stretch_margin_top = 6
	self.stretch_margin_right = 6
	self.stretch_margin_bottom = 6
	self.stretch_margin_left = 6
	self.custom_minimum_size = Vector2(70, 14)
	
	self.texture_under = Preloader.texture_under_progress_bar
	self.texture_over = Preloader.texture_over_progress_bar
	match color:
		Colors.RED:
			self.texture_progress = Preloader.texture_red_progress_bar
		Colors.GREEN:
			self.texture_progress = Preloader.texture_green_progress_bar
		Colors.BLUE:
			self.texture_progress = Preloader.texture_blue_progress_bar
		Colors.YELLOW:
			self.texture_progress = Preloader.texture_yellow_progress_bar
