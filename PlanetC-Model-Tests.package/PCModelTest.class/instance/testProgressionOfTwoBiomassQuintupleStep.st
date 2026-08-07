as yet unclassified
testProgressionOfTwoBiomassQuintupleStep 
 
	cell biomassLevel: 2.
	5 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 0
 