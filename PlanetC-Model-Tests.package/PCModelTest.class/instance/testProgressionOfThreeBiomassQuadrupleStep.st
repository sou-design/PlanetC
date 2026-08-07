as yet unclassified
testProgressionOfThreeBiomassQuadrupleStep 
 
	cell biomassLevel: 3.
	4 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 1

 
