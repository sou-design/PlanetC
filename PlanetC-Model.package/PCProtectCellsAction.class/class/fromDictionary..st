accessing
fromDictionary: aDictionary

	| cellsToProtect |
	
	cellsToProtect := aDictionary
		at: 'cells'
		ifAbsent: [ self error: 'Invalid JSON! The message must contain a cells field' ].
		
	^ self new
		cells: cellsToProtect;
		yourself