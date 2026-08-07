as yet unclassified
moveHarvestersTo: cellsArray
	| count |
	count := cellsArray size min: children size.
	1 to: count do: [ :i |
		(cellsArray at: i) ifNotNil: [ :cellId |
			(children at: i) moveTo: (self cormasModel cells at: cellId) ] ]