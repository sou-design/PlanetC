tests
testHouseholdsReceiveTheirMembersResults
	| members |
	(model cells at: 4) biomassLevel: 3.
	self phase: 'householdsTurn'.
	self send: (self moveTo: #( 4 nil nil nil )) from: alice.
	self phase: 'householdsDone'.
	game proceed: 0.
	members := (alice lastMessageOfType: 'roundResult') at: 'harvesters'.
	self assert: members size equals: 4.
	self assert: ((members collect: [ :h | h at: 'name' ]) asArray) equals: #( 'H1' 'H2' 'H3' 'H4' ).
	self assert: ((members first) at: 'gain') equals: 2.
	self assert: ((members first) at: 'gains') asArray equals: #( 2 ).
	self assert: ((members second) at: 'total') equals: 0











