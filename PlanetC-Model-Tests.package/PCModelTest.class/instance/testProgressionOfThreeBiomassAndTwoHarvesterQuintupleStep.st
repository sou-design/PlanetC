as yet unclassified
testProgressionOfThreeBiomassAndTwoHarvesterQuintupleStep 
 
	harvester moveTo: cell.
	harvester2 moveTo: cell.
	cell biomassLevel: 3.
	5 timesRepeat: [ self performStepOn: cell ].
	self assert: cell biomassLevel equals: 3

 
