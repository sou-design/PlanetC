as yet unclassified
testProgressionOfTwoBiomass 
 
	cell biomassLevel: 2.
	self performStepOn: cell.
	self assert: cell biomassLevel equals: 3
 
