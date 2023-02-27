extends "res://scripts/KenshitUnit.gd"

onready var KenshitItem = preload("res://scripts/KenshitItem.gd")

onready var Hireable = preload("res://misc/RoleHireable.tscn")
onready var ShopKeep = preload("res://misc/RoleShopkeep.tscn")

#??
var player_anim_down = false

# Skills, SAVE THESE
var running = 1
var medic = 1

var swordskill = 1
var axeskill = 1
var rangedskill = 1
var unarmedskill = 1

var heldItem = null

var invItems = []

var charname = ""
var basemodel = ""

var ai_quest_loc = null
var consider_quest_time = 0

# OTHER SHIT.

var QUEST_ACCEPT_CHANCE = 0.1

var BASICALLY_AT_QUEST = rand_range(10,20)

var attackCoolDown = 0

var DISABLE_DIST = 500

var role = ""


var behavior = "PASSIVE"
# PASSIVE, HOLD, REACT, KILL, MEDIC

# default action : chillin
# action : sleepin: head or belly = 0

# Either I want to interact with this
var interactTarget = null

# Or I want to move here
var moveDestination = null


# CONSTS
var BASICALLY_AT_DEST = 0.9
var PERSONAL_SPACE = 0.85
var PICKUP_DEST = 3

var PUNCH_RANGE = 1
var PUNCH_DAMAGE = 10
var PUNCH_COOLDOWN = 1
var TOUGHNESS_HP_BONUS = 3

var SWORD_GROW_RATE = 0.3
var AXE_GROW_RATE = 0.3
var UNARMED_GROW_RATE = 0.7
var RANGED_GROW_RATE = 0.5

var RUN_GROW_RATE = 0.01

var WIGGLE_VEL = 5

var styletemp = null

func getAction():
	if(charIsDead()):
		return "d e d"


	if(charIsKOd()):
		return "unconscious (" + str(int(ko_time)) + ")"
	if (moveDestination != null):
		return "runnin"
	if (attackTarget != null):
		if(heldItem == null):
			return "punchin"
		if(heldItem.type == "r"):
			return "shootin"
		return "fightin"
	return "chillin"

func getMaxHP():
	return 97 + (int(toughness) * TOUGHNESS_HP_BONUS)
	
func getRunSpeed():
	var base = 100.0 * (3.0 + ((running-1) / 30.0))
	if(lleg_hp == 0 and rleg_hp == 0):
		base = base / 2.0
	elif(lleg_hp == 0 or rleg_hp ==0):
		base = base * 0.85
	# base is a 450
	return int(base) / 100.0
	
func getMedicBonus():
	return (medic - 1) * 2
	
func getMaxHanger():
	return 100
	
func charIsKOd():
	return head_hp == 1 or belly_hp == 1

func charIsDead():
	return head_hp == 0 or belly_hp == 0
	

# no healing other players (yet!!!)
func incrBehavior():
	#passive - do nothing
	if(behavior == "PASSIVE"):
		behavior = "HOLD"
	#hold - dont move, but fight.
	elif(behavior == "HOLD"):
		behavior = "KILL"
	#kill - kill anyone i click or anyone fightingme.
	elif(behavior == "KILL"):
		behavior = "PASSIVE"

func dropItem(slot):
	get_node("../../DroppedItems").put(invItems[slot],global_transform.origin)
	invItems.remove(slot)
	updateItemModels()

func dropHeadItem():
	if(headItem != null):
		get_node("../../DroppedItems").put(headItem,global_transform.origin)
	headItem = null
	updateItemModels()

func dropArmorItem():
	if(armorItem != null):
		get_node("../../DroppedItems").put(armorItem,global_transform.origin)
	armorItem = null
	updateItemModels()

func dropWeaponItem():
	if(heldItem != null):
		get_node("../../DroppedItems").put(heldItem,global_transform.origin)
	heldItem = null
	updateItemModels()

func recruitCost():
	var tot = 3 * (swordskill + axeskill + rangedskill + unarmedskill)
	if(heldItem != null):
		tot += 1.3 * heldItem.price
	if(armorItem != null):
		tot += 1.3 * armorItem.price
	if(headItem != null):
		tot += 1.3 * headItem.price
	return int(tot)
	
func recruit():
	faction = "player"
	role = ""
	get_node("RoleHireable").visible = false

