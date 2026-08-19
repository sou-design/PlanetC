initialization
startGame
	super startGame.
	self broadcastBiomass.
	self broadcastBirds.
	self broadcastProtection.
	self broadcastHarvesters.
	self refreshCormasUI.
	self startRoundTimer