tests
testResolveTheRound
	(model cells at: 4) biomassLevel: 3.
	self phase: 'householdsTurn'.
	self send: (self moveTo: #( 4 nil nil nil )) from: alice.
	self phase: 'householdsDone'.
	self clearAllMessages.
	self assert: (game proceed: 0) equals: 'ok'.
	self assert: game phase equals: 'ready'.
	self assert: model currentRound equals: 2.
	self allPlayers do: [ :p |
		self assert: ((p lastMessageOfType: 'roundEnded') at: 'round') equals: 1 ].
	self assert: ((alice lastMessageOfType: 'roundResult') at: 'gain') equals: 2.
	self assert: ((alice lastMessageOfType: 'roundResult') at: 'total') equals: 2.
	self assert: ((bruno lastMessageOfType: 'roundResult') at: 'gain') equals: 0.
	self deny: (rose hasReceived: 'roundResult')
