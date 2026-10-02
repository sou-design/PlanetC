initialization
startGame
	harvestHistory := IdentityDictionary new.
	super startGame.
	self broadcastBiomass.
	self broadcastBirds.
	self broadcastProtection.
	self broadcastHarvesters.
	self refreshCormasUI.
	roundProcess := [ ] forkNamed: 'Game started'.
	Processor yield