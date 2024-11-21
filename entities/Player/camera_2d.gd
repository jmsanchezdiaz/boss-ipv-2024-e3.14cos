extends Camera2D


@export var shake_intensity: float = 10.0
@export var shake_duration: float = 1
@export var shake_decay: float = 10.0  # Controla el decaimiento de la intensidad

var _shake_timer: float = 0.0
var _current_intensity: float = 0.0
var _original_offset: Vector2 = Vector2.ZERO

# Método para iniciar el shake
func start_shake():
	_shake_timer = shake_duration  # Reinicia el temporizador cada vez que se emite la señal
	_current_intensity = shake_intensity  # Reinicia la intensidad
	_original_offset = offset  # Guarda la posición original de la cámara

# Lógica para actualizar el shake
func _process(delta: float) -> void:
	if _shake_timer > 0:
		_shake_timer -= delta  # Disminuye el tiempo restante del shake
		_current_intensity = lerp(_current_intensity, 0.0, delta * shake_decay)  # Reduce gradualmente la intensidad
		var random_x = randf_range(-1, 1) * _current_intensity
		var random_y = randf_range(-1, 1) * _current_intensity
		offset = _original_offset + Vector2(random_x, random_y)  # Aplica el movimiento aleatorio
	else:
		offset = _original_offset  # Restaura la posición original de la cámara
