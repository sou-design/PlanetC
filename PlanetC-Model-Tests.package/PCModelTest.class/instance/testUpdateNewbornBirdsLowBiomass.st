tests
testUpdateNewbornBirdsLowBiomass 
 
	cell biomassLevel: 0.
	cell updateNewbornBirds.
	self assert: cell nbNewBorns equals: 0

