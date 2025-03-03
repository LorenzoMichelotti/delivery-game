class_name CutsceneDialogueResource
extends Resource

@export var character: ActorResource
@export var text: String
@export var choices: Array[CutsceneDialogueChoiceResource] = []
@export var next_dialogue: CutsceneDialogueResource
@export var gameover: bool = false
