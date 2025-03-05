class_name GlobalConstants
extends RefCounted

const GRID_SIZE = 8  

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
