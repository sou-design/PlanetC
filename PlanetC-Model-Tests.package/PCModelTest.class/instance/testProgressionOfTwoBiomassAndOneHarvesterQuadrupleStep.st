as yet unclassified
testProgressionOfTwoBiomassAndOneHarvesterQuadrupleStep 
 
	harvester moveTo: cell.
	cell biomassLevel: 2.
	4 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 2
 
