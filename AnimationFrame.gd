class_name AnimationFrame
extends Node2D
var Enums = preload("res://parser/enums.gd")
var frames={}
func _ready():
	pass # Replace with function body.
func getFrame(type):
	return frames.get(type)

func addSpriteFrame(sprite,type):
	frames[type] = sprite
#	if type==Enums.DrawType.clothing:
#		sprite.position=Vector2(200,-34)
#		getFrame(Enums.DrawType.Character).add_child(sprite)
#	else:
	add_child(sprite)
