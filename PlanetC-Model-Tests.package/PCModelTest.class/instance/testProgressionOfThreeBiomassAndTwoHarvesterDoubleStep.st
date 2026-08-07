as yet unclassified
testProgressionOfThreeBiomassAndTwoHarvesterDoubleStep 
 
	harvester moveTo: cell.
	harvester2 moveTo: cell.
	cell biomassLevel: 3.
	2 timesRepeat: [ self performStepOn: cell ].
 
	self assert: cell biomassLevel equals: 3

 
