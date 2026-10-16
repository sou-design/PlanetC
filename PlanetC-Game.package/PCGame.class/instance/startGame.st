initialization
startGame
	super startGame.
	server assignAgents.
	self saveData: [ recorder saveGame ].
	self broadcastState.
	phase := 'ready'