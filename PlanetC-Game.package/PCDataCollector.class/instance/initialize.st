initialization
initialize
	super initialize.
	folder := (FileLocator imageDirectory / 'planetc-data') asFileReference.
	gameId := UUID new asString first: 8.
	sessionId := UUID new asString first: 8.