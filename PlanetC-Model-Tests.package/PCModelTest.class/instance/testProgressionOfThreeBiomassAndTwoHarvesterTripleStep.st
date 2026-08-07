as yet unclassified
testProgressionOfThreeBiomassAndTwoHarvesterTripleStep 
 
	harvester moveTo: cell.
	harvester2 moveTo: cell.
	cell biomassLevel: 3.
	3 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 3

 
