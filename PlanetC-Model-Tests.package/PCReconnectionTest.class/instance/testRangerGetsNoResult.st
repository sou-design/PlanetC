as yet unclassified
testRangerGetsNoResult
	| state |
	self startGameWith: #('alice').
	self join: 'rita'.
	(self clientNamed: 'rita') role: PCRangerRole.
	(self householdOf: 'alice') gains add: 5.
	state := self stateOf: (self join: 'rita').
	self assert: (state at: 'role') equals: 'Ranger'.
	self deny: (state includesKey: 'roundResult')