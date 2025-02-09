extends RefCounted
class_name Stock

var name: String
var previousClose: float
var history: Array[StockPrices]

func _init(s: String, previous: float, hist: Array[StockPrices]) -> void:
	name = s
	previousClose = previous
	history = hist

static func random() -> Stock:
	var characters = 'abcdefghijklmnopqrstuvwxyz'
	var history: Array[StockPrices] = []
	for x in range(0, 30):
		history.push_back(StockPrices.random())
	return Stock.new(generate_word(characters,5), randf_range(100, 200), history)




static func generate_word(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi() % n_char]
	return word.to_upper()

static func from_dict(dict: Dictionary) -> Stock:
	var history: Array[StockPrices] = []
	for item in dict["history"]:
		history.push_back(StockPrices.from_dict(item))
	return Stock.new(dict["name"], dict["previousClose"], history)
