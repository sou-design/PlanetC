as yet unclassified
recordMove: cellsArray forClientNamed: aName
	| household |
	cellsArray ifNil: [ ^ self ].
	household := self householdForClientNamed: aName.
	household ifNil: [ ^ self ].
	submittedMoves at: household put: cellsArray