class_name TokenLabel
extends IconLabel

var token: Token
var amount: int = 0
var duration: int = 0


static func create() -> TokenLabel:
	var t_label := super()
	t_label.set_script(preload("res://src/ui/token_label.gd"))
	return t_label as TokenLabel


func update_info():
	self.set_icon(token.icon_texture, IconLabel.Sizes.x24)
	self.set_text(str(amount) + "(" + str(duration) + ")")
