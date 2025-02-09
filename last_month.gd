extends Container
class_name  LastMonth
func display(stocks: Array[Stock]):
	for child: Node in get_children():
		child.queue_free()
	var s = stocks
	s.sort_custom(func(a,b): return a.name < b.name)

	for stock: Stock in stocks:
		var _display: Label = Label.new()
		_display.text = "%s | %.2f" % [stock.name,stock.history[0].current]
		_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_display.add_theme_font_size_override("font_size", 16)
		_display.uppercase = true
		_display.clip_text = true
		if (stock.history.size() > 1):
			_display.add_theme_color_override("font_color", Color.GREEN if stock.history[-1].current > stock.history[-2].current else Color.RED)
		else:
			_display.add_theme_color_override("font_color", Color.WHITE)
		add_child(_display)
		
