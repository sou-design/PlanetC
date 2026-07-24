as yet unclassified
testThreeUnharvestedTurnsGrowFlatThenDecline
	cell regrowBiomass.
	self assert: cell biomassLevel equals: 2.
	
	cell regrowBiomass. 
	self assert: cell biomassLevel equals: 2.
 
	cell regrowBiomass.
	self assert: cell biomassLevel equals: 1.
 