extends Control

var player_name: String = ''
var _uuid: String  


var stocks: Array[Stock] = []
@onready var dd: OptionButton = %'SellOptions'
var owned_stocks: Dictionary = {}:
	get:
		return owned_stocks
	set(val):
		owned_stocks = val
		dd.clear()
		for item in owned_stocks.keys():
			dd.add_item(item)


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
@onready var sab: SearchAndBuy = %"Search And Buy"

var points: Array[float]:
	get: 
		return points
	set(val):
		points = val
		_graph_points()
	

var goal_price_scale: float = 10000

var plot: PlotItem 	

@export var websocket_url = "ws://96.246.209.39:8080"
@export var local = false
@export var local_url = "ws://127.0.0.1:8080"
var socket: WebSocketPeer = WebSocketPeer.new()
var socket_close_send = true
# enum {}

func _randomize():
	for x in range(0,50):
		stocks.push_back(Stock.random())
	_last_month(stocks)
	var names: Array[String] = []
	for stock in stocks:
		names.append(stock.name)
	sab.stock_names = names

	




func _ready() -> void:
	goal_price_scale = (goal_price / stock_chart.y_max) 
	# print(goal_price_scale)
	plot = stock_chart.add_plot_item("Held Value", Color.GREEN, 1.0)
	for x in range(0,stock_chart.x_max+1):
		var y = 0
		points.push_back(y)
	_graph_points()
	sab.search.search.connect(search)
	money = starting_money
	(%ConnectButton as Button).pressed.connect(attempt_connection)
	%SellButton.pressed.connect(sell)

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
	
func search(sname: String):
	for s in stocks:
		if s.name == sname:
			_sab(s)
			return

func _process(delta: float) -> void:
	_poll()


func _poll():
	# print('polling')
	if socket:
		socket.poll()
		# if not _uuid:q
			# socket.send_text("give uuid pls")
		# print('polled')
	
	

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()
	# print('s',state == WebSocketPeer.STATE_CONNECTING," ", state == WebSocketPeer.STATE_OPEN)
	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		socket_close_send = false
		while socket.get_available_packet_count():
			var data =  socket.get_packet().get_string_from_utf8()
			# print("Got data from server: ", data)	
			var dict = JSON.parse_string(data)
			# if dict:
				# print(dict)	
			if dict.has('uuid'):
				_uuid = dict['uuid']
				$Timer.wait_time = 30
				(%UUIDText as LineEdit).text = _uuid
			if dict.has('stocks'):
				# print(dict['stocks'])
				stocks.clear()
				var stock_dict: Dictionary = dict['stocks']
				print(stock_dict[stock_dict.keys()[0]])
				for key in stock_dict.keys():
					var stock = Stock.from_dict(stock_dict[key])
					stocks.append(stock)
				_last_month(stocks)
				var names: Array[String] = []
				for stock in stocks:
					names.append(stock.name)
				sab.stock_names = names
		

	
	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED and not socket_close_send:
		(%ConnectButton as Button).text = "Disconnected"
		socket_close_send = true
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])

func _input(event: InputEvent) -> void:
	if (event is InputEventKey):
		# money += 10
		# _on_poll_recieved(randf_range(-20000,100000))
		pass

func attempt_connection():
	var button: Button = (%ConnectButton as Button)
	var err = socket.connect_to_url(websocket_url if not local else local_url, TLSOptions.client_unsafe())
	button.text = "Please Wait..."
	if err != OK:
		button.text = "Please Retry"
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(5).timeout

		# Send data.
		socket.send_text("Test packet")
		button.text = "Connected"
		_poll()
		var timer: Timer = $Timer
		timer.timeout.connect(_poll)
		timer.start()


func _last_month(s: Array[Stock]):
	(%'Last Month' as LastMonth).display(s)

func _sab(s: Stock):
	sab.display(s)

func _on_stock_bought(s: Stock):
	money -= s.history[0].current
	# socket stuff
	pass

func sell():
	#client prediction
	var stock = dd.get_item_text(dd.selected)
	var count = %"SellCount".text.to_int()
	if count > owned_stocks[stock]:
		count = owned_stocks[stock]
	owned_stocks[stock] -= count
	# socket stuff
	pass

# func _notification(what: int) -> void:
# 	if what == NOTIFICATION_WM_QUIT_REQUEST:
# 		if socket:
# 			socket.close()
	
	