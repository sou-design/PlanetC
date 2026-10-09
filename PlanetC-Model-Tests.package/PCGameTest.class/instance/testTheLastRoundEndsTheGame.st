tests
testTheLastRoundEndsTheGame
	model maxRounds: 1.
	self phase: 'householdsDone'.
	game proceed: 0.
	self assert: game phase equals: 'ended'
