tests
testHarvesterResultsBeforeAnyRound
	| results |
	results := game harvesterResultsFor: (self householdOf: alice).
	self assert: (results allSatisfy: [ :r | (r at: 'gain') = 0 and: [ (r at: 'gains') isEmpty ] ])









