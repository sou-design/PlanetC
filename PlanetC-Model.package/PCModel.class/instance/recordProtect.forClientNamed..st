as yet unclassified
recordProtect: cellsArray forClientNamed: aName 
	self linkClientNamed: aName toEntityIn: self rangers.
	submittedProtection := cellsArray.
	self cells do: [ :cell | cell isProtected: false ].
	cellsArray do: [ :cellId | (self cells at: cellId) isProtected: true ]