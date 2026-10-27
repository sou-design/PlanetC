initialization
startGame
	self canStart ifFalse: [ ^ self ].
	super startGame.
	server assignAgents.
	phase := 'ready'.
	self saveData: [ recorder saveGame ].
	self broadcastState.