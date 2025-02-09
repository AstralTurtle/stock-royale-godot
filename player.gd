extends RefCounted

class_name Player

var Name: String
var money: float
var net_worth: float

func _init(n: String, m: float, nw: float) -> void:
    Name = n
    money = m
    net_worth = nw