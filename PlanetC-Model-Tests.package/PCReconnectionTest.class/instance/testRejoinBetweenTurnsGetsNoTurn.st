tests
testRejoinBetweenTurnsGetsNoTurn
	| ws |
	self startGameWith: #('alice' 'bob').
	self phase: 'rangerDone'.
	ws := self join: 'alice'.
	self deny: (ws types includes: 'turn')