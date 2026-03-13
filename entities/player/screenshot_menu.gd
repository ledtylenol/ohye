extends Control
class_name ScreenshotMenu
@export var color_rect: ColorRect 
@export var ss_tool: ScreenshotTool
@export var player: Player
@export var snap: FmodEventEmitter3D

var value := 0.0:
	set(v):
		if color_rect:
			color_rect.set_instance_shader_parameter("threshold", v)
			print(v)
		value = v
var tween: Tween
var active := false:
	set(v):
		if Global.current_menu and Global.current_menu != self:
			return
		active = v
		tween_active(v)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("screenshot_open") and event.is_pressed() and player and player.active and not active:
		active = true
	

func tween_active(v: bool) -> void:
	if tween: tween.kill()
	tween = create_tween()
	if v:
		snap.play()
		visible = true
		ss_tool.take_screenshot("./")
		tween.tween_property(self, "value", 1.0, Global.game_settings.transition_secs ).from(0.0)
		tween.tween_callback(set.bind("active", false))
