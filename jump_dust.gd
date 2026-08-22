extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  
	
func play_effect() -> void:
	frame = 0
	show()
	play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass  

func _on_animation_finished() -> void:
	hide()
