var itemname = "Item"
var price = 1
var type = "r"
var rnge = 1
var damage = 10
var cooldown = 2
var shiny = 0

# h helmet
# a armor
# r ranged
# m medical
# f food
# l long
# s short

func serialize():
	return {
		"itemname": itemname,
		"price": price,
		"type": type,
		"rnge": rnge,
		"damage": damage,
		"cooldown": cooldown,
		"shiny": shiny,
	}

func deserialize(data):
	itemname = data["itemname"]
	price = data["price"]
	type = data["type"]
	rnge = data["rnge"]
	damage = data["damage"]
	cooldown = data["cooldown"]
	shiny = data["shiny"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
