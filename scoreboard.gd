extends VBoxContainer
class_name Scoreboard
func _sort_players(a: Player, b: Player) -> bool:
	return a.net_worth < b.net_worth

func display(players: Array[Player]):
	for child in get_children():
		child.queue_free()
	players.sort_custom(_sort_players)
	for x in range(0, min(10,players.size())):
		var _display: Label = Label.new()
		_display.text = "%s\n%.2f\n%s" % [players[-1*x].Name, players[-1*x].net_worth,players[-1*x].wins]
		_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_display.add_theme_font_size_override("font_size", 12)
		# _display.uppercase = true
		_display.clip_text = true
		# _display.add_theme_font_size_override("font_size", 16)
		add_child(_display)
	

	
