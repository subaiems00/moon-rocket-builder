extends Node
## Static catalog of paint colors and decals. Phase 1 — inline only.

class_name CosmeticCatalog

const PAINT_SCRIPT := preload("res://resources/PaintData.gd")

static func all_paints() -> Array[PaintData]:
	var out: Array[PaintData] = []
	out.append(_p(&"paint_white", "Snow", Color(0.97, 0.97, 1.0), Color(0.40, 0.65, 1.0), true))
	out.append(_p(&"paint_coral", "Coral", Color(1.0, 0.55, 0.42), Color(0.97, 0.86, 0.30), true))
	out.append(_p(&"paint_mint", "Mint", Color(0.65, 0.95, 0.78), Color(0.30, 0.55, 0.95), true))
	out.append(_p(&"paint_lavender", "Lavender", Color(0.78, 0.72, 1.0), Color(0.95, 0.42, 0.66), true))
	out.append(_p(&"paint_amber", "Amber", Color(1.0, 0.78, 0.32), Color(0.65, 0.30, 0.95), false))
	out.append(_p(&"paint_rose", "Rose", Color(1.0, 0.74, 0.85), Color(0.95, 0.42, 0.66), false))
	return out


static func _p(id: StringName, name: String, primary: Color, accent: Color, unlocked: bool) -> PaintData:
	var p := PaintData.new()
	p.id = id
	p.display_name = name
	p.primary = primary
	p.accent = accent
	p.unlocked_by_default = unlocked
	return p
