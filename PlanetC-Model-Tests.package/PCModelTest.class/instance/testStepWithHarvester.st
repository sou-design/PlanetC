tests
testStepWithHarvester
 
	harvester moveTo: cell.
	cell biomassLevel: 3.
	1 to: 5 do: [ :tmp1 | self performStepOn: cell ].
	self
		assert: cell biomassLevel equals: 3;
		assert: cell nbNewBorns equals: 0;
		assert: cell nonHarvestTime equals: 0