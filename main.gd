extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for s in $Spikes.get_children():
		s.player_died.connect(GameManager.on_player_died)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
