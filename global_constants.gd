class_name GlobalConstants
extends RefCounted

# grid
const GRID_SIZE = 8  


# actor
enum ACTOR_TYPES {
	PLAYER,
	ENEMY,
	FRIEND,
	HAZARD
}
const ACTOR_COLORS = {
	GlobalConstants.ACTOR_TYPES.PLAYER: Color.WHITE,
	GlobalConstants.ACTOR_TYPES.ENEMY: Color.RED,
	GlobalConstants.ACTOR_TYPES.HAZARD: Color.RED,
	GlobalConstants.ACTOR_TYPES.FRIEND: Color.LIME_GREEN
}


# bullet
enum BULLET_SPEED {
	FAST,
	SLOW
}
const BULLET_SPEEDS = {
	BULLET_SPEED.FAST: {
		"speed": 200,
		"friction": 8,
		"acceleration": 70
	},
	BULLET_SPEED.SLOW: {
		"speed": 75,
		"friction": .005,
		"acceleration": 25
	}
}
