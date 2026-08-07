as yet unclassified
testProgressionOfTwoBiomassAndOneHarvesterQuintupleStep 
 
	harvester moveTo: cell.
	cell biomassLevel: 2.
	5 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 2
 
