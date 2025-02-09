extends Control
class_name  StockSearch
# Nodes
var line_edit: LineEdit
var popup_menu: PopupMenu

signal search(stock: String)


# List of dropdown options
var all_items = ["Apple", "Banana", "Orange", "Grapes", "Pineapple", "Strawberry"]

func _ready():
    # Get nodes
    line_edit = $LineEdit
    popup_menu = $LineEdit/PopupMenu

    # Populate PopupMenu with all items initially
    update_popup_menu(all_items)
    
    # Connect signals
    line_edit.text_changed.connect(_on_text_changed)
    popup_menu.id_pressed.connect(_on_item_selected)

    # Ensure popup_menu is hidden initially
    popup_menu.hide()

# Called when the text in LineEdit changes
func _on_text_changed(new_text):
    print(all_items)
    # Filter items based on search text
    var filtered_items = []
    for item in all_items:
        if item.to_lower().find(new_text.to_lower()) != -1:
            filtered_items.append(item)
    
    # Update PopupMenu with filtered items
    update_popup_menu(filtered_items)
    
    # Show the PopupMenu if there are any matching items
    if filtered_items.size() > 0:
        var new_position = line_edit.get_global_position() + Vector2(0, line_edit.size.y)
        popup_menu.set_position(new_position)
        popup_menu.show()
        popup_menu.popup()
    else:
        popup_menu.hide()
    line_edit.call_deferred(grab_focus.get_method())

# Update the PopupMenu with given items
func update_popup_menu(items: Array):
    popup_menu.clear()  # Clear existing items
    for i in range(items.size()):
        popup_menu.add_item(items[i], i)  # Add new item

# Handle selection from PopupMenu
func _on_item_selected(index):
    line_edit.text = popup_menu.get_item_text(index)  # Set selected text
    search.emit(popup_menu.get_item_text(index))  # Emit signal with selected text
    popup_menu.hide()  # Hide popup after selection