func healpass(amt):
	var vals = [head_hp,belly_hp,larm_hp,rarm_hp,lleg_hp,rleg_hp]
	var targ = 0
	var mval = getMaxHP()
	
	var i = 0
	for v in vals:
		if(v < mval && v != 0):
			mval = v
			targ = i
		i = i + 1
	
	if(mval == getMaxHP()):
		# nothing to heal, use it all.
		return amt
	
	var to_heal = min(amt,getMaxHP() - mval)

	# heal the wounded part.
	if(targ == 0):
		head_hp += to_heal
	if(targ == 1):
		belly_hp += to_heal
	if(targ == 2):
		larm_hp += to_heal
	if(targ == 3):
		rarm_hp += to_heal
	if(targ == 4):
		lleg_hp += to_heal
	if(targ == 5):
		rleg_hp += to_heal
		
	return to_heal


func healItemUse(giver,receiver,amount):
	giver.medic += 1
	var amount2 = amount * (1 + (getMedicBonus()/100.0))
	while(amount2 > 0):
		amount2 -= receiver.healpass(amount2)

func use(slot):
	var it = invItems[slot]

	if(AppState.shopping):
		AppState.money += it.price
		get_node("Sounds/sell").play()
		invItems.erase(it)
		return

	if(it.type == "f"):
		hanger = min(100,hanger + it.damage)
		if(it.itemname != "monster energy zero ultra" and it.itemname != "bonk"):
			playFx("eat")
		else:
			playFx("drink")
		invItems.erase(it)
	
	if(it.type == "m"):
		healItemUse(self,self,it.damage)
		playFx("heal")
		invItems.erase(it)
	
	if(it.type == "r" or it.type == "s" or it.type == "l"):
		if(heldItem != null):
			invItems[slot] = heldItem

		heldItem = it
		invItems.erase(it)

	if(it.type == "h"):
		if(headItem != null):
			invItems[slot] = headItem

		headItem = it
		invItems.erase(it)
		
	if(it.type == "a"):
		if(armorItem != null):
			invItems[slot] = armorItem 

		armorItem = it
		invItems.erase(it)
	updateItemModels()

func playFx(name):
	if(name == "hurt"):
		get_node("Sounds/hurt" + str(1 + (randi() % 6))).play()
	if(name == "hurtf"):
		get_node("Sounds/hurtf" + str(1 + (randi() % 3))).play()
	if(name == "eat"):
		get_node("Sounds/eat" + str(1 + (randi() % 2))).play()
	if(name == "drink"):
		get_node("Sounds/drink" + str(1 + (randi() % 2))).play()
	if(name == "punch"):
		get_node("Sounds/punch" + str(1 + (randi() % 2))).play()
	if(name == "heal"):
		get_node("Sounds/heal" + str(1 + (randi() % 2))).play()

func emptyInv():
	dropWeaponItem()
	dropArmorItem()
	dropHeadItem()
	for e in invItems:
		get_node("../../DroppedItems").put(e,global_transform.origin)
	invItems = []
	updateItemModels()

func do_anim_finished(nameof):
	if(nameof == "knocked_down1"):
		player_anim_down = true

func pickupItem(item):
	if(item == null):
		# HOW does this happen??????
		print("avoided a null pickup")
		return
	invItems.append(item)

func updateItemModels():
	for v in get_node("model/game_rig/Skeleton/weapons").get_children():
		if(heldItem != null and v.name == heldItem.itemname):
			v.visible = true
			if(heldItem.shiny != 0):
				v.get_node("particles").visible = true
				v.get_node("particles").draw_pass_1 = load("res://misc/shinys/" + str(heldItem.shiny) + "m.tres")
			else:
				v.get_node("particles").visible = false
			
		else:
			v.visible = false
	
	for v in get_node("model/game_rig/Skeleton/headgear").get_children():
		if(headItem != null and v.name == headItem.itemname):
			v.visible = true
		else:
			v.visible = false
		

