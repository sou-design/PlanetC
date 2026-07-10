initialization
broadcastBiomass
	server broadcast: (Dictionary new
		at: 'type' put: 'biomass';
		at: 'values' put: (self cormasModel cells collect: #biomassLevel) asArray;
		yourself)