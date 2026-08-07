as yet unclassified
testCollectBiomassInCorrectOrder 
 
	cell biomassLevel: 3.
	harvester moveTo: cell.
	harvester2 moveTo: cell.
 
	cell collectHarvest.
 
	self assertHarvesters: (OrderedCollection with: harvester with: harvester2)
		collectedBiomassMatches: #(2 1)

