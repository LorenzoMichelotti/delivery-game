extends Node

@onready var cutscene_scene: PackedScene = preload("res://cutscenes/cutscene.tscn")
@onready var cutscene_player: CutscenePlayer

func on_level_changed():
	cutscene_player = cutscene_scene.instantiate() 
	get_tree().current_scene.get_node("CanvasLayer").add_child.call_deferred(cutscene_player)
