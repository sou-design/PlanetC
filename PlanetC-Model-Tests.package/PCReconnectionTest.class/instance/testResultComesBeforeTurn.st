tests
testResultComesBeforeTurn
	| ws |
	self startGameWith: #('alice' 'bob').
	(self householdOf: 'alice') gains add: 5.
	self phase: 'rangerTurn'.
	self turnEndsIn: 30 seconds.
	ws := self join: 'alice'.
	self assert: (ws types indexOf: 'roundResult') < (ws types indexOf: 'turn')