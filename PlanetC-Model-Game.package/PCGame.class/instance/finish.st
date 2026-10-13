initialization
finish
	| model |
	model := self cormasModel.
	((phase = 'ready' or: [ phase = 'ended' ]) and: [ model currentRound > 1 ])
		ifFalse: [ ^ 'notReady' ].
	model maxRounds: model currentRound - 1.
	phase := 'ended'.
	server broadcast: (self resultsMessage
		at: 'type' put: 'gameOver';
		at: 'ranger' put: rangerRounds asArray;
		yourself).
	^ 'ok'