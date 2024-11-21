extends Area2D
class_name CollectableObject

@export var item: InventoryItem
@onready var spr: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
var shader: ShaderMaterial

var player_in_collecting_area: bool = false
var target: Node2D

func _ready():
	shader = spr.material

func _process(delta):
	if player_in_collecting_area and Input.is_action_just_pressed("collect"):
		audio.play()
		target.collect(item)
		hide()


func _on_body_entered(body):
	if body is not Player: return;
	player_in_collecting_area = true
	target = body
	spr.material = shader


func _on_body_exited(body):
	if body is not Player: return;
	player_in_collecting_area = false
	target = null
	spr.material = null


func _on_audio_stream_player_2d_finished():
	queue_free()
