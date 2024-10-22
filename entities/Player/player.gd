extends CharacterBody2D
class_name Player


@export var ACCELERATION = 1500
@export var FRICTION = 1500
@export var MAX_SPEED = 450
@export var MAX_STAMINA = 100.0
@export var STAMINA_REGEN = 10.0 # La cantidad de estamina que se regenera por segundo.
@export var RUNNING_STAMINA_COST = 25.0 # La cantidad de estamina que se consume por segundo al correr.
@onready var bloodAnimation = $BloodAnimation
@onready var bodyAnimation = $BodyAnimation

var current_stamina = MAX_STAMINA
var running_multiplier = 1

var health = 100
var attack_range: float = 150.0
var attack_damage: float = 25.0
var inventory = ["Crowbar"]
var current_target: Node2D = null

var smoothed_mouse_pos = Vector2.ZERO

func attack():
	if current_target and "Crowbar" in inventory:
		var distance = position.distance_to(current_target.position)
		if distance <= attack_range:
			current_target.take_damage(attack_damage, self)
			print("Attacked zombi! Remaining HP: ", current_target.HEALTH_POINTS)
		else:
			print("Target too far!")
	else:
		print("No target in range or no Crowbar in inventory!")


func _input(event):
	if event.is_action_pressed("attack"):
		attack()


func add_to_inventory(item):
	if inventory.size() < 12:
		inventory.append(item)
		print("Added to inventory: ", item)
	else:
		print("Inventory full!")


func remove_from_inventory(item):
	if item in inventory:
		inventory.erase(item)
		print("Removed from inventory: ", item)
	else:
		print("Item not in inventory!")


func use_item(item):
	if item in inventory:
		print("Using item: ", item)
		inventory.erase(item)
	else:
		print("Item not in inventory!")


func _physics_process(delta: float) -> void:
	smoothed_mouse_pos = lerp(smoothed_mouse_pos, get_global_mouse_position(), 0.6)
	rotation = position.angle_to_point(smoothed_mouse_pos)
	print("Current Stamina: ", current_stamina)
	handle_running(delta)
	move(delta)
	regenerate_stamina(delta)


func handle_running(delta: float) -> void:
	if Input.is_action_pressed("run") and current_stamina > 0:
		running_multiplier = 2
		current_stamina = max(current_stamina - RUNNING_STAMINA_COST * delta, 0)
	else:
		running_multiplier = 1

func regenerate_stamina(delta: float) -> void:
	if current_stamina < MAX_STAMINA and running_multiplier == 1: # Regenera estamina sólo si no estás corriendo
		current_stamina = min(current_stamina + STAMINA_REGEN * delta, MAX_STAMINA)

func move(delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector == Vector2.ZERO:
		apply_friction(FRICTION * delta)
		bodyAnimation.play("RESET")
	else:
		apply_movement((input_vector * ACCELERATION * delta))
		bodyAnimation.play("Walk")
	move_and_slide()


func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO


func apply_movement(accel):
	velocity += accel * running_multiplier
	velocity = velocity.limit_length(MAX_SPEED*running_multiplier)


func take_damage(amount):
	if health > 0:
		health -= amount
		print("Nico health:", health)
		bloodAnimation.play("ReceiveDamage")
	else: 
		queue_free()


func _on_crowbar_area_body_entered(body: Node2D) -> void:
	if body is Zombie:
		current_target = body


func _on_crowbar_area_body_exited(body: Node2D) -> void:
	if body == current_target:
		current_target = null
