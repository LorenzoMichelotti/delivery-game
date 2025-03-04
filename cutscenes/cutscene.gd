class_name CutscenePlayer
extends Control

@export var cutscene_resource: CutsceneResource
@export var game_ui: Control
@onready var poirtrait_left = $BackDrop/PoirtraitLeft
@onready var actor_name_label = $BackDrop/DialogueBox/ActorNameLabel
@onready var dialogue_text_label = $BackDrop/DialogueBox/DialogueTextLabel
@onready var choice_buttons = [$BackDrop/DialogueBox/FirstChoiceButton, $BackDrop/DialogueBox/SecondChoiceButton]

var is_playing = false
var current_dialogue: CutsceneDialogueResource

func _ready():
	hide()
	for i in range(choice_buttons.size()):
		choice_buttons[i].pressed.connect(_load_choice_dialogue.bind(i))

func play(new_cutscene: CutsceneResource, new_game_ui: Control):
	GameManager.set_game_mode(GameManager.GAMEMODE.CUTSCENE)
	if new_cutscene == null:
		$Transition/DayLabel.text = "DAY " + str(GameManager.current_day).pad_zeros(2)
		$Transition/GoalDescription.text = GameManager.current_completion_goal.goal_description
		$Transition/GoalDescription.show()
		$Transition/DayLabel.show()
		$Transition/GoalTitle.show()
		$AnimationPlayer.play("no_cutscene_transition")
		print("no_cutscene_transition")
		return
	if CutsceneManager.watched_cutscenes.has(new_cutscene) or GameManager.skip_cutscenes:
		$AnimationPlayer.play("no_goals_no_cutscene_transition")
		print("no_goals_no_cutscene_transition")
		return
	is_playing = true
	CutsceneManager.watched_cutscenes.append(new_cutscene)
	cutscene_resource = new_cutscene
	current_dialogue = null
	game_ui = new_game_ui
	game_ui.hide()
	if cutscene_resource.intro:
		print("intro_cutscene")
		# show DAY if this is a level start cutscene
		$Transition/DayLabel.text = "DAY " + str(GameManager.current_day).pad_zeros(2)
		$Transition/DayLabel.show()
		$Transition/GoalDescription.hide()
		$Transition/GoalTitle.hide()
	else:
		$Transition/GoalDescription.hide()
		$Transition/DayLabel.hide()
		$Transition/GoalTitle.hide()
	_load_next_dialogue()
	$AnimationPlayer.play("appear")

func _input(event):
	if GameManager.current_game_mode == GameManager.GAMEMODE.CUTSCENE and is_playing and (Input.is_action_just_released("click") or Input.is_action_just_released("space")) and not has_choice_to_make():
		_load_next_dialogue()

func _load_next_dialogue(get_next = true):
	if current_dialogue == null:
		# load the first dialogue
		current_dialogue = cutscene_resource.scene[0]
	elif get_next:
		# check if reached end of dialogues
		if current_dialogue.gameover:
			_resume_gameplay()
			return
		if current_dialogue.next_dialogue == null:
			_end_cutscene()
			return
		# go to the next dialogue
		current_dialogue = current_dialogue.next_dialogue
	print("loading next dialogue")
	$AnimationPlayer.play("next_dialogue")
	var dialogue: CutsceneDialogueResource = current_dialogue
	poirtrait_left.texture = dialogue.character.poirtrait
	actor_name_label.text = dialogue.character.name
	actor_name_label.add_theme_color_override("font_color", dialogue.character.color)
	dialogue_text_label.text = dialogue.text
	if has_choice_to_make():
		for i in range(dialogue.choices.size()):
			var choice: CutsceneDialogueChoiceResource = dialogue.choices[i]
			var button: Button = choice_buttons[i]
			button.text = choice.text
			button.show()
	else:
		for button in choice_buttons:
			button.hide()

func _load_choice_dialogue(choice_index: int):
	if not has_choice_to_make():
		_load_next_dialogue()
	var choice_dialogue = current_dialogue.choices[choice_index].result_dialogue if current_dialogue.choices[choice_index].result_dialogue != null else current_dialogue.next_dialogue
	if  current_dialogue == null:
		_end_cutscene()
		return
	if current_dialogue.gameover:
		_resume_gameplay()
		return
	if  choice_dialogue == null:
		_end_cutscene()
		return
	current_dialogue = choice_dialogue
	_load_next_dialogue(false)

func has_choice_to_make():
	if current_dialogue == null: return
	return current_dialogue.choices.size() > 0

func _end_cutscene():
	# cutscene ended
	print("end cutscene")
	if not current_dialogue.gameover:
		# show points if this is not a level ending cutscene
		$Transition/GoalDescription.text = GameManager.current_completion_goal.goal_description
		$Transition/DayLabel.text = "DAY " + str(GameManager.current_day).pad_zeros(2)
		$Transition/GoalDescription.show()
		$Transition/DayLabel.show()
		$Transition/GoalTitle.show()
	else:
		$Transition/GoalDescription.hide()
		$Transition/DayLabel.hide()
		$Transition/GoalTitle.hide()
	is_playing = false
	#GameManager.set_watched_level_cutscene()
	$AnimationPlayer.play("disappear")

func _resume_gameplay():
	if (current_dialogue and current_dialogue.gameover) or GameManager.verify_level_win_condition() or (GameManager.skip_cutscenes and PlayerManager.tank_empty):
		if game_ui:
			game_ui.hide()
		GameManager.set_game_mode(GameManager.GAMEMODE.GAMEOVER)
	else:
		if game_ui:
			game_ui.show()
		GameManager.set_game_mode(GameManager.GAMEMODE.PLAYING)