func addroleicon():
	if(role == "hireable"):
		get_node("RoleHireable").visible = true
	if(role == "shopkeep"):
		get_node("RoleShopkeep").visible = true


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# FIRST -> prepare the node. delete everything except for the name tag.
	for v in get_children():
		if(v.name == "nametag" or v.name == "RoleHireable" or v.name == "RoleShopkeep" or v.name == "Sounds"):
			continue
		if(v.name == basemodel):
			v.name = "model"
		else:
			v.queue_free()
	
	get_node("model/AnimationPlayer").connect("animation_finished", self, "do_anim_finished")
	
	# give char item now
	updateItemModels()

	if(charname == ""):
		if ("gf" in basemodel):
			charname = AppState.get_m_name()
		elif ("gm" in basemodel):
			charname = AppState.get_f_name()
		else:
			if(rand_range(0.0,1.0) < 0.5):
				charname = AppState.get_f_name()
			else:
				charname = AppState.get_m_name()
				
	addroleicon()

func playerai(vis):
	if(behavior == "PASSIVE"):
		attackTarget = null
		# do nothing lawl
		pass
	elif(behavior == "HOLD"):
		# fight if we can, but do not move.
		fight(vis, false)
		attackTarget = null
	elif(behavior == "KILL"):
		
		fight(vis,true)
		if(attackTarget != null):
			handle_attack_consq(attackTarget)
			moveDestination = attackTarget.global_transform.origin


func fight(vis,force_attack):
	if(force_attack):
		if(attackTarget != null and !attackTarget.charIsKOd() and !attackTarget.charIsDead()):
			canattack([attackTarget,global_transform.origin.distance_to(attackTarget.global_transform.origin)])
			return
			
	attackTarget = null
	for n in vis:
		# fight if targeting a friend, OR, if relation low
		if(n[0].charIsKOd() or n[0].charIsDead()):
			continue
		 
		var should_fight = AppState.relation(faction,n[0].faction) < 1 or (n[0].attackTarget != null and n[0].attackTarget["faction"] == faction)
		if(n[0] != self and should_fight):
			attackTarget = n[0]
			canattack(n)
			return

func ai(vis):
	if(faction == "player"):
		playerai(vis)
		return

	moveDestination = null
	if(ai_quest_loc != null):
		moveDestination = ai_quest_loc
	# Fightin AI
	
	fight(vis,false)
	if(attackTarget != null):
		moveDestination = attackTarget.global_transform.origin

func get_camera():
	var r = get_node('/root')
	return r.get_viewport().get_camera()

func position_label(label:Label, point3D:Vector3):
	var camera = get_camera()
	var offset = Vector2(label.get_size().x/2, 0)
	label.rect_position = camera.unproject_position(point3D) - offset
	if(selected):
		label.rect_scale = Vector2(1.1,1.1)
		label.text = "{" + charname + "}"
	else:
		label.rect_scale = Vector2(1,1)
		label.text = charname

func setItemTarget():
	pass

func canattack(v):
	if(attackCoolDown > 0):
		return false

	if(!v[0].charIsKOd() and !v[0].charIsDead()):
		
		# within range?
		if(heldItem == null && v[1] > PUNCH_RANGE):
			return false
		if(heldItem != null && v[1] > heldItem.rnge):
			return false
		
		var damage = PUNCH_DAMAGE
		attackCoolDown = PUNCH_COOLDOWN
		
		if(heldItem != null):
			damage = heldItem.damage
			attackCoolDown = heldItem.cooldown
		
		attackTarget = v[0]


		if(heldItem== null):
			unarmedskill += UNARMED_GROW_RATE
			damage *= 1 + (unarmedskill/100.0)
		elif(heldItem.type == "r"):
			rangedskill += RANGED_GROW_RATE
			damage *= 1 + (rangedskill/100.0)
		elif(heldItem.type == "s"):
			swordskill += SWORD_GROW_RATE
			damage *= 1 + (swordskill/100.0)
		elif(heldItem.type == "l"):
			axeskill += AXE_GROW_RATE
			damage *= 1 + (axeskill/100.0)

			
		v[0].tryAttack(damage)
		
		if(heldItem != null):
			get_node("model/game_rig/Skeleton/weapons/" + str(heldItem.itemname) + "/fire").play()
		else:
			playFx("punch")
		return true
	return false

func animateAll():
	animate(get_node("model/AnimationPlayer"))
	
	get_node("model/armors/samurai_armor").visible = false
	get_node("model/armors/coat").visible = false
	get_node("model/armors/armor1").visible = false
	
	if(armorItem == null):
		return
	
	if(armorItem.itemname == "armor1"):
		get_node("model/armors/armor1").visible = true
		animate(get_node("model/armors/armor1/AnimationPlayer"))
		
	if(armorItem.itemname == "coat"):
		get_node("model/armors/coat").visible = true
		animate(get_node("model/armors/coat/AnimationPlayer"))
		
	if(armorItem.itemname == "samurai_armor"):
		get_node("model/armors/samurai_armor").visible = true
		animate(get_node("model/armors/samurai_armor/AnimationPlayer"))
		

