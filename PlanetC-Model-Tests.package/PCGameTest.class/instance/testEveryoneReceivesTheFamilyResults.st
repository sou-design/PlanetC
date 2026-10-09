tests
testEveryoneReceivesTheFamilyResults
	| results |
	(model cells at: 4) biomassLevel: 3.
	self phase: 'householdsTurn'.
	self send: (self moveTo: #( 4 nil nil nil )) from: alice.
	self phase: 'householdsDone'.
	game proceed: 0.
	results := gm lastMessageOfType: 'results'.
	self assert: (results at: 'rounds') equals: 1.
	self assert: ((self familyNamed: 'alice' in: results) at: 'total') equals: 2.
	self assert: ((self familyNamed: 'bruno' in: results) at: 'gains') asArray equals: #( 0 ).
	self assert: (alice hasReceived: 'results').
	self deny: (rose hasReceived: 'results')






