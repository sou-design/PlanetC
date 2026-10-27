broadcast
broadcastState

	self broadcastBiomass.
	self broadcastBirds.
	self broadcastProtection.
	self broadcastHarvesters.
	server publishState.
	self refreshCormasUI