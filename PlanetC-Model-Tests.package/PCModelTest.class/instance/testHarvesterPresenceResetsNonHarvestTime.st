as yet unclassified
testHarvesterPresenceResetsNonHarvestTime
	cell nonHarvestTime: 2.  
	self placeHarvestersCount: 1 onCell: cell.
	cell updateNonHarvestTime.
	self assert: cell nonHarvestTime equals: 0