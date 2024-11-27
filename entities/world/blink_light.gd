extends PointLight2D

@onready var timer: Timer = $Timer
@onready var audio = $AudioStreamPlayer2D
@onready var initial_energy = self.energy;

@export var min_energy = 0.01
@export var min_wait_time = 4
@export var max_wait_time = 8

func _ready() -> void:
	timer.start()

func _on_timer_timeout() -> void:
	energy = randf_range(min_energy, initial_energy) 
	audio.play(4)
	timer.wait_time = randf_range(min_wait_time, max_wait_time) 
	timer.start()
