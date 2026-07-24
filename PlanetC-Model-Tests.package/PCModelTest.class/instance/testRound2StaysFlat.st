tests
testRound2StaysFlat
	cell regrowBiomass.
	cell regrowBiomass.
	self assert: cell biomassLevel equals: 2.
	self assert: cell nonHarvestTime equals: 2