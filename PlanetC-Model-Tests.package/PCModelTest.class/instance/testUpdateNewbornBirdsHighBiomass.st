tests
testUpdateNewbornBirdsHighBiomass 
 
	cell biomassLevel: 3.
	cell updateNewbornBirds.
	self assert: cell nbNewBorns equals: 2
