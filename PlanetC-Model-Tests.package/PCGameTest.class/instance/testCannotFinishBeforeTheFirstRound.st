tests
testCannotFinishBeforeTheFirstRound
	self phase: 'ready'.
	self assert: game finish equals: 'notReady'.
	self assert: game phase equals: 'ready'





