initialization
initialize
	super initialize.
	folder := (FileLocator imageDirectory / 'planetc-data') asFileReference.
	gameId := 1.
	sessionId := DateAndTime now asUnixTime