func speedadj(mesh,anim_name,time_to_take):
	mesh.set_speed_scale(mesh.get_animation(anim_name).length / time_to_take)

func handle_attack_consq(target):
	# player attacked target.
	# set a cooldown of one minute, decrease relations, make sure they retailiate.
	if(AppState.aggro_cooldown < 0):
		AppState.player_relation[target["faction"]] = max(0,AppState.player_relation[target["faction"]]-1)
		AppState.aggro_cooldown = 60
	if(target.attackTarget == null):
		target.attackTarget = self

func instigate(t):
	attackTarget = t
	if(t.attackTarget == null):
		t.attackTarget = self

func animate(mesh):
	mesh.set_speed_scale(1)
	if(player_anim_down):
		if(charIsKOd()):
			mesh.play("dying")
			attackTarget = null #no retaliate.
		elif(charIsDead()):
			faction = "hell" #dead
			attackTarget = null #no retaliate.
			# later: play actual dead anim
			#mesh.play("dead")
		return
	
	if(charIsKOd() or charIsDead()):
		mesh.play("knocked_down1")
		return

	# attacking someone
	if((attackCoolDown > 0)):
		if(heldItem == null):
			speedadj(mesh,"noweapon_attack1", PUNCH_COOLDOWN)
			mesh.play("noweapon_attack1")
			
			#mesh
			# or 2
		elif(heldItem.type == "r"):
			mesh.play("ranged_firing")
		elif(heldItem.type == "s"):
			speedadj(mesh,"smallmelee_attack1", heldItem.cooldown)
			mesh.play("smallmelee_attack1")
		else:
			speedadj(mesh,"largemelee_sideswing", heldItem.cooldown)
			mesh.play("largemelee_sideswing")
			
	# running
	elif (moveDestination != null or interactTarget != null):
		if(heldItem == null):
			mesh.play("noweapon_run")
			# or 2
		elif(heldItem.type == "r"):
			mesh.play("ranged_run")
		elif(heldItem.type == "s"):
			mesh.play("smallweapon_run")
		else:
			mesh.play("largemelee_run")
	else:
		if(heldItem == null):
			mesh.play("noweapon_idle")
			# or 2
		elif(heldItem.type == "r"):
			mesh.play("ranged_idle")
		elif(heldItem.type == "s"):
			mesh.play("smallmelee_idle")
		else:
			mesh.play("largemelee_idle")

func wiggleFree(vis, delta):
	if(len(vis) > 1):
		var dist = (global_transform.origin - vis[1][0].global_transform.origin)
		if(dist.length() < PERSONAL_SPACE):
			global_transform.origin += Vector3(delta * dist.normalized().x,0,delta * dist.normalized().z)

func move(delta, dest):
		# Calcuate everything important about moving.
		var dir = (dest - global_transform.origin).normalized()
		var looktarg = global_transform.origin + (dir * Vector3(-1,0,-1))
		var move = dir * getRunSpeed() * delta
		get_node("model").look_at(looktarg,Vector3(0,1,0))
		global_transform.origin += move
		running += RUN_GROW_RATE * delta
		
