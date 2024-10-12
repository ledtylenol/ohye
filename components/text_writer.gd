extends AudioStreamPlayer3D
class_name TextWriter3D

@export_multiline var texts: Array[String]
@export var interact_c: InteractComponent
var text_nodes: Array[PosLabel3D]
var active := false:
	set(value):
		if not value and active: 
			active = value
			for node in text_nodes:
				if node != null: await node.delete()
			text_nodes.clear()
		active = value
var current := 0
var t := 0.0
var timer := 0.0:
	set(value):
		if value <= 0.0 and active:
			active = false
		elif value > 0.0:
			active = true
		timer = value
func _ready() -> void:
	interact_c.interact_end.connect(play_line)
func play_line() -> void:
	current += 1
	current = current % texts.size()
	var locked_current = current

	timer = 0
	for node in text_nodes:
		if node != null: await node.delete()
	text_nodes.clear()
	var j := 0
	var i := 0
	var sep_count := 0
	
	for lx in texts[current].length():
		if locked_current != current:
			return
		i += 1
		if lx >= texts[current].length() - 1:
			break
		if ['.', ',', '?'].has(texts[current][lx]) and not ['.', ',', '?'].has(texts[current][lx + 1]):
			sep_count += 1
			i = 0
		if texts[current][lx] == ' ' and i > 10:
			sep_count += 1
	i = 0
	var offset = -texts[current].length() / sep_count
	for lx in texts[current].length():
		if locked_current != current:
			return
		var l := texts[current][lx]
		var t := PosLabel3D.new()
		t.alpha_cut = Label3D.ALPHA_CUT_OPAQUE_PREPASS
		t.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		t.text = l
		t.font_size = 1500
		t.pixel_size = 0.001

		t.position = offset * global_basis.z + i  * global_basis.z - j * 1.5  * global_basis.y + global_basis.y * sep_count
		add_child(t)
		text_nodes.push_back(t)
		play()
		i += 1
		if ['.', ',', '?'].has(texts[current][lx]) and lx < texts[current].length() - 1 and not ['.', ',', '?'].has(texts[current][lx + 1]):
			j += 1
			i = 0
		elif l == ' ' and i > 10:
			j += 1
			i = 0
		await t.start()
	timer = 5.0
	
func _process(delta: float) -> void:
	t += delta
	timer -= delta
	timer = maxf(0.0, timer)
	for i in text_nodes.size():
		var text := text_nodes[i]
		if not text or not text.active:
			continue
		text.position = text.initial_pos + global_basis.z * sin(t + i * PI) / 10 + global_basis.y * cos(i * PI + t / 2.0) / 10
