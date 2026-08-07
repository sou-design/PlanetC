as yet unclassified
testCollectingOfThreeBiomassThreeHarvesters 
 
	cell biomassLevel: 3.
	harvester moveTo: cell.
	harvester2 moveTo: cell.
	harvester3 moveTo: cell.
	cell collectHarvest.
 
	self assertHarvesters: (OrderedCollection with: harvester with: harvester2 with: harvester3)
		collectedBiomassMatches: #(2 1 0)