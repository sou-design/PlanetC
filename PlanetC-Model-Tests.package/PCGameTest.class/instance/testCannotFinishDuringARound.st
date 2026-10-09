tests
testCannotFinishDuringARound
	model currentRound: 2.
	#( 'lobby' 'newBiomass' 'rangerTurn' 'rangerDone' 'householdsTurn' 'householdsDone' ) do: [ :phase |
		self phase: phase.
		self assert: game finish equals: 'notReady' ]






