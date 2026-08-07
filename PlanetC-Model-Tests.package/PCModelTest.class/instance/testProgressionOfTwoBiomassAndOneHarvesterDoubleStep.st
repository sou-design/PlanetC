as yet unclassified
testProgressionOfTwoBiomassAndOneHarvesterDoubleStep 
 
	harvester moveTo: cell.
	cell biomassLevel: 2.
	self performStepOn: cell.
	self performStepOn: cell.
 
	self assert: cell biomassLevel equals: 2
 
