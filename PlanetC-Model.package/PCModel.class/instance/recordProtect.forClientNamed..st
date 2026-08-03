as yet unclassified
recordProtect: cellsArray forClientNamed: aName
	cellsArray ifNotNil: [ :cells |
		| ranger |
		ranger := self linkClientNamed: aName toEntityIn: self rangers.
		submittedProtection at: ranger put: cells ]