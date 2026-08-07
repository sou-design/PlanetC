as yet unclassified
testCollectingOfOneBiomass 
 
	cell biomassLevel: 1.
	harvester moveTo: cell.
	cell collectHarvest.
	self assert: harvester collectedBiomass equals: 1