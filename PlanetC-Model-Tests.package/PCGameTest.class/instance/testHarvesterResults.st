tests
testHarvesterResults
	| family results |
	family := self householdOf: alice.
	(family harvesters at: 2) collect: 3.
	family recordGain.
	results := game harvesterResultsFor: family.
	self assert: results size equals: 4.
	self assert: ((results at: 2) at: 'name') equals: 'H2'.
	self assert: ((results at: 2) at: 'gain') equals: 3.
	self assert: ((results at: 2) at: 'total') equals: 3.
	self assert: ((results at: 1) at: 'gain') equals: 0








