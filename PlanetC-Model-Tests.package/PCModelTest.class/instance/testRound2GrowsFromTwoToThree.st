tests
testRound2GrowsFromTwoToThree
	cell regrowBiomass.  
	cell regrowBiomass.  
	self assert: cell biomassLevel equals: 3.
	self assert: cell nonHarvestTime equals: 2