as yet unclassified
protectCells 
	| cellsToProtect |
	cellsToProtect := self cormasModel cells shuffled first: 3.
	cellsToProtect do: [ :cell | cell isProtected: true ]
