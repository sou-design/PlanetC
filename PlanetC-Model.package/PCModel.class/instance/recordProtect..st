as yet unclassified
recordProtect: cellsArray
	self cells do: [ :cell | cell isProtected: false ].
	cellsArray do: [ :cellId | (self cells at: cellId) isProtected: true ].
