tests
testRejoinBeforeFirstRoundGetsNoResult
	| ws |
	self startGameWith: #('alice' 'bob').
	ws := self join: 'alice'.
	self deny: (ws types includes: 'roundResult')