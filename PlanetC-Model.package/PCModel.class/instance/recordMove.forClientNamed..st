as yet unclassified
recordMove: cellsArray forClientNamed: aName
	| household |
	household := self linkClientNamed: aName toEntityIn: self households.
	Transcript showCr: 'recordMove household: ', household identityHash asString, ' name: ', household name.
	submittedMoves at: household put: cellsArray.
	household moveHarvestersTo: cellsArray