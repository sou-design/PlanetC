as yet unclassified
testRejoinAfterFinishGetsFinalResults
	| state |
	self startGameWith: #('alice' 'bob').
	(self householdOf: 'alice') gains add: 5.
	self phase: 'ended'.
	game instVarNamed: 'finished' put: true.
	state := self stateOf: (self join: 'alice').
	self assert: (state includesKey: 'finalResults').
	self deny: (state includesKey: 'roundResult')