extends Control

var player_name: String:
	get:
		return player_name
	set(val):
		player_name = val
		(%PlayerName as Label).text = val
var _uuid: String  

enum RequestType {
	Buy,
	Sell,
	Win
}

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


@export var starting_money:float
var money: float = 10000:
	get:
		return money
	set(val):
		money = val
		_update_player_text()

@export var goal_price: float
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

@export var websocket_url: String #"ws://96.246.209.39:8080"
@export var local = false
@export var local_url: String
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
	sab.buy_button.pressed.connect(_on_stock_bought)
	money = starting_money
	(%ConnectButton as Button).pressed.connect(attempt_connection)
	%SellButton.pressed.connect(sell)
	# print(websocket_url,local_url)
	# print(socket.supported_protocols)

	

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
	# print('polling')
	if socket:
		socket.poll()
		# print(socket.get_selected_protocol())
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
			if dict:
				if dict.has('uuid'):
					# print(dict)
					_uuid = dict['uuid']
					player_name = dict['username']
					$Timer.wait_time = 30
					(%UUIDText as LineEdit).text = _uuid
				if dict.has('stocks'):
					# print(dict['stocks'])
					stocks.clear()
					var stock_dict: Dictionary = dict['stocks']
					# print(stock_dict[stock_dict.keys()[0]])
					for key in stock_dict.keys():
						var stock = Stock.from_dict(stock_dict[key])
						stocks.append(stock)
					_last_month(stocks)
					var names: Array[String] = []
					for stock in stocks:
						names.append(stock.name)
					sab.stock_names = names
				if dict.has('news'):
					var newscontainer: Container = %"News"
					for child in newscontainer.get_children():
						child.queue_free()
					for news in dict['news']:
						var label: Label = Label.new()
						label.text = "%s\n%s" % [news['headline'],news['stocks_affected']]
						newscontainer.add_child(label)
						label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						label.size_flags_vertical = Control.SIZE_EXPAND_FILL
						label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
						label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
						label.clip_text = true
						label.add_theme_font_size_override("font_size", 24)


				if dict.has("users"):
					var users = dict['users']
					var players: Array[Player] = []
					for user in users:
						if user['username'] == player_name:
							money = user['cash']
							for stock in user['portfolio']:
								owned_stocks[stock] = user['portfolio'][stock]
							var i = dd.selected
							owned_stocks = owned_stocks
							dd.selected = i
							_on_poll_recieved(user['net_worth'] - user['cash'])
						# print(user)
						players.append(Player.from_dict(user))
					var sb:Scoreboard = %"Scoreboard"
					sb.display(players)
				
		
	
	
	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED and not socket_close_send:
		(%ConnectButton as Button).text = "Disconnected"
		socket_close_send = true
		var data =  socket.get_packet()
		print("Got error_string from server: ", data)	
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		print("Reason: %s" % socket.get_close_reason())
		# set_process(false)
		if code == -1:
				print("Unclean disconnection detected. Attempting to reconnect...")
				attempt_connection()

func attempt_connection():
	var button: Button = (%ConnectButton as Button)
	var err = socket.connect_to_url(local_url if local else websocket_url)
	button.text = "Please Wait..."
	if err != OK:
		button.text = "Please Retry"
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout

		# Send data.
		socket.send_text(JSON.stringify({"uuid":(%UUIDText as LineEdit).text}))
		button.text = "Connected"
		# var timer: Timer = $Timer
		# timer.timeout.connect(_poll)
		# timer.start()


func _last_month(s: Array[Stock]):
	(%'Last Month' as LastMonth).display(s)

func _sab(s: Stock):
	sab.display(s)

func _on_stock_bought():
	var request = {"type":RequestType.Buy,"stock":sab.search.line_edit.text,"shares":sab.count.text.to_int(),"uuid":_uuid}
	socket.send_text(JSON.stringify(request))
	pass

func sell():
	#client prediction
	var stock = dd.get_item_text(dd.selected)
	var count = %"SellCount".text.to_int()
	# socket stuff
	var request = {"type":RequestType.Sell,"stock":stock,"shares":count,"uuid":_uuid}
	socket.send_text(JSON.stringify(request))
	pass

# func _notification(what: int) -> void:
# 	if what == NOTIFICATION_WM_QUIT_REQUEST:
# 		if socket:
# 			socket.close()
	
	
