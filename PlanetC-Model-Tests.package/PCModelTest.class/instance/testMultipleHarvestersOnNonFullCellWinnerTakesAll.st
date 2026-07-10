as yet unclassified
testMultipleHarvestersOnNonFullCellWinnerTakesAll
	| harvesters totalCollected |
	cell biomassLevel: 2.
	harvesters := self placeHarvestersCount: 3 onCell: cell.
	cell collectHarvest.
	totalCollected := harvesters inject: 0 into: [ :sum :h | sum + h collectedBiomass ].
	self assert: totalCollected equals: 2. 
	cell applyPendingHarvest.
	self assert: cell biomassLevel equals: 0