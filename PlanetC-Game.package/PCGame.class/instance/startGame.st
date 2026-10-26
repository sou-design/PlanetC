initialization
startGame
	self canStart ifFalse: [ ^ self ].
	super startGame.
	server assignAgents.
	self saveData: [ recorder saveGame ].
	self broadcastState.
	phase := 'ready'