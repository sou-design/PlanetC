as yet unclassified
testTwoHarvestersOnFullCellShareTwoAndOne
	| harvesters totalCollected |
	cell biomassLevel: 3.
	harvesters := self placeHarvestersCount: 2 onCell: cell.
	cell collectHarvest.
	totalCollected := harvesters inject: 0 into: [ :sum :h | sum + h collectedBiomass ].
	self assert: totalCollected equals: 3. 
	cell applyPendingHarvest.
	self assert: cell biomassLevel equals: 1