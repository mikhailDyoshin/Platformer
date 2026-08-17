extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Manager's ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
 
func on_player_died():
	print("Player died")
