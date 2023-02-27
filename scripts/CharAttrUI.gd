extends TextureRect


# Declare member variables here. Examples:
# var a = 2
var player = null
func setPlayer(k):
	player = k

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("Name").text = player.charname
	var skills = ""
	skills += "UNARMED:     +" + str(int(player.unarmedskill)) + "%\n"
	skills += "WEEB SWORDS: +" + str(int(player.swordskill)) + "%\n"
	skills += "BIGASS AXES: +" + str(int(player.axeskill)) + "%\n"
	skills += "BASEBALL:    +" + str(int(player.rangedskill)) + "%\n"

	get_node("Skills").text = skills
	
	var stats = ""
	stats += "TOUGHNESS " + str(int(player.toughness)) + " (+" + str(player.getMaxHP() - 100) + " HP)\n"
	stats += "RUNNING   " + str(int(player.running)) + " (" + str(player.getRunSpeed()) + " MPH)\n"
	stats += "DODGE     " + str(int(player.dodge)) + " (+" + str(player.getDodgeChance()) + "%)\n"
	stats += "MEDIC     " + str(int(player.medic)) + " (+" + str(player.getMedicBonus()) + "%)\n"
	
	get_node("Stats").text = stats
