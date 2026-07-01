accessing
pov 
	<pov>
	^ CMPointOfView new
		color: (household isNil 
			ifTrue:  [ CMColor red ] 
			ifFalse: [ household color ]);
		shape: #square;
		size: 0.21;
		yourself

