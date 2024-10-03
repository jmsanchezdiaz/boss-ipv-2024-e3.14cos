extends CharacterBody2D
class_name Player


@export var ACCELERATION = 1500
@export var FRICTION = 1500
@export var MAX_SPEED = 450

var health = 100
var attack_range: float = 150.0
var attack_damage: float = 25.0
var inventory = ["Crowbar"]
var current_target: Node2D = null


func attack():
	if current_target and "Crowbar" in inventory:
		var distance = position.distance_to(current_target.position)
		if distance <= attack_range:
			current_target.take_damage(attack_damage)
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
	move(delta)


func move(delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector == Vector2.ZERO:
		apply_friction(FRICTION * delta)
	else:
		apply_movement(input_vector * ACCELERATION * delta)
	move_and_slide()


func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO


func apply_movement(accel):
	velocity += accel
	velocity = velocity.limit_length(MAX_SPEED)


func take_damage(amount):
	if health > 0:
		health -= amount
		print("Nico health:", health)


func _on_crowbar_area_body_entered(body: Node2D) -> void:
	if body is Zombie:
		current_target = body
		# print("Zombie in range!")


func _on_crowbar_area_body_exited(body: Node2D) -> void:
	if body == current_target:
		current_target = null
		# print("Zombie out of range!")
