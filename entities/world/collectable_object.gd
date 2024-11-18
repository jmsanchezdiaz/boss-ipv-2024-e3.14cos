extends Area2D
class_name CollectableObject

@export var item: InventoryItem
@onready var spr: Sprite2D

var player_in_collecting_area: bool = false
var target: Node2D
var original_material: Material
var highlight_material: ShaderMaterial

func _process(delta):
	if player_in_collecting_area and Input.is_action_just_pressed("collect"):
		target.collect(item)
		queue_free()


func _on_body_entered(body):
	if body is not Player: return;
	player_in_collecting_area = true
	target = body


func _on_body_exited(body):
	if body is not Player: return;
	player_in_collecting_area = false
	target = null
