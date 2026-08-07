as yet unclassified
testProgressionOfThreeBiomassQuintupleStep 
 
	cell biomassLevel: 3.
	5 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 0

 
