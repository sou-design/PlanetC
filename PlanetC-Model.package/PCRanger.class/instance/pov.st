accessing
pov
	<pov> 
	|color|
	color := CMColor black.
	^ CMPointOfView 
		color: color
		shape: #square size: 0.8