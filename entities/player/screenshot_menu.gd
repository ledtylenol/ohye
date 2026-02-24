extends Control
class_name ScreenshotMenu

@export var player: Player
var active := false:
	set(v):
		if Global.current_menu and Global.current_menu != self:
			return
		active = v
		visible = v
		Global.current_menu = self if v else null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("screenshot_open") and event.is_pressed() and player and player.active:
		active = not active
	
