extends RefCounted
class_name StockPrices

var open: float
var high: float
var low: float
var current: float
var close: float


func _init(o: float, h:float,l:float,cur:float,clo:float) -> void:
    open = o
    high = h
    low = l
    current = cur
    close = clo

static func random() -> StockPrices:
    return StockPrices.new(randf_range(100, 200), randf_range(200, 300), randf_range(50, 100), randf_range(100, 200), randf_range(100, 200))