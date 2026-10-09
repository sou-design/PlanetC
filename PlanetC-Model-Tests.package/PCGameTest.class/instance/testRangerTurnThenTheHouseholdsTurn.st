tests
testRangerTurnThenTheHouseholdsTurn
	model currentRound: 2.
	self phase: 'rangerDone'.
	self assert: (game proceed: 0) equals: 'ok'.
	self waitForPhase: 'householdsDone'.
	self assert: ((alice lastMessageOfType: 'turn') at: 'turn') equals: 'households'

















