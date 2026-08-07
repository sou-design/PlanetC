as yet unclassified
testProgressionOfThreeBiomassTripleStep 
 
	cell biomassLevel: 3.
	3 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 2
 
