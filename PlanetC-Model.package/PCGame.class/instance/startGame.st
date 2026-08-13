initialization
startGame
	super startGame.
	self assignRolesToConnectedClients.
	self broadcastBiomass.
	self broadcastBirds.
	self broadcastProtection.
	self broadcastHarvesters.
	self refreshCormasUI.
	self startRoundTimer