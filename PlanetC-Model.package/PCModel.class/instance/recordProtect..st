as yet unclassified
recordProtect: cellsArray
	currentStep = 1 ifTrue: [ ^ self ].
	self cells do: [ :cell | cell isProtected: false ].
	cellsArray do: [ :cellId | (self cells at: cellId) isProtected: true ].