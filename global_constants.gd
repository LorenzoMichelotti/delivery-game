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
	SLOW,
	VERY_FAST
}
const BULLET_SPEEDS = {
	BULLET_SPEED.VERY_FAST: {
		"speed": 500,
		"friction": 16,
		"acceleration": 120
	},
	BULLET_SPEED.FAST: {
		"speed": 200,
		"friction": 8,
		"acceleration": 70
	},
	BULLET_SPEED.SLOW: {
		"speed": 50,
		"friction": .00005,
		"acceleration": 15
	}
}

# targets
enum TARGET_TYPES {
	NONE,
	TANK,
	CAR,
	TOWER,
	ANY
}
