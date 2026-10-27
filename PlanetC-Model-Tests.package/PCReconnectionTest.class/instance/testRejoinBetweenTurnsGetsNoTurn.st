as yet unclassified
testRejoinBetweenTurnsGetsNoTurn
	| state |
	self startGameWith: #('alice' 'bob').
	self phase: 'rangerDone'.
	state := self stateOf: (self join: 'alice').
	self assert: (state at: 'turn') equals: ''.
	self assert: (state at: 'secondsLeft') equals: 0