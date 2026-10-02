initialization
startGame
	super startGame.
	self broadcastState.
	phase := 'ready'