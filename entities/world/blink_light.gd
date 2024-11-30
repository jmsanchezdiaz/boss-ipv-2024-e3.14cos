extends PointLight2D

@onready var timer: Timer = $Timer
@onready var audio = $AudioStreamPlayer2D
@onready var initial_energy = self.energy;

@export var min_wait_time = 1.0
@export var max_wait_time = 2.0

func _ready() -> void:
	timer.start()

func _on_timer_timeout() -> void:
	audio.stop()
	if energy == initial_energy:
		energy = 0;
	else:
		energy = initial_energy
	audio.play(4)
	timer.wait_time = randf_range(min_wait_time, max_wait_time) 
	timer.start()
