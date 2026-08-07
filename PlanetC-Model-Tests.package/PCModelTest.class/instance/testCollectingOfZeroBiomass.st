as yet unclassified
testCollectingOfZeroBiomass 
 
	cell biomassLevel: 0.
	harvester moveTo: cell.
	cell collectHarvest.
	self assert: harvester collectedBiomass equals: 0.
