as yet unclassified
testInitialize 
 
	self assert: ((cell biomassLevel >= 0) and: (cell biomassLevel <= 3)).
	self assert: cell nbNewBorns equals: 0.
	self assert: cell nonHarvestTime equals: 0.
