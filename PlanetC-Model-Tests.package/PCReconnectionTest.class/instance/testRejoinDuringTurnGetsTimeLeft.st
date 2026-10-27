as yet unclassified
testRejoinDuringTurnGetsTimeLeft
	| state |
	self startGameWith: #('alice' 'bob').
	self phase: 'householdsTurn'.
	self turnEndsIn: 30 seconds.
	state := self stateOf: (self join: 'alice').
	self assert: (state at: 'turn') equals: 'households'.
	self assert: (state at: 'round') equals: model currentStep.
	self assert: ((state at: 'secondsLeft') between: 28 and: 30)