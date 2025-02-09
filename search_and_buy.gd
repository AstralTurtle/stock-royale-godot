extends HBoxContainer
class_name SearchAndBuy
@onready var stock_chart: Graph2D = $Graph2D
var plot: PlotItem 	

@onready var search: StockSearch = $VBoxContainer/StockSearch
@onready var count: LineEdit = %"StockCount"
@onready var buy_button: Button = %"BuyButton"

@export var stock_names: Array[String] = []:
	get:
		return stock_names
	set(val):
		search.all_items = val

@onready var data_display: Container = $VBoxContainer/HFlowContainer

func _ready() -> void:
	plot = stock_chart.add_plot_item("A", Color.GREEN, 1.0)


func display(s: Stock):
	_graph_points(s)
	_show_data(s)

func _show_data(s: Stock):
	for child in data_display.get_children():
		child.queue_free()
	var prices: StockPrices = s.history[0]
	var name: Label = Label.new()
	name.text = s.name.to_upper()
	data_display.add_child(name)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.size_flags_vertical = Control.SIZE_EXPAND_FILL
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var current: Label = Label.new()
	current.text = "Price: %.2f" % [prices.current]
	data_display.add_child(current)
	current.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	current.size_flags_vertical = Control.SIZE_EXPAND_FILL
	current.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var high: Label = Label.new()
	high.text = "High: %.2f" % [prices.high]
	data_display.add_child(high)
	high.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	high.size_flags_vertical = Control.SIZE_EXPAND_FILL
	high.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var low: Label = Label.new()
	low.text = "Low: %.2f" % [prices.low]
	data_display.add_child(low)
	low.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	low.size_flags_vertical = Control.SIZE_EXPAND_FILL
	low.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var open: Label = Label.new()
	open.text = "Open: %.2f" % [prices.open]
	data_display.add_child(open)
	open.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	open.size_flags_vertical = Control.SIZE_EXPAND_FILL
	open.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var close: Label = Label.new()
	close.text = "Close: %.2f" % [prices.close]
	data_display.add_child(close)
	close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close.size_flags_vertical = Control.SIZE_EXPAND_FILL
	close.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER



	

func _graph_points(s: Stock):
	plot.remove_all()

	var sixmonthhigh = -1
	var sixmonthlow  = 100000
	for x in range(0,s.history.size()):	
		if s.history[x].high > sixmonthhigh:
			sixmonthhigh = s.history[x].high
		if s.history[x].low < sixmonthlow:
			sixmonthlow = s.history[x].low

	
	stock_chart.y_max = (sixmonthhigh * 1.1)
	stock_chart.y_min = (sixmonthlow * 0.9)
	var points: Array[float] = []

	for x in range(6,-2,-1):
		# print(x, s.history.size())
		if x < 0: continue
		if x > s.history.size() -1: continue
		# else:
			# print(s.history[x].current)
		points.push_back(s.history[x*-1].current)
	print(points)
	for x in range(0,points.size()):
		print(x," ", points[x])
		plot.add_point(Vector2(x,points[x]))
	if points.size() > 1:
		plot.color = Color.GREEN if points[points.size()-1] >= points[points.size()-2] else Color.RED
	else:
		plot.color = Color.GREEN
	