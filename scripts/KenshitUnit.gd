extends Spatial

onready var floater = preload("res://Floater.tscn")

var dodge = 1
var toughness = 1
var faction = "player"

# 1 puts you on heal = 0
# If you get hit with 1 HP: dead
var head_hp = 100
var belly_hp = 100
var larm_hp = 100
var rarm_hp = 100
var lleg_hp = 100
var rleg_hp = 100
var hanger = 100

var ko_time = 0

var selected = false

var HANGER_RATE = .04
var KO_MAX = 60
var TOUGHNESS_GROWTH_RATE = 0.1

# shitty hack but usually null for animals
var armorItem = null
var headItem = null

var attackTarget = null

# from 1 to 100
# bullshit math function, since dodging is how you train dodge.
# early levels scale quick, later levels scale late.
func getDodgeChance():
	return int(1.0 + ((-(500.0/(dodge+20.0)) + 25.0)/100.0))

func putFloater(t,c):
	var f = floater.instance()
	f.text = t
	f.basecol = c
	f.point = global_transform.origin  + Vector3(0,2,0)
	add_child(f)

func ko():
	ko_time = KO_MAX
	emptyInv()
	
func putOnGround():
	var space_state = get_world().direct_space_state
	var hit = space_state.intersect_ray(translation + Vector3(0,50,0), translation + Vector3(0,-100,0), [])
	if  hit.empty():
		translation += Vector3(0,50,0)
	else:
		translation = hit.values()[0]
		
	if(lleg_hp == 0 and rleg_hp == 0 and belly_hp > 1 and head_hp > 1):
		translation -= Vector3(0,0.5,0)

#abstract
func emptyInv():
	pass

func playDeadFX():
	get_node("Sounds/dead" + str(1 + (randi() % 4))).play()

func kill():
	# empty inv.
	emptyInv()

func tryAttack(amt):
	amt = int(rand_range(amt * 0.6,amt * 1.4))
	
	var goodcolor = Color(0,0.5,0)
	var badcolor = Color(1,0,0)
	if(faction != "player"):
		goodcolor = Color(1,0,0)
		badcolor = Color(0,0.5,0)
		
		
	if(getDodgeChance() > rand_range(0,100)):
		dodge += 1
		putFloater("DODGE!", goodcolor)
		return
		
	toughness += TOUGHNESS_GROWTH_RATE
	#Try to hit a limb (15% * 4)
	var limbtry = int(rand_range(0,6))
	if(limbtry == 0):
		
		if(armorItem != null and armorItem.damage > 2 * rand_range(0,100)):
			putFloater("HIT ARMOR!", goodcolor)
			return

		if(larm_hp == 1):
			larm_hp = 0
			putFloater("MY ARM!", badcolor)
			return
		elif(larm_hp > 0):
			larm_hp -= amt
			larm_hp = max(1,larm_hp)
			putFloater(str(amt), badcolor)
			return

	if(limbtry == 1):
		
		if(armorItem != null and armorItem.damage  > 2 * rand_range(0,100)):
			putFloater("HIT ARMOR!", goodcolor)
			return
			
		if(rarm_hp == 1):
			rarm_hp = 0
			putFloater("MY ARM!", badcolor)
			return
		elif(rarm_hp > 0):
			rarm_hp -= amt
			rarm_hp = max(1,rarm_hp)
			putFloater(str(amt), badcolor)
			return

	if(limbtry == 2):
		
		if(armorItem != null and armorItem.damage > 2 * rand_range(0,100)):
			putFloater("HIT ARMOR!", goodcolor)
			return
			
		if(lleg_hp == 1):
			putFloater("MY LEG!", badcolor)
			lleg_hp = 0
			return
		elif(lleg_hp > 0):
			lleg_hp -= amt
			lleg_hp = max(1,lleg_hp)
			putFloater(str(amt), badcolor)
			return

	if(limbtry == 3):
		
		if(armorItem != null and armorItem.damage  > 2 * rand_range(0,100)):
			putFloater("HIT ARMOR!", goodcolor)
			return
			
		if(rleg_hp == 1):
			rleg_hp = 0
			putFloater("MY LEG!", badcolor)
			return
		elif(rleg_hp > 0):
			rleg_hp -= amt
			rleg_hp = max(1,rleg_hp)
			putFloater(str(amt), badcolor)
			return
			
	#Try to hit a body
	var bodytry = int(rand_range(0,2))
	
	if(bodytry == 0):

		if(armorItem != null and armorItem.damage > rand_range(0,100)):
			putFloater("HIT ARMOR!", goodcolor)
			return

		if(belly_hp <= 2):
			belly_hp = 0
			putFloater("DED!", badcolor)
			playDeadFX()
			kill()
		else:
			belly_hp -= amt
			belly_hp = max(1,belly_hp)
			putFloater(str(amt), badcolor)
			if(belly_hp == 1):
				playDeadFX()
				ko()
			
	if(bodytry == 1):
		
		if(headItem != null and headItem.damage > rand_range(0,100)):
			putFloater("HIT HELMET!", goodcolor)
			return
			
		if(head_hp <= 2):
			putFloater("DED!", badcolor)
			playDeadFX()
			head_hp = 0
			kill()
		else:
			head_hp -= amt
			head_hp = max(1,head_hp)
			putFloater(str(amt), badcolor)
			if(head_hp == 1):
				playDeadFX()
				ko()
				


func serialize(x,z):
	var dat = {}
	dat["faction"] = faction	
	dat["x"] = x
	dat["z"] = z
	
	dat["head_hp"] = head_hp
	dat["belly_hp"] = belly_hp
	dat["larm_hp"] = larm_hp
	dat["rarm_hp"] = rarm_hp
	dat["lleg_hp"] = lleg_hp
	dat["rleg_hp"] = rleg_hp
	dat["hanger"] = hanger

	return dat
	
func deserialize(dat):
	faction = dat["faction"]
	

	if(dat.get("head_hp")):
		head_hp = dat["head_hp"] 
		belly_hp = dat["belly_hp"] 
		larm_hp = dat["larm_hp"] 
		rarm_hp = dat["rarm_hp"] 
		lleg_hp = dat["lleg_hp"] 
		rleg_hp = dat["rleg_hp"] 
		hanger = dat["hanger"] 
	
	return dat
