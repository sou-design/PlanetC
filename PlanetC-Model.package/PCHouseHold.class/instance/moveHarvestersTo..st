moving
moveHarvestersTo: cellsArray
	| count |
	count := cellsArray size min: children size.
	1 to: count do: [ :i |
		| harvester cellId |
		harvester := children at: i.
		cellId := cellsArray at: i.
		cellId
			ifNil: [ harvester cell ifNotNil: [ harvester leave ] ]
			ifNotNil: [ harvester moveTo: (self cormasModel cells at: cellId) ] ]