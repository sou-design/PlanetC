initialization
startGame
	super startGame.
	self saveData: [ recorder saveGame ].
	self broadcastState.
	phase := 'ready'