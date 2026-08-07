as yet unclassified
testProgressionOfTwoBiomassDoubleStep 
 
	cell biomassLevel: 2.
	self performStepOn: cell.
	self performStepOn: cell.
 
	self assert: cell biomassLevel equals: 3
 