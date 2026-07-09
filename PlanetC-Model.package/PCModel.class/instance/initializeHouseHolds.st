initialization
initializeHouseHolds
	1 to: nbFamilies do: [ :i |
		| household selector |
		household := self newEntity: PCHouseHold.
		selector := ('f' , i printString) asSymbol.
		household tile: (PCTiles perform: selector).
		1 to: 4 do: [ :j |
			| harvester |
			harvester := self newEntity: PCHarvester.
			harvester household: household.
			household addChild: harvester ] ]