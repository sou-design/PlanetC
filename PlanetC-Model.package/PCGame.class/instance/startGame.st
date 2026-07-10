initialization
startGame
	super startGame.
	self cormasModel applyBiomassMatrix: self cormasModel initialBiomassMatrix.
	self cormasModel installAdultBirds.
	self broadcastBiomass.
	self broadcastBirds