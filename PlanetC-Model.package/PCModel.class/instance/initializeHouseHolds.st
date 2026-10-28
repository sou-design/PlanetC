initialization
initializeHouseholds
	1 to: nbFamilies do: [ :i |
		| household |
		household := self newEntity: PCHousehold.
		household tile: (PCTiles family: i).
		1 to: 20 // nbFamilies + (i <= (20 \\ nbFamilies) ifTrue: [ 1 ] ifFalse: [ 0 ]) do: [ :j |
			| harvester |
			harvester := self newEntity: PCHarvester.
			harvester household: household.
			household addChild: harvester ] ]