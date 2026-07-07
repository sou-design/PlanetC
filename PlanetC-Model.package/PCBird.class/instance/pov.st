accessing
pov 
	<pov>
	^ state = #adult
		ifTrue: [
	^ CMPointOfView new
		tile: (PCTiles bird);
		size: 0.4;
		yourself
		]
	ifFalse: [

	^ CMPointOfView new
		tile: (PCTiles poussin);
		size: 0.2;
		yourself
	]

