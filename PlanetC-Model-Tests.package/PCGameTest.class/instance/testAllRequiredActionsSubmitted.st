tests
testAllRequiredActionsSubmitted
	self phase: 'householdsTurn'.
	self deny: game allRequiredActionsSubmitted.
	self send: (self moveTo: #( 1 nil nil nil )) from: alice.
	self deny: game allRequiredActionsSubmitted.
	self send: (self moveTo: #( 2 nil nil nil )) from: bruno.
	self assert: game allRequiredActionsSubmitted
