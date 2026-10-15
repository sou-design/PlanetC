game flow
beginNextRound
	self cormasModel updateEnvironment.
	server broadcast: (Dictionary new
		at: 'type' put: 'round';
		at: 'round' put: self cormasModel currentStep;
		at: 'maxRounds' put: self cormasModel maxSteps;
		yourself).
	self broadcastState