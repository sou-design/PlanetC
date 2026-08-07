as yet unclassified
recordProtect: cellsArray forClientNamed: aName
	cellsArray ifNotNil: [ :cells |
		self linkClientNamed: aName toEntityIn: self rangers.
		submittedProtection := submittedProtection , cells ]