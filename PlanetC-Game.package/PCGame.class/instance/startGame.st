initialization
startGame
	super startGame.
	recorder startSession.
	self saveData: [ recorder saveGame ].
	self broadcastState.
	phase := 'ready'