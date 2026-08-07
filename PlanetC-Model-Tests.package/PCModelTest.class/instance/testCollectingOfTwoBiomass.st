as yet unclassified
testCollectingOfTwoBiomass 
 
	cell biomassLevel: 2.
	harvester moveTo: cell.
	cell collectHarvest.
	self assert: harvester collectedBiomass equals: 2.