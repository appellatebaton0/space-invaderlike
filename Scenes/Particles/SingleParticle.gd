class_name SingleParticle extends GPUParticles2D
## Fires off a single time as a oneshot, then queue_frees itself.

func _ready() -> void:
	one_shot = true
	restart()
	finished.connect(queue_free)
