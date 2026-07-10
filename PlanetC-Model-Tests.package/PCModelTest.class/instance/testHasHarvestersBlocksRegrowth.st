as yet unclassified
testHasHarvestersBlocksRegrowth
	cell biomassLevel: 1.
	cell nonHarvestTime: 0.
	self placeHarvestersCount: 1 onCell: cell.
	cell regrowBiomass.
	self assert: cell biomassLevel equals: 1