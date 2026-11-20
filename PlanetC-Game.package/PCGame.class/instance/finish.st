game flow
finish
	| model |
	model := self cormasModel.
	((#('ready' 'regenerated' 'ended') includes: phase) and: [ model currentStep > 1 ])
		ifFalse: [ ^ 'notReady' ].
	finished := true.
	model maxSteps: model currentStep - 1.
	phase := 'ended'.
		server broadcast: (self resultsMessage
		at: 'type' put: 'gameOver';
		at: 'ranger' put: rangerRounds asArray;
		at: 'session' put: session;
		yourself).
	server publishState.
	^ 'ok'