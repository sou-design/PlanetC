as yet unclassified
moveHarvestersTo: cellsArray
	1 to: (cellsArray size min: children size) do: [ :i |
		| cellId |
		cellId := cellsArray at: i.
		cellId ifNotNil: [
			(children at: i) moveTo: (self cormasModel cells at: cellId) ] ]