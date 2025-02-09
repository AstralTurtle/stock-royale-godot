extends RefCounted

class_name Player

var Name: String
var money: float
var net_worth: float
var wins: int

func _init(n: String, m: float, nw: float, w: int) -> void:
    Name = n
    money = m
    net_worth = nw
    wins = w

static func from_dict(dict: Dictionary) -> Player:
    return Player.new(dict["username"], dict["cash"], dict["net_worth"], dict["wins"])
 
 