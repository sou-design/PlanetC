as yet unclassified
testProgressionOfTwoBiomassAndOneHarvesterTripleStep 
 
	harvester moveTo: cell.
	cell biomassLevel: 2.
	3 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 2
 