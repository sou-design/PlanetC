accessing
pov 
	<pov>
	^ CMPointOfView new
		tile: (household isNil 
			ifFalse: [ household tile ]);
		size: 0.3;
		yourself

