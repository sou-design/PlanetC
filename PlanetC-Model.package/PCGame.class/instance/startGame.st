initialization
startGame
	super startGame.
	self assignRolesToConnectedClients.
	self broadcastBiomass.
	self broadcastBirds.
	self refreshCormasUI.
	self startRoundTimer