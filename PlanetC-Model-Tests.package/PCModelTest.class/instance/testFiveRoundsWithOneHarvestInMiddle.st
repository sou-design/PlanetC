as yet unclassified
testFiveRoundsWithOneHarvestInMiddle
	cell regrowBiomass. 
	self assert: cell biomassLevel equals: 2.

	cell regrowBiomass. 
	self assert: cell biomassLevel equals: 2.

	self placeHarvestersCount: 1 onCell: cell.
	cell collectHarvest.
	self assert: cell biomassLevel equals: 2.

	cell regrowBiomass. 
	self assert: cell biomassLevel equals: 2.

	cell regrowBiomass.
	self assert: cell biomassLevel equals: 2.