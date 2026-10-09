tests
testHouseholdsTurnEndsWhenEveryFamilyHasPlayed
	game startHouseholdsTurn: 60.
	self assert: game phase equals: 'householdsTurn'.
	self send: (self moveTo: #( 1 nil nil nil )) from: alice.
	self send: (self moveTo: #( 2 nil nil nil )) from: bruno.
	self waitForPhase: 'householdsDone'












