as yet unclassified
baseline: spec
	<baseline>
	spec for: #common do: [
		spec
			package: 'PlanetC-Model';
		
			package: 'PlanetC-Model-Tests'
			with: [ spec requires: #('PlanetC-Model') ] ].