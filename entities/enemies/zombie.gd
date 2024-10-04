extends CharacterBody2D
class_name Zombie

@export var HEALTH_POINTS: float = 100.0 
@export var SPEED: float = 50.0
@export var ATTACK_DAMAGE = 25
@export var attack_interval: float = 1.0

@onready var raycast: RayCast2D = $RayCast2D
var target: Node2D
var target_in_attack_area: bool = false
var attack_timer: Timer

func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_interval
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))
	add_child(attack_timer)


func _physics_process(delta: float) -> void:
	if target:
		raycast.target_position = raycast.to_local(target.global_transform.origin)
		raycast.force_raycast_update()
		
		var distance = (target.global_position - global_position).length()
		
		if raycast.is_colliding() && raycast.get_collider() == target:
			look_at(target.global_position)
			
			if distance > 100:
				position += (target.global_position - global_position).normalized() * SPEED * delta
				move_and_collide(Vector2.ZERO.rotated(0.0))

			if target_in_attack_area and attack_timer.is_stopped():
				attack_timer.start()  # Comienza los ataques si no está atacando


func take_damage(amount: float) -> void:
	HEALTH_POINTS -= amount
	if HEALTH_POINTS <= 0:
		queue_free()


func attack(enemy):
	if enemy is Player:
		enemy.take_damage(ATTACK_DAMAGE)

func _on_attack_timeout() -> void:
	if target_in_attack_area:
		attack(target)
		attack_timer.start()


func _on_detection_area_body_entered(body: Node2D) -> void:
	target = body;


func _on_detection_area_body_exited(_body: Node2D) -> void:
	target = null


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		target_in_attack_area = true
		attack_timer.start()


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body is Player:
		target_in_attack_area = false
		attack_timer.stop()
