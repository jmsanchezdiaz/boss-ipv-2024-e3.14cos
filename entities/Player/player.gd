extends CharacterBody2D
class_name Player

signal hit

@export var ACCELERATION = 1500
@export var FRICTION = 1500
@export var MAX_SPEED = 450
@export var MAX_STAMINA = 100.0
@export var STAMINA_REGEN = 10.0 # La cantidad de estamina que se regenera por segundo.
@export var RUNNING_STAMINA_COST = 25.0 # La cantidad de estamina que se consume por segundo al correr.
@export var ATTACKING_STAMINA_COST = 25.0
@export var inventory: Inventory
@export var MAX_HEALTH: float = 100.0

@onready var bloodAnimation = $BloodAnimation
@onready var bodyAnimation = $BodyAnimation
@onready var moving_audio = $MovingSound
@onready var heart_audio = $Heartbeat
@onready var attack_audio = $Attacking
@onready var camera = $Camera2D

var idle_sound = preload("res://sounds/player/player-idle.ogg")
var tired_idle_sound = preload("res://sounds/player/player-tired-idle.ogg")
var walking_sound = preload("res://sounds/player/player-walking.ogg")
var running_sound = preload("res://sounds/player/player-running.ogg")

var heartbeat_calm = preload("res://sounds/player/player-heartbeat-calm.ogg")
var heartbeat_fast = preload("res://sounds/player/player-heartbeat-fast.ogg")

var player_attack_sound = preload("res://sounds/player/player-attack.ogg")
var player_missed_punch = preload("res://sounds/player/player-missed_punch.ogg")

var current_stamina = MAX_STAMINA
var running_multiplier = 1

var health = 100
var attack_range: float = 150.0
var current_target: Node2D = null
var smoothed_mouse_pos = Vector2.ZERO
var current_state:STATE = STATE.IDLE
var selected_weapon = null
var selected_weapon_damage = null
var FIST_DAMAGE = 10.0
var attacking = false;
var paused = false;
var lastFistUsed = 0;

enum STATE {
	IDLE,
	WALKING,
	RUNNING,
	ATTAKING,
	HEALING
}

func _ready():
	inventory.set_player(self)

func pause():
	set_physics_process(false)
	paused=true;
	
func unpause():
	set_physics_process(true)
	paused=false

func handle_heartbeat():
	if health < 60:
		if heart_audio.stream != heartbeat_fast:
			heart_audio.stream = heartbeat_fast
	elif heart_audio.stream != heartbeat_calm:
		heart_audio.stream = heartbeat_calm
	if !heart_audio.playing : heart_audio.play()

func _physics_process(delta: float) -> void:
	smoothed_mouse_pos = lerp(smoothed_mouse_pos, get_global_mouse_position(), 0.6)
	rotation = position.angle_to_point(smoothed_mouse_pos)
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	handle_heartbeat()
		
	match current_state:
		STATE.IDLE:
			bodyAnimation.play("RESET")
			_play_stream(idle_sound, moving_audio)
			regenerate_stamina(1, delta)
			if input_vector != Vector2.ZERO:
				if Input.is_action_pressed("run") and current_stamina > 10:
					current_state = STATE.RUNNING
				else: current_state = STATE.WALKING
			
		STATE.WALKING:
			bodyAnimation.play("Walk")
			_play_stream(walking_sound, moving_audio)
			regenerate_stamina(0.5, delta)
			handle_move(delta)
			if input_vector == Vector2.ZERO:
				moving_audio.stop()
				current_state = STATE.IDLE
			if Input.is_action_pressed("run") and current_stamina > 10:
				current_state = STATE.RUNNING
		
		STATE.RUNNING:
			bodyAnimation.play("Run")
			_play_stream(running_sound, moving_audio)
			handle_move(delta)
			handle_run(delta)
			if input_vector == Vector2.ZERO:
				moving_audio.stop()
				current_state = STATE.IDLE
				running_multiplier = 1
			if current_stamina == 0 or (!Input.is_action_pressed("run") and input_vector != Vector2.ZERO):
				current_state = STATE.WALKING
				running_multiplier = 1
		
		STATE.ATTAKING:
			running_multiplier = 1
			handle_move(delta)
			attack(input_vector)
		
		STATE.HEALING:
			bodyAnimation.play("Heal")
			await get_tree().create_timer(0.9).timeout
			current_state = STATE.WALKING if input_vector != Vector2.ZERO else STATE.IDLE


func _play_stream(stream, audio):
	if stream != audio.stream: audio.stream = stream
	if !audio.playing: audio.play()


func attack(inputs):
	if !attacking and current_stamina > 0:
		attacking = true
		if selected_weapon == null:
			punch()
		else:
			bodyAnimation.play("Melee")
		
		if current_target:
			var damage = selected_weapon_damage if selected_weapon else FIST_DAMAGE
			var distance = position.distance_to(current_target.position)
			if distance <= attack_range:
				_play_stream(player_attack_sound,attack_audio)
				current_target.take_damage(damage, self)
				camera.start_shake()
			current_stamina -= max(current_stamina - ATTACKING_STAMINA_COST, 0)
		else:
			_play_stream(player_missed_punch, attack_audio)
		
		await get_tree().create_timer(1).timeout
		
		attack_audio.stop()
		current_state = STATE.WALKING if inputs != Vector2.ZERO else STATE.IDLE
		attacking=false


func punch() -> void:
	if (lastFistUsed+1)%2 == 0:
		bodyAnimation.play("Punch")
	else:
		bodyAnimation.play("Punch2")
	lastFistUsed += 1


func collect(item):
	inventory.insert(item)


func _input(event):
	if !paused and event.is_action_pressed("attack"):
		current_state = STATE.ATTAKING


func recover_health(hp: float):
	current_state = STATE.HEALING
	health = min(MAX_HEALTH, health + hp)
	bloodAnimation.stop()


func handle_move(delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector == Vector2.ZERO:
		apply_friction(FRICTION * delta)
	else:
		apply_movement((input_vector * ACCELERATION * delta))
	move_and_slide()


func handle_run(delta: float) -> void:
	if Input.is_action_pressed("run") and current_stamina > 0:
		current_state = STATE.RUNNING
		running_multiplier = 2
		current_stamina = max(current_stamina - RUNNING_STAMINA_COST * delta, 0)
	else:
		running_multiplier = 1


func regenerate_stamina(regen_speed: float, delta: float) -> void:
	if current_stamina < MAX_STAMINA:
		current_stamina = min(current_stamina + STAMINA_REGEN * regen_speed * delta, MAX_STAMINA)


func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO


func apply_movement(accel):
	velocity += accel * running_multiplier
	velocity = velocity.limit_length(MAX_SPEED*running_multiplier)


func take_damage(amount):
	camera.start_shake()
	if health-amount > 0:
		bloodAnimation.play("ReceiveDamage")
	else:
		# bloodAnimation.play("Die")
		queue_free()
		hit.emit()
	health = max(0, health - amount) 


func _on_crowbar_area_body_entered(body: Node2D) -> void:
	if body is Zombie:
		current_target = body


func _on_crowbar_area_body_exited(body: Node2D) -> void:
	if body == current_target:
		current_target = null
