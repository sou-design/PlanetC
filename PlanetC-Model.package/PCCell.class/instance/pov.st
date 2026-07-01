accessing
pov
	<pov>
	|colors borderWidth borderColor|
	colors := {
		CMColor white.
		CMColor fromHexString: '00FF00'.
		CMColor fromHexString: '00CC00'.
		CMColor fromHexString: '006400' }.
		
		borderWidth :=0.01. borderColor := CMColor gray.
		
isProtected ifTrue:  [ borderColor := CMColor red. borderWidth :=0.02.].

	^ CMPointOfView new
		color: (colors at: biomassLevel + 1);
		borderWidth: borderWidth ;
		borderColor: borderColor 
		yourself