game flow
beginNextRound
	self cormasModel beginRound.
	server broadcast: (Dictionary new
		at: 'type' put: 'round';
		at: 'round' put: self cormasModel currentRound;
		at: 'maxRounds' put: self cormasModel maxRounds;
		yourself).
	self broadcastBiomass; broadcastBirds; broadcastProtection; broadcastHarvesters; refreshCormasUI