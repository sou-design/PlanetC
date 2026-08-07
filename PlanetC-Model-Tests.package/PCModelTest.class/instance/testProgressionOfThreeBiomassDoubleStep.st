as yet unclassified
testProgressionOfThreeBiomassDoubleStep 
 
	cell biomassLevel: 3.
	self performStepOn: cell.
	self performStepOn: cell.
 
	self assert: cell biomassLevel equals: 3

 
