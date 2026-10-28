initialization
startGame
	self canStart ifFalse: [ ^ self ].
	self cormasModel nbFamilies: (server playersOf: PCHouseHoldRole) size.
	super startGame.
	server assignAgents.
	phase := 'ready'.
	self saveData: [ recorder saveGame ].
	self broadcastState.