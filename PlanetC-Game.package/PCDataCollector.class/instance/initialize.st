initialization
initialize
	super initialize.
	folder := (FileLocator imageDirectory / 'planetc-data') asFileReference.
	gameId := UUID new asString.
	sessionId := UUID new asString.