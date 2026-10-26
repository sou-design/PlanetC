tests
testRejoinDuringTurnGetsTimeLeft
	| ws turn |
	self startGameWith: #('alice' 'bob').
	self phase: 'householdsTurn'.
	self turnEndsIn: 30 seconds.
	ws := self join: 'alice'.
	turn := ws messageOfType: 'turn'.
	self assert: (turn at: 'turn') equals: 'households'.
	self assert: (turn at: 'round') equals: model currentStep.
	self assert: ((turn at: 'seconds') between: 28 and: 30)