as yet unclassified
moveHarvestersTo: cellsArray
	| count |
	count := cellsArray size min: children size.
	1 to: count do: [ :i |
		(children at: i) moveTo: (self cormasModel cells at: (cellsArray at: i)) ]