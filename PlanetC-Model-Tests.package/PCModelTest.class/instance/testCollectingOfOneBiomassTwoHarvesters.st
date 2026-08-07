as yet unclassified
testCollectingOfOneBiomassTwoHarvesters 
 
	cell biomassLevel: 1.
	harvester moveTo: cell.
	harvester2 moveTo: cell.
	cell collectHarvest.
 
	self assertHarvesters: (OrderedCollection with: harvester with: harvester2)
		collectedBiomassMatches: #(1 0)