extends Control
## Workshop: 3D rocket preview on the right, part picker on the left,
## stat bars across the bottom, Launch button at the bottom-right.

const RocketPartData = preload("res://resources/RocketPartData.gd")
const PartCatalog = preload("res://resources/PartCatalog.gd")
const CosmeticCatalog = preload("res://resources/CosmeticCatalog.gd")
const RocketBuilder = preload("res://scripts/RocketBuilder.gd")

@onready var _3d_viewport: SubViewport = $Root/PreviewColumn/PreviewPanel/SubViewportContainer/SubViewport
@onready var _category_tabs: HBoxContainer = $Root/PartColumn/CategoryTabs
@onready var _part_grid: GridContainer = $Root/PartColumn/PartGrid
@onready var _stat_panel: VBoxContainer = $Root/StatsColumn
@onready var _launch_button: Button = $Root/PreviewColumn/LaunchBar/LaunchButton
@onready var _back_button: Button = $Root/TopBar/BackButton
@onready var _paint_row: HBoxContainer = $Root/PartColumn/PaintRow

var _builder: RocketBuilder
var _current_slot: int = RocketPartData.Slot.BODY
var _current_paint = null


func _ready() -> void:
	_builder = _3d_viewport.get_node_or_null("World/Rocket")
	_back_button.pressed.connect(_on_back)
	_launch_button.pressed.connect(_on_launch)
	# Build category tabs.
	for slot_name: String in ["Nose", "Body", "Tank", "Engine", "Fin", "Booster"]:
		var slot_id: int = RocketPartData.Slot[slot_name.to_upper()]
		var btn := Button.new()
		btn.text = slot_name
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_category.bind(slot_id))
		_category_tabs.add_child(btn)
	# Initial tab.
	var first_btn: Button = _category_tabs.get_child(0)
	first_btn.button_pressed = true
	# Paint swatches.
	for paint in CosmeticCatalog.all_paints():
		var swatch := Button.new()
		swatch.custom_minimum_size = Vector2(40, 40)
		var style := StyleBoxFlat.new()
		style.bg_color = paint.primary
		style.set_corner_radius_all(20)
		swatch.add_theme_stylebox_override("normal", style)
		swatch.pressed.connect(_on_paint.bind(paint))
		_paint_row.add_child(swatch)
	# Build a default rocket so we always see something.
	_install_default_rocket()
	_refresh_parts()
	_refresh_stats()
	_builder.rocket_rebuilt.connect(_refresh_stats)


func _install_default_rocket() -> void:
	if GameManager.coins < 0:
		return
	_builder.install_part(RocketPartData.Slot.NOSE, PartCatalog._nose_classic())
	_builder.install_part(RocketPartData.Slot.BODY, PartCatalog._body_classic())
	_builder.install_part(RocketPartData.Slot.TANK, PartCatalog._tank_basic())
	_builder.install_part(RocketPartData.Slot.ENGINE, PartCatalog._engine_standard())
	_builder.install_part(RocketPartData.Slot.FIN, PartCatalog._fin_tri())
	_builder.install_part(RocketPartData.Slot.FIN, PartCatalog._fin_tri())
	_builder.install_part(RocketPartData.Slot.FIN, PartCatalog._fin_tri())
	_builder.install_part(RocketPartData.Slot.FIN, PartCatalog._fin_tri())


func _on_category(slot: int) -> void:
	_current_slot = slot
	_refresh_parts()


func _refresh_parts() -> void:
	for child in _part_grid.get_children():
		child.queue_free()
	var parts := PartCatalog.by_slot(_current_slot)
	for part in parts:
		var card := Button.new()
		card.custom_minimum_size = Vector2(96, 96)
		card.text = part.display_name
		card.tooltip_text = "%s\nThrust %.0f\nFuel %.0f\nWeight %.0f\nStability %.2f" % [
			part.display_name, part.thrust, part.fuel, part.weight, part.stability]
		var unlocked := GameManager.is_part_unlocked(part.id)
		if not unlocked:
			card.text = part.display_name + "\n🔒"
			card.disabled = true
			card.modulate = Color(0.6, 0.6, 0.7, 0.6)
		card.pressed.connect(_on_select_part.bind(part))
		_part_grid.add_child(card)


func _on_select_part(part: RocketPartData) -> void:
	_builder.install_part(_current_slot, part)
	AudioManager.play_sfx("part_attach")
	_refresh_stats()


func _on_paint(paint) -> void:
	_current_paint = paint
	_builder.apply_paint(paint)
	AudioManager.play_sfx("ui_click")


func _refresh_stats(_payload = null) -> void:
	var stats := _builder.aggregated_stats()
	for child in _stat_panel.get_children():
		child.queue_free()
	_add_stat("Thrust", stats.thrust, 1000.0)
	_add_stat("Fuel", stats.fuel, 400.0)
	_add_stat("Weight", stats.weight, 50.0, true)
	_add_stat("Stability", stats.stability, 4.0)
	_add_stat("Efficiency", stats.efficiency, 1.0)


func _add_stat(label: String, value: float, max_value: float, inverse: bool = false) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var lbl := Label.new()
	lbl.text = label
	lbl.custom_minimum_size = Vector2(90, 0)
	row.add_child(lbl)
	var bar = preload("res://scripts/ui/StatBar.gd").new()
	var percent := value / max_value
	if inverse:
		percent = clamp(1.0 - percent * 0.5, 0.0, 1.0)
	bar.set_value_colored(percent)
	row.add_child(bar)
	var val_lbl := Label.new()
	val_lbl.text = "%d" % int(value)
	val_lbl.custom_minimum_size = Vector2(40, 0)
	row.add_child(val_lbl)
	_stat_panel.add_child(row)


func _on_launch() -> void:
	UIManager.goto_scene("res://scenes/LaunchPad.tscn")


func _on_back() -> void:
	UIManager.goto_scene("res://scenes/MainMenu.tscn")
