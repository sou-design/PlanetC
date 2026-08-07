tests
testProgressionOfZeroBiomassAndOneHarvesterDoubleStep 
 
	harvester moveTo: cell.
	cell biomassLevel: 0.
	self performStepOn: cell.
	self performStepOn: cell.
 
	self assert: cell biomassLevel equals: 0