extends Node
class_name SchizophreniaComponent
enum{
	HIDDEN = 1,
	VISIBLE = 2,
	HIDDEN_TICK = 4,
	VISIBLE_TICK = 8
}

@warning_ignore("unused_variable")
@export_flags("Hidden", "Visible", "HiddenTick", "VisibleTick")var _when_to_work: int

func on_visible() -> void:
	pass

func on_hidden() -> void:
	pass

func visible_tick(_dt: float) -> void:
	pass

func hidden_tick(_dt: float) -> void:
	pass
