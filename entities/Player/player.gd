extends CharacterBody2D
class_name Player


@export var ACCELERATION = 1500
@export var FRICTION = 1500
@export var MAX_SPEED = 450
@export var MAX_STAMINA = 100.0
@export var STAMINA_REGEN = 10.0 # La cantidad de estamina que se regenera por segundo.
@export var RUNNING_STAMINA_COST = 25.0 # La cantidad de estamina que se consume por segundo al correr.
@export var ATTACKING_STAMINA_COST = 25.0
@export var inventory: Inventory

@onready var bloodAnimation = $BloodAnimation
@onready var bodyAnimation = $BodyAnimation

var current_stamina = MAX_STAMINA
var running_multiplier = 1

var health = 100
var attack_range: float = 150.0
var attack_damage: float = 25.0
var current_target: Node2D = null
var smoothed_mouse_pos = Vector2.ZERO
var current_state:STATE = STATE.IDLE

enum STATE {
	IDLE,
	WALKING,
	RUNNING,
	ATTAKING
}

func _ready():
	inventory.set_player(self)

func _physics_process(delta: float) -> void:
	if inventory.ui_open: return;
	smoothed_mouse_pos = lerp(smoothed_mouse_pos, get_global_mouse_position(), 0.6)
	rotation = position.angle_to_point(smoothed_mouse_pos)
	print("Salud: ", health)
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	match current_state:
		STATE.IDLE:
			#$Body.show()
			#$BodyRunning.hide()
			bodyAnimation.play("RESET")
			regenerate_stamina(1, delta)
			if input_vector != Vector2.ZERO:
				current_state = STATE.WALKING
			if Input.is_action_pressed("run") and current_stamina > 10:
				current_state = STATE.RUNNING
		STATE.WALKING:
			#$Body.show()
			#$BodyRunning.hide()
			bodyAnimation.play("Walk")
			regenerate_stamina(0.5, delta)
			handle_move(delta)
			if input_vector == Vector2.ZERO:
				current_state = STATE.IDLE
			if Input.is_action_pressed("run") and current_stamina > 10:
				current_state = STATE.RUNNING
		STATE.RUNNING:
			#$Body.hide()
			#$BodyRunning.show()
			bodyAnimation.play("Run")
			handle_move(delta)
			handle_run(delta)
			if input_vector == Vector2.ZERO:
				current_state = STATE.IDLE
				running_multiplier = 1
			if current_stamina == 0 or (!Input.is_action_pressed("run") and input_vector != Vector2.ZERO):
				current_state = STATE.WALKING
				running_multiplier = 1
		STATE.ATTAKING:
			pass

func attack():
	if current_target and inventory.has("crowbar") and current_stamina > 0:
		var distance = position.distance_to(current_target.position)
		if distance <= attack_range:
			current_target.take_damage(attack_damage, self)
			print("Attacked zombi! Remaining HP: ", current_target.HEALTH_POINTS)
		#else:
			#print("Target too far!")
		current_stamina -= max(current_stamina - ATTACKING_STAMINA_COST, 0)
	#else:
		#print("No target in range or no Crowbar in inventory!")


func collect(item):
	inventory.insert(item)

func _input(event):
	if event.is_action_pressed("attack"):
		attack()

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
	if health-amount > 0:
		bloodAnimation.play("ReceiveDamage")
	else:
		# bloodAnimation.play("Die")
		queue_free()
	health = max(0, health - amount) 
	print("Nico health:", health)


func _on_crowbar_area_body_entered(body: Node2D) -> void:
	if body is Zombie:
		current_target = body


func _on_crowbar_area_body_exited(body: Node2D) -> void:
	if body == current_target:
		current_target = null
