as yet unclassified
recordMove: cellsArray forClientNamed: aName
	| household |
	household := self linkClientNamed: aName toEntityIn: self households.
	submittedMoves at: household put: cellsArray