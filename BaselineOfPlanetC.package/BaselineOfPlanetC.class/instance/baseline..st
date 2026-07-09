as yet unclassified
baseline: spec
	<baseline>
	spec for: #common do: [
		spec
			baseline: 'CormasGameServer'
			with: [ spec repository: 'github://cormas/cormas-game-server:main' ].

		spec
			package: 'PlanetC-Model'
			with: [ spec requires: #('CormasGameServer') ];

			package: 'PlanetC-Model-Tests'
			with: [ spec requires: #('PlanetC-Model') ] ]