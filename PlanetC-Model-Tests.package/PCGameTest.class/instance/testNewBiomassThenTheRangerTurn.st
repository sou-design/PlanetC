tests
testNewBiomassThenTheRangerTurn
	model currentRound: 2.
	self phase: 'newBiomass'.
	self assert: (game proceed: 0) equals: 'ok'.
	self waitForPhase: 'rangerDone'.
	self assert: ((rose lastMessageOfType: 'turn') at: 'turn') equals: 'ranger'.
	self assert: ((rose lastMessageOfType: 'turnEnded') at: 'turn') equals: 'ranger'














