extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
 
# readonlys
var heightbase = 1.0
var heightmod = 0.2

var thickbase = 1.0
var thickmod = 0.2

var legbase = 0.7
var legmod = 0.6

var stylethickmod = 0.6

#temps
var wStyleId = 0

#basis
var height = 0.5
var thick = 0.5
var legs = 0.5
var styleID = 0.5
var hair = ""


func genParamFromstyleId():
	wStyleId = str(wStyleId).hash()
	var frac = (wStyleId / float(2147483648)) - 1
	return thickbase + -thickmod + (thickmod * 2 * thick) + (frac * styleID * stylethickmod)

func setAmputate(r_arm,l_arm,r_leg,l_leg):
	var t = Transform(Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3())
	if(!r_arm && !l_arm):
		get_node("game_rig/Skeleton").set_bone_custom_pose(30,t)
	if(!l_arm || !r_arm):
		get_node("game_rig/Skeleton").set_bone_custom_pose(24,t)

	if(!r_leg):
		get_node("game_rig/Skeleton").set_bone_custom_pose(17,t)
	if(!l_leg):
		get_node("game_rig/Skeleton").set_bone_custom_pose(11,t)

func setParams(nheight, nthick, nlegs, nstyleID, nhair):
	height = nheight
	thick = nthick
	legs = nlegs
	styleID = nstyleID
	hair = nhair
	
	for v in get_node("game_rig/Skeleton/Hairs").get_children():
		v.visible = (v.name == hair)
		
	wStyleId = str(styleID).hash()
	transform = Transform(Vector3(heightbase,0,0),Vector3(0,heightbase - heightmod + (heightmod * 2 * height),0),Vector3(0,0,heightbase),translation)
	
	for i in get_node("game_rig/Skeleton").get_bone_count ():
		var t = Transform(Vector3(genParamFromstyleId(),0,0),Vector3(0,1,0),Vector3(0,0,genParamFromstyleId()),Vector3())
		if(i == 9 or i == 15):
			var leg = legbase + (legmod * legs)
			t = Transform(Vector3(leg,0,0),Vector3(0,1,0),Vector3(0,0,leg),Vector3())
		if(i == 1):
			var leg = 1 / (legbase + (legmod * legs))
			t = Transform(Vector3(leg,0,0),Vector3(0,1,0),Vector3(0,0,leg),Vector3())
		if(i == 5):
			# un-thick head. this code is fucky and bad, but it works
			# calc thick fix.
			var diff = -thickmod + (thickmod * 2 * thick)


			var vmod = 1 - 1.5*(pow(1+abs(diff),3.5) * diff)
			# overcorrct if negative??????
			if(diff < 0):
				vmod = pow(vmod,2)
				
			# calc "legday" fix.
			diff += 1.5 * ((legbase + (legmod * legs)) - 1)
			
			t = Transform(Vector3(vmod,0,0),Vector3(0,1,0),Vector3(0,0,vmod),Vector3())
		get_node("game_rig/Skeleton").set_bone_custom_pose(i,t)
