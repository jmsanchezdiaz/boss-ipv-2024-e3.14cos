extends CharacterBody2D

@export var HEALTH_POINTS: float  = 100.0 
@export var SPEED: float = 50.0

var raycast: RayCast2D

var target: Node2D

func _ready() -> void:
	raycast = $RayCast2D

func _physics_process(delta: float) -> void:
	if(target):
		raycast.target_position = raycast.to_local(target.global_transform.origin)
		raycast.force_raycast_update()
		
		if raycast.is_colliding() && raycast.get_collider() == target:
			position += (target.position - position).normalized() * SPEED * delta
			move_and_collide(Vector2(0,0)) 
			

func _on_detection_area_body_entered(body: Node2D) -> void:
	target = body;
	


func _on_detection_area_body_exited(body: Node2D) -> void:
	target = null
