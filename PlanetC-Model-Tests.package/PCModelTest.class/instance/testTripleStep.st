tests
testTripleStep 
 
	cell biomassLevel: 3.
	self performStepOn: cell.
	self performStepOn: cell.
	self performStepOn: cell.
 
	self
		assert: cell biomassLevel equals: 2;
		assert: cell nbNewBorns equals: 2;
		assert: cell nonHarvestTime equals: 2

 