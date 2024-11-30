extends Area2D

@export var wait_time: float = 0.0
@export var spawn_node: Node2D
@onready var e_audio = $AudioStreamPlayer2D
@export var enabled: bool = true;
@export var travelling: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if enabled and body is Player:
		e_audio.play()
		if travelling:
			await get_tree().create_timer(wait_time).timeout
			body.global_position = spawn_node.position
		else:
			body.global_position = spawn_node.position
		e_audio.stop()
