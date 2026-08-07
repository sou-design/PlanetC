as yet unclassified
testCollectingOfThreeBiomass 
 
	cell biomassLevel: 3.
	harvester moveTo: cell.
	cell collectHarvest.
	self assert: harvester collectedBiomass equals: 2.