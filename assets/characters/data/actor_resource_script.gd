class_name ActorResource
extends Resource

@export var name: String = "Actor"
@export var poirtrait: Texture = preload("res://assets/characters/actors/morgana/poirtraits/morgana1.png")
@export var color: Color = Color.PURPLE
@export var objects: Array[Texture] = [
	preload("res://assets/characters/actors/morgana/box1.png"),
	preload("res://assets/characters/actors/morgana/box2.png"),
	preload("res://assets/characters/actors/morgana/box3.png")
]
