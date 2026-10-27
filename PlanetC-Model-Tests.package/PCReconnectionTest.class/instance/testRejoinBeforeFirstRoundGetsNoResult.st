as yet unclassified
testRejoinBeforeFirstRoundGetsNoResult
	self startGameWith: #('alice' 'bob').
	self deny: ((self stateOf: (self join: 'alice')) includesKey: 'roundResult')