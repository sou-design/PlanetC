as yet unclassified
startSecondSession
	(phase = 'ended' and: [ session ~= 2 ]) ifFalse: [ ^ 'notReady' ].
	self initializeSimulation.
	(self cormasModel parameters detect: [ :p | p name = #maxSteps ]) setDefaultValueFor: self cormasModel.
	finished := false.
	rangerRounds := OrderedCollection new.
	householdsWithMove := Set new.
	server assignAgents.
	session := 2.
	phase := 'ready'.
	server broadcast: (Dictionary new
		at: 'type' put: 'sessionStarted';
		at: 'session' put: session;
		at: 'maxRounds' put: self cormasModel maxSteps;
		yourself).
	server broadcastStartGame.
	self broadcastState.
	^ 'ok'