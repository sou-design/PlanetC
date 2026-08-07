tests
testUpdateNewbornBirdsWithHarvester 
 
	cell biomassLevel: 3.
	harvester moveTo: cell.
	cell updateNewbornBirds.
	self assert: cell nbNewBorns equals: 0.
