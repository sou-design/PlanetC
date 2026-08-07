as yet unclassified
testProgressionOfThreeBiomassAndTwoHarvesterQuadrupleStep 
 
	harvester moveTo: cell.
	harvester2 moveTo: cell.
	cell biomassLevel: 3.
	4 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 3

 
