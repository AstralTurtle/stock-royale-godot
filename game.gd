extends Control

var player_name: String = ''

@export var starting_money: float = 10000
var money: float = 10000:
	get:
		return money
	set(val):
		money = val
		_update_player_text()

@export var goal_price: float = 100000
@onready var stock_chart: Graph2D = %StockChart
@onready var pmd = %PlayerMoneyDisplay

var points: Array[float]:
	get: 
		return points
	set(val):
		points = val
		_graph_points()
	

var goal_price_scale: float = 10000

var plot: PlotItem 	



@export var websocket_url = "wss://echo.websocket.org"
var websocket: WebSocketPeer = WebSocketPeer.new()
# enum {}

func _ready() -> void:
	goal_price_scale = (goal_price / stock_chart.y_max) 
	print(goal_price_scale)
	plot = stock_chart.add_plot_item("My Plot", Color.GREEN, 1.0)
	for x in range(0,stock_chart.x_max+1):
		var y = 0
		points.push_back(y)
	_graph_points()
	money = starting_money

func _graph_points():
	plot.remove_all()
	for x in range(0,6):
		plot.add_point(Vector2(x,points[x]/ goal_price_scale))
	plot.color = Color.GREEN if points[points.size()-1] >= points[points.size()-2] else Color.RED

func _update_player_text():
	var text: String = "Current Money = %.2f | To Win = %.2f | Stock Value = %.2f" % [money, goal_price-money, points[points.size()-1]]
	pmd.text = text

func _on_poll_recieved(y):
	points.pop_front()
	points.push_back(y)
	_graph_points()
	
func search():
	pass


func _input(event: InputEvent) -> void:
	if (event is InputEventKey):
		money += 10
		_on_poll_recieved(randf_range(-20000,100000))