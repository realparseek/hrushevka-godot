extends Node

var interactions : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is Interaction:
			interactions[child.name.to_lower()] = child
			child.Interacted.connect(_on_interacte)

func _on_interacte(interaction_name : String) -> void:
	var interaction: Interaction = interactions.get(interaction_name.to_lower())
	
	if !interaction:
		return
	
	interaction.interacte()
