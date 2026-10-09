tests
testProtectionIsRemovedWhenTheNextRoundBegins
	model currentRound: 2.
	model recordProtect: #( 1 2 ).
	self phase: 'ready'.
	game proceed: 30.
	self assert: (model cells noneSatisfy: [ :c | c isProtected ])
















