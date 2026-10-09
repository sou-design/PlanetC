tests
testRoundOneStartsWithTheHouseholdsTurn
	self phase: 'ready'.
	self assert: (game proceed: 0) equals: 'ok'.
	self waitForPhase: 'householdsDone'.
	self assert: ((alice lastMessageOfType: 'round') at: 'round') equals: 1.
	self assert: ((alice lastMessageOfType: 'turn') at: 'turn') equals: 'households'.
	self deny: ((rose messagesOfType: 'turn') anySatisfy: [ :m | (m at: 'turn') = 'ranger' ]).
	self assert: (alice hasReceived: 'turnEnded').
	self assert: (gm hasReceived: 'gmMoves')
