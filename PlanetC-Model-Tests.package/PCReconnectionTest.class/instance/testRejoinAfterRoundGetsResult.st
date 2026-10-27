as yet unclassified
testRejoinAfterRoundGetsResult
	| result |
	self startGameWith: #('alice' 'bob').
	(self householdOf: 'alice') gains add: 4; add: 6.
	result := (self stateOf: (self join: 'alice')) at: 'roundResult'.
	self assert: (result at: 'round') equals: 2.
	self assert: (result at: 'gain') equals: 6.
	self assert: (result at: 'total') equals: 10