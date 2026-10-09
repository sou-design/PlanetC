tests
testTheRangerProtectsZones
	| values |
	model currentRound: 2.
	self send: (Dictionary new at: 'type' put: 'protect'; at: 'cells' put: #( 1 5 7 ); yourself) from: rose.
	self assert: ((model cells select: [ :c | c isProtected ]) collect: [ :c | model cells indexOf: c ]) asArray equals: #( 1 5 7 ).
	values := (alice lastMessageOfType: 'protection') at: 'values'.
	self assert: values size equals: 20.
	self assert: (values at: 5).
	self deny: (values at: 2)
