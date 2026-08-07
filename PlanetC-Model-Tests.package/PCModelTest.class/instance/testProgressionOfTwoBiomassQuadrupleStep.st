as yet unclassified
testProgressionOfTwoBiomassQuadrupleStep 
 
	cell biomassLevel: 2.
	4 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 1
 