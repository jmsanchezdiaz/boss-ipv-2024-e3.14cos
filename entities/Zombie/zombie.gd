extends CharacterBody2D
class_name Zombie

@export var HEALTH_POINTS: float = 100.0 
@export var SPEED: float = 50.0
@export var ATTACK_DAMAGE = 25
@export var attack_interval: float = 1.0
@export var direction_change_interval := 2.0  # Intervalo en segundos para cambiar de dirección

@export var idle_duration_min: float = 5.0
@export var idle_duration_max: float = 10.0
@export var walk_duration_min: float = 2.5
@export var walk_duration_max: float = 5.0

@onready var left_eye: RayCast2D = $LeftEye
@onready var right_eye: RayCast2D = $RightEye
@onready var animation = $BloodAnimation
@onready var body_animation = $BodyAnimation
@onready var audio = $AudioStreamPlayer

var MIN_DISTANCE_TO_MOVE = 35

var target: Node2D
var target_in_attack_area: bool = false
var attack_timer: Timer
var state_timer: Timer
var last_position_known: Vector2

var direction := Vector2.ZERO
var time_since_last_change := 0.0

var idle_sound = preload("res://sounds/zombie/zombie-idle.ogg")
var attack_sound = preload("res://sounds/zombie/zombie-attack.ogg")
# State Machine
enum PLAYER_STATE {
	IDLE,
	WALKING,
	ATTACKING
}

var current_state: PLAYER_STATE = PLAYER_STATE.IDLE 

func _init():
	randomize()

func _ready() -> void:
	audio.stream = idle_sound
	change_direction()
	_setup_attack_timer()
	_setup_state_timer()

func _physics_process(delta: float) -> void:
	look_for_player()
	
	time_since_last_change += delta
	if time_since_last_change >= direction_change_interval:
		change_direction()
		time_since_last_change = 0.0
	
	
	match current_state:
		PLAYER_STATE.IDLE:
			_play_stream(idle_sound)
			body_animation.play("idle")
			if last_position_known != Vector2.ZERO:
				current_state = PLAYER_STATE.WALKING
			reset_state_timer(idle_duration_min, idle_duration_min)
		PLAYER_STATE.WALKING:
			_play_stream(idle_sound)
			move_or_pursue(delta)
			body_animation.play("walk")
		PLAYER_STATE.ATTACKING:
			_play_stream(attack_sound)
			body_animation.play("attack")
			attack_near_enemies()

func _play_stream(stream):
	if stream != audio.stream: audio.stream = stream
	if !audio.playing: audio.play()

func _setup_state_timer() -> void:
	state_timer = Timer.new()
	state_timer.one_shot = true
	state_timer.connect("timeout", Callable(self, "_on_state_timeout"))
	add_child(state_timer)
	state_timer.start()


func _setup_attack_timer() -> void:
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_interval
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))
	add_child(attack_timer)


func change_direction():
	var random_dir := randi() % 8
	match random_dir:
		0:
			direction = Vector2.UP
		1:
			direction = Vector2.DOWN
		2:
			direction = Vector2.LEFT
		3:
			direction = Vector2.RIGHT
		4:
			direction = Vector2.UP + Vector2.RIGHT
		5:
			direction = Vector2.UP + Vector2.LEFT
		6:
			direction = Vector2.DOWN + Vector2.RIGHT
		7:
			direction = Vector2.DOWN + Vector2.LEFT


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
		last_position_known = Vector2.ZERO
		position += direction * SPEED * delta
		move_and_collide(velocity * delta)
		look_at(position + direction)
		reset_state_timer(walk_duration_min, walk_duration_max)


func attack_near_enemies() -> void:
	if target_in_attack_area and attack_timer.is_stopped():
		attack_timer.start() 


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


func reset_state_timer(duration_min: float, duration_max: float):
	if state_timer.is_stopped():
		state_timer.wait_time = randf_range(duration_min, duration_max)
		state_timer.start()


func _on_attack_timeout() -> void:
	if target_in_attack_area:
		attack(target)
		attack_timer.start()


func _on_state_timeout() -> void:
	match current_state:
		PLAYER_STATE.IDLE:
			current_state = PLAYER_STATE.WALKING
		PLAYER_STATE.WALKING:
			if last_position_known == Vector2.ZERO:
				current_state = PLAYER_STATE.IDLE
				direction = Vector2.ZERO

func _on_detection_area_body_entered(body: Node2D) -> void:
	target = body;

func _on_detection_area_body_exited(_body: Node2D) -> void:
	target = null

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		target_in_attack_area = true
		current_state = PLAYER_STATE.ATTACKING
		attack_timer.start()
	else: # Cambiar cuando se diseñe el esceneraio! Porque colisiona con el mundo es decir Layer 1.
		# Cambiar a grupos o otra cosa.
		direction *= -1


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body is Player:
		target_in_attack_area = false
		attack_timer.stop()
		if target != null || last_position_known != Vector2.ZERO:
			current_state = PLAYER_STATE.WALKING
		else:
			current_state = PLAYER_STATE.IDLE
