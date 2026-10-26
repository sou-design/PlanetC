tests
testRangerGetsNoResult
	| ws |
	self startGameWith: #('alice').
	self join: 'rita'.
	(self clientNamed: 'rita') role: PCRangerRole.
	(self householdOf: 'alice') gains add: 5.
	ws := self join: 'rita'.
	self deny: (ws types includes: 'roundResult')