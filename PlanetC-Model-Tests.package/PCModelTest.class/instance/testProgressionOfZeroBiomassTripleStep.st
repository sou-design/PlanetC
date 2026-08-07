tests
testProgressionOfZeroBiomassTripleStep 
 
	cell biomassLevel: 0.
	3 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 0