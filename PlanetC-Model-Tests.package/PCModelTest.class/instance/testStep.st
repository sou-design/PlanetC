tests
testStep 
 
	cell biomassLevel: 3.
	self performStepOn: cell.
 
	self assert: cell biomassLevel equals: 3.
	self assert: cell nbNewBorns equals: 2.
	self assert: cell nonHarvestTime equals: 1.