func clearInteractTarget(t):
	for v in get_node("../").get_player_chars():
		if(v.interactTarget == t):
			v.interactTarget = null
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	#expensive?
	get_node("model").setAmputate(rarm_hp > 0,larm_hp > 0,rleg_hp >  0,lleg_hp >  0)
	
	if(rarm_hp == 0 and larm_hp == 0):
		dropWeaponItem()

	ko_time -= delta
	if(ko_time < 0 && charIsKOd()):
		if(head_hp == 1):
			head_hp = 2
		if(belly_hp == 1):
			belly_hp = 2
		player_anim_down = false
			
		
	if("player" in faction):
		# Always position nametag
		position_label(get_node("nametag"),global_transform.origin + Vector3(0,2,0))
		# hunger
		hanger -= delta * HANGER_RATE
		if(hanger < 0):
			belly_hp = 0
			kill()
			
	else:
		get_node("nametag").text = ""
		consider_quest_time -= delta
		if(consider_quest_time < 0 and ai_quest_loc == null):
			consider_quest_time = rand_range(30,160)
			if(rand_range(0,1) < QUEST_ACCEPT_CHANCE and role != "shopkeeper"):
				ai_quest_loc = get_node("../../NPCGen").get_quest()

	# ALWAYS put on ground
	putOnGround()
	
	# too far away! do nothing.
	if(get_viewport().get_camera().global_transform.origin.distance_to(global_transform.origin) > DISABLE_DIST):
		return
	
	# ALWAYS animate.
	animateAll()

	# nothing else for dead players
	if(charIsKOd() or charIsDead()):
		if(faction == "player"):
			behavior = "HOLD"
		return

	# Get everyone we can see -> This is cached!
	var vis = get_parent().get_visible_actors(self)

	# ALWAYS cool down attackers
	attackCoolDown -= delta
	
	# If we're in the middle of an attack, do nothing.
	if(attackCoolDown > 0):
		if(attackTarget == null):
			#deaggrod, no big deal.
			return
		var dir = (attackTarget.global_transform.origin - global_transform.origin).normalized()
		var looktarg = global_transform.origin + (dir * Vector3(-1,0,-1))
		get_node("model").look_at(looktarg,Vector3(0,1,0))
		return

	wiggleFree(vis, delta * WIGGLE_VEL)

	if(interactTarget != null && is_instance_valid(interactTarget)):
		# could be taken by someone else.
		if(interactTarget.global_transform.origin.distance_to(global_transform.origin) < PICKUP_DEST && len(invItems) < 12):
			pickupItem(get_node("../../DroppedItems").geti(interactTarget))
			get_node("../../DroppedItems").destroy(interactTarget)
			clearInteractTarget(interactTarget)
			moveDestination = null
		else:
			move(delta, interactTarget.global_transform.origin)
	
	# Otherwise, see if we can move.
	elif(moveDestination != null):

		# reached the ai quest dest! done.
		if(ai_quest_loc != null and ((global_transform.origin - ai_quest_loc) * Vector3(1,0,1)).length() < BASICALLY_AT_QUEST):
			ai_quest_loc = null
			moveDestination = global_transform.origin
			
			
		# reached the dest, return.
		if(moveDestination.distance_to(global_transform.origin) < BASICALLY_AT_DEST):
			moveDestination = null
			return
		move(delta, moveDestination)

	ai(vis)

# try item serialize
func tis(i):
	if(i == null):
		return i
	return i.serialize()
	
# try item deserialize
func tid(i):
	if(i == null):
		return i
	if(KenshitItem == null):
		KenshitItem = preload("res://scripts/KenshitItem.gd")
	var k = KenshitItem.new()
	k.deserialize(i)
	return k

func serialize(x,z):
	var dat = .serialize(x,z)
	dat["running"] = running
	dat["medic"] = medic

	dat["swordskill"] = swordskill
	dat["axeskill"] = axeskill
	dat["rangedskill"] = rangedskill
	dat["unarmedskill"] = unarmedskill

	dat["heldItem"] = tis(heldItem)
	dat["armorItem"] = tis(armorItem)
	dat["headItem"] = tis(headItem)

	var invser = []
	for i in invItems:
		# we can somehow pick up null items.
		invser.append(i.serialize())

	dat["invItems"] = invser

	dat["charname"] = charname
	dat["basemodel"] = basemodel
	
	#basis
	dat["tall"] = get_node("model").height
	dat["thick"] = get_node("model").thick
	dat["leg"] = get_node("model").legs
	dat["scene"] = get_node("model").styleID
	dat["hair"] = get_node("model").hair
	
	dat["role"] = role

	return dat

func deserialize(dat):
	.deserialize(dat)
	running = dat["running"]
	medic = dat["medic"]
	role = dat["role"]

	swordskill = dat["swordskill"] 
	axeskill = dat["axeskill"] 
	rangedskill = dat["rangedskill"]
	unarmedskill = dat["unarmedskill"]

	heldItem = tid(dat["heldItem"])
	armorItem = tid(dat["armorItem"])
	headItem = tid(dat["headItem"])

	for i in dat["invItems"]:
		invItems.append(tid(i))

	charname = dat["charname"]
	basemodel = dat["basemodel"]
	
	return dat
