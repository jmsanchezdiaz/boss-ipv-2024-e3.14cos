extends Area2D
class_name CollectableObject

@export var item: InventoryItem

var player_in_collecting_area: bool = false
var target: Node2D;

func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_just_pressed("collect"):
		target.collect(item)
		queue_free()


func _on_body_entered(body):
	if body is not Player: return;
	player_in_collecting_area = true
	target = body
	
