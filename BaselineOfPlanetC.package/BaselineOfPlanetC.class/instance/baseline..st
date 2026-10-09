as yet unclassified
baseline: spec
	<baseline>
	spec for: #common do: [
		spec
			baseline: 'Cormas'
			with: [ spec repository: 'github://cormas/cormas' ];
			baseline: 'CormasGameServer'
			with: [ spec repository: 'github://cormas/cormas-game-server:main' ].

		spec
			package: 'PlanetC-Model'
			with: [ spec requires: #('Cormas') ];

			package: 'PlanetC-Model-Tests'
			with: [ spec requires: #('PlanetC-Model') ];

			package: 'PlanetC-Model-Game'
			with: [ spec requires: #('PlanetC-Model' 'CormasGameServer') ] ]