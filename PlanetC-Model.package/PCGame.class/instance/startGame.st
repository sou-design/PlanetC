initialization
startGame
	super startGame.
	self assignRolesToConnectedClients.
	self runStep.
	self startRoundTimer