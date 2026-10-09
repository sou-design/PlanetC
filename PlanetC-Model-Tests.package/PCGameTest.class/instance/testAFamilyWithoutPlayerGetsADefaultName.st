path commands
testAFamilyWithoutPlayerGetsADefaultName
	| names |
	self disconnectFromServer: bruno.
	names := ((game resultsMessage at: 'families') collect: [ :f | f at: 'name' ]) asArray.
	self assert: (names includes: 'alice').
	self assert: (names anySatisfy: [ :n | n beginsWith: 'Family ' ])
 

