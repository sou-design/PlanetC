initialization
initializeHouseHolds
| colors |
	colors := {
    CMColor fromHexString: 'E63946'.  
    CMColor fromHexString: '1D3557'.  
    CMColor fromHexString: '6B2D0E'.  
    CMColor fromHexString: 'FF6B9D'.  
    CMColor fromHexString: '00B4D8' }.
	1 to: nbFamilies do: [ :i |
		| household |
		household := self newEntity: PCHouseHold.
		household color: (colors at: i).
		1 to: 4 do: [ :j |
			| harvester |
			harvester := self newEntity: PCHarvester.
			harvester moveTo: self cells atRandom.
			harvester household: household.
			household addChild: harvester ] ]