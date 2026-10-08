accessing
finish
	"End the game after the last played round. Answer 'ok' or 'notReady'"
	| model |
	model := self cormasModel.
	((phase = 'ready' or: [ phase = 'ended' ]) and: [ model currentRound > 1 ])
		ifFalse: [ ^ 'notReady' ].
	model maxRounds: model currentRound - 1.
	phase := 'ended'.
	server broadcast: (Dictionary new
		at: 'type' put: 'gameOver';
		at: 'rounds' put: model currentRound - 1;
		yourself).
	^ 'ok'