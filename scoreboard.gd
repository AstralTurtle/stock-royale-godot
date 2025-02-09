extends VBoxContainer

func _sort_players(a: Player, b: Player) -> bool:
    return a.net_worth < b.net_worth

func display(players: Array[Player]):
    for child in get_children():
        child.queue_free()
    players.sort_custom(_sort_players)
    for player in players:
        var _display: Label = Label.new()
        _display.text = "%s | %.2f" % [player.Name, player.net_worth]
        _display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _display.size_flags_vertical = Control.SIZE_EXPAND_FILL
        _display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        _display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        _display.add_theme_font_size_override("font_size", 16)
        _display.uppercase = true
        _display.clip_text = true
        add_child(_display)
    

    