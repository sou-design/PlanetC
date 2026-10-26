initialization
finish
	| model |
	finished := true.
	model := self cormasModel.
	((phase = 'ready' or: [ phase = 'ended' ]) and: [ model currentStep > 1 ])
		ifFalse: [ ^ 'notReady' ].
	model maxSteps: model currentStep - 1.
	phase := 'ended'.
	server broadcast: (self resultsMessage
		at: 'type' put: 'gameOver';
		at: 'ranger' put: rangerRounds asArray;
		yourself).
	^ 'ok'