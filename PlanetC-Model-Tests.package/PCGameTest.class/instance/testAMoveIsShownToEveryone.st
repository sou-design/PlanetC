tests
testAMoveIsShownToEveryone
	| family chips |
	self phase: 'householdsTurn'.
	self send: (self moveTo: #( 1 1 nil 5 )) from: alice.
	family := self householdOf: alice.
	self assert: (family harvesters at: 1) cell equals: (model cells at: 1).
	self assert: (family harvesters at: 4) cell equals: (model cells at: 5).
	self assert: (model submittedMoves includesKey: family).
	chips := ((bruno lastMessageOfType: 'harvesters') at: 'values') first.
	self assert: chips size equals: 1.
	self assert: (chips first at: 'household') equals: 'alice'.
	self assert: (chips first at: 'count') equals: 2
