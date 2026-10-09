tests
testResultsMessage
	| family results |
	family := self householdOf: bruno.
	(family harvesters at: 1) collect: 2.
	model households do: [ :h | h recordGain ].
	model currentRound: 2.
	results := game resultsMessage.
	self assert: (results at: 'type') equals: 'results'.
	self assert: (results at: 'rounds') equals: 1.
	self assert: (results at: 'families') size equals: 2.
	self assert: ((self familyNamed: 'bruno' in: results) at: 'total') equals: 2.
	self assert: ((self familyNamed: 'bruno' in: results) at: 'harvesters') size equals: 4.
	self assert: ((self familyNamed: 'alice' in: results) at: 'total') equals: 0
