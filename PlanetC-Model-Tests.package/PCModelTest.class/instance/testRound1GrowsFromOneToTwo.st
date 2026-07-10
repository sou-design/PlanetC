tests
testRound1GrowsFromOneToTwo
	cell regrowBiomass.
	self assert: cell biomassLevel equals: 2.
	self assert: cell nonHarvestTime equals: 1