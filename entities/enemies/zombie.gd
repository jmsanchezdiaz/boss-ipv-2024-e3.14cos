extends CharacterBody2D
class_name Zombie

@export var HEALTH_POINTS: float = 100.0 
@export var SPEED: float = 50.0
@export var ATTACK_DAMAGE = 25
@export var attack_interval: float = 1.0

@onready var leftEye: RayCast2D = $LeftEye
@onready var rightEye: RayCast2D = $RightEye
@onready var animation = $BloodAnimation
@onready var bodyAnimation = $BodyAnimation
var target: Node2D
var target_in_attack_area: bool = false
var attack_timer: Timer
var lastPositionKnown: Vector2

func _ready() -> void:
	bodyAnimation.play("idle")
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_interval
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))
	add_child(attack_timer)


func _physics_process(delta: float) -> void:
	var distanceToLastPosition = (position - lastPositionKnown).length()
	
	if target:
		leftEye.target_position = leftEye.to_local(target.global_transform.origin)
		rightEye.target_position = rightEye.to_local(target.global_transform.origin)
		leftEye.force_raycast_update()
		rightEye.force_raycast_update()
		
		var distance = (target.global_position - global_position).length()
		
		var sawByLeftEye: bool = leftEye.is_colliding() && leftEye.get_collider() == target
		var sawByRightEye: bool = rightEye.is_colliding() && rightEye.get_collider() == target
		
		if sawByLeftEye || sawByRightEye:
			var targetPosition: Vector2 = (target.global_position - global_position).normalized() * SPEED * delta
			look_at(target.global_position)
			lastPositionKnown = target.global_position
			
			if distance > 59:
				position += targetPosition
				bodyAnimation.play("walk")
				move_and_collide(Vector2.ZERO.rotated(0.0))
			else:
				bodyAnimation.play("idle")
				
			if target_in_attack_area and attack_timer.is_stopped():
				attack_timer.start()  # Comienza los ataques si no está atacando
		
		elif lastPositionKnown != Vector2.ZERO and distanceToLastPosition > 1:
			bodyAnimation.play("walk")
			move_to_last_position_known(delta)
		else:
			bodyAnimation.play("idle")
	elif lastPositionKnown != Vector2.ZERO and distanceToLastPosition > 1:
		bodyAnimation.play("walk")
		move_to_last_position_known(delta)
	else:
		bodyAnimation.play("idle")


func move_to_last_position_known(delta) -> void:
	position += (lastPositionKnown - global_position).normalized() * SPEED * delta
	move_and_collide(Vector2.ZERO.rotated(0.0))


func take_damage(amount: float, attacker: Node2D) -> void:
	HEALTH_POINTS -= amount
	animation.play("ReceiveDamage")
	if HEALTH_POINTS <= 0:
		queue_free()
	if target == null:
		target = attacker


func attack(enemy):
	if enemy is Player:
		enemy.take_damage(ATTACK_DAMAGE)


func _on_attack_timeout() -> void:
	if target_in_attack_area:
		bodyAnimation.stop()
		bodyAnimation.play("attack")
		attack(target)
		attack_timer.start()
	else:
		bodyAnimation.play("idle")

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
		bodyAnimation.play("idle")
