class_name UpgradeNode
extends Button

@export var parent_upgrade: UpgradeNode
@export var upgrade_resource: UpgradeResource

@onready var sprite_2d = $Sprite2D
@onready var label = $Label
@onready var panel = $Panel
@onready var tooltip_container = $TooltipContainer
@onready var line_2d: Line2D
@onready var upgrade_title = $TooltipContainer/Tooltip/VBoxContainer/UpgradeTitle
@onready var upgrade_description = $TooltipContainer/Tooltip/VBoxContainer/ScrollContainer/UpgradeDescription
@onready var money_label = $TooltipContainer/Tooltip/VBoxContainer/MoneyLabel


var upgrade: UpgradeResource
var enabled: bool = false:
	set(new_value):
		enabled = new_value
signal level_changed(parent_upgrade_current_level: int)
signal upgrade_changed(upgrade: UpgradeResource)
var mouse_inside_button: bool = false
var mouse_inside_tooltip: bool = false

func _ready():
	if upgrade_resource != null:
		upgrade_changed.connect(PlayerManager.on_upgrade_changed)
		upgrade = upgrade_resource.duplicate()
		if PlayerManager.attributes.upgrade_data.upgrades.has(upgrade.id):
			panel.show_behind_parent = true
			upgrade = PlayerManager.attributes.upgrade_data.upgrades.get(upgrade.id)
			update_upgrade_button.call_deferred()
		upgrade_title.text = upgrade.name
		print(upgrade.cost)
		money_label.text = "$" + str(upgrade.cost)
		upgrade_description.text = upgrade.description.replace("{1}", str(upgrade.bonus_value_per_level * (upgrade.current_level + 1)))
	line_2d = Line2D.new()
	visibility_changed.connect(func(): line_2d.hide() if not visible else line_2d.show())
	line_2d.add_point(get_global_transform().affine_inverse() * get_global_transform() * get_rect().get_center())
	if parent_upgrade != null:
		line_2d.add_point(get_global_transform().affine_inverse() * get_global_transform() * parent_upgrade.get_rect().get_center())
		_on_parent_upgrade_level_changed(parent_upgrade.upgrade.current_level)
		parent_upgrade.level_changed.connect(_on_parent_upgrade_level_changed)
		parent_upgrade.add_sibling.call_deferred(line_2d)
		return
	enabled = true
	panel.show_behind_parent = true
	add_sibling.call_deferred(line_2d)

func _process(delta):
	if mouse_inside_button:
		tooltip_container.show()
	if not mouse_inside_button and not mouse_inside_tooltip:
		tooltip_container.hide()

func add_level():
	if not enabled or upgrade.current_level == upgrade.max_level or upgrade.cost > PlayerManager.money:
		return
	PlayerManager.money -= upgrade.cost
	panel.show_behind_parent = true
	upgrade.current_level += 1
	if upgrade.current_level > upgrade.max_level:
		upgrade.current_level = upgrade.max_level
	upgrade.apply()
	upgrade_changed.emit(upgrade)
	level_changed.emit(upgrade.current_level)
	update_upgrade_button()

func update_upgrade_button():
	upgrade_description.text = upgrade.description.replace("{1}", str(upgrade.bonus_value_per_level * upgrade.current_level + 1))
	label.text = str(upgrade.current_level) + "/" + str(upgrade.max_level)
	money_label.text = "$" + str(upgrade.cost * (upgrade.current_level + 1))

func _on_parent_upgrade_level_changed(parent_upgrade_current_level: int):
	if parent_upgrade_current_level < 1:
		enabled = false
		hide()
	else:
		enabled = true
		show()

func _on_pressed():
	add_level()

func _on_mouse_entered():
	mouse_inside_button = true

func _on_mouse_exited():
	mouse_inside_button = false


func _on_tooltip_container_mouse_entered():
	mouse_inside_tooltip = true

func _on_tooltip_container_mouse_exited():
	mouse_inside_tooltip = false
