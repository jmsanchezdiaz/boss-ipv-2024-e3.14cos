extends CharacterBody2D
class_name Zombie

@export var HEALTH_POINTS: float = 100.0 
@export var SPEED: float = 50.0
@export var ATTACK_DAMAGE = 25
@export var attack_interval: float = 1.0

@onready var left_eye: RayCast2D = $LeftEye
@onready var right_eye: RayCast2D = $RightEye
@onready var animation = $BloodAnimation
@onready var body_animation = $BodyAnimation

var MIN_DISTANCE_TO_MOVE = 38

var target: Node2D
var target_in_attack_area: bool = false
var attack_timer: Timer
var last_position_known: Vector2

@export var direction_change_interval := 1.0  # Intervalo en segundos para cambiar de dirección
var direction := Vector2.ZERO
var time_since_last_change := 0.0

# State Machine
enum PLAYER_STATE {
	IDLE,
	WALKING,
	ATTACKING
}

var current_state: PLAYER_STATE = PLAYER_STATE.IDLE 

func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_interval
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))
	add_child(attack_timer)


func _physics_process(delta: float) -> void:
	attack_near_enemies()
	look_for_player()
	match current_state:
		PLAYER_STATE.IDLE:
			if last_position_known != Vector2.ZERO and get_distance_to_last_position() > MIN_DISTANCE_TO_MOVE:
				current_state = PLAYER_STATE.WALKING
			else: 
				body_animation.play("idle")
		PLAYER_STATE.WALKING:
			move_or_pursue(delta)
			body_animation.play("walk")
		PLAYER_STATE.ATTACKING:
			body_animation.play("attack")
		


func change_direction():
	var random_dir := randi() % 4
	match random_dir:
		0:
			direction = Vector2.UP
		1:
			direction = Vector2.DOWN
		2:
			direction = Vector2.LEFT
		3:
			direction = Vector2.RIGHT

func look_for_player() -> void:
	if target == null: return;
	
	left_eye.target_position = left_eye.to_local(target.global_transform.origin)
	right_eye.target_position = right_eye.to_local(target.global_transform.origin)
	left_eye.force_raycast_update()
	right_eye.force_raycast_update()
			
	var saw_by_left_eye: bool = left_eye.is_colliding() && left_eye.get_collider() == target
	var saw_by_right_eye: bool = right_eye.is_colliding() && right_eye.get_collider() == target
			
	if saw_by_left_eye || saw_by_right_eye:
		last_position_known = target.global_position

func get_distance_to_last_position() -> float:
	return (position - last_position_known).length()

func move_or_pursue(delta: float) -> void:
	if last_position_known and get_distance_to_last_position() > MIN_DISTANCE_TO_MOVE:
		var target_position: Vector2 = (last_position_known - global_position).normalized() * SPEED * delta
		look_at(last_position_known)
		
		position += target_position
		move_and_collide(Vector2.ZERO.rotated(0.0))	
	else:
		current_state = PLAYER_STATE.IDLE

func attack_near_enemies() -> void:
	if target_in_attack_area and attack_timer.is_stopped():
			attack_timer.start()  # Comienza los ataques si no está atacando

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
		current_state = PLAYER_STATE.ATTACKING
		attack(target)
		attack_timer.start()
	else:
		current_state = PLAYER_STATE.IDLE

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
		current_state = PLAYER_STATE.IDLE
