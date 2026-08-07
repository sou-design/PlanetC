as yet unclassified
testProgressionOfThreeBiomassAndTwoHarvester 
 
	harvester moveTo: cell.
	harvester2 moveTo: cell.
	cell biomassLevel: 3.
	self performStepOn: cell.
	self assert: cell biomassLevel equals: 3

 
