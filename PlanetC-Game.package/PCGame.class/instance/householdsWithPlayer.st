initialization
householdsWithPlayer
	^ self cormasModel households asArray select: [ :h | (server nameFor: h) notEmpty ]