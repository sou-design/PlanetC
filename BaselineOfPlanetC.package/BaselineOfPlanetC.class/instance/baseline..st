as yet unclassified
baseline: spec
	<baseline>
	spec for: #common do: [
		spec
			baseline: 'CormasGameServer'
			with: [ spec repository: 'github://cormas/cormas-game-server:main' ].

		spec
			package: 'PlanetC-Model';

			package: 'PlanetC-Model-Tests'
			with: [ spec requires: #('PlanetC-Model') ];

			package: 'PlanetC-Game'
			with: [ spec requires: #('PlanetC-Model' 'CormasGameServer') ] ]